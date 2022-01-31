# Case Study #1 - Danny's Diner :ramen:

## Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers. 

## Case Study Questions

Each of the following case study questions can be answered using a single SQL statement. I'll mostly use two queries for convenience purposes.

#### 1. What is the total amount each customer spent at the restaurant?

````sql
SET
  search_path = dannys_diner;
SELECT
  customer_id,
  SUM(price) as total_spent
FROM
  sales as s
  JOIN menu as m ON s.product_id = m.product_id
GROUP BY
  1
ORDER BY
  1
  ````

| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

---
#### 2. How many days has each customer visited the restaurant?

````sql
SET
  search_path = dannys_diner;
SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS days_of_visiting
FROM
  sales
GROUP BY
  1
ORDER BY
  1
  ````
  
| customer_id | days_of_visiting |
| ----------- | ---------------- |
| A           | 4                |
| B           | 6                |
| C           | 2                |

---

#### 3. What was the first item from the menu purchased by each customer?

To get the first item we need to rank the items ordered by each customer in a temporary table using `WITH` statement. 

After we have those ranks, we can select the rows with the rank = 1. As the customer A made two orders at the first day, we need to use `ORDER BY` in the window function by two criteria: `order_date` and `product_id`.

In the final query I cast date as `varchar` to remove time ans show the date only.

````sql
SET
  search_path = dannys_diner;
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
  rank = 1
````  

| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | sushi        | 2021-01-01 |
| B           | curry        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |

---

The query without using window functions, returns two results for customer A, one result for customer B and two results for customer C:

````sql
SELECT
  customer_id,
  product_name,
  order_date::varchar
FROM
  dannys_diner.sales
  JOIN dannys_diner.menu ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
WHERE
  order_date IN (
    SELECT
      order_date
    FROM
      dannys_diner.sales
    LIMIT
      1
  )
ORDER BY
  1
  ````
  
| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | sushi        | 2021-01-01 |
| A           | curry        | 2021-01-01 |
| B           | curry        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |

---  
  
***The first purchase for customer A was :sushi:***

***The first purchase for customer B was :curry:***

***The first (and the only) purchase for customer C was :ramen:***

#### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SET
  search_path = dannys_diner;
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
  rank = 1
  ````
 | product_name | total_purchase_quantity |
| ------------ | ----------------------- |
| ramen        | 8                       |

---
 
***The most purchased item on the menu was :ramen:, it was purchased 8 times in total.***

#### 5. Which item was the most popular for each customer?

Let's look at all the results sorted by purchase frequency:

````sql
SET
  search_path = dannys_diner;
SELECT
  customer_id,
  product_name,
  COUNT(product_name) AS total_purchase_quantity
FROM
  sales AS s
  INNER JOIN menu AS m ON s.product_id = m.product_id
GROUP BY
  customer_id,
  product_name
ORDER BY
  total_purchase_quantity DESC
````

| customer_id | product_name | total_purchase_quantity |
| ----------- | ------------ | ----------------------- |
| C           | ramen        | 3                       |
| A           | ramen        | 3                       |
| B           | curry        | 2                       |
| B           | sushi        | 2                       |
| B           | ramen        | 2                       |
| A           | curry        | 2                       |
| A           | sushi        | 1                       |

---

Now we can select the most popular products for each customer using `rank` window function:

````sql
SET
  search_path = dannys_diner;
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
  rank = 1
 ```` 
 
| customer_id | product_name | total_purchase_quantity |
| ----------- | ------------ | ----------------------- |
| A           | ramen        | 3                       |
| B           | ramen        | 2                       |
| B           | curry        | 2                       |
| B           | sushi        | 2                       |
| C           | ramen        | 3                       |

---
 
***The most popular item for customer A was :ramen:, they purchased it 3 times. ***

***The most popular item for customer B was :curry:, :ramen: and :sushi:, they purchased each dish 2 times.***

***The most popular item for customer C was :ramen:, they purchased it 3 times.***

#### 6. Which item was purchased first by the customer after they became a member?

Let's consider that if the purchase date matches the membership date, then the purchase made on this date, was the first customer's purchase as a member. 
It means that we need to include this date in the WHERE statement.

````sql
SET
  search_path = dannys_diner;
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
  1
  ````

| customer_id | join_date  | order_date | product_name |
| ----------- | ---------- | ---------- | ------------ |
| A           | 2021-01-07 | 2021-01-07 | curry        |
| B           | 2021-01-09 | 2021-01-11 | sushi        |

---

#### 7. Which item was purchased just before the customer became a member?

Customer A purchased their membership on January, 7 - and they placed an order that day. 
We do not have time and therefore can not say exactly if this purchase was made before of after they became a member. 
Let's consider that if the purchase date matches the membership date, then the purchase made on this date, was the first customer's purchase as a member. 
It means that we need to exclude this date in the `WHERE` statement.

````sql
SET
  search_path = dannys_diner;
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
  1
  ````

| customer_id | join_date  | order_date | product_name |
| ----------- | ---------- | ---------- | ------------ |
| A           | 2021-01-07 | 2021-01-01 | sushi        |
| A           | 2021-01-07 | 2021-01-01 | curry        |
| B           | 2021-01-09 | 2021-01-04 | sushi        |

---

Customer A purchased two items on January, 1 - the date before they became a member. 
We need more information to tell exactly what item was purchased before they became a member: order number or purchase time. I am keeping two items in the list for now.

***Customer A purchased :curry: and :sushi: on 2021-01-01***

***Customer B purchased :sushi: on 2021-01-04***

#### 8. What is the total items and amount spent for each member before they became a member?

Let's consider that if the purchase date matches the membership date, then the purchase made on this date, was the first customer's purchase as a member. 
It means that we need to exclude this date in the WHERE statement.

````sql
SET
  search_path = dannys_diner;
select
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
  1
  ````

| customer_id | total_number_of_items | total_purchase_amount |
| ----------- | --------------------- | --------------------- |
| A           | 2                     | 25                    |
| B           | 3                     | 40                    |

---

#### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

````sql
SET
  search_path = dannys_diner;
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
  1
  ````

| customer_id | points |
| ----------- | ------ |
| A           | 860    |
| B           | 940    |
| C           | 360    |

---

#### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

First we need to count points as usual: 10 points for each dollar spent on :curry: and :ramen: and 20 points for each dollar spent on :sushi:. Add this calculation using `WITH` statement. 

Next we add extra points for all the purchases made by customers on the first week of their membership and return the sum of new points.

````sql
SET
  search_path = dannys_diner;
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
  1
  ````

| customer_id | new_points |
| ----------- | ---------- |
| A           | 1370       |
| B           | 820        |

---

***Customer A at the end of January would have 1370 points***

***Customer B at the end of January would have 820 points*** and 0 benefits from their first week membership

## Bonus Questions

### Join All The Things

````sql
SET
  search_path = dannys_diner;
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
  3
````

| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | ------------ | ----- | ------ |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

---

### Rank All The Things

First we need to select all the necessary columns from `sales`, `menu` and `members` tables - we do that using CTE and `WITH` statement.
Next we can rank orders from this table by `customer_id` and `member` columns.

````sql
SET
  search_path = dannys_diner;
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
  product_name
  ````
 
 | customer_id | order_date | product_name | price | member | ranking |
| ----------- | ---------- | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01 | curry        | 15    | N      |         |
| A           | 2021-01-01 | sushi        | 10    | N      |         |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      |         |
| B           | 2021-01-02 | curry        | 15    | N      |         |
| B           | 2021-01-04 | sushi        | 10    | N      |         |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      |         |
| C           | 2021-01-01 | ramen        | 12    | N      |         |
| C           | 2021-01-07 | ramen        | 12    | N      |         |

---
