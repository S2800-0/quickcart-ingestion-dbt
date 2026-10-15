select
    order_item_id,
    order_id,
    product_id,
    quantity,
    cast(price_per_unit as numeric(12, 2)) as price_per_unit,
    cast(quantity * price_per_unit as numeric(12, 2)) as line_revenue
from {{ source('raw', 'order_items') }}
