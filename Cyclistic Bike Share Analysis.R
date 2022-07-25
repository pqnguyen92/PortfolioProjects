#Cylistic Bike Share Analysis R Code:
#Data cleaning, transformation, visualization steps:


#install packages needed for data cleanup:
install.packages("tidyverse")
install.packages("lubridate")
install.packages("janitor")
install.packages("here")
install.packages("skimr")
install.packages("ggplot2")


#load packages needed for data cleanup:
library(tidyverse)
library(lubridate)
library(janitor)
library(here)
library(skimr)
library(ggplot2)
library(forcats)


#import all 12 .csv files:
marchdf <- read.csv(file.choose())
aprildf <- read.csv(file.choose())
maydf <- read.csv(file.choose())
junedf <- read.csv(file.choose())
julydf <- read.csv(file.choose())
augustdf <- read.csv(file.choose())
septemberdf <- read.csv(file.choose())
octoberdf <- read.csv(file.choose())
novemberdf <- read.csv(file.choose())
decemberdf <- read.csv(file.choose())
januarydf <- read.csv(file.choose())
februarydf <- read.csv(file.choose())

#or:

marchdf <- read.csv("marchtripdata.csv")
aprildf <- read.csv("apriltripdata.csv")
maydf <- read.csv("maytripdata.csv")
junedf <- read.csv("junetripdata.csv")
julydf <- read.csv("julytripdata.csv")
augustdf <- read.csv("augusttripdata.csv")
septemberdf <- read.csv("septtripdata.csv")
octoberdf <- read.csv("octtripdata.csv")
novemberdf <- read.csv("novtripdata.csv")
decemberdf <- read.csv("dectripdata.csv")
januarydf <- read.csv("jantripdata.csv")
februarydf <- read.csv("febtripdata.csv")


#combine all 12 dataframes into one:
total_tripdata <- rbind(marchdf,aprildf,maydf,junedf,julydf,augustdf,
                        septemberdf,octoberdf,novemberdf,decemberdf,januarydf,februarydf)
#5667986 total records


#Remove potential duplicate rows:
total_tripdata <- total_tripdata[!duplicated(total_tripdata), ]


#preview first 6 rows of the dataframe:
head(total_tripdata)
head(total_tripdata_v2)


#view column data types:
compare_df_cols(total_tripdata)



#replace blank values with 'NA':
total_tripdata[total_tripdata == ""]<-NA


#count number of values with 'NA':
sum(is.na(total_tripdata))


#remove all rows containing 'NA':
total_tripdata <- na.omit(total_tripdata)
#4631103 remaining rows, 1036883 rows containing 'NA' removed


#remove columns not needed from data frame:
total_tripdata <- total_tripdata %>%
  select(-c(start_station_id, end_station_id, start_lat, start_lng, 
            end_lat, end_lng))


#create a 'Year-month-date' field:
total_tripdata$Ymd <- as.Date(total_tripdata$started_at)



#'started_at' and 'ended_at' are string data types, convert to datediff:
total_tripdata$started_at <- lubridate::ymd_hms(total_tripdata$started_at)
total_tripdata$ended_at <- lubridate::ymd_hms(total_tripdata$ended_at)



#Calculate trip duration in hours and minutes by finding the time difference
#between started_at and ended_at fields:
total_tripdata$trip_duration_hour <- 
  difftime(total_tripdata$ended_at,total_tripdata$started_at,units = "hours")

total_tripdata$trip_duration_min <- 
  difftime(total_tripdata$ended_at,total_tripdata$started_at,units = "mins")



#filter values where trip duration > 0 min:
total_tripdata_v2 <- total_tripdata %>% filter(trip_duration_min > 0)
#4630904 rows remaining, 199 records removed


#Extract trip month from 'ymd':
total_tripdata_v2$trip_month <- format(total_tripdata_v2$Ymd,"%B")


#Extract trip weekday from 'ymd':
total_tripdata_v2$trip_weekday <- weekdays(total_tripdata_v2$Ymd)



#View df summary:
summary(total_tripdata_v2)
skim_without_charts(total_tripdata_v2)
skim(total_tripdata_v2)
compare_df_cols(total_tripdata_v2)




#Aggregate Calculations:

#Calculate trip duration minimum, max, median, mean by rider type in minutes:
aggregate(total_tripdata_v2$trip_duration_min ~ total_tripdata_v2$member_casual, FUN = min)

aggregate(total_tripdata_v2$trip_duration_min ~ total_tripdata_v2$member_casual, FUN = max)

aggregate(total_tripdata_v2$trip_duration_min ~ total_tripdata_v2$member_casual, FUN = median)

aggregate(total_tripdata_v2$trip_duration_min ~ total_tripdata_v2$member_casual, FUN = mean)



    ##Different format but same results:
    aggregate(total_tripdata_v2$trip_duration_min ~
              total_tripdata_v2$member_casual,total_tripdata_v2,min)
    
    aggregate(total_tripdata_v2$trip_duration_min ~
              total_tripdata_v2$member_casual,total_tripdata_v2,max)
    
    aggregate(total_tripdata_v2$trip_duration_min ~
              total_tripdata_v2$member_casual,total_tripdata_v2,median)
    
    aggregate(total_tripdata_v2$trip_duration_min ~
              total_tripdata_v2$member_casual,total_tripdata_v2,mean)
    
    
    

#Calculate average trip duration by rider type & month in minutes:
aggregate(total_tripdata_v2$trip_duration_min ~
          total_tripdata_v2$member_casual + total_tripdata_v2$trip_month, FUN = mean) 


#Calculate average trip duration by rider type & weekday in minutes:
aggregate(total_tripdata_v2$trip_duration_min ~
          total_tripdata_v2$member_casual + total_tripdata_v2$trip_weekday, FUN = mean)
          



#Total number of trips by rider type and month in descending order:
total_tripdata_v2 %>%
  count(member_casual, trip_month) %>%
  arrange((member_casual),-n) %>%
  rename(total_trip_count = n)


#Total number of trips by rider type and weekday in descending order:
total_tripdata_v2 %>%
  count(member_casual, trip_weekday) %>%
  arrange((member_casual),-n) %>%
  rename(total_trip_count = n) 

#Total number of trips by rider type, month & weekday in descending order:
total_tripdata_v2 %>%
  count(member_casual, trip_month, trip_weekday) %>%
  arrange((member_casual),-n) %>%
  rename(total_trip_count = n) 



#Top 10 start station locations based on total trips by rider type:
total_tripdata_v2 %>%
  count(member_casual, start_station_name) %>%
  group_by(member_casual) %>%
  arrange(-n) %>%
  rename(total_trip_count = n) %>%
  slice(1:10)


#Top 10 end station locations based on total trips by rider type:
total_tripdata_v2 %>%
  count(member_casual, end_station_name) %>%
  group_by(member_casual) %>%
  arrange(-n) %>%
  rename(total_trip_count = n) %>%
  slice(1:10)


#Top 10 start & end station locations based on total trips by rider type: 
#*Note-results based on instances of both the start AND end station locations, not one or the other
total_tripdata_v2 %>%
  count(member_casual, start_station_name, end_station_name) %>%
  group_by(member_casual) %>%
  arrange(-n) %>%
  rename(total_trip_count = n) %>%
  slice(1:10)





#Data Visualizations (ggplot2):


#Bar chart to show total trip count based on weekday, month & rider type:
ggplot(data=total_tripdata_v2) +
  geom_bar(mapping = aes(x = trip_weekday, fill = member_casual)) +
  labs(title = "Trip Count by Weekday and Rider Type", y = "Trip Count", x = "Weekday")

ggplot(data=total_tripdata_v2) +
  geom_bar(mapping = aes(x = trip_month, fill = member_casual)) +
  labs(title = "Trip Count by Month and Rider Type", y = "Trip Count", x = "Month")



#Bar chart to show total trip count based on weekday, month & bike type:
ggplot(data=total_tripdata_v2) +
  geom_bar(mapping = aes(x = trip_weekday, fill = rideable_type)) +
  labs(title = "Trip Count by Weekday and Bike Type", y = "Trip Count", x = "Weekday")

ggplot(data=total_tripdata_v2) +
  geom_bar(mapping = aes(x = trip_month, fill = rideable_type)) +
  labs(title = "Trip Count by Month and Bike Type", y = "Trip Count", x = "Month")



#Facet wrap bar chart to show total trip count based on weekday, month & bike type:
ggplot(data=total_tripdata_v2) +
  geom_bar(mapping = aes(x = trip_weekday, fill = rideable_type)) + 
  facet_wrap(~rideable_type) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Trip Count by Weekday and Bike Type", y = "Trip Count", x = "Weekday") 

  
ggplot(data=total_tripdata_v2) +
  geom_bar(mapping = aes(x = trip_month, fill = rideable_type)) + 
  facet_wrap(~rideable_type) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Trip Count by Month and Bike Type", y = "Trip Count", x = "Month")

  

#Facet wrap bar chart to show total trip count based on weekday, month & rider type:
ggplot(data=total_tripdata_v2) +
  geom_bar(mapping = aes(x = trip_weekday, fill = member_casual)) + 
  facet_wrap(~member_casual) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Trip Count by Weekday and Rider Type", y = "Trip Count", x = "Weekday")


ggplot(data=total_tripdata_v2) +
  geom_bar(mapping = aes(x = trip_month, fill = member_casual)) + 
  facet_wrap(~member_casual) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Trip Count by Month and Rider Type", y = "Trip Count", x = "Month")



#Facet grid bar chart to show total trip count based on weekday, month,
#bike type & rider type:
ggplot(data=total_tripdata_v2) +
  geom_bar(mapping = aes(x = trip_weekday, fill = member_casual)) + 
  facet_grid(rideable_type~member_casual) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Trip Count by Weekday, Rider Type, Bike Type", y = "Trip Count", x = "Weekday")


ggplot(data=total_tripdata_v2) +
  geom_bar(mapping = aes(x = trip_month, fill = member_casual)) +
  facet_grid(rideable_type~member_casual) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Trip Count by Month, Rider Type, Bike Type", y = "Trip Count", x = "Month")


#same as first plot, different format:
ggplot(data=total_tripdata_v2) +
  geom_bar(mapping = aes(x = trip_weekday, fill = rideable_type)) + 
  facet_grid(rideable_type~member_casual) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Trip Count by Weekday, Rider Type, Bike Type", y = "Trip Count", x = "Weekday")




#Facet wrap for Top 10 start station based on total trips by rider type:
#library(forcats)
total_tripdata_v2 %>%
  count(member_casual, start_station_name) %>%
  group_by(member_casual) %>%
  rename(total_trip_count = n) %>%
  mutate(start_station_name = fct_reorder(start_station_name, total_trip_count)) %>%
  arrange(-total_trip_count) %>%
  slice(1:10) %>%
ggplot() + 
  geom_col(aes(x=start_station_name, y=total_trip_count, fill = member_casual)) +
  coord_flip() +
  facet_wrap(~member_casual) +
  labs(title = "Top 10 Start Stations by Rider Type",
       y = "Trip Count", x = "Start Stations")



#Facet wrap for Top 10 start station based on total trips by rider type:
#Added 'position'
total_tripdata_v2 %>%
  count(member_casual, start_station_name) %>%
  group_by(member_casual) %>%
  rename(total_trip_count = n) %>%
  mutate(start_station_name = fct_reorder(start_station_name, total_trip_count)) %>%
  arrange(-total_trip_count) %>%
  slice(1:10) %>%
ggplot(aes(x=start_station_name, y=total_trip_count, fill = member_casual)) + 
  geom_col(position = position_dodge(), width = .6) +
  facet_wrap(~member_casual) +
  coord_flip() +
  labs(title = "Top 10 Start Stations by Rider Type",
       y = "Trip Count", x = "Start Stations")







#Average trip duration by rider type & month in minutes:
#Assign new df for 'avg_tripduration_month'
avg_tripduration_month <- data.frame(aggregate(total_tripdata_v2$trip_duration_min ~
            total_tripdata_v2$member_casual + total_tripdata_v2$trip_month, FUN = mean)) 

avg_tripduration_month %>%
  rename(member_type = total_tripdata_v2.member_casual) %>%
  rename(trip_month = total_tripdata_v2.trip_month) %>%
  rename(trip_duration_min = total_tripdata_v2.trip_duration_min) %>%
  mutate(trip_month = factor(trip_month, levels = month.name)) %>%
  arrange(trip_month) %>%
ggplot(aes(x=trip_month, y=trip_duration_min, fill = member_type)) + 
  geom_col(position = position_dodge(.6), width = .55) +
  labs(title = "Avg Trip Duration by Month",
       y = "Avg Trip Duration (Min)", x = "Trip Month")




  

#Average trip duration by rider type & weekday in minutes:
#Assign new df for 'avg_tripduration_day'
avg_tripduration_day <- data.frame(aggregate(total_tripdata_v2$trip_duration_min ~
            total_tripdata_v2$member_casual + total_tripdata_v2$trip_weekday, FUN = mean))

avg_tripduration_day %>%
  rename(member_type = total_tripdata_v2.member_casual) %>%
  rename(trip_day = total_tripdata_v2.trip_weekday) %>%
  rename(trip_duration_min = total_tripdata_v2.trip_duration_min) %>%
  mutate(trip_day = factor(trip_day, levels = c("Sunday", "Monday", "Tuesday", "Wednesday",
                                                "Thursday", "Friday", "Saturday"))) %>%
  arrange(trip_day) %>%
ggplot(aes(x=trip_day, y=trip_duration_min, fill = member_type)) + 
  geom_col(position = position_dodge(.6), width = .55) +
  labs(title = "Avg Trip Duration by Day",
       y = "Avg Trip Duration (Min)", x = "Trip Day")




