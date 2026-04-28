library(dplyr)
library(mgcv)

setwd("E:\\当期复习\\气温预测")

if (!dir.exists("output")) {
  dir.create("output")
}

# #####---MLR
# model_mlr <- readRDS("output/mlr_model.rds")
# train_data <- readRDS("output/train_data_mlr.rds")
# test_data <- readRDS("output/test_data_mlr.rds")
# test_predictions <- predict(model_mlr, newdata = test_data, type = "response")

# #####---MLR_PCA
# model_mlr_PCA <- readRDS("output/mlr_model_PCA.rds")
# train_data <- readRDS("output/train_data_mlr_PCA.rds")
# test_data <- readRDS("output/test_data_mlr_PCA.rds")
# test_predictions <- predict(model_mlr_PCA, newdata = test_data, type = "response")

#####---GAM
model_gam <- readRDS("output/gam_model.rds")
train_data <- readRDS("output/train_data_gam.rds")
test_data <- readRDS("output/test_data_gam.rds")
test_predictions <- predict(model_gam, newdata = test_data, type = "response")

# #####---GAM_PCA
# model_gam_PCA <- readRDS("output/gam_model_PCA.rds")
# train_data <- readRDS("output/train_data_gam_PCA.rds")
# test_data <- readRDS("output/test_data_gam_PCA.rds")
# test_predictions <- predict(model_gam_PCA, newdata = test_data, type = "response")


actual_values <- test_data$Avg_Temp
predicted_values <- test_predictions

mse <- mean((predicted_values - actual_values)^2)
rmse <- sqrt(mse)
mae <- mean(abs(predicted_values - actual_values))
rmse_mae_ratio <- rmse / mae
r_squared <- 1 - (sum((predicted_values - actual_values)^2) / sum((actual_values - mean(actual_values))^2))

evaluation_results <- data.frame(
  指标 = c("MSE", "RMSE", "MAE", "RMSE/MAE", "R²"),
  值 = c(round(mse, 4), round(rmse, 4), round(mae, 4), round(rmse_mae_ratio, 4), round(r_squared, 4))
)

prediction_results <- data.frame(
  Date = test_data$Date,
  Avg_Temp = actual_values,
  Pre_Avg_Temp = predicted_values
)

# #####---MLR
# write.csv(evaluation_results, "output/评估指标_mlr.csv", row.names = FALSE)
# write.csv(prediction_results, "output/预测结果_mlr.csv", row.names = FALSE)

# #####---MLR_PCA
# write.csv(evaluation_results, "output/评估指标_mlr_PCA.csv", row.names = FALSE)
# write.csv(prediction_results, "output/预测结果_mlr_PCA.csv", row.names = FALSE)

#####---GAM
write.csv(evaluation_results, "output/评估指标_gam.csv", row.names = FALSE)
write.csv(prediction_results, "output/预测结果_gam.csv", row.names = FALSE)
# # 
# #####---GAM_PCA
# write.csv(evaluation_results, "output/评估指标_gam_PCA.csv", row.names = FALSE)
# write.csv(prediction_results, "output/预测结果_gam_PCA.csv", row.names = FALSE)
# # 




