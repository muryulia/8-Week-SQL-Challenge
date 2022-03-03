# Case Study #5 - Data Mart  :shopping:

<img src="https://user-images.githubusercontent.com/98699089/156627083-8535d998-15ef-4c28-b339-978eeb54574a.png" width="500">

Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

## Available Data

For this case study there is only a single table: `data_mart.weekly_sales`.

The columns are pretty self-explanatory based on the column names but here are some further details about the dataset:
- Data Mart has international operations using a multi-region strategy
- Data Mart has both, a retail and online platform in the form of a Shopify store front to serve their customers
- Customer `segment` and `customer_type` data relates to personal age and demographics information that is shared with Data Mart
- `transactions` is the count of unique purchases made through Data Mart and sales is the actual dollar amount of purchases

Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a `week_date` value which represents the start of the sales week.

10 random rows are shown in the table output below from `data_mart.weekly_sales`:

| week_date | region        | platform | segment | customer_type | transactions | sales      |
|-----------|---------------|----------|---------|---------------|--------------|------------|
| 9/9/20    | OCEANIA       | Shopify  | C3      | New           | 610          | 110033.89  |
| 29/7/20   | AFRICA        | Retail   | C1      | New           | 110692       | 3053771.19 |
| 22/7/20   | EUROPE        | Shopify  | C4      | Existing      | 24           | 8101.54    |
| 13/5/20   | AFRICA        | Shopify  | null    | Guest         | 5287         | 1003301.37 |
| 24/7/19   | ASIA          | Retail   | C1      | New           | 127342       | 3151780.41 |
| 10/7/19   | CANADA        | Shopify  | F3      | New           | 51           | 8844.93    |
| 26/6/19   | OCEANIA       | Retail   | C3      | New           | 152921       | 5551385.36 |
| 29/5/19   | SOUTH AMERICA | Shopify  | null    | New           | 53           | 10056.2    |
| 22/8/18   | AFRICA        | Retail   | null    | Existing      | 31721        | 1718863.58 |
| 25/7/18   | SOUTH AMERICA | Retail   | null    | New           | 2136         | 81757.91   |

## Entity Relationship Diagram

![изображение](https://user-images.githubusercontent.com/98699089/156622725-8f9981cb-a9f5-4c18-bcd8-27472fbb55bb.png)

## Table of Contents

[Introduction](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#introduction)

[Case Study Questions](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#case-study-questions)

[1. Data Cleansing Steps](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#1-data-cleansing-steps)

[2. Data Exploration](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#2-data-exploration)

[1. What day of the week is used for each week_date value?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#1-what-day-of-the-week-is-used-for-each-week_date-value)

[2. What range of week numbers are missing from the dataset?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#2-what-range-of-week-numbers-are-missing-from-the-dataset)

[3. How many total transactions were there for each year in the dataset?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#3-how-many-total-transactions-were-there-for-each-year-in-the-dataset)

[4. What is the total sales for each region for each month?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#4-what-is-the-total-sales-for-each-region-for-each-month)

[5. What is the total count of transactions for each platform?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#5-what-is-the-total-count-of-transactions-for-each-platform)

[6. What is the percentage of sales for Retail vs Shopify for each month?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#6-what-is-the-percentage-of-sales-for-retail-vs-shopify-for-each-month)

[7. What is the percentage of sales by demographic for each year in the dataset?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#7-what-is-the-percentage-of-sales-by-demographic-for-each-year-in-the-dataset)

[8. Which age_band and demographic values contribute the most to Retail sales?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#8-which-age_band-and-demographic-values-contribute-the-most-to-retail-sales)

[9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#9-can-we-use-the-avg_transaction-column-to-find-the-average-transaction-size-for-each-year-for-retail-vs-shopify-if-not---how-would-you-calculate-it-instead)

[3. Before &amp; After Analysis](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#3-before--after-analysis)

[1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#1-what-is-the-total-sales-for-the-4-weeks-before-and-after-2020-06-15-what-is-the-growth-or-reduction-rate-in-actual-values-and-percentage-of-sales)

[2. What about the entire 12 weeks before and after?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#2-what-about-the-entire-12-weeks-before-and-after)

[3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#3-how-do-the-sale-metrics-for-these-2-periods-before-and-after-compare-with-the-previous-years-in-2018-and-2019)

[4. Bonus Question](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#4-bonus-question)

[Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#which-areas-of-the-business-have-the-highest-negative-impact-in-sales-metrics-performance-in-2020-for-the-12-week-before-and-after-period)

[Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution.md/#do-you-have-any-further-recommendations-for-dannys-team-at-data-mart-or-any-interesting-insights-based-off-this-analysis)
