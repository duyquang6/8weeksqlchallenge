-- High Level Sales Analysis

-- What was the total quantity sold for all products?
select sum(qty) total_qty
from sales;
-- What is the total generated revenue for all products before discounts?
select sum(qty * price) total_revenue
from sales;
-- What was the total discount amount for all products?
select sum(qty * price * discount::decimal / 100) total_revenue
from sales;

-- Transaction Analysis
-- How many unique transactions were there?
select count(distinct txn_id)
from sales;
-- What is the average unique products purchased in each transaction?
select avg(count)
from (select count(distinct prod_id) from sales group by txn_id) t1;
-- What are the 25th, 50th and 75th percentile values for the revenue per transaction?

select percentile_cont(0.25) within group ( order by revenue ) revenue_25th,
       percentile_cont(0.5) within group ( order by revenue )  revenue_50th,
       percentile_cont(0.75) within group ( order by revenue ) revenue_75th
from (
         select sum(qty * price) revenue
         from sales
         group by txn_id) t1;

-- What is the average discount value per transaction?
select avg(qty * price * discount::decimal / 100)
from sales
group by txn_id;
-- What is the percentage split of all transactions for members vs non-members?
select (select count(distinct txn_id) from sales where member = true) * 100 ::decimal / count(distinct txn_id),
       (select count(distinct txn_id) from sales where member = false) * 100::decimal / count(distinct txn_id)
from sales;
-- What is the average revenue for member transactions and non-member transactions?
select member, avg(qty * price)
from sales
group by member

-- Product Analysis
-- What are the top 3 products by total revenue before discount?
select prod_id, sum(qty * price) revenue
from sales
group by prod_id
order by revenue desc
limit 3;
-- What is the total quantity, revenue and discount for each segment?
select segment_id,
       sum(qty)                                                    total_qty,
       sum(qty * sales.price)                                   as revenue,
       sum(qty * sales.price * sales.discount :: decimal / 100) as discount_amount
from sales
         inner join product_details pd on sales.price = pd.price
group by pd.segment_id;
-- What is the top selling product for each segment?
with cte as (
    select distinct(segment_id), prod_id, rank() over (partition by segment_id order by product_qty desc) as rank
    from (select prod_id, sum(qty) product_qty
          from sales
          group by prod_id) t1
             inner join product_details pd on pd.product_id = t1.prod_id
)
select segment_id, prod_id
from cte
where rank = 1;

-- What is the total quantity, revenue and discount for each category?
select category_id,
       sum(qty)                                                    total_qty,
       sum(qty * sales.price)                                   as revenue,
       sum(qty * sales.price * sales.discount :: decimal / 100) as discount_amount
from sales
         inner join product_details pd on sales.price = pd.price
group by pd.category_id;

-- What is the top selling product for each category?
with cte as (
    select distinct(category_id), prod_id, rank() over (partition by category_id order by product_qty desc) as rank
    from (select prod_id, sum(qty) product_qty
          from sales
          group by prod_id) t1
             inner join product_details pd on pd.product_id = t1.prod_id
)
select category_id, prod_id
from cte
where rank = 1;

-- What is the percentage split of revenue by product for each segment?

select t1.segment_id,
       t1.product_id,
       round(revenue * 100 ::decimal / sum(revenue) over (partition by t1.segment_id), 2) percentage
from (select segment_id,
             product_id,
             sum(qty * sales.price) as revenue
      from sales
               inner join product_details pd on sales.price = pd.price
      group by segment_id, product_id) as t1;
-- What is the percentage split of revenue by segment for each category?
select t1.category_id,
       t1.segment_id,
       round(revenue * 100 ::decimal / sum(revenue) over (partition by t1.category_id), 2) percentage
from (select category_id,
             segment_id,
             sum(qty * sales.price) as revenue
      from sales
               inner join product_details pd on sales.price = pd.price
      group by category_id, segment_id) as t1;
-- What is the percentage split of total revenue by category?
with total_revenues as (
    select sum(qty * price)
    from sales
)
select category_id, sum(qty * sales.price) * 100:: decimal / (select * from total_revenues) percentage
from sales
         inner join product_details pd on sales.price = pd.price
group by category_id;
-- What is the total transaction “penetration” for each product?
-- (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by
-- total number of transactions)

-- What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
