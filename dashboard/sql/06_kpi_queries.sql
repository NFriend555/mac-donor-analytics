-- 06_kpi_queries.sql
-- Final business-facing queries and dashboard extracts.

USE mac_portfolio;

-- Retention trend, including the comparable stable-source measure
SELECT * FROM vw_retention_by_fiscal_year ORDER BY Fiscal_Year;
SELECT * FROM vw_stable_source_retention ORDER BY Fiscal_Year;

-- Active donors and giving by fiscal year
SELECT
    Fiscal_Year, Fiscal_Year_Label,
    COUNT(DISTINCT Constituent_ID) AS Active_Donors,
    SUM(Net_Giving) AS Net_Giving,
    ROUND(AVG(Net_Giving), 2) AS Average_Giving_Per_Donor
FROM vw_donor_fiscal_year
GROUP BY Fiscal_Year, Fiscal_Year_Label
ORDER BY Fiscal_Year;

-- Donor composition: new, retained, and reactivated
WITH first_year AS (
    SELECT Constituent_ID, MIN(Fiscal_Year) AS First_Fiscal_Year
    FROM vw_donor_fiscal_year GROUP BY Constituent_ID
)
SELECT
    d.Fiscal_Year,
    d.Fiscal_Year_Label,
    CASE
        WHEN d.Fiscal_Year = f.First_Fiscal_Year THEN 'New'
        WHEN p.Constituent_ID IS NOT NULL THEN 'Retained'
        ELSE 'Reactivated'
    END AS Donor_Type,
    COUNT(DISTINCT d.Constituent_ID) AS Donor_Count
FROM vw_donor_fiscal_year AS d
JOIN first_year AS f ON d.Constituent_ID = f.Constituent_ID
LEFT JOIN vw_donor_fiscal_year AS p
    ON d.Constituent_ID = p.Constituent_ID
   AND d.Fiscal_Year = p.Fiscal_Year + 1
GROUP BY d.Fiscal_Year, d.Fiscal_Year_Label, Donor_Type
ORDER BY d.Fiscal_Year, Donor_Type;

-- Campaign performance against goals
SELECT *
FROM vw_campaign_performance
ORDER BY Percent_Of_Goal DESC, Gross_Revenue DESC;

-- Solicitation response by channel
SELECT *
FROM vw_solicitation_channel_performance
ORDER BY Response_Rate DESC;

-- Acquisition and engagement opportunities
SELECT *
FROM vw_acquisition_source_performance
ORDER BY Donor_Conversion_Rate DESC;

SELECT *
FROM vw_volunteer_repeat_giving
ORDER BY Repeat_Giving_Rate DESC;
