-- 03_data_cleaning.sql
-- Creates analysis-ready tables from the raw landing tables.
-- Safe to rerun: final tables are dropped and rebuilt in dependency order.

USE mac_portfolio;

DROP TABLE IF EXISTS solicitations_clean_final;
DROP TABLE IF EXISTS gifts_clean_final;
DROP TABLE IF EXISTS campaigns_clean_final;
DROP TABLE IF EXISTS constituents_clean_final;

CREATE TABLE constituents_clean_final (
    Constituent_ID VARCHAR(20) NOT NULL,
    Display_Name VARCHAR(150),
    Honorific VARCHAR(10),
    Email VARCHAR(255),
    Phone VARCHAR(40),
    City VARCHAR(100),
    State VARCHAR(10),
    ZIP VARCHAR(20),
    Country VARCHAR(100),
    Age_Band VARCHAR(30),
    Gender VARCHAR(50),
    Sector VARCHAR(100),
    Newsletter_Opt_In VARCHAR(10),
    Date_Added DATE,
    Acquisition_Source VARCHAR(100),
    Preferred_Contact_Method VARCHAR(100),
    Constituent_Status VARCHAR(50),
    Volunteer_Flag VARCHAR(10),
    Age_Band_Issue_Flag TINYINT NOT NULL,
    Missing_Date_Added_Flag TINYINT NOT NULL,
    PRIMARY KEY (Constituent_ID),
    INDEX idx_constituent_acquisition (Acquisition_Source),
    INDEX idx_constituent_status (Constituent_Status),
    INDEX idx_constituent_date_added (Date_Added)
);

INSERT INTO constituents_clean_final
SELECT
    TRIM(Constituent_ID),
    CASE
        WHEN NULLIF(TRIM(Display_Name), '') IS NULL THEN NULL
        ELSE REGEXP_REPLACE(
            REGEXP_REPLACE(TRIM(Display_Name),
                '^(mrs|miss|mr|ms|dr)[.]?[[:space:]]+', '', 1, 0, 'i'),
            '[[:space:]]+', ' '
        )
    END AS Display_Name,
    CASE
        WHEN LOWER(TRIM(Display_Name)) REGEXP '^mrs[.]?[[:space:]]+' THEN 'Mrs.'
        WHEN LOWER(TRIM(Display_Name)) REGEXP '^miss[[:space:]]+' THEN 'Ms.'
        WHEN LOWER(TRIM(Display_Name)) REGEXP '^ms[.]?[[:space:]]+' THEN 'Ms.'
        WHEN LOWER(TRIM(Display_Name)) REGEXP '^mr[.]?[[:space:]]+' THEN 'Mr.'
        WHEN LOWER(TRIM(Display_Name)) REGEXP '^dr[.]?[[:space:]]+' THEN 'Dr.'
        ELSE NULL
    END AS Honorific,
    LOWER(NULLIF(TRIM(Email), '')),
    NULLIF(NULLIF(TRIM(Phone), ''), 'NULL'),
    CASE UPPER(TRIM(City))
        WHEN 'ARLINGTON' THEN 'Arlington' WHEN 'CLEBURNE' THEN 'Cleburne'
        WHEN 'DALLAS' THEN 'Dallas' WHEN 'DECATUR' THEN 'Decatur'
        WHEN 'DENTON' THEN 'Denton' WHEN 'FLOWER MOUND' THEN 'Flower Mound'
        WHEN 'FORT WORTH' THEN 'Fort Worth' WHEN 'FRISCO' THEN 'Frisco'
        WHEN 'GRAPEVINE' THEN 'Grapevine' WHEN 'IRVING' THEN 'Irving'
        WHEN 'LEWISVILLE' THEN 'Lewisville' WHEN 'MCKINNEY' THEN 'McKinney'
        WHEN 'PLANO' THEN 'Plano' WHEN 'SOUTHLAKE' THEN 'Southlake'
        WHEN 'WEATHERFORD' THEN 'Weatherford'
        ELSE NULLIF(TRIM(City), '')
    END,
    CASE
        WHEN UPPER(TRIM(State)) IN ('TX', 'TEXAS') THEN 'TX'
        ELSE UPPER(NULLIF(TRIM(State), ''))
    END,
    NULLIF(TRIM(ZIP), ''),
    NULLIF(TRIM(Country), ''),
    CASE WHEN TRIM(Age_Band) IN ('18-29', '30-49', '50-65', '66-80')
         THEN TRIM(Age_Band) ELSE NULL END,
    NULLIF(TRIM(Gender), ''),
    NULLIF(TRIM(Sector), ''),
    UPPER(NULLIF(TRIM(Newsletter_Opt_In), '')),
    STR_TO_DATE(NULLIF(TRIM(Date_Added), ''), '%m/%d/%Y'),
    CASE
        WHEN TRIM(Acquisition_Source) IN ('E-news', 'Email Newsletter', 'Newsletter') THEN 'Email Newsletter'
        WHEN TRIM(Acquisition_Source) IN ('Community Event', 'Local event') THEN 'Community Event'
        WHEN TRIM(Acquisition_Source) IN ('Social Media', 'social', 'Facebook', 'Instagram') THEN 'Social Media'
        WHEN TRIM(Acquisition_Source) IN ('Direct Mail', 'Mail') THEN 'Direct Mail'
        WHEN TRIM(Acquisition_Source) IN ('Friend/Referral', 'Word of mouth') THEN 'Friend/Referral'
        ELSE NULLIF(TRIM(Acquisition_Source), '')
    END,
    COALESCE(NULLIF(TRIM(Preferred_Contact_Method), ''), 'Unknown'),
    NULLIF(TRIM(Constituent_Status), ''),
    UPPER(NULLIF(TRIM(Volunteer_Flag), '')),
    CASE WHEN NULLIF(TRIM(Age_Band), '') IS NOT NULL
              AND TRIM(Age_Band) NOT IN ('18-29', '30-49', '50-65', '66-80')
         THEN 1 ELSE 0 END,
    CASE WHEN NULLIF(TRIM(Date_Added), '') IS NULL THEN 1 ELSE 0 END
FROM constituents_raw;

-- High-confidence corrections identified during manual review.
UPDATE constituents_clean_final
SET Display_Name = CASE Constituent_ID
    WHEN 'C100371' THEN 'Clinton Barnett'
    WHEN 'C100911' THEN 'Taylor Howard'
    WHEN 'C100190' THEN 'Jocelyn Foley'
    WHEN 'C101308' THEN 'Andrea Taylor'
    WHEN 'C100264' THEN 'Leo Carey'
    WHEN 'C100064' THEN 'Jeremy Norton'
    WHEN 'C103704' THEN 'Christopher Gray'
    WHEN 'C110148' THEN 'Drake Caldwell'
    WHEN 'C105406' THEN 'Aaron Taylor'
    ELSE Display_Name END
WHERE Constituent_ID IN ('C100371','C100911','C100190','C101308','C100264',
                         'C100064','C103704','C110148','C105406');

-- Rebuild the 190 malformed synthetic email usernames deterministically while
-- retaining the original domain and numeric suffix. This is synthetic-data
-- repair logic, not a recommended method for correcting real donor emails.
UPDATE constituents_clean_final
SET Email = LOWER(CONCAT(
    REGEXP_REPLACE(SUBSTRING_INDEX(
        REGEXP_REPLACE(Display_Name, '[,]?[[:space:]]+(MD|DDS|DVM|PhD|II|III|IV)$', '', 1, 0, 'i'),
        ' ', 1), '[^a-z0-9]', '', 1, 0, 'i'),
    '.',
    REGEXP_REPLACE(SUBSTRING_INDEX(
        REGEXP_REPLACE(Display_Name, '[,]?[[:space:]]+(MD|DDS|DVM|PhD|II|III|IV)$', '', 1, 0, 'i'),
        ' ', -1), '[^a-z0-9]', '', 1, 0, 'i'),
    REGEXP_REPLACE(SUBSTRING_INDEX(Email, '@', 1), '[^0-9]', ''),
    '@', SUBSTRING_INDEX(Email, '@', -1)
))
WHERE SUBSTRING_INDEX(Email, '@', 1) LIKE '%..%';

UPDATE constituents_clean_final
SET Preferred_Contact_Method = 'Needs Updated Contact Information'
WHERE (Preferred_Contact_Method = 'Email' AND Email IS NULL)
   OR (Preferred_Contact_Method = 'Phone' AND Phone IS NULL)
   OR (Preferred_Contact_Method = 'Mail'
       AND (City IS NULL OR State IS NULL OR ZIP IS NULL))
   OR (Newsletter_Opt_In = 'Y' AND Email IS NULL);

CREATE TABLE campaigns_clean_final (
    Campaign_ID VARCHAR(20) NOT NULL,
    Campaign_Name VARCHAR(150) NOT NULL,
    Campaign_Type VARCHAR(100) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Goal DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (Campaign_ID),
    INDEX idx_campaign_type (Campaign_Type),
    INDEX idx_campaign_dates (Start_Date, End_Date)
);

INSERT INTO campaigns_clean_final
SELECT
    TRIM(Campaign_ID), TRIM(Campaign_Name), TRIM(Campaign_Type),
    CASE WHEN TRIM(Campaign_Type) IN ('Year-End', 'Event')
         THEN DATE_SUB(STR_TO_DATE(TRIM(Start_Date), '%m/%d/%Y'), INTERVAL 1 YEAR)
         ELSE STR_TO_DATE(TRIM(Start_Date), '%m/%d/%Y') END,
    CASE WHEN TRIM(Campaign_Type) IN ('Year-End', 'Event')
         THEN DATE_SUB(STR_TO_DATE(TRIM(End_Date), '%m/%d/%Y'), INTERVAL 1 YEAR)
         WHEN TRIM(Campaign_Type) = 'Seasonal Appeal'
         THEN LAST_DAY(STR_TO_DATE(TRIM(End_Date), '%m/%d/%Y'))
         ELSE STR_TO_DATE(TRIM(End_Date), '%m/%d/%Y') END,
    CAST(TRIM(Goal) AS DECIMAL(12,2))
FROM campaigns_raw;

CREATE TABLE gifts_clean_final (
    Gift_ID VARCHAR(30) NOT NULL,
    Constituent_ID VARCHAR(20) NOT NULL,
    Gift_Date DATE NOT NULL,
    Gift_Amount DECIMAL(12,2) NOT NULL,
    Transaction_Type VARCHAR(50) NOT NULL,
    Gift_Method VARCHAR(50) NOT NULL,
    Campaign_ID VARCHAR(20) NOT NULL,
    Campaign_Name VARCHAR(150) NOT NULL,
    Designation VARCHAR(150) NOT NULL,
    Gift_Status VARCHAR(50) NOT NULL,
    Gift_Source VARCHAR(30) NOT NULL,
    PRIMARY KEY (Gift_ID),
    INDEX idx_gift_constituent (Constituent_ID),
    INDEX idx_gift_campaign (Campaign_ID),
    INDEX idx_gift_date (Gift_Date)
);

INSERT INTO gifts_clean_final
SELECT
    TRIM(g.Gift_ID), TRIM(g.Constituent_ID),
    STR_TO_DATE(TRIM(g.Gift_Date), '%m/%d/%Y'),
    CAST(TRIM(g.Gift_Amount) AS DECIMAL(12,2)),
    TRIM(g.Transaction_Type),
    CASE
        WHEN NULLIF(TRIM(g.Gift_Method), '') IS NULL OR UPPER(TRIM(g.Gift_Method)) = 'NULL' THEN 'Unknown'
        WHEN LOWER(TRIM(g.Gift_Method)) IN ('online','online gift','web','website') THEN 'Online'
        WHEN LOWER(TRIM(g.Gift_Method)) IN ('mail','direct mail','check - mail') THEN 'Mail'
        WHEN LOWER(TRIM(g.Gift_Method)) IN ('event','event gift','gala') THEN 'Event'
        WHEN LOWER(TRIM(g.Gift_Method)) IN ('ach','recurring ach') THEN 'ACH'
        WHEN LOWER(TRIM(g.Gift_Method)) = 'in person' THEN 'In Person'
        WHEN LOWER(TRIM(g.Gift_Method)) = 'phone' THEN 'Phone'
        ELSE TRIM(g.Gift_Method) END,
    COALESCE(NULLIF(NULLIF(TRIM(g.Campaign_ID), ''), 'NULL'), cm.Campaign_ID),
    CASE COALESCE(NULLIF(NULLIF(TRIM(g.Campaign_ID), ''), 'NULL'), cm.Campaign_ID)
        WHEN 'CMP0001' THEN 'FY21 Annual Fund' WHEN 'CMP0005' THEN 'FY22 Annual Fund'
        WHEN 'CMP0009' THEN 'FY23 Annual Fund' WHEN 'CMP0013' THEN 'FY24 Annual Fund'
        WHEN 'CMP0017' THEN 'FY25 Annual Fund' WHEN 'CMP0021' THEN 'FY26 Annual Fund'
        ELSE TRIM(g.Campaign_Name) END,
    COALESCE(NULLIF(TRIM(g.Designation), ''), 'Unspecified'),
    COALESCE(NULLIF(TRIM(g.Gift_Status), ''), 'Unknown'),
    CASE WHEN TRIM(g.Gift_ID) REGEXP '^G[0-9]+$' THEN 'Stable Source'
         ELSE 'Merged Source' END
FROM gifts_raw AS g
LEFT JOIN (
    SELECT TRIM(Campaign_Name) AS Campaign_Name,
           MIN(TRIM(Campaign_ID)) AS Campaign_ID
    FROM gifts_raw
    WHERE NULLIF(TRIM(Campaign_ID), '') IS NOT NULL
      AND UPPER(TRIM(Campaign_ID)) <> 'NULL'
    GROUP BY TRIM(Campaign_Name)
    HAVING COUNT(DISTINCT TRIM(Campaign_ID)) = 1
) AS cm ON TRIM(g.Campaign_Name) = cm.Campaign_Name;

CREATE TABLE solicitations_clean_final (
    Solicitation_ID VARCHAR(30) NOT NULL,
    Constituent_ID VARCHAR(20) NOT NULL,
    Solicitation_Date DATE NOT NULL,
    Solicitation_Channel VARCHAR(50) NOT NULL,
    Ask_Amount DECIMAL(12,2) NOT NULL,
    Response VARCHAR(50) NOT NULL,
    Attributed_Gift_ID VARCHAR(30),
    Campaign_ID VARCHAR(20) NOT NULL,
    Solicitor_Type VARCHAR(50) NOT NULL,
    Days_To_Gift INT,
    PRIMARY KEY (Solicitation_ID),
    INDEX idx_solicitation_constituent (Constituent_ID),
    INDEX idx_solicitation_campaign (Campaign_ID),
    INDEX idx_solicitation_gift (Attributed_Gift_ID),
    INDEX idx_solicitation_date (Solicitation_Date)
);

INSERT INTO solicitations_clean_final
SELECT
    x.Solicitation_ID, x.Constituent_ID, x.Regenerated_Date,
    x.Solicitation_Channel, x.Ask_Amount, x.Response,
    x.Attributed_Gift_ID, x.Regenerated_Campaign_ID, x.Solicitor_Type,
    CASE WHEN x.Gift_Date IS NULL THEN NULL
         ELSE DATEDIFF(x.Gift_Date, x.Regenerated_Date) END
FROM (
    SELECT
        TRIM(s.Solicitation_ID) AS Solicitation_ID,
        TRIM(s.Constituent_ID) AS Constituent_ID,
        TRIM(s.Solicitation_Channel) AS Solicitation_Channel,
        CAST(TRIM(s.Ask_Amount) AS DECIMAL(12,2)) AS Ask_Amount,
        TRIM(s.Response) AS Response,
        CASE WHEN TRIM(s.Response) = 'Gift' THEN TRIM(s.Attributed_Gift_ID) END AS Attributed_Gift_ID,
        TRIM(s.Solicitor_Type) AS Solicitor_Type,
        g.Gift_Date,
        CASE WHEN TRIM(s.Response) = 'Gift' THEN g.Campaign_ID
             ELSE TRIM(s.Campaign_ID) END AS Regenerated_Campaign_ID,
        CASE WHEN TRIM(s.Response) = 'Gift' THEN
            GREATEST(gc.Start_Date,
                DATE_SUB(g.Gift_Date, INTERVAL MOD(CRC32(TRIM(s.Solicitation_ID)), 31) DAY))
        ELSE
            DATE_ADD(oc.Start_Date,
                INTERVAL MOD(CRC32(TRIM(s.Solicitation_ID)),
                    DATEDIFF(oc.End_Date, oc.Start_Date) + 1) DAY)
        END AS Regenerated_Date
    FROM solicitations_raw AS s
    JOIN campaigns_clean_final AS oc ON TRIM(s.Campaign_ID) = oc.Campaign_ID
    LEFT JOIN gifts_clean_final AS g ON TRIM(s.Attributed_Gift_ID) = g.Gift_ID
    LEFT JOIN campaigns_clean_final AS gc ON g.Campaign_ID = gc.Campaign_ID
) AS x;
