#!/usr/bin/env python3
"""Runs one Airbyte sync: PostgreSQL source connector -> PostgreSQL destination connector.

This talks the Airbyte protocol directly to the official connector Docker images
(airbyte/source-postgres and airbyte/destination-postgres), which is exactly what the
Airbyte platform does for every sync. It also keeps the incremental state between runs.
"""
import json, subprocess, sys, pathlib, time

HERE = pathlib.Path(__file__).resolve().parent
SRC, DST = "airbyte/source-postgres:latest", "airbyte/destination-postgres:latest"
STATE_FILE = HERE / "state.json"

# Big, growing tables sync incrementally. Small lookup tables are fully refreshed.
SYNC_ID = int(time.time())
INCREMENTAL = {"orders": "order_id", "order_items": "order_item_id"}


def docker(image, *args, stdin=False):
    cmd = ["docker", "run", "--rm"] + (["-i"] if stdin else []) + ["-v", f"{HERE}:/data", image, *args]
    return cmd


def discover():
    out = subprocess.run(docker(SRC, "discover", "--config", "/data/source_config.json"),
                         capture_output=True, text=True, check=True).stdout
    for line in out.splitlines():
        if line.startswith('{"type":"CATALOG"'):
            return json.loads(line)["catalog"]
    sys.exit("no catalog returned")


def configure(catalog):
    streams = []
    for s in catalog["streams"]:
        name, cursor = s["name"], INCREMENTAL.get(s["name"])
        streams.append({
            "stream": s,
            "sync_mode": "incremental" if cursor else "full_refresh",
            "destination_sync_mode": "append_dedup" if cursor else "overwrite",
            "cursor_field": [cursor] if cursor else [],
            "primary_key": s.get("source_defined_primary_key") or [],
            # Fields the Airbyte platform normally fills in for the destination. A full refresh
            # gets a newer generation every sync so the destination replaces the old copy;
            # incremental streams stay on generation 0 and keep appending and deduping.
            "generation_id": 0 if cursor else SYNC_ID,
            "minimum_generation_id": 0 if cursor else SYNC_ID,
            "sync_id": SYNC_ID,
        })
    return {"streams": streams}


def main():
    catalog = configure(discover())
    (HERE / "configured_catalog.json").write_text(json.dumps(catalog, indent=2))
    # Same catalog for the destination, but the tables land in a schema called "raw"
    for st in catalog["streams"]:
        st["stream"]["namespace"] = "raw"
    (HERE / "destination_catalog.json").write_text(json.dumps(catalog, indent=2))
    read = docker(SRC, "read", "--config", "/data/source_config.json", "--catalog", "/data/configured_catalog.json")
    if STATE_FILE.exists():
        read += ["--state", "/data/state.json"]
    write = docker(DST, "write", "--config", "/data/destination_config.json",
                   "--catalog", "/data/destination_catalog.json", stdin=True)

    t0 = time.time()
    src = subprocess.Popen(read, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    dst = subprocess.Popen(write, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)

    counts = {}
    for line in src.stdout:
        if line.startswith('{"type":"RECORD"'):
            stream = json.loads(line)["record"]["stream"]
            counts[stream] = counts.get(stream, 0) + 1
            dst.stdin.write(line.replace('"namespace":"public"', '"namespace":"raw"', 1))
        elif line.startswith('{"type":"TRACE"'):
            dst.stdin.write(line.replace('"namespace":"public"', '"namespace":"raw"'))  # stream status updates
        elif line.startswith('{"type":"STATE"'):
            dst.stdin.write(line)  # checkpoints, kept as the source wrote them
    dst.stdin.close()

    states = {}
    for line in dst.stdout:
        if line.startswith('{"type":"TRACE"') and '"ERROR"' in line:
            print("destination error:", json.loads(line)["trace"]["error"]["message"][:400], file=sys.stderr)
        if line.startswith('{"type":"STATE"'):
            st = json.loads(line)["state"]
            key = json.dumps(st.get("stream", {}).get("stream_descriptor", st.get("type")), sort_keys=True)
            states[key] = st
    dst.wait(); src.wait()
    if src.returncode or dst.returncode:
        sys.exit(f"sync failed (source={src.returncode}, destination={dst.returncode})")
    # Like the platform, keep state only for incremental streams. A finished full refresh
    # starts from scratch next time.
    keep = [st for st in states.values()
            if st.get("stream", {}).get("stream_descriptor", {}).get("name") in INCREMENTAL]
    STATE_FILE.write_text(json.dumps(keep, indent=2))

    print(f"Sync finished in {time.time() - t0:.1f}s")
    print(f"{'stream':<16}{'mode':<14}records read")
    for s in sorted(counts):
        print(f"{s:<16}{'incremental' if s in INCREMENTAL else 'full refresh':<14}{counts[s]}")
    print(f"total records: {sum(counts.values())}")


if __name__ == "__main__":
    main()
