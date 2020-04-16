## function

sigmoid <- function(x){
  1/(1+exp(-x))
}

# 0-1
normalization<-function(x){
  return ((x-min(x))/(max(x)-min(x)))
}

# z-score
# zscore <- scale(data,center=T,scale=T)

# save csv
save_csv <- function(file_name, df){
  save_path = file.path(data_path, file_name, fsep = .Platform$file.sep)
  write.csv(df,file=save_path,quote=F,row.names = F)
}



confirmed_by_day_with_influence <- function(infection_factor, latent_period, generation_gap, init_confirmed, data, 
                             day, start_day, end_day){
  # slice data
  slice_data <- data %>%
    filter(date >= start_day) %>%
    filter(date <= end_day)
  # initial confirmed
  sum_confirmed <- slice_data$actual[1]
  # calculate infect gap
  infect_gap <- latent_period - generation_gap
  
  # superparameter
  # k=0.0139    
  # m=4.1067
  #
  k=0.0350
  m=4.8454
  
  confirmed_list <-numeric(0)
  for (i in 1:(nrow(slice_data))) {
    period <- (day%/%infect_gap) + 1
    # if(period>8){
    #   period <- 8
    # }
    day <- day + 1
    # calculate factor by fs_scale
    fs_scale <- slice_data$fs_scale[i]
    # version 1
    # if(fs_scale > 0){
    #   factor <- infection_factor/(fs_scale+1)
    # }else if (fs_scale < 0){
    #   factor <- infection_factor - fs_scale
    # }else{
    #   factor <- infection_factor
    # }
    # version 2
    # factor <- 6/(1+exp(1)**fs_scale)
    factor <- 2*m/(1+exp(1)**fs_scale)

    # calculate confirmed in a day
    # version1: confirmed_in_day = (1/ infect_gap) * (factor ** period)
    # version2:
    confirmed_in_day = (1/(k*day+m)) * (factor ** (day/(k*day+m)))
    
    # append this data into confirmed list
    confirmed_list <- c(confirmed_list, sum_confirmed)
    # calulate the sum of confirmed
    sum_confirmed <- sum_confirmed + confirmed_in_day
  }
  confirmed_list
}