

library(dplyr)
library(corrplot)

setwd("E:\\当期复习\\旅游业\\代码\\气温预测final\\2025测试")

data <- read.csv("preprocessed_data.csv", stringsAsFactors = FALSE)

selected_vars <- c( "Pressure_1", "Avg_Temp_1", "Dew_point_1",
                    "Pressure_2", "Avg_Temp_2", "Dew_point_2", "Yday")

cor_data <- data[, selected_vars]

cor_matrix <- cor(cor_data, use = "complete.obs")

if (!dir.exists("output")) {
  dir.create("output")
}

png("output/变量相关性图.png", width = 800, height = 800, res = 120)

corrplot(cor_matrix,
         method = "circle",
         type = "full",
         tl.col = "red",
         tl.srt = 90,
         addgrid.col = "gray",
         col = colorRampPalette(c("#8B0000", "white", "#00008B"))(200))

dev.off()

cat("\n=== 相关系数绝对值 > 0.5 的变量组合 ===\n")

var_names <- colnames(cor_matrix)
n_vars <- length(var_names)

for (i in 1:(n_vars - 1)) {
  for (j in (i + 1):n_vars) {
    cor_val <- cor_matrix[i, j]
    if (!is.na(cor_val) && abs(cor_val) > 0.5) {
      cat(sprintf("%-15s 与 %-15s : %8.4f\n", var_names[i], var_names[j], cor_val))
    }
  }
}

cat("\n相关性图绘制完成！已保存到 output/变量相关性图.png\n")

