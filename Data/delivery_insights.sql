WITH tmp AS
(select *,
DATE_SUB(order_placement_dates, INTERVAL WEEKDAY(order_placement_dates) DAY) AS WEEK,
LEFT(order_placement_dates,7) AS MONTH,
CASE WHEN delivery_qty <> order_qty THEN 0
ELSE 1 END AS in_full,
CASE WHEN 
STR_TO_DATE(SUBSTRING(actual_delivery_date, LOCATE(',', actual_delivery_date) + 2), '%M %e, %Y') > 
STR_TO_DATE(SUBSTRING(agreed_delivery_date, LOCATE(',', agreed_delivery_date) + 2), '%M %e, %Y') 
THEN 0
ELSE 1 END AS on_time
FROM
(SELECT A.*, B.city,
STR_TO_DATE(SUBSTRING(A.order_placement_date, LOCATE(',', A.order_placement_date) + 2), '%M %e, %Y')
AS order_placement_dates
FROM fmcg.fact_order_lines A
LEFT JOIN 
fmcg.dim_customers B
USING(customer_id))C)

SELECT city,
ROUND(SUM(in_full)*100 / COUNT(in_full),2) AS full_orders,
ROUND(SUM(on_time)*100 / COUNT(on_time),2) AS timely_orders,
ROUND(SUM(in_full_time)*100 / COUNT(in_full_time),2) AS in_full_time
FROM
(SELECT *,
in_full and on_time as in_full_time
FROM tmp)D
GROUP BY city
