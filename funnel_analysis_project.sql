------ This query selects all columns from best, keeping only the first event per user_pseudo_id and event_name based on the earliest 
----- event_timestamp. It uses a Common Table Expression (CTE) with ROW_NUMBER() to identify the earliest event.
------Filters ensure non-null user_pseudo_id, event_name, and event_timestamp to avoid invalid rows while preserving all rows as requested.
------All columns are retained as per the task requirements.
------(not set) values in country or other fields are kept for analysis but will be noted in insights.
WITH RankedEvents AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY user_pseudo_id, event_name ORDER BY event_timestamp) AS rn
    FROM best
    WHERE user_pseudo_id IS NOT NULL 
        AND event_name IS NOT NULL
        AND event_timestamp IS NOT NULL
)
SELECT 
    event_date,
    event_timestamp,
    event_name,
    event_value_in_usd_cleaned,
    user_pseudo_id,
    user_first_touch_timestamp,
    category,
    mobile_model_name,
    mobile_brand_name,
    operating_system,
    standardized_language,
    is_limited_ad_tracking,
    browser,
    browser_version,
    country,
    medium,
    name,
    traffic_source,
    platform,
    total_item_quantity,
    purchase_revenue_in_usd,
    tax_value_in_usd,
    transaction_id,
    page_title,
    page_location,
    source,
    page_referrer,
    campaign,
	language
FROM RankedEvents
WHERE rn = 1;

-------To determine the top 3 countries by event count, I’ll aggregate the total number of events per country from the cleaned data.
WITH UniqueEvents AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY user_pseudo_id, event_name ORDER BY event_timestamp) AS rn
    FROM best
    WHERE user_pseudo_id IS NOT NULL 
        AND event_name IS NOT NULL
        AND event_timestamp IS NOT NULL
)
SELECT 
    country,
    COUNT(*) AS event_count
FROM UniqueEvents
WHERE rn = 1
GROUP BY country
ORDER BY event_count DESC;

--------- These four events align with the task’s suggested funnel and the 4–6 event requirement.
---This query aggregates the count of unique events for the selected funnel stages, calculates conversion percentages, 
----- and computes drop-off rates for the top 3 countries (United States, Germany, Canada).
WITH UniqueEvents AS (
    SELECT 
        user_pseudo_id,
        event_name,
        country,
        ROW_NUMBER() OVER (PARTITION BY user_pseudo_id, event_name ORDER BY event_timestamp) AS rn
    FROM best
    WHERE user_pseudo_id IS NOT NULL 
        AND event_name IS NOT NULL
        AND event_timestamp IS NOT NULL
        AND event_name IN ('view_item', 'add_to_cart', 'begin_checkout', 'purchase')
),
EventCounts AS (
    SELECT 
        event_name,
        country,
        COUNT(DISTINCT user_pseudo_id) AS user_count
    FROM UniqueEvents
    WHERE rn = 1
        AND country IN ('United States', 'India', 'Canada')
    GROUP BY event_name, country
),
FunnelData AS (
    SELECT 
        CASE 
            WHEN event_name = 'view_item' THEN 1
            WHEN event_name = 'add_to_cart' THEN 2
            WHEN event_name = 'begin_checkout' THEN 3
            WHEN event_name = 'purchase' THEN 4
        END AS event_order, event_name,
        MAX(CASE WHEN country = 'United States' THEN user_count ELSE 0 END) AS us_count,
        MAX(CASE WHEN country = 'India' THEN user_count ELSE 0 END) AS india_count,
        MAX(CASE WHEN country = 'Canada' THEN user_count ELSE 0 END) AS canada_count
    FROM EventCounts
    GROUP BY event_name
),
FunnelWithMetrics AS (
    SELECT 
        event_order,
		event_name,
        us_count,
        india_count,
        canada_count,
        CAST(1.0 * us_count / NULLIF(MAX(us_count) OVER (), 0) AS DECIMAL(10, 4)) AS us_full_perc,
        CAST(1.0 * india_count / NULLIF(MAX(india_count) OVER (), 0) AS DECIMAL(10, 4)) AS india_full_perc,
        CAST(1.0 * canada_count / NULLIF(MAX(canada_count) OVER (), 0) AS DECIMAL(10, 4)) AS canada_full_perc,
        CASE 
            WHEN event_order = 1 THEN 1.0000
            ELSE CAST(1.0 - (1.0 * us_count / NULLIF(LAG(us_count, 1) OVER (ORDER BY event_order), 0)) AS DECIMAL(10, 4))
        END AS us_dropoff,
        CASE 
            WHEN event_order = 1 THEN 1.0000
            ELSE CAST(1.0 - (1.0 * india_count / NULLIF(LAG(india_count, 1) OVER (ORDER BY event_order), 0)) AS DECIMAL(10, 4))
        END AS india_dropoff,
        CASE 
            WHEN event_order = 1 THEN 1.0000
            ELSE CAST(1.0 - (1.0 * canada_count / NULLIF(LAG(canada_count, 1) OVER (ORDER BY event_order), 0)) AS DECIMAL(10, 4))
        END AS canada_dropoff
    FROM FunnelData
)
SELECT 
    event_order,
	event_name,
    us_count AS united_states_events,
    india_count AS india_events,
    canada_count AS canada_events,
    us_full_perc AS full_perc,
    us_dropoff AS united_states_perc_drop,
    india_dropoff AS india_perc_drop,
    canada_dropoff AS canada_perc_drop
FROM FunnelWithMetrics
ORDER BY event_order;


WITH UniqueEvents AS (
    SELECT 
        user_pseudo_id,
        event_name,
        country,
        ROW_NUMBER() OVER (PARTITION BY user_pseudo_id, event_name ORDER BY event_timestamp) AS rn
    FROM best
    WHERE user_pseudo_id IS NOT NULL 
        AND event_name IS NOT NULL
        AND event_timestamp IS NOT NULL
)
SELECT TOP 3
    country,
    COUNT(*) AS event_count
FROM UniqueEvents
WHERE rn = 1
GROUP BY country
ORDER BY event_count DESC;
