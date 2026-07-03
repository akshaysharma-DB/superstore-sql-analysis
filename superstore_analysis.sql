-- =========================================
-- SUPERSTORE SQL ANALYSIS PROJECT
-- =========================================
-- Author: Akshay Sharma
-- Dataset: Superstore Sales (Kaggle) - ~9,800 orders
-- Tools: MySQL 8.0
--
-- Table schema (orders):
-- Row_ID, Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID,
-- Customer_Name, Segment, Country, City, State, Postal_Code, Region,
-- Product_ID, Category, Sub_Category, Product_Name, Sales, Quantity,
-- Discount, Profit
-- =========================================


-- =========================================
-- BEGINNER: Aggregations & Grouping
-- =========================================

-- Q1: Total sales and profit by region
select region, sum(sales) as Total_sales,
sum(profit) as Total_profit from orders
group by region
order by Total_sales desc;
-- Insight:
-- - West region drives the highest revenue (~₹7.25L) and profit (~₹1.08L)
-- - Central generates ~₹5L in sales but converts far less into profit — signaling inefficiency

-- Add on Question - Most Efficient region?
Select region, sum(sales) as Total_sales,
sum(Profit) as Total_profit,
Round(sum(Profit) *100 / sum(sales) ,2) as Profit_prcnt
from orders 
group by region 
order by Profit_prcnt desc;
-- Insight:
-- - West is the most efficient region (14.94% margin) — nearly double Central's rate (7.92%)
-- - Central has the 2nd-highest sales volume but the worst profit margin
-- - Suggests excessive discounting or high costs are eroding profit in Central

-- Q2: Total sales and profit by category and which category has highest profit margin?
select Category, sum(sales) as Total_sales,
sum(profit) as Total_profit, 
Round(sum(Profit) *100 / sum(sales) ,2) as Profit_margin from orders
group by Category
order by profit_margin desc;
-- Insight:
-- - Furniture generates almost as much revenue as Technology (~₹7.42L vs ~₹8.36L)
-- - Furniture converts only 2.49% into profit vs ~17% for Technology and Office Supplies
-- - Likely driven by high shipping costs or excessive discounting
-- - Worth flagging as a business risk area

-- Q3: Top 10 best-selling products by revenue
select product_name, Sum(sales) as Total_revenue
from orders
group by Product_Name
order by Total_revenue desc
limit 10;
-- Insight:
-- - Canon imageCLASS 2200 Advanced Copier is the top-selling product (₹61,599.83)
-- - It generates more than 2x the revenue of the #2 product
-- - Technology items dominate the top 10 (Canon, Cisco, HP)
-- - Confirms Technology's high margins (from Q2) are backed by high-value individual sales, not just volume

-- Q4: Number of orders per customer segment
SELECT COUNT(quantity) AS total_orders, segment
FROM orders
GROUP BY segment
ORDER BY total_orders DESC;
-- Insight:
-- Consumer segment leads with 5,191 orders, nearly 3x more than Home Office.
-- Corporate follows with 3,020 orders, sitting between the two extremes.
-- Home Office has the lowest volume at 1,783 orders, suggesting fewer but possibly larger-value transactions.

-- Q5: Sub-categories operating at a loss (negative profit)
SELECT Sub_Category, SUM(profit) AS Total_profit
FROM orders
GROUP BY Sub_Category
HAVING Total_profit < 0
ORDER BY Total_profit;
-- Insight:
-- Tables is the biggest loss-making sub-category, losing ₹17,725.59 overall.
-- Bookcases also operate at a loss, though far smaller at ₹3,472.56.
-- Supplies rounds out the list with the smallest loss at ₹1,188.99.
-- These three sub-categories may need pricing, discount, or cost review since they actively drag down overall profit.

-- Q6: Total number of unique customers
Select count(distinct(customer_id)) as Unique_customers from orders
--There are total 793 unique customers.

-- Q7: Average order value (Sales/Order)
 Select Round( sum(sales)/Count( distinct order_id), 2) as Avg_order_value 
from orders;
--Insights:
-- Average order value is 458.61 .

-- Q8: Most frequently used shipping mode
SELECT ship_mode, COUNT(*) AS Order_count
FROM orders
GROUP BY ship_mode
ORDER BY Order_count DESC;
-- Insight:
-- Standard Class is by far the most used shipping mode, with 5,968 orders — more than 3x every other mode combined.
-- Second Class follows at 1,945 orders, a significant drop from Standard.
-- First Class and Same Day are the least used, at 1,538 and 543 orders respectively.
-- This suggests most customers prioritize cost/convenience over speed, and Same Day shipping is a niche option.

-- =========================================
-- INTERMEDIATE: Joins, Subqueries, HAVING
-- =========================================

-- Q9: Customers who ordered more than 5 times (repeat customers)
SELECT Customer_ID, COUNT(DISTINCT order_id) AS Order_count
FROM orders
GROUP BY Customer_ID
HAVING Order_count > 5
ORDER BY order_count DESC;
-- we didn't use customer_name because two customers can have same name.
-- Insight:
-- Customer EP-13915 is the most frequent repeat buyer with 17 distinct orders, well ahead of everyone else.
-- A large group of customers (CK-12205, EA-14035, JE-15745, NS-18640, PG-18820, SH-19975, ZC-21910) share the second tier at 13 orders each.
-- The presence of many customers above the 5-order threshold points to strong repeat purchase behavior rather than one-off buyers.

-- Q10: Products profitable in one region but loss-making in another
SELECT rp.Product_name,
       MIN(rp.Total_profit) AS Min_profit,
       SUBSTRING_INDEX(GROUP_CONCAT(rp.region ORDER BY rp.Total_profit ASC), ',', 1) AS Min_profit_region,
       MAX(rp.Total_profit) AS Max_profit,
       SUBSTRING_INDEX(GROUP_CONCAT(rp.region ORDER BY rp.Total_profit DESC), ',', 1) AS Max_profit_region
FROM (
    SELECT Product_name, region, SUM(profit) AS Total_profit
    FROM orders
    GROUP BY Product_name, region
) AS rp
GROUP BY rp.Product_name
HAVING MIN(rp.Total_profit) < 0 AND MAX(rp.Total_profit) > 0
ORDER BY rp.Product_name;
-- Insight:
-- 539 products are profitable in one region while losing money in another — a large share of the catalog behaves inconsistently across regions.
-- The 3.6 Cubic Foot Counter Height Office Refrigerator shows one of the widest swings: a loss of ₹1,378.82 in Central versus a profit of ₹412.47 in West.
-- Central and South repeatedly show up as loss-making regions across multiple products, while West is frequently the profitable region — pointing to a regional pattern rather than isolated product issues.
-- With over 500 products affected, this looks like a structural/regional problem (shipping cost, discount policy, competition) rather than a handful of bad products.




-- Q11: Average discount per category vs average profit
SELECT Category, 
       ROUND(SUM(profit) / COUNT(DISTINCT order_id), 2) AS Avg_profit,
       ROUND(SUM(discount) / COUNT(DISTINCT order_id), 2) AS Avg_discount
FROM orders
GROUP BY category;
-- Insight:
-- Technology has the highest average profit per order (₹94.21) despite having the lowest average discount (0.16) — strong pricing power with minimal discounting.
-- Furniture has the lowest average profit per order (₹10.46) even though its discount (0.21) is close to Office Supplies — heavy discounting is likely eating into margins here.
-- Office Supplies sits in the middle for profit (₹32.73) but carries the highest average discount (0.25), suggesting this category relies more on discounts to drive sales.
-- Overall, higher discounts tend to correlate with lower average profit — Furniture and Office Supplies both discount more and earn less per order than Technology.


-- Q12: Monthly sales trend across full date range
SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS Month, SUM(Sales) AS Monthly_Sales
FROM orders
GROUP BY Month
ORDER BY Month;
-- Insight:
-- - Nov and Dec are consistently the strongest months every year (holiday season)
-- - Nov 2018 (₹1,18,447.81) is the highest single month in the entire 4-year dataset
-- - February is consistently the weakest month every year — a recurring post-holiday slump
-- - September shows a smaller but consistent seasonal spike each year
-- - Year-over-year growth is visible (e.g., Dec sales grew from ₹69.5K in 2015 to ₹96.9K in 2017)
-- - 2018 is the strongest year overall, showing the business is trending upward
-- - Predictable seasonality (low Feb, high Nov-Dec) could guide inventory and staffing planning.


-- Q13: Which state/city generates highest sales
SELECT State, city, SUM(Sales) AS Total_Sales
FROM orders
GROUP BY State, city
ORDER BY Total_Sales DESC
LIMIT 10;
-- Insight:
-- New York City is the top-performing city by far, generating ₹2,56,368.12 in sales.
-- Los Angeles follows in second place with ₹1,75,851.33, about 31% lower than New York City.
-- California appears three times in the top 10 (Los Angeles, San Francisco, San Diego), making it the strongest state overall by city coverage, not just a single hub.
-- The gap between the top city (New York City) and the 10th city (Jacksonville, ₹39,133.36) is massive — nearly a 6.5x difference — showing sales are heavily concentrated in a handful of major metro areas.

-- Q14: Top 5 customers by total spend
SELECT customer_id, SUM(sales) AS Total_spend
FROM orders
GROUP BY Customer_ID
ORDER BY Total_spend DESC
LIMIT 5;
-- Insight:
-- Customer SM-20320 is the highest spender by a wide margin, with ₹25,043.07 in total sales — about 32% more than the second-highest customer.
-- TC-20980 ranks second at ₹19,052.22, followed by RB-19360 at ₹15,117.35.
-- The top 5 customers (SM-20320, TC-20980, RB-19360, TA-21385, AB-10105) together represent a small group driving disproportionately high revenue, making them strong candidates for loyalty or retention-focused strategies.
-- The drop-off from 1st (₹25,043.07) to 5th (₹14,473.57) shows spend is fairly concentrated at the very top rather than evenly spread.

-- Q15: Average shipping delay (Ship_Date - Order_Date) by Ship_Mode
SELECT ship_mode, ROUND(AVG(DATEDIFF(ship_date, order_date)), 2) AS Avg_Delay_days
FROM orders
GROUP BY Ship_Mode
ORDER BY Avg_Delay_days;
-- Insight:
-- Same Day shipping lives up to its name, with an average delay of just 0.04 days — essentially instant.
-- First Class averages 2.18 days, a reasonable jump but still fast.
-- Second Class takes 3.24 days on average, roughly 50% longer than First Class.
-- Standard Class is the slowest at 5.01 days — over 100x slower than Same Day and more than double First Class — consistent with it being the cheapest/default option.

-- Q16: Category with highest average discount
SELECT category, ROUND(AVG(discount), 2) AS Avg_discount
FROM orders
GROUP BY Category
ORDER BY Avg_discount DESC;
-- Insight:
-- Furniture has the highest average discount at 0.17, matching what Q11 showed — heavy discounting that likely explains its low average profit.
-- Office Supplies follows closely at 0.16, also consistent with its Q11 profit numbers.
-- Technology has the lowest average discount at 0.13, reinforcing the earlier finding that it relies least on discounting and still earns the highest profit per order.

-- =========================================
-- ADVANCED: Window Functions & CTEs
-- =========================================

-- Q17: Month-over-month sales growth %
WITH monthly_sales AS (
    SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS Month, SUM(Sales) AS Sales
    FROM orders
    GROUP BY Month
)
SELECT Month, Sales,
    LAG(Sales) OVER (ORDER BY Month) AS Prev_Month_Sales,
    ROUND((Sales - LAG(Sales) OVER (ORDER BY Month)) / LAG(Sales) OVER (ORDER BY Month) * 100, 2) AS Growth_Pct
FROM monthly_sales;
-- Insight:
-- Sales grew strongly through mid-2018, peaking with a 52.29% jump in November 2018 (₹1,18,447.81).
-- Growth was volatile rather than steady — three months (July -14.57%, October -11.48%, December -29.23%) saw sales decline compared to the previous month.
-- December's -29.23% drop is the steepest decline in the period, despite November being the highest sales month — suggesting a strong pre-holiday peak followed by a sharp pullback.
-- Overall the pattern looks seasonal: sales build up through the year with a big surge around September–November, then fall off toward year-end.

-- Q18: Running total of cumulative sales
SELECT Order_Date, Sales,
    SUM(Sales) OVER (ORDER BY Order_Date) AS Running_Total
FROM orders
ORDER BY Order_Date;
-- Insight:
-- Total cumulative sales across the entire dataset reach approximately ₹22,97,201 by the end of the period (Dec 2018).
-- The running total grows in sharp jumps rather than smoothly — e.g. it jumps from ~₹29,757 to ~₹33,717 to ~₹61,824 within just three consecutive days (Mar 16-18, 2015), showing certain days carry disproportionately large single orders.
-- One standout: a single order of ₹22,638.48 on 2015-03-18 alone accounts for a huge chunk of that day's jump — high-value individual transactions can visibly skew the running trend.
-- This 4-year view (2015-2018) shows sales didn't just grow steadily — they compounded through bursts tied to specific big-ticket orders and busy days.

-- Q19: Rank customers by total spend within each region
SELECT Region, Customer_Name, SUM(Sales) AS Total_Spend,
    RANK() OVER (PARTITION BY Region ORDER BY SUM(Sales) DESC) AS Rank_In_Region
FROM orders
GROUP BY Region, Customer_Name
ORDER BY Region, Rank_In_Region;
-- Insight:
-- Sean Miller is the single highest-spending customer across all regions, leading South with ₹23,669.21.
-- Tamara Chand tops Central at ₹18,437.14, followed by a steep drop to Adrian Barton (₹12,181.60) — Central's top spot is dominated by one clear outlier.
-- Raymond Buch leads West at ₹14,345.28, and Tom Ashbrook leads East at ₹13,723.50 — both notably lower than


-- Q20: Top 3 products per category by sales
WITH ranked AS (
    SELECT Category, Product_Name, SUM(Sales) AS Total_Sales,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY SUM(Sales) DESC) AS rnk
    FROM orders
    GROUP BY Category, Product_Name
)
SELECT * FROM ranked WHERE rnk <= 3;
-- Insight:
-- The Canon imageCLASS 2200 Advanced Copier is the single best-selling product overall, generating ₹61,599.83 — nearly 3x its category runner-up.
-- Technology's top 3 products dwarf the other categories in raw sales value (₹18,839–₹61,599), while Furniture's top 3 sit in the ₹12,995–₹21,870 range — showing Technology drives disproportionately high per-product revenue.
-- Interestingly, the Cisco TelePresence System (₹22,638.48) appearing here matches the same high-value order flagged earlier in Q18's running total spike on 2015-03-18 — likely a single large bulk purchase.
-- Office Supplies' top performers are dominated by binding/punch equipment (Fellowes, GBC x2), suggesting business/office equipment sub-categories outsell everyday consumables even within Office Supplies.

-- Q21: Year-over-year sales comparison
SELECT YEAR(Order_Date) AS Year, SUM(Sales) AS Total_Sales
FROM orders
GROUP BY Year
ORDER BY Year;
-- Insight:
-- Sales dipped slightly in 2016 (₹4,70,532.46) compared to 2015 (₹4,84,247.56), a small decline of about 2.8%.
-- 2017 saw a strong rebound with ₹6,09,205.86 in sales, a roughly 29.5% jump over 2016 — the biggest year-over-year growth in the dataset.
-- 2018 continued the upward trend, reaching ₹7,33,215.19, a further 20.4% increase over 2017.
-- Overall, the business grew nearly 51% from 2015 to 2018, despite a brief slowdown in year two — suggesting the dip in 2016 was temporary rather than a sign of decline.


-- Q22: Customer cohort analysis (first purchase month vs retention)
WITH first_purchase AS (
    SELECT Customer_ID, MIN(DATE_FORMAT(Order_Date, '%Y-%m')) AS Cohort_Month
    FROM orders
    GROUP BY Customer_ID
),
orders_with_cohort AS (
    SELECT o.Customer_ID, f.Cohort_Month, DATE_FORMAT(o.Order_Date, '%Y-%m') AS Order_Month
    FROM orders o
    JOIN first_purchase f ON o.Customer_ID = f.Customer_ID
)
SELECT Cohort_Month, Order_Month, COUNT(DISTINCT Customer_ID) AS Active_Customers
FROM orders_with_cohort
GROUP BY Cohort_Month, Order_Month
ORDER BY Cohort_Month, Order_Month;
-- Insight:
-- The 2015-01 cohort started with 32 new customers in their first month, but activity dropped sharply to just 3 in month two — a common early drop-off pattern seen in cohort analysis.
-- Despite the early drop, this same cohort shows customers still active nearly 4 years later (2018-09 to 2018-12), proving some early customers become long-term repeat buyers rather than one-time purchasers.
-- Activity for the 2015-01 cohort isn't steadily declining — it fluctuates (e.g. a jump to 11 active customers in 2017-09, then 9 in 2018-09/2018-10), suggesting seasonal buying patterns or reactivation campaigns rather than pure attrition.
-- This kind of cohort view is valuable for retention strategy: it shows the business isn't just acquiring one-time buyers, but retaining a meaningful subset of customers across multiple years.


-- Q23: Percentage contribution of each region to total company sales
SELECT Region, SUM(Sales) AS Region_Sales,
    ROUND(SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER (), 2) AS Pct_Of_Total
FROM orders
GROUP BY Region;
-- Insight:
-- West is the largest contributor, generating ₹7,25,457.93 — nearly a third (31.58%) of total company sales.
-- East follows at 29.55% (₹6,78,781.36), meaning West and East together account for over 61% of all sales.
-- South is the smallest contributor at just 17.05% (₹3,91,721.90), less than half of West's share.
-- Central sits in between at 21.82% — combined with South, these two regions make up under 39% of total sales, showing revenue is heavily concentrated in West and East.

-- Q24: Most profitable order in each category
WITH ranked_orders AS (
    SELECT Category, Order_ID, SUM(Profit) AS Order_Profit,
        RANK() OVER (PARTITION BY Category ORDER BY SUM(Profit) DESC) AS rnk
    FROM orders
    GROUP BY Category, Order_ID
)
SELECT * FROM ranked_orders WHERE rnk = 1;
-- Insight:
-- Technology contains the single most profitable order in the entire dataset, order CA-2017-118689, earning ₹8,399.98 in profit.
-- Office Supplies' top order (CA-2017-117121, ₹4,946.37) earns nearly 5x more than Furniture's top order (CA-2016-117086, ₹1,013.13) — even though Q5 showed Furniture and Office Supplies both struggle with loss-making sub-categories overall.
-- This confirms a pattern seen throughout the project: Technology consistently produces the highest-value outcomes (highest average profit in Q11, highest top-selling product in Q20, and now the single most profitable order here).
-- Furniture's comparatively low peak-order profit (₹1,013.13) reinforces it as the weakest-performing category across nearly every metric analyzed in this project.







