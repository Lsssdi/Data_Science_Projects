-- NUMBER OF WAREHOUSES
SELECT COUNT( DISTINCT warehouseCode) AS warehouse_count
FROM warehouses;

-- GET INFORMATION ABOUT WAREHOUSES
SELECT *
FROM warehouses;

-- NUMBER OF DISTINCT PRODUCTS
SELECT COUNT( DISTINCT(productCode) ) AS number_of_products
FROM products;

-- NUMBER OF PRODUCT LINES
SELECT COUNT( DISTINCT productLine) AS number_of_product_lines
FROM productlines;

-- PRODUCT LINES
SELECT *
FROM productlines
;

-- NUMBER OF ORDERS TO DATE
SELECT COUNT(DISTINCT( orderNumber)) AS number_of_orders
FROM orders
;

-- CHECK THE TYPE OF PRODUCTS EACH WAREHOUSE HAS
SELECT DISTINCT w.warehouseCode, w.warehouseName, w.warehousePctCap, p.productLine
FROM warehouses AS w
LEFT JOIN products AS p
USING(warehouseCode)
;

-- CHECK THE TOTAL QUANTITY OF STOCK  IN EACH WAREHOUSE
SELECT 
	warehouseName,
	SUM(quantityInStock) AS total_stock
FROM warehouses
LEFT JOIN products
USING(warehouseCode)
GROUP BY warehouseName
;

-- WHICH PRODUCTS HAVE NOT BEEN ORDERED
SELECT productName
FROM products
WHERE productCode NOT IN (SELECT productCode FROM orderdetails )
;


DROP TABLE IF EXISTS product_order_counts;

-- CHECK HOW MUCH A PRODUCT IS ORDERED COMPARED TO HOW MUCH IT STOCKED
CREATE TEMPORARY TABLE product_order_counts
SELECT p.productCode, p.productName, p.productLine, IFNULL(oc.order_count, 0) AS total_ordered_quantity, quantityInStock
FROM products AS p
LEFT JOIN
(
SELECT productCode, productName, SUM(quantityOrdered) AS order_count
FROM orderdetails
LEFT JOIN products AS p
USING(productCode)
GROUP BY productCode, productName
ORDER BY order_count
) AS oc
USING(productCode)
;

-- top_overstocked_products = PRODUCTS WHOSE order_percenatge is less than 15 percent
CREATE TEMPORARY TABLE overstocked_products
WITH top_overstocked_products AS
(
SELECT product_order_counts.*,
	total_ordered_quantity / quantityInStock * 100 AS order_percentage 
FROM product_order_counts
WHERE total_ordered_quantity / quantityInStock * 100 <= 15
ORDER BY order_percentage
)
-- LOOK AT WHICH PRODUCTLINE COUNT FOR THE OVERSTOCKED PRODUCTS
SELECT *
FROM top_overstocked_products
ORDER BY order_percentage
;

SELECT *
FROM overstocked_products
WHERE productLine LIKE "%cars%"
;
 
 
 -- CALCULATE THE APPROXIMATE MAX WAREHOUSE CAPACITY
 SELECT
	*,
	ROUND(( total_stock * 100) / warehousePctCap, 0)
    AS  total_warehouseCap
 FROM warehouses
 LEFT JOIN 
	(
	SELECT 
	warehouseName,
	SUM(quantityInStock) AS total_stock
FROM warehouses
LEFT JOIN products
USING(warehouseCode)
GROUP BY warehouseName
) wc -- warehouse capacity
USING(warehouseName)
 ;


WITH profit_by_order AS 
(
SELECT co.orderNumber, p.productCode, p.productName, p.productLine, co.quantityOrdered, co.priceEach,  
		(priceEach - buyPrice) * quantityOrdered AS profit
FROM 
(
SELECT *
FROM orderdetails
WHERE productCode IN (SELECT productCode FROM products WHERE productLine LIKE "%cars%" )
) co -- car orders
LEFT JOIN products AS p
	USING(productCode)
LEFT JOIN orders
	USING(orderNumber)
WHERE status = "Shipped"
)
SELECT productCode, productName, productLine,
	SUM(profit) AS total_profit
FROM profit_by_order
GROUP BY productCode, productName
ORDER BY total_profit DESC
;















