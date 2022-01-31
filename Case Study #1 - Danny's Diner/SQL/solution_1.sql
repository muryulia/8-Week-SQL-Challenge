-- Solved on PostgreSQL 13.4 by Yulia Murtazina, January, 4, 2022
-- Fixed on January, 31, 2022

/* --------------------
   Case Study Questions
   --------------------*/

SET search_path = dannys_diner;

-- 1. What is the total amount each customer spent at the restaurant?

SELECT
  customer_id,
  SUM(price) as total_spent
FROM
  sales as s
  JOIN menu as m ON s.product_id = m.product_id
GROUP BY
  1
ORDER BY
  1;

-- 2. How many days has each customer visited the restaurant?

SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS days_of_visiting
FROM
  sales
GROUP BY
  1
ORDER BY
  1;

-- 3. What was the first item from the menu purchased by each customer?

WITH ranked AS (
    SELECT
      customer_id,
      product_name,
      order_date,
      row_number() OVER (
        PARTITION BY customer_id
        ORDER BY
          order_date,
          s.product_id
      ) AS rank
    FROM
      sales AS s
      JOIN menu AS m ON s.product_id = m.product_id
  )
SELECT
  customer_id,
  product_name,
  order_date::varchar
FROM
  ranked
WHERE
  rank = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

WITH totals AS (
    SELECT
      product_name,
      COUNT(product_name) AS total_purchase_quantity,
      row_number() OVER() AS rank
    FROM
      sales AS s
      JOIN menu AS m ON s.product_id = m.product_id
    GROUP BY
      1
  )
SELECT
  product_name,
  total_purchase_quantity
FROM
  totals
WHERE
  rank = 1;

-- 5. Which item was the most popular for each customer?

WITH ranked AS (
    SELECT
      customer_id,
      product_name,
      COUNT(product_name) AS total_purchase_quantity,
      rank() OVER (
        PARTITION BY customer_id
        ORDER BY
          COUNT(product_name) desc
      ) AS rank
    FROM
      sales AS s
      JOIN menu AS m ON s.product_id = m.product_id
    GROUP BY
      customer_id,
      product_name
  )
SELECT
  customer_id,
  product_name,
  total_purchase_quantity
FROM
  ranked
WHERE
  rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH ranked AS (
    SELECT
      s.customer_id,
      order_date,
      join_date,
      product_name,
      row_number() OVER (
        PARTITION BY s.customer_id
        ORDER BY
          order_date
      ) AS rank
    FROM
      sales AS s
      JOIN members AS mm ON s.customer_id = mm.customer_id
      JOIN menu AS m ON s.product_id = m.product_id
    WHERE
      order_date >= join_date
  )
SELECT
  customer_id,
  join_date::varchar,
  order_date::varchar,
  product_name
FROM
  ranked AS r
WHERE
  rank = 1
ORDER BY
  1;

-- 7. Which item was purchased just before the customer became a member?

WITH ranked AS (
    SELECT
      s.customer_id,
      order_date,
      join_date,
      product_name,
      rank() OVER (
        PARTITION BY s.customer_id
        ORDER BY
          order_date DESC
      ) AS rank
    FROM
      sales AS s
      JOIN members AS mm ON s.customer_id = mm.customer_id
      JOIN menu AS m ON s.product_id = m.product_id
    WHERE
      order_date < join_date
  )
SELECT
  customer_id,
  join_date::varchar,
  order_date::varchar,
  product_name
FROM
  ranked AS r
WHERE
  rank = 1
ORDER BY
  1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT
  s.customer_id,
  COUNT(product_name) AS total_number_of_items,
  SUM(price) AS total_purchase_amount
FROM
  sales AS s
  JOIN members AS mm ON s.customer_id = mm.customer_id
  JOIN menu AS m ON s.product_id = m.product_id
WHERE
  order_date < join_date
GROUP BY
  1
ORDER BY
  1;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT
  customer_id,
  SUM(point) AS points
FROM
  sales AS s
  JOIN (
    SELECT
      product_id,
      CASE
        WHEN product_id = 1 THEN price * 20
        ELSE price * 10
      END AS point
    FROM
      menu
  ) AS p ON s.product_id = p.product_id
GROUP BY
  1
ORDER BY
  1;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH count_points AS (
    SELECT
      s.customer_id,
      order_date,
      join_date,
      product_name,
      SUM(point) AS point
    FROM
      sales AS s
      JOIN (
        SELECT
          product_id,
          product_name,
          CASE
            WHEN product_name = 'sushi' THEN price * 20
            ELSE price * 10
          END AS point
        FROM
          menu AS m
      ) AS p ON s.product_id = p.product_id
      JOIN members AS mm ON s.customer_id = mm.customer_id
    GROUP BY
      s.customer_id,
      order_date,
      join_date,
      product_name,
      point
  )
SELECT
  customer_id,
  SUM(
    CASE
      WHEN order_date >= join_date
      AND order_date < join_date + (7 * INTERVAL '1 day')
      AND product_name != 'sushi' THEN point * 2
      ELSE point
    END
  ) AS new_points
FROM
  count_points
WHERE
  DATE_PART('month', order_date) = 1
GROUP BY
  1
ORDER BY
  1;

/* --------------------
   Bonus Questions
   --------------------*/

-- Join All The Things

WITH members AS (
    SELECT
      s.customer_id,
      order_date,
      product_name,
      price,
      join_date
    FROM
      sales AS s
      JOIN menu AS m ON s.product_id = m.product_id
      LEFT JOIN members AS mm ON s.customer_id = mm.customer_id
  )
SELECT
  customer_id,
  order_date::varchar,
  product_name,
  price,
  CASE
    WHEN order_date >= join_date THEN 'Y'
    ELSE 'N'
  END AS member
FROM
  members
ORDER BY
  1,
  2,
  3;

-- Rank All The Things

WITH members AS (
    SELECT
      s.customer_id,
      order_date::varchar,
      product_name,
      price,
      CASE
        WHEN order_date >= join_date THEN 'Y'
        ELSE 'N'
      END AS member
    FROM
      sales AS s
      JOIN menu AS m ON s.product_id = m.product_id
      LEFT JOIN members AS mm ON s.customer_id = mm.customer_id
  )
SELECT
  *,
  CASE
    WHEN member = 'Y' THEN rank() OVER (
      PARTITION BY customer_id,
      member
      ORDER BY
        order_date
    )
  END AS ranking
FROM
  members
ORDER BY
  customer_id,
  order_date,
  product_name;
