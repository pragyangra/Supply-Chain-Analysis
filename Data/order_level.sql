select *,
in_full and on_time as in_full_time
FROM
(select order_id, customer_id, product_id, order_qty, delivery_qty, city, customer_name, category,
STR_TO_DATE(SUBSTRING(actual_delivery_date, LOCATE(',', actual_delivery_date) + 2), '%M %e, %Y') AS actual_delivery_date,
STR_TO_DATE(SUBSTRING(agreed_delivery_date, LOCATE(',', agreed_delivery_date) + 2), '%M %e, %Y') AS agreed_delivery_date,
STR_TO_DATE(SUBSTRING(order_placement_date, LOCATE(',', order_placement_date) + 2), '%M %e, %Y') AS order_placement_date,
CASE WHEN delivery_qty <> order_qty THEN 0
ELSE 1 END AS in_full,
CASE WHEN 
STR_TO_DATE(SUBSTRING(actual_delivery_date, LOCATE(',', actual_delivery_date) + 2), '%M %e, %Y') > 
STR_TO_DATE(SUBSTRING(agreed_delivery_date, LOCATE(',', agreed_delivery_date) + 2), '%M %e, %Y') 
THEN 0
ELSE 1 END AS on_time
FROM
(SELECT A.*, B.city, B.customer_name, D.category
FROM fmcg.fact_order_lines A
LEFT JOIN 
fmcg.dim_customers B
USING(customer_id)
LEFT JOIN 
fmcg.dim_products D
USING(product_id))C)E
