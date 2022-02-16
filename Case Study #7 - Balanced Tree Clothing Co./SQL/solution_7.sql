-- Solved on PostgreSQL 13.4 by Yulia Murtazina, January 28, 2022
-- Fixed on February 15, 2022

/* --------------------
Case Study #7 - Balanced Tree Clothing Co.
   --------------------*/

SET
  SEARCH_PATH = balanced_tree; 

/* --------------------
Case Study Questions
   --------------------*/

-- 1. What was the total quantity sold for all products?

SELECT
  SUM(qty) AS total_qty_sold
FROM
  sales;

-- 2. What is the total generated revenue for all products before discounts?

SELECT
  SUM(qty * price) AS total_sales
FROM
  sales;

-- 3. What was the total discount amount for all products?

SELECT
  ROUND(SUM(qty * price * discount :: numeric / 100), 2) AS total_discount
FROM
  sales;

/* --------------------
Transaction Analysis
   --------------------*/

-- 1. How many unique transactions were there?

SELECT
  COUNT(distinct txn_id) AS number_of_transactions
FROM
  sales;

-- 2. What is the average unique products purchased in each transaction?

SELECT
  COUNT(prod_id) / COUNT(distinct txn_id) AS avg_number_of_product_in_order
FROM
  sales;

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

WITH revenue AS(
    SELECT
      txn_id,
      SUM(qty * price) AS revenue
    FROM
      sales
    GROUP BY
      txn_id
  )
SELECT
  PERCENTILE_CONT(0.25) WITHIN GROUP (
    ORDER BY
      revenue
  ) AS percentile_25,
  PERCENTILE_CONT(0.50) WITHIN GROUP (
    ORDER BY
      revenue
  ) AS percentile_50,
  PERCENTILE_CONT(0.75) WITHIN GROUP (
    ORDER BY
      revenue
  ) AS percentile_75
FROM
  revenue;

-- 4. What is the average discount value per transaction?

WITH revenue AS(
    SELECT
      txn_id,
      SUM(qty * price * discount :: numeric / 100) AS order_discount
    FROM
      sales
    GROUP BY
      txn_id
  )
SELECT
  ROUND(AVG(order_discount), 2) AS avg_order_discount
FROM
  revenue;

-- 5. What is the percentage split of all transactions for members vs non-members?

WITH members AS (
    SELECT
      DISTINCT sales.txn_id,
      COUNT(distinct member) AS total_members,
      CASE
        WHEN member = TRUE THEN 1
        ELSE 0
      END AS number_of_members
    FROM
      sales
    GROUP BY
      txn_id,
      number_of_members
  )
SELECT
  distinct percentage_of_members,
  100 - percentage_of_members AS percentage_of_guests
FROM
  members,
  LATERAL(
    SELECT
      ROUND(
        100 *(SUM(number_of_members) / SUM(total_members)),
        1
      ) AS percentage_of_members
    FROM
      members
  ) pm;

-- 6. What is the average revenue for member transactions and non-member transactions?

WITH members AS (
    SELECT
      sales.txn_id,
      CASE
        WHEN member = TRUE THEN SUM(qty * price)
      END AS members_revenue,
      CASE
        WHEN member = FALSE THEN SUM(qty * price)
      END AS guests_revenue
    FROM
      sales
    GROUP BY
      txn_id,
      member
  )
SELECT
  ROUND(AVG(members_revenue), 2) AS avg_members_revenue,
  ROUND(AVG(guests_revenue), 2) AS avg_guests_revenue
FROM
  members;

/* --------------------
Product Analysis
   --------------------*/

-- 1. What are the top 3 products by total revenue before discount?

WITH revenue AS(
    SELECT
      product_name,
      SUM(qty * s.price) AS total_revenue,
      ROW_NUMBER() OVER(
        ORDER BY
          SUM(qty * s.price) DESC
      ) AS row
    FROM
      sales AS s
      JOIN product_details AS pd ON s.prod_id = pd.product_id
    GROUP BY
      product_name
  )
SELECT
  product_name,
  total_revenue
FROM
  revenue
WHERE
  row in (1, 2, 3);

-- 2. What is the total quantity, revenue and discount for each segment?


SELECT
  segment_name,
  SUM(qty) AS total_quantity,
  SUM(qty * s.price) AS total_revenue,
  round(
    SUM(qty * s.price * discount :: numeric / 100),
    2
  ) AS total_discount
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id
GROUP BY
  segment_name
ORDER BY
  1;

-- 3. What is the top selling product for each segment?

WITH revenue AS (
    SELECT
      segment_name,
      product_name,
      SUM(qty) AS total_quantity,
      SUM(qty * s.price) AS total_revenue,
      ROW_NUMBER() OVER(
        PARTITION BY segment_name
        ORDER BY
          SUM(qty * s.price) DESC
      ) AS revenue_rank,
      ROW_NUMBER() OVER(
        PARTITION BY segment_name
        ORDER BY
          SUM(qty) DESC
      ) AS qty_rank
    FROM
      sales AS s
      JOIN product_details AS pd ON s.prod_id = pd.product_id
    GROUP BY
      segment_name,
      product_name
  )
SELECT
  segment_name,
  product_name,
  total_quantity,
  total_revenue
FROM
  revenue
WHERE
  revenue_rank = 1
  OR qty_rank = 1;

-- 4. What is the total quantity, revenue and discount for each category?

SELECT
  category_name,
  SUM(qty) AS total_quantity,
  SUM(qty * s.price) AS total_revenue,
  round(
    SUM(qty * s.price * discount :: numeric / 100),
    2
  ) AS total_discount
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id
GROUP BY
  category_name
ORDER BY
  1;

-- 5. What is the top selling product for each category?

WITH revenue AS (
    SELECT
      category_name,
      product_name,
      SUM(qty) AS total_quantity,
      SUM(qty * s.price) AS total_revenue,
      ROW_NUMBER() OVER(
        PARTITION BY category_name
        ORDER BY
          SUM(qty * s.price) DESC
      ) AS revenue_rank,
      ROW_NUMBER() OVER(
        PARTITION BY category_name
        ORDER BY
          SUM(qty) DESC
      ) AS qty_rank
    FROM
      sales AS s
      JOIN product_details AS pd ON s.prod_id = pd.product_id
    GROUP BY
      category_name,
      product_name
  )
SELECT
  category_name,
  product_name,
  total_quantity,
  total_revenue
FROM
  revenue
WHERE
  revenue_rank = 1
  OR qty_rank = 1;

-- 6. What is the percentage split of revenue by product for each segment?

SELECT
  segment_name,
  product_name,
  ROUND(
    100 *(
      SUM(qty * s.price) :: numeric / SUM(SUM(qty * s.price)) OVER(PARTITION BY segment_name)
    ),
    1
  ) AS percent_of_revenue
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id
GROUP BY
  segment_name,
  product_name
ORDER BY
  1, 3 DESC;

-- 7. What is the percentage split of revenue by segment for each category?

SELECT
  segment_name,
  category_name,
  ROUND(
    100 *(
      SUM(qty * s.price) :: numeric / SUM(SUM(qty * s.price)) OVER(PARTITION BY category_name)
    ),
    1
  ) AS percent_of_revenue
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id
GROUP BY
  segment_name,
  category_name
ORDER BY
  1;

-- 8. What is the percentage split of total revenue by category?

SELECT
  category_name,
  ROUND(
    100 *(
      SUM(qty * s.price) :: numeric / SUM(SUM(qty * s.price)) OVER()
    ),
    1
  ) AS percent_of_revenue
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id
GROUP BY
  category_name
ORDER BY
  1;

-- 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

SELECT
  product_name,
  ROUND(
    100 *(COUNT(product_name) :: numeric / number_of_txn),
    2
  ) AS percent_of_penetration
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id,
  LATERAL(
    SELECT
      COUNT(distinct txn_id) AS number_of_txn
    FROM
      sales
  ) ss
GROUP BY
  product_name,
  number_of_txn
ORDER BY
  2 DESC;

-- 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

SELECT
  product_1,
  product_2,
  product_3,
  times_bought_together
FROM
  (
    with products AS(
      SELECT
        txn_id,
        product_name
      FROM
        sales AS s
        JOIN product_details AS pd ON s.prod_id = pd.product_id
    )
    SELECT
      p.product_name AS product_1,
      p1.product_name AS product_2,
      p2.product_name AS product_3,
      COUNT(*) AS times_bought_together,
      ROW_NUMBER() OVER(
        ORDER BY
          COUNT(*) DESC
      ) AS rank
    FROM
      products AS p
      JOIN products AS p1 ON p.txn_id = p1.txn_id
      AND p.product_name != p1.product_name
      AND p.product_name < p1.product_name
      JOIN products AS p2 ON p.txn_id = p2.txn_id
      AND p.product_name != p2.product_name
      AND p1.product_name != p2.product_name
      AND p.product_name < p2.product_name
      AND p1.product_name < p2.product_name
    GROUP BY
      p.product_name,
      p1.product_name,
      p2.product_name
  ) pp
WHERE
  rank = 1;

/* --------------------
Reporting Challenge

Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the same analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)
   --------------------*/

-- [WORK IN PROGRESS]

/* --------------------
Bonus Challenge

Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.

Hint: you may want to consider using a recursive CTE to solve this problem!
   --------------------*/

SELECT
  product_id,
  price,
  CONCAT(
    ph.level_text,
    ' ',
    ph1.level_text,
    ' - ',
    ph2.level_text
  ) AS product_name,
  ph2.id AS category_id,
  ph1.id AS segment_id,
  ph.id AS style_id,
  ph2.level_text AS category_name,
  ph1.level_text AS segment_name,
  ph.level_text AS style_name
FROM
  product_hierarchy AS ph
  JOIN product_hierarchy AS ph1 on ph.parent_id = ph1.id
  JOIN product_hierarchy AS ph2 on ph1.parent_id = ph2.id
  JOIN product_prices AS pp on ph.id = pp.id
