-- Solved on PostgreSQL 13.4 by Yulia Murtazina, January 25, 2022
-- Fixed on February 14, 2022

-- Case Study #6 - Clique Bait

SET
  SEARCH_PATH = clique_bait;

/* --------------------
Case Study Questions

-- 1. Enterprise Relationship Diagram
   --------------------*/

-- Not a coding question

/* --------------------
2. Digital Analysis

Using the available datasets - answer the following questions using a single query for each one:
   --------------------*/

-- 1. How many users are there?

SELECT
  COUNT(distinct user_id) AS number_of_users
FROM
  users;

-- 2. How many cookies does each user have on average?

SELECT
  ROUND(
    COUNT(cookie_id) / COUNT(distinct user_id) :: numeric,
    2
  ) AS avg_cookies_per_user
FROM
  users;

-- 3. What is the unique number of visits by all users per month?

SELECT
  TO_CHAR(event_time, 'Month') AS month,
  count(distinct visit_id) AS number_of_visits
FROM
  events
GROUP BY
  1
ORDER BY
  MIN(event_time);

-- 4. What is the number of events for each event type?

SELECT
  event_name,
  COUNT(e.event_type) AS number_of_events
from
  events AS e
  JOIN event_identifier AS ei ON e.event_type = ei.event_type
GROUP BY
  1
ORDER BY
  2 DESC;

-- 5. What is the percentage of visits which have a purchase event?

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
  number_of_purchases;

-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

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
  checkout_visits;

-- 7. What are the top 3 pages by number of views?

WITH ordered_rows AS(
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
  row in (1, 2, 3);

-- 8. What is the number of views and cart adds for each product category?

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
  1;

-- 9. What are the top 3 products by purchases?

WITH ordered_rows AS(
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
  row in (1, 2, 3);

/* --------------------
3. Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:

    How many times was each product viewed?
    How many times was each product added to cart?
    How many times was each product added to a cart but not purchased (abandoned)?
    How many times was each product purchased?
   --------------------*/

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

-- INTO TABLE product_stats
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
  1;

-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

SELECT
  product_category,
  SUM(number_of_views) AS number_of_views,
  SUM(number_of_added_to_cart) AS number_of_added_to_cart,
  SUM(number_of_abandoned_carts) AS number_of_abandoned_carts,
  SUM(number_of_purchases) AS number_of_purchases

-- INTO TABLE product_category_stats
FROM
  product_stats AS ps
  JOIN page_hierarchy AS pe ON ps.page_name = pe.page_name
GROUP BY
  product_category
ORDER BY
  1;

-- Use your 2 new output tables - answer the following questions:
-- 1. Which product had the most views, cart adds and purchases?

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
  OR purchases = 1;

-- 2. Which product was most likely to be abandoned?

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
  row = 1;

-- 3. Which product had the highest view to purchase percentage?

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
  row = 1;

-- 4. What is the average conversion rate from view to cart add?

SELECT
  ROUND(
    100 *(
      SUM(number_of_added_to_cart) / SUM(number_of_views)
    ),
    1
  ) AS avg_view_to_cart_conversion
FROM
  product_category_stats;

-- 5. What is the average conversion rate from cart add to purchase?

SELECT
  ROUND(
    100 *(
      SUM(number_of_purchases) / SUM(number_of_added_to_cart)
    ),
    1
  ) AS avg_cart_to_purchase_conversion
FROM
  product_category_stats;

/* --------------------
3. Campaigns Analysis

Generate a table that has 1 single row for every unique visit_id record and has the following columns:

    user_id
    visit_id
    visit_start_time: the earliest event_time for each visit
    page_views: count of page views for each visit
    cart_adds: count of product cart add events for each visit
    purchase: 1/0 flag if a purchase event exists for each visit
    campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
    impression: count of ad impressions for each visit
    click: count of ad clicks for each visit
    (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)
   --------------------*/

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
  3;

/* --------------------
Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

Some ideas you might want to investigate further include:

    Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
    Does clicking on an impression lead to higher purchase rates?
    What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
    What metrics can you use to quantify the success or failure of each campaign compared to each other?
   --------------------*/
