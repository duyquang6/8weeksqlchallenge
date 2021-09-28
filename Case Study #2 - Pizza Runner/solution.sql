-- How many pizzas were ordered?
select count(distinct(order_id)) from pizza_runner.customer_orders;

-- How many unique customer orders were made?
SELECT customer_id, COUNT(order_id) AS unique_orders
FROM pizza_runner.customer_orders
GROUP BY customer_id;

-- How many successful orders were delivered by each runner?
select t1.runner_id, count(distinct(t1.order_id)) from pizza_runner.runner_orders t1
inner join pizza_runner.customer_orders t2 on t1.order_id = t2.order_id
where t1.distance <> 'null'
group by t1.runner_id;

-- How many of each type of pizza was delivered?
select t2.pizza_id, count(distinct(t1.order_id)) from pizza_runner.runner_orders t1
inner join pizza_runner.customer_orders t2 on t1.order_id = t2.order_id
where t1.distance <> 'null'
group by t2.pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?
select t3.pizza_name, count(t1.order_id) from pizza_runner.runner_orders t1
inner join pizza_runner.customer_orders t2 on t1.order_id = t2.order_id
inner join pizza_runner.pizza_names t3 on t3.pizza_id = t2.pizza_id
where t3.pizza_name in ('Meatlovers','Vegetarian')
group by t3.pizza_name;

-- What was the maximum number of pizzas delivered in a single order?
with cte1 as (
  select t1.order_id, count(*) from pizza_runner.customer_orders t1
  inner join pizza_runner.runner_orders t2 on t1.order_id = t2.order_id
  where t2.distance <> 'null'
  group by t1.order_id
)
select order_id, count, row_number() over(order by count desc) from cte1 limit 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes? no idea what it is

-- How many pizzas were delivered that had both exclusions and extras?
select count(t1.order_id) from pizza_runner.runner_orders t1
inner join pizza_runner.customer_orders t2 on t1.order_id = t2.order_id
where t1.distance <> 'null' and t2.exclusions is not null and t2.extras is not null and t2.exclusions not in ('null','') and t2.extras in ('null','')

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT DATE_PART('hour', t1.order_time), count(t1.order_id)
FROM pizza_runner.customer_orders t1
GROUP BY DATE_PART('hour', t1.order_time);
                         
-- What was the volume of orders for each day of the week?
SELECT to_char(t1.order_time, 'Day'), count(t1.order_id)
FROM pizza_runner.customer_orders t1
GROUP BY to_char(t1.order_time, 'Day');
