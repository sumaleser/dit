CREATE SCHEMA IF NOT EXISTS mart;
CREATE OR REPLACE VIEW mart.v_top_customers AS
SELECT 
    c.customer_id,
    c.name AS customer_name,
    c.city,
    SUM(o.quantity * o.unit_price) AS total_spent,
    COUNT(DISTINCT o.order_id) AS orders_count
FROM fact.fact_orders o
JOIN dim.dim_customer c ON o.customer_id = c.customer_id
WHERE o.customer_id > 0  -- исключаем Unknown (0) и Invalid (-1)
GROUP BY c.customer_id, c.name, c.city
ORDER BY total_spent DESC
LIMIT 10;

CREATE OR REPLACE VIEW mart.v_revenue_by_month AS
SELECT 
    d.year_month,
    d.year,
    d.month,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(o.quantity * o.unit_price) AS total_revenue,
    AVG(o.quantity * o.unit_price) AS avg_order_value
FROM fact.fact_orders o
JOIN dim.dim_date d ON o.date_id = d.date_id
WHERE o.customer_id > 0
GROUP BY d.year_month, d.year, d.month
ORDER BY d.year, d.month;

CREATE OR REPLACE VIEW mart.v_top_products AS
SELECT 
    p.product_id,
    p.name AS product_name,
    p.category,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(o.quantity) AS total_quantity_sold,
    SUM(o.quantity * o.unit_price) AS total_revenue
FROM fact.fact_orders o
JOIN dim.dim_product p ON o.product_id = p.product_id
WHERE o.product_id > 0
GROUP BY p.product_id, p.name, p.category
ORDER BY total_quantity_sold DESC
LIMIT 10;

CREATE OR REPLACE VIEW mart.v_top5_last_activity AS
WITH top_customers AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS orders_count
    FROM fact.fact_orders
    WHERE customer_id > 0
    GROUP BY customer_id
    ORDER BY orders_count DESC
    LIMIT 5
)
SELECT 
    tc.customer_id,
    c.name AS customer_name,
    tc.orders_count,
    MAX(o.order_timestamp) AS last_activity_date
FROM top_customers tc
JOIN fact.fact_orders o ON tc.customer_id = o.customer_id
JOIN dim.dim_customer c ON tc.customer_id = c.customer_id
GROUP BY tc.customer_id, c.name, tc.orders_count
ORDER BY tc.orders_count DESC;

CREATE OR REPLACE VIEW mart.v_customers_without_orders AS
SELECT 
    c.customer_id,
    c.name AS customer_name,
    c.email,
    c.phone,
    c.city,
    c.registration_date
FROM dim.dim_customer c
LEFT JOIN fact.fact_orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
  AND c.customer_id > 0  -- исключаем служебные записи
ORDER BY c.customer_id;