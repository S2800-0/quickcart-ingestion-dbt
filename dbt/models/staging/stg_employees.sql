select
    employee_id,
    first_name || ' ' || last_name as employee_name,
    job_title,
    store_id,
    manager_id,
    hire_date
from {{ source('raw', 'employees') }}
