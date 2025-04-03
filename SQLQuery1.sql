use olist_store;

select * from pname;
select * from customers;
select * from geolocation;
select * from  orderitems;
select * from orders;
DELETE FROM orders
WHERE order_id IN (96476, 96477, 96478, 96479); -- 

WITH OrderedRows AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
    FROM 
        orders
)
DELETE FROM OrderedRows
WHERE RowNum BETWEEN 96476 AND 96479;

select * from payments;
select * from products;
select * from reviews;
select * from sellers;

SELECT 
    CASE 
        WHEN DATENAME(WEEKDAY, o.order_purchase_timestamp) IN ('Saturday', 'Sunday') 
        THEN 'Weekend' 
        ELSE 'Weekday' 
    END AS order_day_type,
    COUNT(DISTINCT p.order_id) AS total_orders,
    SUM(p.payment_value) AS total_payments,
    AVG(p.payment_value) AS avg_payment_value,
    p.payment_type,
    COUNT(*) AS payment_count
FROM orders o
JOIN payments p 
    ON o.order_id = p.order_id
GROUP BY 
    CASE 
        WHEN DATENAME(WEEKDAY, o.order_purchase_timestamp) IN ('Saturday', 'Sunday') 
        THEN 'Weekend' 
        ELSE 'Weekday' 
    END,
    p.payment_type
ORDER BY payment_type;


SELECT 
    SUM(payment_value) AS total_payment
FROM 
    payments;

SELECT 
    SUM(p.payment_value) AS total_payment
FROM 
    payments p
JOIN 
    orders o ON p.order_id = o.order_id;

select sum(p.payment_value) as TOT_PAYMENTS
from payments p
join orders o on o.order_id=p.order_id;

SELECT 
    SUM(p.payment_value) AS TOT_PAYMENTS 
FROM 
    orders o 
LEFT JOIN 
    payments p ON o.order_id = p.order_id;


SELECT 
    SUM(p.payment_value) AS TOT_PAYMENTS 
FROM 
    orders o
INNER JOIN 
    payments p ON o.order_id = p.order_id; -- 


SELECT 
SUM(p.payment_value) AS TOT_PAYMENTS 
FROM 
    orders o
INNER JOIN 
    payments p ON o.order_id = p.order_id;

	SELECT 
    p.order_id, 
    p.payment_value
FROM 
    payments p
left JOIN 
    orders o ON p.order_id = o.order_id
WHERE 
    o.order_id IS NULL; -- null values as these are not in orders table 



-- Check data type in orders table
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders' AND COLUMN_NAME = 'order_id';

-- Check data type in payments table
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'payments' AND COLUMN_NAME = 'order_id';


SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders' AND COLUMN_NAME = 'order_id';

SELECT 
SUM(CAST(p.payment_value AS FLOAT)) AS total_payments from
    orders o
INNER JOIN 
    payments p ON o.order_id = p.order_id;

	ALTER TABLE payments
ALTER COLUMN payment_value NVARCHAR(50);  -- Adjust the size as needed


SELECT DATA_TYPE 
FROM OLIST_store.INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'payments';

select * from payments;

ALTER TABLE payments
ALTER COLUMN order_id NVARCHAR(50);

ALTER TABLE payments
ALTER COLUMN payment_sequential INT;

ALTER TABLE payments
ALTER COLUMN payment_type NVARCHAR(20);

ALTER TABLE payments
ALTER COLUMN payment_installments INT;

ALTER TABLE payments
ALTER COLUMN payment_value float;


select * from orders;
SELECT DATA_TYPE 
FROM OLIST_store.INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'orders';

ALTER TABLE orders
ALTER COLUMN order_id NVARCHAR(50);

ALTER TABLE orders
ALTER COLUMN weekend_weekday nvarchar(50) ;

--ALTER TABLE orders
--ALTER COLUMN `shipping days` int;

ALTER TABLE orders
ALTER COLUMN [shipping days] INT;


SELECT 
SUM(p.payment_value) AS TOT_PAYMENTS 
FROM 
    orders o
INNER JOIN 
    payments p ON o.order_id = p.order_id;


SELECT 
SUM(p.payment_value) AS TOT_PAYMENTS 
FROM 
    payments p
left JOIN 
    orders o ON o.order_id = p.order_id; --- note the difference it will
	--return all order ids inpayments table even if not on orders table

SELECT 
SUM(p.payment_value) AS TOT_PAYMENTS 
FROM 
    payments p
right JOIN 
    orders o ON o.order_id = p.order_id; --- note the difference right join
	

SELECT 
SUM(p.payment_value) AS TOT_PAYMENTS 
FROM 
    payments p
	JOIN 
    orders o ON o.order_id = p.order_id;

	SELECT 
SUM(p.payment_value) AS TOT_PAYMENTS 
FROM 
    orders o
left JOIN     payments p ON o.order_id = p.order_id; --- note it returns same as the inner join 

select * from payments;

SELECT COUNT(order_id)
FROM payments; 


SELECT COUNT(order_id)
FROM payments
HAVING COUNT(order_id) > 1;

select * from payments;

SELECT COUNT(*) AS duplicate_order_count
FROM (
    SELECT order_id
    FROM payments
    GROUP BY order_id
    HAVING COUNT(order_id) > 1) AS duplicates; --This will return the total number of unique order_ids that have duplicates. 
-- Returns the number of orders that have more than one payment.


SELECT order_id 
    FROM payments
    GROUP BY order_id
    HAVING COUNT(order_id) > 1;


SELECT COUNT(*) AS duplicate_order_count
FROM (
    SELECT order_id
    FROM payments
    GROUP BY order_id
    HAVING COUNT(order_id) > 1)x; 

SELECT o.order_id, p.payment_value
FROM orders AS o
left JOIN payments AS p ON o.order_id = p.order_id; -- example of alias in joins inner join from orders table to payments table

--Where and Having 

select * from payments;

SELECT  payment_type ,sum(payment_value) AS PAYMENTS
FROM payments
WHERE PAYMENT_VALUE>1000 -- WHERE IS APPLIED BEFORE AGGREGATION
GROUP BY  payment_typE 
HAVING SUM(payment_value)> 25000  --HAVING IS APPLIED AFTER AGGREGATION - NOW NO VOUCHER-  
ORDER BY PAYMENT_TYPE;  


SELECT 
    order_id,PAYMENT_TYPE,
    payment_value,
    ROW_NUMBER() OVER (ORDER BY payment_value DESC) AS RowNum,
    RANK() OVER (ORDER BY payment_value DESC) AS RankNum,
    DENSE_RANK() OVER (ORDER BY payment_value DESC) AS DenseRankNum
FROM payments;

SELECT ORDER_ID,PAYMENT_TYPE,PAYMENT_vALUE FROM PAYMENTS ORDER BY 3 DESC;

SELECT MAX(payment_value) 
FROM payments 
WHERE payment_value < (SELECT MAX(payment_value) FROM payments);

SELECT payment_value 
FROM payments 
ORDER BY payment_value DESC 
LIMIT 1 OFFSET 1;

SELECT DISTINCT payment_value
FROM payments
ORDER BY payment_value DESC
OFFSET 1 ROW FETCH NEXT 1 ROW ONLY;

--CTE common table expression 

    SELECT payment_type, SUM(payment_value) AS total_payment
    FROM payments
    GROUP BY payment_type order by 2 desc;

WITH PaymentData AS (
    SELECT payment_type, SUM(payment_value) AS total_payment
    FROM payments
    GROUP BY payment_type
)
SELECT * 
FROM PaymentData 
WHERE total_payment > 250000;


select * from payments ;
select * from orders;

SELECT o.order_id, SUM(p.payment_value) AS total
FROM orders as o
join payments p on o.order_id = p.order_id
GROUP BY o.order_id
ORDER BY total DESC; -- clearly shows group by usage 
 

SELECT SUM(p.payment_value) AS total_payment
FROM orders o JOIN payments p ON o.order_id = p.order_id;

SELECT SUM(payment_value) AS total_payment FROM PAYMENTS;


SELECT SUM(p.payment_value) AS excluded_payments
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL; - important interview question 

SELECT SUM(p.payment_value) AS total_payments , sum (oi.price) AS total_price , sum(oi.freight_value) as freigh_value
FROM payments p jOIN orderitems oi ON p.order_id = oi.order_id JOIN ORDERS O ON O.ORDER_ID=P.ORDER_ID;

SELECT SUM(FREIGHT_VALUE) AS total_FREIGHT FROM ORDERITEMS;