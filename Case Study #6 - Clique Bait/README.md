# Case Study #6 - Clique Bait :hook:

<img src="https://user-images.githubusercontent.com/98699089/156626752-a3e26b14-df39-4166-8079-c519520ac9f1.png" width="500">

In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

## Available Data

For this case study there is a total of 5 datasets which you will need to combine to solve all of the questions.

### Users

Customers who visit the Clique Bait website are tagged via their `cookie_id`.

| user_id | cookie_id | start_date          |
|---------|-----------|---------------------|
| 397     | 3759ff    | 2020-03-30 00:00:00 |
| 215     | 863329    | 2020-01-26 00:00:00 |
| 191     | eefca9    | 2020-03-15 00:00:00 |
| 89      | 764796    | 2020-01-07 00:00:00 |
| 127     | 17ccc5    | 2020-01-22 00:00:00 |
| 81      | b0b666    | 2020-03-01 00:00:00 |
| 260     | a4f236    | 2020-01-08 00:00:00 |
| 203     | d1182f    | 2020-04-18 00:00:00 |
| 23      | 12dbc8    | 2020-01-18 00:00:00 |
| 375     | f61d69    | 2020-01-03 00:00:00 |

### Events

Customer visits are logged in this events table at a `cookie_id` level and the `event_type` and `page_id` values can be used to join onto relevant satellite tables to obtain further information about each event.

The `sequence_number` is used to order the events within each visit.
| visit_id | cookie_id | page_id | event_type | sequence_number | event_time                 |
|----------|-----------|---------|------------|-----------------|----------------------------|
| 719fd3   | 3d83d3    | 5       | 1          | 4               | 2020-03-02 00:29:09.975502 |
| fb1eb1   | c5ff25    | 5       | 2          | 8               | 2020-01-22 07:59:16.761931 |
| 23fe81   | 1e8c2d    | 10      | 1          | 9               | 2020-03-21 13:14:11.745667 |
| ad91aa   | 648115    | 6       | 1          | 3               | 2020-04-27 16:28:09.824606 |
| 5576d7   | ac418c    | 6       | 1          | 4               | 2020-01-18 04:55:10.149236 |
| 48308b   | c686c1    | 8       | 1          | 5               | 2020-01-29 06:10:38.702163 |
| 46b17d   | 78f9b3    | 7       | 1          | 12              | 2020-02-16 09:45:31.926407 |
| 9fd196   | ccf057    | 4       | 1          | 5               | 2020-02-14 08:29:12.922164 |
| edf853   | f85454    | 1       | 1          | 1               | 2020-02-22 12:59:07.652207 |
| 3c6716   | 02e74f    | 3       | 2          | 5               | 2020-01-31 17:56:20.777383 |

### Event Identifier

The `event_identifier` table shows the types of events which are captured by Clique Bait’s digital data systems.

| event_type | event_name    |
|------------|---------------|
| 1          | Page View     |
| 2          | Add to Cart   |
| 3          | Purchase      |
| 4          | Ad Impression |
| 5          | Ad Click      |

### Campaign Identifier

This table shows information for the 3 campaigns that Clique Bait has ran on their website so far in 2020.

| campaign_id | products | campaign_name                     | start_date          | end_date            |
|-------------|----------|-----------------------------------|---------------------|---------------------|
| 1           | 1-3      | BOGOF - Fishing For Compliments   | 2020-01-01 00:00:00 | 2020-01-14 00:00:00 |
| 2           | 4-5      | 25% Off - Living The Lux Life     | 2020-01-15 00:00:00 | 2020-01-28 00:00:00 |
| 3           | 6-8      | Half Off - Treat Your Shellf(ish) | 2020-02-01 00:00:00 | 2020-03-31 00:00:00 |

### Page Hierarchy

This table lists all of the pages on the Clique Bait website which are tagged and have data passing through from user interaction events.

| page_id | page_name      | product_category | product_id |
|---------|----------------|------------------|------------|
| 1       | Home Page      | null             | null       |
| 2       | All Products   | null             | null       |
| 3       | Salmon         | Fish             | 1          |
| 4       | Kingfish       | Fish             | 2          |
| 5       | Tuna           | Fish             | 3          |
| 6       | Russian Caviar | Luxury           | 4          |
| 7       | Black Truffle  | Luxury           | 5          |
| 8       | Abalone        | Shellfish        | 6          |
| 9       | Lobster        | Shellfish        | 7          |
| 10      | Crab           | Shellfish        | 8          |
| 11      | Oyster         | Shellfish        | 9          |
| 12      | Checkout       | null             | null       |
| 13      | Confirmation   | null             | null       |

## Entity Relationship Diagram

[1. Enterprise Relationship Diagram](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#1-enterprise-relationship-diagram)

## Table of Contents

[Introduction](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#introduction)

[Case Study Questions](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#case-study-questions)

[1. Enterprise Relationship Diagram](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#1-enterprise-relationship-diagram)

[2. Digital Analysis](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#2-digital-analysis)

[1. How many users are there?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#1-how-many-users-are-there)

[2. How many cookies does each user have on average?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#2-how-many-cookies-does-each-user-have-on-average)

[3. What is the unique number of visits by all users per month?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#3-what-is-the-unique-number-of-visits-by-all-users-per-month)

[4. What is the number of events for each event type?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#4-what-is-the-number-of-events-for-each-event-type)

[5. What is the percentage of visits which have a purchase event?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#5-what-is-the-percentage-of-visits-which-have-a-purchase-event)

[6. What is the percentage of visits which view the checkout page but do not have a purchase event?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#6-what-is-the-percentage-of-visits-which-view-the-checkout-page-but-do-not-have-a-purchase-event)

[7. What are the top 3 pages by number of views?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#7-what-are-the-top-3-pages-by-number-of-views)

[8. What is the number of views and cart adds for each product category?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#8-what-is-the-number-of-views-and-cart-adds-for-each-product-category)

[9. What are the top 3 products by purchases?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#9-what-are-the-top-3-products-by-purchases)

[3. Product Funnel Analysis](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#3-product-funnel-analysis)

[1. Which product had the most views, cart adds and purchases?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#1-which-product-had-the-most-views-cart-adds-and-purchases)

[2. Which product was most likely to be abandoned?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#2-which-product-was-most-likely-to-be-abandoned)

[3. Which product had the highest view to purchase percentage?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#3-which-product-had-the-highest-view-to-purchase-percentage)

[4. What is the average conversion rate from view to cart add?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#4-what-is-the-average-conversion-rate-from-view-to-cart-add)

[5. What is the average conversion rate from cart add to purchase?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#5-what-is-the-average-conversion-rate-from-cart-add-to-purchase)

[3. Campaigns Analysis](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution.md/#3-campaigns-analysis)
