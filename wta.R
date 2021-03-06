# Imports
library(fpp2)
library(forecast)
library(ggplot2)


dataset_path<-"F:/Phd/Private Project/train_1-slice0.csv"
y_lab<- "Number Vistors Apple page in wikipedia"   # input name of data
Actual_date_interval <- c("2015/07/01","2016/12/31")
Forecast_date_interval <- c("2017/01/01","2017/01/7")
validation_data_days <-7
frequency<-"days"


# Data Preparation
original_data<-read.csv(dataset_path) 
# Apple Page : original_data$Apple_II_zh.wikipedia.org_all.access_spider
# Facebook Page : original_data$Facebook_zh.wikipedia.org_all.access_spider
# Android Page : original_data$Android_zh.wikipedia.org_all.access_spider
# Energy Page : original_data$Energy_zh.wikipedia.org_all.access_spider
input_data<-cumsum(original_data$Apple_II_zh.wikipedia.org_all.access_spider)
rows <- NROW(input_data)
training_data<-input_data[1:(rows-validation_data_days)]
testing_data<-input_data[(rows-validation_data_days+1):rows]
AD<-fulldate<-seq(as.Date(Actual_date_interval[1]),as.Date(Actual_date_interval[2]), frequency)  #input range for actual date
FD<-seq(as.Date(Forecast_date_interval[1]),as.Date(Forecast_date_interval[2]), frequency)  #input range forecasting date
N_forecasting_days<-nrow(data.frame(FD)) 
validation_dates<-tail(AD,validation_data_days)
validation_data_by_name<-weekdays(validation_dates)
forecasting_data_by_name<-weekdays(FD)



# Data Modeling
data_series<-ts(training_data)
model_TBATS<-forecast:::fitSpecificTBATS(data_series,use.box.cox=FALSE, use.beta=TRUE,  seasonal.periods=c(6),use.damping=FALSE,k.vector=c(2))
accuracy(model_TBATS)  # accuracy on training data
# Print Model Parameters
model_TBATS
plot(model_TBATS,main =paste(y_lab))



# Testing Data Evaluation
forecasting_tbats <- predict(model_TBATS, h=N_forecasting_days+validation_data_days)
validation_forecast<-head(forecasting_tbats$mean,validation_data_days)
MAPE_Per_Day<-round(  abs(((testing_data-validation_forecast)/testing_data)*100)  ,3)
paste ("MAPE % For ",validation_data_days,frequency,"by using TBATS Model for  ==> ",y_lab, sep=" ")
MAPE_Mean_All<-paste(round(mean(MAPE_Per_Day),3),"% MAPE ",validation_data_days,frequency,y_lab,sep=" ")
MAPE_TBATS<-paste(round(MAPE_Per_Day,3),"%")
MAPE_TBATS_Model<-paste(MAPE_Per_Day ,"%")
paste (" MAPE that's Error of Forecasting for ",validation_data_days," days in TBATS Model for  ==> ",y_lab, sep=" ")
paste(MAPE_Mean_All,"%")
paste ("MAPE that's Error of Forecasting day by day for ",validation_data_days," days in TBATS Model for  ==> ",y_lab, sep=" ")
data.frame(date_TBATS=validation_dates,validation_data_by_name,actual_data=testing_data,forecasting_TBATS=validation_forecast,MAPE_TBATS_Model)
data.frame(FD,forecating_date=forecasting_data_by_name,forecasting_by_TBATS=tail(forecasting_tbats$mean,N_forecasting_days))
plot(forecasting_tbats)
x1_test <- ts(testing_data, start =(rows-validation_data_days+1) )
lines(x1_test, col='red',lwd=2)
graph<-autoplot(forecasting_tbats,xlab = paste ("Time in  ", frequency , sep=" "),ylab = y_lab)
graph

