-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? 
-- What is the growth or reduction rate in actual values and percentage of sales?
with cte as (
    select sum(
            case
                when week_date < '2020-06-15'
                and week_date >= '2020-05-15' then sales
            end
        ) as before_change,
        sum(
            case
                when week_date >= '2020-06-15'
                and week_date < '2020-07-12' then sales
            end
        ) as after_change
    from clean_weekly_sales
)
select *,
    after_change - before_change as diff,
    round(
        (after_change - before_change)::decimal / before_change * 100,
        2
    ) as percentage
from cte;
-- 2. What is the total sales for the 12 weeks before and after 2020-06-15? 
-- What is the growth or reduction rate in actual values and percentage of sales?
with cte as (
    select sum(
            case
                when week_date < '2020-06-15'
                and week_date >= '2020-06-15'::date - interval '12 week' then sales
            end
        ) as before_change,
        sum(
            case
                when week_date >= '2020-06-15'
                and week_date < '2020-06-15'::date + interval '12 week' then sales
            end
        ) as after_change
    from clean_weekly_sales
),
cte2 as (
    select sum(
            case
                when week_date < '2019-06-15'
                and week_date >= '2019-06-15'::date - interval '12 week' then sales
            end
        ) as before_change,
        sum(
            case
                when week_date >= '2019-06-15'
                and week_date < '2019-06-15'::date + interval '12 week' then sales
            end
        ) as after_change
    from clean_weekly_sales
),
cte3 as (
    select sum(
            case
                when week_date < '2018-06-15'
                and week_date >= '2018-06-15'::date - interval '12 week' then sales
            end
        ) as before_change,
        sum(
            case
                when week_date >= '2018-06-15'
                and week_date < '2018-06-15'::date + interval '12 week' then sales
            end
        ) as after_change
    from clean_weekly_sales
)
select 2020 as calendar_year,
    *,
    after_change - before_change as diff,
    round(
        (after_change - before_change)::decimal / before_change * 100,
        2
    ) as percentage
from cte
union
select 2019 as calendar_year,*,
    after_change - before_change as diff,
    round(
        (after_change - before_change)::decimal / before_change * 100,
        2
    ) as percentage
from cte2
union
select 2018 as calendar_year, *,
    after_change - before_change as diff,
    round(
        (after_change - before_change)::decimal / before_change * 100,
        2
    ) as percentage
from cte3;