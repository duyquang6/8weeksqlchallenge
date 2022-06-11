-- How many unique nodes are there on the Data Bank system?
select count(distinct node_id)
from customer_nodes;
-- What is the number of nodes per region?
select region_name, count(distinct node_id) node_count
from customer_nodes cn
         inner join regions r on cn.region_id = r.region_id
group by region_name;
-- How many customers are allocated to each region?
select region_name, count(distinct customer_id) node_count
from customer_nodes cn
         inner join regions r on cn.region_id = r.region_id
group by region_name;
-- How many days on average are customers reallocated to a different node?
with cte as (
    select *
    from customer_nodes
    where end_date <> '9999-12-31'
)
select ROUND(avg(end_date - start_date), 2)
from cte;
-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
select percentile_cont(0.5) within group ( order by end_date - start_date )  as median,
       percentile_cont(0.8) within group ( order by end_date - start_date )  as percentile_80,
       percentile_cont(0.95) within group ( order by end_date - start_date ) as percentile_95
from customer_nodes
group by region_id;
