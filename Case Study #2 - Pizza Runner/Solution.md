# Case Study #2 - Pizza Runner :pizza:

### Introduction

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

Full description: [Case Study #2 - Pizza Runner](https://8weeksqlchallenge.com/case-study-2/)

## Case Study Questions

### A. Pizza Metrics

#### 1. How many pizzas were ordered?

````sql
SELECT
  COUNT(pizza_id) AS number_of_pizza_ordered
FROM
  pizza_runner.customer_orders
  ````
  
| number_of_pizza_ordered |
| ----------------------- |
| 14                      |


#### 2. How many unique customer orders were made?

Let's count how many unique customers we have:

````sql
SELECT
  COUNT(DISTINCT customer_id) AS unique_customers
FROM
  pizza_runner.customer_orders
  ````

| unique_customers |
| ---------------- |
| 5                |


Now we can count how many orders each customer made. This query includes all orders, successful ones and cancelled ones.

````sql
SELECT
  customer_id,
  COUNT(DISTINCT order_id) AS unique_customer_orders
FROM
  pizza_runner.customer_orders
GROUP BY
  customer_id
  ````
  
| customer_id | unique_customer_orders |
| ----------- | ---------------------- |
| 101         | 3                      |
| 102         | 2                      |
| 103         | 2                      |
| 104         | 2                      |
| 105         | 1                      |


#### 3. How many successful orders were delivered by each runner?

According to the case description, some orders can be cancelled.
Let's find the cancelled orders in the `runner_orders` table.

````sql
SELECT
  *
FROM
  pizza_runner.runner_orders
WHERE
  length(cancellation) > 0
  ````
  
| order_id | runner_id | pickup_time         | distance | duration  | cancellation            |
| -------- | --------- | ------------------- | -------- | --------- | ----------------------- |
| 6        | 3         | null                | null     | null      | Restaurant Cancellation |
| 7        | 2         | 2020-01-08 21:30:45 | 25km     | 25mins    | null                    |
| 8        | 2         | 2020-01-10 00:15:02 | 23.4 km  | 15 minute | null                    |
| 9        | 2         | null                | null     | null      | Customer Cancellation   |
| 10       | 1         | 2020-01-11 18:50:20 | 10km     | 10minutes | null                    |


As we can see, there are two cancelled order: one is cancelled by a customer, the other is cancelled by the restaurant.
We need to exclude these orders from the query as we want to count successful orders only.

````sql
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
  1
  ````
  
| runner_id | delivered_orders |
| --------- | ---------------- |
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |


#### 4. How many of each type of pizza was delivered?

Here we need join the `pizza_names` table and the `runner_orders` table to the customer_orders table.
We join the `pizza_names` table to get pizza names, and we join the `runner_orders` table to exclude cancelled orders.

````sql
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
  1
  ````

| pizza_name | number_of_pizzas_delivered |
| ---------- | -------------------------- |
| Meatlovers | 9                          |
| Vegetarian | 3                          |


#### 5. How many Vegetarian and Meatlovers were ordered by each customer?

We can calculate the number of ordered pizzas including cancelled orders - all the pizzas were ordered but some of them had not been delivered.

In this case we join the `pizza_names` table to get pizza names:

````sql
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
  customer_id
  ````
  
| customer_id | pizza_name | number_of_pizzas_delivered |
| ----------- | ---------- | -------------------------- |
| 101         | Meatlovers | 2                          |
| 101         | Vegetarian | 1                          |
| 102         | Meatlovers | 2                          |
| 102         | Vegetarian | 1                          |
| 103         | Meatlovers | 3                          |
| 103         | Vegetarian | 1                          |
| 104         | Meatlovers | 3                          |
| 105         | Vegetarian | 1                          |

  
***Customer with ID 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza***

***Customer with ID 102 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza***

***Customer with ID 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza***

***Customer with ID 104 ordered 3 Meatlovers pizzas***

***Customer with ID 105 ordered 1 Vegetarian pizza***

We can calculate this value excluding cancelled orders. In this case we need to join two tables: `pizza_names` to get pizza names and `runner_orders` to exclude cancelled orders.

````sql
SELECT
  customer_id,
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
  customer_id,
  pizza_name
ORDER BY
  customer_id
  ````
  
| customer_id | pizza_name | number_of_pizzas_delivered |
| ----------- | ---------- | -------------------------- |
| 101         | Meatlovers | 2                          |
| 102         | Meatlovers | 2                          |
| 102         | Vegetarian | 1                          |
| 103         | Meatlovers | 2                          |
| 103         | Vegetarian | 1                          |
| 104         | Meatlovers | 3                          |
| 105         | Vegetarian | 1                          |


***Customer with ID 101 ordered 2 Meatlovers pizzas***

***Customer with ID 102 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza***

***Customer with ID 103 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza***

***Customer with ID 104 ordered 3 Meatlovers pizzas***

***Customer with ID 105 ordered 1 Vegetarian pizza***


#### 6. What was the maximum number of pizzas delivered in a single order?

Let's look at how many items were delivered for each order:

````sql
SELECT
  c.order_id,
  COUNT(c.order_id) AS items_in_order
FROM
  pizza_runner.customer_orders AS c
  JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  c.order_id
ORDER BY
  items_in_order DESC
  ````

| order_id | items_in_order |
| -------- | -------------- |
| 4        | 3              |
| 3        | 2              |
| 10       | 2              |
| 7        | 1              |
| 8        | 1              |
| 5        | 1              |
| 2        | 1              |
| 1        | 1              |


Now let's select the maximum number of items in one order (an easy nested query, without window functions which would allow us to include addtional information in the result):

````sql
SELECT
  MAX(items_in_order) AS max_items_in_order
FROM
  (
    SELECT
      c.order_id,
      COUNT(c.order_id) AS items_in_order
    FROM
      pizza_runner.customer_orders AS c
      JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
    WHERE
      pickup_time != 'null'
      AND distance != 'null'
      AND duration != 'null'
    GROUP BY
      c.order_id
    ORDER BY
      items_in_order DESC
  ) AS count_items
  ````

| max_items_in_order |
| ------------------ |
| 3                  |


We can also use `rank` window function to show order ID and customer ID for the maximum pizzas delivered:

````sql
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
  rank = 1
  ````
  
| order_id | customer_id | items_in_order |
| -------- | ----------- | -------------- |
| 4        | 103         | 3              |


***There were maximum 3 pizzas ordered in one order.***

#### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

Changes are either exclusions or extras to the ordered pizzas. Let's see how orders with changes look in the table: 

````sql
SELECT
  *
FROM
  pizza_runner.customer_orders
WHERE
  length(extras) > 0
  OR length(exclusions) > 0
  ````
  
| order_id | customer_id | pizza_id | exclusions | extras | order_time               |
| -------- | ----------- | -------- | ---------- | ------ | ------------------------ |
| 4        | 103         | 1        | 4          |        | 2020-01-04T13:23:46.000Z |
| 4        | 103         | 1        | 4          |        | 2020-01-04T13:23:46.000Z |
| 4        | 103         | 2        | 4          |        | 2020-01-04T13:23:46.000Z |
| 5        | 104         | 1        | null       | 1      | 2020-01-08T21:00:29.000Z |
| 6        | 101         | 2        | null       | null   | 2020-01-08T21:03:13.000Z |
| 7        | 105         | 2        | null       | 1      | 2020-01-08T21:20:29.000Z |
| 8        | 102         | 1        | null       | null   | 2020-01-09T23:54:33.000Z |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10T11:22:59.000Z |
| 10       | 104         | 1        | null       | null   | 2020-01-11T18:34:49.000Z |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11T18:34:49.000Z |


Data type in the extras and exclusions columns is `varchar`, and the values are in the form of NaN (empty values), 'null' - string values or numeric values: single values or separated by commas. I decided to use a regular expression to find numeric values in these columns (thanks, StackOverFlow).
Another tough thing is that order #4 has 2 duplicated rows - all 2 pizzas in the order have exclusions and these pizzas should be counted separately. But when we use a `GROUP BY` statement, it groups these 2 records into one. So we need to avoid that grouping in advance. We can use CTE and `row_number` window function in the inner query to add a pseudo auto increment which allows us to keep these records separated. 

And one more solution - pre clean extras and exclusions columns as recommended by Danny, remove NaN and 'null' values. I won't do it now. 

````sql
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
  customer_id
  ````
  
| customer_id | changes      | number_of_pizzas |
| ----------- | ------------ | ---------------- |
| 101         | No changes   | 2                |
| 102         | No changes   | 3                |
| 103         | Have changes | 3                |
| 104         | Have changes | 2                |
| 104         | No changes   | 1                |
| 105         | Have changes | 1                |


***Customer with ID 101 ordered 2 pizzas without changes***

***Customer with ID 102 ordered 3 pizzas without changes***

***Customer with ID 103 ordered 3 pizzas with changes***

***Customer with ID 104 ordered 2 pizza with changes***

***Customer with ID 104 ordered 1 pizzas without changes***

***Customer with ID 105 ordered 1 pizza with changes***

***In total, 6 pizzas had changes and 6 pizzas had no changes***

#### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
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
  AND exclusions ~ '^[0-9, ]+$'
  ````
  
| exclusions_and_extras      | number_of_pizzas |
| -------------------------- | ---------------- |
| Have exclusions and extras | 1                |


#### 9. What was the total volume of pizzas ordered for each hour of the day?

Including cancelled orders:

````sql
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
      pizzas_ordered DESC, hours
````

| hours | pizzas_ordered |
| ----- | -------------- |
| 13    | 3              |
| 18    | 3              |
| 21    | 3              |
| 23    | 3              |
| 11    | 1              |
| 19    | 1              |


Excluding cancelled orderes:

````sql
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
      JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
    WHERE
      pickup_time != 'null'
      AND distance != 'null'
      AND duration != 'null'
    GROUP BY
      order_time
  ) AS count_hours
GROUP BY
  hours
ORDER BY
  pizzas_ordered DESC, hours 
  ````
  
| hours | pizzas_ordered |
| ----- | -------------- |
| 13    | 3              |
| 18    | 3              |
| 23    | 3              |
| 21    | 2              |
| 19    | 1              |


#### 10. What was the volume of orders for each day of the week?

Including cancelled orders:

````sql
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
  pizzas_ordered DESC
  ````
  
| day_of_week | pizzas_ordered |
| ----------- | -------------- |
| Wednesnday  | 5              |
| Saturday    | 5              |
| Thursday    | 3              |
| Friday      | 1              |

Excluding cancelled orderes:

````sql
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
          FROM
            order_time
        )
      ) AS pizzas_ordered
    FROM
      pizza_runner.customer_orders AS c
      JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
    WHERE
      pickup_time != 'null'
      AND distance != 'null'
      AND duration != 'null'
    GROUP BY
      order_time
  ) AS count_dow
GROUP BY
  dow
ORDER BY
  pizzas_ordered DESC
  ````
  
| day_of_week | pizzas_ordered |
| ----------- | -------------- |
| Saturday    | 5              |
| Wednesnday  | 4              |
| Thursday    | 3              |

### B. Runner and Customer Experience

#### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

There is some discrepancy between the data in the `runners table`, `customer_orders` and `runner_orders` tables.

Runners' registration dates are in January, 2021, orders were made and picked up by the runners in January, 2020.

To count the number of registrations, we need to extract the week and rank each week with the `rank` window function, so the first week of registration will have number 1.

````sql
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
  ) AS count_weeks
  ````

| number_of_week | number_of_registrations |
| -------------- | ----------------------- |
| Week 1         | 2                       |
| Week 2         | 1                       |
| Week 3         | 1                       |

#### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

The `pickup_time` column in the `runner_orders` table has `varchar` type, and we need transfrom it to timestamp first. After that we can count the difference between order creation time and order pickup time and the average time in minutes for each runner to arrive at the Pizza Runner HQ to pickup the order.

````sql
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
  runner_id
  ````
  
| runner_id | average_pickup_time_in_minutes |
| --------- | ------------------------------ |
| 1         | 15                             |
| 2         | 23                             |
| 3         | 10                             |

#### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

To answer this question, let's count for each order: number of ordered pizzas, time from placing order to pick up, and average time it took to prepare one pizza.

````sql
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
  items_in_order DESC
  ````
  
| order_id | items_in_order | average_pickup_time_in_minutes | average_time_per_pizza_in_minutes |
| -------- | -------------- | ------------------------------ | --------------------------------- |
| 4        | 3              | 29                             | 10                                |
| 3        | 2              | 21                             | 10                                |
| 10       | 2              | 15                             | 8                                 |
| 7        | 1              | 10                             | 10                                |
| 8        | 1              | 20                             | 20                                |
| 5        | 1              | 10                             | 10                                |
| 2        | 1              | 10                             | 10                                |
| 1        | 1              | 10                             | 10                                |  
  
It takes 10 minutes in average to prepare one pizza (except order #8 - it took 20 minutes to prepare 1 pizza). The more pizzas in one order, the more time it takes to prepare the order.

#### 4. What was the average distance travelled for each customer?

Assuming that each customer has the same address, we can suggest that there is a possible misspelling error in the distance cell for the customer with ID 102 (order #2 - 13.4km, order #8 - 23.4km). 
Data in the `distance` column has `varchar` type. To calculate the average distance we need to cast is as `numeric`. We can do it using `TO_NUMBER` function.

````sql
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
  customer_id
  ````
  
| customer_id | average_distance_km |
| ----------- | ------------------- |
| 101         | 20.0                |
| 102         | 16.7                |
| 103         | 23.4                |
| 104         | 10.0                |
| 105         | 25.0                |  
  
And I'd like to check the average distance for each runner too:

````sql
SELECT
  runner_id,
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
  runner_id
ORDER BY
  runner_id
````

| runner_id | average_distance_km |
| --------- | ------------------- |
| 1         | 14.5                |
| 2         | 23.7                |
| 3         | 10.0                |

#### 5. What was the difference between the longest and shortest delivery times for all orders?

Let's check the longest and the shortest delivery time first:

````sql
SELECT
  MIN(TO_NUMBER(duration, '99')) AS min_delivery_time_in_minutes,
  MAX(TO_NUMBER(duration, '99')) AS max_delivery_time_in_minutes
FROM
  pizza_runner.runner_orders AS r
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
````

| min_delivery_time_in_minutes | max_delivery_time_in_minutes |
| ---------------------------- | ---------------------------- |
| 10                           | 40                           |

The shortest delivery time was 10 minutes, the longest delivery time was 40 minutes.

Now let's calculate the time difference:

````sql
SELECT
  MAX(TO_NUMBER(duration, '99')) - MIN(TO_NUMBER(duration, '99')) AS delivery_time_difference_in_minutes
FROM
  pizza_runner.runner_orders AS r
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
  ````
  
| delivery_time_difference_in_minutes |
| ----------------------------------- |
| 30                                  |  

***The difference between the longest and the shortest delivery time is 30 minutes***

#### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

To calculate the average speed in km/h we need to divide distance to duration, and as the duration is in minutes, we need to divide the result to 60 to convert minutes to hours.
`distance` and `duration` columns have `varchar` data type, it needs to be converted to `numeric` to make calculations.

````sql
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
  order_id
````

| order_id | runner_id | runner_average_speed |
| -------- | --------- | -------------------- |
| 1        | 1         | 38                   |
| 2        | 1         | 44                   |
| 3        | 1         | 40                   |
| 4        | 2         | 35                   |
| 5        | 3         | 40                   |
| 7        | 2         | 60                   |
| 8        | 2         | 94                   |
| 10       | 1         | 60                   |  
  
Runner's speed 94 km/h for order #8 is way too fast compared to other deliveries.

Looks like that there is a misspelling error in the distance for the customer with ID 102.

I think that the distance to their address is 13.4km, not 23.4km.

#### 7. What is the successful delivery percentage for each runner?

First we need to count number of successful deliveries and unsuccessful deliveries.

Then we can calculate the percentage of successful deliveries: 100% deduct the percent of unsuccessful deliveries. To calculate the percent of unsuccessful deliveries we need to divide the number of unsuccessful deliveries to the total number of deliveries and multiply to 100. If all the deliveries were successful then the rating is 100% (100 - 0\*100), and if all of them were unsuccesful then the rating is 0% (100 - 1\*100):

````sql
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
  runner_id
````

| runner_id | successful_delivery_percent |
| --------- | --------------------------- |
| 1         | 100                         |
| 2         | 75                          |
| 3         | 50                          |

### C. Ingredient Optimisation

#### 1. What are the standard ingredients for each pizza?
In this query we need to join two tables: `pizza_toppings` and `pizza_recipes` to get the names of ingredients for each pizza. The column `toppings` in the `pizza_recipes` table is a comma separated string and we can convert it to an array using the `string_to_array` function. Next we can unnest this array and join tables using the `topping_id` column.

Now we have toppings for each pizza as text values, we can transform them into a string again using the `string_agg` function and comma as a separator.

````sql
SELECT
  pizza_name,
  STRING_AGG(topping_name, ', ') AS toppings
FROM
  pizza_runner.pizza_toppings AS t,
  pizza_runner.pizza_recipes AS r
  JOIN pizza_runner.pizza_names AS n ON r.pizza_id = n.pizza_id
WHERE
  t.topping_id IN (
    SELECT
      UNNEST(STRING_TO_ARRAY(r.toppings, ',') :: int [])
  )
GROUP BY
  1
ORDER BY
  1
````

| pizza_name | toppings                                                              |
| ---------- | --------------------------------------------------------------------- |
| Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce            |

#### 2. What was the most commonly added extra?

First we select all orders with extras to CTE and convert comma separated values to rows using `string_to_array` and `unnest` functions.
Next we join the `pizza_topping` table to the CTE, count number of each extra and rank them by count of extras in orders. After that we can select the ingredient with the rank = 1.

````sql
SELECT
  extra_ingredient,
  number_of_pizzas
FROM
  (
    WITH extras_table AS (
      SELECT
        order_id,
        UNNEST(STRING_TO_ARRAY(extras, ',') :: int []) AS topping_id
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
  rank = 1
````

| extra_ingredient | number_of_pizzas |
| ---------------- | ---------------- |
| Bacon            | 4                |

***The most poplular extra ingredient is bacon. It was added as extra to 4 pizzas***

#### 3. What was the most common exclusion?

````sql
SELECT
  excluded_ingredient,
  number_of_pizzas
FROM
  (
    WITH exclusions_table AS (
      SELECT
        order_id,
        UNNEST(STRING_TO_ARRAY(exclusions, ',') :: int []) AS topping_id
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
  rank = 1
````

| excluded_ingredient | number_of_pizzas |
| ------------------- | ---------------- |
| Cheese              | 4                |

***The most common exclusion is cheese. It was excluded from 4 pizzas***

#### 4. Generate an order item for each record in the `customers_orders` table in the format of one of the following:

- Meat Lovers

- Meat Lovers - Exclude Beef

- Meat Lovers - Extra Bacon

- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

Actually it took some time before I have figured out how to generate the correct output. And the query is quite complex. I'd like to explain how this query with a bunch of nested queries works.

First we add rank to each row to prevent grouping of duplicate rows in the order #4 and follow the original row order. We do that in a CTE using the `row_number` window function.

Next we join this CTE with the `pizza_toppings` table to get the ingredient names and the `pizza_names` table to get pizzas' names.

Then we convert comma separated values in `extras` and `exclusion` columns into rows using `string_to_array` and `unnest` functions.

Now we are ready for the final output. We need to convert extras and exclusions to strings - we will use `strting_agg` function to do that.
We also need to add words "- Exclude" or "- Extra" if a pizza has exclusion or extras - we can do that using `CASE` statement and `count` function.
And eventually we can concatenate these parts into one string using the `concat` function. 

````sql
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
  rank
````

| order_id | pizza_name_exclusions_and_extras                                |
| -------- | --------------------------------------------------------------- |
| 1        | Meatlovers                                                      |
| 2        | Meatlovers                                                      |
| 3        | Meatlovers                                                      |
| 3        | Vegetarian                                                      |
| 4        | Meatlovers - Exclude Cheese                                     |
| 4        | Meatlovers - Exclude Cheese                                     |
| 4        | Vegetarian - Exclude Cheese                                     |
| 5        | Meatlovers  - Extra Bacon                                       |
| 6        | Vegetarian                                                      |
| 7        | Vegetarian  - Extra Bacon                                       |
| 8        | Meatlovers                                                      |
| 9        | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
| 10       | Meatlovers                                                      |
| 10       | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |


#### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the `customer_orders` table and add a 2x in front of any relevant ingredients

For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"


This query utilizes similar functions as the previous query. 

The query logic is: first we select all ingredients for each pizza type, exclude exclusions, add extras and count how many ingredients each pizza includes, then we select the ingredients that are greater than 0 and calculate the sum of them to add 2x when relevant, and then aggregate the results into one string.
To sort all the ingredients alphabetically we add the `ORDER BY` parameter to the `string_agg` function.

````sql
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
  rank
````

| order_id | all_ingredients                                                                     |
| -------- | ----------------------------------------------------------------------------------- |
| 1        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 2        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4        | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                      |
| 5        | Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 6        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 7        | Vegetarian: Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes       |
| 8        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 9        | Meatlovers: 2xBacon, 2xChicken, BBQ Sauce, Beef, Mushrooms, Pepperoni, Salami       |
| 10       | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 10       | Meatlovers: 2xBacon, 2xCheese, Beef, Chicken, Pepperoni, Salami                     |

#### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

This query is created using a similar logic as the two previous one. Now we count ingredients and extras in pizzas for delivered orders only.

To do that we create a full list of all 12 ingredients for each delivered pizza, does not matter what kind of pizza it is: Meatlover or Vegetarian.

Next we create an `extras_count` column and count extras for pizzas.
We also create a `topping_count` column. If the ingredient is excluded from pizza we add `NULL` value to the row, if the ingredient is included to pizza, we count it.
Then we sum the values from these two columns to get the total quantity of each ingredient.

````sql
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
  total_ingredients DESC
````

| topping_name | total_ingredients |
| ------------ | ----------------- |
| Bacon        | 12                |
| Mushrooms    | 11                |
| Cheese       | 10                |
| Pepperoni    | 9                 |
| Salami       | 9                 |
| Chicken      | 9                 |
| Beef         | 9                 |
| BBQ Sauce    | 8                 |
| Tomatoes     | 3                 |
| Onions       | 3                 |
| Peppers      | 3                 |
| Tomato Sauce | 3                 |

### D. Pricing and Ratings

#### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

We have already counted the number of each type of pizza delivered in the question A4. Now we need to multiply the number of pizzas to the pizza price and sum them to get the total profit.

````sql
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
FROM profit
````

| profit_in_dollars |
| ----------------- |
| 138               |

***The total profit is $138***

#### 2. What if there was an additional $1 charge for any pizza extras?

#### - Add cheese is $1 extra

To calculate the totals with extras we need to calculate the number of extra ingredients in delivered pizzas and add this amount to the total profit calculated in the previous query. We use two CTE to do that: one CTE to count number of extras, and the other to calculate the profit without extras.

This is option 1:

````sql
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
  extras
````

| profit_in_dollars |
| ----------------- |
| 142               |  

Another option, with window function: select ingredients for every delivered pizza, count extras, and then sum prices of pizzas and extras. I like this option because it uses only one WHERE statement to exclude cancelled orders. But I need to use more nested queries here.

````sql
SELECT
  (SUM(price) + SUM(extras_price)) AS profit_with_extras
FROM
  (
    SELECT
      rank,
      price,
      SUM(extras_count) AS extras_price
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
          CASE
            WHEN pizza_name = 'Meatlovers' then 12
            ELSE 10
          END AS price,
          CASE
            WHEN extras != 'null'
            AND topping_id IN (
              SELECT
                UNNEST(STRING_TO_ARRAY(extras, ',') :: int [])
            ) THEN COUNT(topping_name)
            ELSE 0
          END AS extras_count
        FROM
          pizza_runner.pizza_toppings AS t,
          pizza_runner.pizza_recipes AS r,
          pizza_runner.runner_orders AS ro,
          rank_added as ra
          JOIN pizza_runner.pizza_names AS n ON ra.pizza_id = n.pizza_id
        WHERE
          ro.order_id = ra.order_id
          and ra.pizza_id = r.pizza_id
          and pickup_time != 'null'
          AND distance != 'null'
          AND duration != 'null'
        GROUP BY
          pizza_name,
          rank,
          extras,
          topping_id
      ) tt
    GROUP BY
      price,
      rank
  ) pp
````

| profit_in_dollars |
| ----------------- |
| 142               |

***The total profit with extras is $142***

#### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

I use only the basic fields: id as primary key (I think it's convenient to retrieve elements by ID - but probably here are some disadvantages), order_id, customer_id (it is not necessary but it can be useful), runner_id (it is also not necessary but it can be useful), rating (in the future different details of the delivery can be rated separately) and rating time. It would also be useful to add a note field in the future.

In my table each customer rated the runner, in real life many customers do not leave any rating. And in the real world the order of the entries most likely would be different, for example, order #5 can be rated before order #3.

````sql
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
````

#### 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?

- `customer_id`
- `order_id`
- `runner_id`
- `rating`
- `order_time`
- `pickup_time`
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas

````sql
SELECT
  co.customer_id,
  ro.order_id,
  ro.runner_id,
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
  ro.runner_id,
  rating,
  order_time,
  pickup_time,
  duration
  ORDER BY 1
````

| customer_id | order_id | runner_id | rating | order_time          | pickup_time         | time_between_order_and_pickup | delivery_time_in_minutes | average_speed | number_of_pizzas |
| ----------- | -------- | --------- | ------ | ------------------- | ------------------- | ----------------------------- | ------------------------ | ------------- | ---------------- |
| 101         | 1        | 1         | 5      | 2020-01-01 18:05:02 | 2020-01-01 18:15:34 | 10                            | 32                       | 38            | 1                |
| 101         | 2        | 1         | 5      | 2020-01-01 19:00:52 | 2020-01-01 19:10:54 | 10                            | 27                       | 44            | 1                |
| 102         | 3        | 1         | 4      | 2020-01-02 23:51:23 | 2020-01-03 00:12:37 | 21                            | 20                       | 40            | 2                |
| 102         | 8        | 2         | 4      | 2020-01-09 23:54:33 | 2020-01-10 00:15:02 | 20                            | 15                       | 94            | 1                |
| 103         | 4        | 2         | 5      | 2020-01-04 13:23:46 | 2020-01-04 13:53:03 | 29                            | 40                       | 35            | 3                |
| 104         | 5        | 3         | 5      | 2020-01-08 21:00:29 | 2020-01-08 21:10:57 | 10                            | 15                       | 40            | 1                |
| 104         | 10       | 1         | 5      | 2020-01-11 18:34:49 | 2020-01-11 18:50:20 | 15                            | 10                       | 60            | 2                |
| 105         | 7        | 2         | 4      | 2020-01-08 21:20:29 | 2020-01-08 21:30:45 | 10                            | 25                       | 60            | 1                |  
  
#### 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

We can calculate profit and expenses in two CTEs, and then subtract expenses from profit to get the net profit. 

````sql
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
  expense
````

| net_profit_in_dollars |
| --------------------- |
| 94.44                 |  
  
***Pizza Runner has left over $94.44***

### E. Bonus Questions

#### If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

````sql
INSERT INTO
  pizza_runner.pizza_names ("pizza_id", "pizza_name")
VALUES
  (3, 'Supreme');
INSERT INTO
  pizza_runner.pizza_recipes ("pizza_id", "toppings")
VALUES
  (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
````

Let's check how our table looks now:

````sql
SELECT
  *
FROM
  pizza_runner.pizza_names AS n
  JOIN pizza_runner.pizza_recipes AS r ON n.pizza_id = r.pizza_id
````

| pizza_id | pizza_name | pizza_id | toppings                              |
| -------- | ---------- | -------- | ------------------------------------- |
| 1        | Meatlovers | 1        | 1, 2, 3, 4, 5, 6, 8, 10               |
| 2        | Vegetarian | 2        | 4, 6, 7, 9, 11, 12                    |
| 3        | Supreme    | 3        | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 |
