-- Using a single SQL query - create a new output table which has the following details:
--
-- How many times was each product viewed?
-- How many times was each product added to cart?
-- How many times was each product added to a cart but not purchased (abandoned)?
-- How many times was each product purchased?
with cte1 as (
    select ph.product_id,
        count(1) views
    from events e
        inner join page_hierarchy ph on e.page_id = ph.page_id
        and e.event_type = 1
    where ph.product_id is not null
    group by ph.product_id
),
cte2 as (
    select ph.product_id,
        count(1) add_to_carts
    from events e
        inner join page_hierarchy ph on e.page_id = ph.page_id
        and e.event_type = 2
    where ph.product_id is not null
    group by ph.product_id
),
cte3 as (
    select ph.product_id,
        count(1) abandoned
    from events e
        inner join page_hierarchy ph on e.page_id = ph.page_id
        and e.visit_id not in (
            select distinct(visit_id)
            from events
            where event_type = 3
        )
        and e.event_type = 2
    where ph.product_id is not null
    group by ph.product_id
),
cte4 as (
    select ph.product_id,
        count(1) purchases
    from events e
        inner join page_hierarchy ph on e.page_id = ph.page_id
        and e.visit_id in (
            select distinct(visit_id)
            from events
            where event_type = 3
        )
        and e.event_type = 2
    where ph.product_id is not null
    group by ph.product_id
)
select t1.product_id,
    views,
    add_to_carts,
    t3.abandoned,
    purchases
from cte1 t1
    inner join cte2 t2 on t1.product_id = t2.product_id
    inner join cte3 t3 on t3.product_id = t2.product_id
    inner join cte4 t4 on t4.product_id = t2.product_id;