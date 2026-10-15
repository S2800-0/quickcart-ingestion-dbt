select
    c.customer_id,
    c.customer_name,
    c.email,
    c.city,
    c.state,
    c.registration_date,
    c.loyalty_tier,
    count(distinct case when o.order_status <> 'cancelled' then o.order_id end) as orders_placed,
    coalesce(sum(case when o.order_status <> 'cancelled' then o.order_revenue end), 0) as lifetime_revenue
from {{ ref('stg_customers') }} c
left join {{ ref('fct_orders') }} o using (customer_id)
group by 1, 2, 3, 4, 5, 6, 7
