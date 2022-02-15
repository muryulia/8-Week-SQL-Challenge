# Case Study #7 - Balanced Tree Clothing Co. :mountain_snow:

## Introduction

Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

Full description: [Case Study #7 - Balanced Tree Clothing Co.](https://8weeksqlchallenge.com/case-study-7/)

## Case Study Questions

The following questions can be considered key business questions and metrics that the Balanced Tree team requires for their monthly reports.

Each question can be answered using a single query - but as you are writing the SQL to solve each individual problem, keep in mind how you would generate all of these metrics in a single SQL script which the Balanced Tree team can run each month.

### High Level Sales Analysis

#### 1. What was the total quantity sold for all products?

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  SUM(qty) AS total_qty_sold
FROM
  sales
```

| total_qty_sold |
| -------------- |
| 45216          |

***There were 45216 items sold***

#### 2. What is the total generated revenue for all products before discounts?

First we need to check that the prices in the `sales` table are recorded as prices before discount. Let's join the `product_prices` table and the `sales` table to compare prices in these two tables.

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  prod_id,
  s.price AS sale_price,
  p.price AS product_price
FROM
  sales AS s
  JOIN product_prices AS p ON s.prod_id = p.product_id
GROUP BY
  prod_id,
  s.price,
  p.price
```

<details><summary> Click to expand :arrow_down: </summary>
  
| prod_id | sale_price | product_price |
| ------- | ---------- | ------------- |
| 2a2353  | 57         | 57            |
| 2feb6b  | 29         | 29            |
| 5d267b  | 40         | 40            |
| 72f5d4  | 19         | 19            |
| 9ec847  | 54         | 54            |
| b9a74d  | 17         | 17            |
| c4a632  | 13         | 13            |
| c8d436  | 10         | 10            |
| d5e9a6  | 23         | 23            |
| e31d39  | 10         | 10            |
| e83aa3  | 32         | 32            |
| f084eb  | 36         | 36            |

</details>

The prices are the same, now we can calculate the revenue using the `sales` table.

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  SUM(qty * price) AS total_sales
FROM
  sales
```

| total_sales |
| ----------- |
| 1289453     |

***The total revenue genetated is $1289453***

#### 3. What was the total discount amount for all products?

Discount in the sales table is recorded as percentage value, so we need to calculate the value in dollars first.
Next, the data type for the columns qty, price and discount is integer. We need to cast the integer data type as numeric to get the correct result.

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  ROUND(SUM(qty * price * discount :: numeric / 100), 2) AS total_discount
FROM
  sales
```

| total_discount |
| -------------- |
| 156229.14      |

***The total discount amount for all products is $156229,14***

### Transaction Analysis

#### 1. How many unique transactions were there?

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  COUNT(distinct txn_id) AS number_of_transactions
FROM
  sales
```

| number_of_transactions |
| ---------------------- |
| 2500                   |

***There were 2500 unique transactions***

#### 2. What is the average unique products purchased in each transaction?

Each order has unique product IDs, and the quantity for each product is recorded in a separate column. It means that we need to count the number of products and divide it to the number of unique transactions to get the average unique products purchased in each transaction.

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  COUNT(prod_id) / COUNT(distinct txn_id) AS avg_number_of_product_in_order
FROM
  sales
```

| avg_number_of_product_in_order |
| ------------------------------ |
| 6                              |

***There are 6 unique products purchased in each transaction on average***

#### 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

We need to calculate the revenue for each transaction first first. Next we can calculate the percentiles using the `percentile_cont()` function.

```sql
SET
  SEARCH_PATH = balanced_tree;
WITH revenue AS(
    SELECT
      txn_id,
      SUM(qty * price) AS revenue
    FROM
      sales
    GROUP BY
      txn_id
  )
SELECT
  PERCENTILE_CONT(0.25) WITHIN GROUP (
    ORDER BY
      revenue
  ) AS percentile_25,
  PERCENTILE_CONT(0.50) WITHIN GROUP (
    ORDER BY
      revenue
  ) AS percentile_50,
  PERCENTILE_CONT(0.75) WITHIN GROUP (
    ORDER BY
      revenue
  ) AS percentile_75
FROM
  revenue
```

| percentile_25 | percentile_50 | percentile_75 |
| ------------- | ------------- | ------------- |
| 375.75        | 509.5         | 647           |

#### 4. What is the average discount value per transaction?

First we need to calculate the total discount for each transactions. Then we can calculate the average discount value.

```sql
SET
  SEARCH_PATH = balanced_tree;
WITH revenue AS(
    SELECT
      txn_id,
      SUM(qty * price * discount :: numeric / 100) AS order_discount
    FROM
      sales
    GROUP BY
      txn_id
  )
SELECT
  ROUND(AVG(order_discount), 2) AS avg_order_discount
FROM
  revenue
```

| avg_order_discount |
| ------------------ |
| 62.49              |

***The average discount value per transaction is $62.49***

#### 5. What is the percentage split of all transactions for members vs non-members?

Information about membership is recorded in the `sales` table, the `member` column. Data in the `member` column has boolean type. We can set the records with the `True` value in the `member` column as 1 and the records with the `False` value as 0 using the `CASE WHEN` statement. Then we sum the values from the `member` column to get the number of orders made by members, divide this value to the total number of records in the member column, and multiply it to 100.

The number of guest orders is equal to 100 diminued to the share of the orders made by members.

```sql
SET
  SEARCH_PATH = balanced_tree;
WITH members AS (
    SELECT
      DISTINCT sales.txn_id,
      COUNT(distinct member) AS total_members,
      CASE
        WHEN member = TRUE THEN 1
        ELSE 0
      END AS number_of_members
    FROM
      sales
    GROUP BY
      txn_id,
      number_of_members
  )
SELECT
  distinct percentage_of_members,
  100 - percentage_of_members AS percentage_of_guests
FROM
  members,
  LATERAL(
    SELECT
      ROUND(
        100 *(SUM(number_of_members) / SUM(total_members)),
        1
      ) AS percentage_of_members
    FROM
      members
  ) pm
```

| percentage_of_members | percentage_of_guests |
| --------------------- | -------------------- |
| 60.2                  | 39.8                 |

***60.2% of transactions were made by members, 39.8% transactions were mare by non-members***

#### 6. What is the average revenue for member transactions and non-member transactions?

First we need to calculate the revenue for member transactions and for guest transactions separately. We can do it in a `CTE` using a `CASE WHEN` statement. Next we can calculate the average revenue for member transactions and non-member transactions.

```sql
SET
  SEARCH_PATH = balanced_tree;
WITH members AS (
    SELECT
      sales.txn_id,
      CASE
        WHEN member = TRUE THEN SUM(qty * price)
      END AS members_revenue,
      CASE
        WHEN member = FALSE THEN SUM(qty * price)
      END AS guests_revenue
    FROM
      sales
    GROUP BY
      txn_id,
      member
  )
SELECT
  ROUND(AVG(members_revenue), 2) AS avg_members_revenue,
  ROUND(AVG(guests_revenue), 2) AS avg_guests_revenue
FROM
  members
```

| avg_members_revenue | avg_guests_revenue |
| ------------------- | ------------------ |
| 516.27              | 515.04             |

***The average revenue per member transaction without discount is $516.27, for non-member transaction $515.04***

### Product Analysis

#### 1. What are the top 3 products by total revenue before discount?

We can calculate the total revenue by product and rank the results using the `row_number()` window function. After that we can select the rows with the rank from 1 to 3.

```sql
SET
  SEARCH_PATH = balanced_tree;
WITH revenue AS(
    SELECT
      product_name,
      SUM(qty * s.price) AS total_revenue,
      ROW_NUMBER() OVER(
        ORDER BY
          SUM(qty * s.price) DESC
      ) AS row
    FROM
      sales AS s
      JOIN product_details AS pd ON s.prod_id = pd.product_id
    GROUP BY
      product_name
  )
SELECT
  product_name,
  total_revenue
FROM
  revenue
WHERE
  row in (1, 2, 3)
```

| product_name                 | total_revenue |
| ---------------------------- | ------------- |
| Blue Polo Shirt - Mens       | 217683        |
| Grey Fashion Jacket - Womens | 209304        |
| White Tee Shirt - Mens       | 152000        |

#### 2. What is the total quantity, revenue and discount for each segment?

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  segment_name,
  SUM(qty) AS total_quantity,
  SUM(qty * s.price) AS total_revenue,
  round(
    SUM(qty * s.price * discount :: numeric / 100),
    2
  ) AS total_discount
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id
GROUP BY
  segment_name
ORDER BY
  1
```

| segment_name | total_quantity | total_revenue | total_discount |
| ------------ | -------------- | ------------- | -------------- |
| Jacket       | 11385          | 366983        | 44277.46       |
| Jeans        | 11349          | 208350        | 25343.97       |
| Shirt        | 11265          | 406143        | 49594.27       |
| Socks        | 11217          | 307977        | 37013.44       |

#### 3. What is the top selling product for each segment?

We can calculate top selling products by revenue or by quantity sold. To do that we need to calculate the total revenue and then rank the records by revenue or by quantity using the `row_number()` window function.

The top selling products for each segment by revenue:

```sql
SET
  SEARCH_PATH = balanced_tree;
WITH revenue AS (
    SELECT
      segment_name,
      product_name,
      SUM(qty) AS total_quantity,
      SUM(qty * s.price) AS total_revenue,
      ROW_NUMBER() OVER(
        PARTITION BY segment_name
        ORDER BY
          SUM(qty * s.price) DESC
      ) AS revenue_rank
    FROM
      sales AS s
      JOIN product_details AS pd ON s.prod_id = pd.product_id
    GROUP BY
      segment_name,
      product_name
  )
SELECT
  segment_name,
  product_name,
  total_quantity,
  total_revenue
FROM
  revenue
WHERE
  revenue_rank = 1
``

| segment_name | product_name                  | total_quantity | total_revenue |
| ------------ | ----------------------------- | -------------- | ------------- |
| Jacket       | Grey Fashion Jacket - Womens  | 3876           | 209304        |
| Jeans        | Black Straight Jeans - Womens | 3786           | 121152        |
| Shirt        | Blue Polo Shirt - Mens        | 3819           | 217683        |
| Socks        | Navy Solid Socks - Mens       | 3792           | 136512        |

Top selling products by quantity:

```sql
SET
  SEARCH_PATH = balanced_tree;
WITH revenue AS (
    SELECT
      segment_name,
      product_name,
      SUM(qty) AS total_quantity,
      SUM(qty * s.price) AS total_revenue,
      ROW_NUMBER() OVER(
        PARTITION BY segment_name
        ORDER BY
          SUM(qty) DESC
      ) AS qty_rank
    FROM
      sales AS s
      JOIN product_details AS pd ON s.prod_id = pd.product_id
    GROUP BY
      segment_name,
      product_name
  )
SELECT
  segment_name,
  product_name,
  total_quantity,
  total_revenue
FROM
  revenue
WHERE
  qty_rank = 1
```

The result is pretty much the same but a product in the Jeans segment has changed:

| segment_name | product_name                  | total_quantity | total_revenue |
| ------------ | ----------------------------- | -------------- | ------------- |
| Jacket       | Grey Fashion Jacket - Womens  | 3876           | 209304        |
| Jeans        | Navy Oversized Jeans - Womens | 3856           | 50128         |
| Shirt        | Blue Polo Shirt - Mens        | 3819           | 217683        |
| Socks        | Navy Solid Socks - Mens       | 3792           | 136512        |

#### 4. What is the total quantity, revenue and discount for each category?

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  category_name,
  SUM(qty) AS total_quantity,
  SUM(qty * s.price) AS total_revenue,
  round(
    SUM(qty * s.price * discount :: numeric / 100),
    2
  ) AS total_discount
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id
GROUP BY
  category_name
ORDER BY
  1
```

| category_name | total_quantity | total_revenue | total_discount |
| ------------- | -------------- | ------------- | -------------- |
| Mens          | 22482          | 714120        | 86607.71       |
| Womens        | 22734          | 575333        | 69621.43       |

#### 5. What is the top selling product for each category?

```sql
SET
  SEARCH_PATH = balanced_tree;
WITH revenue AS (
    SELECT
      category_name,
      product_name,
      SUM(qty) AS total_quantity,
      SUM(qty * s.price) AS total_revenue,
      ROW_NUMBER() OVER(
        PARTITION BY category_name
        ORDER BY
          SUM(qty * s.price) DESC
      ) AS revenue_rank,
      ROW_NUMBER() OVER(
        PARTITION BY category_name
        ORDER BY
          SUM(qty) DESC
      ) AS qty_rank
    FROM
      sales AS s
      JOIN product_details AS pd ON s.prod_id = pd.product_id
    GROUP BY
      category_name,
      product_name
  )
SELECT
  category_name,
  product_name,
  total_quantity,
  total_revenue
FROM
  revenue
WHERE
  revenue_rank = 1
  OR qty_rank = 1
```

For this query top selling products by revenue and by quantity are the same.

| category_name | product_name                 | total_quantity | total_revenue |
| ------------- | ---------------------------- | -------------- | ------------- |
| Mens          | Blue Polo Shirt - Mens       | 3819           | 217683        |
| Womens        | Grey Fashion Jacket - Womens | 3876           | 209304        |

#### 6. What is the percentage split of revenue by product for each segment?

We consider revenue for each segment as 100%, and we need to calculate the percentage for each product in the segment: divide the sales by product to sales by segment and multiply to 100. We can calculate total sales by segment by caclucating total revenue over the `segment_name` window.

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  segment_name,
  product_name,
  ROUND(
    100 *(
      SUM(qty * s.price) :: numeric / SUM(SUM(qty * s.price)) OVER(PARTITION BY segment_name)
    ),
    1
  ) AS percent_of_revenue
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id
GROUP BY
  segment_name,
  product_name
ORDER BY
  1, 3 DESC
```

| segment_name | product_name                     | percent_of_revenue |
| ------------ | -------------------------------- | ------------------ |
| Jacket       | Grey Fashion Jacket - Womens     | 57.0               |
| Jacket       | Khaki Suit Jacket - Womens       | 23.5               |
| Jacket       | Indigo Rain Jacket - Womens      | 19.5               |
| Jeans        | Black Straight Jeans - Womens    | 58.1               |
| Jeans        | Navy Oversized Jeans - Womens    | 24.1               |
| Jeans        | Cream Relaxed Jeans - Womens     | 17.8               |
| Shirt        | Blue Polo Shirt - Mens           | 53.6               |
| Shirt        | White Tee Shirt - Mens           | 37.4               |
| Shirt        | Teal Button Up Shirt - Mens      | 9.0                |
| Socks        | Navy Solid Socks - Mens          | 44.3               |
| Socks        | Pink Fluro Polkadot Socks - Mens | 35.5               |
| Socks        | White Striped Socks - Mens       | 20.2               |

#### 7. What is the percentage split of revenue by segment for each category?

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  segment_name,
  category_name,
  ROUND(
    100 *(
      SUM(qty * s.price) :: numeric / SUM(SUM(qty * s.price)) OVER(PARTITION BY category_name)
    ),
    1
  ) AS percent_of_revenue
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id
GROUP BY
  segment_name,
  category_name
ORDER BY
  1
```

| segment_name | category_name | percent_of_revenue |
| ------------ | ------------- | ------------------ |
| Jacket       | Womens        | 63.8               |
| Jeans        | Womens        | 36.2               |
| Shirt        | Mens          | 56.9               |
| Socks        | Mens          | 43.1               |

#### 8. What is the percentage split of total revenue by category?

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  category_name,
  ROUND(
    100 *(
      SUM(qty * s.price) :: numeric / SUM(SUM(qty * s.price)) OVER()
    ),
    1
  ) AS percent_of_revenue
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id
GROUP BY
  category_name
ORDER BY
  1
```

| category_name | percent_of_revenue |
| ------------- | ------------------ |
| Mens          | 55.4               |
| Womens        | 44.6               |

#### 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

First we need to count the number of transactions for each product regardless of the quantity of the product in the transaction, next we'll calculate the percentage of penetration for each product - it shows how often customers purchased this product, or also the most upselling product for transaction. 

In our example the most penetrating product is socks - I think people might add this product to get a discount if they have spent not enough to get it and they do not want to spend too much. Smart pricing and carefully chosen upsell products is a key to success.

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  product_name,
  ROUND(
    100 *(COUNT(product_name) :: numeric / number_of_txn),
    2
  ) AS percent_of_penetration
FROM
  sales AS s
  JOIN product_details AS pd ON s.prod_id = pd.product_id,
  LATERAL(
    SELECT
      COUNT(distinct txn_id) AS number_of_txn
    FROM
      sales
  ) ss
GROUP BY
  product_name,
  number_of_txn
ORDER BY
  2 DESC
```

| product_name                     | percent_of_penetration |
| -------------------------------- | ---------------------- |
| Navy Solid Socks - Mens          | 51.24                  |
| Grey Fashion Jacket - Womens     | 51.00                  |
| Navy Oversized Jeans - Womens    | 50.96                  |
| White Tee Shirt - Mens           | 50.72                  |
| Blue Polo Shirt - Mens           | 50.72                  |
| Pink Fluro Polkadot Socks - Mens | 50.32                  |
| Indigo Rain Jacket - Womens      | 50.00                  |
| Khaki Suit Jacket - Womens       | 49.88                  |
| Black Straight Jeans - Womens    | 49.84                  |
| White Striped Socks - Mens       | 49.72                  |
| Cream Relaxed Jeans - Womens     | 49.72                  |
| Teal Button Up Shirt - Mens      | 49.68                  |

#### 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

This is a combinatorics question. We need to find all possible combinations of 3 different items from all the items in the list. The total number of items is 12, so we have 220 possible combinatations of 3 different items. 

The formula to count the number of combinations is:

![index](https://user-images.githubusercontent.com/98699089/154108351-75600543-8c50-4efb-bff3-bddc07b12fe1.png)

`12! / 3! * (12 - 9)! = 12! / 3! * 9! = 4 * 5 * 11 = 220`

We will use self joins to create the table of all these combinations. After that we can count the number of transcations for each combination and rank them using the row_number() window function.

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  product_1,
  product_2,
  product_3,
  times_bought_together
FROM
  (
    with products AS(
      SELECT
        txn_id,
        product_name
      FROM
        sales AS s
        JOIN product_details AS pd ON s.prod_id = pd.product_id
    )
    SELECT
      p.product_name AS product_1,
      p1.product_name AS product_2,
      p2.product_name AS product_3,
      COUNT(*) AS times_bought_together,
      ROW_NUMBER() OVER(
        ORDER BY
          COUNT(*) DESC
      ) AS rank
    FROM
      products AS p
      JOIN products AS p1 ON p.txn_id = p1.txn_id
      AND p.product_name != p1.product_name
      AND p.product_name < p1.product_name
      JOIN products AS p2 ON p.txn_id = p2.txn_id
      AND p.product_name != p2.product_name
      AND p1.product_name != p2.product_name
      AND p.product_name < p2.product_name
      AND p1.product_name < p2.product_name
    GROUP BY
      p.product_name,
      p1.product_name,
      p2.product_name
  ) pp
WHERE
  RANK = 1
```

| product_1                    | product_2                   | product_3              | times_bought_together |
| ---------------------------- | --------------------------- | ---------------------- | --------------------- |
| Grey Fashion Jacket - Womens | Teal Button Up Shirt - Mens | White Tee Shirt - Mens | 352                   |


The most common combination of 3 products in a transaction is:
- Grey Fashion Jacket - Womens
- Teal Button Up Shirt - Mens
- White Tee Shirt - Mens

These products were bought together 352 times.

### Reporting Challenge

Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the same analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)

[WORK IN PROGRESS]

### Bonus Challenge

Use a single SQL query to transform the `product_hierarchy` and `product_prices` datasets to the `product_details` table.

Hint: you may want to consider using a recursive CTE to solve this problem!

I did not use recursive CTEs or nested queries here, just consequent self joins on `parent_id` and `id` columns. The `product_name` column generated by the `concat()` function.

```sql
SET
  SEARCH_PATH = balanced_tree;
SELECT
  product_id,
  price,
  CONCAT(
    ph.level_text,
    ' ',
    ph1.level_text,
    ' - ',
    ph2.level_text
  ) AS product_name,
  ph2.id AS category_id,
  ph1.id AS segment_id,
  ph.id AS style_id,
  ph2.level_text AS category_name,
  ph1.level_text AS segment_name,
  ph.level_text AS style_name
FROM
  product_hierarchy AS ph
  JOIN product_hierarchy AS ph1 on ph.parent_id = ph1.id
  JOIN product_hierarchy AS ph2 on ph1.parent_id = ph2.id
  JOIN product_prices AS pp on ph.id = pp.id
```

| product_id | price | product_name                     | category_id | segment_id | style_id | category_name | segment_name | style_name          |
| ---------- | ----- | -------------------------------- | ----------- | ---------- | -------- | ------------- | ------------ | ------------------- |
| c4a632     | 13    | Navy Oversized Jeans - Womens    | 1           | 3          | 7        | Womens        | Jeans        | Navy Oversized      |
| e83aa3     | 32    | Black Straight Jeans - Womens    | 1           | 3          | 8        | Womens        | Jeans        | Black Straight      |
| e31d39     | 10    | Cream Relaxed Jeans - Womens     | 1           | 3          | 9        | Womens        | Jeans        | Cream Relaxed       |
| d5e9a6     | 23    | Khaki Suit Jacket - Womens       | 1           | 4          | 10       | Womens        | Jacket       | Khaki Suit          |
| 72f5d4     | 19    | Indigo Rain Jacket - Womens      | 1           | 4          | 11       | Womens        | Jacket       | Indigo Rain         |
| 9ec847     | 54    | Grey Fashion Jacket - Womens     | 1           | 4          | 12       | Womens        | Jacket       | Grey Fashion        |
| 5d267b     | 40    | White Tee Shirt - Mens           | 2           | 5          | 13       | Mens          | Shirt        | White Tee           |
| c8d436     | 10    | Teal Button Up Shirt - Mens      | 2           | 5          | 14       | Mens          | Shirt        | Teal Button Up      |
| 2a2353     | 57    | Blue Polo Shirt - Mens           | 2           | 5          | 15       | Mens          | Shirt        | Blue Polo           |
| f084eb     | 36    | Navy Solid Socks - Mens          | 2           | 6          | 16       | Mens          | Socks        | Navy Solid          |
| b9a74d     | 17    | White Striped Socks - Mens       | 2           | 6          | 17       | Mens          | Socks        | White Striped       |
| 2feb6b     | 29    | Pink Fluro Polkadot Socks - Mens | 2           | 6          | 18       | Mens          | Socks        | Pink Fluro Polkadot |
