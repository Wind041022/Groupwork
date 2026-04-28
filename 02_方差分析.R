library(dplyr)

setwd("E:\\当期复习\\旅游业\\代码\\气温预测final\\2025测试")

data <- read.csv("preprocessed_data.csv", stringsAsFactors = FALSE)

categorical_vars <- c("Year", "Month", "Wind_direction", "Humidity_1", "Wind_Speed_1", "Sunshine_1")

for (var in categorical_vars) {
  if (var %in% names(data)) {
    data[[var]] <- as.factor(data[[var]])
  }
}

if (!dir.exists("output")) {
  dir.create("output")
}

results_df <- data.frame(
  变量 = character(),
  F值 = numeric(),
  P值 = numeric(),
  是否显著 = character(),
  stringsAsFactors = FALSE
)

cat("=========================================\n")
cat("       单因素方差分析 (One-Way ANOVA)    \n")
cat("       探究各分类变量对平均气温的影响    \n")
cat("=========================================\n\n")

for (var in categorical_vars) {
  if (var %in% names(data)) {

    formula_str <- as.formula(paste("Avg_Temp ~", var))

    aov_model <- aov(formula_str, data = data)
    aov_summary <- summary(aov_model)

    cat(sprintf("--- 目标变量: Avg_Temp vs 分类变量: %s ---\n", var))
    print(aov_summary)
    cat("\n")

    f_value <- aov_summary[[1]][["F value"]][1]
    p_value <- aov_summary[[1]][["Pr(>F)"]][1]

    is_sig <- ifelse(p_value < 0.001, "显著 (***)",
                     ifelse(p_value < 0.01, "显著 (**)",
                            ifelse(p_value < 0.05, "显著 (*)", "不显著")))

    results_df <- rbind(results_df, data.frame(
      变量 = var,
      F值 = round(f_value, 4),
      P值 = signif(p_value, 4),
      是否显著 = is_sig
    ))
  }
}

write.csv(results_df, "output/方差分析_ANOVA汇总.csv", row.names = FALSE)

cat("分析完成！各变量的显著性汇总结果已保存到 'output/方差分析_ANOVA汇总.csv'\n")
