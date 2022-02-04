# Case Study #3 - Foodie-Fi :avocado: 

## Introduction

Danny realised that he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows!
Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

This case study focuses on using subscription style digital data to answer important business questions.

Full description: [Case Study #3 - Foodie-Fi](https://8weeksqlchallenge.com/case-study-3/)

## Case Study Questions

### A. Customer Journey

#### 1. Based off the 8 sample customers provided in the sample from the `subscriptions` table, write a brief description about each customer’s onboarding journey.
#### Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

The sample table has plan IDs, join the plan table to show plan names.

- Customer with ID 1 started with a trial subscription and continued with a basic monthly subscription in 7 days after sign-up

- Customer with ID 2 started with a trial subscription and continued with a pro annual subscription in 7 days after sign-up

- Customer with ID 11 started with a trial subscription and has churned in 7 days after sign-up

- Customer with ID 13 started with a trial subscription, then purchased a basic monthly subscription in 7 days after sign-up and in 7 days after that has upgraded to a pro monthly subscription

- Customer with ID 15 started with a trial subscription, purchased a basic monthly subscription in 7 days after sign-up and has churned in a month

- Customer with ID 16 started with a trial subscription, purchased a basic monthly subscription in 7 days after sign-up and in 4 months after that has ugraded to a pro annual subscription

- Customer with ID 18 started with a trial subscription and continued with a pro monthly subscription in 7 days after sign-up

- Customer with ID 19 started with a trial subscription, continued with a pro monthly subscription in 7 days after sign-up and has upgraded to pro annual subscpription in 2 months

### B. Data Analysis Questions

#### 1. How many customers has Foodie-Fi ever had?

````sql
    SELECT
      COUNT(distinct customer_id) AS total_number_of_customers
    FROM
      subscriptions
````

| total_number_of_customers |
| ------------------------- |
| 1000                      |

#### 2. What is the monthly distribution of trial plan `start_date` values for our dataset - use the start of the month as the group by value

````sql
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
      start_date
````

| start_date | plan_name | number_of_customers |
| ---------- | --------- | ------------------- |
| 2020-01-01 | trial     | 88                  |
| 2020-02-01 | trial     | 68                  |
| 2020-03-01 | trial     | 94                  |
| 2020-04-01 | trial     | 81                  |
| 2020-05-01 | trial     | 88                  |
| 2020-06-01 | trial     | 79                  |
| 2020-07-01 | trial     | 89                  |
| 2020-08-01 | trial     | 88                  |
| 2020-09-01 | trial     | 87                  |
| 2020-10-01 | trial     | 79                  |
| 2020-11-01 | trial     | 75                  |
| 2020-12-01 | trial     | 84                  |

#### 3. What plan `start_date` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each `plan_name`

To answer this question I selected all dates after the year 2020, counted the number of events and grouped them by the plan name.

Interesting - there are no new sign-ups in 2021.

````sql
SET
  search_path = foodie_fi;
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
  plan_name
````

| plan_name     | number_of_events |
| ------------- | ---------------- |
| basic monthly | 8                |
| churn         | 71               |
| pro annual    | 63               |
| pro monthly   | 60               |

There were following events with the start date after 2020:

***8 basic monthly subscriptions purchased***

***71 customer churned***

***63 pro annual subscriptions purchased***

***60 pro monthly subscriptions purchased***

#### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

Here we need to count all customers on the churn plan. To calculate the percentage of the churned customers we need to divide the number of churned customers to the the total number of customers.

````sql
SET
  search_path = foodie_fi;
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
  ) AS count_churn
 ```` 
| churned_customers | churn_percentage |
| ----------------- | ---------------- |
| 307               | 30.7             |

***There were 307 churned customers, and the churn rate is 30.7%***

#### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

As we know, the trial period takes 7 days. It means that we need two dates: start date, when the trial starts, and the date in 7 days after the trial has been started. We need to count the number of churn plans after 7 days. 

Next we can calculate the percentage of churned after trial customers: as a ratio to all customers, or as a ratio to all churned customers.

````sql
SET
  search_path = foodie_fi;
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
  churned_customers
````

| plan_name | number_of_churned_customers | percentage_of_churned_after_trial | churned_after_trial_to_all_churned |
| --------- | --------------------------- | --------------------------------- | ---------------------------------- |
| churn     | 92                          | 9                                 | 30                                 |

***92 customers have churned after their initial trial, it is 9% from all customers and 30% of all churned customers***

#### 6. What is the number and percentage of customer plans after their initial free trial?

This question is similar to the previous one but we need to calculate all kinds of plans after trial.

````sql
SET
  search_path = foodie_fi;
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
      GROUP BY plan_name
````

| plan_name     | number_of_plans_after_trial | percentage_of_total_customers |
| ------------- | --------------------------- | ----------------------------- |
| basic monthly | 546                         | 54.6                          |
| churn         | 92                          | 9.2                           |
| pro annual    | 37                          | 3.7                           |
| pro monthly   | 325                         | 32.5                          |


#### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

To answer this question we need to count which plans are active at 2020-12-31 and how many customers are on these plans.

We can do that using the `rank()` window function in CTE: we select plans with start date before or equal to 2020-12-31 and then rank customers by start date in descending order. So the last plan date will have rank = 1 and we can count the number of plans by date.

````sql
SET
  search_path = foodie_fi;
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
  1
````

| plan_name     | number_of_plans | percentage_of_plans |
| ------------- | --------------- | ------------------- |
| basic monthly | 224             | 22.4                |
| churn         | 236             | 23.6                |
| pro annual    | 195             | 19.5                |
| pro monthly   | 326             | 32.6                |
| trial         | 19              | 1.9                 |


#### 8. How many customers have upgraded to an annual plan in 2020?

We can calculate how many users have started their annual plan in 2020 by selecting users on annual plans with start dates between January 1, 2020 and December 31, 2020.

````sql
SET
  search_path = foodie_fi;
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
  plan_name
````

| plan_name  | number_of_customers |
| ---------- | ------------------- |
| pro annual | 195                 |

***195 customers have upgraded to the annual plan in 2020***

#### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

We can use `SELF JOIN` to calculate the average difference between signup date and upgrade to an annual plan date.

````sql
SET
  search_path = foodie_fi;
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
  plan_name
````

| plan_name  | average_days_to_upgrade |
| ---------- | ----------------------- |
| pro annual | 105                     |

***It takes 105 days in average for a customer to upgrade to the annual plan from their sign-up date***

#### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

I counted customers who upgraded their membership to the annual plan by day groups, and added the average value of days from the previous query too.
My query is not the best option as I see now. I'll keep it unchanged but there are more optimal ways to write this query, for example using the `width_bucket()` function.

````sql
SET
  search_path = foodie_fi;
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
  END
````

| plan_name  | group_by_days_to_upgrade | number_of_customers | average_days_to_upgrade |
| ---------- | ------------------------ | ------------------- | ----------------------- |
| pro annual | 0-30 days                | 49                  | 10                      |
| pro annual | 31-60 days               | 24                  | 42                      |
| pro annual | 61-90 days               | 34                  | 71                      |
| pro annual | 91-120 days              | 35                  | 101                     |
| pro annual | 121-150 days             | 42                  | 133                     |
| pro annual | 151-180 days             | 36                  | 162                     |
| pro annual | 181-210 days             | 26                  | 191                     |
| pro annual | 211-240 days             | 4                   | 224                     |
| pro annual | 241-270 days             | 5                   | 257                     |
| pro annual | 271-300 days             | 1                   | 285                     |
| pro annual | 301-330 days             | 1                   | 327                     |
| pro annual | 331-360 days             | 1                   | 346                     |

And here is a visualisation to see the dynamic more clearly:

![image](https://user-images.githubusercontent.com/98699089/152517319-8ff69cde-4b39-4be9-8688-811f2e5c12e7.png)

#### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

In this query I would like to show the day difference between the date when a basic plan started and the date when a pro plan started.

If the difference is greater than zero then the customer has downgraded their plan - they had a pro first and downgraded to a basic after.

If the difference is below zero it means that a basic plan comes before a pro.

I do it because 0 customers downgraded their plans from a pro monthly to a basic monthly plan in 2020 and adding this condition into WHERE statements obviously returns an empty result.

````sql
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
      5
````

| customer_id | basic_plan_started_on | pro_plan_started_on | days_between_basic_and_pro |
| ----------- | --------------------- | ------------------- | -------------------------- |
| 315         | 2020-12-20            | 2020-12-21          | -1                         |
| 775         | 2020-12-01            | 2020-12-03          | -2                         |
| 151         | 2020-09-14            | 2020-09-17          | -3                         |
| 806         | 2020-05-09            | 2020-05-13          | -4                         |
| 914         | 2020-07-25            | 2020-07-30          | -5                         |

As a result, we can see that there were no basic plans that had been started after pro plans. 

***0 customers downgraded their plans from a pro monthly to a basic monthly plan in 2020***

### C. Challenge Payment Question

#### The Foodie-Fi team wants you to create a new `payments` table for the year 2020 that includes amounts paid by each customer in the `subscriptions` table with the following requirements:

- monthly payments always occur on the same day of month as the original `start_date` of any monthly paid plan
- 
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- 
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- 
- once a customer churns they will no longer make payments

We can select the values into a temporary table using the `SELECT INTO` statement.

Recurring payments are created with `GENERATE_SERIES()` function, previous and next values are checked with `LAG()` and `LEAD()` window functions.

Next, we need to remember that if a customer upgrades their plan during their current payment period, we need to count the difference between curren plan and the new plan. For example, customer #16 paid for their basic monthly plan on October 10 and upgraded to an annual pro plan on October 21. We deduct their annual payment on the amount of their basic monthly payment: 199 - 9.9 = 189.1

But if they upgrade plans in the next payment period we need to count one payment only. For example, customer #19 paid for their pro monthly plan on  July 29 and upgraded to an annual plan on August 29. We count each payment separately and we need to avoid double payments.

To check how many days passed between two payments we calculate the difference between two dates. If the difference is below 30, we deduct the amount paid from the new plan payment. To avoid double payments between two plans, I added 1 second for each recurrent payment, it adds a maximum of 12 seconds per one year. 

````sql
SET
  search_path = foodie_fi;
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
  customer_id
````

The query creates a temporary table with 4448 rows. Here is a few rows from the table:

| customer_id | plan_id | plan_name     | payment_date | amount | payment_order |
| ----------- | ------- | ------------- | ------------ | ------ | ------------- |
| 1           | 1       | basic monthly | 2020-08-08   | 9.90   | 1             |
| 1           | 1       | basic monthly | 2020-09-08   | 9.90   | 2             |
| 1           | 1       | basic monthly | 2020-10-08   | 9.90   | 3             |
| 1           | 1       | basic monthly | 2020-11-08   | 9.90   | 4             |
| 1           | 1       | basic monthly | 2020-12-08   | 9.90   | 5             |
| 2           | 3       | pro annual    | 2020-09-27   | 199.00 | 1             |
...
| 8           | 1       | basic monthly | 2020-06-18   | 9.90   | 1             |
| 8           | 1       | basic monthly | 2020-07-18   | 9.90   | 2             |
| 8           | 2       | pro monthly   | 2020-08-03   | 10.00  | 3             |
| 8           | 2       | pro monthly   | 2020-09-03   | 19.90  | 4             |
| 8           | 2       | pro monthly   | 2020-10-03   | 19.90  | 5             |
| 8           | 2       | pro monthly   | 2020-11-03   | 19.90  | 6             |
| 8           | 2       | pro monthly   | 2020-12-03   | 19.90  | 7             |
...
| 16          | 1       | basic monthly | 2020-06-07   | 9.90   | 1             |
| 16          | 1       | basic monthly | 2020-07-07   | 9.90   | 2             |
| 16          | 1       | basic monthly | 2020-08-07   | 9.90   | 3             |
| 16          | 1       | basic monthly | 2020-09-07   | 9.90   | 4             |
| 16          | 1       | basic monthly | 2020-10-07   | 9.90   | 5             |
| 16          | 3       | pro annual    | 2020-10-21   | 189.10 | 6             |
| 17          | 1       | basic monthly | 2020-08-03   | 9.90   | 1             |
| 17          | 1       | basic monthly | 2020-09-03   | 9.90   | 2             |
| 17          | 1       | basic monthly | 2020-10-03   | 9.90   | 3             |
| 17          | 1       | basic monthly | 2020-11-03   | 9.90   | 4             |
| 17          | 1       | basic monthly | 2020-12-03   | 9.90   | 5             |
| 17          | 3       | pro annual    | 2020-12-11   | 189.10 | 6             |
| 18          | 2       | pro monthly   | 2020-07-13   | 19.90  | 1             |
| 18          | 2       | pro monthly   | 2020-08-13   | 19.90  | 2             |
| 18          | 2       | pro monthly   | 2020-09-13   | 19.90  | 3             |
| 18          | 2       | pro monthly   | 2020-10-13   | 19.90  | 4             |
| 18          | 2       | pro monthly   | 2020-11-13   | 19.90  | 5             |
| 18          | 2       | pro monthly   | 2020-12-13   | 19.90  | 6             |
| 19          | 2       | pro monthly   | 2020-06-29   | 19.90  | 1             |
| 19          | 2       | pro monthly   | 2020-07-29   | 19.90  | 2             |
| 19          | 3       | pro annual    | 2020-08-29   | 199.00 | 3             |
| 20          | 1       | basic monthly | 2020-04-15   | 9.90   | 1             |
| 20          | 1       | basic monthly | 2020-05-15   | 9.90   | 2             |
| 20          | 3       | pro annual    | 2020-06-05   | 189.10 | 3             |

### D. Outside The Box Questions 

<details><summary> Click to expand :arrow_down: </summary>

The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!

#### 1. How would you calculate the rate of growth for Foodie-Fi?

The current value subtracts the previous value, then divides to the previous value, multiplying by 100 to get the percentage result.
If the value is greater than 0 then the growth is positive, if the value is below or equal to 0 then there is no growth.

We can calculate revenue growth or customer growth, year over year growth, month over month growth.

Values need to be cleared before calculation, for example, if we calculate revenue we need to subtract refunds or chargebacks first as they are not in our revenue anymore.
What about customers, it can be calculated as the growth of active customers (all customers subtracting churned customers and trial customers).

Let's calculate month over month grow using `lag()` window function:

````sql
SET
  search_path = foodie_fi;
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
  month
````

| month                    | current_number_of_customers | past_number_of_customers | growth |
| ------------------------ | --------------------------- | ------------------------ | ------ |
| 2020-01-01T00:00:00.000Z | 62                          |                          |        |
| 2020-02-01T00:00:00.000Z | 71                          | 62                       | 14%    |
| 2020-03-01T00:00:00.000Z | 93                          | 71                       | 30%    |
| 2020-04-01T00:00:00.000Z | 85                          | 93                       | -8%    |
| 2020-05-01T00:00:00.000Z | 105                         | 85                       | 23%    |
| 2020-06-01T00:00:00.000Z | 106                         | 105                      | 0%     |
| 2020-07-01T00:00:00.000Z | 104                         | 106                      | -1%    |
| 2020-08-01T00:00:00.000Z | 134                         | 104                      | 28%    |
| 2020-09-01T00:00:00.000Z | 115                         | 134                      | -14%   |
| 2020-10-01T00:00:00.000Z | 125                         | 115                      | 8%     |
| 2020-11-01T00:00:00.000Z | 101                         | 125                      | -19%   |
| 2020-12-01T00:00:00.000Z | 111                         | 101                      | 9%     |
| 2021-01-01T00:00:00.000Z | 58                          | 111                      | -47%   |
| 2021-02-01T00:00:00.000Z | 29                          | 58                       | -50%   |
| 2021-03-01T00:00:00.000Z | 24                          | 29                       | -17%   |
| 2021-04-01T00:00:00.000Z | 20                          | 24                       | -16%   |

We can see that the number of users during the last four months is decreasing.

#### 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?

- Total number of the customers on a certain date, 

- number of active customers (total - churn), 

- number of paying customers (total - churn - trial),

- number of new customers on a certain date,

- ratio new to churn customers - to understand if the company grows or losing their customers,

- ratio new customers to paying customers, 

- revenue: total revenue, recurring revenue, average revenue per user (ARPU), average revenue per paying user (ARPPU)

- number of active customers by plans - to understand what plan do customers prefer, and to see growth points,

- number of active customers on date after their sign-up (cohort analysis: day 7, day 30, etc).

#### 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?

I think it is important to see what happens on the day 7 when the trial ends - if a user becomes a customer or not. Next, what happens after their purchase - do they stick with it or prefer to upgrade / downgrade it? If a customer decides to cancel their subscription - we can analyze when it happened and how long they used the APP before cancel.

Also it always helpful to know how often customers use the app, how long they use it, how many videos they watch during a session, check which rating the customers leave for the APP, number of uninstalls / reinstalls.

#### 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?

1. What’s the single biggest reason for you cancelling? - Please select one reason

- I don’t understand how to use Foodie-Fi

- Foodie-Fi is too expensive

- I found another product that I like better

Optional follow-up question: What service are you using now?

- I no longer needed Foodie-Fi

- Foodie-Fi service quality is too low

- Foodie-Fi is  missing some features that I need

Optional follow-up question: could you please describe the feature you need?

- Other (could you please explain your reason?)

2.Did we meet your expectations?

- Yes

- No

3. What would it take for you to reconsider subscribing to Foodie-Fi? - Optional

4. How can we improve? - Optional, could you please let us know how can we make Foodie-Fi better?

#### 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

First need to understand what churn rate we are talking about.

Churn rate after trial is different from the paying customer churn rate.
When a user sign-ups, the Foodie-Fi goal is to convert him into customer as quick as possible. Need to show them features of the paid plans and offer a special discount for early subscription for pro plans.

After the trial ends, it is possible to show limited amount of videos per day for free, and offer another discount.

Email marketing: if customers subscribed to our email updates we can remind them about the service - not often, when there is something interesting for the user to know.
We can remind users about the service via targeted advertisement campaigns too.

Loyalty program: paying customers can be extra rewarded for their loyalty with bonus points for their future purchases for example. Adding gamification elements to the loyalty program might also work: like goal-setting, countdowns, or virtual rewards.

Feedback feature - if something goes wrong, and a user or a customer has an option to easily share their opinion or send a bug report - that's fine. Sometimes users are ready to pay but just cannot do it because of some technical problems or something that can be resolved easily.

If a paying user churns then we can ask them about the reasons - why they decided to cancel their subscription?

And also send them some reminders from time to time.

How to validate: A/B tests, cohort analysis - number of active customers by date (retention day 7, retention day 30 etc.). 
</details>
