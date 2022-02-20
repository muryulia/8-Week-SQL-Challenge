-- Solved on PostgreSQL 13.4 by Yulia Murtazina, January 30, 2022
-- Fixed on February 19, 2022

-- Case Study #8 - Fresh Segments

SET
  SEARCH_PATH = fresh_segments;

/* --------------------
Data Exploration and Cleansing
1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
   --------------------*/

ALTER TABLE
  interest_metrics
ALTER COLUMN
  month_year TYPE DATE USING TO_DATE(month_year, 'MM-YYYY');

-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

SELECT
  DATE_TRUNC('month', month_year) AS date,
  COUNT(*) AS number_of_records
FROM
  interest_metrics
GROUP BY
  month_year
ORDER BY
  month_year NULLS FIRST;

-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics?
-- Non-coding question

-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?

SELECT
  COUNT(distinct interest_id) AS interest_id
FROM
  interest_metrics
WHERE
  interest_id :: int NOT IN (
    SELECT
      id
    FROM
      interest_map
  );

SELECT
  COUNT(id) AS interest_id
FROM
  interest_map
WHERE
  id NOT IN (
    SELECT
      distinct interest_id :: int
    FROM
      interest_metrics
    WHERE
      interest_id IS NOT NULL
  );

-- 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table

SELECT
  COUNT(distinct id) AS total_count
FROM
  interest_map AS m;

-- 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column

SELECT
  distinct interest_id :: int,
  interest_name,
  interest_summary,
  created_at,
  last_modified,
  _month,
  _year,
  month_year,
  composition,
  index_value,
  ranking,
  percentile_ranking
FROM
  interest_map AS m
  LEFT JOIN interest_metrics AS im ON m.id = im.interest_id :: int
WHERE
  interest_id = '21246'
GROUP BY
  interest_name,
  id,
  interest_summary,
  created_at,
  last_modified,
  _month,
  _year,
  month_year,
  interest_id,
  composition,
  index_value,
  ranking,
  percentile_ranking
ORDER BY
  _month NULLS FIRST;

-- 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

WITH joined_table AS (
    SELECT
      distinct interest_id :: int,
      interest_name,
      interest_summary,
      created_at,
      last_modified,
      _month,
      _year,
      month_year,
      composition,
      index_value,
      ranking,
      percentile_ranking
    FROM
      interest_map AS m
      LEFT JOIN interest_metrics AS im ON m.id = im.interest_id :: int
    GROUP BY
      interest_name,
      id,
      interest_summary,
      created_at,
      last_modified,
      _month,
      _year,
      month_year,
      interest_id,
      composition,
      index_value,
      ranking,
      percentile_ranking
  )
SELECT
  COUNT(*)
FROM
  joined_table
WHERE
  created_at > month_year
ORDER BY
  1;

/* --------------------
Interest Analysis
1. Which interests have been present in all month_year dates in our dataset?
   --------------------*/

WITH interests AS (
    SELECT
      id,
      interest_name
    FROM
      interest_map AS m
      LEFT JOIN interest_metrics AS im ON m.id = im.interest_id :: int
    GROUP BY
      1,
      2
    HAVING
      COUNT(interest_id) = 14
  )
SELECT
  interest_name
FROM
  interests
ORDER BY
  1;

-- 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?

WITH counted_months AS (
    SELECT
      interest_id,
      COUNT(interest_id) total_months,
      ROW_NUMBER() OVER(
        PARTITION BY COUNT(interest_id)
        ORDER BY
          COUNT(interest_id)
      ) AS rank
    FROM
      interest_metrics AS im
    GROUP BY
      1
    HAVING
      COUNT(interest_id) > 0
  )
SELECT
  total_months,
  MAX(rank) AS number_of_interests,
  CAST(
    100 * SUM(MAX(rank)) OVER (
      ORDER BY
        total_months
    ) / SUM(MAX(rank)) OVER () AS numeric(10, 2)
  ) cum_top,
  CAST(
    100 - 100 * SUM(MAX(rank)) OVER (
      ORDER BY
        total_months
    ) / SUM(MAX(rank)) OVER () AS numeric(10, 2)
  ) cum_top_reversed
FROM
  counted_months
GROUP BY
  total_months
ORDER BY
  1;

-- 3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?

WITH interests AS (
    SELECT
      interest_id
    FROM
      interest_metrics AS im
    GROUP BY
      1
    HAVING
      COUNT(interest_id) < 6
  )
SELECT
  COUNT(interest_id) AS number_of_interests
FROM
  interests
ORDER BY
  1;

-- 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.

SELECT
  im.month_year,
  COUNT(interest_id) AS number_of_excluded_interests,
  number_of_included_interests,
  ROUND(
    100 *(
      COUNT(interest_id) / number_of_included_interests :: numeric
    ),
    1
  ) AS percent_of_excluded
FROM
  interest_metrics AS im
  JOIN (
    SELECT
      month_year,
      COUNT(interest_id) AS number_of_included_interests
    FROM
      interest_metrics AS im
    WHERE
      month_year IS NOT NULL
      AND interest_id :: int IN (
        SELECT
          interest_id :: int
        FROM
          interest_metrics
        GROUP BY
          1
        HAVING
          COUNT(interest_id) > 5
      )
    GROUP BY
      1
  ) i ON im.month_year = i.month_year
WHERE
  im.month_year IS NOT NULL
  AND interest_id :: int IN (
    SELECT
      interest_id :: int
    FROM
      interest_metrics
    GROUP BY
      1
    having
      COUNT(interest_id) < 6
  )
GROUP BY
  1,
  3
ORDER BY
  1;

-- 5. After removing these interests - how many unique interests are there for each month?

SELECT
  month_year,
  COUNT(interest_id) AS number_of_interests
FROM
  interest_metrics AS im
WHERE
  month_year IS NOT NULL
  AND interest_id :: int IN (
    SELECT
      interest_id :: int
    FROM
      interest_metrics
    GROUP BY
      1
    HAVING
      COUNT(interest_id) > 5
  )
GROUP BY
  1
ORDER BY
  1;

/* --------------------
Segment Analysis
1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year
   --------------------*/

SELECT
  interests.month_year,
  interests.interest_name,
  interests.composition,
  i_max_new.composition AS max_composition,
  i_max_new.month_year AS max_composition_month
FROM
  (
    (
      WITH max_interests AS (
        SELECT
          month_year,
          interest_name,
          composition,
          RANK() OVER (
            PARTITION BY interest_name
            ORDER BY
              composition DESC
          ) AS max_rank
        FROM
          interest_metrics AS im
          JOIN interest_map AS m ON m.id = im.interest_id :: int
        WHERE
          month_year IS NOT NULL
          AND interest_id :: int in (
            SELECT
              interest_id :: int
            FROM
              interest_metrics
            GROUP BY
              1
            HAVING
              COUNT(interest_id) > 5
          )
        GROUP BY
          1,
          2,
          3
      )
      SELECT
        month_year,
        interest_name,
        composition
      FROM
        max_interests
      WHERE
        max_rank = 1
      GROUP BY
        1,
        2,
        3
      ORDER BY
        3 DESC
      LIMIT
        10
    )
    UNION
      (
        WITH min_interests AS (
          SELECT
            month_year,
            interest_name,
            composition,
            RANK() OVER (
              PARTITION BY interest_name
              ORDER BY
                composition
            ) AS min_rank
          FROM
            interest_metrics AS im
            JOIN interest_map AS m ON m.id = im.interest_id :: int
          WHERE
            month_year IS NOT NULL
            AND interest_id :: int in (
              SELECT
                interest_id :: int
              FROM
                interest_metrics
              GROUP BY
                1
              HAVING
                COUNT(interest_id) > 5
            )
          GROUP BY
            1,
            2,
            3
        )
        SELECT
          month_year,
          interest_name,
          composition
        FROM
          min_interests
        WHERE
          min_rank = 1
        GROUP BY
          1,
          2,
          3
        ORDER BY
          3
        LIMIT
          10
      )
  ) AS interests
  JOIN (
    WITH max_interests AS (
      SELECT
        month_year,
        interest_name,
        composition,
        RANK() OVER (
          PARTITION BY interest_name
          ORDER BY
            composition DESC
        ) AS max_rank
      FROM
        interest_metrics AS im
        JOIN interest_map AS m ON m.id = im.interest_id :: int
      WHERE
        month_year IS NOT NULL
        AND interest_id :: int in (
          SELECT
            interest_id :: int
          FROM
            interest_metrics
          GROUP BY
            1
          HAVING
            COUNT(interest_id) > 5
        )
      GROUP BY
        1,
        2,
        3
    )
    SELECT
      month_year,
      interest_name,
      composition
    FROM
      max_interests
    WHERE
      max_rank = 1
    GROUP BY
      1,
      2,
      3
    ORDER BY
      3 DESC
  ) i_max_new on interests.interest_name = i_max_new.interest_name
ORDER BY
  3 DESC;

-- 2. Which 5 interests had the lowest average ranking value?

WITH ranking AS (
    SELECT
      interest_name,
      AVG(ranking) :: numeric(10, 2) AS avg_ranking,
      RANK() OVER (
        ORDER BY
          AVG(ranking) DESC
      ) AS rank
    FROM
      interest_metrics AS im
      JOIN interest_map AS m ON m.id = im.interest_id :: int
    WHERE
      month_year IS NOT NULL
      AND interest_id :: int IN (
        SELECT
          interest_id :: int
        FROM
          interest_metrics
        GROUP BY
          1
        HAVING
          COUNT(interest_id) > 5
      )
    GROUP BY
      1
  )
SELECT
  interest_name,
  avg_ranking
FROM
  ranking
WHERE
  rank between 0
  AND 5;

-- 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

WITH ranking AS (
    SELECT
      id,
      interest_name,
      STDDEV(percentile_ranking) :: numeric(10, 2) AS standard_deviation,
      RANK() OVER (
        ORDER BY
          STDDEV(percentile_ranking) DESC
      ) AS rank
    FROM
      interest_metrics AS im
      JOIN interest_map AS m ON m.id = im.interest_id :: int
    WHERE
      month_year IS NOT NULL
      AND interest_id :: int IN (
        SELECT
          interest_id :: int
        FROM
          interest_metrics
        GROUP BY
          1
        having
          count(interest_id) > 5
      )
    GROUP BY
      1,
      2
  )
SELECT
  interest_name,
  standard_deviation
FROM
  ranking
WHERE
  rank between 0
  AND 5;

-- 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?

WITH ranking AS (
    SELECT
      month_year,
      id,
      interest_name,
      percentile_ranking,
      RANK() OVER (
        PARTITION BY id
        ORDER BY
          percentile_ranking
      ) AS min_rank,
      RANK() OVER (
        PARTITION BY id
        ORDER BY
          percentile_ranking DESC
      ) AS max_rank
    FROM
      interest_metrics AS im
      JOIN interest_map AS m ON m.id = im.interest_id :: int
    WHERE
      month_year IS NOT NULL
      AND interest_id :: int IN (
        SELECT
          interest_id :: int
        FROM
          interest_metrics
        GROUP BY
          1
        HAVING
          COUNT(interest_id) > 5
      )
      AND id IN (
        WITH ranking AS (
          SELECT
            id,
            interest_name,
            STDDEV(percentile_ranking) :: numeric(10, 2) AS standard_deviation,
            RANK() OVER (
              ORDER BY
                STDDEV(percentile_ranking) DESC
            ) AS rank
          FROM
            interest_metrics AS im
            JOIN interest_map AS m ON m.id = im.interest_id :: int
          WHERE
            month_year IS NOT NULL
            AND interest_id :: int IN (
              SELECT
                interest_id :: int
              FROM
                interest_metrics
              GROUP BY
                1
              having
                count(interest_id) > 5
            )
          GROUP BY
            1,
            2
        )
        SELECT
          id
        FROM
          ranking
        WHERE
          rank between 0
          AND 5
      )
    GROUP BY
      1,
      2,
      3,
      4
  )
SELECT
  month_year,
  interest_name,
  percentile_ranking
FROM
  ranking
WHERE
  min_rank = 1
  or max_rank = 1
GROUP BY
  1,
  2,
  3
ORDER BY
  2,
  3 DESC;

-- 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?
-- Non-coding question

/* --------------------
Index Analysis
The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.
Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.
1. What is the top 10 interests by the average composition for each month?
   --------------------*/

WITH ranking AS (
    SELECT
      month_year,
      id,
      interest_name,
      avg_composition,
      RANK() OVER (
        PARTITION BY month_year
        ORDER BY
          avg_composition DESC
      ) AS max_rank
    FROM
      interest_metrics AS im
      JOIN interest_map AS m ON m.id = im.interest_id :: int,
      LATERAL(
        SELECT
          (composition / index_value) :: numeric(10, 2) AS avg_composition
      ) ac
    WHERE
      month_year IS NOT NULL
      AND interest_id :: int IN (
        SELECT
          interest_id :: int
        FROM
          interest_metrics
        GROUP BY
          1
        HAVING
          COUNT(interest_id) > 5
      )
    GROUP BY
      1,
      2,
      3,
      4
  )
SELECT
  month_year,
  interest_name,
  avg_composition
FROM
  ranking
WHERE
  max_rank between 1
  AND 10
ORDER BY
  1,
  3 DESC;

-- 2. For all of these top 10 interests - which interest appears the most often?

WITH ranking AS (
    SELECT
      month_year,
      id,
      interest_name,
      avg_composition,
      RANK() OVER (
        PARTITION BY month_year
        ORDER BY
          avg_composition DESC
      ) AS max_rank
    FROM
      interest_metrics AS im
      JOIN interest_map AS m on m.id = im.interest_id :: int,
      LATERAL(
        SELECT
          (composition / index_value) :: numeric(10, 2) AS avg_composition
      ) ac
    WHERE
      month_year IS NOT NULL
      AND interest_id :: int IN (
        SELECT
          interest_id :: int
        FROM
          interest_metrics
        GROUP BY
          1
        HAVING
          COUNT(interest_id) > 5
      )
    GROUP BY
      1,
      2,
      3,
      4
  )
SELECT
  interest_name,
  COUNT(interest_name) AS months_in_top_1
FROM
  ranking
WHERE
  max_rank = 1
GROUP BY
  1
ORDER BY
  2 DESC;

-- 3. What is the average of the average composition for the top 10 interests for each month?

SELECT
  month_year,
  AVG(avg_composition) :: numeric(10, 2) AS average_rating
FROM
  (
    WITH ranking AS (
      SELECT
        month_year,
        id,
        interest_name,
        avg_composition,
        RANK() OVER (
          PARTITION BY month_year
          ORDER BY
            avg_composition DESC
        ) AS max_rank
      FROM
        interest_metrics AS im
        JOIN interest_map AS m ON m.id = im.interest_id :: int,
        LATERAL(
          SELECT
            (composition / index_value) :: numeric(10, 2) AS avg_composition
        ) ac
      WHERE
        month_year IS NOT NULL
        AND interest_id :: int IN (
          SELECT
            interest_id :: int
          FROM
            interest_metrics
          GROUP BY
            1
          HAVING
            COUNT(interest_id) > 5
        )
      GROUP BY
        1,
        2,
        3,
        4
    )
    SELECT
      month_year,
      interest_name,
      avg_composition
    FROM
      ranking
    WHERE
      max_rank between 1
      AND 10
  ) r
GROUP BY
  1
ORDER BY
  1;

-- 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below

SELECT
  *
FROM
  (
    WITH ranking AS (
      SELECT
        month_year,
        id,
        interest_name,
        avg_composition,
        RANK() OVER (
          PARTITION BY month_year
          ORDER BY
            avg_composition DESC
        ) AS max_rank
      FROM
        interest_metrics AS im
        JOIN interest_map AS m ON m.id = im.interest_id :: int,
        LATERAL(
          SELECT
            (composition / index_value) :: numeric(10, 2) AS avg_composition
        ) ac
      WHERE
        month_year IS NOT NULL
        AND interest_id :: int IN (
          SELECT
            interest_id :: int
          FROM
            interest_metrics
          GROUP BY
            1
          HAVING
            COUNT(interest_id) > 5
        )
      GROUP BY
        1,
        2,
        3,
        4
    )
    SELECT
      month_year,
      interest_name,
      avg_composition AS max_index_composition,
      (
        AVG(avg_composition) OVER(
          ORDER BY
            month_year ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW
        )
      ) :: numeric(10, 2) AS _3_month_moving_avg,
      CONCAT(
        LAG(interest_name) OVER (
          ORDER BY
            month_year
        ),
        ': ',
        LAG(avg_composition) OVER (
          ORDER BY
            month_year
        )
      ) AS _1_month_ago,
      CONCAT(
        LAG(interest_name, 2) OVER (
          ORDER BY
            month_year
        ),
        ': ',
        LAG(avg_composition, 2) OVER (
          ORDER BY
            month_year
        )
      ) AS _2_month_ago
    FROM
      ranking
    WHERE
      max_rank = 1
  ) r
WHERE
  month_year > '2018-08-01'
ORDER BY
  1;

-- 5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?
-- Non-coding question
