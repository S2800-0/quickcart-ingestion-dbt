select
    customer_id,
    initcap(first_name) || ' ' || initcap(last_name) as customer_name,
    lower(email) as email,
    phone,
    city,
    state,
    registration_date,
    loyalty_tier
from {{ source('raw', 'customers') }}
