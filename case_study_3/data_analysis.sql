-- How many customers has Foodie-Fi ever had?
select count(distinct(customer_id))
from subscriptions;
-- What is the monthly distribution of trial plan start_date values for our dataset -
-- use the start of the month as the group by value
select DATE_TRUNC('month', start_date) as start_date,
    count(1)
from subscriptions
where plan_id = 0
group by DATE_TRUNC('month', start_date)
order by start_date;
-- 3. What plan start_date values occur after the year 2020 for our dataset?
-- Show the breakdown by count of events for each plan_name.
with cte as (
    select p.plan_id,
        p.plan_name,
        coalesce(date_part('year', start_date), 0) as year,
        count(1) events_count
    from plans p
        left join subscriptions t1 on p.plan_id = t1.plan_id
        or t1.plan_id is null
    where date_part('year', start_date) >= 2020
    group by p.plan_id,
        p.plan_name,
        year
    order by year,
        plan_id
)
select t1.year,
    p.plan_id,
    coalesce(t2.events_count, 0) as events_count
from (
        select distinct year
        from cte
    ) as t1
    left join plans p on p.plan_id is not null
    left join cte t2 on t1.year = t2.year
    and p.plan_id = t2.plan_id;

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select count(distinct (customer_id)) as customer_count,
       round(count(distinct (customer_id))::decimal / (select count(distinct (customer_id)) from subscriptions) *
             100, 1)                 as percentage
from subscriptions t1
where t1.plan_id = 4;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
with cte1 as (
    select *, rank() over (partition by customer_id order by start_date) as rank
    from subscriptions
),
     cte2 as (
         select customer_id
         from cte1
         where rank = 1
           and plan_id = 0
     ),
     cte3 as (
         select customer_id
         from cte1
         where rank = 2
           and plan_id = 4
     )

select count(1), count(1)::decimal / (select count(distinct customer_id) from subscriptions) * 100 as percentage
from (select *
      from cte3
      intersect
      select *
      from cte2) as t1;

-- What is the number and percentage of customer plans after their initial free trial?
with cte1 as (
    select *, rank() over (partition by customer_id order by start_date) as rank
    from subscriptions
)

select plan_id  as next_plan,
       count(1) as conversions,
       count(1)::decimal / (select count(distinct customer_id) from subscriptions) * 100
from cte1 t1
where rank = 2
group by plan_id;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
with cte1 as (
    select *, rank() over (partition by customer_id order by start_date desc) as rank
    from subscriptions where start_date <= '2020-12-31'
)

select plan_id, count(1) from cte1 where rank = 1 group by plan_id;

-- 8. How many customers have upgraded to an annual plan in 2020?
select count(1)
from subscriptions
where start_date <= '2020-12-31'
  and start_date >= '2020-01-01'
  and plan_id = 3;

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with cte1 as (
    select *, start_date - first_value(start_date) over (partition by customer_id order by start_date) as day_to_annual
    from subscriptions
)

select round(avg(day_to_annual))
from cte1
where plan_id = 3;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
with cte1 as (
    select *, start_date - first_value(start_date) over (partition by customer_id order by start_date) as day_to_annual
    from subscriptions
)
select concat((WIDTH_BUCKET(day_to_annual, 0, 360, 12) - 1) * 30, '-',
              WIDTH_BUCKET(day_to_annual, 0, 360, 12) * 30) day_group,
       count(1)
from cte1
where plan_id = 3
group by day_group;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
with cte1 as (
    select *, lead(plan_id) over (partition by customer_id order by start_date) as next_plan
    from subscriptions
)

select count(1) from cte1 where plan_id = 2 and next_plan = 1;
