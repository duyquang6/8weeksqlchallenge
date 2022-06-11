-- Which interests have been present in all month_year dates in our dataset?
select count(1)
from (
        select 1
        from interest_metrics im
        group by im.interest_id
        having count(distinct month_year) = (
                select count(distinct month_year)
                from interest_metrics
            )
    ) t1;
-- Using this same total_months measure - calculate the cumulative percentage of
-- all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
select percentile_cont(0.9) within group (
        order by cnt desc
    )
from (
        select count(distinct month_year) as cnt
        from interest_metrics im
        group by im.interest_id
    ) t1;
-- If we were to remove all interest_id values
-- which are lower than the total_months value we found in the previous question -
-- how many total data points would we be removing?
select count(1)
from interest_metrics
where interest_id in (
        select interest_id
        from interest_metrics im
        group by im.interest_id
        having count(distinct month_year) < 6
    );
-- Does this decision make sense to remove these data points from a business perspective?
-- Use an example where there are all 14 months present to a removed interest example for your arguments -
-- think about what it means to have less months present from a segment perspective.
-- After removing these interests - how many unique interests are there for each month?
select month_year,
    count(distinct interest_id)
from interest_metrics im
where interest_id not in (
        select interest_id
        from interest_metrics im
        group by im.interest_id
        having count(distinct month_year) < 6
    )
group by month_year;