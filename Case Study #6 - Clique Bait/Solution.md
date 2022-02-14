# Case Study #6 - Clique Bait :hook:

## Introduction

Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

Full description: [Case Study #6 - Clique Bait](https://8weeksqlchallenge.com/case-study-6/)

## Case Study Questions

### 1. Enterprise Relationship Diagram

Using the following DDL schema details to create an ERD for all the Clique Bait datasets.

[WORK IN PROGRESS]

### 2. Digital Analysis

Using the available datasets - answer the following questions using a single query for each one:

#### 1. How many users are there?

We need to count distinct user records from the users table.

```sql
SET
  SEARCH_PATH = clique_bait;
SELECT
  COUNT(distinct user_id) AS number_of_users
FROM
  users
```

| number_of_users |
| --------------- |
| 500             |

***There are 500 unique users***

#### 2. How many cookies does each user have on average?

To find the average number of cookies per user we need to divide the number of cookies (1782) to the number of the unique users (500).
And one more detail that we need to remember: the result of the division is the integer number 3, which is not quite accurate. Let's cast the number of users as a numeric type and round the result.

```sql
SET
  SEARCH_PATH = clique_bait;
SELECT
  ROUND(
    COUNT(cookie_id) / COUNT(distinct user_id) :: numeric,
    2
  ) AS avg_cookies_per_user
FROM
  users
```

| avg_cookies_per_user |
| -------------------- |
| 3.56                 |

***There are 3.56 cookies per user on average***

#### 3. What is the unique number of visits by all users per month?

To count the unique number of visits, we can group the visits by months first using the `to_char()` function, and then count the distinct visits.

```sql
SET
  SEARCH_PATH = clique_bait;
SELECT
  TO_CHAR(event_time, 'Month') AS month,
  count(distinct visit_id) AS number_of_visits
FROM
  events
GROUP BY
  1
ORDER BY
  MIN(event_time)
```

| month     | number_of_visits |
| --------- | ---------------- |
| January   | 876              |
| February  | 1488             |
| March     | 916              |
| April     | 248              |
| May       | 36               |

#### 4. What is the number of events for each event type?

Event type in the events table is represented as number. We need to join two tables: `events` and `event_type` to get names of the events. After that we can count the number of events for each event type.

```sql
SET
  SEARCH_PATH = clique_bait;
SELECT
  event_name,
  COUNT(e.event_type) AS number_of_events
from
  events AS e
  JOIN event_identifier AS ei ON e.event_type = ei.event_type
GROUP BY
  1
ORDER BY
  2 DESC
```

| event_name    | number_of_events |
| ------------- | ---------------- |
| Page View     | 20928            |
| Add to Cart   | 8451             |
| Purchase      | 1777             |
| Ad Impression | 876              |
| Ad Click      | 702              |

#### 5. What is the percentage of visits which have a purchase event?

To count the percentage of purchase events, we need to divide the number of purchase events to the unique number of visits and multiply the result to 100.

```sql
SET
  SEARCH_PATH = clique_bait;
SELECT
  event_name,
  ROUND(
    100 *(number_of_purchases :: numeric / number_of_visits),
    1
  ) AS percentage_from_all_visits
FROM
  events AS e
  join event_identifier AS ei on e.event_type = ei.event_type,
  LATERAL(
    SELECT
      COUNT(distinct visit_id) AS number_of_visits
    FROM
      events
  ) AS nv,
  LATERAL(
    SELECT
      COUNT(distinct visit_id) AS number_of_purchases
    FROM
      events
    WHERE
      event_type = 3
  ) np
WHERE
  event_name = 'Purchase'
GROUP BY
  event_name,
  number_of_visits,
  number_of_purchases
```

| event_name | percentage_from_all_visits |
| ---------- | -------------------------- |
| Purchase   | 49.9                       |

***49.9% percents of visits had a purchase event***

#### 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

First we need to count all the visitors who visited the Checkout page. Next we need to exclude the visits that had a purchase event - we can exclude these IDs using the `WHERE` statement. After that we can calculate the percentage of these visits by dividing the number of the visitors who visited the checkout page but have not completed their purchase to the total number of visits - this is percentage to all visits; and by dividing to the total number of the checkout page visitors - to get the percentage to the checkout page visitors.

```sql
SET
  SEARCH_PATH = clique_bait;
SELECT
  page_name,
  COUNT(page_name) AS number_of_visits,
  ROUND(
    100 *(COUNT(page_name) :: numeric / checkout_visits),
    1
  ) AS percentage_from_checkout_page_visits,
  ROUND(
    100 *(COUNT(page_name) :: numeric / total_visits),
    1
  ) AS percentage_from_all_visits
FROM
  events AS e
  JOIN page_hierarchy AS pe ON e.page_id = pe.page_id,
  LATERAL(
    SELECT
      COUNT(distinct visit_id) AS total_visits
    FROM
      events
  ) AS tv,
  LATERAL(
    SELECT
      COUNT(distinct visit_id) AS checkout_visits
    FROM
      events
    WHERE
      page_id = 12
  ) AS cv
WHERE
  page_name = 'Checkout'
  AND visit_id NOT IN (
    SELECT
      distinct visit_id
    FROM
      events AS ee
    WHERE
      event_type = 3
  )
GROUP BY
  page_name,
  total_visits,
  checkout_visits
```

| page_name | number_of_visits | percentage_from_checkout_page_visits | percentage_from_all_visits |
| --------- | ---------------- | ------------------------------------ | -------------------------- |
| Checkout  | 326              | 15.5                                 | 9.1                        |

***326 visits had the Checkout page views but did not have a purchase event, which represents 15.5% to the checkout page visits and 9.1% to all visits***

#### 7. What are the top 3 pages by number of views?

Page names are recorded into the `page_hierarchy` table. We need to count page views, and it is an event type. Event names are recorded into the `event_identifier` table. First we join tables `page_hierarchy` and `event_identifier` to the `event` table to get page names and event names.

Next, we need to count only the Page View events, so we need to add this condition to the `WHERE` statement.

And as we need to select only the top 3 pages by the number of views, we can use the `row_number()` window function to rank our results accordingly. 

```sql
SET
  SEARCH_PATH = clique_bait;
with ordered_rows AS(
    SELECT
      page_name,
      event_name,
      COUNT(event_name) AS number_of_views,
      ROW_NUMBER() OVER (
        ORDER BY
          COUNT(page_name) DESC
      ) AS row
    FROM
      events AS e
      JOIN page_hierarchy AS pe on e.page_id = pe.page_id
      JOIN event_identifier AS ei on e.event_type = ei.event_type
    WHERE
      event_name = 'Page View'
    GROUP BY
      1,
      2
  )
SELECT
  page_name,
  number_of_views
FROM
  ordered_rows
WHERE
  row in (1, 2, 3)
```

| page_name    | number_of_views |
| ------------ | --------------- |
| All Products | 3174            |
| Checkout     | 2103            |
| Home Page    | 1782            |

#### 8. What is the number of views and cart adds for each product category?

We need to count the number of page views and add to cart events by category. We can do it using the `CASE WHEN` statement: if an event name is equal to 'Page View', then we count it as 1, elso we count it as 0. After that we can sum the results. We repeat this query to count 'Add to Cart' events too.

And we need to exclude from the count products with the null ID - to do that we add a special condition to the `WHERE` statement.

```sql
SET
  SEARCH_PATH = clique_bait;
SELECT
  pe.product_category,
  SUM(
    CASE
      WHEN event_name = 'Page View' THEN 1
      ELSE 0
    END
  ) AS number_of_page_views,
  SUM(
    CASE
      WHEN event_name = 'Add to Cart' THEN 1
      ELSE 0
    END
  ) AS number_of_add_to_cart_events
FROM
  events AS e
  JOIN page_hierarchy AS pe ON e.page_id = pe.page_id
  JOIN event_identifier AS ei ON e.event_type = ei.event_type
WHERE
  product_id > 0
GROUP BY
  1
ORDER BY
  1
```

| product_category | number_of_page_views | number_of_add_to_cart_events |
| ---------------- | -------------------- | ---------------------------- |
| Fish             | 4633                 | 2789                         |
| Luxury           | 3032                 | 1870                         |
| Shellfish        | 6204                 | 3792                         |

#### 9. What are the top 3 products by purchases?

It's not 100% clear how to understand which products are purchased within an order. And we do not have the quantity of the products ordered. For example, a customer has purchased 1 lobster, 12 oysters and 12 abalones - then we have 1 record for lobster, 1 record for oysters and 1 record for abalones, which might be a kind of distortion.

Anyhow, my assumption is: if a product is added to cart, it has an "Add to cart" event recorded.
If a product was not added to cart or it was removed from the cart, there is no "Add to cart" event recorded.

Having this in mind, we need to select `visit_id` records that have a purchase event and then count products added to cart for this `visit_id` (we suggest that a customer has added some products to cart and then purchased them all - no partial purchases).

```sql
SET
  SEARCH_PATH = clique_bait;
with ordered_rows AS(
    SELECT
      page_name,
      event_name,
      COUNT(event_name) AS number_of_purchases,
      ROW_NUMBER() OVER (
        ORDER BY
          COUNT(event_name) DESC
      ) AS row
    FROM
      events AS e
      JOIN page_hierarchy AS pe ON e.page_id = pe.page_id
      JOIN event_identifier AS ei ON e.event_type = ei.event_type
    WHERE
      visit_id in (
        SELECT
          distinct visit_id
        FROM
          events AS ee
        WHERE
          event_type = 3
      )
      AND product_id > 0
      AND event_name = 'Add to Cart'
    GROUP BY
      1,
      2
  )
SELECT
  page_name,
  number_of_purchases
FROM
  ordered_rows
WHERE
  row in (1, 2, 3)
```

| page_name | number_of_purchases |
| --------- | ------------------- |
| Lobster   | 754                 |
| Oyster    | 726                 |
| Crab      | 719                 |

### 3. Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:

- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?

We will create a new table using the `SELECT INTO` statement.

At the first step we will join all the necessary tables: `events`, `page_hierarchy` and `event_identifier` into one CTE and select columns for the further count. We need to group page names by event types, so we will use three columns: `visit_id`, `page_name`, `event_name`.

Next we need to count the number of events and add new columns with the counted numbers to the table. There are a few options to do that, I used self joins:

```sql
SET
  SEARCH_PATH = clique_bait;
WITH joined_tables AS(
    SELECT
      visit_id,
      page_name,
      event_name
    FROM
      events AS e
      JOIN page_hierarchy AS pe ON e.page_id = pe.page_id
      JOIN event_identifier AS ei ON e.event_type = ei.event_type
   GROUP BY
      1,
      2,
      3
  )
SELECT
  jt.page_name,
  COUNT(event_name) AS number_of_views,
  number_of_added_to_cart,
  number_of_abandoned_carts,
  number_of_purchases 

INTO TABLE product_stats
FROM
  joined_tables AS jt
  JOIN (
    SELECT
      page_name,
      COUNT(event_name) AS number_of_added_to_cart
    FROM
      joined_tables
    WHERE
      event_name = 'Add to Cart'
    GROUP BY
      1
  ) jt1 ON jt.page_name = jt1.page_name
  JOIN (
    SELECT
      page_name,
      COUNT(event_name) AS number_of_abandoned_carts
    FROM
      joined_tables
    WHERE
      event_name = 'Add to Cart'
      AND visit_id NOT IN (
        SELECT
          distinct visit_id
        FROM
          events AS ee
        WHERE
          event_type = 3
      )
   GROUP BY
      1
  ) jt2 ON jt.page_name = jt2.page_name
  JOIN (
    SELECT
      page_name,
      COUNT(event_name) AS number_of_purchases
    FROM
      joined_tables
    WHERE
      event_name = 'Add to Cart'
      AND visit_id IN (
        SELECT
          distinct visit_id
        FROM
          events AS ee
        WHERE
          event_type = 3
      )
    GROUP BY
      1
  ) jt3 ON jt.page_name = jt3.page_name
WHERE
  event_name = 'Page View'
GROUP BY
  jt.page_name,
  number_of_added_to_cart,
  number_of_purchases,
  number_of_abandoned_carts
ORDER BY
  1
```

| page_name      | number_of_views | number_of_added_to_cart | number_of_abandoned_carts | number_of_purchases |
| -------------- | --------------- | ----------------------- | ------------------------- | ------------------- |
| Abalone        | 1525            | 932                     | 233                       | 699                 |
| Black Truffle  | 1469            | 924                     | 217                       | 707                 |
| Crab           | 1564            | 949                     | 230                       | 719                 |
| Kingfish       | 1559            | 920                     | 213                       | 707                 |
| Lobster        | 1547            | 968                     | 214                       | 754                 |
| Oyster         | 1568            | 943                     | 217                       | 726                 |
| Russian Caviar | 1563            | 946                     | 249                       | 697                 |
| Salmon         | 1559            | 938                     | 227                       | 711                 |
| Tuna           | 1515            | 931                     | 234                       | 697                 |

Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

To create this table we can join the `product_stats` table and the `page_hierarchy` table, count the number of records and group by product category.

```sql
SET
  SEARCH_PATH = clique_bait;
SELECT
  product_category,
  SUM(number_of_views) AS number_of_views,
  SUM(number_of_added_to_cart) AS number_of_added_to_cart,
  SUM(number_of_abandoned_carts) AS number_of_abandoned_carts,
  SUM(number_of_purchases) AS number_of_purchases

INTO TABLE product_category_stats
FROM
  product_stats AS ps
  JOIN page_hierarchy AS pe ON ps.page_name = pe.page_name
GROUP BY
  product_category
ORDER BY
  1
```

| product_category | number_of_views | number_of_added_to_cart | number_of_abandoned_carts | number_of_purchases |
| ---------------- | --------------- | ----------------------- | ------------------------- | ------------------- |
| Fish             | 4633            | 2789                    | 674                       | 2115                |
| Luxury           | 3032            | 1870                    | 466                       | 1404                |
| Shellfish        | 6204            | 3792                    | 894                       | 2898                |

Use your 2 new output tables - answer the following questions:

#### 1. Which product had the most views, cart adds and purchases?

To answer this question we can rank the records in the `product_stats` table using the `row_number()` window function in a `CTE` statement. The records are ranked in descending order, so next we need to select records with the rank = 1.

```sql
SET
  SEARCH_PATH = clique_bait;
WITH ordered_rows AS (
    SELECT
      *,
      ROW_NUMBER() OVER (
        ORDER BY
          number_of_views DESC
      ) AS views,
      ROW_NUMBER() OVER (
        ORDER BY
          number_of_added_to_cart DESC
      ) AS carts,
      ROW_NUMBER() OVER (
        ORDER BY
          number_of_purchases DESC
      ) AS purchases
    FROM
      product_stats
    GROUP BY
      1,
      2,
      3,
      4,
      5
  )
SELECT
  page_name,
  number_of_views,
  number_of_added_to_cart,
  number_of_purchases
FROM
  ordered_rows
WHERE
  views = 1
  OR carts = 1
  OR purchases = 1
```

| page_name | number_of_views | number_of_added_to_cart | number_of_purchases |
| --------- | --------------- | ----------------------- | ------------------- |
| Oyster    | 1568            | 943                     | 726                 |
| Lobster   | 1547            | 968                     | 754                 |

***:oyster: has most views: 1568 views***

***:lobster: has most cart adds: 968 and purchases: 754***

#### 2. Which product was most likely to be abandoned?

```sql
SET
  SEARCH_PATH = clique_bait;
WITH ordered_rows AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      ORDER BY
        number_of_abandoned_carts DESC
    ) AS row
  FROM
    product_stats
  GROUP BY
    1,
    2,
    3,
    4,
    5
)
SELECT
  page_name,
  number_of_abandoned_carts
FROM
  ordered_rows
WHERE
  row = 1
```

| page_name      | number_of_abandoned_carts |
| -------------- | ------------------------- |
| Russian Caviar | 249                       |

***The most abandoned product is Russian Caviar: 249 abandoned cart events***

#### 3. Which product had the highest view to purchase percentage?

To find the percentage we need to divide the number of purchases to the number of views and multiply the result to 100.

```sql
SET
  SEARCH_PATH = clique_bait;
WITH ordered_rows AS (
  SELECT
    page_name,
    view_to_purchase_percentage,
    ROW_NUMBER() OVER (
      ORDER BY
        view_to_purchase_percentage DESC
    ) AS row
  FROM
    product_stats,
    LATERAL(
      SELECT
        ROUND(
          100 *(number_of_purchases :: numeric / number_of_views),
          1
        ) AS view_to_purchase_percentage
    ) vpp
  GROUP BY
    1,
    2
)
SELECT
  page_name,
  view_to_purchase_percentage
FROM
  ordered_rows
WHERE
  row = 1
```

| page_name | view_to_purchase_percentage |
| --------- | --------------------------- |
| Lobster   | 48.7                        |

***:lobster: has 48.7% conversion from view to purchase***

#### 4. What is the average conversion rate from view to cart add?

To find the average conversion rate from view to cart add, we need to divide the total number of add to cart events to the total number of views and multiply to 100.

```sql
SET
  SEARCH_PATH = clique_bait;
SELECT
  ROUND(
    100 *(
      SUM(number_of_added_to_cart) / SUM(number_of_views)
    ),
    1
  ) AS avg_view_to_cart_conversion
FROM
  product_category_stats
```

| avg_view_to_cart_conversion |
| --------------------------- |
| 60.9                        |

***The average conversion rate from view to cart add is 60.9%***

#### 5. What is the average conversion rate from cart add to purchase?

To find the average conversion rate from cart add to purchase, we need to divide the total number of purchases to total number of add to cart events and multiply to 100.

```sql
SET
  SEARCH_PATH = clique_bait;
SELECT
  ROUND(
    100 *(
      SUM(number_of_purchases) / SUM(number_of_added_to_cart)
    ),
    1
  ) AS avg_cart_to_purchase_conversion
FROM
  product_category_stats
```

| avg_cart_to_purchase_conversion |
| ------------------------------- |
| 75.9                            |

***The average conversion rate from cart add to purchase is 75.9%***

### 3. Campaigns Analysis

Generate a table that has 1 single row for every unique visit_id record and has the following columns:
- `user_id`
- `visit_id`
- `visit_start_time`: the earliest event_time for each visit
- `page_views`: count of page views for each visit
- `cart_adds`: count of product cart add events for each visit
- `purchase`: 1/0 flag if a purchase event exists for each visit
- `campaign_name`: map the visit to a campaign if the `visit_start_time` falls between the `start_date` and `end_date`
- `impression`: count of ad impressions for each visit
- `click`: count of ad clicks for each visit
- (Optional column) `cart_products`: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

We will create this table using the approach that we have applied to create tables for product funnel analysis. We will use left joins to add new columns to the table because we need to keep all rows from the left table. The products added to cart, can be added to the table as a string using the `string_agg()` function, and sorted by the `sequence_number` column to follow the order they were added to the cart. 

```sql
SET
  SEARCH_PATH = clique_bait;
WITH joined_table AS (
    SELECT
      user_id,
      visit_id,
      event_time AS visit_start_time,
      page_name,
      event_name,
      sequence_number,
      product_id
    FROM
      users AS u
      JOIN events AS e ON u.cookie_id = e.cookie_id
      JOIN event_identifier AS ei ON e.event_type = ei.event_type
      JOIN page_hierarchy AS pe ON e.page_id = pe.page_id
    GROUP BY
      user_id,
      visit_id,
      event_name,
      page_name,
      event_time,
      sequence_number,
      product_id
  )
SELECT
  user_id,
  jt.visit_id,
  visit_start_time,
  page_views,
  cart_adds,
  purchase,
  campaign_name,
  impression,
  click,
  cart_products
FROM
  joined_table AS jt
  LEFT JOIN(
    SELECT
      visit_id,
      COUNT(page_name) AS page_views
    FROM
      joined_table
    WHERE
      event_name = 'Page View'
    GROUP BY
      1
  ) AS jt1 ON jt.visit_id = jt1.visit_id
  LEFT JOIN(
    SELECT
      visit_id,
      COUNT(page_name) AS cart_adds
    FROM
      joined_table
    WHERE
      event_name = 'Add to Cart'
    GROUP BY
      1
  ) AS jt2 ON jt.visit_id = jt2.visit_id
  LEFT JOIN(
    SELECT
      visit_id,
      CASE
        WHEN visit_id IN (
          SELECT
            distinct visit_id
          FROM
            events AS ee
          WHERE
            event_type = 3
        ) THEN 1
        ELSE 0
      END AS purchase
    FROM
      joined_table
    GROUP BY
      1
  ) AS jt3 ON jt.visit_id = jt3.visit_id
  LEFT JOIN(
    SELECT
      visit_id,
      COUNT(page_name) AS impression
    FROM
      joined_table
    WHERE
      event_name = 'Ad Impression'
    GROUP BY
      1
  ) AS jt4 ON jt.visit_id = jt4.visit_id
  LEFT JOIN(
    SELECT
      visit_id,
      COUNT(page_name) AS click
    FROM
      joined_table
    WHERE
      event_name = 'Ad Click'
    GROUP BY
      1
  ) AS jt5 ON jt.visit_id = jt5.visit_id
  LEFT JOIN campaign_identifier AS ci ON jt.visit_start_time between ci.start_date
  AND ci.end_date
  LEFT JOIN(
    SELECT
      visit_id,
      STRING_AGG(
        page_name,
        ', '
        ORDER BY
          sequence_number
      ) AS cart_products
    FROM
      joined_table
    WHERE
      product_id > 0
      AND event_name = 'Add to Cart'
    GROUP BY
      1
  ) AS jt6 ON jt.visit_id = jt6.visit_id
WHERE
  sequence_number = 1
GROUP BY
  page_name,
  page_views,
  cart_adds,
  user_id,
  jt.visit_id,
  purchase,
  impression,
  click,
  visit_start_time,
  campaign_name,
  cart_products
ORDER BY
  1,
  3
```

There are a few rows from this table below:
  
  | user_id | visit_id | visit_start_time         | page_views | cart_adds | purchase | campaign_name                     | impression | click | cart_products                                                                         |
| ------- | -------- | ------------------------ | ---------- | --------- | -------- | --------------------------------- | ---------- | ----- | ------------------------------------------------------------------------------------- |
| 1       | 0fc437   | 2020-02-04T17:49:49.602Z | 10         | 6         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Tuna, Russian Caviar, Black Truffle, Abalone, Crab, Oyster                            |
| 1       | ccf365   | 2020-02-04T19:16:09.182Z | 7          | 3         | 1        | Half Off - Treat Your Shellf(ish) |            |       | Lobster, Crab, Oyster                                                                 |
| 1       | 0826dc   | 2020-02-26T05:58:37.918Z | 1          |           | 0        | Half Off - Treat Your Shellf(ish) |            |       |                                                                                       |
| 1       | 02a5d5   | 2020-02-26T16:57:26.260Z | 4          |           | 0        | Half Off - Treat Your Shellf(ish) |            |       |                                                                                       |
| 1       | f7c798   | 2020-03-15T02:23:26.312Z | 9          | 3         | 1        | Half Off - Treat Your Shellf(ish) |            |       | Russian Caviar, Crab, Oyster                                                          |
| 1       | 30b94d   | 2020-03-15T13:12:54.023Z | 9          | 7         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon, Kingfish, Tuna, Russian Caviar, Abalone, Lobster, Crab                        |
| 1       | 41355d   | 2020-03-25T00:11:17.860Z | 6          | 1         | 0        | Half Off - Treat Your Shellf(ish) |            |       | Lobster                                                                               |
| 1       | eaffde   | 2020-03-25T20:06:32.342Z | 10         | 8         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon, Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab, Oyster           |
| 2       | 3b5871   | 2020-01-18T10:16:32.158Z | 9          | 6         | 1        | 25% Off - Living The Lux Life     | 1          | 1     | Salmon, Kingfish, Russian Caviar, Black Truffle, Lobster, Oyster                      |
| 2       | c5c0ee   | 2020-01-18T10:35:22.765Z | 1          |           | 0        | 25% Off - Living The Lux Life     |            |       |                                                                                       |
| 2       | e26a84   | 2020-01-18T16:06:40.907Z | 6          | 2         | 1        | 25% Off - Living The Lux Life     |            |       | Salmon, Oyster                                                                        |
| 2       | d58cbd   | 2020-01-18T23:40:54.761Z | 8          | 4         | 0        | 25% Off - Living The Lux Life     |            |       | Kingfish, Tuna, Abalone, Crab                                                         |
| 2       | 910d9a   | 2020-02-01T10:40:46.875Z | 8          | 1         | 0        | Half Off - Treat Your Shellf(ish) |            |       | Abalone                                                                               |
| 2       | 1f1198   | 2020-02-01T21:51:55.078Z | 1          |           | 0        | Half Off - Treat Your Shellf(ish) |            |       |                                                                                       |
| 2       | 49d73d   | 2020-02-16T06:21:27.138Z | 11         | 9         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon, Kingfish, Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab, Oyster |
| 2       | 0635fb   | 2020-02-16T06:42:42.735Z | 9          | 4         | 1        | Half Off - Treat Your Shellf(ish) |            |       | Salmon, Kingfish, Abalone, Crab                                                       |
| 3       | 9a2f24   | 2020-02-21T03:19:10.032Z | 6          | 2         | 1        | Half Off - Treat Your Shellf(ish) |            |       | Kingfish, Black Truffle                                                               |
| 3       | 25502e   | 2020-02-21T11:26:15.353Z | 1          |           | 0        | Half Off - Treat Your Shellf(ish) |            |       |                                                                                       |
| 3       | bf200a   | 2020-03-11T04:10:26.708Z | 7          | 2         | 1        | Half Off - Treat Your Shellf(ish) |            |       | Salmon, Crab                                                                          |
| 3       | eb13cd   | 2020-03-11T21:36:37.222Z | 1          |           | 0        | Half Off - Treat Your Shellf(ish) |            |       |                                                                                       |

[WORK IN PROGRESS]

Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

Some ideas you might want to investigate further include:

- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to each other?

