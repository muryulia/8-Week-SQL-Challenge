# Case Study #8 - Fresh Segments :diamond_shape_with_a_dot_inside:

## Introduction

Danny created Fresh Segments, a digital marketing agency that helps other businesses analyse trends in online ad click behaviour for their unique customer base.
Clients share their customer lists with the Fresh Segments team who then aggregate interest metrics and generate a single dataset worth of metrics for further analysis.

In particular - the composition and rankings for different interests are provided for each client showing the proportion of their customer list who interacted with online assets related to each interest for each month.

Danny has asked for your assistance to analyse aggregated metrics for an example client and provide some high level insights about the customer list and their interests.

Full description: [Case Study #8 - Fresh Segments](https://8weeksqlchallenge.com/case-study-8/)

## Case Study Questions

The following questions can be considered key business questions that are required to be answered for the Fresh Segments team.
Most questions can be answered using a single query however some questions are more open ended and require additional thought and not just a coded solution!

### Data Exploration and Cleansing

#### 1. Update the `fresh_segments.interest_metrics` table by modifying the `month_year` column to be a date data type with the start of the month

```sql
SET
  SEARCH_PATH = fresh_segments;
ALTER TABLE
  interest_metrics
ALTER COLUMN
  month_year TYPE DATE USING TO_DATE(month_year, 'MM-YYYY')
```

Data type in the `month_year` column has changed to the date data type.

#### 2. What is count of records in the `fresh_segments.interest_metrics` for each `month_year` value sorted in chronological order (earliest to latest) with the null values appearing first?

We need to group the number of records in the `interest_metrics` table by months. We can extract month using the `date_trunc()` function.

```sql
SET
  SEARCH_PATH = fresh_segments;
SELECT
  DATE_TRUNC('month', month_year) AS date,
  COUNT(*) AS number_of_records
FROM
  interest_metrics
GROUP BY
  month_year
ORDER BY
  month_year NULLS FIRST
```

| date       | number_of_records |
| ---------- | ----------------- |
|            | 1194              |
| 2018-07-01 | 729               |
| 2018-08-01 | 767               |
| 2018-09-01 | 780               |
| 2018-10-01 | 857               |
| 2018-11-01 | 928               |
| 2018-12-01 | 995               |
| 2019-01-01 | 973               |
| 2019-02-01 | 1121              |
| 2019-03-01 | 1136              |
| 2019-04-01 | 1099              |
| 2019-05-01 | 857               |
| 2019-06-01 | 824               |
| 2019-07-01 | 864               |
| 2019-08-01 | 1149              |

#### 3. What do you think we should do with these null values in the `fresh_segments.interest_metrics`?

If `month_year` and `interest_id` columns are nulls, then we can just drop these values, or exclude them because we can not join them to other tables and can not understand what the other values, like composition, index, ranking in the rows are about. For example, we see the composition or index but do not know which `interest_id` it belongs to. 

#### 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?

We will compare the interests in the two tables using the `NOT IN` statement.

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  )
```

| interest_id |
| ----------- |
| 0           |

***0 `interest_id` from the `interest_metrics` table are not in the `interest_map` table***

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  )
```

| interest_id |
| ----------- |
| 7           |

***7 `id` from the `interest_map` table are not in the `interest_metrics` table***

#### 5. Summarise the `id` values in the `fresh_segments.interest_map` by its total record count in this table

We need to count how many distinct interest IDs are in the `interest_map` table.

```sql
SET
  SEARCH_PATH = fresh_segments;
SELECT
  COUNT(distinct id) AS total_count
FROM
  interest_map AS m
```

| total_count |
| ----------- |
| 1209        |

#### 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where `interest_id` = 21246 in your joined output and include all columns from `fresh_segments.interest_metrics` and all columns from `fresh_segments.interest_map` except from the `id` column

As we know from the question 4, the number of the unique id records in the `interest_metrics` table and in the `interest_map` table is not the same: the `interest_metrics` table has 1202 unique `interest_id` records, and the `interest_map` table has 1209 unique `id` records.

That's why I used `LEFT JOIN` to keep all the values from the `interest_map` table, and join the records from the `interest_metrics` table only to the matching values.

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  _month NULLS FIRST
```

| interest_id | interest_name                    | interest_summary                                      | created_at               | last_modified            | \_month | \_year | month_year | composition | index_value | ranking | percentile_ranking |
| ----------- | -------------------------------- | ----------------------------------------------------- | ------------------------ | ------------------------ | ------ | ----- | ---------- | ----------- | ----------- | ------- | ------------------ |
| 21246       | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11T17:50:04.000Z | 2018-06-11T17:50:04.000Z |        |       |            | 1.61        | 0.68        | 1191    | 0.25               |
| 21246       | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11T17:50:04.000Z | 2018-06-11T17:50:04.000Z | 1      | 2019  | 01-2019    | 2.05        | 0.76        | 954     | 1.95               |
| 21246       | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11T17:50:04.000Z | 2018-06-11T17:50:04.000Z | 10     | 2018  | 10-2018    | 1.74        | 0.58        | 855     | 0.23               |
| 21246       | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11T17:50:04.000Z | 2018-06-11T17:50:04.000Z | 11     | 2018  | 11-2018    | 2.25        | 0.78        | 908     | 2.16               |
| 21246       | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11T17:50:04.000Z | 2018-06-11T17:50:04.000Z | 12     | 2018  | 12-2018    | 1.97        | 0.7         | 983     | 1.21               |
| 21246       | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11T17:50:04.000Z | 2018-06-11T17:50:04.000Z | 2      | 2019  | 02-2019    | 1.84        | 0.68        | 1109    | 1.07               |
| 21246       | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11T17:50:04.000Z | 2018-06-11T17:50:04.000Z | 3      | 2019  | 03-2019    | 1.75        | 0.67        | 1123    | 1.14               |
| 21246       | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11T17:50:04.000Z | 2018-06-11T17:50:04.000Z | 4      | 2019  | 04-2019    | 1.58        | 0.63        | 1092    | 0.64               |
| 21246       | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11T17:50:04.000Z | 2018-06-11T17:50:04.000Z | 7      | 2018  | 07-2018    | 2.26        | 0.65        | 722     | 0.96               |
| 21246       | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11T17:50:04.000Z | 2018-06-11T17:50:04.000Z | 8      | 2018  | 08-2018    | 2.13        | 0.59        | 765     | 0.26               |
| 21246       | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources. | 2018-06-11T17:50:04.000Z | 2018-06-11T17:50:04.000Z | 9      | 2018  | 09-2018    | 2.06        | 0.61        | 774     | 0.77               |

#### 7. Are there any records in your joined table where the `month_year` value is before the `created_at` value from the `fresh_segments.interest_map` table? Do you think these values are valid and why?

Let's find these values by comparing created_at date and month_year date:

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  1
```

| count |
| ----- |
| 188   |

We have 188 rows where the `month_year` value is before the `created_at` value from the `fresh_segments.interest_map` table. I think these values are valid because months are the same, and the value in the `month_year` column has the first day of the month but we do not know the real day of the month as we created this column by combining month and year only.

### Interest Analysis

#### 1. Which interests have been present in all `month_year` dates in our dataset?

Let's count how many distinct months we have in the `interest_metrics` table:

```sql
SET
  SEARCH_PATH = fresh_segments;
SELECT
  COUNT(distinct month_year)
FROM
  interest_metrics
```

| count |
| ----- |
| 14    |

There are 14 months.

Now we can count how many times each interest appeared in the table and keep only the values where count is equal to 14.

Let's try this query:

```sql
SET
  SEARCH_PATH = fresh_segments;
SELECT
  interest_name,
  COUNT(interest_id)
FROM
  interest_map AS m
  left join interest_metrics AS im ON m.id = im.interest_id :: int
GROUP BY
  1
ORDER BY
  2 DESC
```

| interest_name                                        | count |
| ---------------------------------------------------- | ----- |
| Pizza Lovers                                         | 18    |
| Luxury Travel Researchers                            | 14    |
| Real Estate Decision Makers                          | 14    |
| Last Minute Travelers                                | 14    |
| Atlanta Trip Planners                                | 14    |
| Zoo Visitors                                         | 14    |
| Mens Shoe Shoppers                                   | 14    |
| Ski House Second Home Owners                         | 14    |
| Nursing Students                                     | 14    |
| Sporting Goods Shoppers                              | 14    |
| Halloween Costume Shoppers                           | 14    |
| Software Directory Researchers                       | 14    |
| Democrats                                            | 14    |

What do we see? The Pizza Lovers intererest has the value which is equal to 18. Ok, we need to re-write the query and add the `id` column:

```sql
SET
  SEARCH_PATH = fresh_segments;
SELECT
  id,
  interest_name,
  COUNT(interest_id)
FROM
  interest_map AS m
  LEFT JOIN interest_metrics AS im ON m.id = im.interest_id :: int
WHERE
  interest_name = 'Pizza Lovers'
GROUP BY
  1,
  2
ORDER BY
  3 DESC
```

| id    | interest_name | count |
| ----- | ------------- | ----- |
| 6364  | Pizza Lovers  | 14    |
| 45668 | Pizza Lovers  | 4     |

There are two Pizza Lovers interest with different IDs, and we need to keep one of them, where count = 14.

Now the final version of the query looks like this:

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  1
```

A few rows from the results:

<details><summary> Click to expand :arrow_down: </summary>
  
| interest_name                                        |
| ---------------------------------------------------- |
| Accounting & CPA Continuing Education Researchers    |
| Affordable Hotel Bookers                             |
| Aftermarket Accessories Shoppers                     |
| Alabama Trip Planners                                |
| Alaskan Cruise Planners                              |
| Alzheimer and Dementia Researchers                   |
| Anesthesiologists                                    |
| Apartment Furniture Shoppers                         |
| Apartment Hunters                                    |
| Apple Fans                                           |
| Arizona Trip Planners                                |
| Arsenal Fans                                         |
| Arthritis Sufferers                                  |
| Asian Food Enthusiasts                               |
| Asthma Sufferers                                     |
| At-Home Gym Intenders                                |
| Atlanta Trip Planners                                |
| Audi Vehicle Shoppers                                |
| Audio Book Listeners                                 |
| Austin Trip Planners                                 |
| Australia Trip Planners                              |
| Authors                                              |
| Auto Insurance Shoppers                              |
| Auto Show Enthusiasts                                |
| Auto-Looking for New Car Purchase or Lease           |
| Automotive Safety Researchers                        |
| Avid Readers                                         |
| Back Pain Sufferers                                  |
| Beach House Second Home Owners                       |
| Beach Supplies Shoppers                              |
| Beard Care Shoppers                                  |
| Beauty & Skincare Buyers                             |
| Bed & Bath Shoppers                                  |
| Beer Aficionados                                     |
| Beer Lovers                                          |
| Big & Tall Men                                       |
| Boston Celtics Fans                                  |
...
| Shared Work Space Researchers                        |
| Shoe Shoppers                                        |
| Sightseeing Travelers                                |
| Ski House Second Home Owners                         |
| Ski and Snowboard Enthusiasts                        |
| Skin Care Researchers                                |
| Sleep Disorder Researchers                           |
| Small Business Employees                             |
| Smart Home Product Researchers                       |
| Soccer Fans                                          |
| Software Directory Researchers                       |
| Solar Energy Solution Shoppers                       |
| Sony Fans                                            |
| Spa Goers                                            |
| Spa and Pool Owners                                  |
| Special Olympics Fans                                |
| Sporting Goods Shoppers                              |
| Sports Gamblers                                      |
| Sports Medicine Health Care Professionals            |
| Stay-at-Home Parents                                 |
| Streaming Music Enthusiasts                          |
| Study Abroad Researchers                             |
| Summer Activities Researchers                        |
| Summer Festivals and Fairs Visitors                  |
| Supermarket Shoppers                                 |
| Supply Chain Professionals                           |
| Surfers                                              |
| Sweet Tooths                                         |
| Tailgaters                                           |
| Teachers                                             |
| Tech-Savvy Moms                                      |
| Teen Girl Clothing Shoppers                          |
| Tennis Players                                       |
| Texas Energy Providers                               |
| Texas Trip Planners                                  |
| Thanksgiving Entertaining Researchers                |
| Thanksgiving Meal Planners                           |
| Theme Park Researchers                               |
| Thrift Store Shoppers                                |
| Tire Researchers                                     |
| Tire Shoppers                                        |
| Toyota Vehicle Shopper                               |
| Tractor Shoppers                                     |
| Travel Researchers                                   |
| Travel Reward Points Enthusiasts                     |
| United Arab Emirates Trip Planners                   |
| Urban Skateboarding Sneaker Shoppers                 |
| Used Car Shoppers                                    |
| Vacation Planners                                    |
| Vacation Rental Accommodation Researchers            |
| Vacuum Shoppers                                      |
| Vaping Shoppers                                      |
| Vegans                                               |
| Venture Capitalists                                  |
| Video Game Shoppers                                  |
| Videographers                                        |
| Vitamin Shoppers                                     |
| Washington DC Trip Planners                          |
| Water Park Visitors                                  |
| Web Design Researchers                               |
| Weight Lifting Enthusiasts                           |
| Weight Loss Researchers                              |
| Whiskey Lovers                                       |
| Wireless Service Provider Researchers                |
| Womens Equality Advocates                            |
| Womens Fashion Brands Shoppers                       |
| World Cup Apparel Shoppers                           |
| World Cup Enthusiasts                                |
| Yachting Enthusiasts                                 |
| Yale University Fans                                 |
| Yogis                                                |
| Zoo Visitors                                         |

</details>  

#### 2. Using this same `total_months` measure - calculate the cumulative percentage of all records starting at 14 months - which `total_months` value passes the 90% cumulative percentage value?

It took some time before I realised what I need to do here. I think the goal is to exclude 10% bottom interests by calculating reversed cumulative value.
We need to find all values that are lower than top 90 - and we will reverse the top, to show these interests first. As these interests do not have any significant influence we can remove them from our dataset.

The formula for calculating cumulative percentage is based on the logic that the percentage of all records for 14 months is equal to the `SUM` of all interests in a month until the month 14, divided to the `SUM` of all interests. As a result, the `cum_top` column shows the bottom 10% of interests, and the `cum_top_reverse` column shows the records that pass the 90% cumulative percentage value, as the subtraction of 100 to the cumulative percentage value. 

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  1
```

| total_months | number_of_interests | cum_top | cum_top_reversed |
| ------------ | ------------------- | ------- | ---------------- |
| 1            | 13                  | 1.08    | 98.92            |
| 2            | 12                  | 2.08    | 97.92            |
| 3            | 15                  | 3.33    | 96.67            |
| 4            | 32                  | 5.99    | 94.01            |
| 5            | 38                  | 9.15    | 90.85            |
| 6            | 33                  | 11.90   | 88.10            |
| 7            | 90                  | 19.38   | 80.62            |
| 8            | 67                  | 24.96   | 75.04            |
| 9            | 95                  | 32.86   | 67.14            |
| 10           | 85                  | 39.93   | 60.07            |
| 11           | 95                  | 47.84   | 52.16            |
| 12           | 65                  | 53.24   | 46.76            |
| 13           | 82                  | 60.07   | 39.93            |
| 14           | 480                 | 100.00  | 0.00             |

***The interests which presented in 6+ months has passed 90% cumulative percentage value***

#### 3. If we were to remove all `interest_id` values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?

Let's count how many interests are in the bottom 10% of the cumulative interests.

```sql
SET
  SEARCH_PATH = fresh_segments;
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
      COUNT(interest_id) < 6
  )
SELECT
  COUNT(interest_name) AS number_of_interests
FROM
  interests
ORDER BY
  1
```

| number_of_interests |
| ------------------- |
| 117                 |

117 data points would be removed as these interests are the bottom 10% of the all interests - if we join the `intereset_map` and the `interest_metrics` table.

I think this join is not necessary and we can remove only the 10% bottom interests from the interest_metrics table only (7 interests from the `interest_map` table are not presented in the `interest_metrics` table):

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  1
```

| number_of_interests |
| ------------------- |
| 110                 |

Now we have 110 data points to remove.

#### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.

The decision makes sense, these data points are less valuable and do not represent strong and constant interests of the users. Removing these interests let us keep the segmets more targeted and focused to the most popular interests and customers' needs.

Let's compare month by month, how many interests we exclude and how many we keep:

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  1
```

| month_year | number_of_excluded_interests | number_of_included_interests | percent_of_excluded |
| ---------- | ---------------------------- | ---------------------------- | ------------------- |
| 07-2018    | 20                           | 709                          | 2.8                 |
| 08-2018    | 15                           | 752                          | 2.0                 |
| 09-2018    | 6                            | 774                          | 0.8                 |
| 10-2018    | 4                            | 853                          | 0.5                 |
| 11-2018    | 3                            | 925                          | 0.3                 |
| 12-2018    | 9                            | 986                          | 0.9                 |
| 01-2019    | 7                            | 966                          | 0.7                 |
| 02-2019    | 49                           | 1072                         | 4.6                 |
| 03-2019    | 58                           | 1078                         | 5.4                 |
| 04-2019    | 64                           | 1035                         | 6.2                 |
| 05-2019    | 30                           | 827                          | 3.6                 |
| 06-2019    | 20                           | 804                          | 2.5                 |
| 07-2019    | 28                           | 836                          | 3.3                 |
| 08-2019    | 87                           | 1062                         | 8.2                 |

#### 5. After removing these interests - how many unique interests are there for each month?

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  1
```

| month_year | number_of_included_interests | 
| ---------- | ---------------------------- | 
| 07-2018    | 709                          |
| 08-2018    | 752                          |
| 09-2018    | 774                          | 
| 10-2018    | 853                          | 
| 11-2018    | 925                          |
| 12-2018    | 986                          | 
| 01-2019    | 966                          | 
| 02-2019    | 1072                         |
| 03-2019    | 1078                         | 
| 04-2019    | 1035                         | 
| 05-2019    | 827                          |
| 06-2019    | 804                          | 
| 07-2019    | 836                          | 
| 08-2019    | 1062                         | 

### Segment Analysis

#### 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any `month_year`? Only use the maximum composition value for each interest but you must keep the corresponding `month_year`

We need to select the top 10 and the bottom 10 interests. Each interest may appear only once as we can use only the maximum composition value for each interest, and any month - so months can be repeated. So, we need to select the unique top 10 and bottom 10 interests with the maximum composition value.

The query is quite complex and here is my logic.

We create two CTEs:
- in the first one we select the top 10 interests by ranking each interest by the maximum composition value in descending order and selecting the interests with the rank = 1
- in the second one we select the bottom 10 interests by ranking each interest by the minimum composition value in ascending order and selecting the interests with the rank = 1

At the next step we use the `UNION` statement to combine these two tables into one.

And the next step - as we need to use only the maximum composition value for each interest, we join the table from step one and select the maximum composition value for each interest.

I kept two different columns for composition value and the maximum composition value to show the minimum and maximum values separately. And the maximum values are equal. 

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  3 DESC
```

| month_year | interest_name                     | composition | max_composition | max_composition_month |
| ---------- | --------------------------------- | ----------- | --------------- | --------------------- |
| 12-2018    | Work Comes First Travelers        | 21.2        | 21.2            | 12-2018               |
| 07-2018    | Gym Equipment Owners              | 18.82       | 18.82           | 07-2018               |
| 07-2018    | Furniture Shoppers                | 17.44       | 17.44           | 07-2018               |
| 07-2018    | Luxury Retail Shoppers            | 17.19       | 17.19           | 07-2018               |
| 10-2018    | Luxury Boutique Hotel Researchers | 15.15       | 15.15           | 10-2018               |
| 12-2018    | Luxury Bedding Shoppers           | 15.05       | 15.05           | 12-2018               |
| 07-2018    | Shoe Shoppers                     | 14.91       | 14.91           | 07-2018               |
| 07-2018    | Cosmetics and Beauty Shoppers     | 14.23       | 14.23           | 07-2018               |
| 07-2018    | Luxury Hotel Guests               | 14.1        | 14.1            | 07-2018               |
| 07-2018    | Luxury Retail Researchers         | 13.97       | 13.97           | 07-2018               |
| 05-2019    | LED Lighting Shoppers             | 1.53        | 5.96            | 07-2018               |
| 05-2019    | Crochet Enthusiasts               | 1.53        | 2.97            | 11-2018               |
| 06-2019    | Online Directory Searchers        | 1.53        | 3.77            | 07-2018               |
| 05-2019    | Beer Aficionados                  | 1.52        | 6.53            | 07-2018               |
| 05-2019    | Gastrointestinal Researchers      | 1.52        | 6.29            | 07-2018               |
| 06-2019    | Disney Fans                       | 1.52        | 2.95            | 10-2018               |
| 05-2019    | Philadelphia 76ers Fans           | 1.52        | 2.77            | 08-2019               |
| 04-2019    | United Nations Donors             | 1.52        | 2.68            | 02-2019               |
| 06-2019    | New York Giants Fans              | 1.52        | 2.68            | 08-2019               |
| 05-2019    | Mowing Equipment Shoppers         | 1.51        | 2.57            | 03-2019               |

#### 2. Which 5 interests had the lowest average ranking value?

The highest ranking is equal to 1. So the more the rank value, the lower the ranking of the interest. We can calculate the average ranking and then rank the results in descending order.

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  AND 5
```

| interest_name                                      | avg_ranking |
| -------------------------------------------------- | ----------- |
| League of Legends Video Game Fans                  | 1037.29     |
| Computer Processor and Data Center Decision Makers | 974.13      |
| Astrology Enthusiasts                              | 968.50      |
| Medieval History Enthusiasts                       | 961.71      |
| Budget Mobile Phone Researchers                    | 961.00      |

#### 3. Which 5 interests had the largest standard deviation in their `percentile_ranking` value?

We can count the standart deviation value by using the `STDDEV()` function. Then we need to rank the results in the descending order and select the top 5 results.

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  AND 5
```

| interest_name                          | standard_deviation |
| -------------------------------------- | ------------------ |
| Techies                                | 30.18              |
| Entertainment Industry Decision Makers | 28.97              |
| Oregon Trip Planners                   | 28.32              |
| Personalized Gift Shoppers             | 26.24              |
| Tampa and St Petersburg Trip Planners  | 25.61              |

#### 4. For the 5 interests found in the previous question - what was minimum and maximum `percentile_ranking` values for each interest and its corresponding `year_month` value? Can you describe what is happening for these 5 interests?

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  3 DESC
```

| month_year | interest_name                          | percentile_ranking |
| ---------- | -------------------------------------- | ------------------ |
| 07-2018    | Entertainment Industry Decision Makers | 86.15              |
| 08-2019    | Entertainment Industry Decision Makers | 11.23              |
| 11-2018    | Oregon Trip Planners                   | 82.44              |
| 07-2019    | Oregon Trip Planners                   | 2.2                |
| 03-2019    | Personalized Gift Shoppers             | 73.15              |
| 06-2019    | Personalized Gift Shoppers             | 5.7                |
| 07-2018    | Tampa and St Petersburg Trip Planners  | 75.03              |
| 03-2019    | Tampa and St Petersburg Trip Planners  | 4.84               |
| 07-2018    | Techies                                | 86.69              |
| 08-2019    | Techies                                | 7.92               |

Popularity of these interests is decreasing from month to month. For example, there were 86.69% of customers are interested in Techies in July 2018, and only 7.92% of customers by August, 2019. 

#### 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

The customers in this segment love to travel, some of them are probably business travellers, they prefer luxury lifestyle and go into sports.
We should show the products or services related to luxury travel or luxury lifestyle (furniture, cosmetics, apparel), and avoid budget segment or any product or services related to random interests like computer games or astrology. We also can exclude some topics related to locations that are out of area of the customers' interests like Tampa or Oregon, because the customers possibly has already visited those locations and do not wish to return there. Also we can exclude topics related to some long-term needs and the  long-term use products, that the customers have probably already purchased. For example, if a customer had an interest in Luxury Furniture or Gym Equipment, they might have purchased those products and do not have interest in this topic anymore. 

So in general we need to focus on the interests with high composition value but we need to track this metric to define when customers lose their interest in the topic.

### Index Analysis

The `index_value` is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the `index_value` column rounded to 2 decimal places.

#### 1. What is the top 10 interests by the average composition for each month?

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  3 DESC
```  

<details><summary> Click to expand :arrow_down: </summary>
  
| month_year | interest_name                                        | avg_composition |
| ---------- | ---------------------------------------------------- | --------------- |
| 07-2018    | Las Vegas Trip Planners                              | 7.36            |
| 07-2018    | Gym Equipment Owners                                 | 6.94            |
| 07-2018    | Cosmetics and Beauty Shoppers                        | 6.78            |
| 07-2018    | Luxury Retail Shoppers                               | 6.61            |
| 07-2018    | Furniture Shoppers                                   | 6.51            |
| 07-2018    | Asian Food Enthusiasts                               | 6.10            |
| 07-2018    | Recently Retired Individuals                         | 5.72            |
| 07-2018    | Family Adventures Travelers                          | 4.85            |
| 07-2018    | Work Comes First Travelers                           | 4.80            |
| 07-2018    | HDTV Researchers                                     | 4.71            |
| 08-2018    | Las Vegas Trip Planners                              | 7.21            |
| 08-2018    | Gym Equipment Owners                                 | 6.62            |
| 08-2018    | Luxury Retail Shoppers                               | 6.53            |
| 08-2018    | Furniture Shoppers                                   | 6.30            |
| 08-2018    | Cosmetics and Beauty Shoppers                        | 6.28            |
| 08-2018    | Work Comes First Travelers                           | 5.70            |
| 08-2018    | Asian Food Enthusiasts                               | 5.68            |
| 08-2018    | Recently Retired Individuals                         | 5.58            |
| 08-2018    | Alabama Trip Planners                                | 4.83            |
| 08-2018    | Luxury Bedding Shoppers                              | 4.72            |
| 09-2018    | Work Comes First Travelers                           | 8.26            |
| 09-2018    | Readers of Honduran Content                          | 7.60            |
| 09-2018    | Alabama Trip Planners                                | 7.27            |
| 09-2018    | Luxury Bedding Shoppers                              | 7.04            |
| 09-2018    | Nursing and Physicians Assistant Journal Researchers | 6.70            |
| 09-2018    | New Years Eve Party Ticket Purchasers                | 6.59            |
| 09-2018    | Teen Girl Clothing Shoppers                          | 6.53            |
| 09-2018    | Christmas Celebration Researchers                    | 6.47            |
| 09-2018    | Restaurant Supply Shoppers                           | 6.25            |
| 09-2018    | Solar Energy Researchers                             | 6.24            |
| 10-2018    | Work Comes First Travelers                           | 9.14            |
| 10-2018    | Alabama Trip Planners                                | 7.10            |
| 10-2018    | Readers of Honduran Content                          | 7.02            |
| 10-2018    | Nursing and Physicians Assistant Journal Researchers | 7.02            |
| 10-2018    | Luxury Bedding Shoppers                              | 6.94            |
| 10-2018    | New Years Eve Party Ticket Purchasers                | 6.91            |
| 10-2018    | Teen Girl Clothing Shoppers                          | 6.78            |
| 10-2018    | Christmas Celebration Researchers                    | 6.72            |
| 10-2018    | Luxury Boutique Hotel Researchers                    | 6.53            |
| 10-2018    | Solar Energy Researchers                             | 6.50            |
| 11-2018    | Work Comes First Travelers                           | 8.28            |
| 11-2018    | Readers of Honduran Content                          | 7.09            |
| 11-2018    | Solar Energy Researchers                             | 7.05            |
| 11-2018    | Alabama Trip Planners                                | 6.69            |
| 11-2018    | Nursing and Physicians Assistant Journal Researchers | 6.65            |
| 11-2018    | Luxury Bedding Shoppers                              | 6.54            |
| 11-2018    | New Years Eve Party Ticket Purchasers                | 6.31            |
| 11-2018    | Christmas Celebration Researchers                    | 6.08            |
| 11-2018    | Teen Girl Clothing Shoppers                          | 5.95            |
| 11-2018    | Restaurant Supply Shoppers                           | 5.59            |
| 12-2018    | Work Comes First Travelers                           | 8.31            |
| 12-2018    | Nursing and Physicians Assistant Journal Researchers | 6.96            |
| 12-2018    | Alabama Trip Planners                                | 6.68            |
| 12-2018    | Luxury Bedding Shoppers                              | 6.63            |
| 12-2018    | Readers of Honduran Content                          | 6.58            |
| 12-2018    | Solar Energy Researchers                             | 6.55            |
| 12-2018    | New Years Eve Party Ticket Purchasers                | 6.48            |
| 12-2018    | Teen Girl Clothing Shoppers                          | 6.38            |
| 12-2018    | Christmas Celebration Researchers                    | 6.09            |
| 12-2018    | Chelsea Fans                                         | 5.86            |
| 01-2019    | Work Comes First Travelers                           | 7.66            |
| 01-2019    | Solar Energy Researchers                             | 7.05            |
| 01-2019    | Readers of Honduran Content                          | 6.67            |
| 01-2019    | Nursing and Physicians Assistant Journal Researchers | 6.46            |
| 01-2019    | Luxury Bedding Shoppers                              | 6.46            |
| 01-2019    | Alabama Trip Planners                                | 6.44            |
| 01-2019    | New Years Eve Party Ticket Purchasers                | 6.16            |
| 01-2019    | Teen Girl Clothing Shoppers                          | 5.96            |
| 01-2019    | Christmas Celebration Researchers                    | 5.65            |
| 01-2019    | Chelsea Fans                                         | 5.48            |
| 01-2019    | Readers of Catholic News                             | 5.48            |
| 02-2019    | Work Comes First Travelers                           | 7.66            |
| 02-2019    | Nursing and Physicians Assistant Journal Researchers | 6.84            |
| 02-2019    | Luxury Bedding Shoppers                              | 6.76            |
| 02-2019    | Alabama Trip Planners                                | 6.65            |
| 02-2019    | Solar Energy Researchers                             | 6.58            |
| 02-2019    | New Years Eve Party Ticket Purchasers                | 6.56            |
| 02-2019    | Teen Girl Clothing Shoppers                          | 6.29            |
| 02-2019    | Readers of Honduran Content                          | 6.24            |
| 02-2019    | PlayStation Enthusiasts                              | 6.23            |
| 02-2019    | Christmas Celebration Researchers                    | 5.98            |
| 03-2019    | Alabama Trip Planners                                | 6.54            |
| 03-2019    | Nursing and Physicians Assistant Journal Researchers | 6.52            |
| 03-2019    | Luxury Bedding Shoppers                              | 6.47            |
| 03-2019    | Solar Energy Researchers                             | 6.40            |
| 03-2019    | Readers of Honduran Content                          | 6.21            |
| 03-2019    | New Years Eve Party Ticket Purchasers                | 6.21            |
| 03-2019    | PlayStation Enthusiasts                              | 6.06            |
| 03-2019    | Teen Girl Clothing Shoppers                          | 6.01            |
| 03-2019    | Readers of Catholic News                             | 5.65            |
| 03-2019    | Christmas Celebration Researchers                    | 5.61            |
| 03-2019    | Restaurant Supply Shoppers                           | 5.61            |
| 04-2019    | Solar Energy Researchers                             | 6.28            |
| 04-2019    | Alabama Trip Planners                                | 6.21            |
| 04-2019    | Luxury Bedding Shoppers                              | 6.05            |
| 04-2019    | Readers of Honduran Content                          | 6.02            |
| 04-2019    | Nursing and Physicians Assistant Journal Researchers | 6.01            |
| 04-2019    | New Years Eve Party Ticket Purchasers                | 5.65            |
| 04-2019    | PlayStation Enthusiasts                              | 5.52            |
| 04-2019    | Teen Girl Clothing Shoppers                          | 5.39            |
| 04-2019    | Readers of Catholic News                             | 5.30            |
| 04-2019    | Restaurant Supply Shoppers                           | 5.07            |
| 05-2019    | Readers of Honduran Content                          | 4.41            |
| 05-2019    | Readers of Catholic News                             | 4.08            |
| 05-2019    | Solar Energy Researchers                             | 3.92            |
| 05-2019    | PlayStation Enthusiasts                              | 3.55            |
| 05-2019    | Alabama Trip Planners                                | 3.34            |
| 05-2019    | Gamers                                               | 3.29            |
| 05-2019    | Luxury Bedding Shoppers                              | 3.25            |
| 05-2019    | New Years Eve Party Ticket Purchasers                | 3.19            |
| 05-2019    | Video Gamers                                         | 3.19            |
| 05-2019    | Nursing and Physicians Assistant Journal Researchers | 3.15            |
| 06-2019    | Las Vegas Trip Planners                              | 2.77            |
| 06-2019    | Gym Equipment Owners                                 | 2.55            |
| 06-2019    | Cosmetics and Beauty Shoppers                        | 2.55            |
| 06-2019    | Asian Food Enthusiasts                               | 2.52            |
| 06-2019    | Luxury Retail Shoppers                               | 2.46            |
| 06-2019    | Furniture Shoppers                                   | 2.39            |
| 06-2019    | Medicare Researchers                                 | 2.35            |
| 06-2019    | Recently Retired Individuals                         | 2.27            |
| 06-2019    | Medicare Provider Researchers                        | 2.21            |
| 06-2019    | Cruise Travel Intenders                              | 2.20            |
| 07-2019    | Las Vegas Trip Planners                              | 2.82            |
| 07-2019    | Luxury Retail Shoppers                               | 2.81            |
| 07-2019    | Furniture Shoppers                                   | 2.79            |
| 07-2019    | Gym Equipment Owners                                 | 2.79            |
| 07-2019    | Cosmetics and Beauty Shoppers                        | 2.78            |
| 07-2019    | Asian Food Enthusiasts                               | 2.78            |
| 07-2019    | Medicare Researchers                                 | 2.77            |
| 07-2019    | Medicare Provider Researchers                        | 2.73            |
| 07-2019    | Recently Retired Individuals                         | 2.72            |
| 07-2019    | Medicare Price Shoppers                              | 2.66            |
| 08-2019    | Cosmetics and Beauty Shoppers                        | 2.73            |
| 08-2019    | Gym Equipment Owners                                 | 2.72            |
| 08-2019    | Las Vegas Trip Planners                              | 2.70            |
| 08-2019    | Asian Food Enthusiasts                               | 2.68            |
| 08-2019    | Solar Energy Researchers                             | 2.66            |
| 08-2019    | Furniture Shoppers                                   | 2.59            |
| 08-2019    | Luxury Retail Shoppers                               | 2.59            |
| 08-2019    | Marijuana Legalization Advocates                     | 2.56            |
| 08-2019    | Medicare Researchers                                 | 2.55            |
| 08-2019    | Recently Retired Individuals                         | 2.53            |

</details>  

#### 2. For all of these top 10 interests - which interest appears the most often?

As I understand we need to count the number of months when a certain interest had the top 1 position. We can do that by ranking all interests within one month using the `rank()` window function. Then we need to count the interests with rank = 1.

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  2 DESC
```

| interest_name                 | months_in_top_1 |
| ----------------------------- | --------------- |
| Work Comes First Travelers    | 6               |
| Las Vegas Trip Planners       | 4               |
| Alabama Trip Planners         | 1               |
| Cosmetics and Beauty Shoppers | 1               |
| Readers of Honduran Content   | 1               |
| Solar Energy Researchers      | 1               |

***The most popular interest is Work Comes First Travelers, it was the top 1 for 6 months***

#### 3. What is the average of the average composition for the top 10 interests for each month?

We will count the average of the average composition for the result from the question 1.

```sql
SET
  SEARCH_PATH = fresh_segments;
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
  1
```  
  
| month_year | average_rating |
| ---------- | -------------- |
| 01-2019    | 6.32           |
| 02-2019    | 6.58           |
| 03-2019    | 6.12           |
| 04-2019    | 5.75           |
| 05-2019    | 3.54           |
| 06-2019    | 2.43           |
| 07-2018    | 6.04           |
| 07-2019    | 2.77           |
| 08-2018    | 5.95           |
| 08-2019    | 2.63           |
| 09-2018    | 6.90           |
| 10-2018    | 7.07           |
| 11-2018    | 6.62           |
| 12-2018    | 6.65           |

As we can see, the average composition is decreasing from April 2019.

#### 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below

We will calculate the 3 month rolling average by using a window over 3 months in `month_year` column and this statement: `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`. To get the values for previous months, we will use the `LAG()` window function and the `OFFSET` parameter = 2 to get the 2 month ago value.

```sql
SET
  SEARCH_PATH = fresh_segments;
SELECT
  *
FROM
  (
    WITH ranking AS (
      SELECT
        month_year :: varchar,
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
  1
```  

| month_year | interest_name                 | max_index_composition | \_3_month_moving_avg | \_1_month_ago                      | \_2_month_ago                      |
| ---------- | ----------------------------- | --------------------- | ------------------- | --------------------------------- | --------------------------------- |
| 2018-09-01 | Work Comes First Travelers    | 8.26                  | 7.61                | Las Vegas Trip Planners: 7.21     | Las Vegas Trip Planners: 7.36     |
| 2018-10-01 | Work Comes First Travelers    | 9.14                  | 8.20                | Work Comes First Travelers: 8.26  | Las Vegas Trip Planners: 7.21     |
| 2018-11-01 | Work Comes First Travelers    | 8.28                  | 8.56                | Work Comes First Travelers: 9.14  | Work Comes First Travelers: 8.26  |
| 2018-12-01 | Work Comes First Travelers    | 8.31                  | 8.58                | Work Comes First Travelers: 8.28  | Work Comes First Travelers: 9.14  |
| 2019-01-01 | Work Comes First Travelers    | 7.66                  | 8.08                | Work Comes First Travelers: 8.31  | Work Comes First Travelers: 8.28  |
| 2019-02-01 | Work Comes First Travelers    | 7.66                  | 7.88                | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 8.31  |
| 2019-03-01 | Alabama Trip Planners         | 6.54                  | 7.29                | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 7.66  |
| 2019-04-01 | Solar Energy Researchers      | 6.28                  | 6.83                | Alabama Trip Planners: 6.54       | Work Comes First Travelers: 7.66  |
| 2019-05-01 | Readers of Honduran Content   | 4.41                  | 5.74                | Solar Energy Researchers: 6.28    | Alabama Trip Planners: 6.54       |
| 2019-06-01 | Las Vegas Trip Planners       | 2.77                  | 4.49                | Readers of Honduran Content: 4.41 | Solar Energy Researchers: 6.28    |
| 2019-07-01 | Las Vegas Trip Planners       | 2.82                  | 3.33                | Las Vegas Trip Planners: 2.77     | Readers of Honduran Content: 4.41 |
| 2019-08-01 | Cosmetics and Beauty Shoppers | 2.73                  | 2.77                | Las Vegas Trip Planners: 2.82     | Las Vegas Trip Planners: 2.77     |

#### 5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?

I think that the users' interests may have changed, and the users are less interested in some topics now if at all. Users "burnt out", and the index composition value has decreased. Maybe some users (or interests) need to be transferred to another segment. However, some interests keep high `index_composition` value, it possibly means that these topics are always in the users' interest area. Another possible reason is seasonality.

To make the long story short, the company can ask themselves: are the fresh segments really fresh?
