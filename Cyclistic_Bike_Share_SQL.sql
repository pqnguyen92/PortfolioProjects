#Merged all 12 datasets with distinct records:
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.march_2021_data` 
UNION DISTINCT
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.april_2021_data`
UNION DISTINCT
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.may_2021_data` 
UNION DISTINCT
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.june_2021_data`
UNION DISTINCT
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.july_2021_data` 
UNION DISTINCT
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.august_2021_data`
UNION DISTINCT
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.september_2021_data` 
UNION DISTINCT
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.october_2021_data`
UNION DISTINCT
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.november_2021_data` 
UNION DISTINCT
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.december_2021_data`
UNION DISTINCT
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.january_2022_data` 
UNION DISTINCT
SELECT *
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.february_2022_data`


#Data Cleaning Summary:

#Count Null and Non Null vales in merged table, ran query for each field of the table:
SELECT
    SUM(CASE WHEN field_name IS NULL THEN 1 ELSE 0 END) AS Number_Of_Null_Values,
    SUM(CASE WHEN field_name IS NOT NULL THEN 1 ELSE 0 END) AS Number_Of_Non_Null_Values
FROM `cyclistic-bikeshare-case-study.monthly_trip_data.merged_trip_data`


#1. Extracted number month (1-12) from 'started at' field
#2. Extracted the number day of the week from 'started at' field with '1' corresponding to 'Sunday' and '7' corresponding to 'Saturday'
#3. Created total trip duration in minutes column by subtracting 'started at' by 'ended at' field
#4  Created total trip duration in seconds column by subtracting 'started at' by 'ended at' field
#5. Filter out all null values from the dataset
#6. Created a (CTE) common table expression column to display the day of the week names and month names using a CASE statement
#7. Filtered the dataset to view trips where duration is longer than 0 seconds from the CTE
#8. Exported results to new dataset(cleaned_trip_data) for new cleaned table

WITH cte_cleaned_trip_data AS
    (SELECT
        ride_id,rideable_type,started_at,ended_at,start_station_name,end_station_name,member_casual,
        EXTRACT(MONTH FROM started_at) AS number_trip_month,
        EXTRACT(DAYOFWEEK FROM started_at) AS number_day_of_week,
        TIMESTAMP_DIFF(ended_at, started_at, minute) AS trip_duration_minute,
        TIMESTAMP_DIFF(ended_at, started_at, second) AS trip_duration_seconds
    FROM `cyclistic-bikeshare-case-study.monthly_trip_data.merged_trip_data`
    WHERE start_station_name IS NOT NULL
        AND end_station_name IS NOT NULL)
SELECT *,
    CASE
        WHEN number_trip_month = 1 THEN 'January'
        WHEN number_trip_month = 2 THEN 'February'
        WHEN number_trip_month = 3 THEN 'March'
        WHEN number_trip_month = 4 THEN 'April'
        WHEN number_trip_month = 5 THEN 'May'
        WHEN number_trip_month = 6 THEN 'June'
        WHEN number_trip_month = 7 THEN 'July'
        WHEN number_trip_month = 8 THEN 'August'
        WHEN number_trip_month = 9 THEN 'September'
        WHEN number_trip_month = 10 THEN 'October'
        WHEN number_trip_month = 11 THEN 'November'
        WHEN number_trip_month = 12 THEN 'December'
        END AS trip_month,
    CASE
        WHEN number_day_of_week = 1 THEN 'Sunday'
        WHEN number_day_of_week = 2 THEN 'Monday'
        WHEN number_day_of_week = 3 THEN 'Tuesday'
        WHEN number_day_of_week = 4 THEN 'Wednesday'
        WHEN number_day_of_week = 5 THEN 'Thursday'
        WHEN number_day_of_week = 6 THEN 'Friday'
        WHEN number_day_of_week = 7 THEN 'Saturday'
        END AS day_of_week
FROM cte_cleaned_trip_data
WHERE trip_duration_seconds > 0



#Aggregate Data Calculations:

#Total number of casual riders:
SELECT
COUNT(member_casual) AS number_casual
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'casual'



#Total number of members riders:
SELECT
COUNT(member_casual) AS number_member
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'member'



#Total number of casual and members riders:
SELECT
  SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS number_casual,
  SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS number_member
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`



#Find the max, min, average ride duration:
SELECT 
MAX(trip_duration_minute) AS max_trip_duration_min,
MIN(trip_duration_minute) AS min_trip_duration_min,
AVG(trip_duration_minute) AS avg_trip_duration_min
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`




#Find the max, min, average ride duration for casual riders:
SELECT 
MAX(trip_duration_minute) AS max_trip_duration_min,
MIN(trip_duration_minute) AS min_trip_duration_min,
AVG(trip_duration_minute) AS avg_trip_duration_min
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'casual'




#Find the max, min, average ride duration for member riders:
SELECT 
MAX(trip_duration_minute) AS max_trip_duration_min,
MIN(trip_duration_minute) AS min_trip_duration_min,
AVG(trip_duration_minute) AS avg_trip_duration_min
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'member'





#Find average trip duration(minutes) for casual or member riders by day of week in desc order:
SELECT
    member_casual,
    day_of_week,
    AVG(trip_duration_minute) AS avg_trip_duration_min
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'casual'
    OR member_casual = 'member'
GROUP BY day_of_week, member_casual
ORDER BY avg_trip_duration_min DESC



#Find average trip duration(minutes) for casual or member riders by trip month in desc order:
SELECT
    member_casual,
    trip_month,
    AVG(trip_duration_minute) AS avg_trip_duration_min
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'casual' 
    OR member_casual = 'member'
GROUP BY trip_month, member_casual
ORDER BY avg_trip_duration_min DESC



#Find total number of rides by day sorted in descending order:
SELECT 
    day_of_week,
    COUNT(day_of_week) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
GROUP BY day_of_week
ORDER BY total_num_of_rides DESC




#Find total number of rides from casual riders by day sorted in descending order:
SELECT
    member_casual,
    day_of_week,
    COUNT(day_of_week) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
GROUP BY day_of_week, member_casual
WHERE member_casual = 'casual'
ORDER BY total_num_of_rides DESC




#Find total number of rides from member riders by day sorted in descending order:
SELECT
    member_casual,
    day_of_week,
    COUNT(day_of_week) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'member'
GROUP BY day_of_week, member_casual
ORDER BY total_num_of_rides DESC




#Find total number of rides by month in desc order:
SELECT
    trip_month,
    COUNT(trip_month) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
GROUP BY trip_month
ORDER BY total_num_of_rides DESC





#Find total number of rides casual riders by month in desc order:
SELECT
    member_casual,
    trip_month,
    COUNT(trip_month) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'casual'
GROUP BY trip_month, member_casual
ORDER BY total_num_of_rides DESC






#Find total number of rides by member riders by month in desc order:
SELECT
    member_casual,
    trip_month,
    COUNT(trip_month) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'member'
GROUP BY trip_month, member_casual
ORDER BY total_num_of_rides DESC





#Top 10 start station by casual riders and total trips in desc order:
SELECT
    member_casual,
    start_station_name,
    COUNT(start_station_name) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'casual'
GROUP BY start_station_name, member_casual
ORDER BY total_num_of_rides DESC
LIMIT 10



#Top 10 start station by member riders and total trips in desc order:
SELECT
    member_casual,
    start_station_name,
    COUNT(start_station_name) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'member'
GROUP BY start_station_name, member_casual
ORDER BY total_num_of_rides DESC
LIMIT 10



#Top 10 end stations by casual riders and total trips in desc order:
SELECT
    member_casual,
    end_station_name,
    COUNT(end_station_name) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'casual'
GROUP BY end_station_name, member_casual
ORDER BY total_num_of_rides DESC
LIMIT 10



#Top 10 end stations by member riders and total trips in desc order:
SELECT
    member_casual,
    end_station_name,
    COUNT(end_station_name) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'member'
GROUP BY end_station_name, member_casual
ORDER BY total_num_of_rides DESC
LIMIT 10



#Top 10 start & end stations by casual riders and total trips in desc order:
SELECT
    member_casual,
    start_station_name,
    end_station_name,
    COUNT(start_station_name) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'casual'
GROUP BY start_station_name, end_station_name, member_casual
ORDER BY total_num_of_rides DESC
LIMIT 10



#Top 10 start & end stations by member riders and total trips in desc order:
SELECT
    member_casual,
    start_station_name,
    end_station_name,
    COUNT(start_station_name) AS total_num_of_rides
FROM `cyclistic-bikeshare-case-study.cleaned_trip_data.cleaned_trip_data_v1`
WHERE member_casual = 'member'
GROUP BY start_station_name, end_station_name, member_casual
ORDER BY total_num_of_rides DESC
LIMIT 10