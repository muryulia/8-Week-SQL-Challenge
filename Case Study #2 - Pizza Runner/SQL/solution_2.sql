-- Solved on PostgreSQL 13.4 by Yulia Murtazina, January, 14, 2022
-- Fixed on February, 2, 2022

/* --------------------
   Case Study Questions
   --------------------*/

-- A. Pizza Metrics
-- 1. How many pizzas were ordered?

SELECT
  COUNT(pizza_id) AS number_of_pizza_ordered
FROM
  pizza_runner.customer_orders;

-- 2. How many unique customer orders were made?

SELECT
  customer_id,
  COUNT(DISTINCT order_id) AS unique_customer_orders
FROM
  pizza_runner.customer_orders
GROUP BY
  customer_id;

-- 3. How many successful orders were delivered by each runner?

SELECT
  runner_id,
  COUNT(order_id) AS delivered_orders
FROM
  pizza_runner.runner_orders
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  1
ORDER BY
  1;

-- 4. How many of each type of pizza was delivered?

SELECT
  pizza_name,
  COUNT(pizza_name) AS number_of_pizzas_delivered
FROM
  pizza_runner.customer_orders AS c
  JOIN pizza_runner.pizza_names AS n ON c.pizza_id = n.pizza_id
  JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  1
ORDER BY
  1;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
  customer_id,
  pizza_name,
  COUNT(pizza_name) AS number_of_pizzas_delivered
FROM
  pizza_runner.customer_orders AS c
  JOIN pizza_runner.pizza_names AS n ON c.pizza_id = n.pizza_id
GROUP BY
  customer_id,
  pizza_name
ORDER BY
  customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?

WITH rank_added AS (
  SELECT
    c.order_id,
    c.customer_id,
    COUNT(c.order_id) AS items_in_order,
    rank() OVER (
      ORDER BY
        COUNT(c.order_id) DESC
    ) AS rank
  FROM
    pizza_runner.customer_orders AS c
    JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
  WHERE
    pickup_time != 'null'
    AND distance != 'null'
    AND duration != 'null'
  GROUP BY
    c.order_id,
    c.customer_id
)
SELECT
  order_id,
  customer_id,
  items_in_order
FROM
  rank_added
WHERE
  rank = 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
  customer_id,
  changes,
  COUNT(changes) AS number_of_pizzas
FROM
  (
    WITH ranked AS (
      SELECT
        *,
        ROW_NUMBER() OVER () AS rank
      FROM
        pizza_runner.customer_orders
    )
    SELECT
      customer_id,
      c.order_id,
      CASE
        WHEN exclusions ~ '^[0-9, ]+$'
        OR extras ~ '^[0-9, ]+$' THEN 'Have changes'
        ELSE 'No changes'
      END AS changes,
      rank
    FROM
      ranked AS c
      JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
    WHERE
      pickup_time != 'null'
      AND distance != 'null'
      AND duration != 'null'
    GROUP BY
      exclusions,
      extras,
      customer_id,
      c.order_id,
      rank
  ) AS changes
GROUP BY
  changes,
  customer_id
ORDER BY
  customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT
  CASE
    WHEN exclusions ~ '^[0-9, ]+$'
    AND extras ~ '^[0-9, ]+$' THEN 'Have exclusions and extras'
  END AS exclusions_and_extras,
  COUNT(exclusions) AS number_of_pizzas
FROM
  pizza_runner.customer_orders AS c
  JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  exclusions,
  extras
HAVING
  extras ~ '^[0-9, ]+$'
  AND exclusions ~ '^[0-9, ]+$';

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT
  hours,
  SUM(pizzas_ordered) AS pizzas_ordered
FROM
  (
    SELECT
      EXTRACT(
        hour
        FROM
          order_time
      ) AS hours,
      COUNT(
        EXTRACT(
          hour
          FROM
            order_time
        )
      ) AS pizzas_ordered
    FROM
      pizza_runner.customer_orders AS c
    GROUP BY
      order_time
  ) AS count_hours
GROUP BY
  hours
ORDER BY
  pizzas_ordered DESC;

-- 10. What was the volume of orders for each day of the week?

SELECT
  dow AS day_of_week,
  SUM(pizzas_ordered) AS pizzas_ordered
FROM
  (
    SELECT
      CASE
        WHEN EXTRACT(
          isodow
          FROM
            order_time
        ) = 1 THEN 'Monday'
        WHEN EXTRACT(
          isodow
          FROM
            order_time
        ) = 2 THEN 'Tuesday'
        WHEN EXTRACT(
          isodow
          FROM
            order_time
        ) = 3 THEN 'Wednesnday'
        WHEN EXTRACT(
          isodow
          FROM
            order_time
        ) = 4 THEN 'Thursday'
        WHEN EXTRACT(
          isodow
          FROM
            order_time
        ) = 5 THEN 'Friday'
        WHEN EXTRACT(
          isodow
          FROM
            order_time
        ) = 6 THEN 'Saturday'
        WHEN EXTRACT(
          isodow
          FROM
            order_time
        ) = 7 THEN 'Sunday'
      END AS dow,
      COUNT(
        EXTRACT(
          isodow
          from
            order_time
        )
      ) AS pizzas_ordered
    FROM
      pizza_runner.customer_orders AS c
    GROUP BY
      order_time
  ) AS count_dow
GROUP BY
  dow
ORDER BY
  pizzas_ordered DESC;

-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
  number_of_week,
  number_of_registrations
FROM
  (
    SELECT
      'Week ' || RANK () OVER (
        ORDER BY
          date_trunc('week', registration_date)
      ) number_of_week,
      DATE_TRUNC('week', registration_date) AS week,
      COUNT(*) AS number_of_registrations
    FROM
      pizza_runner.runners
    GROUP BY
      week
  ) AS count_weeks;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT
  runner_id,
  ROUND(
    AVG (
      DATE_PART(
        'minute',
        TO_TIMESTAMP(pickup_time, 'YYYY-MM-DD HH24:MI:SS') - c.order_time
      )
    )
  ) AS average_pickup_time_in_minutes
FROM
  pizza_runner.runner_orders AS r,
  pizza_runner.customer_orders AS c
WHERE
  c.order_id = r.order_id
  AND pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  runner_id
ORDER BY
  runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT
  c.order_id,
  COUNT(c.order_id) AS items_in_order,
  ROUND(
    AVG (
      DATE_PART(
        'minute',
        pickup_time_new - c.order_time
      )
    )
  ) AS average_pickup_time_in_minutes,
  ROUND(
    AVG (
      DATE_PART(
        'minute',
        pickup_time_new - c.order_time
      )
    ) / COUNT(c.order_id)
  ) AS average_time_per_pizza_in_minutes
FROM
  pizza_runner.runner_orders AS r,
  pizza_runner.customer_orders AS c,
  LATERAL(
    SELECT
      TO_TIMESTAMP(pickup_time, 'YYYY-MM-DD HH24:MI:SS') AS pickup_time_new
  ) pt
WHERE
  c.order_id = r.order_id
  AND pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  c.order_id
ORDER BY
  items_in_order DESC;

-- 4. What was the average distance travelled for each customer?

SELECT
  customer_id,
  ROUND(AVG(TO_NUMBER(distance, '99D9')), 1) AS average_distance_km
FROM
  pizza_runner.runner_orders AS r,
  pizza_runner.customer_orders AS c
WHERE
  c.order_id = r.order_id
  AND pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  customer_id
ORDER BY
  customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT
  MAX(TO_NUMBER(duration, '99')) - MIN(TO_NUMBER(duration, '99')) AS delivery_time_difference_in_minutes
FROM
  pizza_runner.runner_orders AS r
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null';

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT
  order_id,
  runner_id,
  ROUND(
    AVG(
      TO_NUMBER(distance, '99D9') /(TO_NUMBER(duration, '99') / 60)
    )
  ) AS runner_average_speed
FROM
  pizza_runner.runner_orders AS r
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  order_id,
  runner_id
ORDER BY
  order_id;

-- 7. What is the successful delivery percentage for each runner?

SELECT
  runner_id,
  ROUND(
    100 - (
      SUM(unsuccessful) / (SUM(unsuccessful) + SUM(successful))
    ) * 100
  ) AS successful_delivery_percent
FROM
  (
    SELECT
      runner_id,
      CASE
        WHEN pickup_time != 'null' THEN COUNT(*)
        ELSE 0
      END AS successful,
      CASE
        WHEN pickup_time = 'null' THEN COUNT(*)
        ELSE 0
      END AS unsuccessful
    FROM
      pizza_runner.runner_orders AS r
    GROUP BY
      runner_id,
      pickup_time
  ) AS count_rating
GROUP BY
  runner_id
ORDER BY
  runner_id;

-- C. Ingredient Optimisation
-- 1. What are the standard ingredients for each pizza?

SELECT
  pizza_name,
  string_agg(topping_name, ', ') AS toppings
FROM
  pizza_runner.pizza_toppings AS t,
  pizza_runner.pizza_recipes AS r
  JOIN pizza_runner.pizza_names AS n ON r.pizza_id = n.pizza_id
WHERE
  t.topping_id IN (
    SELECT
      unnest(string_to_array(r.toppings, ',') :: int [])
  )
GROUP BY
  1
ORDER BY
  1;

-- 2. What was the most commonly added extra?

SELECT
  extra_ingredient,
  number_of_pizzas
FROM
  (
    WITH extras_table AS (
      SELECT
        order_id,
        unnest(string_to_array(extras, ',') :: int []) AS topping_id
      FROM
        pizza_runner.customer_orders AS c
      WHERE
        extras != 'null'
    )
    SELECT
      topping_name AS extra_ingredient,
      COUNT(topping_name) AS number_of_pizzas,
      RANK() OVER (
        ORDER BY
          COUNT(topping_name) DESC
      ) AS rank
    FROM
      extras_table AS et
      JOIN pizza_runner.pizza_toppings AS t ON et.topping_id = t.topping_id
    GROUP BY
      topping_name
  ) t
WHERE
  rank = 1;

-- 3. What was the most common exclusion?

SELECT
  excluded_ingredient,
  number_of_pizzas
FROM
  (
    WITH exclusions_table AS (
      SELECT
        order_id,
        unnest(string_to_array(exclusions, ',') :: int []) AS topping_id
      FROM
        pizza_runner.customer_orders AS c
      WHERE
        exclusions != 'null'
    )
    SELECT
      topping_name AS excluded_ingredient,
      COUNT(topping_name) AS number_of_pizzas,
      RANK() OVER (
        ORDER BY
          COUNT(topping_name) DESC
      ) AS rank
    FROM
      exclusions_table AS et
      JOIN pizza_runner.pizza_toppings AS t ON et.topping_id = t.topping_id
    GROUP BY
      topping_name
  ) t
WHERE
  rank = 1;

/* --------------------
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
   --------------------*/

SELECT
  order_id,
  CONCAT(
    pizza_name,
    ' ',
    CASE
      WHEN COUNT(exclusions) > 0 THEN '- Exclude '
      ELSE ''
    END,
    STRING_AGG(exclusions, ', '),
    CASE
      WHEN COUNT(extras) > 0 THEN ' - Extra '
      ELSE ''
    END,
    STRING_AGG(extras, ', ')
  ) AS pizza_name_exclusions_and_extras
FROM
  (
    WITH rank_added AS (
      SELECT
        *,
        ROW_NUMBER() OVER () AS rank
      FROM
        pizza_runner.customer_orders
    )
    SELECT
      rank,
      ra.order_id,
      pizza_name,
      CASE
        WHEN exclusions != 'null'
        AND topping_id IN (
          SELECT
            UNNEST(STRING_TO_ARRAY(exclusions, ',') :: int [])
        ) THEN topping_name
      END AS exclusions,
      CASE
        WHEN extras != 'null'
        AND topping_id IN (
          SELECT
            unnest(string_to_array(extras, ',') :: int [])
        ) THEN topping_name
      END AS extras
    FROM
      pizza_runner.pizza_toppings AS t,
      rank_added as ra
      JOIN pizza_runner.pizza_names AS n ON ra.pizza_id = n.pizza_id
    GROUP BY
      rank,
      ra.order_id,
      pizza_name,
      exclusions,
      extras,
      topping_id,
      topping_name
  ) AS toppings_as_names
GROUP BY
  pizza_name,
  rank,
  order_id
ORDER BY
  rank;

/* --------------------
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
   --------------------*/

SELECT
  order_id,
  CONCAT(
    pizza_name,
    ': ',
    STRING_AGG(
      topping_name,
      ', '
      ORDER BY
        topping_name
    )
  ) AS all_ingredients
FROM
  (
    SELECT
      rank,
      order_id,
      pizza_name,
      CONCAT(
        CASE
          WHEN (SUM(count_toppings) + SUM(count_extra)) > 1 THEN (SUM(count_toppings) + SUM(count_extra)) || 'x'
        END,
        topping_name
      ) AS topping_name
    FROM
      (
        WITH rank_added AS (
          SELECT
            *,
            ROW_NUMBER() OVER () AS rank
          FROM
            pizza_runner.customer_orders
        )
        SELECT
          rank,
          ra.order_id,
          pizza_name,
          topping_name,
          CASE
            WHEN exclusions != 'null'
            AND t.topping_id IN (
              SELECT
                unnest(string_to_array(exclusions, ',') :: int [])
            ) THEN 0
            ELSE CASE
              WHEN t.topping_id IN (
                SELECT
                  UNNEST(STRING_TO_ARRAY(r.toppings, ',') :: int [])
              ) THEN COUNT(topping_name)
              ELSE 0
            END
          END AS count_toppings,
          CASE
            WHEN extras != 'null'
            AND t.topping_id IN (
              SELECT
                unnest(string_to_array(extras, ',') :: int [])
            ) THEN count(topping_name)
            ELSE 0
          END AS count_extra
        FROM
          rank_added AS ra,
          pizza_runner.pizza_toppings AS t,
          pizza_runner.pizza_recipes AS r
          JOIN pizza_runner.pizza_names AS n ON r.pizza_id = n.pizza_id
        WHERE
          ra.pizza_id = n.pizza_id
        GROUP BY
          pizza_name,
          rank,
          ra.order_id,
          topping_name,
          toppings,
          exclusions,
          extras,
          t.topping_id
      ) tt
    WHERE
      count_toppings > 0
      OR count_extra > 0
    GROUP BY
      pizza_name,
      rank,
      order_id,
      topping_name
  ) cc
GROUP BY
  pizza_name,
  rank,
  order_id
ORDER BY
  rank;

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

SELECT
  topping_name,
  (SUM(topping_count) + SUM(extras_count)) AS total_ingredients
FROM
  (
    WITH rank_added AS (
      SELECT
        *,
        ROW_NUMBER() OVER () AS rank
      FROM
        pizza_runner.customer_orders
    )
    SELECT
      rank,
      topping_name,
      CASE
        WHEN extras != 'null'
        AND topping_id IN (
          SELECT
            unnest(string_to_array(extras, ',') :: int [])
        ) THEN count(topping_name)
        ELSE 0 END AS extras_count,
      CASE
        WHEN exclusions != 'null'
        AND topping_id IN (
          SELECT
            unnest(string_to_array(exclusions, ',') :: int [])
        ) THEN NULL
        ELSE CASE
          WHEN topping_id IN (
            SELECT
              UNNEST(STRING_TO_ARRAY(toppings, ',') :: int [])
          ) THEN COUNT(topping_name)
        END
      END AS topping_count
    FROM
      pizza_runner.pizza_toppings AS t,
      pizza_runner.pizza_recipes AS r,
      rank_added as ra,
      pizza_runner.runner_orders AS ro
    WHERE
      ro.order_id = ra.order_id
      and ra.pizza_id = r.pizza_id
      and pickup_time != 'null'
      AND distance != 'null'
      AND duration != 'null'
    GROUP BY
      topping_name,
      exclusions,
      extras,
      toppings,
      topping_id,
      rank
  ) AS topping_count
GROUP BY
  topping_name
ORDER BY
  total_ingredients DESC;

-- D. Pricing and Ratings
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

WITH profit AS
(SELECT
  pizza_name,
  CASE
        WHEN pizza_name = 'Meatlovers' THEN COUNT(pizza_name)*12
        ELSE COUNT(pizza_name)*10
      END AS profit
FROM
  pizza_runner.customer_orders AS c
  JOIN pizza_runner.pizza_names AS n ON c.pizza_id = n.pizza_id
  JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  1)
SELECT SUM(profit) AS profit_in_dollars
FROM profit;

-- 2. What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

WITH profit AS (
  SELECT
    pizza_name,
    CASE
      WHEN pizza_name = 'Meatlovers' THEN COUNT(pizza_name) * 12
      ELSE COUNT(pizza_name) * 10
    END AS profit
  FROM
    pizza_runner.customer_orders AS c
    JOIN pizza_runner.pizza_names AS n ON c.pizza_id = n.pizza_id
    JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
  WHERE
    pickup_time != 'null'
    AND distance != 'null'
    AND duration != 'null'
  GROUP BY
    1
),
extras AS (
  SELECT
    COUNT(topping_id) AS extras
  FROM
    (
      SELECT
        UNNEST(STRING_TO_ARRAY(extras, ',') :: int []) AS topping_id
      FROM
        pizza_runner.customer_orders AS c
        JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
      WHERE
        pickup_time != 'null'
        AND distance != 'null'
        AND duration != 'null'
        AND extras != 'null'
    ) e
)
SELECT
  SUM(profit) + extras AS profit_in_dollars
FROM
  profit,
  extras
GROUP BY
  extras;

/* --------------------
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
   --------------------*/
SET
  search_path = pizza_runner;
DROP TABLE IF EXISTS runner_rating;
CREATE TABLE runner_rating (
    "id" SERIAL PRIMARY KEY,
    "order_id" INTEGER,
    "customer_id" INTEGER,
    "runner_id" INTEGER,
    "rating" INTEGER,
    "rating_time" TIMESTAMP
  );
INSERT INTO
  runner_rating (
    "order_id",
    "customer_id",
    "runner_id",
    "rating",
    "rating_time"
  )
VALUES
  ('1', '101', '1', '5', '2020-01-01 19:34:51'),
  ('2', '101', '1', '5', '2020-01-01 20:23:03'),
  ('3', '102', '1', '4', '2020-01-03 10:12:58'),
  ('4', '103', '2', '5', '2020-01-04 16:47:06'),
  ('5', '104', '3', '5', '2020-01-08 23:09:27'),
  ('7', '105', '2', '4', '2020-01-08 23:50:12'),
  ('8', '102', '2', '4', '2020-01-10 12:30:45'),
  ('10', '104', '1', '5', '2020-01-11 20:05:35');

/* --------------------
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas
   --------------------*/

SELECT
  co.customer_id,
  ro.order_id,
  runner_id,
  rating,
  TO_CHAR(order_time, 'YYYY-MM-DD HH24:MI:SS') AS order_time,
  pickup_time,
  ROUND(
    DATE_PART(
      'minute',
      TO_TIMESTAMP(pickup_time, 'YYYY-MM-DD HH24:MI:SS') - co.order_time
    )
  ) AS time_between_order_and_pickup,
  TO_NUMBER(duration, '99') AS delivery_time_in_minutes,
  ROUND(
    AVG(
      TO_NUMBER(distance, '99D9') /(TO_NUMBER(duration, '99') / 60)
    )
  ) AS average_speed,
  COUNT(ro.order_id) AS number_of_pizzas
FROM
  pizza_runner.runner_orders as ro
  JOIN pizza_runner.runner_rating as rr on ro.order_id = rr.order_id
  JOIN pizza_runner.customer_orders as co on ro.order_id = co.order_id
GROUP BY
  co.customer_id,
  ro.order_id,
  runner_id,
  rating,
  order_time,
  pickup_time,
  duration
  ORDER BY 1;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

WITH profit AS (
  SELECT
    pizza_name,
    CASE
      WHEN pizza_name = 'Meatlovers' THEN COUNT(pizza_name) * 12
      ELSE COUNT(pizza_name) * 10
    END AS profit
  FROM
    pizza_runner.customer_orders AS c
    JOIN pizza_runner.pizza_names AS n ON c.pizza_id = n.pizza_id
    JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
  WHERE
    pickup_time != 'null'
    AND distance != 'null'
    AND duration != 'null'
  GROUP BY
    1
),
expenses AS (
  SELECT
   sum(TO_NUMBER(distance, '99D9')*0.3) as expense
  FROM
    pizza_runner.runner_orders
      WHERE
        pickup_time != 'null'
        AND distance != 'null'
        AND duration != 'null'
    ) 
SELECT
  SUM(profit) - expense AS net_profit_in_dollars
FROM
  profit,
  expenses
GROUP BY
  expense;

-- E. Bonus Questions
-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

INSERT INTO
  pizza_runner.pizza_names ("pizza_id", "pizza_name")
VALUES
  (3, 'Supreme');
INSERT INTO
  pizza_runner.pizza_recipes ("pizza_id", "toppings")
VALUES
  (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
