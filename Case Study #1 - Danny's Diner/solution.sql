/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
select customer_id, sum(m.price) from dannys_diner.sales as s inner join dannys_diner.menu as m on m.product_id = s.product_id group by s.customer_id;
-- 2. How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) from dannys_diner.sales as s group by customer_id
-- 3. What was the first item from the menu purchased by each customer?
select customer_id, (select product_id from dannys_diner.sales s1 where s.customer_id = s1.customer_id order by order_date asc limit 1) from dannys_diner.sales s group by s.customer_id
with cte1 as(
	select customer_id, product_id, 
        row_number() over(partition by customer_id order by order_date) row_num 
    from dannys_diner.sales  
) 
select customer_id, product_id from cte1 where row_num = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_id, count(*) from dannys_diner.sales group by product_id order by count desc limit 1;
-- 5. Which item was the most popular for each customer?
with cte5 as(
  select distinct(customer_id), product_id, 
  		count(*) over(partition by (customer_id, product_id)) 
	from dannys_diner.sales order by customer_id asc, count desc
),
cte6 as(
  select customer_id, 
	product_id, 
	row_number() over(partition by customer_id order by count desc) from cte5
)
select customer_id, product_id from cte6 where row_number=1;
-- 6. Which item was purchased first by the customer after they became a member?
with cte6 as( 
  select m.customer_id, s.product_id, m.join_date, s.order_date, 
      row_number() over(partition by m.customer_id order by order_date asc)
  from dannys_diner.sales as s 
  inner join dannys_diner.members m 
  on m.customer_id = s.customer_id 
  where m.join_date <= s.order_date
)
select * from cte6 where row_number=1; 
-- 7. Which item was purchased just before the customer became a member?
with cte7 as ( 
  select m.customer_id, s.product_id, m.join_date, s.order_date, 
      row_number() over(partition by m.customer_id order by order_date desc)
  from dannys_diner.sales as s 
  inner join dannys_diner.members m 
  on m.customer_id = s.customer_id 
  where m.join_date > s.order_date
)
select * from cte7 where row_number=1;
-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id, sum(menu.price), count(s.product_id)
from dannys_diner.sales as s 
inner join dannys_diner.members m 
on m.customer_id = s.customer_id 
inner join dannys_diner.menu menu
on menu.product_id = s.product_id
where m.join_date > s.order_date
group by s.customer_id;
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id, 
	sum(case when menu.product_name='sushi' then 2 * menu.price else menu.price end) as points
from dannys_diner.sales as s 
inner join dannys_diner.members m 
on m.customer_id = s.customer_id 
inner join dannys_diner.menu menu
on menu.product_id = s.product_id
group by s.customer_id;
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select s.customer_id, 
	sum(case when menu.product_name='sushi' then 2 * menu.price 
	when m.join_date <= s.order_date and s.order_date - m.join_date <= 6
	then 2 * menu.price
	else menu.price end) as points
from dannys_diner.sales as s 
inner join dannys_diner.members m 
on m.customer_id = s.customer_id 
inner join dannys_diner.menu menu
on menu.product_id = s.product_id
group by s.customer_id;

