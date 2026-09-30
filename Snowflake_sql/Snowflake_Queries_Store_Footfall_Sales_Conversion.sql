-- ============================================================
-- STORE FOOTFALL VS SALES CONVERSION - SNOWFLAKE SQL
-- Name: Subham Debnath
-- Roll No.: 2306070
-- Batch: DATABRICKS And SNOWFLAKE 2026
-- Submitted to: Dr. Kanthi Kiran
-- Date: 30 September 2026
-- ============================================================

-- ============================================================
-- 1. CREATE DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS STORE_FOOTFALL_DB;


-- ============================================================
-- 2. CREATE SCHEMA
-- ============================================================

CREATE SCHEMA IF NOT EXISTS STORE_FOOTFALL_DB.CAPSTONE;


-- ============================================================
-- 3. CREATE CSV FILE FORMAT
-- ============================================================

CREATE OR REPLACE FILE FORMAT STORE_FOOTFALL_DB.CAPSTONE.GOLD_CSV_FORMAT
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', 'null', '');


-- ============================================================
-- 4. CREATE INTERNAL STAGE
-- ============================================================

CREATE OR REPLACE STAGE STORE_FOOTFALL_DB.CAPSTONE.GOLD_STAGE
    FILE_FORMAT = STORE_FOOTFALL_DB.CAPSTONE.GOLD_CSV_FORMAT;


-- ============================================================
-- 5. CHECK FILES IN THE STAGE
-- NOTE:
-- The CSV file was uploaded to the named internal stage
-- through the Snowflake Snowsight UI.
-- ============================================================

LIST @STORE_FOOTFALL_DB.CAPSTONE.GOLD_STAGE;


-- ============================================================
-- 6. CREATE GOLD TABLE
-- ============================================================

CREATE OR REPLACE TABLE STORE_FOOTFALL_DB.CAPSTONE.GOLD_STORE_HOUR (
    store_id VARCHAR,
    city VARCHAR,
    format VARCHAR,
    trade_date DATE,
    hour INTEGER,
    is_weekend BOOLEAN,
    footfall INTEGER,
    bills INTEGER,
    revenue FLOAT,
    conversion_rate FLOAT,
    sensor_ok BOOLEAN
);


-- ============================================================
-- 7. LOAD GOLD CSV FROM STAGE INTO SNOWFLAKE TABLE
-- ============================================================

COPY INTO STORE_FOOTFALL_DB.CAPSTONE.GOLD_STORE_HOUR
FROM @STORE_FOOTFALL_DB.CAPSTONE.GOLD_STAGE
FILE_FORMAT = (
    FORMAT_NAME = STORE_FOOTFALL_DB.CAPSTONE.GOLD_CSV_FORMAT
)
ON_ERROR = 'ABORT_STATEMENT';


-- ============================================================
-- 8. VALIDATE LOADED GOLD TABLE
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(bills) AS total_bills,
    SUM(revenue) AS total_revenue,
    SUM(IFF(sensor_ok, 1, 0)) AS sensor_ok_true,
    SUM(IFF(sensor_ok, 0, 1)) AS sensor_ok_false
FROM STORE_FOOTFALL_DB.CAPSTONE.GOLD_STORE_HOUR;


-- ============================================================
-- 9. Q1 - CONVERSION RATE PER STORE-HOUR
-- ============================================================

SELECT
    store_id,
    city,
    format,
    trade_date,
    hour,
    footfall,
    bills,
    conversion_rate
FROM STORE_FOOTFALL_DB.CAPSTONE.GOLD_STORE_HOUR
WHERE sensor_ok = TRUE
ORDER BY store_id, trade_date, hour;


-- ============================================================
-- 10. Q2 - THREE WORST HOURS ACROSS THE ENTIRE CHAIN
-- ============================================================

SELECT
    hour,
    SUM(footfall) AS total_footfall,
    SUM(bills) AS total_bills,
    ROUND(
        SUM(bills) / NULLIF(SUM(footfall), 0),
        4
    ) AS conversion_rate
FROM STORE_FOOTFALL_DB.CAPSTONE.GOLD_STORE_HOUR
WHERE sensor_ok = TRUE
GROUP BY hour
ORDER BY conversion_rate
LIMIT 3;


-- ============================================================
-- 11. Q3 - DOES CONVERSION DROP ON DAYS WITH THE HIGHEST
--     FOOTFALL?
--
-- Days are ranked into 10 footfall deciles separately for
-- each store using NTILE(10).
-- ============================================================

WITH daily AS (
    SELECT
        store_id,
        trade_date,
        SUM(footfall) AS visitors,
        SUM(bills) AS bills
    FROM STORE_FOOTFALL_DB.CAPSTONE.GOLD_STORE_HOUR
    WHERE sensor_ok = TRUE
    GROUP BY store_id, trade_date
),
deciles AS (
    SELECT
        store_id,
        trade_date,
        visitors,
        bills,
        NTILE(10) OVER (
            PARTITION BY store_id
            ORDER BY visitors
        ) AS decile
    FROM daily
)
SELECT
    decile,
    COUNT(*) AS store_days,
    SUM(visitors) AS visitors,
    SUM(bills) AS bills,
    ROUND(
        SUM(bills) / NULLIF(SUM(visitors), 0),
        4
    ) AS conversion_rate
FROM deciles
GROUP BY decile
ORDER BY decile;


-- ============================================================
-- 12. OPTIONAL Q3 SUMMARY COMPARISON
-- LOWEST FOOTFALL DECILE VS HIGHEST FOOTFALL DECILE
-- ============================================================

WITH daily AS (
    SELECT
        store_id,
        trade_date,
        SUM(footfall) AS visitors,
        SUM(bills) AS bills
    FROM STORE_FOOTFALL_DB.CAPSTONE.GOLD_STORE_HOUR
    WHERE sensor_ok = TRUE
    GROUP BY store_id, trade_date
),
deciles AS (
    SELECT
        store_id,
        trade_date,
        visitors,
        bills,
        NTILE(10) OVER (
            PARTITION BY store_id
            ORDER BY visitors
        ) AS decile
    FROM daily
),
summary AS (
    SELECT
        decile,
        SUM(visitors) AS visitors,
        SUM(bills) AS bills,
        ROUND(
            SUM(bills) / NULLIF(SUM(visitors), 0),
            4
        ) AS conversion_rate
    FROM deciles
    GROUP BY decile
)
SELECT *
FROM summary
WHERE decile IN (1, 10)
ORDER BY decile;


-- ============================================================
-- END OF SNOWFLAKE SQL
-- ============================================================
