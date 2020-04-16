

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
# library(rvest)
# library(twitteR)
# library(rtweet)

## path
# set root path
wd <- getwd()
setwd("..\\")
root <- getwd()
setwd(root)

# set data path
data_path = file.path(root, 'resource', 'dataset', fsep = .Platform$file.sep)
convid_by_time_path = file.path(data_path, 'time_series_covid19_confirmed_global.csv', fsep = .Platform$file.sep)
sentiment_path_03 = file.path(data_path, '2020-03', 'coronavirus-tweet-summary.csv', fsep = .Platform$file.sep)
sentiment_path_04 = file.path(data_path, '2020-04', 'coronavirus-tweet-summary.csv', fsep = .Platform$file.sep)

# load data
data_convid_by_time <- read.table(file = convid_by_time_path, header = TRUE, sep = ',', 
                                  quote = "", fill = F, strip.white = T)
data_sentiment_03 <- read.table(file = sentiment_path_03, header = TRUE, sep = ',', 
                                  quote = "", fill = F, strip.white = T)
data_sentiment_04 <- read.table(file = sentiment_path_04, header = TRUE, sep = ',', 
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
temp_df$score <- c(c(temp1,data_sentiment$score),data_sentiment_04$score)
temp_df$rs <- c(c(temp1,data_sentiment$rs),data_sentiment_04$rs)
temp_df$fs <- c(c(temp1,data_sentiment$fs),data_sentiment_04$fs)

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
  filter(date < '2020-04-11')

# plot actual increase
ggplot(temp_df_03, aes(x=date)) + 
  geom_point(aes(y=actual_increase)) + 
  geom_line(aes(y=actual_increase, color="actual_increase")) 

# plot fs
ggplot(temp_df_03, aes(x=date)) + 
  geom_point(aes(y=fs)) + 
  geom_line(aes(y=fs, color="fs")) 

# plot fs_scale
# center = True
# temp_df_03$fs_scale <- scale(temp_df_03$fs,center=T,scale=T)
# center = False
temp_df_03$fs_scale <- scale(temp_df_03$fs,center=F,scale=T)
ggplot(temp_df_03, aes(x=date)) + 
  geom_point(aes(y=fs_scale)) + 
  geom_line(aes(y=fs_scale, color="fs_scale")) 


# predict by fs
init_confirmed <- 74
day <- 14
start_day <- '2020-03-01'
end_day <- '2020-04-10'
confirmed_list <- confirmed_by_day_with_influence(basic_infection_factor, latent_period, generation_gap, init_confirmed, temp_df_03, 
                                            day, start_day, end_day)
temp_df_03$fs_predict <- as.integer(confirmed_list)
temp_df_03$predict_increase <- temp_df_03$fs_predict - c(0,temp_df_03$fs_predict)[0:41]


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


# plot actual_increase and fs_predict_increase
ggplot(temp_df_03, aes(x=date)) + 
  geom_point(aes(y=actual_increase), ) + 
  geom_line(aes(y=actual_increase, color="actual_increase"))+
  geom_point(aes(y=predict_increase)) + 
  geom_line(aes(y=predict_increase, color="predict_increase")) +
  # ylim(0, 10**6) +
  # scale_y_continuous(breaks=seq(0, 10, 5)) +
  scale_x_date(labels = date_format("%Y/%m/%d")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))

# center前，预测数值过高
# center后，预测还行，但是还是不够准确：在fs-scale为负的时候








# try linear regression
# there is not a linear relationship between rs,fs and actual_increase
linear_relation <- lm(actual_increase ~ fs+rs,data=temp_df_03)
predict(linear_relation, temp_df_03)
plot(temp_df_03$actual_increase,temp_df_03$fs + temp_df_03$rs,col = "blue",main = "Regression",
     abline(lm(fs+rs~actual_increase, data=temp_df_03)),cex = 1.3,pch = 16,xlab = "actual_increase",ylab = "fs+rs")


# try logistic regression
# most sigmoid(actual_increase) == 1, not a binary problem
# model<-glm(formula = sigmoid(actual_increase) ~ rs+fs,data=temp_df_03,family = binomial('logit'))


# try polynomial regression
model <- lm(actual_increase ~ poly(fs_scale,3), data=temp_df_03)
summary(model)
confint(model, level=0.95)

plot(fitted(model),residuals(model))

predicted.intervals <- predict(model,data.frame(fs_scale=temp_df_03$fs_scale),interval='confidence',
                               level=0.99)

plot(temp_df_03$fs_scale,temp_df_03$actual_increase,col='deepskyblue4',xlab='fs_scale',main='Observed data')
lines(temp_df_03$fs_scale,predicted.intervals[,1],col='green',lwd=3)
lines(temp_df_03$fs_scale,predicted.intervals[,2],col='black',lwd=1)
lines(temp_df_03$fs_scale,predicted.intervals[,3],col='black',lwd=1)
legend("bottomright",c("Observ.","Predicted"), 
       col=c("deepskyblue4","green"), lwd=3)






