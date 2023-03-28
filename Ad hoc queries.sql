Atliq Hardware Consumer Goods Ad hoc Request Project challenge

1) Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.

SELECT market
FROM dim_customer
where customer = "Atliq Exclusive" and 
region = "APAC";


2) What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields,
  unique_products_2020
  unique_products_2021
  percentage_chg


with cte1 as (select 
count(distinct (product_code)) as unique_product_2020
from fact_sales_monthly
where fiscal_year = 2020),
cte2 as (select
count(distinct(product_code)) as unique_product_2021
from fact_sales_monthly
where fiscal_year = 2021)

select unique_product_2020,
	   unique_product_2021,
       round((unique_product_2021-
       unique_product_2020)*100/
       unique_product_2020,2) as
       percentage_change
from cte1
join cte2;



3) Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. The final output contains 2 fields
  segment,
  product_count

select segment,
count(distinct product_code) as product_count
from dim_product
group by segment
order by product_count desc;


4) Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields,
  segment
  product_count_2020
  product_count_2021
  difference


with cte1 as (
select p.segment,
count(distinct (p.product_code)) 
as unique_product_2020
from dim_product p
join fact_sales_monthly fs 
on p.product_code=fs.product_code
where fiscal_year = 2020
group by segment),

cte2 as (
select p.segment,
count(distinct (p.product_code)) 
as unique_product_2021
from dim_product p
join fact_sales_monthly fs  
on p.product_code=fs.product_code
where fiscal_year = 2021
group by segment)

select segment,
       unique_product_2020,
       unique_product_2021,
       (unique_product_2021-unique_product_2020) as diff
from cte1
join cte2
using (segment)
order by diff desc;


5) Get the products that have the highest and lowest manufacturing costs.The final output should contain these fields,
  product_code
  product
  manufacturing_cost


select 	p.Product_code,
	p.product,
        m.manufacturing_cost
from dim_product p
join fact_manufacturing_cost m
on p.product_code=m.product_code
where manufacturing_cost = (select max(manufacturing_cost) from fact_manufacturing_cost)
        or
      manufacturing_cost = (select min(manufacturing_cost) from fact_manufacturing_cost)
      order by manufacturing_cost desc;
        

6) Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the 
  Indian market. The final output contains these fields,
  customer_code
  customer
  average_discount_percentage


select c.customer_code,
       c.customer,
       round(avg(pre_invoice_discount_pct),2) as avg_discount_per
from dim_customer c
join fact_pre_invoice_deductions p
on c.customer_code=p.customer_code
where fiscal_year = 2021 and 
market = "india"
group by customer_code
order by avg_discount_per desc
limit 5;


7) Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and 
  high-performing months and take strategic decisions. The final report contains these columns:
  Month
  Year
  Gross sales Amount


select month(date) as Month, 
year(date) as Year, round((sum(fgp.gross_price*fsm.sold_quantity)),2) as Gross_sales_Amount 
from fact_gross_price fgp
join fact_sales_monthly fsm on fsm.product_code=fgp.product_code
join dim_customer dm on fsm.customer_code=dm.customer_code
where customer="Atliq Exclusive"
group by Month, Year
order by Year;


8) In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the 
  total_sold_quantity,
  Quarter
  total_sold_quantity


select 
	case
		when month(date) in (9,10,11) then
        "Q1"
        when month(date) in (12,1,2) then
        "Q2"
        when month(date) in (3,4,5) then
        "Q3"
        when month(date) in (6,7,8) then
        "Q4"
  end as quarter,
sum(sold_quantity) as total_sold_quantity
from fact_sales_monthly
where fiscal_year = 2020
group by quarter
order by total_sold_quantity desc;


9) Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? The final output contains these fields,
  channel
  gross_sales_mln
  percentage


with cte1 as (
select channel,
       round(sum((gross_price*sold_quantity)/1000000),2) as gross_sales_mln
from fact_sales_monthly fsm
join fact_gross_price fgp
using (product_code)
join dim_customer
using (customer_code)
where fsm.fiscal_year = 2021
group by channel
order by gross_sales_mln desc)

select channel,
       gross_sales_mln,
       round(gross_sales_mln*100/sum(gross_sales_mln) over(),2) as percentage
from cte1
order by percentage desc;


10) Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these fields,
    division
    product_code
    product
    total_sold_quantity
    rank_order



with cte1 as(
select p.division,
       p.product_code,
       p.product,
       sum(fsm.sold_quantity) 
       as total_sold_quantity
from dim_product p
join fact_sales_monthly fsm
on p.product_code = fsm.product_code
where fsm.fiscal_year = 2021
group by p.product_code),

cte2 as (
	select *,
        dense_rank () over 
        (partition by division order by total_sold_quantity desc) as
        rank_order
from cte1)
select *
from cte2
where rank_order<=3;
