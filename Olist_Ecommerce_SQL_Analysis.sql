/* ============================================================
   OLIST E-COMMERCE DATA ANALYTICS PROJECT
   Tool: MySQL
   Purpose: Customer, Product, Sales, Delivery, Review,
            Payment and Seller Analysis
   ============================================================ */


/* ============================================================
   MODULE 0: DATABASE SETUP
   ============================================================ */

CREATE DATABASE IF NOT EXISTS olist_project;
USE olist_project;


/* ============================================================
   MODULE 1: DATABASE & TABLE SETUP
   ============================================================ */

-- Rename imported tables to shorter, easier names

RENAME TABLE olist_orders_dataset
TO orders;

RENAME TABLE olist_order_items_dataset
TO order_items;

RENAME TABLE olist_order_reviews_dataset
TO order_reviews;

RENAME TABLE olist_order_payments_dataset
TO order_payments;

RENAME TABLE olist_products_dataset
TO products;


/* ============================================================
   MODULE 2: DATASET OVERVIEW
   ============================================================ */

-- Check available tables

SHOW TABLES;


-- Count records in major tables

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT COUNT(*) AS total_order_items
FROM order_items;

SELECT COUNT(*) AS total_products
FROM products;

SELECT COUNT(*) AS total_payments
FROM order_payments;

SELECT COUNT(*) AS total_reviews
FROM order_reviews;


/* ============================================================
   MODULE 3: EXECUTIVE OVERVIEW
   ============================================================ */

-- 3.1 Total Revenue

SELECT
    ROUND(SUM(price), 2) AS total_revenue
FROM order_items;


-- 3.2 Total Orders

SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;


-- 3.3 Total Customers

SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM customers;


-- 3.4 Average Order Value

SELECT
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id;


/* ============================================================
   MODULE 4: CUSTOMER ANALYTICS
   ============================================================ */

-- 4.1 State with the highest number of customers

SELECT
    customer_state,
    COUNT(customer_id) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC
LIMIT 1;


-- 4.2 Most valuable customer based on number of orders

SELECT
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 1;


-- 4.3 Repeat / Loyal Customers

SELECT
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1
ORDER BY total_orders DESC;


-- 4.4 Customer Purchase Frequency

SELECT
    customer_id,
    COUNT(order_id) AS purchase_frequency
FROM orders
GROUP BY customer_id
ORDER BY purchase_frequency DESC;


-- 4.5 One-Time vs Repeat Customers

SELECT
    customer_type,
    COUNT(*) AS total_customers
FROM
(
    SELECT
        customer_id,
        CASE
            WHEN COUNT(order_id) = 1
                THEN 'One-Time Customer'
            ELSE 'Repeat Customer'
        END AS customer_type
    FROM orders
    GROUP BY customer_id
) AS customer_summary
GROUP BY customer_type;


-- 4.6 Customer Retention Rate

SELECT
    ROUND(
        COUNT(
            CASE
                WHEN total_orders > 1 THEN 1
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS retention_rate
FROM
(
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
) AS customer_summary;


-- 4.7 Customer Lifetime Value (CLV)

SELECT
    o.customer_id,
    ROUND(SUM(oi.price), 2) AS customer_lifetime_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY customer_lifetime_value DESC;


/* ============================================================
   MODULE 5: PRODUCT ANALYTICS
   ============================================================ */

-- 5.1 Top 10 Products by Number of Orders

SELECT
    oi.product_id,
    COUNT(oi.order_id) AS units_sold
FROM order_items oi
GROUP BY oi.product_id
ORDER BY units_sold DESC
LIMIT 10;


-- 5.2 Top 5 Products by Revenue

SELECT
    product_id,
    ROUND(SUM(price), 2) AS total_revenue
FROM order_items
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 5;


-- 5.3 Highest Revenue Product

SELECT
    product_id,
    ROUND(SUM(price), 2) AS total_revenue
FROM order_items
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 1;


-- 5.4 Top 5 Product Categories by Revenue

SELECT
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS category_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY category_revenue DESC
LIMIT 5;


-- 5.5 Average Product Price

SELECT
    ROUND(AVG(price), 2) AS average_product_price
FROM order_items;


-- 5.6 Highest Individual Product Price

SELECT
    product_id,
    MAX(price) AS highest_product_price
FROM order_items
GROUP BY product_id
ORDER BY highest_product_price DESC
LIMIT 1;


-- 5.7 Lowest Individual Product Price

SELECT
    product_id,
    MIN(price) AS lowest_product_price
FROM order_items
GROUP BY product_id
ORDER BY lowest_product_price
LIMIT 1;


/* ============================================================
   MODULE 6: SALES & REVENUE ANALYTICS
   ============================================================ */

-- 6.1 Monthly Revenue

SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;


-- 6.2 Revenue by Customer State

SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- 6.3 Highest Revenue State

SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 1;


-- 6.4 Revenue by Product Category

SELECT
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;


-- 6.5 Top 10 Products by Revenue

SELECT
    oi.product_id,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
GROUP BY oi.product_id
ORDER BY total_revenue DESC
LIMIT 10;


-- 6.6 Month-over-Month Revenue Change

SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    ROUND(
        revenue - LAG(revenue) OVER (ORDER BY month),
        2
    ) AS revenue_change
FROM
(
    SELECT
        MONTH(o.order_purchase_timestamp) AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY MONTH(o.order_purchase_timestamp)
) AS monthly_sales
ORDER BY month;


/* ============================================================
   MODULE 7: ORDER & DELIVERY ANALYTICS
   ============================================================ */

-- 7.1 Orders by Status

SELECT
    order_status,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 7.2 Cancellation Rate

SELECT
    ROUND(
        SUM(
            CASE
                WHEN order_status = 'canceled'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate
FROM orders;


-- 7.3 Average Delivery Time in Days

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        0
    ) AS average_delivery_time_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


-- 7.4 Late Deliveries

SELECT
    SUM(
        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_deliveries
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


/* ============================================================
   MODULE 8: CUSTOMER EXPERIENCE / REVIEW ANALYTICS
   ============================================================ */

-- 8.1 Average Review Score

SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM order_reviews;


-- 8.2 Review Score Distribution

SELECT
    review_score,
    COUNT(*) AS number_of_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- 8.3 Total Reviews

SELECT
    COUNT(*) AS total_reviews
FROM order_reviews;


-- 8.4 Customer Satisfaction Rate
-- Satisfaction = 4-star and 5-star reviews

SELECT
    ROUND(
        COUNT(
            CASE
                WHEN review_score IN (4, 5)
                THEN 1
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS satisfaction_rate
FROM order_reviews;


-- 8.5 Average Review Score by Month

SELECT
    MONTH(review_creation_date) AS review_month,
    MONTHNAME(review_creation_date) AS month_name,
    ROUND(AVG(review_score), 2) AS average_review_score
FROM order_reviews
GROUP BY
    MONTH(review_creation_date),
    MONTHNAME(review_creation_date)
ORDER BY review_month;


/* ============================================================
   MODULE 9: PAYMENT ANALYTICS
   ============================================================ */

-- 9.1 Total Payment Revenue

SELECT
    ROUND(SUM(payment_value), 2) AS total_payment_revenue
FROM order_payments;


-- 9.2 Average Payment Value

SELECT
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments;


-- 9.3 Most Used Payment Method

SELECT
    payment_type,
    COUNT(*) AS total_payments
FROM order_payments
GROUP BY payment_type
ORDER BY total_payments DESC
LIMIT 1;


-- 9.4 Revenue by Payment Method

SELECT
    payment_type,
    ROUND(SUM(payment_value), 2) AS revenue_by_payment_method
FROM order_payments
GROUP BY payment_type
ORDER BY revenue_by_payment_method DESC;


-- 9.5 Most Preferred Number of Installments

SELECT
    payment_installments,
    COUNT(*) AS total_payments
FROM order_payments
GROUP BY payment_installments
ORDER BY total_payments DESC
LIMIT 1;


/* ============================================================
   MODULE 10: SELLER PERFORMANCE
   ============================================================ */

-- 10.1 Highest Revenue Seller

SELECT
    seller_id,
    ROUND(SUM(price), 2) AS total_revenue
FROM order_items
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 1;


-- 10.2 Average Product Price by Seller

SELECT
    seller_id,
    ROUND(AVG(price), 2) AS average_product_price
FROM order_items
GROUP BY seller_id
ORDER BY average_product_price DESC;


-- 10.3 Top 5 Sellers by Freight Cost

SELECT
    seller_id,
    ROUND(SUM(freight_value), 2) AS total_freight_cost
FROM order_items
GROUP BY seller_id
ORDER BY total_freight_cost DESC
LIMIT 5;


/* ============================================================
   MODULE 11: TOP CUSTOMER SPENDING
   ============================================================ */

-- Top 10 Customers by Total Spending

SELECT
    o.customer_id,
    ROUND(SUM(op.payment_value), 2) AS total_spent
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 10;


/* ============================================================
   END OF OLIST E-COMMERCE SQL ANALYSIS
   ============================================================ */