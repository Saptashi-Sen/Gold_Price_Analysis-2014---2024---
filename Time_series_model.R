# Title: Daily Gold Price (2015-2024) Time Series
# Content: Daily gold prices (2014-01-01 to 2024-10-31)
# Acknowledgements
# Raw Data Source: MCX Market
# This data frame is preprocessed to time series analysis and forecasting

gp = read_csv("Gold Price.csv")

# Ensure chronological order
gp = gp %>% arrange(as.Date(Date, format = "%Y-%m-%d"))
gp$Date = as.Date(gp$Date)
ts_gold = zoo(gp$Price, order.by = gp$Date)
monthly_avg = aggregate(ts_gold, as.yearmon, mean)
ts_monthly = ts(coredata(monthly_avg), frequency = 12)
stl_result = stl(ts_monthly, s.window = "periodic")

# Extract components
gp_stl = data.frame(
  Date = as.Date(time(ts_monthly)),
  Price = as.numeric(ts_monthly),
  Trend = as.numeric(stl_result$time.series[, "trend"]),
  Seasonal = as.numeric(stl_result$time.series[, "seasonal"]),
  Residual = as.numeric(stl_result$time.series[, "remainder"]),
  Deseasonalized = as.numeric(ts_monthly - stl_result$time.series[, "seasonal"])
)
# Plot Deseasonalized Series and Trend
ggplot(gp_stl, aes(x = Date)) +
  geom_line(aes(y = Deseasonalized), color = "blue", linetype = "dashed") +
  geom_line(aes(y = Trend), color = "red", size = 1) +
  labs(title = "Gold Price - Deseasonalized Series with Trend", x = "Date", y = "Price")  
  

#ADF Test for Stationarity
adf_result= adf.test(gp_stl$Residual, alternative = "stationary")
print(adf_result)

if (adf_result$p.value <= 0.05 && adf_result$statistic <= -2.9) {
  cat("Reject null — Residuals are stationary\n")
} else {
  cat("Fail to reject null — Residuals may be non-stationary\n")
}
#ACF and PACF Plots
acf(gp_stl$Residual, lag.max = 40, main = "ACF of Residuals")
pacf(gp_stl$Residual, lag.max = 20, main = "PACF of Residuals")


#ACF Table:
max_lag = 20
lags = 1:max_lag

# Ljung–Box Q-stats for each lag
q_stats = sapply(lags, function(lag) Box.test(gp_stl$Residual, lag = lag, type = "Ljung-Box")$statistic)

# Critical chi-square values at 5% significance
chi_sq_critical = qchisq(0.95, df = lags)

# Combine in a table
acf_chisq_gp = data.frame(
  Lag = lags,
  `Q-Statistic` = round(q_stats, 4),
  `Chi-Square Critical (0.05)` = round(chi_sq_critical, 4),
  `Reject H0 (Q > χ²)` = q_stats > chi_sq_critical
)

print(acf_chisq_gp)

# Compute PACF Table:
pacf_result = pacf(gp_stl$Residual, lag.max = 20, plot = FALSE)

# Length of residuals for test statistic scaling
n = length(gp_stl$Residual)

# Extract values and compute test statistics
pacf_vals = pacf_result$acf
lags = pacf_result$lag
test_stats = pacf_vals * sqrt(n)
critical_value = 1.96

pacf_df = data.frame(
  Lag = lags,
  PACF = round(pacf_vals, 4),
  `Test Statistic (ϕₖ×√n)` = round(test_stats, 4),
  `Significant at 5%` = abs(test_stats) > critical_value
)
print(pacf_df)
#So the model is AR(2)

adf.test(gp_stl$Deseasonalized)  # ADF test for stationarity
gp_diff = diff(gp_stl$Deseasonalized)
ar_model = arima(gp_diff, order = c(2, 0, 0))

# Residuals from AR(2) model
resid_ar2 = residuals(ar_model)

# Ljung–Box test at multiple lags
ljung_diag = sapply(1:20, function(lag) {
  test = Box.test(resid_ar2, lag = lag, type = "Ljung-Box")
  c(Q = test$statistic, p = test$p.value)
})

# Format results as a table
ljung_df= as.data.frame(t(ljung_diag))
ljung_gp = data.frame(
  Lag = 1:20,
  Q_Statistic = round(ljung_df$Q, 4),
  P_Value = round(ljung_df$p, 4),
  Reject_H0 = ljung_df$p < 0.05
)

print(ljung_gp)

#conclusion:
#P-values are all >0.05, do not reject for all lags.
#That is there is no significant autocorrelation left in the reseduals.
# So, the residuals behave like White Noise which suggests AR(2) Model is a good fit to the differenced deseasonalized data.




