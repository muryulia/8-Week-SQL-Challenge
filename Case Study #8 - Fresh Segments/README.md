# Case Study #8 - Fresh Segments :diamond_shape_with_a_dot_inside:

<img src="https://user-images.githubusercontent.com/98699089/158591829-696bd095-b249-4403-8467-0d867d4c6971.png" width="500">

Clients share their customer lists with the Fresh Segments team who then aggregate interest metrics and generate a single dataset worth of metrics for further analysis.

Danny has asked for your assistance to analyse aggregated metrics for an example client and provide some high level insights about the customer list and their interests.

## Available Data

For this case study there is a total of 2 datasets which you will need to use to solve the questions.

### Interest Metrics

This table contains information about aggregated interest metrics for a specific major client of Fresh Segments which makes up a large proportion of their customer base.

Each record in this table represents the performance of a specific interest_id based on the client’s customer base interest measured through clicks and interactions with specific targeted advertising content.

| \_month | \_year | month_year | interest_id | composition | index_value | ranking | percentile_ranking |
|---------|--------|------------|-------------|-------------|-------------|---------|--------------------|
| 7       | 2018   | 07-2018    | 32486       | 11.89       | 6.19        | 1       | 99.86              |
| 7       | 2018   | 07-2018    | 6106        | 9.93        | 5.31        | 2       | 99.73              |
| 7       | 2018   | 07-2018    | 18923       | 10.85       | 5.29        | 3       | 99.59              |
| 7       | 2018   | 07-2018    | 6344        | 10.32       | 5.1         | 4       | 99.45              |
| 7       | 2018   | 07-2018    | 100         | 10.77       | 5.04        | 5       | 99.31              |
| 7       | 2018   | 07-2018    | 69          | 10.82       | 5.03        | 6       | 99.18              |
| 7       | 2018   | 07-2018    | 79          | 11.21       | 4.97        | 7       | 99.04              |
| 7       | 2018   | 07-2018    | 6111        | 10.71       | 4.83        | 8       | 98.9               |
| 7       | 2018   | 07-2018    | 6214        | 9.71        | 4.83        | 8       | 98.9               |
| 7       | 2018   | 07-2018    | 19422       | 10.11       | 4.81        | 10      | 98.63              |


For example - let’s interpret the first row of the interest_metrics table together:

| \_month | \_year | month_year | interest_id | composition | index_value | ranking | percentile_ranking |
|---------|--------|------------|-------------|-------------|-------------|---------|--------------------|
| 7       | 2018   | 07-2018    | 32486       | 11.89       | 6.19        | 1       | 99.86              |

In July 2018, the composition metric is 11.89, meaning that 11.89% of the client’s customer list interacted with the interest `interest_id` = 32486 - we can link interest_id to a separate mapping table to find the segment name called “Vacation Rental Accommodation Researchers”

The `index_value` is 6.19, means that the composition value is 6.19x the average composition value for all Fresh Segments clients’ customer for this particular interest in the month of July 2018.

The `ranking` and `percentage_ranking` relates to the order of `index_value` records in each month year.

### Interest Map

This mapping table links the `interest_id` with their relevant interest information. You will need to join this table onto the previous `interest_details` table to obtain the interest_name as well as any details about the summary information.

| id | interest_name             | interest_summary                                                                   | created_at          | last_modified       |
|----|---------------------------|------------------------------------------------------------------------------------|---------------------|---------------------|
| 1  | Fitness Enthusiasts       | Consumers using fitness tracking apps and websites.                                | 2016-05-26 14:57:59 | 2018-05-23 11:30:12 |
| 2  | Gamers                    | Consumers researching game reviews and cheat codes.                                | 2016-05-26 14:57:59 | 2018-05-23 11:30:12 |
| 3  | Car Enthusiasts           | Readers of automotive news and car reviews.                                        | 2016-05-26 14:57:59 | 2018-05-23 11:30:12 |
| 4  | Luxury Retail Researchers | Consumers researching luxury product reviews and gift ideas.                       | 2016-05-26 14:57:59 | 2018-05-23 11:30:12 |
| 5  | Brides & Wedding Planners | People researching wedding ideas and vendors.                                      | 2016-05-26 14:57:59 | 2018-05-23 11:30:12 |
| 6  | Vacation Planners         | Consumers reading reviews of vacation destinations and accommodations.             | 2016-05-26 14:57:59 | 2018-05-23 11:30:13 |
| 7  | Motorcycle Enthusiasts    | Readers of motorcycle news and reviews.                                            | 2016-05-26 14:57:59 | 2018-05-23 11:30:13 |
| 8  | Business News Readers     | Readers of online business news content.                                           | 2016-05-26 14:57:59 | 2018-05-23 11:30:12 |
| 12 | Thrift Store Shoppers     | Consumers shopping online for clothing at thrift stores and researching locations. | 2016-05-26 14:57:59 | 2018-03-16 13:14:00 |
| 13 | Advertising Professionals | People who read advertising industry news.                                         | 2016-05-26 14:57:59 | 2018-05-23 11:30:12 |

## Table of Contents

[Introduction](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#introduction)

[Case Study Questions](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#case-study-questions)

[Data Exploration and Cleansing](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#data-exploration-and-cleansing)

[1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#1-update-the-fresh_segmentsinterest_metrics-table-by-modifying-the-month_year-column-to-be-a-date-data-type-with-the-start-of-the-month)

[2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#2-what-is-count-of-records-in-the-fresh_segmentsinterest_metrics-for-each-month_year-value-sorted-in-chronological-order-earliest-to-latest-with-the-null-values-appearing-first)

[3. What do you think we should do with these null values in the fresh_segments.interest_metrics?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#3-what-do-you-think-we-should-do-with-these-null-values-in-the-fresh_segmentsinterest_metrics)

[4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#4-how-many-interest_id-values-exist-in-the-fresh_segmentsinterest_metrics-table-but-not-in-the-fresh_segmentsinterest_map-table-what-about-the-other-way-around)

[5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#5-summarise-the-id-values-in-the-fresh_segmentsinterest_map-by-its-total-record-count-in-this-table)

[6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#6-what-sort-of-table-join-should-we-perform-for-our-analysis-and-why-check-your-logic-by-checking-the-rows-where-interest_id--21246-in-your-joined-output-and-include-all-columns-from-fresh_segmentsinterest_metrics-and-all-columns-from-fresh_segmentsinterest_map-except-from-the-id-column)

[7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#7-are-there-any-records-in-your-joined-table-where-the-month_year-value-is-before-the-created_at-value-from-the-fresh_segmentsinterest_map-table-do-you-think-these-values-are-valid-and-why)

[Interest Analysis](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#interest-analysis)

[1. Which interests have been present in all month_year dates in our dataset?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#1-which-interests-have-been-present-in-all-month_year-dates-in-our-dataset)

[2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#2-using-this-same-total_months-measure---calculate-the-cumulative-percentage-of-all-records-starting-at-14-months---which-total_months-value-passes-the-90-cumulative-percentage-value)

[3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#3-if-we-were-to-remove-all-interest_id-values-which-are-lower-than-the-total_months-value-we-found-in-the-previous-question---how-many-total-data-points-would-we-be-removing)

[4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#4-does-this-decision-make-sense-to-remove-these-data-points-from-a-business-perspective-use-an-example-where-there-are-all-14-months-present-to-a-removed-interest-example-for-your-arguments---think-about-what-it-means-to-have-less-months-present-from-a-segment-perspective)

[5. After removing these interests - how many unique interests are there for each month?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#5-after-removing-these-interests---how-many-unique-interests-are-there-for-each-month)

[Segment Analysis](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#segment-analysis)

[1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#1-using-our-filtered-dataset-by-removing-the-interests-with-less-than-6-months-worth-of-data-which-are-the-top-10-and-bottom-10-interests-which-have-the-largest-composition-values-in-any-month_year-only-use-the-maximum-composition-value-for-each-interest-but-you-must-keep-the-corresponding-month_year)

[2. Which 5 interests had the lowest average ranking value?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#2-which-5-interests-had-the-lowest-average-ranking-value)

[3. Which 5 interests had the largest standard deviation in their percentile_ranking value?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#3-which-5-interests-had-the-largest-standard-deviation-in-their-percentile_ranking-value)

[4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#4-for-the-5-interests-found-in-the-previous-question---what-was-minimum-and-maximum-percentile_ranking-values-for-each-interest-and-its-corresponding-year_month-value-can-you-describe-what-is-happening-for-these-5-interests)

[5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#5-how-would-you-describe-our-customers-in-this-segment-based-off-their-composition-and-ranking-values-what-sort-of-products-or-services-should-we-show-to-these-customers-and-what-should-we-avoid)

[Index Analysis](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#index-analysis)

[1. What is the top 10 interests by the average composition for each month?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#1-what-is-the-top-10-interests-by-the-average-composition-for-each-month)

[2. For all of these top 10 interests - which interest appears the most often?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#2-for-all-of-these-top-10-interests---which-interest-appears-the-most-often)

[3. What is the average of the average composition for the top 10 interests for each month?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#3-what-is-the-average-of-the-average-composition-for-the-top-10-interests-for-each-month)

[4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#4-what-is-the-3-month-rolling-average-of-the-max-average-composition-value-from-september-2018-to-august-2019-and-include-the-previous-top-ranking-interests-in-the-same-output-shown-below)

[5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?](https://github.com/muryulia/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution.md#5-provide-a-possible-reason-why-the-max-average-composition-might-change-from-month-to-month-could-it-signal-something-is-not-quite-right-with-the-overall-business-model-for-fresh-segments)
