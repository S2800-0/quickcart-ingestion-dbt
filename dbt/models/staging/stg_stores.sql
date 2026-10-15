select
    store_id,
    store_name,
    city,
    state,
    region,
    opening_date
from {{ source('raw', 'stores') }}
