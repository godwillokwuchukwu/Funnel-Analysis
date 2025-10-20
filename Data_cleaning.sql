SELECT *
FROM [dbo].[best];

--------

-- Add the new column, Update the new column with cleaned dates and Verify the results
ALTER TABLE best
ADD event_date_cleaned DATE;

UPDATE best
SET event_date_cleaned = CAST(LEFT(event_date, CHARINDEX(' 00:00:00', event_date) - 1) AS DATE)
WHERE event_date LIKE '% 00:00:00%';
 
SELECT event_date, event_date_cleaned
FROM best;

-- Add cleaned columns to existing table, Update the new columns and Verify results
ALTER TABLE best
ADD cleaned_event_time DATETIME2(0),
    event_date_only DATE,
    event_time_only TIME(0);

UPDATE best
SET 
    cleaned_event_time = CAST(event_time AS DATETIME2(0)),
    event_date_only = CAST(event_time AS DATE),
    event_time_only = CAST(event_time AS TIME(0));
 
SELECT event_time, cleaned_event_time, event_date_only, event_time_only
FROM best;

-- Add a new column for cleaned event_value_in_usd, Update with cleaned values, replacing NULLs with 0.00 and Verify the cleaned data
ALTER TABLE best
ADD event_value_in_usd_cleaned DECIMAL(18,2);

UPDATE best
SET event_value_in_usd_cleaned = CASE 
    WHEN event_value_in_usd IS NOT NULL AND ISNUMERIC(event_value_in_usd) = 1 
    THEN CAST(event_value_in_usd AS DECIMAL(18,2)) 
    ELSE 0.00 
END;

SELECT event_value_in_usd, event_value_in_usd_cleaned
FROM best;

-- Add cleaned columns to existing table, Update the new columns and Verify results
ALTER TABLE best
ADD user_first_touch_datetime DATETIME2(0),
    user_first_touch_date DATE,
    user_first_touch_time_only TIME(0);

UPDATE best
SET 
    user_first_touch_datetime = CAST(user_first_touch_time AS DATETIME2(0)),
    user_first_touch_date = CAST(user_first_touch_time AS DATE),
    user_first_touch_time_only = CAST(user_first_touch_time AS TIME(0));
 
SELECT user_first_touch_time, user_first_touch_datetime, user_first_touch_date, user_first_touch_time_only
FROM best;

-- Add a new column for cleaned total_item_quantity, Update with cleaned values, replacing NULLs with 0 and Verify the cleaned data
ALTER TABLE best
ADD total_item_quantity_cleaned INT;

UPDATE best
SET total_item_quantity_cleaned = CASE 
    WHEN total_item_quantity IS NOT NULL AND ISNUMERIC(total_item_quantity) = 1 
    THEN CAST(total_item_quantity AS INT) 
    ELSE 0 
END;

SELECT total_item_quantity, total_item_quantity_cleaned
FROM best;

-- Add a new column, Update with cleaned values, replacing NULLs with 0.00, Verify the cleaned data
ALTER TABLE best
ADD purchase_revenue_in_usd_cleaned DECIMAL(18,2), refund_value_in_usd_cleaned DECIMAL(18,2), 
	shipping_value_in_usd_cleaned DECIMAL(18,2), tax_value_in_usd_cleaned DECIMAL(18,2);

UPDATE best
SET purchase_revenue_in_usd_cleaned = CASE 
    WHEN purchase_revenue_in_usd IS NOT NULL AND ISNUMERIC(purchase_revenue_in_usd) = 1 
    THEN CAST(purchase_revenue_in_usd AS DECIMAL(18,2)) 
    ELSE 0.00 
END;

UPDATE best
SET refund_value_in_usd_cleaned = CASE 
    WHEN refund_value_in_usd IS NOT NULL AND ISNUMERIC(refund_value_in_usd) = 1 
    THEN CAST(refund_value_in_usd AS DECIMAL(18,2)) 
    ELSE 0.00 
END;

UPDATE best
SET shipping_value_in_usd_cleaned = CASE 
    WHEN shipping_value_in_usd IS NOT NULL AND ISNUMERIC(shipping_value_in_usd) = 1 
    THEN CAST(shipping_value_in_usd AS DECIMAL(18,2)) 
    ELSE 0.00 
END;

UPDATE best
SET tax_value_in_usd_cleaned = CASE 
    WHEN tax_value_in_usd IS NOT NULL AND ISNUMERIC(tax_value_in_usd) = 1 
    THEN CAST(tax_value_in_usd AS DECIMAL(18,2)) 
    ELSE 0.00 
END;

SELECT purchase_revenue_in_usd_cleaned, tax_value_in_usd_cleaned, shipping_value_in_usd_cleaned, refund_value_in_usd_cleaned
FROM best;

-- Add a new column for cleaned transaction_id, Update with cleaned transaction IDs, replacing NULLs with '', Verify the cleaned data
ALTER TABLE best
ADD transaction_id_cleaned NVARCHAR(50);

UPDATE best
SET transaction_id_cleaned = CASE 
    WHEN transaction_id IS NOT NULL 
    THEN TRIM(transaction_id) 
    ELSE '(not set)' 
END;

SELECT transaction_id, transaction_id_cleaned
FROM best;

-- Add a new column, Update with cleaned event names, replacing NULLs with '<other>', Verify the cleaned data
ALTER TABLE best
ADD campaign_cleaned NVARCHAR(50);

UPDATE best
SET campaign_cleaned = CASE 
    WHEN campaign IS NOT NULL 
    THEN TRIM(LOWER(campaign)) 
    ELSE '<other>' 
END;

SELECT campaign, campaign_cleaned
FROM best;

-- Add a new column, Update with cleaned event names, replacing NULLs with '<other>', Verify the cleaned data
ALTER TABLE best
ADD language_cleaned NVARCHAR(50);

UPDATE best
SET language_cleaned = CASE 
    WHEN language IS NOT NULL 
    THEN TRIM(LOWER(campaign)) 
    ELSE '<other>' 
END;

SELECT language, language_cleaned
FROM best;

-- First add a computed column
ALTER TABLE best
ADD standardized_language AS (CASE WHEN language IS NULL THEN '<other>' ELSE LOWER(TRIM(language)) END);

-- First, drop all unnecessary columns in a single statement
ALTER TABLE best
DROP COLUMN 
    event_date,
	event_time,
    user_id, 
    event_value_in_usd, 
    user_first_touch_time, 
    cleaned_event_time, 
    event_date_only, 
    user_first_touch_datetime, 
    user_first_touch_date, 
    purchase_revenue_in_usd, 
    total_item_quantity,  
    refund_value_in_usd, 
    shipping_value_in_usd, 
    tax_value_in_usd, 
    transaction_id, 
    shipping_value_in_usd_cleaned,
    refund_value_in_usd_cleaned, 
    campaign, 
    language_cleaned;

-- Then rename each column individually with separate EXEC sp_rename statements
EXEC sp_rename 'best.event_date_cleaned', 'event_date', 'COLUMN';
EXEC sp_rename 'best.event_time_only', 'event_time', 'COLUMN';
EXEC sp_rename 'best.user_first_touch_time_only', 'user_first_touch_time', 'COLUMN';
EXEC sp_rename 'best.total_item_quantity_cleaned', 'total_item_quantity', 'COLUMN';
EXEC sp_rename 'best.purchase_revenue_in_usd_cleaned', 'purchase_revenue_in_usd', 'COLUMN';
EXEC sp_rename 'best.tax_value_in_usd_cleaned', 'tax_value_in_usd', 'COLUMN';
EXEC sp_rename 'best.transaction_id_cleaned', 'transaction_id', 'COLUMN';
EXEC sp_rename 'best.campaign_cleaned', 'campaign', 'COLUMN';

SELECT *
FROM [dbo].[best]