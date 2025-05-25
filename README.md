# Gold Price Time Series Analysis (2014–2024)

## Overview
This project performs time series decomposition and stationarity analysis on **daily gold prices** from 2015 to 2024, sourced from MCX market data. The analysis involves STL decomposition, ADF testing, autocorrelation diagnostics, and AR(2) model specification to understand price trends and enable forecasting.

---

## Dataset Description
- **Source**: MCX Market
- **Range**: 2014-01-01 to 2024-10-31
- **Variable Used**: Daily closing `Price`

---

## Methodology

### 1. Preprocessing
- Converted date column to proper `Date` format.
- Aggregated daily data to **monthly averages** for stable decomposition.

### 2. STL Decomposition
Used the `stl()` function in R to break down the monthly series into:
- **Trend**
- **Seasonality**
- **Residuals**

### 3. Stationarity Check
- Applied **ADF Test** on the residuals.
- If residuals failed stationarity, differencing was applied to `Deseasonalized` series.

### 4. ACF & PACF Analysis
- Computed and plotted **ACF** and **PACF** of residuals.
- Created statistical significance tables for both (e.g., Ljung–Box Q-tests, PACF Z-tests).

### 5. AR Model Specification
- Based on PACF, identified AR(2) structure.
- Fitted **AR(2) model** on differenced deseasonalized data.

### 6. Residual Diagnostics
- Performed **Ljung–Box test** at lags 1–20.
- Residuals showed no significant autocorrelation → White noise confirmed.

---

## 🧠 Conclusion

- The gold price series shows **clear seasonality and trend**, which were isolated via STL.
- **AR(2)** model was found to be a good fit for the differenced deseasonalized data.
- **Residual diagnostics confirmed model adequacy** — no autocorrelation left.
- This model can be used for short-term forecasting with confidence.

---

## Tools & Libraries
- `R`, `ggplot2`, `forecast`, `tseries`, `zoo`, `stats`
- Analysis written entirely in R script: `Time_series_model.R`

---

## 📌 Future Enhancements
- Extend model to include **exogenous variables** (e.g., oil price, USD index)
- Integrate **automatic ARIMA** selection (`auto.arima`)
- Deploy a Shiny dashboard for interactive time series exploration.
