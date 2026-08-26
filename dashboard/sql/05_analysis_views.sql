-- 05_analysis_views.sql
-- Reusable analytical layer used by Tableau and the KPI queries.

USE mac_portfolio;

CREATE OR REPLACE VIEW vw_gifts_enriched AS
SELECT
    g.*,
    CASE WHEN MONTH(g.Gift_Date) >= 9 THEN YEAR(g.Gift_Date) + 1
         ELSE YEAR(g.Gift_Date) END AS Fiscal_Year,
    CONCAT('FY', RIGHT(CASE WHEN MONTH(g.Gift_Date) >= 9 THEN YEAR(g.Gift_Date) + 1
                           ELSE YEAR(g.Gift_Date) END, 2)) AS Fiscal_Year_Label,
    CASE WHEN g.Gift_Amount > 0 AND g.Gift_Status = 'Completed' THEN 1 ELSE 0 END AS Is_Positive_Gift
FROM gifts_clean_final AS g;

CREATE OR REPLACE VIEW vw_donor_fiscal_year AS
SELECT
    Constituent_ID,
    Fiscal_Year,
    Fiscal_Year_Label,
    COUNT(*) AS Transaction_Count,
    SUM(Gift_Amount) AS Net_Giving,
    SUM(CASE WHEN Gift_Amount > 0 THEN Gift_Amount ELSE 0 END) AS Gross_Positive_Giving
FROM vw_gifts_enriched
WHERE Is_Positive_Gift = 1
GROUP BY Constituent_ID, Fiscal_Year, Fiscal_Year_Label;

CREATE OR REPLACE VIEW vw_retention_by_fiscal_year AS
SELECT
    prior_fy.Fiscal_Year + 1 AS Fiscal_Year,
    CONCAT('FY', RIGHT(prior_fy.Fiscal_Year + 1, 2)) AS Fiscal_Year_Label,
    COUNT(DISTINCT prior_fy.Constituent_ID) AS Prior_Year_Donors,
    COUNT(DISTINCT current_fy.Constituent_ID) AS Retained_Donors,
    ROUND(100.0 * COUNT(DISTINCT current_fy.Constituent_ID)
          / NULLIF(COUNT(DISTINCT prior_fy.Constituent_ID), 0), 1) AS Retention_Rate
FROM vw_donor_fiscal_year AS prior_fy
LEFT JOIN vw_donor_fiscal_year AS current_fy
    ON current_fy.Constituent_ID = prior_fy.Constituent_ID
   AND current_fy.Fiscal_Year = prior_fy.Fiscal_Year + 1
GROUP BY prior_fy.Fiscal_Year;

CREATE OR REPLACE VIEW vw_stable_source_fiscal_year AS
SELECT
    Constituent_ID,
    CASE WHEN MONTH(Gift_Date) >= 9 THEN YEAR(Gift_Date) + 1 ELSE YEAR(Gift_Date) END AS Fiscal_Year,
    SUM(Gift_Amount) AS Net_Giving
FROM gifts_clean_final
WHERE Gift_Source = 'Stable Source'
  AND Gift_Amount > 0
  AND Gift_Status = 'Completed'
GROUP BY Constituent_ID,
         CASE WHEN MONTH(Gift_Date) >= 9 THEN YEAR(Gift_Date) + 1 ELSE YEAR(Gift_Date) END;

CREATE OR REPLACE VIEW vw_stable_source_retention AS
SELECT
    p.Fiscal_Year + 1 AS Fiscal_Year,
    CONCAT('FY', RIGHT(p.Fiscal_Year + 1, 2)) AS Fiscal_Year_Label,
    COUNT(DISTINCT p.Constituent_ID) AS Prior_Year_Donors,
    COUNT(DISTINCT c.Constituent_ID) AS Retained_Donors,
    ROUND(100.0 * COUNT(DISTINCT c.Constituent_ID)
          / NULLIF(COUNT(DISTINCT p.Constituent_ID), 0), 1) AS Retention_Rate
FROM vw_stable_source_fiscal_year AS p
LEFT JOIN vw_stable_source_fiscal_year AS c
    ON c.Constituent_ID = p.Constituent_ID
   AND c.Fiscal_Year = p.Fiscal_Year + 1
GROUP BY p.Fiscal_Year;

CREATE OR REPLACE VIEW vw_campaign_performance AS
SELECT
    c.Campaign_ID, c.Campaign_Name, c.Campaign_Type,
    c.Start_Date, c.End_Date, c.Goal,
    COUNT(DISTINCT CASE WHEN g.Gift_Amount > 0 THEN g.Gift_ID END) AS Positive_Gift_Count,
    COUNT(DISTINCT CASE WHEN g.Gift_Amount > 0 THEN g.Constituent_ID END) AS Donor_Count,
    SUM(g.Gift_Amount) AS Net_Revenue,
    SUM(CASE WHEN g.Gift_Amount > 0 THEN g.Gift_Amount ELSE 0 END) AS Gross_Revenue,
    ROUND(100.0 * SUM(g.Gift_Amount) / NULLIF(c.Goal, 0), 1) AS Percent_Of_Goal
FROM campaigns_clean_final AS c
LEFT JOIN gifts_clean_final AS g ON c.Campaign_ID = g.Campaign_ID
GROUP BY c.Campaign_ID, c.Campaign_Name, c.Campaign_Type,
         c.Start_Date, c.End_Date, c.Goal;

CREATE OR REPLACE VIEW vw_solicitation_channel_performance AS
SELECT
    Solicitation_Channel,
    COUNT(*) AS Total_Solicitations,
    SUM(Response = 'Gift') AS Gift_Responses,
    ROUND(100.0 * SUM(Response = 'Gift') / COUNT(*), 1) AS Response_Rate,
    ROUND(AVG(CASE WHEN Response = 'Gift' THEN Ask_Amount END), 2) AS Average_Successful_Ask,
    ROUND(AVG(CASE WHEN Response = 'Gift' THEN Days_To_Gift END), 1) AS Average_Days_To_Gift
FROM solicitations_clean_final
GROUP BY Solicitation_Channel;

CREATE OR REPLACE VIEW vw_acquisition_source_performance AS
SELECT
    c.Acquisition_Source,
    COUNT(DISTINCT c.Constituent_ID) AS Constituents_Acquired,
    COUNT(DISTINCT CASE WHEN g.Gift_Amount > 0 THEN c.Constituent_ID END) AS Donors,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN g.Gift_Amount > 0 THEN c.Constituent_ID END)
          / NULLIF(COUNT(DISTINCT c.Constituent_ID), 0), 1) AS Donor_Conversion_Rate,
    SUM(CASE WHEN g.Gift_Amount > 0 THEN g.Gift_Amount ELSE 0 END) AS Gross_Giving
FROM constituents_clean_final AS c
LEFT JOIN gifts_clean_final AS g ON c.Constituent_ID = g.Constituent_ID
GROUP BY c.Acquisition_Source;

CREATE OR REPLACE VIEW vw_volunteer_repeat_giving AS
SELECT
    CASE WHEN c.Volunteer_Flag = 'Y' THEN 'Donor-Volunteer' ELSE 'Non-Volunteer' END AS Engagement_Group,
    COUNT(*) AS Donors,
    SUM(d.Positive_Gift_Count > 1) AS Repeat_Donors,
    ROUND(100.0 * SUM(d.Positive_Gift_Count > 1) / COUNT(*), 1) AS Repeat_Giving_Rate
FROM constituents_clean_final AS c
JOIN (
    SELECT Constituent_ID, COUNT(*) AS Positive_Gift_Count
    FROM gifts_clean_final
    WHERE Gift_Amount > 0 AND Gift_Status = 'Completed'
    GROUP BY Constituent_ID
) AS d ON c.Constituent_ID = d.Constituent_ID
GROUP BY CASE WHEN c.Volunteer_Flag = 'Y' THEN 'Donor-Volunteer' ELSE 'Non-Volunteer' END;
