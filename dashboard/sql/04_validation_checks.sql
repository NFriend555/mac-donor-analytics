-- 04_validation_checks.sql
-- Each issue count should return zero unless explicitly documented.

USE mac_portfolio;

-- Row preservation and primary-key uniqueness
SELECT 'constituents' AS Dataset,
       (SELECT COUNT(*) FROM constituents_raw) AS Raw_Rows,
       (SELECT COUNT(*) FROM constituents_clean_final) AS Clean_Rows,
       (SELECT COUNT(*) FROM constituents_clean_final)
         - (SELECT COUNT(DISTINCT Constituent_ID) FROM constituents_clean_final) AS Duplicate_Keys
UNION ALL
SELECT 'campaigns', (SELECT COUNT(*) FROM campaigns_raw),
       (SELECT COUNT(*) FROM campaigns_clean_final),
       (SELECT COUNT(*) FROM campaigns_clean_final)
         - (SELECT COUNT(DISTINCT Campaign_ID) FROM campaigns_clean_final)
UNION ALL
SELECT 'gifts', (SELECT COUNT(*) FROM gifts_raw),
       (SELECT COUNT(*) FROM gifts_clean_final),
       (SELECT COUNT(*) FROM gifts_clean_final)
         - (SELECT COUNT(DISTINCT Gift_ID) FROM gifts_clean_final)
UNION ALL
SELECT 'solicitations', (SELECT COUNT(*) FROM solicitations_raw),
       (SELECT COUNT(*) FROM solicitations_clean_final),
       (SELECT COUNT(*) FROM solicitations_clean_final)
         - (SELECT COUNT(DISTINCT Solicitation_ID) FROM solicitations_clean_final);

-- Constituent validation
SELECT
    SUM(Constituent_ID IS NULL) AS Missing_IDs,
    SUM(SUBSTRING_INDEX(Email, '@', 1) LIKE '%..%') AS Double_Period_Emails,
    SUM(Age_Band NOT IN ('18-29','30-49','50-65','66-80')) AS Invalid_Age_Bands,
    SUM(Preferred_Contact_Method = 'Email' AND Email IS NULL) AS Unusable_Email_Preferences,
    SUM(Preferred_Contact_Method = 'Phone' AND Phone IS NULL) AS Unusable_Phone_Preferences,
    SUM(Preferred_Contact_Method = 'Mail'
        AND (City IS NULL OR State IS NULL OR ZIP IS NULL)) AS Unusable_Mail_Preferences
FROM constituents_clean_final;

-- Campaign validation
SELECT
    SUM(End_Date < Start_Date) AS Invalid_Date_Ranges,
    SUM(Goal <= 0) AS Invalid_Goals
FROM campaigns_clean_final;

-- Gift validation and referential integrity
SELECT
    SUM(c.Constituent_ID IS NULL) AS Orphaned_Constituents,
    SUM(cp.Campaign_ID IS NULL) AS Orphaned_Campaigns,
    SUM(g.Gift_Date IS NULL) AS Missing_Gift_Dates,
    SUM(g.Campaign_ID IS NULL) AS Missing_Campaign_IDs
FROM gifts_clean_final AS g
LEFT JOIN constituents_clean_final AS c ON g.Constituent_ID = c.Constituent_ID
LEFT JOIN campaigns_clean_final AS cp ON g.Campaign_ID = cp.Campaign_ID;

-- Negative amounts are retained when their transaction type indicates an
-- adjustment or refund; the second count identifies unexplained negatives.
SELECT
    SUM(Gift_Amount < 0) AS Retained_Negative_Transactions,
    SUM(Gift_Amount < 0
        AND Transaction_Type NOT IN ('Refund', 'Adjustment')) AS Unexplained_Negative_Transactions
FROM gifts_clean_final;

-- Solicitation validation
SELECT
    SUM(c.Constituent_ID IS NULL) AS Orphaned_Constituents,
    SUM(cp.Campaign_ID IS NULL) AS Orphaned_Campaigns,
    SUM(s.Response = 'Gift' AND g.Gift_ID IS NULL) AS Gift_Responses_Missing_Gift,
    SUM(s.Response <> 'Gift' AND s.Attributed_Gift_ID IS NOT NULL) AS NonGift_With_Gift,
    SUM(s.Days_To_Gift < 0) AS Gifts_Before_Solicitation,
    SUM(s.Solicitation_Date < cp.Start_Date OR s.Solicitation_Date > cp.End_Date)
        AS Solicitations_Outside_Campaign_Window
FROM solicitations_clean_final AS s
LEFT JOIN constituents_clean_final AS c ON s.Constituent_ID = c.Constituent_ID
LEFT JOIN campaigns_clean_final AS cp ON s.Campaign_ID = cp.Campaign_ID
LEFT JOIN gifts_clean_final AS g ON s.Attributed_Gift_ID = g.Gift_ID;

-- Campaign window exceptions are retained for disclosure rather than deleted.
SELECT cp.Campaign_Name, COUNT(*) AS Positive_Gifts_Outside_Window
FROM gifts_clean_final AS g
JOIN campaigns_clean_final AS cp ON g.Campaign_ID = cp.Campaign_ID
WHERE g.Gift_Amount > 0
  AND (g.Gift_Date < cp.Start_Date OR g.Gift_Date > cp.End_Date)
GROUP BY cp.Campaign_Name
ORDER BY Positive_Gifts_Outside_Window DESC;
