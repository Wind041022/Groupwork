library(dplyr)

setwd("E:\\当期复习\\旅游业\\代码\\气温预测final\\2025测试")

data <- read.csv("preprocessed_data.csv", stringsAsFactors = FALSE)

pca_cols <- c("Pressure_1", "Pressure_2", "Dew_point_1", "Dew_point_2", "Avg_Temp_1", "Avg_Temp_2")

pca_data <- data[, pca_cols]

pca_model <- prcomp(pca_data, center = TRUE, scale. = TRUE)

cat("\n=== PCA 降维 Summary 报告 ===\n")
print(summary(pca_model))

cat("\n=== PCA 载荷矩阵 (Rotation) ===\n")
print(pca_model$rotation)

pca_scores <- as.data.frame(pca_model$x)

cols_to_remove <- c(pca_cols)

final_data <- data %>%
  select(-any_of(cols_to_remove)) %>%
  bind_cols(pca_scores)

write.csv(final_data, "PCA_data.csv", row.names = FALSE)

cat("\n数据处理完成！包含PCA新列的数据已保存为 PCA_data.csv\n")
