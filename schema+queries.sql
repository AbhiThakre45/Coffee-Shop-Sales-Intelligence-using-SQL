CREATE database coffee_project;

use coffee_project;

CREATE TABLE coffee_data (
    transaction_id INT,
    transaction_date DATE,
    transaction_time TIME,
    transaction_qty INT,
    store_id INT,
    store_location VARCHAR(50),
    product_id INT,
    unit_price FLOAT,
    product_category VARCHAR(50),
    product_type VARCHAR(50),
    product_detail VARCHAR(100)
);

Select * from coffee_data limit 10;

select count(*) from coffee_data;

desc coffee_data;

--- check Null value -- 

Select count(*) from coffee_data where transaction_qty is null;

select count(*) from coffee_data where unit_price is null;

select count(*) from coffee_data where product_id is null;

---- check duplicate ---

select transaction_id , count(*) from coffee_data Group by transaction_id having count(*) > 1;


---- Split table for the data modeling  ---

--- Create products table ---

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_category VARCHAR(50),
    product_type VARCHAR(50),
    product_detail VARCHAR(100),
    unit_price FLOAT
);

select * from products;

--- Create store table ---

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_location VARCHAR(50)
);

select * from stores;

--- Create sales table --- 

CREATE TABLE sales (
    transaction_id INT,
    transaction_date DATE,
    transaction_time TIME,
    product_id INT,
    store_id INT,
    transaction_qty INT
);


---- Inseting Data from Main coffee table -----

INSERT INTO products
SELECT 
    product_id,
    MIN(product_category),
    MIN(product_type),
    MIN(product_detail),
    MIN(unit_price)
FROM coffee_data
GROUP BY product_id;

--- insert data in stores table from maine table ---

INSERT INTO stores
SELECT DISTINCT 
    store_id,
    store_location
FROM coffee_data;

---- insert data in sales table from maine table ---

INSERT INTO sales
SELECT 
    transaction_id,
    STR_TO_DATE(transaction_date, '%d-%m-%Y'),
    transaction_time,
    product_id,
    store_id,
    transaction_qty
FROM coffee_data;

select count(*) from products;

select count(*) from stores;

select count(*) from sales;


----- Create New Columns ----
--- Revenue columns ----

Alter Table sales add column revenue float;

SET SQL_SAFE_UPDATES = 0;
UPDATE sales s
JOIN products p ON s.product_id = p.product_id
SET s.revenue = s.transaction_qty * p.unit_price;

--- Create Month columns----

ALTER TABLE sales ADD COLUMN month VARCHAR(10);

UPDATE sales
SET month = DATE_FORMAT(transaction_date, '%Y-%m');

---- Create Hour column ----
ALTER TABLE sales ADD COLUMN hour INT;

UPDATE sales
SET hour = HOUR(transaction_time);


----- EDA Question ----

# Q1 Total Revenue

select sum(revenue) as Total_Revenue from sales;


# Q2 Total Orders

select count(distinct transaction_id) as Total_Orders from sales;

# Q3 Total Quantity Sold

Select sum(transaction_qty) as Total_Quantity_Sold from sales;

# Q4 Avg Orders values

Select sum(revenue) / count(distinct transaction_id) as avg_order_value from sales;

# Q5 Total Product SOld

Select count(distinct product_id) from sales;


# Q6 Top 5 Selling product

SELECT p.product_detail, SUM(s.transaction_qty) AS total_sold
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_detail
ORDER BY total_sold DESC
LIMIT 5;

# Q7 Category wise revenue

SELECT p.product_category, SUM(s.revenue) AS revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_category
ORDER BY revenue DESC;

# Q8 Store wise revenue

SELECT st.store_location, SUM(s.revenue) AS revenue
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY st.store_location
ORDER BY revenue DESC;

# Q9 Monthly Revenue trend

Select month, sum(revenue) as Monthly_Revenue from sales Group by month Order by month;

# Q10 Hours By Sales 

Select hour, sum(revenue) as Total_sales from sales Group by hour Order by Total_sales desc;

# Q11 Peak Sales Hour
Select hour, sum(revenue) as Total_sales from sales Group by hour Order by Total_sales desc limit 1;

# Q12 High Revenue Transactions

SELECT *
FROM sales
WHERE revenue > (
    SELECT AVG(revenue) FROM sales
);


# 13 Sales per hour per store 
SELECT 
    st.store_location,
    s.hour,
    SUM(s.revenue) AS revenue
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY st.store_location, s.hour;

