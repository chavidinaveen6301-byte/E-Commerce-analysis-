use olistdb;
-- 1.  Sales Performance Issues
-- What is the total sales revenue?
select round(sum(payment_value),2) as total_sales_revenue 
from olist_order_payments_dataset;

-- How many orders are completed?
select count(order_id) as completed_orders
from olist_orders_dataset
where order_status = "delivered";

-- What is monthly sales growth?
drop view vw_customer_sales;
CREATE VIEW order_sales AS
SELECT
    c.customer_id,c.customer_unique_id,
    c.customer_city,
    c.customer_state,r.review_score,
    o.order_id,
    p.payment_value sales,
    p.payment_type,
    o.order_status,
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
    join olist_order_reviews_dataset r on r.order_id = o.order_id;
    
   -- monthwise sales  growth
   select order_month,sum(payment_value)
   from vw_customer_sales
   group by order_month
   order by order_month;
   
 select order_month,round(sum(payment_value),2) monthly_sales,
 concat(round((sum(payment_value)-lag(sum(payment_value)) over (order by order_month)) /
 lag(sum(payment_value)) over (order by order_month)*100,2),"%") monthly_sales_growth
 from vw_customer_sales
 group by order_month 
 order by order_month ; 
 
  -- monthwise order  
  select order_month,count(order_id)
from vw_customer_sales
group by order_month
order by  order_month;

-- avg order value
select order_month,round(sum(payment_value)/count(distinct order_id),2) as avg_order_valuea
from vw_customer_sales
group by order_month
order by  order_month;


with monthsales as (select year(o.order_purchase_timestamp) as year,
month(o.order_purchase_timestamp) as month,
round(sum(p.payment_value),2) as revenue
from olist_orders_dataset o join olist_order_payments_dataset p
using(order_id)
where order_status = "delivered"
group by  year(o.order_purchase_timestamp),
month(o.order_purchase_timestamp)
order by year(o.order_purchase_timestamp),
month(o.order_purchase_timestamp))

select month,revenue,concat(round(
(revenue-lag(revenue) over(order by year ,month)) / 
lag(revenue) over(order by year ,month)*100,2),"%" )as previous_revenue
from monthsales;

-- Which states and cities generate the highest revenue?
select customer_city,customer_state,round(sum(payment_value),2) sales
 from vw_customer_sales
 where order_month=5
 group by customer_city,customer_state
 order by sales desc
 limit 10;
 
 -- Which payment methods contribute the most revenue?
select payment_type,sum(payment_value) sales
from vw_customer_sales
group by payment_type
order by sales desc;

--  product categody wise
SELECT
    t.product_category_name_english,
    ROUND(SUM(oi.price),2) AS sales
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE MONTH(o.order_purchase_timestamp)=5
AND o.order_status='delivered'
GROUP BY t.product_category_name_english
ORDER BY sales DESC;

-- customer analysis
-- Total customers
SELECT COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset;

-- repeat vs new customers
 select case when total_orders>1 
 then "repeat customer"
 else "new customer" 
 end as customer_type,
 count(*)
 from ( 
 SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id) t 
group by customer_type;

-- Average Order Value (AOV)
select round(sum(payment_value)/count(distinct order_id),2) as avg_order_valuea
from order_sales;

-- Customer distribution by state
select customer_state,count(distinct customer_unique_id) customers
from order_sales
group by customer_state
order by customers desc;
select customer_city,count(distinct customer_unique_id) customers
from order_sales
group by customer_city
order by customers desc;

-- review score by state and city

select avg(review_score) reviewscore from order_sales;

select customer_state,avg(review_score) review
from order_sales
group by  customer_state
order by review desc;

select customer_city,avg(review_score) review
from order_sales
group by  customer_city
order by review desc;

-- payment mthods
select payment_type,count(order_id) orders
from order_sales
group by payment_type
order by orders desc;
-- Customer purchasing trends over time
select order_month,sum(sales) 
from order_sales
group by order_month
order by order_month;
select dayname(o.order_purchase_timestamp) as daynames,sum(p.payment_value) sales 
from olist_orders_dataset o
join olist_order_payments_dataset p on o.order_id=p.order_id
group by daynames
order by sales;

-- Product Analysis

create view product_analysis as 
select  c.customer_id,c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_id,
    i.price ,
    o.order_status,
    p.product_category_name ,
    i.freight_value,
    pe.product_category_name_english pcn,
    s.seller_id,
    s.seller_city,
    s.seller_state,
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset i
    ON o.order_id = i.order_id
    join olist_products_dataset p on i.product_id=p.product_id
    join product_category_name_translation pe on pe.product_category_name=p.product_category_name
    join olist_sellers_dataset s on s.seller_id=i.seller_id;
    
-- Best-selling product categories
select pcn,count(order_id) orders
from product_analysis 
group by pcn
order by orders desc;

-- Highest revenue categories

select pcn,round(sum(price),2) sales
from product_analysis 
group by pcn
order by sales desc
limit  5;

-- Lowest performing categories
select pcn,count(order_id),round(sum(price),2) sales
from product_analysis 
group by pcn
order by sales 
limit  5;

-- Average product price by category
select pcn,count(order_id),round(avg(price),2) avg_product_price
from product_analysis 
group by pcn
order by avg_product_price desc 
;

-- Products with highest order quantity
select pcn,count(order_id) orders
from product_analysis 
group by pcn
order by orders desc
limit 5;

-- Revenue contribution by category
SELECT
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    concat( ROUND(
        SUM(oi.price) * 100 /
        (SELECT SUM(price) FROM olist_order_items_dataset),
        2
    ),"%") AS revenue_percentage
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;


-- Product sales trend over time
select order_month,sum(price) sales from product_analysis
group by order_month
order by order_month;

-- sellers performance analysis
-- total active sellers
SELECT
    COUNT(DISTINCT oi.seller_id) AS active_sellers
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
    ON oi.order_id = o.order_id
WHERE o.order_delivered_carrier_date IS NOT NULL;

-- top 10 sellers revenue
select round(sum(revenue),2)
from (
select seller_id,sum(price) revenue
from product_analysis
group by seller_id
order by revenue desc
limit 10) t;

-- Top sellers by number of orders
select seller_id top_sellers ,count(order_id) orders
from product_analysis
group by seller_id
having orders >=1000
order by orders desc;

-- Seller distribution by state
select seller_state,count(*) seller_count
from  olist_sellers_dataset
group by seller_state
order by seller_count desc;

-- Average delivery time by seller
select oi.seller_id,round(avg(datediff(o.order_delivered_carrier_date,o.order_purchase_timestamp)),2) delivery_time
from olist_order_items_dataset oi
join olist_orders_dataset o
using(order_id)
where o.order_delivered_carrier_date is not null
group by oi.seller_id;

-- Seller review ratings
select oi.seller_id,count(*) total_reviews,round(avg(r.review_score)) avg_review 
from olist_order_items_dataset oi 
join olist_order_reviews_dataset r
using(order_id)
group by oi.seller_id
order by avg_review desc;

-- Order Analysis Problems
-- Orders experience delays.
select count(*) from olist_orders_dataset;
SELECT
    order_id,
    order_estimated_delivery_date,
    order_delivered_customer_date,
    DATEDIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date
    ) AS delay_days
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
order by delay_days desc;

-- to count delay orders
select count(*) delay_orders 
from olist_orders_dataset
where order_delivered_customer_date > order_estimated_delivery_date
and order_delivered_customer_date is not null;

-- delay percentage
select concat(round(sum(order_delivered_customer_date > order_estimated_delivery_date)/count(*)*100,2),"%") as delay_percentage
from olist_orders_dataset
where order_delivered_customer_date is not null;

-- order sucess rate
SELECT ROUND(SUM(CASE 
                     WHEN order_status = 'delivered' THEN 1 ELSE 0 END)
                     / COUNT(*) * 100,2) AS success_rate
FROM olist_orders_dataset;

-- Order status isn't monitored.
select order_status,count(*) as orders
from olist_orders_dataset
group by order_status
order by orders;

-- Cancellation trends are unknown.
select year(order_purchase_timestamp),
month(order_purchase_timestamp),
count(*) as cancel_orders
from olist_orders_dataset
where order_status = "canceled"
group by year(order_purchase_timestamp),
month(order_purchase_timestamp)
order by year(order_purchase_timestamp),
month(order_purchase_timestamp);

-- monthly orders trend
select year(order_purchase_timestamp),
month(order_purchase_timestamp),
count(*) as orders
from olist_orders_dataset
group by year(order_purchase_timestamp),
month(order_purchase_timestamp)
order by year(order_purchase_timestamp),
month(order_purchase_timestamp);

-- avg delivered days
select avg(datediff(order_delivered_customer_date,order_purchase_timestamp)) as avg_delivered_days
from olist_orders_dataset;

-- 7. Payment Analysis
-- Revenue by payment type
select payment_type,round(sum(payment_value),2) revenue
from olist_order_payments_dataset
group by payment_type
order by revenue desc ;

-- Average payment value
select round(avg(payment_value),2) from olist_order_payments_dataset;

-- Installment distribution
select payment_installments,count(*) payments
from olist_order_payments_dataset
group by payment_installments
order by payments desc;

-- Average installments
select avg(payment_installments) avg_installments
from olist_order_payments_dataset;

-- Revenue by installment range
select payment_installments,case 
							   when 
                                  round(sum(payment_value)) >= 1000000
                                       then concat(round(round(sum(payment_value))/1000000),"m")
                               when 
                                   round(sum(payment_value)) >= 1000
                                       then concat(round(round(sum(payment_value))/1000),"k")
							  else round(sum(payment_value))
                              end as revenue
from olist_order_payments_dataset
group by payment_installments
order by payment_installments;

select payment_type, count(order_id) 
from olist_order_payments_dataset
group by payment_type








