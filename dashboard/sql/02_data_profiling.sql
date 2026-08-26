-- 02_data_profiling.sql
-- Run after loading the raw source tables.

USE mac_portfolio;

-- Row counts and key uniqueness
SELECT 'constituents_raw' AS Table_Name, COUNT(*) AS Total_Rows,
       COUNT(DISTINCT TRIM(Constituent_ID)) AS Distinct_Keys
FROM constituents_raw
UNION ALL
SELECT 'campaigns_raw', COUNT(*), COUNT(DISTINCT TRIM(Campaign_ID))
FROM campaigns_raw
UNION ALL
SELECT 'gifts_raw', COUNT(*), COUNT(DISTINCT TRIM(Gift_ID))
FROM gifts_raw
UNION ALL
SELECT 'solicitations_raw', COUNT(*), COUNT(DISTINCT TRIM(Solicitation_ID))
FROM solicitations_raw;

-- Constituent completeness and format profile
SELECT
    COUNT(*) AS Total_Rows,
    SUM(NULLIF(TRIM(Constituent_ID), '') IS NULL) AS Missing_ID,
    SUM(NULLIF(TRIM(Display_Name), '') IS NULL) AS Missing_Name,
    SUM(NULLIF(TRIM(Email), '') IS NULL OR UPPER(TRIM(Email)) = 'NULL') AS Missing_Email,
    SUM(NULLIF(TRIM(Phone), '') IS NULL OR UPPER(TRIM(Phone)) = 'NULL') AS Missing_Phone,
    SUM(NULLIF(TRIM(Date_Added), '') IS NULL) AS Missing_Date_Added,
    SUM(STR_TO_DATE(NULLIF(TRIM(Date_Added), ''), '%m/%d/%Y') IS NULL
        AND NULLIF(TRIM(Date_Added), '') IS NOT NULL) AS Invalid_Date_Added,
    SUM(NULLIF(TRIM(Age_Band), '') IS NOT NULL
        AND TRIM(Age_Band) NOT IN ('18-29', '30-49', '50-65', '66-80')) AS Invalid_Age_Band,
    SUM(SUBSTRING_INDEX(LOWER(TRIM(Email)), '@', 1) LIKE '%..%') AS Double_Period_Emails
FROM constituents_raw;

SELECT TRIM(Acquisition_Source) AS Acquisition_Source, COUNT(*) AS Record_Count
FROM constituents_raw
GROUP BY TRIM(Acquisition_Source)
ORDER BY Record_Count DESC;

-- Campaign completeness and ranges
SELECT
    COUNT(*) AS Total_Rows,
    SUM(NULLIF(TRIM(Campaign_ID), '') IS NULL) AS Missing_ID,
    SUM(NULLIF(TRIM(Campaign_Name), '') IS NULL) AS Missing_Name,
    SUM(STR_TO_DATE(NULLIF(TRIM(Start_Date), ''), '%m/%d/%Y') IS NULL) AS Invalid_Start_Date,
    SUM(STR_TO_DATE(NULLIF(TRIM(End_Date), ''), '%m/%d/%Y') IS NULL) AS Invalid_End_Date,
    SUM(CAST(NULLIF(TRIM(Goal), '') AS DECIMAL(12,2)) <= 0) AS Nonpositive_Goals
FROM campaigns_raw;

-- Gift completeness, categories, and value ranges
SELECT
    COUNT(*) AS Total_Rows,
    SUM(NULLIF(TRIM(Gift_ID), '') IS NULL) AS Missing_Gift_ID,
    SUM(NULLIF(TRIM(Constituent_ID), '') IS NULL) AS Missing_Constituent_ID,
    SUM(STR_TO_DATE(NULLIF(TRIM(Gift_Date), ''), '%m/%d/%Y') IS NULL) AS Invalid_Gift_Date,
    SUM(NULLIF(TRIM(Gift_Method), '') IS NULL OR UPPER(TRIM(Gift_Method)) = 'NULL') AS Missing_Method,
    SUM(NULLIF(TRIM(Campaign_ID), '') IS NULL OR UPPER(TRIM(Campaign_ID)) = 'NULL') AS Missing_Campaign_ID,
    MIN(CAST(TRIM(Gift_Amount) AS DECIMAL(12,2))) AS Minimum_Amount,
    MAX(CAST(TRIM(Gift_Amount) AS DECIMAL(12,2))) AS Maximum_Amount,
    MIN(STR_TO_DATE(TRIM(Gift_Date), '%m/%d/%Y')) AS Earliest_Gift_Date,
    MAX(STR_TO_DATE(TRIM(Gift_Date), '%m/%d/%Y')) AS Latest_Gift_Date
FROM gifts_raw;

SELECT TRIM(Transaction_Type) AS Transaction_Type, COUNT(*) AS Record_Count
FROM gifts_raw
GROUP BY TRIM(Transaction_Type)
ORDER BY Record_Count DESC;

SELECT TRIM(Gift_Method) AS Gift_Method, COUNT(*) AS Record_Count
FROM gifts_raw
GROUP BY TRIM(Gift_Method)
ORDER BY Record_Count DESC;

-- Solicitation completeness and response distribution
SELECT
    COUNT(*) AS Total_Rows,
    SUM(NULLIF(TRIM(Solicitation_ID), '') IS NULL) AS Missing_Solicitation_ID,
    SUM(NULLIF(TRIM(Constituent_ID), '') IS NULL) AS Missing_Constituent_ID,
    SUM(STR_TO_DATE(NULLIF(TRIM(Solicitation_Date), ''), '%m/%d/%Y') IS NULL) AS Invalid_Date,
    SUM(CAST(TRIM(Ask_Amount) AS DECIMAL(12,2)) <= 0) AS Nonpositive_Asks,
    SUM(TRIM(Response) = 'Gift'
        AND (NULLIF(TRIM(Attributed_Gift_ID), '') IS NULL
             OR UPPER(TRIM(Attributed_Gift_ID)) = 'NULL')) AS Gift_Responses_Missing_Gift
FROM solicitations_raw;

SELECT TRIM(Solicitation_Channel) AS Solicitation_Channel, COUNT(*) AS Record_Count
FROM solicitations_raw
GROUP BY TRIM(Solicitation_Channel)
ORDER BY Record_Count DESC;

SELECT TRIM(Response) AS Response, COUNT(*) AS Record_Count
FROM solicitations_raw
GROUP BY TRIM(Response)
ORDER BY Record_Count DESC;
