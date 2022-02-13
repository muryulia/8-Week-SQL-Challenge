-- Solved on PostgreSQL 13.4 by Yulia Murtazina, January 25, 2022
-- Fixed on February 13, 2022


-- Case Study #5 - Data Mart


SET
  search_path = data_mart;

/* --------------------
Case Study Questions

1. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the `data_mart` schema named `clean_weekly_sales`:

- Convert the `week_date` to a `DATE` format
- Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a `month_number` with the calendar month for each week_date value as the 3rd column
- Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called `age_band` after the original segment column using the following mapping on the number inside the segment value
- Add a new `demographic` column using the following mapping for the first letter in the segment values
- Ensure all `null` string values with an "unknown" string value in the original segment column as well as the new `age_band` and `demographic` columns
- Generate a new `avg_transaction` column as the sales value divided by transactions rounded to 2 decimal places for each record
--------------------*/

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
  calendar_year;

/* --------------------
2. Data Exploration

1. What day of the week is used for each week_date value?
   --------------------*/

SELECT
  EXTRACT(
    ISODOW
    FROM
      week_date
  ) AS day_of_week
FROM
  clean_weekly_sales
GROUP BY
  1;

-- 2. What range of week numbers are missing from the dataset?

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
  1;

-- 3. How many total transactions were there for each year in the dataset?

SELECT
  calendar_year,
  SUM(transactions) AS total_number_of_transactions
FROM
  clean_weekly_sales
GROUP BY
  1
ORDER BY
  1;

-- 4. What is the total sales for each region for each month?

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
  2;

-- 5. What is the total count of transactions for each platform?

SELECT
  platform,
  SUM(transactions) as total_transactions
FROM
  clean_weekly_sales
GROUP BY
  1
ORDER BY
  1;

-- 6. What is the percentage of sales for Retail vs Shopify for each month?

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
  1;

-- 7. What is the percentage of sales by demographic for each year in the dataset?

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
  2;

-- 8. Which age_band and demographic values contribute the most to Retail sales?

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
  2;

SELECT
  age_band,
  total_sales,
  percentage_of_sales
FROM
  (
    SELECT
      age_band,
      SUM(sales) AS total_sales,
      round(100 * (SUM(sales) :: numeric / all_sales), 1) AS percentage_of_sales,
      row_number() over (
        ORDER BY
          SUM(sales) DESC
      )
    FROM
      clean_weekly_sales,
      LATERAL (
        SELECT
          SUM(sales) AS all_sales
        FROM
          clean_weekly_sales
      ) s
    WHERE
      platform = 'Retail'
      AND demographic != 'unknown'
    GROUP BY
      1,
      all_sales
  ) ts
WHERE
  row_number = 1;

SELECT
  demographic,
  total_sales,
  percentage_of_sales
FROM
  (
    SELECT
      demographic,
      SUM(sales) AS total_sales,
      round(100 * (SUM(sales) :: numeric / all_sales), 1) AS percentage_of_sales,
      row_number() over (
        ORDER BY
          SUM(sales) DESC
      )
    FROM
      clean_weekly_sales,
      LATERAL (
        SELECT
          SUM(sales) AS all_sales
        FROM
          clean_weekly_sales
      ) s
    WHERE
      platform = 'Retail'
      AND demographic != 'unknown'
    GROUP BY
      1,
      all_sales
  ) ts
WHERE
  row_number = 1;

SELECT
  demographic,
  age_band,
  total_sales,
  percentage_of_sales
FROM
  (
    SELECT
      demographic,
      age_band,
      SUM(sales) AS total_sales,
      round(100 * (SUM(sales) :: numeric / all_sales), 1) AS percentage_of_sales,
      row_number() over (
        ORDER BY
          SUM(sales) DESC
      )
    FROM
      clean_weekly_sales,
      LATERAL (
        SELECT
          SUM(sales) AS all_sales
        FROM
          clean_weekly_sales
      ) s
    WHERE
      platform = 'Retail'
      AND demographic != 'unknown'
    GROUP BY
      1,
      2,
      all_sales
  ) ts
WHERE
  row_number = 1;

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

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
  2;

/* --------------------
3. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the `week_date` value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
We would include all `week_date` values for 2020-06-15 as the start of the period after the change and the previous `week_date` values would be before.

Using this analysis approach - answer the following questions:

1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
   --------------------*/

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
  sales_after;

-- 2. What about the entire 12 weeks before and after?

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
  sales_after;

-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

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
  3;

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
      week_number between (base_week - 12)
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
      AND (base_week + 11)
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
  3;

/* --------------------
4. Bonus Question

Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
   --------------------*/

-- region:

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
  5;

-- platform:

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
  5;

-- age_band:

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
  5;

-- demographic:

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
  5;

-- customer_type:

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
  5;
