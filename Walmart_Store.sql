CREATE DATABASE Walmart;
USE Walmart;

CREATE TABLE Walmart_sales(
 transaction_id INT PRIMARY KEY,
 customer_id INT,
 product_id INT,
 product_name VARCHAR(50),
 category VARCHAR(30),
 quantity_sold INT,
 unit_price DECIMAL(10, 2),
 transaction_date DATE,
 store_id INT,
 store_location VARCHAR(100),
 inventory_level INT,
 reorder_point INT,
 reorder_quantity INT,
 supplier_id INT,
 supplier_lead_time INT,
 customer_age INT,
 customer_gender VARCHAR(20),
 customer_income DECIMAL(12, 2),
 customer_loyalty_level VARCHAR(20),
 payment_method VARCHAR(20),
 promotion_applied VARCHAR(5),
 promotion_type VARCHAR(30),
 weather_conditions VARCHAR(10),
 holiday_indicator VARCHAR(10),
 weekday Varchar(10),
 stockout_indicator VARCHAR(5),
 forecasted_demand INT,
 actual_demand INT
);

-- IMPORTED DATA INTO TABLE Walmart_sales USING 'TABLE DATA IMPORT WIZARD'

SELECT * FROM Walmart_sales;

-- DATA CLEANING & PREPARING

-- CHEECK DUPLICATES IN TRANSACTION ID
SELECT transaction_id, count(*) 
FROM Walmart_sales
GROUP BY transaction_id
HAVING COUNT(*) >1;

-- CHECK NULL VALUES
SELECT COUNT(*),
  SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS transaction_id,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id,
  SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id,
  SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS product_name,
  SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category,
  SUM(CASE WHEN quantity_sold IS NULL THEN 1 ELSE 0 END) AS quantity_sold,
  SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price,
  SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS transaction_date,
  SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS store_id,
  SUM(CASE WHEN store_location IS NULL THEN 1 ELSE 0 END) AS store_location,
  SUM(CASE WHEN inventory_level IS NULL THEN 1 ELSE 0 END) AS inventory_level,
  SUM(CASE WHEN reorder_point IS NULL THEN 1 ELSE 0 END) AS reorder_point,
  SUM(CASE WHEN reorder_quantity IS NULL THEN 1 ELSE 0 END) AS reorder_quantity,
  SUM(CASE WHEN supplier_id IS NULL THEN 1 ELSE 0 END) AS supplier_id,
  SUM(CASE WHEN supplier_lead_time IS NULL THEN 1 ELSE 0 END) AS supplier_lead_time,
  SUM(CASE WHEN customer_age IS NULL THEN 1 ELSE 0 END) AS customer_age,
  SUM(CASE WHEN customer_gender IS NULL THEN 1 ELSE 0 END) AS customer_gender,
  SUM(CASE WHEN customer_income IS NULL THEN 1 ELSE 0 END) AS customer_income,
  SUM(CASE WHEN customer_loyalty_level IS NULL THEN 1 ELSE 0 END) customer_loyalty_level,
  SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS payment_method,
  SUM(CASE WHEN promotion_applied IS NULL THEN 1 ELSE 0 END) AS promotion_applied,
  SUM(CASE WHEN promotion_type IS NULL THEN 1 ELSE 0 END) AS promotion_type,
  SUM(CASE WHEN weather_conditions IS NULL THEN 1 ELSE 0 END) AS weather_conditions,
  SUM(CASE WHEN holiday_indicator IS NULL THEN 1 ELSE 0 END) AS holiday_indicator,
  SUM(CASE WHEN weekday IS NULL THEN 1 ELSE 0 END) AS weekday,
  SUM(CASE WHEN stockout_indicator IS NULL THEN 1 ELSE 0 END) AS stockout_indicator,
  SUM(CASE WHEN forecasted_demand IS NULL THEN 1 ELSE 0 END) AS forecasted_demand,
  SUM(CASE WHEN actual_demand IS NULL THEN 1 ELSE 0 END) AS actual_demand
FROM walmart_sales;

-- CREATE NEW COLUMNS
-- 1. ADD COLUMN total_revenue
ALTER TABLE Walmart_sales ADD COLUMN total_revenue DECIMAL(12, 2);
UPDATE Walmart_sales SET total_revenue = quantity_sold * unit_price;

SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;

-- 2. ADD Month, YEAR COLUMN 
ALTER TABLE Walmart_sales ADD COLUMN transaction_month VARCHAR(20);
ALTER TABLE Walmart_sales ADD COLUMN transaction_year YEAR;

UPDATE Walmart_sales 
SET transaction_month = MONTH(transaction_date), 
    transaction_year = YEAR(transaction_date);
    
UPDATE Walmart_sales 
SET transaction_month = MONTHNAME(transaction_date)
WHERE transaction_month = MONTH(transaction_date);

-- CHECK NULL VALUES OF ADDED COLUMNS
SELECT COUNT(*),
  SUM(CASE WHEN total_revenue IS NULL THEN 1 ELSE 0 END) AS total_revenue,
  SUM(CASE WHEN transaction_month IS NULL THEN 1 ELSE 0 END) AS transaction_month,
  SUM(CASE WHEN transaction_year IS NULL THEN 1 ELSE 0 END) AS transaction_year
FROM Walmart_sales;

-- UPDATE PROMOTION TYPE COLUMN
UPDATE Walmart_sales
SET promotion_type = 'No Discount'
WHERE promotion_type = 'NONE';

-- KEY BUSINESS QUESTIONS AND SOLUTION

-- 1. What are the top 3 best-selling products by revenue and quantity?
SELECT product_name, 
	   SUM(total_revenue) AS revenue,
       COUNT(quantity_sold) AS quantity
FROM walmart_sales
GROUP BY product_name
ORDER BY revenue DESC, quantity 
LIMIT 3;

-- 2. Which category & store generate the most sales?
SELECT category, store_location,
       SUM(total_revenue) AS revenue
FROM Walmart_sales
GROUP BY category, store_location
ORDER BY revenue DESC
LIMIT 1;

-- 3.Which promotion type is most effective?
SELECT promotion_type, SUM(total_revenue) AS total_revenue
FROM walmart_sales
GROUP BY promotion_type
ORDER BY total_revenue DESC
LIMIT 1;

-- 4. What is the monthly revenue trend?
SELECT transaction_month, SUM(total_revenue) AS total_revenue
FROM walmart_sales
GROUP BY transaction_month;

-- 6. Which age group contributes most to sales?
SELECT CASE 
       WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
       WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
       WHEN customer_age BETWEEN 36 AND 45 THEN '36-45'
       WHEN customer_age BETWEEN 46 AND 60 THEN '46-60'
       ELSE '60+'
       END AS age_group,
       SUM(total_revenue) AS total_sales,
	   AVG(total_revenue) AS Avg_sales
FROM walmart_sales
GROUP BY age_group
ORDER BY total_sales DESC, Avg_sales DESC
LIMIT 1;

-- 7. Is there any correlation between income and loyalty level?
SELECT customer_loyalty_level,
       COUNT(DISTINCT customer_id) AS customer_id,
       ROUND(AVG(customer_income)) AS avg_customer_income,
       SUM(total_revenue) AS revenue
FROM walmart_sales
GROUP BY customer_loyalty_level
ORDER BY customer_id, avg_customer_income, revenue DESC;

-- 8. Which customer loyalty level brings in the most revenue?
SELECT customer_loyalty_level, SUM(total_revenue) AS total_revenue
FROM walmart_sales
GROUP BY customer_loyalty_level
ORDER BY total_revenue DESC
LIMIT 1;

-- 9. How do promotions impact sales (with vs without promotion)?
SELECT promotion_applied, SUM(total_revenue) AS total_revenue
FROM walmart_sales
GROUP BY  promotion_applied;

-- 10. Do holidays increase total revenue?
SELECT holiday_indicator, SUM(total_revenue) AS total_revenue
FROM walmart_sales
GROUP BY holiday_indicator
ORDER BY total_revenue DESC;

-- 11. What is the average spend per loyalty level?
SELECT customer_loyalty_level, AVG(total_revenue) AS avg_spend
FROM walmart_sales
GROUP BY customer_loyalty_level;

-- 12. How often do stockouts happen and in which stores?
SELECT store_id, store_location, COUNT(*) AS stockout_count
FROM walmart_sales
WHERE stockout_indicator = 'TRUE'
GROUP BY store_id, store_location
ORDER BY stockout_count DESC
LIMIT 1;

-- 13. Are reorder quantities and forecasted demand aligned with actual demand?
SELECT 
	ROUND(AVG(reorder_quantity)) AS avg_reorder_quantity,
	ROUND(AVG(forecasted_demand)) AS forecasted_demand,
	ROUND(AVG(actual_demand)) AS actual_demand,
	ROUND(AVG(forecasted_demand - actual_demand)) AS avg_forcast_gap,
	ROUND(AVG(reorder_quantity - actual_demand)) AS avg_reorder_gap
FROM walmart_sales;

-- 14. Which suppliers have the longest lead time and affect stockouts?
SELECT supplier_id, 
       avg(supplier_lead_time) as avg_lead_time,
       COUNT(*) AS stockout_count
FROM walmart_sales
WHERE stockout_indicator = 'TRUE'
GROUP BY supplier_id, supplier_lead_time
ORDER BY avg_lead_time DESC, stockout_count DESC;

-- 15. Which payment method is most preferred by customers?
SELECT payment_method, COUNT(transaction_id) AS payment_count
FROM walmart_sales
GROUP BY payment_method
ORDER BY payment_count DESC
LIMIT 1;

-- 16. Which day of the week bring the most footfall/sales?
SELECT weekday, SUM(total_revenue) AS revenue
FROM walmart_sales
GROUP BY weekday
ORDER BY revenue DESC
LIMIT 1;

-- 17. Which category do high income customers prefer?
SELECT category, COUNT(*) AS purchase_count
FROM walmart_sales
WHERE customer_income > 100000
GROUP BY category
ORDER BY purchase_count DESC
LIMIT 1;

-- 18. Which weather condition affect sales?
SELECT weather_conditions, 
       COUNT(*) AS transactions,
       SUM(total_revenue) AS sales
FROM walmart_sales
GROUP BY weather_conditions
ORDER BY sales ASC
LIMIT 1;

-- 19. Which gender contributes most to sales?
SELECT customer_gender, SUM(total_revenue) AS revenue
FROM walmart_sales
GROUP BY customer_gender
ORDER BY revenue DESC
LIMIT 1;

-- 20. How often do stockouts happen and in which products?
SELECT product_id, product_name, COUNT(*) AS stockout_count
FROM walmart_sales
WHERE stockout_indicator = 'TRUE'
GROUP BY product_id, product_name
ORDER BY stockout_count DESC
LIMIT 1;


-- 21. Which is the top-selling product by promotion and revenue?
SELECT product_name, COUNT(quantity_sold) AS quantity,
       SUM(total_revenue) AS revenue
FROM walmart_sales
WHERE promotion_applied = 'TRUE'
GROUP BY product_name
ORDER BY revenue DESC,quantity
LIMIT 1;

-- 22. Total Revenue & Average Revenue
SELECT SUM(total_revenue),
       AVG(Total_revenue)
FROM walmart_sales;


-- END OF THE PROJECT






















