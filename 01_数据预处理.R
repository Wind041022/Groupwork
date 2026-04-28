library(readxl)
library(dplyr)
library(lubridate)

setwd("E:\\当期复习\\旅游业\\代码\\气温预测final\\2025测试")

data <- read_excel("气象数据.xlsx", sheet = "Sheet1")

data$Rainfall[data$Rainfall == "VST"] <- 0
data$Rainfall <- as.numeric(data$Rainfall)

data$Wind_Speed <- suppressWarnings(as.numeric(as.character(data$Wind_Speed)))
data$Wind_Speed[is.na(data$Wind_Speed)] <- 0

data$Sunshine <- suppressWarnings(as.numeric(as.character(data$Sunshine)))
data$Sunshine[is.na(data$Sunshine)] <- 0

data <- na.omit(data)

data$Date <- as.Date(data$Date, format = "%Y/%m/%d")

data <- data %>%
  mutate(
    Year = year(Date),
    Month = month(Date),
    Day = day(Date),
    Yday = yday(Date)
  )

data <- data %>%
  mutate(
    Humidity = case_when(
      Humidity >= 30 & Humidity < 50  ~ "Low",
      Humidity >= 50 & Humidity < 70  ~ "midium",
      Humidity >= 70 & Humidity < 90  ~ "high",
      Humidity >= 90 & Humidity <= 110 ~ "super high",
      TRUE ~ as.character(Humidity)
    ),

    Wind_Speed = case_when(
      Wind_Speed >= 0 & Wind_Speed < 11 ~ "Low",
      Wind_Speed >= 11 & Wind_Speed <= 50 ~ "high",
      TRUE ~ as.character(Wind_Speed)
    ),

    Sunshine = paste0("Sun_", Sunshine)
  )

new_data <- data.frame()

for (i in 3:nrow(data)) {
  current_date <- data$Date[i]
  current_avg_temp <- data$Avg_Temp[i]
  current_Year <- data$Year[i]
  current_Month <- data$Month[i]
  current_Day <- data$Day[i]
  current_Yday <- data$Yday[i]
  current_direction <- data$Wind_direction[i]

  prev_data1 <- data[i-1, ]
  prev_data2 <- data[i-2, ]

  new_row <- data.frame(
    Date = current_date,
    Avg_Temp = current_avg_temp,
    Wind_direction = current_direction,
    Wind_Speed_1 = prev_data1$Wind_Speed,
    Sunshine_1 = prev_data1$Sunshine,
    Pressure_1 = prev_data1$Pressure,
    Humidity_1 = prev_data1$Humidity,
    Avg_Temp_1 = prev_data1$Avg_Temp,
    Dew_point_1 = prev_data1$Dew_point,
    Pressure_2 = prev_data2$Pressure,
    Avg_Temp_2 = prev_data2$Avg_Temp,
    Dew_point_2 = prev_data2$Dew_point,
    Year = current_Year,
    Month = current_Month,
    Day = current_Day,
    Yday = current_Yday
  )

  new_data <- rbind(new_data, new_row)
}

saveRDS(new_data, file = "preprocessed_data.rds")
write.csv(new_data, file = "preprocessed_data.csv", row.names = FALSE)

