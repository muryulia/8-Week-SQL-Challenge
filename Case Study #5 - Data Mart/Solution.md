# Case Study #5 - Data Mart

## Introduction

Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

The key business question he wants you to help him answer are the following:

- What was the quantifiable impact of the changes introduced in June 2020?

- Which platform, region, segment and customer types were the most impacted by this change?

- What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?

Full description: [Case Study #5 - Data Mart](https://8weeksqlchallenge.com/case-study-5/)

## Case Study Questions

The following case study questions require some data cleaning steps before we start to unpack Danny’s key business questions in more depth.

### 1. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the `data_mart` schema named `clean_weekly_sales`:

- Convert the `week_date` to a `DATE` format
- Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a `month_number` with the calendar month for each week_date value as the 3rd column
- Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called `age_band` after the original segment column using the following mapping on the number inside the segment value
- Add a new `demographic` column using the following mapping for the first letter in the segment values
- Ensure all `null` string values with an "unknown" string value in the original segment column as well as the new `age_band` and `demographic` columns
- Generate a new `avg_transaction` column as the sales value divided by transactions rounded to 2 decimal places for each record

```sql
SET
  search_path = data_mart;
SELECT
  date AS week_date,
  EXTRACT(
    WEEK
    FROM
      date
  ) :: int AS week_number,
  EXTRACT(
    MONTH
    FROM
      date
  ) :: int AS month_number,
  EXTRACT(
    YEAR
    FROM
      date
  ) :: int AS calendar_year,
  region,
  platform,
  CASE
    WHEN segment = 'null' then 'unknown'
    ELSE segment
  END AS segment,
  CASE
    WHEN substr(segment, 2, 1) = '1' then 'Young Adults'
    WHEN substr(segment, 2, 1) = '2' then 'Middle Aged'
    WHEN substr(segment, 2, 1) in ('3', '4') then 'Retirees'
    ELSE 'unknown'
  END AS age_band,
  CASE
    WHEN substr(segment, 1, 1) = 'C' then 'Couples'
    WHEN substr(segment, 1, 1) = 'F' then 'Families'
    ELSE 'unknown'
  END AS demographic,
  customer_type,
  transactions,
  sales,
  avg_transaction INTO clean_weekly_sales
FROM
  weekly_sales,
  LATERAL (
    SELECT
      TO_DATE(week_date, 'DD/MM/YY') AS date
  ) date,
  LATERAL (
    SELECT
      ROUND((sales :: numeric / transactions), 2) AS avg_transaction
  ) avt
ORDER BY
  calendar_year
  ```
Data is added to a new temporary table using `SELECT INTO` statement. The original table remains unchanged, change log will be added later.

Here are the first 20 rows of the new table.

| week_date                | week_number | month_number | calendar_year | region        | platform | segment | age_band     | demographic | customer_type | transactions | sales    | avg_transaction |
| ------------------------ | ----------- | ------------ | ------------- | ------------- | -------- | ------- | ------------ | ----------- | ------------- | ------------ | -------- | --------------- |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | USA           | Shopify  | F1      | Young Adults | Families    | New           | 104          | 16827    | 161.80          |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | ASIA          | Shopify  | C3      | Retirees     | Couples     | New           | 179          | 26659    | 148.93          |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | SOUTH AMERICA | Shopify  | C3      | Retirees     | Couples     | Existing      | 61           | 14120    | 231.48          |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | EUROPE        | Shopify  | F3      | Retirees     | Families    | New           | 3            | 628      | 209.33          |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | AFRICA        | Retail   | C3      | Retirees     | Couples     | New           | 100193       | 3674012  | 36.67           |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | CANADA        | Retail   | F3      | Retirees     | Families    | Existing      | 79527        | 4697152  | 59.06           |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | CANADA        | Retail   | C3      | Retirees     | Couples     | New           | 27513        | 978070   | 35.55           |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | CANADA        | Shopify  | F3      | Retirees     | Families    | Existing      | 408          | 80997    | 198.52          |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | USA           | Retail   | unknown | unknown      | unknown     | Existing      | 10953        | 590212   | 53.89           |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | OCEANIA       | Retail   | F3      | Retirees     | Families    | New           | 107209       | 3767499  | 35.14           |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | ASIA          | Shopify  | F3      | Retirees     | Families    | Existing      | 1079         | 221475   | 205.26          |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | OCEANIA       | Shopify  | C2      | Middle Aged  | Couples     | Existing      | 2908         | 591752   | 203.49          |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | CANADA        | Shopify  | unknown | unknown      | unknown     | Existing      | 61           | 11781    | 193.13          |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | USA           | Shopify  | C2      | Middle Aged  | Couples     | New           | 148          | 25314    | 171.04          |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | AFRICA        | Retail   | unknown | unknown      | unknown     | New           | 62763        | 2595500  | 41.35           |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | EUROPE        | Retail   | F2      | Middle Aged  | Families    | Existing      | 13774        | 919696   | 66.77           |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | AFRICA        | Retail   | C1      | Young Adults | Couples     | New           | 87792        | 2285900  | 26.04           |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | USA           | Retail   | F3      | Retirees     | Families    | New           | 27155        | 1116307  | 41.11           |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | CANADA        | Shopify  | C2      | Middle Aged  | Couples     | Existing      | 410          | 77189    | 188.27          |
| 2018-09-03T00:00:00.000Z | 36          | 9            | 2018          | AFRICA        | Shopify  | unknown | unknown      | unknown     | Existing      | 219          | 43420    | 198.26          |

This temporary table will be used for the further analysis.

### 2. Data Exploration

#### 1. What day of the week is used for each week_date value?

```sql
SET
  search_path = data_mart;
SELECT
  EXTRACT(
    ISODOW
    FROM
      week_date
  ) AS day_of_week
FROM
  clean_weekly_sales
GROUP BY
  1
  ```
  
| day_of_week  |  
|--------------|
| 1            |  
  
***Each week starts from Monday in the `week_date` table***

#### 2. What range of week numbers are missing from the dataset?

We can get a range of the weeks that are in our table:

```sql
SET search_path = data_mart;
SELECT
  week_number
FROM
  clean_weekly_sales
GROUP BY
  1
ORDER BY
  1
  ```
| week_number    |
|----------------|
| 13             | 
| 14             |
| 15             |
| 16             |
| 17             |
| 18             |
| 19             |
| 20             |
| 21             |
| 22             |
| 23             |
| 24             |
| 25             |
| 26             |
| 27             |
| 28             |
| 29             |
| 30             |
| 31             |
| 32             |
| 33             |
| 34             |
| 35             |
| 36             |
  
We can also get the weeks that are out of our table.

First we need to generate all week numbers from 1 to 52. We can do that using the `generate_series()` function.

Next we can exclude the weeks from the table using the `NOT IN` statement:

```sql
SET
  search_path = data_mart;
WITH series as (
    SELECT
      GENERATE_SERIES(1, 52) as missing_weeks
    FROM
      clean_weekly_sales
  )
SELECT
  missing_weeks
FROM
  series
WHERE
  missing_weeks NOT IN(
    SELECT
      week_number
    FROM
      clean_weekly_sales
  )
GROUP BY
  1
ORDER BY
  1
  ```
  
| missing_weeks  |
|----------------|
| 1              | 
| 2              |
| 3              |
| 4              |
| 5              |
| 6              |
| 7              |
| 8              |
| 9              |
| 10             |
| 11             |
| 12             |
| 37             |
| 38             |
| 39             |
| 40             |
| 41             |
| 42             |
| 43             |
| 44             |
| 45             |
| 46             |
| 47             |
| 48             |
| 49             |
| 50             |
| 51             |
| 52             |
  
***Weeks 1 - 12 and 37 - 52 are missing from the dataset***

#### 3. How many total transactions were there for each year in the dataset?

We need to group all the transactions by years and count the total number of transaction using `SUM` function.

```sql
SET
  search_path = data_mart;
SELECT
  calendar_year,
  SUM(transactions) AS total_number_of_transactions
FROM
  clean_weekly_sales
GROUP BY
  1
ORDER BY
  1
  ```
  
| calendar_year | total_number_of_transactions  |
|---------------|-------------------------------|
| 2018          | 346406460                     |
| 2019          | 365639285                     |
| 2020          | 375813651                     |

The number of transcations is increasing year over year.

#### 4. What is the total sales for each region for each month?

```sql
SET
  search_path = data_mart;
SELECT
  region,
  month_number,
  SUM(sales) AS total_sales
FROM
  clean_weekly_sales
GROUP BY
  1,
  2
ORDER BY
  1,
  2
```

| region        | month_number | total_sales  |
|---------------|--------------|--------------|
| AFRICA        | 3            | 567767480    |
| AFRICA        | 4            | 1911783504   |
| AFRICA        | 5            | 1647244738   |
| AFRICA        | 6            | 1767559760   |
| AFRICA        | 7            | 1960219710   |
| AFRICA        | 8            | 1809596890   |
| AFRICA        | 9            | 276320987    |
| ASIA          | 3            | 529770793    |
| ASIA          | 4            | 1804628707   |
| ASIA          | 5            | 1526285399   |
| ASIA          | 6            | 1619482889   |
| ASIA          | 7            | 1768844756   |
| ASIA          | 8            | 1663320609   |
| ASIA          | 9            | 252836807    |
| CANADA        | 3            | 144634329    |
| CANADA        | 4            | 484552594    |
| CANADA        | 5            | 412378365    |
| CANADA        | 6            | 443846698    |
| CANADA        | 7            | 477134947    |
| CANADA        | 8            | 447073019    |
| CANADA        | 9            | 69067959     |
| EUROPE        | 3            | 35337093     |
| EUROPE        | 4            | 127334255    |
| EUROPE        | 5            | 109338389    |
| EUROPE        | 6            | 122813826    |
| EUROPE        | 7            | 136757466    |
| EUROPE        | 8            | 122102995    |
| EUROPE        | 9            | 18877433     |
| OCEANIA       | 3            | 783282888    |
| OCEANIA       | 4            | 2599767620   |
| OCEANIA       | 5            | 2215657304   |
| OCEANIA       | 6            | 2371884744   |
| OCEANIA       | 7            | 2563459400   |
| OCEANIA       | 8            | 2432313652   |
| OCEANIA       | 9            | 372465518    |
| SOUTH AMERICA | 3            | 71023109     |
| SOUTH AMERICA | 4            | 238451531    |
| SOUTH AMERICA | 5            | 201391809    |
| SOUTH AMERICA | 6            | 218247455    |
| SOUTH AMERICA | 7            | 235582776    |
| SOUTH AMERICA | 8            | 221166052    |
| SOUTH AMERICA | 9            | 34175583     |
| USA           | 3            | 225353043    |
| USA           | 4            | 759786323    |
| USA           | 5            | 655967121    |
| USA           | 6            | 703878990    |
| USA           | 7            | 760331754    |
| USA           | 8            | 712002790    |
| USA           | 9            | 110532368    |

Here is a visualisation for this query:

![index](https://user-images.githubusercontent.com/98699089/153630406-6e6f7495-8e89-42ac-b8f8-a6bfca2bba19.png)

We can see that Oceania generates the most of the sales, followed by Africa and Asia. 

#### 5. What is the total count of transactions for each platform?

```sql
SET
  search_path = data_mart;
SELECT
  platform,
  SUM(transactions) as total_transactions
FROM
  clean_weekly_sales
GROUP BY
  1
ORDER BY
  1
```
| platform | total_transactions  |
|----------|---------------------|
| Retail   | 1081934227          |
| Shopify  | 5925169             |

#### 6. What is the percentage of sales for Retail vs Shopify for each month?

I think this question presumes not only grouping by months but grouping by months and years. This kind of grouping allows us to see year over year trends. Let's check the share of retail and Shopify sales in the total sales volume. Since we have only two sales channels, we need to calculate the share of one channel, and the share of the other channel can be calculated as subtraction, 100 - share of the first channel. 

```sql
SET
  search_path = data_mart;
SELECT
  sr.month_number,
  sr.calendar_year,
  ROUND(100 *(SUM(sales) :: numeric / total_sales_s), 1) AS percentage_of_sales_retail,
  100 - ROUND(100 *(SUM(sales) :: numeric / total_sales_s), 1) AS percentage_of_sales_shopify
FROM
  clean_weekly_sales AS sr
  JOIN (
    SELECT
      ss.month_number,
      ss.calendar_year,
      SUM(sales) AS total_sales_s
    FROM
      clean_weekly_sales AS ss
    GROUP BY
      ss.month_number,
      ss.calendar_year
  ) ss ON sr.month_number = ss.month_number
  and ss.calendar_year = sr.calendar_year
WHERE
  sr.platform = 'Retail'
GROUP BY
  sr.month_number,
  sr.calendar_year,
  total_sales_s
ORDER BY
  2,
  1
```

| month_number | calendar_year | percentage_of_sales_retail | percentage_of_sales_shopify  |
|--------------|---------------|----------------------------|------------------------------|
| 3            | 2018          | 97.9                       | 2.1                          |
| 4            | 2018          | 97.9                       | 2.1                          |
| 5            | 2018          | 97.7                       | 2.3                          |
| 6            | 2018          | 97.8                       | 2.2                          |
| 7            | 2018          | 97.8                       | 2.2                          |
| 8            | 2018          | 97.7                       | 2.3                          |
| 9            | 2018          | 97.7                       | 2.3                          |
| 3            | 2019          | 97.7                       | 2.3                          |
| 4            | 2019          | 97.8                       | 2.2                          |
| 5            | 2019          | 97.5                       | 2.5                          |
| 6            | 2019          | 97.4                       | 2.6                          |
| 7            | 2019          | 97.4                       | 2.6                          |
| 8            | 2019          | 97.2                       | 2.8                          |
| 9            | 2019          | 97.1                       | 2.9                          |
| 3            | 2020          | 97.3                       | 2.7                          |
| 4            | 2020          | 97.0                       | 3.0                          |
| 5            | 2020          | 96.7                       | 3.3                          |
| 6            | 2020          | 96.8                       | 3.2                          |
| 7            | 2020          | 96.7                       | 3.3                          |
| 8            | 2020          | 96.5                       | 3.5                          |

Let's visualise this result: the line chart below shows the retail share. We can see that retail takes a significant share in the total sales but year over year this share is decreasing.

![index1](https://user-images.githubusercontent.com/98699089/153631481-7f60414e-3fcf-401f-a999-6995f0ac61b5.png)

#### 7. What is the percentage of sales by demographic for each year in the dataset?

```sql
SET
  search_path = data_mart;
SELECT
  s.calendar_year,
  demographic,
  ROUND(100 *(SUM(sales) :: numeric / total_sales), 1) AS percentage
FROM
  clean_weekly_sales AS s
  JOIN (
    SELECT
      cSUMalendar_year,
      SUM(sales) AS total_sales
    FROM
      clean_weekly_sales AS ts
    GROUP BY
      calendar_year
  ) ts ON s.calendar_year = ts.calendar_year
GROUP BY
  1,
  2,
  total_sales
ORDER BY
  1,
  2
```

| calendar_year | demographic | percentage  |
|---------------|-------------|-------------|
| 2018          | Couples     | 26.4        |
| 2018          | Families    | 32.0        |
| 2018          | unknown     | 41.6        |
| 2019          | Couples     | 27.3        |
| 2019          | Families    | 32.5        |
| 2019          | unknown     | 40.3        |
| 2020          | Couples     | 28.7        |
| 2020          | Families    | 32.7        |
| 2020          | unknown     | 38.6        |


#### 8. Which age_band and demographic values contribute the most to Retail sales?

```sql
SET
  search_path = data_mart;
SELECT
  age_band,
  demographic,
  SUM(sales) AS total_sales
FROM
  clean_weekly_sales
WHERE
  platform = 'Retail'
GROUP BY
  1,
  2
ORDER BY
  3 DESC,
  1,
  2
```

Let's visualize this query by age band and demographic:

![index2](https://user-images.githubusercontent.com/98699089/153636560-daad2faf-1615-42ac-b02d-204e651d6982.png) 
![index3](https://user-images.githubusercontent.com/98699089/153636549-e5cb3a6b-6674-4c10-a28b-438cd1c37171.png)

We can see that most of age band and demographic characteristics of our users are unknown. Among the others, Families and Retirees contribute in retail sales the most.

Now let's get amount of maximum sales for age band and for demographic, excluding unknown values. We will use the `row_number()` window function to get the maximum value:

```sql
SET
  search_path = data_mart;
SELECT
  age_band,
  total_sales
FROM
  (
    SELECT
      age_band,
      SUM(sales) AS total_sales,
      row_number() over (
        ORDER BY
          SUM(sales) DESC
      )
    FROM
      clean_weekly_sales
    WHERE
      platform = 'Retail'
      AND age_band != 'unknown'
    GROUP BY
      1
  ) ts
WHERE
  row_number = 1
```  
  
***Age band: Retirees - $13,005,266,930***

```sql
SET
  search_path = data_mart;
SELECT
  demographic,
  total_sales
FROM
  (
    SELECT
      demographic,
      SUM(sales) AS total_sales,
      row_number() over (
        ORDER BY
          SUM(sales) DESC
      )
    FROM
      clean_weekly_sales
    WHERE
      platform = 'Retail'
      AND demographic != 'unknown'
    GROUP BY
      1
  ) ts
WHERE
  row_number = 1
```

***Demographic: Families - $12,759,667,763***

And one more touch - let's check the age of the families from the previous query:

```sql
SET
  search_path = data_mart;
SELECT
  demographic, age_band,
  total_sales
FROM
  (
    SELECT
      demographic, age_band,
      SUM(sales) AS total_sales,
      row_number() over (
        ORDER BY
          SUM(sales) DESC
      )
    FROM
      clean_weekly_sales
    WHERE
      platform = 'Retail'
      AND demographic != 'unknown'
    GROUP BY
      1, 2
  ) ts
WHERE
  row_number = 1
```

***Demographic and Age Band: Retired families - $6,634,686,916***

We can conclude that the age group of retirees and the demographic group of families and the combined group of retired families contribute the most to retail sales.

#### 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

We can not use avg_transaction column to find the average transaction size per year and sales platform, because we need to aggregate it first. If we aggregate it as an average value the result will be incorrect. In other words, we can not use average of average to calculate the average. Here is the math behind this statement: [https://math.stackexchange.com/questions/95909/why-is-an-average-of-an-average-usually-incorrect/](why is an average of average usually incorrect)

To find the average transaction size we need to calculate the number of transcations per year and sales platform, then the total amount of transactions per year and sales platform. After that we can calculate the average transaction size by dividing the total number of transactions to the total amount of sales.

Here is a query and the result for the correct and incorrect calculation:

```sql
SET
  search_path = data_mart;
SELECT
  calendar_year,
  platform,
  ROUND(SUM(sales) :: numeric / SUM(transactions), 1) AS correct_avg,
  ROUND(AVG(avg_transaction), 1) AS incorrect_avg
FROM
  clean_weekly_sales
GROUP BY
  1,
  2
ORDER BY
  1,
  2
```

| calendar_year | platform | correct_avg | incorrect_avg  |
|---------------|----------|-------------|----------------|
| 2018          | Retail   | 36.6        | 42.9           |
| 2018          | Shopify  | 192.5       | 188.3          |
| 2019          | Retail   | 36.8        | 42.0           |
| 2019          | Shopify  | 183.4       | 177.6          |
| 2020          | Retail   | 36.6        | 40.6           |
| 2020          | Shopify  | 179.0       | 174.9          |

### 3. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the `week_date` value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
We would include all `week_date` values for 2020-06-15 as the start of the period after the change and the previous `week_date` values would be before.

Using this analysis approach - answer the following questions:

#### 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

Let's look the sales (absolute values) at the line chart below first:

```sql
SET
  search_path = data_mart;
SELECT
  week_number,
  SUM(sales) AS total_sales
FROM
  clean_weekly_sales
WHERE
calendar_year = 2020 AND
  week_number - 3 <= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
  AND week_number + 4 >= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
GROUP BY
  1
ORDER BY
  1
```

![New query (12)](https://user-images.githubusercontent.com/98699089/153697378-c0a35abf-7b99-424f-8746-0345a15b05c6.png)

We can see a sales drop on the week 25, and the date 2020-06-15 is on the week 25.

Let's calculate the total sales for the 4 weeks before and after this date.

We calculate sales for two periods in two CTEs, and then calculate absolute and percentage changes in sales.

The date 2020-06-15 is considered a base week, it is excluded from the 'before' period and included in the 'after' period.

```sql
SET
  search_path = data_mart;
WITH sales_before AS (
    SELECT
      SUM(sales) AS total_sales_before
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week - 4)
      AND (base_week - 1)
  ),
  sales_after AS (
    SELECT
      SUM(sales) AS total_sales_after
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week)
      AND (base_week + 3)
  )
SELECT
  total_sales_before,
  total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(
    100 * (total_sales_after - total_sales_before) :: numeric / total_sales_before,
    2
  ) AS percentage_of_change
FROM
  sales_before,
  sales_after
```

| total_sales_before | total_sales_after | change_in_sales | percentage_of_change  |
|--------------------|-------------------|-----------------|-----------------------|
| 2345878357         | 2318994169        | -26884188       | -1.15                 |

***Total sales for 4 weeks after week 25 decreased to 1.15% compared to 4 week sales before week 25***

#### 2. What about the entire 12 weeks before and after?

Let'start from visualisation of sales for the period 12 weeks before and after.

```sql
SET
  search_path = data_mart;
SELECT
  week_number,
  SUM(sales) AS total_sales
FROM
  clean_weekly_sales
WHERE
calendar_year = 2020 AND
  week_number - 11 <= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
  AND week_number + 12 >= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
GROUP BY
  1
ORDER BY
  1
  ```
  
  ![New query (13)](https://user-images.githubusercontent.com/98699089/153698469-00bc220a-5101-4fdb-b173-f4f016980e49.png)
  
We can see three sale drop peaks: week 17, week 25 and week 32. We also can see that the first week of sales, week 13, was the most successful in 2020. Sales trend is negative, sales are decreasing all over the period. Looking at this chart we can suppose that the changes on week 25 were one of the reasons for the yearly sales drop but not the only reason for that.

Let's calculate the total sales for the 12 weeks before and after 2020-06-15. The date 2020-06-15 is included in the 'after' period and excluded from 'before' period.

```sql
SET
  search_path = data_mart;
WITH sales_before AS (
    SELECT
      SUM(sales) AS total_sales_before
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)
  ),
  sales_after AS (
    SELECT
      SUM(sales) AS total_sales_after
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week)
      AND (base_week + 11)
  )
SELECT
  total_sales_before,
  total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(
    100 * (total_sales_after - total_sales_before) :: numeric / total_sales_before,
    2
  ) AS percentage_of_change
FROM
  sales_before,
  sales_after
```

| total_sales_before | total_sales_after | change_in_sales | percentage_of_change  |
|--------------------|-------------------|-----------------|-----------------------|
| 7126273147         | 6973947753        | -152325394      | -2.14                 |

***Total sales for 12 weeks after week 25 decreased to 2.14% compared to 12 week sales before week 25***


#### 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?


Check 4 weeks before and after week 25 for 2018, 2019 and 2020 years, changes in absolute values first:

```sql
SET
  search_path = data_mart;
SELECT
  calendar_year,
  week_number,
  SUM(sales) AS total_sales
FROM
  clean_weekly_sales
WHERE
  week_number - 3 <= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
  AND week_number + 4 >= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
GROUP BY
  1,
  2
ORDER BY
  1,
  2
```

![New query (14)](https://user-images.githubusercontent.com/98699089/153700974-e9c380e7-63a0-44e0-995d-86a484e6aadd.png)

The chart shows that sales are changing week over week every year. However the trendline in 2018 and 2019 is rising, and in 2020 the trend is falling.

Now let's check the period for 12 weeks before and after week 25:

```sql
SET
  search_path = data_mart;
SELECT
  calendar_year,
  week_number,
  SUM(sales) AS total_sales
FROM
  clean_weekly_sales
WHERE
  week_number - 11 <= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
  AND week_number + 12 >= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
GROUP BY
  1,
  2
ORDER BY
  1,
  2
```  
    
![New query (15)](https://user-images.githubusercontent.com/98699089/153701136-3a17b3ca-b821-479c-976f-d4db52201686.png)

12-weeks analysis shows a similar picture. Sales are volatile over the whole period.

Sales in 2018 tend to rise, in 2019 sales look like a plateau, and sales in 2020 are falling. Weeks 15, 17 and 32 in 2020 had less sales than the same weeks in 2019. Actually we can not say that the week 25 in 2020 was the worst one. 

However, the year 2020 shows the maximum absolute sales level comparing to 2018 and 2019. 
  
Now let's calculate the total sales for each year and two periods: 4 weeks before and after the date and 12 weeks before and after the date.

It will allow us to see if the packaging issue had a significant impact for sales.

Let's check 4 weeks before and after 2020-06-15:

```sql
SET
  search_path = data_mart;
WITH sales_before AS (
    SELECT
      calendar_year,
      SUM(sales) AS total_sales_before
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      week_number between (base_week - 4)
      AND (base_week - 1)
    group by
      1
  ),
  sales_after AS (
    SELECT
      calendar_year,
      SUM(sales) AS total_sales_after
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      week_number between (base_week)
      AND (base_week + 3)
    group by
      1
  )
SELECT
  sb.calendar_year,
  total_sales_before,
  total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(
    100 * (total_sales_after - total_sales_before) :: numeric / total_sales_before,
    2
  ) AS percentage_of_change
FROM
  sales_before AS sb
  JOIN sales_after AS sa ON sb.calendar_year = sa.calendar_year
group by
  1,
  2,
  3
```

| calendar_year | total_sales_before | total_sales_after | change_in_sales | percentage_of_change  |
|---------------|--------------------|-------------------|-----------------|-----------------------|
| 2018          | 2125140809         | 2129242914        | 4102105         | 0.19                  |
| 2019          | 2249989796         | 2252326390        | 2336594         | 0.10                  |
| 2020          | 2345878357         | 2318994169        | -26884188       | -1.15                 |

We can see that in 2018 and 2019 sales were growing after week 25, and the year 2020 shows drop in sales after week 25.

Now let's check 12 weeks before and after 2020-06-15:
  
| calendar_year | total_sales_before | total_sales_after | change_in_sales | percentage_of_change  |
|---------------|--------------------|-------------------|-----------------|-----------------------|
| 2018          | 6396562317         | 6500818510        | 104256193       | 1.63                  |
| 2019          | 6883386397         | 6862646103        | -20740294       | -0.30                 |
| 2020          | 7126273147         | 6973947753        | -152325394      | -2.14                 |

We can see sales growth in 2018, and sales reduction in 2019 and 2020. However, the reduction is clearly more marked in 2020.


### 4. Bonus Question

Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

Let's start from the absolute values first and the compare performance for the 12 week before and after period.

- **region:**

```sql
SET
  search_path = data_mart;
SELECT
  region,
  week_number,
  SUM(sales) AS total_sales
FROM
  clean_weekly_sales
WHERE
  calendar_year = 2020
  AND week_number - 11 <= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
  AND week_number + 12 >= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
GROUP BY
  1,
  2
ORDER BY
  2,
  1
```

![New query (16)](https://user-images.githubusercontent.com/98699089/153703749-325eafdc-122f-48db-a410-9a5298ac35c8.png)

Africa and USA showed drop in sales on the week 17, and Oceania - on the week 25.

Let's check the total sales for 12 weeks before and after 2020-06-15 by region:

```sql
SET
  search_path = data_mart;
WITH sales_before AS (
    SELECT
      region,
      SUM(sales) AS total_sales_before
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)
    GROUP BY
      1
  ),
  sales_after AS (
    SELECT
      region,
      SUM(sales) AS total_sales_after
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week)
      AND (base_week + 11)
   GROUP BY
      1
  )
SELECT
  sb.region,
  total_sales_before,
  total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(
    100 * (total_sales_after - total_sales_before) :: numeric / total_sales_before,
    2
  ) AS percentage_of_change
FROM
  sales_before AS sb
  JOIN sales_after AS sa ON sb.region = sa.region
GROUP BY
  1,
  2,
  3,
  4
ORDER BY
  5
```

| region        | total_sales_before | total_sales_after | change_in_sales | percentage_of_change  |
|---------------|--------------------|-------------------|-----------------|-----------------------|
| ASIA          | 1637244466         | 1583807621        | -53436845       | -3.26                 |
| OCEANIA       | 2354116790         | 2282795690        | -71321100       | -3.03                 |
| SOUTH AMERICA | 213036207          | 208452033         | -4584174        | -2.15                 |
| CANADA        | 426438454          | 418264441         | -8174013        | -1.92                 |
| USA           | 677013558          | 666198715         | -10814843       | -1.60                 |
| AFRICA        | 1709537105         | 1700390294        | -9146811        | -0.54                 |
| EUROPE        | 108886567          | 114038959         | 5152392         | 4.73                  |

Before and after analysis shows that sales drop 3.26% in Asia and $71,321,100 in Oceania had the highest negative impact in sales metrics performance in 2020.


- **platform:**

```sql
SET
  search_path = data_mart;
SELECT
  platform,
  week_number,
  SUM(sales) AS total_sales
FROM
  clean_weekly_sales
WHERE
  calendar_year = 2020
  AND week_number - 11 <= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
  AND week_number + 12 >= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
GROUP BY
  1,
  2
ORDER BY
  2,
  1
```

![New query (17)](https://user-images.githubusercontent.com/98699089/153703877-bf7c784c-7a36-478b-a6b7-a8d58b7aef2e.png)

We can see sale drops on Retail platform on the weeks 15, 17, 25 and 32. 

```sql
SET
  search_path = data_mart;
WITH sales_before AS (
    SELECT
      platform,
      SUM(sales) AS total_sales_before
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)
    GROUP BY
      1
  ),
  sales_after AS (
    SELECT
      platform,
      SUM(sales) AS total_sales_after
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week)
      AND (base_week + 11)
    GROUP BY
      1
  )
SELECT
  sb.platform,
  total_sales_before,
  total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(
    100 * (total_sales_after - total_sales_before) :: numeric / total_sales_before,
    2
  ) AS percentage_of_change
FROM
  sales_before AS sb
  JOIN sales_after AS sa ON sb.platform = sa.platform
GROUP BY
  1,
  2,
  3,
  4
ORDER BY
  5
```

| platform | total_sales_before | total_sales_after | change_in_sales | percentage_of_change  |
|----------|--------------------|-------------------|-----------------|-----------------------|
| Retail   | 6906861113         | 6738777279        | -168083834      | -2.43                 |
| Shopify  | 219412034          | 235170474         | 15758440        | 7.18                  |

Sales drop in Retail had the highest negative impact in sales metrics performance in 2020. And we can see that the Shopify platform showed 7.18% growth. However, the growth of the Shopify platform did not compensate for the drop in Retail platform.

- **age_band:**

```sql
SET
  search_path = data_mart;
SELECT
  age_band,
  week_number,
  SUM(sales) AS total_sales
FROM
  clean_weekly_sales
WHERE
  calendar_year = 2020
  AND week_number - 11 <= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
  AND week_number + 12 >= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
GROUP BY
  1,
  2
ORDER BY
  2,
  1
```

![New query (18)](https://user-images.githubusercontent.com/98699089/153703951-018c16d6-51bc-4d73-ba8b-8fc4a3d836c6.png)

There is sale drop in the 'unknown' age group on the weeks 17, 25 and 32, and in the Retirees age group on the weeks 15 and 17.

```sql
SET
  search_path = data_mart;
WITH sales_before AS (
    SELECT
      age_band,
      SUM(sales) AS total_sales_before
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)
    GROUP BY
      1
  ),
  sales_after AS (
    SELECT
      age_band,
      SUM(sales) AS total_sales_after
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week)
      AND (base_week + 11)
   GROUP BY
      1
  )
SELECT
  sb.age_band,
  total_sales_before,
  total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(
    100 * (total_sales_after - total_sales_before) :: numeric / total_sales_before,
    2
  ) AS percentage_of_change
FROM
  sales_before AS sb
  JOIN sales_after AS sa ON sb.age_band = sa.age_band
GROUP BY
  1,
  2,
  3,
  4
ORDER BY
  5
```

| age_band     | total_sales_before | total_sales_after | change_in_sales | percentage_of_change  |
|--------------|--------------------|-------------------|-----------------|-----------------------|
| unknown      | 2764354464         | 2671961443        | -92393021       | -3.34                 |
| Middle Aged  | 1164847640         | 1141853348        | -22994292       | -1.97                 |
| Retirees     | 2395264515         | 2365714994        | -29549521       | -1.23                 |
| Young Adults | 801806528          | 794417968         | -7388560        | -0.92                 |

Before and after analysis shows that sales drop 3.34% in unknown age group had the highest negative impact in sales metrics performance in 2020.

- **demographic**

```sql
SET
  search_path = data_mart;
SELECT
  demographic,
  week_number,
  SUM(sales) AS total_sales
FROM
  clean_weekly_sales
WHERE
  calendar_year = 2020
  AND week_number - 11 <= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
  AND week_number + 12 >= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
GROUP BY
  1,
  2
ORDER BY
  2,
  1
```

![New query (19)](https://user-images.githubusercontent.com/98699089/153704066-75fb742e-21a1-49dd-9f2e-c762f37eb5eb.png)

All three demographic groups: 'unknown', Families and Couples showed sales drop on the weeks 17 and 32. Couples and Families also showed a drop on the week 15, and the 'unknown' group - on the week 25.

```sql
SET
  search_path = data_mart;
WITH sales_before AS (
    SELECT
      demographic,
      SUM(sales) AS total_sales_before
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)
    GROUP BY
      1
  ),
  sales_after AS (
    SELECT
      demographic,
      SUM(sales) AS total_sales_after
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week)
      AND (base_week + 11)
   GROUP BY
      1
  )
SELECT
  sb.demographic,
  total_sales_before,
  total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(
    100 * (total_sales_after - total_sales_before) :: numeric / total_sales_before,
    2
  ) AS percentage_of_change
FROM
  sales_before AS sb
  JOIN sales_after AS sa ON sb.demographic = sa.demographic
GROUP BY
  1,
  2,
  3,
  4
ORDER BY
  5
```

| age_band    | total_sales_before | total_sales_after | change_in_sales | percentage_of_change  |
|-------------|--------------------|-------------------|-----------------|-----------------------|
| unknown     | 2764354464         | 2671961443        | -92393021       | -3.34                 |
| Families    | 2328329040         | 2286009025        | -42320015       | -1.82                 |
| Couples     | 2033589643         | 2015977285        | -17612358       | -0.87                 |

Sales drop 3.34% in unknown demographic group had the highest negative impact in sales metrics performance in 2020.

- **customer_type:**

```sql
SET
  search_path = data_mart;
SELECT
  customer_type,
  week_number,
  SUM(sales) AS total_sales
FROM
  clean_weekly_sales
WHERE
  calendar_year = 2020
  AND week_number - 11 <= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
  AND week_number + 12 >= EXTRACT(
    WEEK
    FROM
      '2020-06-15' :: date
  )
GROUP BY
  1,
  2
ORDER BY
  2,
  1
```

![New query (20)](https://user-images.githubusercontent.com/98699089/153704680-84f658d3-022d-48af-a8d3-351935412056.png)

We can see that Guests and Existing customers had a sales drop on the weeks 17 and 32, and guest customers also showed sales drop on the week 25.

```sql
SET
  search_path = data_mart;
WITH sales_before AS (
    SELECT
      customer_type,
      SUM(sales) AS total_sales_before
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)
    GROUP BY
      1
  ),
  sales_after AS (
    SELECT
      customer_type,
      SUM(sales) AS total_sales_after
    FROM
      clean_weekly_sales,
      LATERAL(
        SELECT
          EXTRACT(
            WEEK
            FROM
              '2020-06-15' :: date
          ) AS base_week
      ) bw
    WHERE
      calendar_year = 2020
      AND week_number between (base_week)
      AND (base_week + 11)
   GROUP BY
      1
  )
SELECT
  sb.customer_type,
  total_sales_before,
  total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(
    100 * (total_sales_after - total_sales_before) :: numeric / total_sales_before,
    2
  ) AS percentage_of_change
FROM
  sales_before AS sb
  JOIN sales_after AS sa ON sb.customer_type = sa.customer_type
GROUP BY
  1,
  2,
  3,
  4
ORDER BY
  5
```

| customer_type | total_sales_before | total_sales_after | change_in_sales | percentage_of_change  |
|---------------|--------------------|-------------------|-----------------|-----------------------|
| Guest         | 2573436301         | 2496233635        | -77202666       | -3.00                 |
| Existing      | 3690116427         | 3606243454        | -83872973       | -2.27                 |
| New           | 862720419          | 871470664         | 8750245         | 1.01                  |


Sales drop 3% in the guest customer group had the highest negative impact in sales metrics performance in 2020.

We can conclude that these areas of business had the highest negative impact in sales metrics performance in 2020: sales in Asia and Oceania, retail platform, unknown age and demographic group and guest customers.

In general, packaging issues had a negative sales impact but it was not the only reason for decreasing sales in 2020. 

### Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

Retail sales is the biggest channel and the retired customers is the biggest group of customers. It is important to keep their loyality and try to meet their expectations. 

Shopify sales channel is increasing its share year over year and developing of this channel might be profitable from the future prospective. 

The analysis shows that the loyal customers (existing customers and guest customers) generate the most sales. The sales trend is slopping down. Focusing on new customer acquisition and retention could be another growth point for the company. Middle aged adults is the most lucrative age group to appeal to. They show their interest in the company products and there is a room for further market penetration.
