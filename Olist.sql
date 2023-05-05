-- I checked the datasets in excel to familiarize myself with the data 
-- Answering business questions:

-- 1 What is the total revenue generated by Olist, and how has it changed over time?
SELECT ROUND(sum(CAST(p.["payment_value"] AS FLOAT)),2) AS revenue
FROM olist_payments p

-- Total payment received is 16M 

-- Joined the payment and orders table together, and fitered out 'cancelled' and 'unavailable' rows to calculate another total revenue
SELECT ROUND(sum(CAST(p.["payment_value"] AS FLOAT)),2) AS revenue
FROM olist_payments p
JOIN olist_orders o ON  p.["order_id"] = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable');

-- Total revenue OVER YEAR MONTH

SELECT  YEAR(o.order_purchase_timestamp) AS Year ,MONTH(o.order_purchase_timestamp) AS month , DATENAME(MONTH,o.order_purchase_timestamp) AS month_name,
CONCAT(YEAR(o.order_purchase_timestamp), '-',DATENAME(MONTH,o.order_purchase_timestamp)) AS year_month,
ROUND(sum(CAST(p.["payment_value"] AS FLOAT)),2) AS revenue
FROM olist_payments p
JOIN olist_orders o ON o.order_id = p.["order_id"]
WHERE  o.order_status NOT IN ('cancelled', 'unavailable')
GROUP BY   YEAR(o.order_purchase_timestamp) ,MONTH(o.order_purchase_timestamp), DATENAME(MONTH,o.order_purchase_timestamp) 
ORDER BY 1 , 2


--2: How many orders were placed on Olist, and how does this vary by month or season?

SELECT  COUNT(DISTINCT( o.order_id)) AS total_orders_placed
FROM olist_orders AS o;

-- 99441 orders were made on Olist

SELECT  COUNT(DISTINCT( o.order_id)) AS total_orders_placed, MONTH(o.order_purchase_timestamp) AS month_num, DATENAME(month, o.order_purchase_timestamp)  as month
FROM olist_orders o 
GROUP BY  DATENAME(month, o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)  
ORDER BY 2 
-- i grouped the orders count by month

--3: What are the most popular product categories on Olist, and how do their sales volumes compare to each other?��

SELECT  pt.product_category_name_english, count(*) AS product_category_count, ROUND( SUM(CAST(py.["payment_value"] AS FLOAT)), 2) AS revenue
FROM  product_category_name_translation AS pt
JOIN olist_products AS pr    ON pt.product_category_name = pr.product_category_name
JOIN olist_order_items AS oi  ON oi.["product_id"] = pr.product_id
JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
JOIN olist_payments as py ON py.["order_id"] = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY pt.product_category_name_english
ORDER BY 2 DESC


--4: What is the average order value (AOV) on Olist, and how does this vary by product category or payment method?

SELECT ROUND(AVG(CAST(py.["payment_value"] AS FLOAT)), 2) AS average_order_value1, ROUND( SUM(CAST(py.["payment_value"] AS FLOAT))/ COUNT(o.order_id), 2) AS average_order_value
FROM olist_payments py
JOIN olist_orders o ON py.["order_id"] = o.order_id

-- average order value is 154.44

--  average order value bY product category
SELECT  pt.product_category_name_english , ROUND( AVG(CAST(py.["payment_value"] AS FLOAT)), 2) AS average_order_value
FROM  product_category_name_translation AS pt
JOIN olist_products AS pr    ON pt.product_category_name = pr.product_category_name
JOIN olist_order_items AS oi  ON oi.["product_id"] = pr.product_id
JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
JOIN olist_payments as py ON py.["order_id"] = o.order_id
GROUP BY pt.product_category_name_english
ORDER BY 2 DESC


-- average order value bY payment method

SELECT  py.["payment_type"] , ROUND( AVG(CAST(py.["payment_value"] AS FLOAT)), 2) AS average_order_value
FROM  olist_payments py
GROUP BY ["payment_type"]
ORDER BY 2


--5: How many sellers are active on Olist, and how does this number change over time?

--checking the sellers dataset again
SELECT *
FROM olist_sellers;

   -- To check for the total number of sellers
SELECT COUNT(DISTINCT(["seller_id"])) AS num_sellers
FROM olist_sellers;

-- There is a total of 3095 sellers on the Olist platform 

--OVER MONTH YEAR

SELECT CONCAT(YEAR(o.order_purchase_timestamp), '-', SUBSTRING(DATENAME(MONTH,o.order_purchase_timestamp),1,3)) AS year_month ,
YEAR(o.order_purchase_timestamp) AS Year , MONTH(o.order_purchase_timestamp) AS month ,
DATENAME(MONTH,o.order_purchase_timestamp) AS month_name, COUNT(DISTINCT(s.["seller_id"])) AS sellers_count
FROM  olist_order_items AS oi  
JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
JOIN olist_payments as py ON py.["order_id"] = o.order_id
JOIN olist_sellers s ON s.["seller_id"] = oi.["seller_id"]
GROUP BY   YEAR(o.order_purchase_timestamp) ,MONTH(o.order_purchase_timestamp) , DATENAME(MONTH,o.order_purchase_timestamp)
ORDER BY 2,3;

--OVER YEAR

SELECT YEAR(o.order_purchase_timestamp) AS year ,COUNT(DISTINCT(s.["seller_id"])) AS sellers_count
FROM  olist_order_items AS oi  
JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
JOIN olist_payments as py ON py.["order_id"] = o.order_id
JOIN olist_sellers s ON s.["seller_id"] = oi.["seller_id"]
GROUP BY   YEAR(o.order_purchase_timestamp)
ORDER BY 1

--OVER YEAR Quater
SELECT YEAR(o.order_purchase_timestamp) AS year,DATEPART(QUARTER,o.order_purchase_timestamp) AS  quarter,
CONCAT(YEAR(o.order_purchase_timestamp), ' Q-',DATEPART(QUARTER,o.order_purchase_timestamp)) AS year_quarter ,
COUNT(DISTINCT(s.["seller_id"])) AS sellers_count
FROM  olist_order_items AS oi  
JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
JOIN olist_payments as py ON py.["order_id"] = o.order_id
JOIN olist_sellers s ON s.["seller_id"] = oi.["seller_id"]
GROUP BY   YEAR(o.order_purchase_timestamp), DATEPART(QUARTER,o.order_purchase_timestamp), CONCAT(YEAR(o.order_purchase_timestamp),DATEPART(QUARTER,o.order_purchase_timestamp))
ORDER BY 1, 2



--Distribution of sellers by State
SELECT  s.["seller_state"] ,COUNT(DISTINCT(s.["seller_id"])) AS sellers_count
FROM  olist_order_items AS oi  
JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
JOIN olist_payments as py ON py.["order_id"] = o.order_id
JOIN olist_sellers s ON s.["seller_id"] = oi.["seller_id"]
GROUP BY  s.["seller_state"]
ORDER BY 2 DESC

--6: What is the distribution of seller ratings on Olist, and how does this impact sales performance?

-- Get the count of orders, revenue and average order value for each seller rating
SELECT  orr.review_score , COUNT( o.order_id) AS review_score_count ,
ROUND(SUM(CAST(py.["payment_value"] AS FLOAT)),2) AS sales, 
ROUND(AVG(CAST(py.["payment_value"] AS FLOAT)),2) AS aov
FROM olist_orders AS o  
JOIN olist_payments as py ON py.["order_id"] = o.order_id
JOIN olist_order_reviews AS orr ON orr.order_id = o.order_id
GROUP BY orr.review_score
ORDER BY 3 DESC;



SELECT  orr.review_score ,  
CASE WHEN orr.review_score = 5 THEN 'Excellent'
		WHEN orr.review_score = 4 THEN	'Very Good'
		WHEN orr.review_score = 3 THEN   'Good'
		WHEN orr.review_score = 2 THEN	'Bad'
		WHEN orr.review_score = 1 THEN    'Very Bad'
		END AS rating,
COUNT( o.order_id) AS review_score_count ,
ROUND(SUM(CAST(py.["payment_value"] AS FLOAT)),2) AS sales, 
ROUND(AVG(CAST(py.["payment_value"] AS FLOAT)),2) AS aov
FROM olist_orders AS o  
JOIN olist_payments as py ON py.["order_id"] = o.order_id
JOIN olist_order_reviews AS orr ON orr.order_id = o.order_id
GROUP BY orr.review_score
ORDER BY 5;

--7: How many customers have made repeat purchases on Olist, and what percentage of total sales do they account for?

-- I will group by unique customer_id and count how many unique customer_id have made more than one order 
SELECT COUNT(*) AS customer_unique_id_count
FROM(SELECT  cu.["customer_unique_id"],  COUNT(DISTINCT o.order_id) AS orders
FROM olist_orders AS o
JOIN olist_customers cu
ON cu.["customer_id"] = o.customer_id
Group by cu.["customer_unique_id"]
HAVING COUNT(o.order_id) > 1)sub

-- There are 474 distinct customers that have made more than one order

-- I joined the payment dataset to check how much customers with these customer_unique_ids have spent on the Olist platform

-- Check the percentage of revenue customers with these customer_unique_ids contribute
WITH repeat_cust AS 
			(	
			SELECT COUNT(DISTINCT cu.["customer_unique_id"]) AS rep_cus, SUM(CAST(py.["payment_value"] AS FLOAT)) AS repeat_cust_rev
			FROM olist_orders AS o
			JOIN olist_customers cu ON o.customer_id = cu.["customer_id"]
			JOIN olist_payments AS py ON py.["order_id"] = o.order_id
			WHERE cu.["customer_unique_id"] IN  
							(SELECT ["customer_unique_id"]
							FROM(SELECT  cu.["customer_unique_id"],  COUNT(DISTINCT o.order_id) AS orders
							FROM olist_orders AS o
							JOIN olist_customers cu
							ON cu.["customer_id"] = o.customer_id
							Group by cu.["customer_unique_id"]
							HAVING COUNT(o.order_id) > 1)sub)),

	total_cust AS	
			(SELECT COUNT(DISTINCT cu.["customer_unique_id"]) AS total_cus, SUM(CAST(py.["payment_value"] AS FLOAT)) AS total_cus_rev
			FROM olist_orders AS o
			JOIN olist_customers cu ON o.customer_id = cu.["customer_id"]
			JOIN olist_payments AS py ON py.["order_id"] = o.order_id
			)

	SELECT ROUND((repeat_cust.repeat_cust_rev/ total_cust.total_cus_rev)*100, 2) AS  repeat_cust_rev_perc
	FROM  repeat_cust
	CROSS JOIN total_cust;



--8: What is the average customer rating for products sold on Olist,  and how does this impact sales performance?

SELECT ROUND(AVG(CAST(review_score AS FLOAT)), 2) AS avg_cust_rating
FROM olist_order_reviews as orr
JOIN olist_orders o
ON orr.order_id = o.order_id

--The average customer rating on Olist is 4.07

-- To check for variation in average customer rating between products and sales performance of these products
--The average customer rating on Olist is 4.07
SELECT pt.product_category_name_english, ROUND(AVG(CAST(review_score AS FLOAT)), 2) AS avG_cust_rating, SUM(CAST(py.["payment_value"] AS FLOAT)) AS revenue
FROM   olist_orders AS o
JOIN  olist_order_items AS oi  ON o.order_id = oi.["order_id"]
JOIN olist_order_reviews AS orr ON orr.order_id = o.order_id
JOIN olist_payments as py ON py.["order_id"] = o.order_id
JOIN olist_customers AS c ON c.["customer_id"] = o.customer_id
JOIN olist_products AS pr    ON pr.product_id = oi.["product_id"] 
JOIN product_category_name_translation AS pt ON pt.product_category_name = pr.product_category_name
GROUP BY pt.product_category_name_english 
ORDER BY 3



--9: What is the average order cancellation rate on Olist, and how does this impact seller
--performance?.

WITH canceled_orders AS 
		(SELECT CAST(COUNT(order_id) AS FLOAT) AS canceled
		FROM olist_orders
		WHERE order_status = 'canceled'),

	 total_orders AS (
		SELECT CAST(COUNT(order_id) AS FLOAT) AS total
		FROM olist_orders
		)

SELECT *, 
		CONCAT(ROUND((canceled_orders.canceled / total_orders.total)*100,2), '%') AS canceled_order_percent
FROM canceled_orders
CROSS JOIN total_orders;

-- The average order cancellation rate on Olist is 0.63%

--10: What are the top-selling products on Olist?

-- Select the top 15 product categories based on revenue generated

SELECT product_category_name_english AS product_category
FROM   (SELECT  pt.product_category_name_english, pt.product_category_name, 
				ROUND( SUM(CAST(py.["payment_value"] AS FLOAT)), 2) AS revenue ,
				COUNT(pr.product_id ) AS productc_sold
		FROM  product_category_name_translation AS pt
		JOIN olist_products AS pr    ON pt.product_category_name = pr.product_category_name
		JOIN olist_order_items AS oi  ON oi.["product_id"] = pr.product_id
		JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
		JOIN olist_payments as py ON py.["order_id"] = o.order_id
		GROUP BY pt.product_category_name_english, pt.product_category_name
		ORDER BY 3 DESC 
		OFFSET 0 ROWS FETCH NEXT 15 ROWS ONLY)sub


--			to check how their sales trends changed over time. I will reduce the products to top 10
SELECT  CONCAT(YEAR(o.order_purchase_timestamp), ' Q-',DATEPART(QUARTER,o.order_purchase_timestamp)) AS year_quarter, pt.product_category_name_english, 
	    ROUND( SUM(CAST(py.["payment_value"] AS FLOAT)), 2) AS revenue ,
	    COUNT(pr.product_id ) AS productc_sold
FROM  product_category_name_translation AS pt
JOIN olist_products AS pr    ON pt.product_category_name = pr.product_category_name
JOIN olist_order_items AS oi  ON oi.["product_id"] = pr.product_id
JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
JOIN olist_payments as py ON py.["order_id"] = o.order_id
WHERE	pt.product_category_name_english IN		
			(SELECT product_category_name_english
			FROM	(SELECT  pt.product_category_name_english, pt.product_category_name, ROUND( SUM(CAST(py.["payment_value"] AS FLOAT)), 2) AS revenue ,
					COUNT(pr.product_id ) AS productc_sold
					FROM  product_category_name_translation AS pt
					JOIN olist_products AS pr    ON pt.product_category_name = pr.product_category_name
					JOIN olist_order_items AS oi  ON oi.["product_id"] = pr.product_id
					JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
					JOIN olist_payments as py ON py.["order_id"] = o.order_id
					GROUP BY pt.product_category_name_english, pt.product_category_name
					ORDER BY 3 DESC 
					OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY)sub)
GROUP BY pt.product_category_name_english,CONCAT(YEAR(o.order_purchase_timestamp), ' Q-',DATEPART(QUARTER,o.order_purchase_timestamp))
ORDER BY 3 DESC ,2 


--11: Which payment methods are most commonly used by Olist customers, and how does this
--vary by product category or geographic region?

			--  most commonly used payment methods by Olist customers 
SELECT p.["payment_type"], COUNT(*) AS payment_type_count
FROM olist_payments AS p
GROUP BY p.["payment_type"]
ORDER BY 2 DESC


----  most commonly used payment methods by Olist customers in each state
SELECT  c.["customer_state"], py.["payment_type"], COUNT(*) AS payment_type_count
FROM  product_category_name_translation AS pt
JOIN olist_products AS pr    ON pt.product_category_name = pr.product_category_name
JOIN olist_order_items AS oi  ON oi.["product_id"] = pr.product_id
JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
JOIN olist_payments as py ON py.["order_id"] = o.order_id
JOIN olist_customers AS c ON c.["customer_id"] = o.customer_id
GROUP BY c.["customer_state"], py.["payment_type"]
HAVING COUNT(*) = (SELECT MAX(counts.payment_type_count)
FROM(SELECT  c.["customer_state"], py.["payment_type"], COUNT(*) AS payment_type_count
FROM  product_category_name_translation AS pt
JOIN olist_products AS pr    ON pt.product_category_name = pr.product_category_name
JOIN olist_order_items AS oi  ON oi.["product_id"] = pr.product_id
JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
JOIN olist_payments as py ON py.["order_id"] = o.order_id
JOIN olist_customers AS c ON c.["customer_id"] = o.customer_id
GROUP BY c.["customer_state"], py.["payment_type"]) AS counts
WHERE counts.["customer_state"] = c.["customer_state"])
order by 3 DESC

--  most commonly used payment methods for each product category by Olist customers 

SELECT  pt.product_category_name_english, py.["payment_type"], COUNT(*) AS payment_type_count
FROM  product_category_name_translation AS pt
JOIN olist_products AS pr    ON pt.product_category_name = pr.product_category_name
JOIN olist_order_items AS oi  ON oi.["product_id"] = pr.product_id
JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
JOIN olist_payments as py ON py.["order_id"] = o.order_id
JOIN olist_customers AS c ON c.["customer_id"] = o.customer_id
GROUP BY pt.product_category_name_english, py.["payment_type"]
HAVING COUNT(*) = (SELECT MAX(counts.payment_type_count)
FROM(SELECT  pt.product_category_name_english, py.["payment_type"], COUNT(*) AS payment_type_count
FROM  product_category_name_translation AS pt
JOIN olist_products AS pr    ON pt.product_category_name = pr.product_category_name
JOIN olist_order_items AS oi  ON oi.["product_id"] = pr.product_id
JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
JOIN olist_payments as py ON py.["order_id"] = o.order_id
JOIN olist_customers AS c ON c.["customer_id"] = o.customer_id
GROUP BY pt.product_category_name_english, py.["payment_type"]) AS counts
WHERE counts.product_category_name_english = pt.product_category_name_english)
order by 3 DESC

-- credit card is the most used payment type by customers for each product

--12: How do customer reviews and ratings affect sales and product performance on Olist?
 
	-- This has been answered in question 6


--	13: Which product categories have the highest profit margins on Olist, and how can the
--company increase profitability across different categories?

SELECT product_category_name_english, revenue, cost, revenue - cost AS profit 
FROM
		(SELECT pt.product_category_name_english, ROUND(SUM(CAST(py.["payment_value"] AS FLOAT)), 2) revenue , 
			     ROUND(SUM(CAST(oi.["price"] AS FLOAT)) + SUM(CAST(oi.["freight_value"] AS FLOAT)),2) AS cost
		FROM  product_category_name_translation AS pt
		JOIN olist_products AS pr    ON pt.product_category_name = pr.product_category_name
		JOIN olist_order_items AS oi  ON oi.["product_id"] = pr.product_id
		JOIN olist_orders AS o ON o.order_id = oi.["order_id"]
		JOIN olist_payments as py ON py.["order_id"] = o.order_id
		GROUP BY pt.product_category_name_english) AS sub
ORDER BY profit DESC


--14: How does Olist's marketing spend and channel mix impact sales and customer acquisition
--costs, and how can the company optimize its marketing strategy to increase ROI?

-- There is in information on the marketing channels


--15: Locations having high customer density.

-- To select the zip codes with highest customers and thier states

SELECT cu.["customer_state"] ,
		cu.["customer_zip_code_prefix"], 
		CONCAT( cu.["customer_state"] , '-', SUBSTRING(cu.["customer_zip_code_prefix"],2,LEN(cu.["customer_zip_code_prefix"])-2)) AS state_zipcode,
		count(DISTINCT(cu.["customer_id"])) AS cus_density
FROM olist_customers as cu
GROUP BY cu.["customer_zip_code_prefix"], cu.["customer_state"]
ORDER BY 4  DESC
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY


-- To select the States with highest customers
SELECT cu.["customer_state"] ,  count(DISTINCT(cu.["customer_id"])) AS cus_density
FROM olist_customers as cu
GROUP BY  cu.["customer_state"]
ORDER BY 2  DESC
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
