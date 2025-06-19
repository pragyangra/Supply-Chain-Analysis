WITH tmp AS
(select *,
DATE_SUB(order_placement_dates, INTERVAL WEEKDAY(order_placement_dates) DAY) AS WEEK,
DATEDIFF(actual_delivery_dates, agreed_delivery_dates) AS diff,
CASE WHEN delivery_qty <> order_qty THEN 0
ELSE 1 END AS in_full,
CASE WHEN 
actual_delivery_dates > 
agreed_delivery_dates 
THEN 0
ELSE 1 END AS on_time
FROM
(SELECT A.*, 
STR_TO_DATE(SUBSTRING(A.agreed_delivery_date, LOCATE(',', A.agreed_delivery_date) + 2), '%M %e, %Y') AS agreed_delivery_dates,
STR_TO_DATE(SUBSTRING(A.actual_delivery_date, LOCATE(',', A.actual_delivery_date) + 2), '%M %e, %Y') AS actual_delivery_dates,
B.city,
STR_TO_DATE(SUBSTRING(A.order_placement_date, LOCATE(',', A.order_placement_date) + 2), '%M %e, %Y')
AS order_placement_dates
FROM fmcg.fact_order_lines A
LEFT JOIN 
fmcg.dim_customers B
USING(customer_id))C)


SELECT diff, category,
count(*) as orders
FROM tmp
GROUP BY diff, category;
