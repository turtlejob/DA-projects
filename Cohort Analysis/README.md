
# Cohort Analysis using MySQL

Cohort analysis is an analytical technique that categorizes and divides data into groups (cohorts), with common characteristics prior to analysis. This technique helps us isolate, analyze, and detect patterns in the lifecycle of a user, to optimize customer retention, and to better understand user behavior in a particular cohort.

## 🎯 Objectives

📦 Group customers by their first purchase month.\
📈 Track repeat customer behavior across months.\
🧠 Understand retention and drop-off patterns.\
💼 Derive actionable insights for marketing and loyalty programs.



## 🧾 SQL Query

```sql
WITH CTE1 AS (
  SELECT
    InvoiceNo, CustomerID,
    STR_TO_DATE(InvoiceDate, "%d/%m/%Y %H:%i") AS InvoiceDate,
    ABS(ROUND(Quantity * UnitPrice, 2)) AS Revenue
  FROM Retail
  WHERE CustomerID IS NOT NULL AND CustomerID <> ''
),
CTE2 AS (
  SELECT 
    InvoiceNo, CustomerID, InvoiceDate,
    DATE_FORMAT(InvoiceDate, '%Y-%m-01') AS Purchase_Month,
    DATE_FORMAT(MIN(InvoiceDate) OVER (PARTITION BY CustomerID ORDER BY InvoiceDate), '%Y-%m-01') AS First_Purchase_Month,
    Revenue
  FROM CTE1
),
CTE3 AS (
  SELECT 
    CustomerID, First_Purchase_Month,
    CONCAT('Month_', 
      PERIOD_DIFF(
        EXTRACT(YEAR_MONTH FROM Purchase_Month),
        EXTRACT(YEAR_MONTH FROM First_Purchase_Month)
      )
    ) AS Cohort_Month
  FROM CTE2
)
SELECT 
  First_Purchase_Month AS Cohort,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_0', CustomerID, NULL)) AS Month_0,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_1', CustomerID, NULL)) AS Month_1,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_2', CustomerID, NULL)) AS Month_2,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_3', CustomerID, NULL)) AS Month_3,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_4', CustomerID, NULL)) AS Month_4,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_5', CustomerID, NULL)) AS Month_5,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_6', CustomerID, NULL)) AS Month_6,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_7', CustomerID, NULL)) AS Month_7,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_8', CustomerID, NULL)) AS Month_8,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_9', CustomerID, NULL)) AS Month_9,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_10', CustomerID, NULL)) AS Month_10,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_11', CustomerID, NULL)) AS Month_11,
  COUNT(DISTINCT IF(Cohort_Month = 'Month_12', CustomerID, NULL)) AS Month_12
FROM CTE3
GROUP BY First_Purchase_Month
ORDER BY First_Purchase_Month;
```

## 📊 Results (Sample Output)

| Cohort     | M0  | M1  | M2  | M3  | M4  | M5  | M6  | M7  | M8  | M9  | M10 | M11 | M12 |
| ---------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2010-12-01 | 948 | 362 | 317 | 367 | 341 | 376 | 360 | 336 | 336 | 374 | 354 | 474 | 260 |
| 2011-01-01 | 421 | 101 | 119 | 102 | 138 | 126 | 110 | 108 | 131 | 146 | 155 | 63  | 0   |
| 2011-02-01 | 380 | 94  | 73  | 106 | 102 | 94  | 97  | 107 | 98  | 119 | 35  | 0   | 0   |
| 2011-03-01 | 440 | 84  | 112 | 96  | 102 | 78  | 116 | 105 | 127 | 39  | 0   | 0   | 0   |
| 2011-04-01 | 299 | 68  | 66  | 63  | 62  | 71  | 69  | 78  | 25  | 0   | 0   | 0   | 0   |
| 2011-05-01 | 279 | 66  | 48  | 48  | 60  | 68  | 74  | 29  | 0   | 0   | 0   | 0   | 0   |
| 2011-06-01 | 235 | 49  | 44  | 64  | 58  | 79  | 24  | 0   | 0   | 0   | 0   | 0   | 0   |
| 2011-07-01 | 191 | 40  | 39  | 44  | 52  | 22  | 0   | 0   | 0   | 0   | 0   | 0   | 0   |
| 2011-08-01 | 167 | 42  | 42  | 42  | 23  | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   |
| 2011-09-01 | 298 | 89  | 97  | 36  | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   |
| 2011-10-01 | 352 | 93  | 46  | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   |
| 2011-11-01 | 321 | 43  | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   |
| 2011-12-01 | 41  | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   | 0   |


## 📌 Insights
2010-12 was the most active cohort in terms of long-term engagement.

Many newer cohorts (like 2011-10, 2011-11) show strong initial numbers (Month_0), but weaker retention in subsequent months.

There is a drop-off in repeat engagement after Month_2 or Month_3 in most cohorts, suggesting the need for stronger post-purchase strategies.

## 🚀 Future Work
Extend cohort analysis to revenue-based retention, not just customer count.

Visualize the cohort matrix using heatmaps in Power BI, Tableau, or Python.

Integrate with marketing campaign data to analyze impact on cohort behavior.

Build customer lifetime value (CLV) models based on cohort trends.
