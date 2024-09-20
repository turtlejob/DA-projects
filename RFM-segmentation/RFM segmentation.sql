create database Project;
USE Project;

CREATE TABLE SALES_SAMPLE_DATA (
ORDERNUMBER DECIMAL (8, 0),
QUANTITYORDERED DECIMAL (8,2),
PRICEEACH DECIMAL (8,2),
ORDERLINENUMBER DECIMAL (3, 0),
SALES DECIMAL (8,2),
ORDERDATE VARCHAR (16),
STATUS VARCHAR (16),
QTR_ID DECIMAL (1,0),
MONTH_ID DECIMAL (2,0),
YEAR_ID DECIMAL (4,0),
PRODUCTLINE VARCHAR (32),
MSRP DECIMAL (8,0),
PRODUCTCODE VARCHAR (16),
CUSTOMERNAME VARCHAR (32),
PHONE VARCHAR (16),
ADDRESSLINE1 VARCHAR (64),
ADDRESSLINE2 VARCHAR (64),
CITY VARCHAR (16),
STATE VARCHAR (16),
POSTALCODE VARCHAR (16),
COUNTRY VARCHAR (24),
TERRITORY VARCHAR (24),
CONTACTLASTNAME VARCHAR (16),
CONTACTFIRSTNAME VARCHAR (16),
DEALSIZE VARCHAR (10)
);

SELECT * FROM SALES_SAMPLE_DATA LIMIT 10;
select count(*) from SALES_SAMPLE_DATA; -- 2761 records
select count(distinct CUSTOMERNAME) FROM SALES_SAMPLE_DATA;

-- Checking unique values
select distinct status from SALES_SAMPLE_DATA;
select distinct year_id from SALES_SAMPLE_DATA;
select distinct PRODUCTLINE from SALES_SAMPLE_DATA;
select distinct COUNTRY from SALES_SAMPLE_DATA;
select distinct DEALSIZE from SALES_SAMPLE_DATA;
select distinct TERRITORY from SALES_SAMPLE_DATA; 


SELECT distinct MONTH_ID FROM SALES_SAMPLE_DATA WHERE YEAR_ID= 2005 ORDER BY 1;

-- SALES BY PRODUCTLINE

SELECT PRODUCTLINE, ROUND(SUM(SALES),2) as 
FROM SALES_SAMPLE_DATA 
GROUP BY PRODUCTLINE 
ORDER BY 2 DESC; -- classic cars with highest sales 

-- ANALYSIS
-- Let's start by grouping sales by productline

select PRODUCTLINE, ROUND(sum(sales),0) AS Revenue, COUNT(DISTINCT ORDERNUMBER) AS NO_OF_ORDERS
from SALES_SAMPLE_DATA
group by PRODUCTLINE
order by 3 desc; -- though ships have more # of sales but planes had more revenue in less # of sales

select YEAR_ID, sum(sales) Revenue
from SALES_SAMPLE_DATA
group by YEAR_ID
order by 2 desc;

select DEALSIZE, sum(sales) Revenue
from SALES_SAMPLE_DATA
group by DEALSIZE
order by 2 desc; -- medium dealsize showed highest revenue

-- What was the best month for sales in a specific year? How much was earned that month?
select MONTH_ID, sum(sales) Revenue, count(ORDERNUMBER) Frequency
from SALES_SAMPLE_DATA
where YEAR_ID = 2004 -- change year to see the rest
group by MONTH_ID
order by 2 desc; -- November seems to be the month, what product do they sell in November, Classic I believe from the following query

select MONTH_ID, PRODUCTLINE, sum(sales) Revenue, count(ORDERNUMBER)
from SALES_SAMPLE_DATA
where YEAR_ID = 2004 and MONTH_ID = 11 -- change year to see the rest
group by MONTH_ID, PRODUCTLINE
order by 3 desc;
/* Just practiced date conversion. Not necessary for this project
SELECT DATE_FORMAT(STR_TO_DATE(ORDERDATE, '%d/%m/%y'), '%Y-%m-%d') AS
converted_date from SALES_SAMPLE_DATA;

SELECT ORDERDATE, converted_date FROM SALES_SAMPLE_DATA LIMIT 5;

SELECT STR_TO_DATE(ORDERDATE, '%d/%m/%y') 
FROM SALES_SAMPLE_DATA;

SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) AS LATESTDATE 
FROM SALES_SAMPLE_DATA; -- Latest date: 2005-05-31

SELECT MIN(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) AS EARLIESTDATE 
FROM SALES_SAMPLE_DATA; -- Earliest date: 2003-01-06
*/

SELECT DATEDIFF(MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')), MIN(STR_TO_DATE(ORDERDATE, '%d/%m/%y'))) AS date_difference 
FROM SALES_SAMPLE_DATA;

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
SELECT * FROM rfm_segment limit 10;

-- Distinct RFM score categories
SELECT COUNT(DISTINCT rfm_score_category) FROM rfm_segment;

-- Customers with RFM score category '444'
SELECT * FROM rfm_segment WHERE rfm_score_category = '444';

-- Customer segmentation based on RFM scores
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