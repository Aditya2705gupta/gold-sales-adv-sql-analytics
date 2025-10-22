create database Gold ; 
use Gold;

select * from gold_customers;
select * from gold_products ; 
select* from gold_facts_sales;

DELETE
from gold_facts_sales where order_date = '' order by order_date  ; 








select
year(order_date) as order_year, 
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold_facts_sales 
group by year(order_date)
order by year(order_date) ; 

select
year(order_date) as order_year, 
month(order_date) as order_month, 
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold_facts_sales 
group by year(order_date), month(order_date)
order by year(order_date), month(order_date) ; 


select
date_format(order_date, '%Y-%m-01') as order_date, 
month(order_date) as order_month, 
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold_facts_sales 
group by date_format(order_date, '%Y-%m-01'), month(order_date)
order by date_format(order_date,'%Y-%m-01'), month(order_date);










-- cumulative analysis 
select 
order_date,
total_sales,
sum(total_sales) over(order by order_date) as running_total_sales
from
(select 
month(order_date) as order_date, 
sum(sales_amount) as total_sales
from gold_facts_sales
where order_date is not null
group by month(order_date)
order by month(order_date)) as t ;


select 
order_date,
total_sales,
sum(total_sales) over(order by order_date) as running_total_sales,
avg(avg_price) over(order by order_date) as moving_averageprice
from
(select 
year(order_date) as order_date, 
sum(sales_amount) as total_sales,
avg(price) as avg_price
from gold_facts_sales
where order_date is not null
group by year(order_date)
order by year(order_date)) as t ;










-- performance analysis 
-- analye the yearly performance of sales to both average sales performance of produces and previous years sales

with yearly_product_sales as (
select 
year(f.order_date) as order_year, 
p.product_name,
sum(f.sales_amount) as current_sales
from gold_facts_sales as f
left join gold_products as p
on f.product_key = p.product_key
where f.order_date is not null 
group by year(f.order_date),
p.product_name ) 


select
order_year, 
product_name,
current_sales, 
round(avg(current_sales) over(partition by product_name),0) as avg_sales,
round(current_sales - avg(current_sales) over(partition by product_name),0) as diff_avg,
case 
	when round(current_sales - avg(current_sales) over(partition by product_name),0) >0 then 'Above Avg'
    when round(current_sales - avg(current_sales) over(partition by product_name),0) < 0 then 'Below Avg'
	else 'Avg'
end avg_change,
lag(current_sales) over(partition by product_name order by order_year) as prev_year_sales,
current_sales - lag(current_sales) over(partition by product_name order by order_year) as diff_prev_yr,
case 
	when lag(current_sales) over(partition by product_name order by order_year) >0 then 'Increase'
    when lag(current_sales) over(partition by product_name order by order_year) < 0 then 'Decrease'
	else 'No change'
end prev_yr_change
from yearly_product_sales 
order by product_name, order_year;










-- part to whole analysis 
-- which category contribute to overall sales the most 

with category_sales as (
select 
category, 
sum(sales_amount) as total_sales
from gold_facts_sales as f
left join gold_products as p 
on f.product_key = p.product_key
group by category)

select 
category,
category,
sum(total_sales) over() as overall_sales,
concat(round((total_sales/sum(total_sales) over()) *100,2),'%') as percentagr_of_total
from category_sales
order by total_sales desc ;










-- Data Segmentation 
-- segment products in to cost ranges and count how many segments fall into each segment 

with product_segments as (select  
product_key,
product_name, 
cost,
case 
	when cost < 100 then 'Below 100'
	when cost between 100 and 500 then '100-500'
	when cost between 500 and 1000 then '500-1000'
    else 'Above 1000'
end cost_range
from gold_products)

select
cost_range, 
count(product_key) as total_products
from product_segments
group by cost_range
order by total_products desc ;










with customer_spending as (
select 
c.customer_key, 
sum(f.sales_amount) as total_spending, 
min(order_date) as first_order,
max(order_date) as last_date,
timestampdiff(month, min(order_date), max(order_date)) as lifespan
from gold_facts_sales as f 
left join gold_customers as c
on f.customer_key = c.customer_key 
group by c.customer_key) 

select
customer_segment,
count(customer_key) as total_customers
from (
	select
	customer_key,
	case
		when lifespan >= 12 and total_spending > 5000 then 'VIP'
		when lifespan > 12 and total_spending <= 5000 then 'Regular'
		else 'New'
	end customer_segment
	from customer_spending) t 
group by customer_segment
order by total_customers desc ;










create view gold_report_customers as(

-- Build Customer Reports 
with base_query as(
select 
f.order_number,
f.product_key,
f.order_date, 
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name, ' ', c.last_name) as cust_name,
timestampdiff(year, c.birthdate, now()) as age
from gold_facts_sales as f 
left join gold_customers as c
on f.customer_key = c.customer_key )

, customer_aggregation as (
select
	customer_key,
	customer_number,
	cust_name,
	age, 
	count(distinct order_number) as total_number,
	sum(sales_amount) as total_sales, 
	sum(quantity) as total_quantity, 
	count(distinct product_key) as total_products, 
	max(order_date) as last_order, 
	timestampdiff(month, min(order_date), max(order_date)) as lifespan
from base_query 
group by 
	customer_key,
	customer_number,
	cust_name,
	age 
    )

select 
customer_key,
customer_number,
cust_name,
age,
case
	when age < 20 then 'Under 20'
    when age between 20 and 29 then '20-29'
	when age between 30 and 39 then '30-39'
    when age between 40 and 49 then '40-49'
    else 'above 50'
end age_group,     
case
	when lifespan >= 12 and total_sales > 5000 then 'VIP'
	when lifespan > 12 and total_sales <= 5000 then 'Regular'
	else 'New'
end customer_segment,
last_order, 
timestampdiff(month, last_order, now()) as recency,
total_number,
total_sales, 
total_quantity, 
total_products, 
lifespan,
-- calculating average order vaalue
case
	when total_number= 0 then 0 
	else total_sales/total_number 
end as avg_order_value ,
-- calculating averaage monthly spend
case
	 when lifespan = 0 then total_sales 
     else total_sales/lifespan
end as avg_monthly_spend     

from customer_aggregation
);



select* from gold_report_customers
