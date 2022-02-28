# Case Study #1 - Danny's Diner ::ramen::

<img src="https://user-images.githubusercontent.com/98699089/156034616-ef978d44-af18-4e54-9885-1ac376a009bf.png" width="500">

Danny has shared with you 3 key datasets for this case study:
- `sales`;
- `menu`;
- `members`.

## Table 1: `sales`

The `sales` table captures all `customer_id` level purchases with an corresponding `order_date` and `product_id` information for when and what menu items were ordered.

| customer_id | order_date | product_id |
|-------------|------------|------------|
| A           | 2021-01-01 | 1          |
| A           | 2021-01-01 | 2          |
| A           | 2021-01-07 | 2          |
| A           | 2021-01-10 | 3          |
| A           | 2021-01-11 | 3          |
| A           | 2021-01-11 | 3          |
| B           | 2021-01-01 | 2          |
| B           | 2021-01-02 | 2          |
| B           | 2021-01-04 | 1          |
| B           | 2021-01-11 | 1          |
| B           | 2021-01-16 | 3          |
| B           | 2021-02-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-07 | 3          |

## Table 2: `menu`

The `menu` table maps the `product_id` to the actual `product_name` and price of each menu item.

| product_id | product_name | price |
|------------|--------------|-------|
| 1          | sushi        | 10    |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |

## Table 3: `members`

The final members table captures the `join_date` when a `customer_id` joined the beta version of the Danny’s Diner loyalty program.

| customer_id | join_date  |
|-------------|------------|
| A           | 2021-01-07 |
| B           | 2021-01-09 |

## Entity Relationship Diagram

![изображение](https://user-images.githubusercontent.com/98699089/156034410-8775d5d2-eda5-4453-9e33-54bfef253084.png)


## Table of Contents

[Problem Statement](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#problem-statement)

[Case Study Questions](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#case-study-questions)

[1. What is the total amount each customer spent at the restaurant?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#1-what-is-the-total-amount-each-customer-spent-at-the-restaurant)

[2. How many days has each customer visited the restaurant?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#2-how-many-days-has-each-customer-visited-the-restaurant)

[3. What was the first item from the menu purchased by each customer?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#3-what-was-the-first-item-from-the-menu-purchased-by-each-customer)

[4. What is the most purchased item on the menu and how many times was it purchased by all customers?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#4-what-is-the-most-purchased-item-on-the-menu-and-how-many-times-was-it-purchased-by-all-customers)

[5. Which item was the most popular for each customer?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#5-which-item-was-the-most-popular-for-each-customer)

[6. Which item was purchased first by the customer after they became a member?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#6-which-item-was-purchased-first-by-the-customer-after-they-became-a-member)

[7. Which item was purchased just before the customer became a member?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#7-which-item-was-purchased-just-before-the-customer-became-a-member)

[8. What is the total items and amount spent for each member before they became a member?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#8-what-is-the-total-items-and-amount-spent-for-each-member-before-they-became-a-member)

[9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#9-if-each-1-spent-equates-to-10-points-and-sushi-has-a-2x-points-multiplier---how-many-points-would-each-customer-have)

[10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#10-in-the-first-week-after-a-customer-joins-the-program-including-their-join-date-they-earn-2x-points-on-all-items-not-just-sushi---how-many-points-do-customer-a-and-b-have-at-the-end-of-january)

[Bonus Questions](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#bonus-questions)

[Join All The Things](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#join-all-the-things)

[Rank All The Things](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md/#rank-all-the-things)
