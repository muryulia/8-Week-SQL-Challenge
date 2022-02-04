-- Solved on PostgreSQL 13.4 by Yulia Murtazina, January 18, 2022
-- Fixed on February 4, 2022

/* --------------------
   Case Study Questions: Case Study #3 - Foodie-Fi
   --------------------*/
SET
  search_path = foodie_fi;

-- A. Customer Journey

-- 1. Based off the 8 sample customers provided in the sample from the `subscriptions` table, write a brief description about each customer’s onboarding journey.
-- Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
-- Non-SQL question, answered in Solution.md

-- B. Data Analysis Questions
-- 1. How many customers has Foodie-Fi ever had?

    SELECT
      COUNT(distinct customer_id) AS total_number_of_customers
    FROM
      subscriptions;

-- 2. What is the monthly distribution of trial plan `start_date` values for our dataset - use the start of the month as the group by value

    SELECT
      start_date::varchar,
      plan_name,
      SUM(number_of_customers) AS number_of_customers
    FROM
      (
        SELECT
          DATE_TRUNC('month', start_date)::date AS start_date,
          plan_name,
          COUNT(customer_id) AS number_of_customers
        FROM
          subscriptions AS s
          JOIN plans AS p ON s.plan_id = p.plan_id
        WHERE
          plan_name = 'trial'
        GROUP BY
          start_date,
          plan_name
      ) AS count_customers
    GROUP BY
      start_date,
      plan_name
    ORDER BY
      start_date;

-- 3. What plan `start_date` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each `plan_name`

SELECT
  plan_name,
  COUNT(customer_id) AS number_of_events
FROM
  subscriptions as s
  JOIN plans AS p ON s.plan_id = p.plan_id
WHERE
  start_date > '2020-12-31' :: date
GROUP BY
  plan_name
ORDER BY
  plan_name;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
  SUM(churned_customers) AS churned_customers,
  ROUND(
    (SUM(churned_customers) / SUM(total_customers)) * 100,
    1
  ) AS churn_percentage
FROM
  (
    SELECT
      CASE
        WHEN plan_name = 'churn' THEN COUNT(distinct customer_id)
        ELSE 0
      END AS churned_customers,
      CASE
        WHEN plan_name = 'trial' THEN COUNT(distinct customer_id)
        ELSE 0
      END AS total_customers
    FROM
      subscriptions AS s
      JOIN plans AS p ON s.plan_id = p.plan_id
    GROUP BY
      plan_name
  ) AS count_churn;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

SELECT
  plan_name,
  COUNT(plan_name) AS number_of_churned_customers,
  ROUND(
    COUNT(plan_name) / customers :: numeric * 100
  ) AS percentage_of_churned_after_trial,
  ROUND(
    COUNT(plan_name) / churned_customers :: numeric * 100
  ) AS churned_after_trial_to_all_churned
FROM
  (
    SELECT
      s.customer_id,
      trial_ended,
      plan_name
    FROM
      subscriptions AS s
      JOIN plans AS p ON s.plan_id = p.plan_id
      JOIN (
        SELECT
          customer_id,
          (start_date + interval '7' day) AS trial_ended
        FROM
          subscriptions
        WHERE
          plan_id = 0
      ) AS t ON s.customer_id = t.customer_id
    WHERE
      start_date = trial_ended
      AND plan_name = 'churn'
    GROUP BY
      start_date,
      s.customer_id,
      trial_ended,
      plan_name
  ) AS count_plans,
  LATERAL(
    SELECT
      COUNT(distinct customer_id) AS customers
    FROM
      subscriptions
  ) p,
  LATERAL(
    SELECT
      COUNT(distinct customer_id) as churned_customers
    FROM
      subscriptions
    WHERE
      plan_id = 4
  ) p1
GROUP BY
  plan_name,
  customers,
  churned_customers;

-- 6. What is the number and percentage of customer plans after their initial free trial?

SELECT plan_name, COUNT(plan_name) AS number_of_plans_after_trial,
ROUND(
    (
      COUNT(plan_name) / (
        SELECT
          COUNT(distinct customer_id)
        FROM
          subscriptions
      ) ::numeric * 100
    ), 1
  ) AS percentage_of_total_customers
FROM
  (SELECT
      s.customer_id,
      trial_ended,
      plan_name
    FROM
      subscriptions AS s
      JOIN plans AS p ON s.plan_id = p.plan_id
      JOIN (
        SELECT
          customer_id,
          (start_date + interval '7' day) AS trial_ended
        FROM
          subscriptions
        WHERE
          plan_id = 0
      ) AS t ON s.customer_id = t.customer_id
 WHERE
start_date = trial_ended
    GROUP BY
      start_date,
      s.customer_id,
      trial_ended,
      plan_name) AS count_plans
      GROUP BY plan_name;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH ranked AS (
    SELECT
      plan_name,
      RANK() OVER(
        PARTITION BY customer_id
        ORDER BY
          start_date DESC
      ) AS RANK
    FROM
      subscriptions AS s
      JOIN plans AS p ON s.plan_id = p.plan_id
    WHERE
      start_date <= '2020-12-31' :: date
  )
SELECT
  plan_name,
  COUNT(plan_name) as number_of_plans,
  ROUND(
    (
      COUNT(plan_name) / customers :: numeric
    ) * 100,
    1
  ) AS percentage_of_plans
FROM
  ranked,
  LATERAL(
    SELECT
      COUNT(distinct customer_id) AS customers
    FROM
      subscriptions
  ) c
WHERE
  rank = 1
GROUP BY
  plan_name,
  customers
ORDER BY
  1;

-- 8. How many customers have upgraded to an annual plan in 2020?

SELECT
  plan_name,
  count(plan_name) AS number_of_customers
FROM
  subscriptions AS s
  JOIN plans AS p ON s.plan_id = p.plan_id
WHERE
  start_date BETWEEN '2020-01-01' :: date
  AND '2020-12-31' :: date
  AND plan_name = 'pro annual'
GROUP BY
  plan_name;

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

SELECT
  plan_name,
  ROUND(AVG(s.start_date - t.start_date)) AS average_days_to_upgrade
FROM
  subscriptions AS s
  JOIN plans AS p ON s.plan_id = p.plan_id
  JOIN (
    SELECT
      customer_id,
      start_date
    FROM
      subscriptions
    WHERE
      plan_id = 0
  ) AS t ON s.customer_id = t.customer_id
WHERE
  plan_name = 'pro annual'
GROUP BY
  plan_name;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

SELECT
  *
FROM
  (
    SELECT
      plan_name,
      CASE
        WHEN s.start_date - t.start_date < 31 THEN '0-30 days'
        WHEN s.start_date - t.start_date BETWEEN 31
        AND 60 THEN '31-60 days'
        WHEN s.start_date - t.start_date BETWEEN 61
        AND 90 THEN '61-90 days'
        WHEN s.start_date - t.start_date BETWEEN 91
        AND 120 THEN '91-120 days'
        WHEN s.start_date - t.start_date BETWEEN 121
        AND 150 THEN '121-150 days'
        WHEN s.start_date - t.start_date BETWEEN 151
        AND 180 THEN '151-180 days'
        WHEN s.start_date - t.start_date BETWEEN 181
        AND 210 THEN '181-210 days'
        WHEN s.start_date - t.start_date BETWEEN 211
        AND 240 THEN '211-240 days'
        WHEN s.start_date - t.start_date BETWEEN 241
        AND 270 THEN '241-270 days'
        WHEN s.start_date - t.start_date BETWEEN 271
        AND 300 THEN '271-300 days'
        WHEN s.start_date - t.start_date BETWEEN 301
        AND 330 THEN '301-330 days'
        WHEN s.start_date - t.start_date BETWEEN 331
        AND 360 THEN '331-360 days'
        WHEN s.start_date - t.start_date > 360 THEN '360+ days' 
      END AS group_by_days_to_upgrade,
      COUNT(s.start_date - t.start_date) AS number_of_customers,
      ROUND(AVG(s.start_date - t.start_date)) AS average_days_to_upgrade
    FROM
      subscriptions AS s
      JOIN plans AS p ON s.plan_id = p.plan_id
      JOIN (
        SELECT
          customer_id,
          start_date
        FROM
          subscriptions
        WHERE
          plan_id = 0
      ) AS t ON s.customer_id = t.customer_id
    WHERE
      plan_name = 'pro annual'
    GROUP BY
      plan_name,
      group_by_days_to_upgrade
  ) AS count_groups
GROUP BY
  plan_name,
  group_by_days_to_upgrade,
  number_of_customers,
  average_days_to_upgrade
ORDER BY
  CASE
    WHEN group_by_days_to_upgrade = '0-30 days' THEN 1
    WHEN group_by_days_to_upgrade = '31-60 days' THEN 2
    WHEN group_by_days_to_upgrade = '61-90 days' THEN 3
    WHEN group_by_days_to_upgrade = '91-120 days' THEN 4
    WHEN group_by_days_to_upgrade = '121-150 days' THEN 5
    WHEN group_by_days_to_upgrade = '151-180 days' THEN 6
    WHEN group_by_days_to_upgrade = '181-210 days' THEN 7
    WHEN group_by_days_to_upgrade = '211-240 days' THEN 8
    WHEN group_by_days_to_upgrade = '241-270 days' THEN 9
    WHEN group_by_days_to_upgrade = '271-300 days' THEN 10
    WHEN group_by_days_to_upgrade = '301-330 days' THEN 11
    WHEN group_by_days_to_upgrade = '331-360 days' THEN 12
    WHEN group_by_days_to_upgrade = '360+ days' THEN 13
  END;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

    SELECT
      s.customer_id,
      t.start_date::varchar AS basic_plan_started_on,
      s.start_date::varchar AS pro_plan_started_on,
      (t.start_date - s.start_date) AS days_between_basic_and_pro
    FROM
      subscriptions AS s
      JOIN plans AS p ON s.plan_id = p.plan_id
      JOIN (
        SELECT
          customer_id,
          start_date
        FROM
          subscriptions
        WHERE
          plan_id = 1
      ) AS t ON s.customer_id = t.customer_id
    WHERE
      plan_name = 'pro monthly'
      AND s.start_date >= '2020-01-01' :: date
      AND s.start_date <= '2020-12-31' :: date
    GROUP BY
      s.start_date,
      t.start_date,
      s.customer_id,
      plan_name
    ORDER BY
      days_between_basic_and_pro DESC
    LIMIT
      5;
-- C. Challenge Payment Question

/* --------------------
The Foodie-Fi team wants you to create a new `payments` table for the year 2020 that includes amounts paid by each customer in the `subscriptions` table with the following requirements:

- monthly payments always occur on the same day of month as the original `start_date` of any monthly paid plan
- 
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- 
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- 
- once a customer churns they will no longer make payments
   --------------------*/

SELECT
  customer_id,
  plan_id,
  plan_name,
  payment_date ::date :: varchar,
  CASE
    WHEN LAG(plan_id) OVER (
      PARTITION BY customer_id
      ORDER BY
        plan_id
    ) != plan_id
    AND DATE_PART(
      'day',
      payment_date - LAG(payment_date) OVER (
        PARTITION BY customer_id
        ORDER BY
          plan_id
      )
    ) < 30 THEN amount - LAG(amount) OVER (
      PARTITION BY customer_id
      ORDER BY
        plan_id
    )
    ELSE amount
  END AS amount,
  RANK() OVER(
    PARTITION BY customer_id
    ORDER BY
      payment_date
  ) AS payment_order 
  
INTO TEMP TABLE payments
FROM
  (
    SELECT
      customer_id,
      s.plan_id,
      plan_name,
      generate_series(
        start_date,
        CASE
          WHEN s.plan_id = 3 THEN start_date
          WHEN s.plan_id = 4 THEN NULL
          WHEN LEAD(start_date) OVER (
            PARTITION BY customer_id
            ORDER BY
              start_date
          ) IS NOT NULL THEN LEAD(start_date) OVER (
            PARTITION BY customer_id
            ORDER BY
              start_date
          )
          ELSE '2020-12-31' :: date
        END,
        '1 month' + '1 second' :: interval
      ) AS payment_date,
      price AS amount
    FROM
      subscriptions AS s
      JOIN plans AS p ON s.plan_id = p.plan_id
    WHERE
      s.plan_id != 0
      AND start_date < '2021-01-01' :: date
    GROUP BY
      customer_id,
      s.plan_id,
      plan_name,
      start_date,
      price
  ) AS t
ORDER BY
  customer_id;

-- D. Outside The Box Questions 
-- The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!

-- 1. How would you calculate the rate of growth for Foodie-Fi?

SELECT
  DATE_TRUNC('month', start_date) AS month,
  COUNT(customer_id) AS current_number_of_customers,
  LAG(COUNT(customer_id), 1) over (
    ORDER BY
      DATE_TRUNC('month', start_date)
  ) AS past_number_of_customers,
  (
    100 * (
      COUNT(customer_id) - LAG(COUNT(customer_id), 1) over (
        ORDER BY
          DATE_TRUNC('month', start_date)
      )
    ) / LAG(COUNT(customer_id), 1) over (
      ORDER BY
        DATE_TRUNC('month', start_date)
    )
  ) || '%' AS growth
FROM
  subscriptions AS s
  JOIN plans AS p ON s.plan_id = p.plan_id
WHERE
  plan_name != 'trial'
  AND plan_name != 'churn'
GROUP BY
  month
ORDER BY
  month;

-- 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?

-- Non-SQL question

-- 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?

-- Non-SQL question

-- 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?

-- Non-SQL question

-- 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

-- Non-SQL question
