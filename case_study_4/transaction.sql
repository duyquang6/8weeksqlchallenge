-- What is the unique count and total amount for each transaction type?
select txn_type, count(1), sum(txn_amount)
from customer_transactions
group by txn_type;
-- What is the average total historical deposit counts and amounts for all customers?
select avg(cnt), avg(avg_amount)
from (
         select count(1) as cnt, avg(txn_amount) avg_amount
         from customer_transactions cn
         where txn_type = 'deposit'
         group by customer_id
     ) t1;
-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
select month, count(distinct customer_id)
from (select customer_id,
             to_char(txn_date, 'yyyy-mm')                             as month,
             sum(case when txn_type = 'deposit' then 1 else 0 end)    as deposit_count,
             sum(case when txn_type = 'purchase' then 1 else 0 end)   as purchase_count,
             sum(case when txn_type = 'withdrawal' then 1 else 0 end) as withdrawal_count
      from customer_transactions cn
      group by customer_id, month) t1
where deposit_count > 1
  and (purchase_count >= 1 or withdrawal_count >= 1)
group by month;

-- What is the closing balance for each customer at the end of the month?
select customer_id,
       date_part('month', txn_date)                                             as month,
       sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) as closing_balance
from customer_transactions cn
group by customer_id, month
order by customer_id, month;
-- What is the percentage of customers who increase their closing balance by more than 5%?
with cte as (
    select distinct customer_id,
                    month,
                    0 closing_balance
    from customer_transactions cn,
         (
             select distinct(date_part('month', txn_date)) as month
             from customer_transactions cn
         ) t1
),
     cte1 as (
         select cte.customer_id,
                cte.month,
                coalesce(t1.closing_balance, 0) closing_balance
         from cte
                  left join (
             select customer_id,
                    date_part('month', txn_date) as month,
                    sum(
                            case
                                when txn_type = 'deposit' then txn_amount
                                else - txn_amount
                                end
                        )                        as closing_balance
             from customer_transactions cn
             group by customer_id,
                      month
             order by customer_id,
                      month
         ) t1 on t1.customer_id = cte.customer_id
             and t1.month = cte.month
         order by cte.customer_id,
                  cte.month
     ),
     cte2 as (
         select *, lead(closing_balance) over (partition by customer_id order by month) next_closing_balance from cte1
     )

select distinct(customer_id),
               closing_balance,
               next_closing_balance,
               ROUND((next_closing_balance - closing_balance)::decimal * 100 / closing_balance, 2) as diff_percentage
from cte2
where closing_balance > 0
  and ROUND((next_closing_balance - closing_balance)::decimal * 100 / closing_balance, 2) > 5;
  