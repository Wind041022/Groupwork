library(dplyr)
library(mgcv)

setwd("E:\\当期复习\\气温预测")

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

smooth_vars <- c("Avg_Temp_1", "Pressure_2", "Dew_point_1", "Yday")

linear_vars <- c("Avg_Temp_2", "Pressure_1", "Dew_point_2")

categorical_vars <- c("Month","Wind_direction","Sunshine_1","Wind_Speed_1","Humidity_1")

smooth_terms <- paste0("s(", smooth_vars, ")")
param_terms  <- c(linear_vars, categorical_vars)

all_terms <- c(smooth_terms, param_terms)
gam_formula <- as.formula(
  paste("Avg_Temp ~", paste(all_terms, collapse = " + "))
)

model_gam <- gam(gam_formula, data = train_data, select = TRUE)

summary(model_gam)

saveRDS(model_gam, "output/gam_model.rds")

saveRDS(train_data, "output/train_data_gam.rds")
saveRDS(test_data, "output/test_data_gam.rds")

