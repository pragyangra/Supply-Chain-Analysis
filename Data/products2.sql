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
(SELECT A.*, B.city, D.category,
STR_TO_DATE(SUBSTRING(A.order_placement_date, LOCATE(',', A.order_placement_date) + 2), '%M %e, %Y')
AS order_placement_dates
FROM fmcg.fact_order_lines A
LEFT JOIN 
fmcg.dim_customers B
USING(customer_id)
LEFT JOIN 
fmcg.dim_products D
USING(product_id))C)

SELECT category,
SUM(in_full) / COUNT(in_full) AS LIFR,
SUM(delivery_qty)/SUM(order_qty) AS VOFR
FROM tmp
GROUP BY category;
