-- Report table: revenue per store per month, cancelled orders excluded.
select
    s.store_id,
    s.store_name,
    s.region,
    o.order_month,
    count(*) as orders,
    sum(o.units) as units,
    sum(o.order_revenue) as revenue
from {{ ref('fct_orders') }} o
join {{ ref('stg_stores') }} s using (store_id)
where o.order_status <> 'cancelled'
group by 1, 2, 3, 4
