-- set default schema on query
set search_path = clique_bait;
-- How many users are there?
select count(distinct user_id)
from users;
-- How many cookies does each user have on average?
select user_id,
    count(1)
from users
group by user_id;
-- What is the unique number of visits by all users per month?
select to_char(event_time, 'yyyy-mm') as month,
    count(distinct visit_id)
from events
group by month;
-- What is the number of events for each event type?
select ei.event_name,
    count(1)
from events ev
    inner join event_identifier ei on ev.event_type = ei.event_type
group by ei.event_name;
-- What is the percentage of visits which have a purchase event?
select count(distinct (visit_id))::decimal * 100 / (
        select count(distinct (visit_id))
        from events
    )
from events
where event_type = 3;
-- What is the percentage of visits which view the checkout page but do not have a purchase event?
select count(distinct visit_id)::decimal * 100 / (
        select count(distinct visit_id)
        from events
    )
from (
        select t2.visit_id
        from (
                select visit_id,
                    (
                        case
                            when event_type = 1
                            and page_id = 12 then true
                            else false
                        end
                    ) as is_checkout,
                    (
                        case
                            when event_type = 3 then true
                            else false
                        end
                    ) as is_payment
                from events
            ) as t2
        group by t2.visit_id
        having bool_or(is_checkout) = true
            and bool_or(is_payment) = false
    ) t1;
-- What are the top 3 pages by number of views?
select ph.page_name,
    count(1) views_count
from events e
    inner join page_hierarchy ph on e.page_id = ph.page_id
group by ph.page_name
order by views_count desc
limit 3;
-- What is the number of views and cart adds for each product category?
select product_category,
    ei.event_name,
    count(1) as views
from events e
    inner join page_hierarchy ph on e.page_id = ph.page_id
    inner join event_identifier ei on e.event_type = ei.event_type
where ph.product_category is not null
group by product_category,
    ei.event_type,
    ei.event_name
order by product_category,
    ei.event_type;
-- What are the top 3 products by purchases?
select ph.product_id,
    count(1) purchases
from events e
    inner join event_identifier ei on e.event_type = ei.event_type
    and e.event_type = 2
    and e.visit_id in (
        select distinct(visit_id)
        from events
        where event_type = 3
    )
    inner join page_hierarchy ph on e.page_id = ph.page_id
group by ph.product_id
order by purchases desc
limit 3;