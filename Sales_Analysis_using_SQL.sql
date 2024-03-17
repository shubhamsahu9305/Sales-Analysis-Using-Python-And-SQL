CREATE DATABASE Sales_Analysis;
USE Sales_Analysis;

-- REMOVE NULL VALUES FROM DATA


SELECT * FROM all_sales_data WHERE `Product` IS NULL;

DELETE  FROM all_sales_data WHERE `Order ID` IS NULL;


-- DROP INDEX COLUMN


SELECT * FROM all_sales_data;

ALTER TABLE all_sales_data DROP COLUMN `index`;


-- REMOVE DUPLICATE RECORD FROM DATA


ALTER TABLE all_sales_data ADD COLUMN id INT PRIMARY KEY AUTO_INCREMENT;

SELECT * FROM all_sales_data;

WITH cte AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY `Order ID`,
								`Product`,
                                `Quantity Ordered`,
                                `Price Each`,
                                `Order Date`,
                                `Purchase Address` ORDER BY `Order ID`) AS row_num
FROM all_sales_data)
SELECT * FROM cte WHERE row_num>1;

WITH cte AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY `Order ID`,
								`Product`,
                                `Quantity Ordered`,
                                `Price Each`,
                                `Order Date`,
                                `Purchase Address` ORDER BY `Order ID`) AS row_num
FROM all_sales_data)
DELETE FROM all_sales_data
WHERE all_sales_data.`id` in (SELECT cte.`id` FROM cte WHERE row_num>1);


-- REMOVE EXTRA COLUMN HEADER FROM DATA


SELECT * FROM all_sales_data WHERE `Order ID` LIKE "Order ID";

DELETE FROM all_sales_data WHERE `Order ID` LIKE "Order ID";


-- CONVERT COLUMNS IN APPROPRIATE DATATYPE


SELECT * FROM all_sales_data;

SELECT *, str_to_date(`Order Date`,"%m/%d/%Y %H:%i") FROM all_sales_data;

UPDATE all_sales_data SET `Order Date` = str_to_date(`Order Date`,"%m/%d/%Y %H:%i");

ALTER TABLE all_sales_data MODIFY COLUMN `Order ID` INT NOT NULL;
ALTER TABLE all_sales_data MODIFY COLUMN `Quantity Ordered` INT NOT NULL;
ALTER TABLE all_sales_data MODIFY COLUMN `Price Each` FLOAT NOT NULL;
ALTER TABLE all_sales_data MODIFY COLUMN `Order Date` DATETIME NOT NULL;


/*----------------------------- Month wise Total Sales and %age Sales ------------------------------------*/

SELECT monthname(`Order Date`) AS `Month`,
	   round(sum((`Quantity Ordered`*`Price Each`)),2) AS `Total Sales`,
       round(sum((`Quantity Ordered`*`Price Each`))/
            (SELECT sum((`Quantity Ordered`*`Price Each`)) 
             FROM all_sales_data)*100,2) AS `%age Sales`
       FROM all_sales_data
       GROUP BY monthname(`Order Date`)
       ORDER BY sum((`Quantity Ordered`*`Price Each`)) DESC;
       
/*---------------------------- Top Five Month Based on Total Sales ------------------------------*/

WITH month_sales AS
(
SELECT monthname(`Order Date`) AS `Month`,
	   round(sum((`Quantity Ordered`*`Price Each`)),2) AS `Total Sales`,
       round(sum((`Quantity Ordered`*`Price Each`))/
            (SELECT sum((`Quantity Ordered`*`Price Each`)) 
             FROM all_sales_data)*100,2) AS `%age Sales`
       FROM all_sales_data
       GROUP BY monthname(`Order Date`)
),
month_sales_rank AS
(
SELECT *,
       DENSE_RANK() OVER (ORDER BY `Total Sales` DESC) AS `Sales_Rank`
       FROM month_sales
)
SELECT `Month`, `Total Sales`, `%age Sales` 
		FROM month_sales_rank
        WHERE `Sales_Rank`<=5;
        
/*-------------------------------- Month wise Quantity Sold and %age Quantity Sold ----------------------------------*/        

SELECT monthname(`Order Date`) AS `Month`,
	   round(sum(`Quantity Ordered`),2) AS `Total Quantity Sold`,
       round(sum(`Quantity Ordered`)/
            (SELECT sum(`Quantity Ordered`) 
             FROM all_sales_data)*100,2) AS `%age Quantity Sold`
       FROM all_sales_data
       GROUP BY monthname(`Order Date`)
       ORDER BY sum(`Quantity Ordered`) DESC;
       
/*---------------------------- Top Five Months Based on Quantity Sold ------------------------------*/

WITH month_qty_sold AS
(
SELECT monthname(`Order Date`) AS `Month`,
	   round(sum(`Quantity Ordered`),2) AS `Total Quantity Sold`,
       round(sum(`Quantity Ordered`)/
            (SELECT sum(`Quantity Ordered`) 
             FROM all_sales_data)*100,2) AS `%age Quantity Sold`
       FROM all_sales_data
       GROUP BY monthname(`Order Date`)
),
month_qty_sold_rank AS
(
SELECT *,
       DENSE_RANK() OVER (ORDER BY `Total Quantity Sold` DESC) AS `Qty_Sold_Rank`
       FROM month_qty_sold
)
SELECT `Month`, `Total Quantity Sold`, `%age Quantity Sold` 
		FROM month_qty_sold_rank
        WHERE `Qty_Sold_Rank`<=5;

/* Observation : December month is at the top in terms of both total sales and quantity sold. Almost 13.44% sales done on december month.
Also, October, April and November being the 2nd , 3rd and 4th month in terms of both total sales and quantity sold.

Inference : December month sales might be higher due to Christmas and new year.
Also, it is concluded from data that quarter-4 has highest sales.*/

/*---------------------------- City wise Total Sales, Quantity Sold, %age Quantity Sold and %age Sales ------------------------------*/

WITH city_added AS
(
SELECT * , 
CONCAT(SUBSTRING_INDEX(
						SUBSTRING_INDEX(`Purchase Address`,",",-2),
                        ",",
                        1),
	   " (", 
       SUBSTRING(`Purchase Address`,-8,2),")") AS City
FROM all_sales_data
)
SELECT City,
	   round(sum((`Quantity Ordered`*`Price Each`)),2) AS `Total Sales`,
       round(sum((`Quantity Ordered`*`Price Each`))/
            (SELECT sum((`Quantity Ordered`*`Price Each`)) 
             FROM all_sales_data)*100,2) AS `%age Sales`,
	   round(sum(`Quantity Ordered`),2) AS `Total Quantity Sold`,
       round(sum(`Quantity Ordered`)/
            (SELECT sum(`Quantity Ordered`) 
             FROM all_sales_data)*100,2) AS `%age Quantity Sold`
       FROM city_added
       GROUP BY City
       ORDER BY round(sum((`Quantity Ordered`*`Price Each`)),2) DESC;

/*---------------------------- Top Five Cities Based on Quantity Sold ------------------------------*/

WITH city_added AS
(
SELECT * , 
CONCAT(SUBSTRING_INDEX(
						SUBSTRING_INDEX(`Purchase Address`,",",-2),
                        ",",
                        1),
	   " (", 
       SUBSTRING(`Purchase Address`,-8,2),")") AS City
FROM all_sales_data
),
city_sales AS
(
SELECT City,
	   round(sum((`Quantity Ordered`*`Price Each`)),2) AS `Total Sales`,
       round(sum((`Quantity Ordered`*`Price Each`))/
            (SELECT sum((`Quantity Ordered`*`Price Each`)) 
             FROM all_sales_data)*100,2) AS `%age Sales`,
	   round(sum(`Quantity Ordered`),2) AS `Total Quantity Sold`,
       round(sum(`Quantity Ordered`)/
            (SELECT sum(`Quantity Ordered`) 
             FROM all_sales_data)*100,2) AS `%age Quantity Sold`
       FROM city_added
       GROUP BY City
),
city_sales_rank AS 
(
SELECT *,
       DENSE_RANK() OVER (ORDER BY `Total Sales` DESC) AS `Total_Sales_Rank`
       FROM city_sales
)
SELECT `City`, `Total Sales`, `%age Sales`,`Total Quantity Sold`, `%age Quantity Sold` 
		FROM city_sales_rank
        WHERE `Total_Sales_Rank`<=5;
        	
/* Observation : San Francisco is at the top in terms of both total sales and quantity sold. Almost 24.03% sales came from san francisco city.
Also, Los Angeles, New York and Boston being the 2nd , 3rd and 4th city in terms of both total sales and quantity sold.

Inference : These cities will might be the profitable one. Also to increase the likelihood of customer's buying we may 
increase the advertisement or provide offers in these cities.*/


/*-----------------Best Time to Display Advertisements to Maximize the Likelihood of Customer’s Buying Product  ----------------------*/

SELECT HOUR(`Order Date`) AS `Order Hour`, 
	   COUNT(DISTINCT(`Order ID`)) AS `Number of Orders`
	   FROM all_sales_data
	   GROUP BY HOUR(`Order Date`)
	   ORDER BY COUNT(DISTINCT(`Order ID`)) DESC
	   LIMIT 6;

SELECT DAYNAME(`Order Date`) AS `Weekday`,
	   COUNT(DISTINCT(`Order ID`)) AS `Number of Orders`
	   FROM all_sales_data
	   GROUP BY  DAYNAME(`Order Date`)
	   ORDER BY COUNT(DISTINCT(`Order ID`)) DESC
	   LIMIT 3;
       
/*Observation : In all the cities, most of the customers place order between 10:00 A.M to 1:00 P.M and 6:00 P.M to 8:00 P.M.
Also, on tuesday the number of customers is more in comparision to other weekdays.

Inference : These duration will be the best for advertisement.*/


/*------------------------------  Product wise Total Sales and %age Sales ---------------------------------*/

SELECT `Product`,
	   round(sum((`Quantity Ordered`*`Price Each`)),2) AS `Total Sales`,
       round(sum((`Quantity Ordered`*`Price Each`))/
            (SELECT sum((`Quantity Ordered`*`Price Each`)) 
             FROM all_sales_data)*100,2) AS `%age Sales`
       FROM all_sales_data
       GROUP BY `Product`
       ORDER BY sum((`Quantity Ordered`*`Price Each`)) DESC;
       
       
/*---------------------------- Top Five Product Based on Total Sales ------------------------------*/


WITH product_sales AS
(
SELECT `Product`,
	   round(sum((`Quantity Ordered`*`Price Each`)),2) AS `Total Sales`,
       round(sum((`Quantity Ordered`*`Price Each`))/
            (SELECT sum((`Quantity Ordered`*`Price Each`)) 
             FROM all_sales_data)*100,2) AS `%age Sales`
       FROM all_sales_data
       GROUP BY `Product`
),
product_sales_rank AS
(
SELECT *,
       DENSE_RANK() OVER (ORDER BY `Total Sales` DESC) AS `Sales_Rank`
       FROM product_sales
)
SELECT `Product`, `Total Sales`, `%age Sales` 
		FROM product_sales_rank
        WHERE `Sales_Rank`<=5;
        

/*-----------------  Product wise Total Quantity Sold and %age Quantity Sold  ----------------------*/

SELECT `Product`,
	   round(sum(`Quantity Ordered`),2) AS `Total Quantity Sold`,
       round(sum(`Quantity Ordered`)/
            (SELECT sum(`Quantity Ordered`) 
             FROM all_sales_data)*100,2) AS `%age Quantity Sold`
       FROM all_sales_data
       GROUP BY `Product`
       ORDER BY sum(`Quantity Ordered`) DESC;
       
       
/*---------------------------- Top Five Product Based on Quantity Sold ------------------------------*/


WITH product_qty_sold AS
(
SELECT `Product`,
	   round(sum(`Quantity Ordered`),2) AS `Total Quantity Sold`,
       round(sum(`Quantity Ordered`)/
            (SELECT sum(`Quantity Ordered`) 
             FROM all_sales_data)*100,2) AS `%age Quantity Sold`
       FROM all_sales_data
       GROUP BY `Product`
),
product_qty_sold_rank AS
(
SELECT *,
       DENSE_RANK() OVER (ORDER BY `Total Quantity Sold` DESC) AS `Qty_Sold_Rank`
       FROM product_qty_sold
)
SELECT `Product`, `Total Quantity Sold`, `%age Quantity Sold`
		FROM product_qty_sold_rank
        WHERE `Qty_Sold_Rank`<=5;
        
        
/*Observation : AAA and AA Batteries, USB-C Charging Cable, Lightning Cable, Wired Headphones and Apple Airpods 
are among the top 5 best selling Product in terms of quantity sold while Macbook Pro Laptop, iPhone, ThinkPad Laptop,
Google Phone and 27in 4k Gaming Monitor are among the top 5 best selling product in terms of total sales.

Inference : The reason for being the top selling product is because of its lowest price among all the products available.*/


/*----------------------------------- Month on Month Sales Growth % ---------------------------------------*/

WITH monthly_sales AS
(
SELECT month(`Order Date`) AS `Month`,
	   round(sum((`Quantity Ordered`*`Price Each`)),2) AS `Total Sales`,
       round(sum((`Quantity Ordered`*`Price Each`))/
            (SELECT sum((`Quantity Ordered`*`Price Each`)) 
             FROM all_sales_data)*100,2) AS `%age Sales`
       FROM all_sales_data
       GROUP BY month(`Order Date`)
),
monthly_sales_lag AS
(
SELECT *,
		LAG(`Total Sales`,1) OVER (ORDER BY `Month`) AS `Prev Month Sales`
        FROM monthly_sales
)
SELECT  `Month`,
		IFNULL(round(((`Total Sales`/`Prev Month Sales`)-1)*100,2),0) AS `MOM Growth%`
        FROM monthly_sales_lag;
        
        
/*------------------------------  Products Most Often Sold Together ---------------------------------*/

-- TOP 10 PAIR OF TWO PRODUCTS BASED ON ORDER COUNT
WITH product_sold_together AS
(
SELECT `Order ID`, 
		GROUP_CONCAT(`Product`) AS `Product Sold Together`
        FROM all_sales_data
		GROUP BY `Order ID`
		HAVING COUNT(`id`)=2
)
SELECT `Product Sold Together`, COUNT(`Order ID`) AS `Number of Orders`
FROM product_sold_together
GROUP BY `Product Sold Together`
ORDER BY COUNT(`Order ID`) DESC
LIMIT 10;


-- TOP 5 PAIR OF THREE PRODUCTS BASED ON ORDER COUNT
WITH product_sold_together AS
(
SELECT `Order ID`, 
		GROUP_CONCAT(`Product`) AS `Product Sold Together`
        FROM all_sales_data
		GROUP BY `Order ID`
		HAVING COUNT(`id`)=3
)
SELECT `Product Sold Together`, COUNT(`Order ID`) AS `Number of Orders`
FROM product_sold_together
GROUP BY `Product Sold Together`
ORDER BY COUNT(`Order ID`) DESC
LIMIT 5;


/*Inference : The above shown product pair will be helpful to give offers and discounts to the customers.*/
