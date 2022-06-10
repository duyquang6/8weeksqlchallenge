select *
from subscriptions t1
    inner join plans p on t1.plan_id = p.plan_id;
-- Customer journey of first 8 users
select *,
    rank() over (
        order by customer_id
    )
from subscriptions t1
    inner join plans p on t1.plan_id = p.plan_id
where customer_id <= (
        select distinct(customer_id)
        from subscriptions
        order by customer_id
        limit 1 offset 7
    )
order by customer_id,
    start_date;