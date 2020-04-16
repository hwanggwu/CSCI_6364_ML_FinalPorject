

# library
#install.packages('installr')
# installr::updateR()
# install.packages('rvcheck')
# require(rvcheck)
# rvcheck::update_all()

# install.packages("rvest")
# install.packages("twitteR")
# install.packages("glue")
# library(devtools)
# devtools::install_github("mkearney/rtweet")

library(tidyverse)
library(ggplot2)
library(scales)
library(rvest)
# library(twitteR)
library(rtweet)

## path
# set root path
wd <- getwd()
setwd("..\\")
root <- getwd()
setwd(root)

# set data path
data_path = file.path(root, 'resource', 'dataset', fsep = .Platform$file.sep)
convid_by_time_path = file.path(data_path, 'time_series_covid19_confirmed_global.csv', fsep = .Platform$file.sep)
sentiment_path = file.path(data_path, '2020-03', 'coronavirus-tweet-summary.csv', fsep = .Platform$file.sep)
  

# load data
data_convid_by_time <- read.table(file = convid_by_time_path, header = TRUE, sep = ',', 
                                  quote = "", fill = F, strip.white = T)
data_sentiment <- read.table(file = sentiment_path, header = TRUE, sep = ',', 
                                  quote = "", fill = F, strip.white = T)
col_names <- colnames(data_convid_by_time)
data_american_covid <- data_convid_by_time %>% 
  filter(Country.Region == 'US') %>%
  select(-Province.State, -Country.Region, -Lat, -Long)

# the basic model
basic_infection_factor <- 3
latent_period <- 8 
generation_gap <- 4

confirmed_by_day <- function(infection_factor, latent_period, generation_gap, init_confirmed, day){
  sum_confirmed <- init_confirmed
  infect_gap <- latent_period - generation_gap
  confirmed_list <-numeric(0)
  for (i in 0:(day-1)) {
    # day_in_period <- i%%infect_gap
    period <- (i%/%infect_gap) + 1
    confirmed_in_day = (1/ infect_gap) * (infection_factor ** period)
    # print(c(i,confirmed_in_day,sum_confirmed))
    confirmed_list <- c(confirmed_list, sum_confirmed)
    sum_confirmed <- sum_confirmed + confirmed_in_day
  }
  confirmed_list
}

first_80_day <- confirmed_by_day(infection_factor=basic_infection_factor, 
                                 latent_period=latent_period,generation_gap=generation_gap, 
                                 init_confirmed=1,day = 80)

# format column name 2020-01-22 ~ 2020-04-10
time_range <- seq.Date(from = as.Date("2020-01-22",format = "%Y-%m-%d"), by = "day", length.out = 80)
colnames(data_american_covid) <- time_range

temp_df <- as.data.frame(t(data_american_covid)) 
colnames(temp_df) <- 'actual'
temp_df$predict <- first_80_day
temp_df$date <- as.Date(rownames(temp_df))
temp_df$row_id <- c(1:80)
temp_df$actual_increase <- temp_df$actual - c(0,temp_df$actual)[0:80]

# add score, rs, fs
temp1 <- rep(0,39)
temp2 <- rep(0,10)
temp_df$score <- c(c(temp1,data_sentiment$score),temp2)
temp_df$rs <- c(c(temp1,data_sentiment$rs),temp2)
temp_df$fs <- c(c(temp1,data_sentiment$fs),temp2)

# we can find that the actual confirmed was much less than predicted
ggplot(temp_df, aes(x=date)) + 
  geom_point(aes(y=predict), ) + 
  geom_line(aes(y=predict, color="predict"))+
  geom_point(aes(y=actual)) + 
  geom_line(aes(y=actual, color="actual")) +
  ylim(0, 10**6) +
  # scale_y_continuous(breaks=seq(0, 10, 5)) +
  scale_x_date(labels = date_format("%Y/%m/%d")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))

# look the detail from 02/01 to 03/15
# the actual confirmed and predicting confirmed have similar growth rate
# postpone about 23 days and see the curve
ggplot(temp_df, aes(x=date)) + 
  geom_point(aes(y=predict), ) + 
  geom_line(aes(y=predict, color="predict"))+
  geom_point(aes(y=actual)) + 
  geom_line(aes(y=actual, color="actual")) +
  ylim(0, 10**4) +
  # scale_y_continuous(breaks=seq(0, 10, 5)) +
  scale_x_date(labels = date_format("%Y/%m/%d")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))

# postpone 25days
postpone <- rep(0,25)
predict_post <- c(postpone, first_80_day)[0:80]
temp_df$predict_post <- predict_post
# df[,-which(names(df)%in%c("z","u")]
# temp_df <- subset(temp_df,select=-c(predict_post_23))

# we can see the two curve is overlapped to each other
ggplot(temp_df, aes(x=date)) + 
  geom_point(aes(y=predict_post), ) + 
  geom_line(aes(y=predict_post, color="predict_post"))+
  geom_point(aes(y=actual)) + 
  geom_line(aes(y=actual, color="actual")) +
  ylim(0, 10**4) +
  # scale_y_continuous(breaks=seq(0, 10, 5)) +
  scale_x_date(labels = date_format("%Y/%m/%d")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))

# see from a bigger tange, the two curve are not overlapped from 3/25
ggplot(temp_df, aes(x=date)) + 
  geom_point(aes(y=predict_post), ) + 
  geom_line(aes(y=predict_post, color="predict_post"))+
  geom_point(aes(y=actual)) + 
  geom_line(aes(y=actual, color="actual")) +
  ylim(0, 10**6) +
  # scale_y_continuous(breaks=seq(0, 10, 5)) +
  scale_x_date(labels = date_format("%Y/%m/%d")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))

# see the detail, the acutal confirmed slow down beginning at 03/27
start_date <- as.Date("2020-3-22")
end_date <- max(temp_df$date)
ggplot(temp_df, aes(x=date)) + 
  geom_point(aes(y=predict_post), ) + 
  geom_line(aes(y=predict_post, color="predict_post"))+
  geom_point(aes(y=actual)) + 
  geom_line(aes(y=actual, color="actual")) +
  ylim(0, 10**6) +
  # scale_y_continuous(breaks=seq(0, 10, 5)) +
  scale_x_date(labels = date_format("%Y/%m/%d"), limits = c(start_date, end_date), breaks = date_breaks("days")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))

# find elbew of the actual confirmed
# there are not any elbew
start_date <- as.Date("2020-3-22")
end_date <- max(temp_df$date)
ggplot(temp_df, aes(x=date)) + 
  geom_point(aes(y=actual)) + 
  geom_line(aes(y=actual, color="actual")) +
  scale_x_date(labels = date_format("%Y/%m/%d"), limits = c(start_date, end_date), breaks = date_breaks("days")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))


# plot scattered points
# there is a linear relationship between retweet and favorite  
ggplot(data_sentiment, aes(x = rs, y = fs)) +
  geom_point()

# 
temp_df_03 <- temp_df %>%
  filter(date > '2020-02-29') %>%
  filter(date < '2020-04-01')

# plot actual increase
ggplot(temp_df_03, aes(x=date)) + 
  geom_point(aes(y=actual_increase)) + 
  geom_line(aes(y=actual_increase, color="actual_increase")) 

# plot fs
ggplot(temp_df_03, aes(x=date)) + 
  geom_point(aes(y=fs)) + 
  geom_line(aes(y=fs, color="fs")) 

# plot fs_scale
temp_df_03$fs_scale <- scale(temp_df_03$fs,center=T,scale=T)
ggplot(temp_df_03, aes(x=date)) + 
  geom_point(aes(y=fs_scale)) + 
  geom_line(aes(y=fs_scale, color="fs_scale")) 


# predict by fs
init_confirmed <- 74
day <- 14
start_day <- '2020-03-01'
end_day <- '2020-03-31'
confirmed_list <- confirmed_by_day_with_influence(basic_infection_factor, latent_period, generation_gap, init_confirmed, temp_df_03, 
                                            day, start_day, end_day)
temp_df_03$fs_predict <- integer(confirmed_list)

# plot actual and fs_predict
ggplot(temp_df_03, aes(x=date)) + 
  geom_point(aes(y=fs_predict), ) + 
  geom_line(aes(y=fs_predict, color="fs_predict"))+
  geom_point(aes(y=actual)) + 
  geom_line(aes(y=actual, color="actual")) +
  # ylim(0, 10**6) +
  # scale_y_continuous(breaks=seq(0, 10, 5)) +
  scale_x_date(labels = date_format("%Y/%m/%d")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))



# there is not a linear relationship between rs,fs and actual_increase
linear_relation <- lm(actual_increase ~ fs+rs,data=temp_df_03)
predict(linear_relation, temp_df_03)
plot(temp_df_03$actual_increase,temp_df_03$fs + temp_df_03$rs,col = "blue",main = "Regression",
     abline(lm(fs+rs~actual_increase, data=temp_df_03)),cex = 1.3,pch = 16,xlab = "actual_increase",ylab = "fs+rs")

# moist sigmoid(actual_increase) == 1
# model<-glm(formula = sigmoid(actual_increase) ~ rs+fs,data=temp_df_03,family = binomial('logit'))




# collect the data in range 03/20 ~ 03/24

# crawl web pages -- but failed
html_data <- read_html('https://twitter.com/bbcchinese/status/1238068141995024385')
# https://twitter.com/bbcchinese/status/1249200624727711744

html_content <- html_data %>% 
  html_nodes('div.css-901oao.r-hkyrab') %>% 
  html_text()

# css-901oao r-hkyrab r-1qd0xha r-1blvdjr r-16dba41 r-ad9z0x r-bcqeeo r-bnwqim r-qvutc0

# some tweet id
1238068141995024385
1238068142322192385
1238068141395148801
1238068142288572416
1238068142305431552
1238068142259216384
1238068142552707072
1238068142825336833

# crawl by twitter api
api_key = 'TgHNMa7WZE7Cxi1JbkAMQ'
api_secret = 'SHy9mBMBPNj3Y17et9BF4g5XeqS4y3vkeW24PttDcY'

api_key = '4p0r42c2fG5nRKOe1UbJP1N7W'
api_secret = 'SpHvrzMtUVVxUErjqFPzko90GA7oiDM8NlqOT8FNHy28Av9M9Q'
access_token = '229834223-DXyN4o2rGwaX2N4od3xwCoTIk6JDzgcoQlEtw5Xs'
access_token_secret = '8TsC8azAlYulio8sBWXjwlYbj6SjlLSoyxVPd6KuPDR8N'

token <- create_token(app = "TweeterCatcher",
                      consumer_key = "XYznzPFOFZR2a39FwWKN1Jp41",
                      consumer_secret = "CtkGEWmSevZqJuKl6HHrBxbCybxI1xGLqrD5ynPd9jG0SoHZbD")

token <- create_token(app = "TweeterCatcher",
                      consumer_key = api_key,
                      consumer_secret = api_secret)

setup_twitter_oauth(api_key, api_secret)

data = searchTwitter('littlecaesars',n=1000)








