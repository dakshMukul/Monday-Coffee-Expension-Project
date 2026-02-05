-- Monday Coffee -- Data Analysis
SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;

-- Reports & Data Analysis
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
city_name as city, 
population, 
ROUND((population * 0.25)/1000000, 2) as "25 % population in M"
FROM city
ORDER BY 3 DESC;

-- What is the total revenue generated from coffee sales across all cities in last qtr of 2023?
SELECT
	sum(total)
FROM sales
WHere quarter(sale_date) = 4
and year(sale_date) = 2023;

-- - Sales Count for Each Product
-- How many units of each coffee product have been sold

select p.product_name, count(s.sale_id) as "total unit sold"
from products as p
left join sales as s
on s.product_id = p.product_id
group by p.product_name
order by 2 desc;

-- - Average Sales Amount per City
-- What is the average sales amount per customer in each city?

select
	ct.city_name,
    round((sum(s.total)/count(distinct c.customer_id)),2) as "avg sales/customer"
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ct
on c.city_id = ct.city_id
group by ct.city_name
order by 2 desc;

-- City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.

select 
	ct.city_name,
    ct.population,
    ct.population * 0.25 as "estimated consumers"
from city as ct;

-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

select city_name, product_name, sales_volumn
from
(select ct.city_name, p.product_name,
	count(s.sale_id) as sales_volumn,
    row_number() over(partition by ct.city_name order by count(s.sale_id) desc) as rank_in_city
from sales as s
join products as p
on s.product_id = p.product_id
join customers as c
on s.customer_id = c.customer_id
join city as ct
on c.city_id = ct.city_id
group by ct.city_name, p.product_name
) ranked
where rank_in_city <= 3;

-- - Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

select ct.city_name,
	count(distinct c.customer_id) as unique_customers
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ct
on ct.city_id = c.city_id
join products as p
on p.product_id = s.product_id
where p.product_id <= 14
group by ct.city_name
order by unique_customers desc;

-- - Impact of Estimated Rent on Sales
-- Find each city and their average sale per customer and average rent per customer.

select ct.city_name,
		round(sum(s.total)/count(distinct s.customer_id),2) "Total Sales/customer",
        round(avg(ct.estimated_rent)/count(distinct s.customer_id),2) "Rent/customer"
from customers as c
join city as ct
on c.city_id = ct.city_id
join sales s
on c.customer_id = s.customer_id
group by ct.city_name
order by 2 desc;

-- - Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
-- by city
	
with t1 as (
    SELECT 
		ct.city_name as City,
        YEAR(sale_date) AS SaleYear, 
        MONTH(sale_date) AS SaleMonth,
        SUM(total) AS Total_Sales
    FROM sales as s
    join customers as c on c.customer_id = s.customer_id
    join city as ct on c.city_id = ct.city_id
    GROUP BY 1, 2,3
),
growth_ratio as
(
select City, SaleYear, SaleMonth,
		Total_sales as cr_month_sale,
        lag(Total_sales) over(partition by City order by SaleYear, SaleMonth) as prev_month_sale
from t1
)
select City, SaleYear, SaleMonth, 
	round((cr_month_Sale - prev_month_sale) / prev_month_sale * 100,2) as growth_Rate
from growth_ratio;

-- Market Potential Analysis
-- Identify top 3 cities based on highest sales. Return city name, total sales, total rent, total customers,
-- and estimated coffee consumers.
with tbl1 as 
(
select ct.city_name as city_name , 
	sum(s.total) as sales, sum(ct.estimated_rent) as total_rent , count(distinct s.customer_id) as total_customers,
	round((sum(distinct ct.population) * 0.25)/1000000,2) as est_coffee_consumers
from sales as s
join customers as c on s.customer_id = c.customer_id
join city as ct on c.city_id = ct.city_id
group by ct.city_name
order by 2 desc
),
tbl2 as 
(
	select city_name, sales, total_rent, total_customers, est_coffee_consumers,
    rank() over(order by sales desc) as num
    from tbl1
)
select city_name, sales, total_rent, total_customers, est_coffee_consumers, num
from tbl2

/*
Recomendation
City Pune
	1. Total revenue is highest
    2. Total rent is lower then the others
    3. Total estimated coffee consumers are 1.88 M 
City Jaipur
	1. Total revenue is higher then the others
    2. Total rent is lower lowest
    3. Estimated coffee consumers are 1M
City Delhi
	1. Estimated coffee consumers are 7.75 M
    2. Total rent is conperetively less than the other cities which is 29362500
    3. Total customers is 68 which is high then the other cities
*/
