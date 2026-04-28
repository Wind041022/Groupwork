library(dplyr)

setwd("E:\\当期复习\\旅游业\\代码\\气温预测final\\2025测试")

data <- read.csv("preprocessed_data.csv", stringsAsFactors = FALSE)

categorical_vars <- c("Month","Wind_direction","Sunshine_1","Wind_Speed_1","Humidity_1")

for (var in categorical_vars) {
  if (var %in% names(data)) {
    data[[var]] <- as.factor(data[[var]])
  }
}

if (!dir.exists("output")) {
  dir.create("output")
}

train_data <- data[data$Year %in% 2021:2024, ]
test_data <- data[data$Year == 2025, ]

continuous_vars <- c("Avg_Temp_1", "Avg_Temp_2", "Pressure_1", "Pressure_2", "Dew_point_1", "Dew_point_2")

all_terms <- c(continuous_vars, categorical_vars)
mlr_formula <- as.formula(
  paste("Avg_Temp ~", paste(all_terms, collapse = " + "))
)

model_mlr <- lm(mlr_formula, data = train_data)

summary(model_mlr)

saveRDS(model_mlr, "output/mlr_model.rds")
saveRDS(train_data, "output/train_data_mlr.rds")
saveRDS(test_data, "output/test_data_mlr.rds")

