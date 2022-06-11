delete from interest_metrics
where interest_id in (
        select interest_id
        from interest_metrics im
        group by im.interest_id
        having count(distinct month_year) < 6
    );
-- Using our filtered dataset by removing the interests with less than 6 months worth of data,
-- which are the top 10 and bottom 10 interests which have the largest composition values in any month_year?
-- Only use the maximum composition value for each interest but you must keep the corresponding month_year
select interest_id,
    ROUND(sum(composition)::decimal, 1) as total_composition_values
from interest_metrics
group by interest_id
order by total_composition_values
limit 10;
select interest_id,
    ROUND(sum(composition)::decimal, 1) as total_composition_values
from interest_metrics
group by interest_id
order by total_composition_values desc
limit 10;
-- Which 5 interests had the lowest average ranking value?
select interest_id,
    avg(ranking) avg_rank
from interest_metrics
group by interest_id
order by avg_rank
limit 5;
-- Which 5 interests had the largest standard deviation in their percentile_ranking value?
select interest_id,
    stddev(percentile_ranking) pr_std
from interest_metrics
group by interest_id
order by pr_std desc
limit 5;
-- For the 5 interests found in the previous question -
-- what was minimum and maximum percentile_ranking values for each interest and
-- its corresponding year_month value? Can you describe what is happening for these 5 interests?
with cte as (
    select interest_id,
        stddev(percentile_ranking) pr_std,
        max(percentile_ranking) max_pr,
        min(percentile_ranking) min_pr
    from interest_metrics
    group by interest_id
    order by pr_std desc
    limit 5
)
select *,
    (
        select month_year
        from interest_metrics t2
        where t2.interest_id = t1.interest_id
            and t2.percentile_ranking = t1.max_pr
    ) as max_pr_date,
    (
        select month_year
        from interest_metrics t2
        where t2.interest_id = t1.interest_id
            and t2.percentile_ranking = t1.min_pr
    ) as min_pr_date
from cte t1;
-- How would you describe our customers in this segment based off their composition and ranking values?
-- What sort of products or services should we show to these customers and what should we avoid?