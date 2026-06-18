-- 1. Создаём схемы
CREATE SCHEMA IF NOT EXISTS dim;
CREATE SCHEMA IF NOT EXISTS fact;

-- 2. Измерения (dim)
DROP TABLE IF EXISTS dim.dim_customer;
CREATE table dim.dim_customer AS
SELECT 
    customer_id,
    full_name AS name,
    email,
    phone,
    city,
    created_at::DATE AS registration_date
FROM dds.customers;

DROP TABLE IF EXISTS dim.dim_product;
CREATE TABLE dim.dim_product AS
SELECT 
    product_id,
    product_name AS name,
    category,
    price,
    currency,
    is_active
FROM dds.products;

DROP TABLE IF EXISTS dim.dim_date;
CREATE TABLE dim.dim_date AS
SELECT DISTINCT
    order_timestamp::DATE AS date_id,
    EXTRACT(YEAR FROM order_timestamp) AS year,
    EXTRACT(MONTH FROM order_timestamp) AS month,
    EXTRACT(DAY FROM order_timestamp) AS day,
    EXTRACT(QUARTER FROM order_timestamp) AS quarter,
    TO_CHAR(order_timestamp, 'YYYY-MM') AS year_month
FROM dds.orders
WHERE order_timestamp IS NOT NULL

UNION

SELECT DISTINCT
    payment_timestamp::DATE AS date_id,
    EXTRACT(YEAR FROM payment_timestamp) AS year,
    EXTRACT(MONTH FROM payment_timestamp) AS month,
    EXTRACT(DAY FROM payment_timestamp) AS day,
    EXTRACT(QUARTER FROM payment_timestamp) AS quarter,
    TO_CHAR(payment_timestamp, 'YYYY-MM') AS year_month
FROM dds.payments
WHERE payment_timestamp IS NOT NULL

UNION

SELECT DISTINCT
    event_timestamp::DATE AS date_id,
    EXTRACT(YEAR FROM event_timestamp) AS year,
    EXTRACT(MONTH FROM event_timestamp) AS month,
    EXTRACT(DAY FROM event_timestamp) AS day,
    EXTRACT(QUARTER FROM event_timestamp) AS quarter,
    TO_CHAR(event_timestamp, 'YYYY-MM') AS year_month
FROM dds.events
WHERE event_timestamp IS NOT NULL;

-- 3. Факты (fact)
DROP TABLE IF EXISTS fact.fact_orders;
CREATE TABLE fact.fact_orders AS
SELECT 
	order_timestamp::DATE AS date_id,
	order_id,
	customer_id,
	product_id,
	quantity,
	unit_price,
	currency,
	order_timestamp,
	status
FROM dds.orders;

DROP TABLE IF EXISTS fact.fact_events;
CREATE TABLE fact.fact_events AS
SELECT 
	event_timestamp::DATE AS date_id,
	event_id,
	customer_id,
	event_type,
	event_timestamp,
	product_id
FROM dds.events;

DROP TABLE IF EXISTS fact.fact_payments;
CREATE TABLE fact.fact_payments AS
SELECT 
	payment_timestamp::DATE AS date_id,
	payment_id,
	order_id,
	payment_method,
	amount,
	currency,
	payment_timestamp
FROM dds.payments;