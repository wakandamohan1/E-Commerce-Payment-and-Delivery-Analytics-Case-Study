--Olist E-Commerce Payment and Delivery Analytics – SQL Queries

--🧾 Section 1: Data Preview & Basic Checks
--1.1 View all tables
USE OLIST_store;

SELECT * FROM pname;
SELECT * FROM customers;
SELECT * FROM geolocation;
SELECT * FROM orderitems;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT * FROM products;
SELECT * FROM reviews;
SELECT * FROM sellers;


--🧹 Section 2: Data Cleanup & Type Handling
--2.1 Delete specific rows from orders

DELETE FROM orders
WHERE order_id IN (96476, 96477, 96478, 96479);

--2.2 Delete rows using ROW_NUMBER()

WITH OrderedRows AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
    FROM orders
)
DELETE FROM OrderedRows
WHERE RowNum BETWEEN 96476 AND 96479;

--2.3 Check data types of key columns
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders' AND COLUMN_NAME = 'order_id';

SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'payments' AND COLUMN_NAME = 'order_id';

--2.4 Change data types if necessary

ALTER TABLE payments ALTER COLUMN order_id NVARCHAR(50);
ALTER TABLE payments ALTER COLUMN payment_sequential INT;
ALTER TABLE payments ALTER COLUMN payment_type NVARCHAR(20);
ALTER TABLE payments ALTER COLUMN payment_installments INT;
ALTER TABLE payments ALTER COLUMN payment_value FLOAT;

ALTER TABLE orders ALTER COLUMN order_id NVARCHAR(50);
ALTER TABLE orders ALTER COLUMN [shipping days] INT;
ALTER TABLE orders ALTER COLUMN weekend_weekday NVARCHAR(50);

--💳 Section 3: Payment KPIs

--3.1 Total payments (multiple ways to write)

SELECT SUM(p.payment_value) AS total_payment
FROM orders o
INNER JOIN payments p ON o.order_id = p.order_id;

SELECT SUM(p.payment_value) AS total_payment
FROM payments p
JOIN orders o ON p.order_id = o.order_id;

--3.2 Compare inner, left, right joins

SELECT SUM(p.payment_value) AS total_payment
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id;

SELECT SUM(p.payment_value) AS total_payment
FROM payments p
RIGHT JOIN orders o ON o.order_id = p.order_id;


--3.3 Payments from unmatched orders (important interview Q)
SELECT SUM(p.payment_value) AS excluded_payments
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


--3.4 Payment breakdown by day type and type
SELECT 
    CASE 
        WHEN DATENAME(WEEKDAY, TRY_CAST(o.order_purchase_timestamp AS DATETIME)) IN ('Saturday', 'Sunday') THEN 'Weekend' 
        ELSE 'Weekday' 
    END AS order_day_type,
    p.payment_type,
    COUNT(DISTINCT p.order_id) AS total_orders,
    COUNT(*) AS payment_count,
    SUM(p.payment_value) AS total_payments,
    AVG(p.payment_value) AS avg_payment_value
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE TRY_CAST(o.order_purchase_timestamp AS DATETIME) IS NOT NULL
GROUP BY 
    CASE 
        WHEN DATENAME(WEEKDAY, TRY_CAST(o.order_purchase_timestamp AS DATETIME)) IN ('Saturday', 'Sunday') THEN 'Weekend' 
        ELSE 'Weekday' 
    END,
    p.payment_type
ORDER BY order_day_type ;



--3.5 Payment amount by type with filters (HAVING/WHERE)

SELECT payment_type, SUM(payment_value) AS PAYMENTS
FROM payments
WHERE payment_value > 1000
GROUP BY payment_type
HAVING SUM(payment_value) > 25000
ORDER BY payment_type;

--🏅 Section 4: Ranking & Window Functions

--4.1 Rank orders by payment value
SELECT 
    order_id, payment_type, payment_value,
    ROW_NUMBER() OVER (ORDER BY payment_value DESC) AS RowNum,
    RANK() OVER (ORDER BY payment_value DESC) AS RankNum,
    DENSE_RANK() OVER (ORDER BY payment_value DESC) AS DenseRankNum
FROM payments;

--4.2 Get the 2nd highest payment
SELECT MAX(payment_value) second_highest
FROM payments 
WHERE payment_value < (SELECT MAX(payment_value) FROM payments);

--OR

SELECT payment_value 
FROM payments 
ORDER BY payment_value DESC 
OFFSET 1 ROW FETCH NEXT 1 ROW ONLY;


--📊 Section 5: CTE & Aggregation Usage

--5.1 Basic CTE to filter high-value types

WITH PaymentData AS (
    SELECT payment_type, SUM(payment_value) AS total_payment
    FROM payments
    GROUP BY payment_type
)
SELECT * FROM PaymentData 
WHERE total_payment > 250000;


--📋 Section 6: Duplicate Payments Check

--6.1 Find count of duplicate order_ids in payments

SELECT COUNT(*) AS duplicate_order_count
FROM (
    SELECT order_id
    FROM payments
    GROUP BY order_id
    HAVING COUNT(order_id) > 1
) AS duplicates;


--6.2 List all duplicated order_ids

SELECT order_id
FROM payments
GROUP BY order_id
HAVING COUNT(order_id) > 1;


--🔍Simple Example showing the above
--You aim to:

--Count how many order_ids appear more than once in the payments table.

--List all order_ids that have duplicates.

--🧪 Sample Data
--Consider the following entries in the payments table:


--order_id	payment_value
--1001	500.00
--1002	300.00
--1003	450.00
--1001	200.00
--1004	700.00
--1002	150.00
--1005	600.00
--In this dataset:

--order_id 1001 appears twice.

--order_id 1002 appears twice.

--Other order_ids appear only once.




--📦 Section 7: Price & Freight Analysis

--7.1 Payment, price & freight combined

SELECT 
    SUM(p.payment_value) AS total_payments, 
    SUM(oi.price) AS total_price, 
    SUM(oi.freight_value) AS freight_value
FROM payments p 
JOIN orderitems oi ON p.order_id = oi.order_id 
JOIN orders o ON o.order_id = p.order_id;


--7.2 Total freight value
SELECT SUM(freight_value) AS total_freight 
FROM orderitems;


--🗂 Section 8: Group By Examples

--8.1 Payments by order_id

SELECT o.order_id, SUM(p.payment_value) AS total
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id
ORDER BY total DESC;

--8.2 Payments by payment_type

SELECT payment_type, SUM(payment_value) AS total_payment
FROM payments
GROUP BY payment_type
ORDER BY total_payment DESC;

--✅ KPI 1: Weekday vs Weekend Payment Statistics
 
 SELECT
  CASE
    WHEN DATEPART(WEEKDAY, o.order_purchase_timestamp) IN (1, 7) THEN 'Weekend'
    ELSE 'Weekday'
  END AS day_type,
  COUNT(DISTINCT o.order_id) AS total_orders,
  SUM(p.payment_value) AS total_payment_value,
  AVG(p.payment_value) AS avg_payment_value,
  p.payment_type,
  COUNT(p.payment_type) AS payment_type_count
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY
  CASE
    WHEN DATEPART(WEEKDAY, o.order_purchase_timestamp) IN (1, 7) THEN 'Weekend'
    ELSE 'Weekday'
  END,
  p.payment_type;


--9.  KPI 2: Count of Orders with Review Score 5 and Payment Type as Credit Card

SELECT COUNT(DISTINCT o.order_id) AS high_rating_credit_card_orders
FROM orders o
JOIN reviews r ON o.order_id = r.order_id
JOIN payments p ON o.order_id = p.order_id
WHERE r.review_score = 5 AND p.payment_type = 'credit_card';

-- this is an example where multiple joins is used 

--✅ KPI 3: Average Delivery Time for Pet Shop Products

SELECT AVG(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_delivery_days
FROM orders o
JOIN orderitems oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category_name = 'pet_shop';


--✅ KPI 4: Average Order Price and Payment Amount for Customers in São Paulo

SELECT
  AVG(oi.price) AS avg_order_price,
  AVG(p.payment_value) AS avg_payment_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN orderitems oi ON o.order_id = oi.order_id
JOIN payments p ON o.order_id = p.order_id
WHERE c.customer_city = 'Sao Paulo';

--✅ KPI 5: Relationship Between Shipping Days and Review Scores

SELECT
  r.review_score,
  AVG(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_shipping_days
FROM orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;

--- to check data type 
--SELECT COLUMN_NAME, DATA_TYPE
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME = 'orders';
--order_id	nvarchar
--customer_id	varchar
--order_status	varchar
--order_purchase_timestamp	varchar
--order_approved_at	varchar
--order_delivered_carrier_date	varchar
--order_delivered_customer_date	varchar
--order_estimated_delivery_date	varchar
--weekend_weekday	nvarchar
--SHIPPING DAYS	int


  SET LANGUAGE British;  -- or SET LANGUAGE French

 -- 1) Identify any non‑convertible strings
SELECT order_id, order_purchase_timestamp
FROM orders
WHERE ISDATE(order_purchase_timestamp) = 0;

SELECT order_id, order_delivered_customer_date
FROM orders
WHERE ISDATE(order_delivered_customer_date) = 0;


select * from orders;
-- 3) Change the columns’ data types


ALTER TABLE orders
  ALTER COLUMN order_purchase_timestamp      datetime2 NULL;

ALTER TABLE orders
  ALTER COLUMN order_delivered_customer_date datetime2 NULL;

  -- the above was a very important step !!! notes 

--  datetime2

--This is a built‑in SQL Server data type for storing both a date and a time.

--Compared with the older datetime type, datetime2 can store dates from year 0001 to 9999, and lets you choose a precision up to 7 decimal places for the seconds (e.g. “2025‑04‑18 14:23:12.1234567”).

--NULL

--That keyword right after the type means “this column is allowed to be empty.”

--If you insert a row without providing a value for that column, SQL Server will store a special NULL marker rather than rejecting the row.

--By contrast, if you declared it NOT NULL, every row must have a valid date/time value.

--So when you ran:

--ALTER TABLE orders
--  ALTER COLUMN order_purchase_timestamp datetime2 NULL;
--you told SQL Server:

--Change order_purchase_timestamp so that from now on it holds true datetime/time values (with datetime2 precision).

--Allow rows that don’t have a date for that field (they’ll show up as NULL).

--<<<<ADDITIONAL QUERIES >>>>

--1. Top 5 Customer States by Number of Orders

SELECT TOP 5
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS num_orders
FROM orders o
JOIN customers c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY num_orders DESC;

--2. Top 5 Products by Total Sales Revenue

SELECT TOP 5
  p.product_id,
  p.product_category_name,
  SUM(oi.price) AS total_revenue
FROM orderitems oi
JOIN products p
  ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_category_name
ORDER BY total_revenue DESC;


--3. Top 5 Customers by Total Spending

SELECT TOP 5
  o.customer_id,
  SUM(p.payment_value) AS total_spent
FROM payments p
JOIN orders o
  ON p.order_id = o.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC;


--4. Top 5 States by Total Payment Value

SELECT TOP 5
  c.customer_state,
  SUM(p.payment_value) AS total_payments
FROM payments p
JOIN orders o
  ON p.order_id = o.order_id
JOIN customers c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_payments DESC;


--5. Top 5 Sellers by Number of Orders Fulfilled

SELECT TOP 5
  s.seller_id,
  s.seller_city,
  COUNT(DISTINCT oi.order_id) AS orders_fulfilled
FROM orderitems oi
JOIN sellers s
  ON oi.seller_id = s.seller_id
GROUP BY s.seller_id, s.seller_city
ORDER BY orders_fulfilled DESC;

--note - WE WILL GET THE SAME ANSWER IF WE JUST PUT SELLER ID ONLY AND GROUP BY SELLER ID 

--6. Top 5 Product Categories by Average Review Score


 SELECT TOP 5
  p.product_category_name,
  AVG(r.review_score) AS avg_review_score
FROM reviews r
JOIN orderitems oi
  ON r.order_id = oi.order_id
JOIN products p
  ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY avg_review_score DESC;

--- notice the correct  review !!! above one was not converted to the correct data type 
SELECT TOP 5
  p.product_category_name,
  ROUND(AVG(CAST(r.review_score AS float)), 2) AS avg_review_score
FROM reviews r
JOIN orderitems oi ON r.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY avg_review_score DESC;




-- CONVERT REVIEW SCORE TO FLOAT 

--7. Top 5 Customers with Most 5‑Star Reviews

SELECT TOP 5
  o.customer_id,
  COUNT(*) AS five_star_count
FROM reviews r
JOIN orders o
  ON r.order_id = o.order_id
WHERE r.review_score = 5
GROUP BY o.customer_id
ORDER BY five_star_count DESC;


--8 Top 5 States by Fastest Average Delivery Time

SELECT TOP 5
  c.customer_state,
  AVG(DATEDIFF(
    DAY,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date
  )) AS avg_delivery_days
FROM orders o
JOIN customers c
  ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days ASC;


--9. Top 5 Payment Types by Total Amount and Count

SELECT TOP 5
  p.payment_type,
  COUNT(*) AS payment_count,
  SUM(p.payment_value) AS total_amount
FROM payments p
GROUP BY p.payment_type
ORDER BY total_amount DESC;

-- WITH JOIN ON ORDERS ✅ Query 9 using JOIN and assuming star schema:We’ll need to join: orders (fact table) , order_items (to get product IDs) products (to get category name)

SELECT TOP 5
  p.payment_type,
  COUNT(*) AS payment_count,
  SUM(p.payment_value) AS total_payment_amount
FROM payments p
JOIN orders o ON p.order_id = o.order_id
GROUP BY p.payment_type
ORDER BY total_payment_amount DESC;





-- 10 Top 5 Purchase Dates by Order Volume


-- CONVERT DATETIME TO GET DATE !!! 

SELECT TOP 5
  CAST(o.order_purchase_timestamp AS date) AS purchase_date,
  COUNT(*) AS order_count
FROM orders o
GROUP BY CAST(o.order_purchase_timestamp AS date)
ORDER BY order_count DESC;


-- IN CONVERT METHOD 

SELECT TOP 5
  CONVERT(date, o.order_purchase_timestamp) AS purchase_date,
  COUNT(*) AS order_count
FROM orders o
GROUP BY
  CONVERT(date, o.order_purchase_timestamp)
ORDER BY
  order_count DESC;

