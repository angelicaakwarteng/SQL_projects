-- checking the sql version I'm using
SELECT VERSION(); 
-- working in database project
USE project;

-- EXPLORING DATASET
-- preview table
SELECT * FROM glare_sales_warehouse;

-- previewing total entries
SELECT COUNT(*) AS TOTAL_ENTRIES FROM glare_sales_warehouse;

-- previewing only columns
SHOW COLUMNS FROM glare_sales_warehouse;

-- renaming column heads as the current one will pose a challenge
ALTER TABLE glare_sales_warehouse RENAME COLUMN `YEAR` TO sales_year;
ALTER TABLE glare_sales_warehouse RENAME COLUMN `MONTH` TO sales_month;
ALTER TABLE glare_sales_warehouse RENAME COLUMN `ITEM CODE` TO item_code;
ALTER TABLE glare_sales_warehouse RENAME COLUMN `ITEM DESCRIPTION` TO item_desc;
ALTER TABLE glare_sales_warehouse RENAME COLUMN `ITEM TYPE` TO item_type;
ALTER TABLE glare_sales_warehouse RENAME COLUMN `RETAIL SALES` TO retail_sales;
ALTER TABLE glare_sales_warehouse RENAME COLUMN `SUPPLIER` TO supplier;
ALTER TABLE glare_sales_warehouse RENAME COLUMN `RETAIL TRANSFERS` TO retail_transfers;
ALTER TABLE glare_sales_warehouse RENAME COLUMN `WAREHOUSE SALES` TO warehouse_sales;

-- checking for missing values for retail sales
SELECT COUNT(*) AS missing_values FROM glare_sales_warehouse WHERE retail_sales IS NULL;

-- previewing column heads again to see if changes applied
SHOW COLUMNS FROM glare_sales_warehouse;

-- previewing years of records in the dataset
SELECT DISTINCT
    sales_year
FROM
    glare_sales_warehouse
ORDER BY sales_year DESC;

-- previewing the sales months in the dataset
SELECT DISTINCT sales_month FROM glare_sales_warehouse ORDER BY sales_month;

-- counting distinct suppliers in the dataset
SELECT COUNT(DISTINCT supplier) FROM glare_sales_warehouse;

-- previewing the distinct suppliers and their item types in the dataset
SELECT DISTINCT supplier FROM glare_sales_warehouse ORDER BY supplier;
SELECT DISTINCT supplier, item_type FROM glare_sales_warehouse ORDER BY item_type;
SELECT DISTINCT supplier, item_type FROM glare_sales_warehouse ORDER BY supplier;

-- counting unique suppliers by item_type
SELECT DISTINCT supplier, COUNT(item_type) FROM glare_sales_warehouse GROUP BY supplier ORDER BY supplier;

-- previewing the distinct suppliers in the dataset
SELECT DISTINCT supplier FROM glare_sales_warehouse;

-- previewing the item types in the dataset
SELECT DISTINCT item_type FROM glare_sales_warehouse;

-- checking item codes by item_type in the dataset
SELECT DISTINCT item_code, item_type FROM glare_sales_warehouse ORDER BY item_type;
SELECT DISTINCT item_code, item_type FROM glare_sales_warehouse ORDER BY item_code;

-- retrieving info on item code = 347939 in the dataset
SELECT * FROM glare_sales_warehouse WHERE item_code = 347939;

-- checking distinct type of item this supplier supplies
SELECT DISTINCT item_type FROM glare_sales_warehouse WHERE supplier = 'REPUBLIC NATIONAL DISTRIBUTING CO';

-- checking distinct type of item this supplier supplied in 2017
SELECT DISTINCT sales_month, item_type FROM glare_sales_warehouse WHERE supplier = 'REPUBLIC NATIONAL DISTRIBUTING CO' AND sales_year='2017'
ORDER BY sales_month;

-- checking item description BY item_types in the dataset
SELECT item_desc, item_type FROM glare_sales_warehouse ORDER BY item_desc;
SELECT item_desc, item_type FROM glare_sales_warehouse ORDER BY item_type;

-- checking retail_sales, transfers and warehouse sales column
SELECT item_type, retail_sales FROM glare_sales_warehouse ORDER BY retail_sales;
SELECT item_type, retail_transfers FROM glare_sales_warehouse ORDER BY retail_transfers;
SELECT item_type, warehouse_sales FROM glare_sales_warehouse ORDER BY warehouse_sales;
SELECT item_type, warehouse_sales FROM glare_sales_warehouse ORDER BY item_type;

-- checking retail sales and warehouse_sales by suppliers and sales year 
SELECT sales_year, supplier, warehouse_sales FROM glare_sales_warehouse ORDER BY supplier;
SELECT sales_year, supplier, retail_sales FROM glare_sales_warehouse ORDER BY supplier, sales_year desc;

-- Creating a new table cleaned_dataset from glare_sales_warehouse
CREATE TABLE cleaned_dataset AS
SELECT * FROM glare_sales_warehouse;

-- preview table cleaned_dataset
SELECT * FROM cleaned_dataset;

SELECT @@sql_safe_updates; -- checking safe mode 1
SET SQL_SAFE_UPDATES = 0;  -- disable safe mode

-- HANDLING EMPTY STRINGS
UPDATE cleaned_dataset SET sales_year = TRIM(sales_year);
UPDATE cleaned_dataset SET sales_month = TRIM(sales_month);
UPDATE cleaned_dataset SET supplier = TRIM(supplier);
UPDATE cleaned_dataset SET item_code = TRIM(item_code);
UPDATE cleaned_dataset SET item_desc = TRIM(item_desc);
UPDATE cleaned_dataset SET item_type = TRIM(item_type);
UPDATE cleaned_dataset SET retail_sales = TRIM(retail_sales);
UPDATE cleaned_dataset SET retail_transfers = TRIM(retail_transfers);
UPDATE cleaned_dataset SET warehouse_sales = TRIM(warehouse_sales);

-- preview all order by supplier
SELECT * FROM cleaned_dataset ORDER BY supplier;

-- since columns are trimmed and still showing blanks, checking with empty string
SELECT * FROM cleaned_dataset WHERE supplier = '';   -- CONFIRMED

-- setting all blanks to NULLS
UPDATE cleaned_dataset SET sales_year = NULL WHERE sales_year = '';
UPDATE cleaned_dataset SET sales_month = NULL WHERE sales_month = '';
UPDATE cleaned_dataset SET supplier = NULL WHERE supplier = '';
UPDATE cleaned_dataset SET item_code = NULL WHERE item_code = '';
UPDATE cleaned_dataset SET item_desc = NULL WHERE item_desc = '';
UPDATE cleaned_dataset SET item_type = NULL WHERE item_type = '';
UPDATE cleaned_dataset SET retail_sales = NULL WHERE retail_sales = '';
UPDATE cleaned_dataset SET retail_transfers = NULL WHERE retail_transfers = '';
UPDATE cleaned_dataset SET warehouse_sales = NULL WHERE warehouse_sales = '';

-- counting null entries in dataset
SELECT COUNT(*) AS total_sales_year_nulls FROM cleaned_dataset WHERE sales_year IS NULL;
SELECT COUNT(*) AS total_sales_month_nulls FROM cleaned_dataset WHERE sales_month IS NULL;
SELECT COUNT(*) AS total_supplier_nulls FROM cleaned_dataset WHERE supplier IS NULL;
SELECT COUNT(*) AS total_item_code_nulls FROM cleaned_dataset WHERE item_code IS NULL;
SELECT COUNT(*) AS total_item_desc_nulls FROM cleaned_dataset WHERE item_desc IS NULL;
SELECT COUNT(*) AS total_item_type_nulls FROM cleaned_dataset WHERE item_type IS NULL;
SELECT COUNT(*) AS total_retail_sales_nulls FROM cleaned_dataset WHERE retail_sales IS NULL;
SELECT COUNT(*) AS total_retail_transfers_nulls FROM cleaned_dataset WHERE retail_transfers IS NULL;
SELECT COUNT(*) AS total_warehouse_sales_nulls FROM cleaned_dataset WHERE warehouse_sales IS NULL;
 
-- checking rows at random to see changes effected
SELECT * FROM cleaned_dataset WHERE supplier IS NULL; 

-- setting threshold 
SELECT COUNT(*) * 0.05 AS total_threshold, COUNT(*) AS total_entries
FROM cleaned_dataset;

-- comparing null counts with thresh hold
SELECT CASE WHEN 
	COUNT(*) <= (SELECT COUNT(*) * 0.05 FROM cleaned_dataset) 
		THEN 'MUST_DROP' 
		ELSE 'DO_NOT_DROP' END AS impute_supplier
 FROM cleaned_dataset WHERE supplier IS NULL;
SELECT CASE WHEN 
	COUNT(*) <= (SELECT COUNT(*) * 0.05 FROM cleaned_dataset) 
		THEN 'MUST_DROP'
		ELSE 'DO_NOT_DROP' END AS impute_itemcode
 FROM cleaned_dataset WHERE item_code IS NULL;
SELECT CASE WHEN 
	COUNT(*) <= (SELECT COUNT(*) * 0.05 FROM cleaned_dataset)
		THEN 'MUST_DROP'
		ELSE 'DO_NOT_DROP' END AS impute_item_desc
 FROM cleaned_dataset WHERE item_desc IS NULL;
SELECT CASE WHEN 
	COUNT(*) <= (SELECT COUNT(*) * 0.05 FROM cleaned_dataset)
		THEN 'MUST_DROP'
		ELSE'DO_NOT_DROP' END AS impute_item_type
 FROM cleaned_dataset WHERE item_type IS NULL;
 
SELECT COUNT(*) FROM cleaned_dataset WHERE retail_sales IS NULL; -- retail sales count
SELECT CASE WHEN 
	COUNT(*) <= (SELECT COUNT(*) * 0.05 FROM cleaned_dataset) 
		THEN 'MUST_DROP'
		ELSE 'DO_NOT_DROP' END AS impute_retail_sales
 FROM cleaned_dataset WHERE retail_sales IS NULL;
SELECT CASE WHEN 
	COUNT(*) <= (SELECT COUNT(*) * 0.05 FROM cleaned_dataset)
		THEN 'MUST_DROP'
		ELSE 'DO_NOT_DROP' END AS impute_retail_transfers
 FROM cleaned_dataset WHERE retail_transfers IS NULL;
SELECT CASE WHEN 
	COUNT(*) <= (SELECT COUNT(*) * 0.05 FROM cleaned_dataset) 
		THEN 'MUST_DROP'
		ELSE 'DO_NOT_DROP' END AS impute_warehouse_sales
 FROM cleaned_dataset WHERE warehouse_sales IS NULL;
 
 -- drop all nulls for suppliers, item_code, item_desc and item_type
DELETE FROM cleaned_dataset 
WHERE supplier IS NULL
	OR item_code IS NULL
	OR item_desc IS NULL
	OR item_type IS NULL;

-- imputing values for retail_sales, retail_transfers and warehouse_sales
WITH orderly_retail AS (
	SELECT retail_sales, retail_transfers, warehouse_sales,
		ROW_NUMBER() OVER (ORDER BY retail_sales) AS ROW_NUM_SALES, COUNT(*) OVER () AS TOTAl_ROWS_SALES,
        ROW_NUMBER() OVER (ORDER BY retail_transfers) AS ROW_NUM_TRANSFERS, COUNT(*) OVER () AS TOTAl_ROWS_TRANSFERS,
        ROW_NUMBER() OVER (ORDER BY warehouse_sales) AS ROW_NUM_WAREHOUSE, COUNT(*) OVER () AS TOTAl_ROWS_WAREHOUSE
	FROM cleaned_dataset GROUP BY retail_sales, retail_transfers, warehouse_sales)
    
SELECT ROUND(AVG(retail_sales), 2) AS median_retail_sales,
	(SELECT ROUND(AVG(retail_transfers), 2)
	FROM orderly_retail
	WHERE ROW_NUM_TRANSFERS IN (FLOOR((TOTAl_ROWS_TRANSFERS + 1) / 2), CEIL((TOTAl_ROWS_TRANSFERS + 1) / 2))
    ) AS median_retail_transfers,
    (SELECT ROUND(AVG(warehouse_sales), 2)
	 FROM orderly_retail
	WHERE ROW_NUM_WAREHOUSE IN (FLOOR((TOTAl_ROWS_WAREHOUSE + 1) / 2), CEIL((TOTAl_ROWS_WAREHOUSE + 1) / 2))
    ) AS median_warehouse_sales
FROM orderly_retail
WHERE ROW_NUM_SALES IN (FLOOR((TOTAl_ROWS_SALES + 1) / 2), CEIL((TOTAl_ROWS_SALES + 1) / 2));


-- updating cleaned_dataset with imputed values with the median values
UPDATE cleaned_dataset SET retail_sales = 9.23  WHERE retail_sales IS NULL;
UPDATE cleaned_dataset SET retail_transfers = 9.75  WHERE retail_transfers IS NULL;
UPDATE cleaned_dataset SET warehouse_sales = 7  WHERE warehouse_sales IS NULL;
 
 -- previewing dataset to check if there are nulls
 SELECT * FROM cleaned_dataset WHERE retail_sales IS NULL;
 SELECT * FROM cleaned_dataset WHERE retail_transfers IS NULL;
 SELECT * FROM cleaned_dataset WHERE warehouse_sales IS NULL; -- NO NULLS CONFIRMED

-- counting rows of table cleaned_dataset
SELECT COUNT(*) AS remaining FROM cleaned_dataset;

-- INSIGHTS
SELECT sales_year,
		COUNT(DISTINCT supplier) AS n_supplier,
        ROUND(SUM(retail_sales), 2) AS total_sales,
        ROUND(SUM(retail_transfers), 2) AS total_transfers,
        ROUND(SUM(warehouse_sales), 2) AS total_warehouse_sales
FROM cleaned_dataset
GROUP BY sales_year
ORDER BY sales_year DESC;

SELECT sales_month,
		COUNT(DISTINCT item_type) AS n_item_type,
        ROUND(AVG(retail_sales), 2) AS average_sales,
        ROUND(AVG(retail_transfers), 2) AS average_retail_transfers,
        ROUND(AVG(warehouse_sales),2) AS average_warehouse_sales
FROM cleaned_dataset
GROUP BY sales_month
ORDER BY average_sales DESC;

SELECT DISTINCT supplier,
		COUNT(item_type) AS n_item_type,
        ROUND(AVG(retail_sales), 2) AS average_sales,
        ROUND(AVG(retail_transfers), 2) AS average_transfers,
        ROUND(AVG(warehouse_sales), 2) AS average_warehouse_sales
FROM cleaned_dataset
GROUP BY supplier
ORDER BY average_sales DESC;

SELECT DISTINCT item_type,
		COUNT(item_type) AS n_item_type,
        ROUND(AVG(retail_sales), 2) AS average_sales,
        ROUND(AVG(retail_transfers), 2) AS average_retail_transfers,
        ROUND(AVG(warehouse_sales), 2) AS average_warehouse_sales
FROM cleaned_dataset
GROUP BY item_type
ORDER BY average_sales DESC;

SELECT DISTINCT item_type,
		COUNT(item_type) AS n_item_type,
        ROUND(AVG(retail_sales), 2) AS average_sales,
        ROUND(AVG(retail_transfers), 2) AS average_retail_transfers,
        ROUND(AVG(warehouse_sales), 2) AS average_warehouse_sales
FROM cleaned_dataset
GROUP BY item_type
ORDER BY n_item_type DESC;

SELECT DISTINCT item_type,
        ROUND(SUM(retail_transfers), 2) AS total_retail_transfers,
        ROUND(AVG(retail_transfers), 2) AS average_transfers
FROM cleaned_dataset
GROUP BY item_type
ORDER BY average_transfers DESC;    -- using average transfers to check which item type sold much




-- in case we no longer need table
DROP TABLE cleaned_dataset;