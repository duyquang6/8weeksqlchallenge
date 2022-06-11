-- Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
alter table interest_metrics
ALTER COLUMN month_year TYPE date USING to_date(month_year, 'MM-YYYY');
-- What is count of records in the fresh_segments.interest_metrics
-- for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
select month_year,
    count(1)
from interest_metrics
group by month_year
order by month_year NULLS FIRST;
-- What do you think we should do with these null values in the fresh_segments.interest_metrics
delete from interest_metrics
where interest_id is null
    or month_year is null;
-- How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
select count(distinct imap.id) as not_in_metric,
    count(distinct im.interest_id) as not_in_map
from interest_metrics im
    full outer join interest_map imap on imap.id = im.interest_id
where imap.id is null
    or im.interest_id is null;
-- Summarise the id values in the fresh_segments.interest_map by its total record count in this table
select id,
    count(1)
from interest_map
group by id;
-- What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
select *
from interest_metrics im
    inner join interest_map imap on imap.id = im.interest_id
where imap.id = 21246;
select *
from interest_metrics im
    left join interest_map imap on imap.id = im.interest_id
where imap.id = 21246;
-- Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
select count(1)
from interest_metrics im
    inner join interest_map imap on imap.id = im.interest_id
where month_year < created_at;
