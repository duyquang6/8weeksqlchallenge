-- What day of the week is used for each week_date value?
select distinct(week_date),
    to_char(week_date, 'Day')
from clean_weekly_sales;
-- What range of week numbers are missing from the dataset?
SELECT GENERATE_SERIES(1, 52) AS week_number
except
select week_number
from clean_weekly_sales
order by week_number;
-- How many total transactions were there for each year in the dataset?
select calendar_year,
    sum(transactions) as total_trans
from clean_weekly_sales
group by calendar_year;
-- What is the total sales for each region for each month?
select region,
    month_date,
    sum(sales)
from clean_weekly_sales
group by region,
    month_date
order by region,
    month_date;
-- What is the total count of transactions for each platform
select platform,
    sum(transactions) as trans_count
from clean_weekly_sales
group by platform;
-- What is the percentage of sales for Retail vs Shopify for each month?
select platform,
    t1.month_date,
    sum(sales) as sales_count,
    t2.total_sales,
    round(sum(sales)::decimal * 100 / t2.total_sales, 2) as percentage
from clean_weekly_sales t1
    inner join (
        select month_date,
            sum(sales) total_sales
        from clean_weekly_sales
        group by month_date
    ) t2 on t1.month_date = t2.month_date
group by platform,
    t1.month_date,
    t2.total_sales
order by platform,
    t1.month_date;
-- What is the percentage of sales by demographic for each year in the dataset?
select calendar_year,
    round(
        sum(
            case
                when demographic = 'Families' then sales
            end
        )::decimal * 100 / sum(sales),
        2
    ) as family_percentage,
    round(
        sum(
            case
                when demographic = 'Couples' then sales
            end
        )::decimal * 100 / sum(sales),
        2
    ) as couples_percentage,
    round(
        sum(
            case
                when demographic = 'unknown' then sales
            end
        )::decimal * 100 / sum(sales),
        2
    ) as unknown_percentage
from clean_weekly_sales
group by calendar_year
order by calendar_year;
-- Which age_band and demographic values contribute the most to Retail sales?
select age_band
from clean_weekly_sales
where platform = 'Retail'
group by age_band
order by sum(sales) desc
limit 1;
select demographic
from clean_weekly_sales
where platform = 'Retail'
group by demographic
order by sum(sales) desc
limit 1;
-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify?
-- If not - how would you calculate it instead?
select platform,
    calendar_year,
    avg(avg_transaction),
    sum(sales) / sum(transactions)
from clean_weekly_sales
group by platform,
    calendar_year
order by platform,
    calendar_year;