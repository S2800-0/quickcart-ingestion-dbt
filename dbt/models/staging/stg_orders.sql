select
    order_id,
    order_date,
    customer_id,
    employee_id,
    store_id,
    lower(status) as order_status,
    cast(shipping_fee as numeric(12, 2)) as shipping_fee
from {{ source('raw', 'orders') }}
