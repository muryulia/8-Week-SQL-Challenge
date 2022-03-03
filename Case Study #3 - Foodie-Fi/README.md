# Case Study #3 - Foodie-Fi :avocado:

<img src="https://user-images.githubusercontent.com/98699089/156627293-3fc9484a-9903-408e-85f2-a95fcba757cd.png" width="500">

Danny has shared the data design for Foodie-Fi and also short descriptions on each of the database tables - our case study focuses on only 2 tables but there will be a challenge to create a new table for the Foodie-Fi team.

All datasets exist within the `foodie_fi` database schema.

## Available Data

### Table 1: `plans`

Customers can choose which plans to join Foodie-Fi when they first sign up.

Basic plan customers have limited access and can only stream their videos and is only available monthly at $9.90

Pro plan customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

Customers can sign up to an initial 7 day free trial will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.

When customers cancel their Foodie-Fi service - they will have a churn plan record with a null price but their plan will continue until the end of the billing period.

| plan_id | plan_name     | price |
|---------|---------------|-------|
| 0       | trial         | 0     |
| 1       | basic monthly | 9.90  |
| 2       | pro monthly   | 19.90 |
| 3       | pro annual    | 199   |
| 4       | churn         | null  |

### Table 2: `subscriptions`

Customer subscriptions show the exact date where their specific `plan_id` starts.

If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the start_date in the subscriptions table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan - the higher plan will take effect straightaway.

When customers churn - they will keep their access until the end of their current billing period but the `start_date` will be technically the day they decided to cancel their service.

| customer_id | plan_id | start_date |
|-------------|---------|------------|
| 1           | 0       | 2020-08-01 |
| 1           | 1       | 2020-08-08 |
| 2           | 0       | 2020-09-20 |
| 2           | 3       | 2020-09-27 |
| 11          | 0       | 2020-11-19 |
| 11          | 4       | 2020-11-26 |
| 13          | 0       | 2020-12-15 |
| 13          | 1       | 2020-12-22 |
| 13          | 2       | 2021-03-29 |
| 15          | 0       | 2020-03-17 |
| 15          | 2       | 2020-03-24 |
| 15          | 4       | 2020-04-29 |
| 16          | 0       | 2020-05-31 |
| 16          | 1       | 2020-06-07 |
| 16          | 3       | 2020-10-21 |
| 18          | 0       | 2020-07-06 |
| 18          | 2       | 2020-07-13 |
| 19          | 0       | 2020-06-22 |
| 19          | 2       | 2020-06-29 |
| 19          | 3       | 2020-08-29 |

## Entity Relationship Diagram

![изображение](https://user-images.githubusercontent.com/98699089/156618670-0540e629-2726-497f-b54f-f882df7a72c5.png)

## Table of Contents

[Introduction](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#introduction)

[Case Study Questions](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#case-study-questions)

[A. Customer Journey](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#a-customer-journey)

[1. Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#1-based-off-the-8-sample-customers-provided-in-the-sample-from-the-subscriptions-table-write-a-brief-description-about-each-customers-onboarding-journey)

[Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#try-to-keep-it-as-short-as-possible---you-may-also-want-to-run-some-sort-of-join-to-make-your-explanations-a-bit-easier)

[B. Data Analysis Questions](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#b-data-analysis-questions)

[1. How many customers has Foodie-Fi ever had?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#1-how-many-customers-has-foodie-fi-ever-had)

[2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#2-what-is-the-monthly-distribution-of-trial-plan-start_date-values-for-our-dataset---use-the-start-of-the-month-as-the-group-by-value)

[3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#3-what-plan-start_date-values-occur-after-the-year-2020-for-our-dataset-show-the-breakdown-by-count-of-events-for-each-plan_name)

[4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#4-what-is-the-customer-count-and-percentage-of-customers-who-have-churned-rounded-to-1-decimal-place)

[5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#5-how-many-customers-have-churned-straight-after-their-initial-free-trial---what-percentage-is-this-rounded-to-the-nearest-whole-number)

[6. What is the number and percentage of customer plans after their initial free trial?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#6-what-is-the-number-and-percentage-of-customer-plans-after-their-initial-free-trial)

[7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#7-what-is-the-customer-count-and-percentage-breakdown-of-all-5-plan_name-values-at-2020-12-31)

[8. How many customers have upgraded to an annual plan in 2020?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#8-how-many-customers-have-upgraded-to-an-annual-plan-in-2020)

[9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#9-how-many-days-on-average-does-it-take-for-a-customer-to-an-annual-plan-from-the-day-they-join-foodie-fi)

[10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#10-can-you-further-breakdown-this-average-value-into-30-day-periods-ie-0-30-days-31-60-days-etc)

[11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#11-how-many-customers-downgraded-from-a-pro-monthly-to-a-basic-monthly-plan-in-2020)

[C. Challenge Payment Question](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#c-challenge-payment-question)

[The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#the-foodie-fi-team-wants-you-to-create-a-new-payments-table-for-the-year-2020-that-includes-amounts-paid-by-each-customer-in-the-subscriptions-table-with-the-following-requirements)

[D. Outside The Box Questions](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#d-outside-the-box-questions)

[1. How would you calculate the rate of growth for Foodie-Fi?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#1-how-would-you-calculate-the-rate-of-growth-for-foodie-fi)

[2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#2-what-key-metrics-would-you-recommend-foodie-fi-management-to-track-over-time-to-assess-performance-of-their-overall-business)

[3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#3-what-are-some-key-customer-journeys-or-experiences-that-you-would-analyse-further-to-improve-customer-retention)

[4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#4-if-the-foodie-fi-team-were-to-create-an-exit-survey-shown-to-customers-who-wish-to-cancel-their-subscription-what-questions-would-you-include-in-the-survey)

[5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution.md/#5-what-business-levers-could-the-foodie-fi-team-use-to-reduce-the-customer-churn-rate-how-would-you-validate-the-effectiveness-of-your-ideas)
