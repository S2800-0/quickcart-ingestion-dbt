select
    product_id,
    product_name,
    category,
    subcategory,
    supplier,
    cast(unit_price as numeric(12, 2)) as unit_price,
    cast(cost_price as numeric(12, 2)) as cost_price,
    stock_quantity
from {{ source('raw', 'products') }}
