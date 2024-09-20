
# RFM Segmentation using MySQL





## What is RFM?

RFM segmentation is a marketing analysis method that involves analyzing customer behavior based on three key factors: **recency**, **frequency**, and **monetary value**.

## Objectives

The objectives of RFM segmentation are:

1.**Segment customers** based on purchasing behavior.  
2.**Tailor marketing strategies** to different customer groups.  
3.**Improve retention** by identifying loyal and at-risk customers. 
4.**Boost customer lifetime value** through targeted actions.  
5.Maximize **marketing ROI** by focusing on high-value segments.

Here I also did some EDA to better understand the dataset.

## Tools Used 

<img src="https://github.com/user-attachments/assets/bc7fb9e6-3b0b-4ac6-9026-cbbadd36d8e7" width="200" height="200">

```sql
-- summary of records
select count(*) from SALES_SAMPLE_DATA;                             -- 2761 records
select count(distinct CUSTOMERNAME) FROM SALES_SAMPLE_DATA;         -- 89

-- Checking unique values
select distinct status from SALES_SAMPLE_DATA;                     -- Shipped,Disputed,In Process,Cancelled,On Hold,Resolved
select distinct year_id from SALES_SAMPLE_DATA;                    -- 2003,2004,2005
select distinct PRODUCTLINE from SALES_SAMPLE_DATA;                -- 7
select distinct COUNTRY from SALES_SAMPLE_DATA;                    -- 19 distinct countries
select distinct DEALSIZE from SALES_SAMPLE_DATA;                   -- 3
select distinct TERRITORY from SALES_SAMPLE_DATA;                  -- 4
```
### Total Sales and Number of orders by Productline
```sql
SELECT PRODUCTLINE, ROUND(SUM(SALES),2) 
FROM SALES_SAMPLE_DATA 
GROUP BY PRODUCTLINE 
ORDER BY 2 DESC; -- classic cars with highest sales 
```
### Output:
![image](https://github.com/user-attachments/assets/adfbc452-31cb-4546-9511-543f7b276beb)

### Finding the difference between 1st and last order
```sql
SELECT DATEDIFF(MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')), MIN(STR_TO_DATE(ORDERDATE, '%d/%m/%y'))) AS date_difference 
FROM SALES_SAMPLE_DATA;
```
### Output: 876

## CODE for RFM:
```sql
CREATE VIEW rfm_segment AS
WITH CTE1 AS(
	SELECT
		CUSTOMERNAME,
		ROUND(SUM(sales), 0) AS MonetaryValue,
		ROUND(AVG(sales), 0) AS AvgMonetaryValue,
		COUNT(DISTINCT ORDERNUMBER) AS Frequency,
		MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%Y')) AS last_order_date,
		(SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%Y')) FROM SALES_SAMPLE_DATA) AS max_order_date,
		DATEDIFF(
		  (SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%Y')) FROM SALES_SAMPLE_DATA), 
		  MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%Y'))
		) AS Recency
	  FROM SALES_SAMPLE_DATA
	  GROUP BY CUSTOMERNAME),
rfm_calc as(      
	select C.*,
	NTILE(4) OVER (order by Recency DESC) rfm_recency,
	NTILE(4) OVER (order by Frequency ASC) rfm_frequency,
	NTILE(4) OVER (order by MonetaryValue ASC) rfm_monetary
	from CTE1 C)
SELECT
  R.*,
  (rfm_recency + rfm_frequency + rfm_monetary) AS rfm_total_score,
  CONCAT(CAST(rfm_recency AS CHAR), CAST(rfm_frequency AS CHAR), CAST(rfm_monetary AS CHAR)
  ) AS rfm_score_category
FROM rfm_calc R;

-- Querying RFM segments
SELECT * FROM rfm_segment;
```
## OUTPUT:

![image](https://github.com/user-attachments/assets/f949a1a5-6a6f-403a-9d0b-f87623431e82)

### Distinct RFM score categories
```sql
SELECT COUNT(DISTINCT rfm_score_category) 
FROM rfm_segment;
```
### Output: 30

## Customer segmentation based on RFM scores
```sql
SELECT CUSTOMERNAME, rfm_score_category,
  CASE
    WHEN rfm_score_category IN ('111', '112', '121', '122', '123', '132', '211', '212', '114', '141') THEN 'lost_customers'
    WHEN rfm_score_category IN ('133', '134', '143', '244', '334', '343', '344', '144') THEN 'slipping away, cannot lose'
    WHEN rfm_score_category IN ('311', '411', '331','113') THEN 'new customers'
    WHEN rfm_score_category IN ('222', '231', '221', '223', '233', '322','242') THEN 'potential churners'
    WHEN rfm_score_category IN ('323', '333', '321', '341', '422', '332', '432','441','431') THEN 'active'
    WHEN rfm_score_category IN ('433', '434', '443', '444') THEN 'loyal'
    ELSE 'Other'
  END AS Customer_Segment
FROM rfm_segment;
```

## Output:
![image](https://github.com/user-attachments/assets/44394a68-415e-4b1d-945a-79d35ac3b14f)

## Conclusion
- From out analysis we can recommend the marketing team to focus on developing a customized plan to target customers who are active and loyal. To re-engage customers who are slipping away, the marketing team can send them personalized messages with enticing offers.
- Customers who have already churned may not respond as effectively to marketing efforts. However, by focusing on the right customer groups, the marketing team can optimize their strategies and achieve better results.
