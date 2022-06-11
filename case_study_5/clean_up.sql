SET search_path = data_mart;
create table if not exists clean_weekly_sales (
    week_date date,
    week_number integer,
    month_date integer,
    calendar_year integer,
    region varchar(13),
    platform varchar(7),
    segment varchar(36),
    age_band varchar(36),
    demographic varchar(36),
    customer_type varchar(8),
    transactions integer,
    sales integer,
    avg_transaction decimal
);
with cte as (
    select to_date(week_date, 'DD/MM/YY') as week_date,
        region,
        platform,
        segment,
        customer_type,
        transactions,
        sales
    from weekly_sales
)
insert into clean_weekly_sales (
        select week_date,
            extract(
                'week'
                from week_date
            ) as week_number,
            extract(
                'month'
                from week_date
            ) as month_date,
            extract(
                'year'
                from week_date
            ) as calendar_year,
            region,
            platform,
            (
                case
                    when segment = 'null' then 'unknown'
                    else segment
                end
            ),
            (
                case
                    when substring(segment, 2) = '1' then 'Young Adults'
                    when substring(segment, 2) = '2' then 'Middle Aged'
                    when substring(segment, 2) in ('3', '4') then 'Retirees'
                    else 'unknown'
                end
            ) as age_band,
            (
                case
                    when substring(segment, 1, 1) = 'C' then 'Couples'
                    when substring(segment, 1, 1) = 'F' then 'Families'
                    else 'unknown'
                end
            ) as demographic,
            customer_type,
            transactions,
            sales,
            round(sales::decimal / transactions, 2) as avg_transaction
        from cte
    );