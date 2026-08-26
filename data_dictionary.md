# Data Dictionary

The project uses four synthetic source tables and four analysis-ready tables. Raw fields are imported as text so that type conversion and quality controls remain visible in SQL.

## `constituents_clean_final`

| Field | Type | Description |
|---|---|---|
| `Constituent_ID` | VARCHAR(20) | Unique constituent identifier and primary key |
| `Display_Name` | VARCHAR(150) | Trimmed name with honorific removed and reviewed corrections applied |
| `Honorific` | VARCHAR(10) | Standardized title: Dr., Mr., Mrs., or Ms. |
| `Email` | VARCHAR(255) | Lowercase email; malformed synthetic usernames repaired deterministically |
| `Phone` | VARCHAR(40) | Trimmed phone number; missing strings converted to NULL |
| `City` | VARCHAR(100) | Standardized city capitalization |
| `State` | VARCHAR(10) | Standardized state abbreviation |
| `ZIP` | VARCHAR(20) | Postal code retained as text to preserve leading zeros |
| `Country` | VARCHAR(100) | Country value |
| `Age_Band` | VARCHAR(30) | Valid values: 18-29, 30-49, 50-65, 66-80 |
| `Gender` | VARCHAR(50) | Synthetic demographic category |
| `Sector` | VARCHAR(100) | Constituent sector/category |
| `Newsletter_Opt_In` | VARCHAR(10) | Standardized opt-in indicator |
| `Date_Added` | DATE | Constituent acquisition date |
| `Acquisition_Source` | VARCHAR(100) | Standardized acquisition channel |
| `Preferred_Contact_Method` | VARCHAR(100) | Preferred channel or contact-information remediation flag |
| `Constituent_Status` | VARCHAR(50) | Constituent lifecycle status |
| `Volunteer_Flag` | VARCHAR(10) | Volunteer engagement indicator |
| `Age_Band_Issue_Flag` | TINYINT | 1 when a source age-band value was invalid |
| `Missing_Date_Added_Flag` | TINYINT | 1 when source acquisition date was missing |

## `campaigns_clean_final`

| Field | Type | Description |
|---|---|---|
| `Campaign_ID` | VARCHAR(20) | Unique campaign identifier and primary key |
| `Campaign_Name` | VARCHAR(150) | Campaign display name |
| `Campaign_Type` | VARCHAR(100) | Annual Fund, Event, Seasonal Appeal, Year-End, or program category |
| `Start_Date` | DATE | Validated campaign start date |
| `End_Date` | DATE | Validated campaign end date |
| `Goal` | DECIMAL(12,2) | Fundraising goal |

## `gifts_clean_final`

| Field | Type | Description |
|---|---|---|
| `Gift_ID` | VARCHAR(30) | Unique transaction identifier and primary key |
| `Constituent_ID` | VARCHAR(20) | Donor identifier |
| `Gift_Date` | DATE | Transaction date |
| `Gift_Amount` | DECIMAL(12,2) | Signed transaction amount; refunds/adjustments remain negative |
| `Transaction_Type` | VARCHAR(50) | Gift, Recurring Gift, Refund, or Adjustment |
| `Gift_Method` | VARCHAR(50) | Standardized channel such as Online, Mail, Event, ACH, Phone, or In Person |
| `Campaign_ID` | VARCHAR(20) | Associated campaign identifier; inferred from uniquely mapped campaign name when missing |
| `Campaign_Name` | VARCHAR(150) | Standardized campaign name |
| `Designation` | VARCHAR(150) | Intended fund or program |
| `Gift_Status` | VARCHAR(50) | Transaction status |
| `Gift_Source` | VARCHAR(30) | Stable Source or Merged Source, derived from source ID format |

## `solicitations_clean_final`

| Field | Type | Description |
|---|---|---|
| `Solicitation_ID` | VARCHAR(30) | Unique solicitation identifier and primary key |
| `Constituent_ID` | VARCHAR(20) | Solicited constituent |
| `Solicitation_Date` | DATE | Regenerated synthetic date constrained to the campaign window |
| `Solicitation_Channel` | VARCHAR(50) | Email, Mail, Phone, In Person, or Event |
| `Ask_Amount` | DECIMAL(12,2) | Solicitation amount |
| `Response` | VARCHAR(50) | Gift, Declined, or No Response |
| `Attributed_Gift_ID` | VARCHAR(30) | Gift attributed to a successful solicitation, otherwise NULL |
| `Campaign_ID` | VARCHAR(20) | Campaign used for performance attribution |
| `Solicitor_Type` | VARCHAR(50) | Solicitor category |
| `Days_To_Gift` | INT | Days between solicitation and attributed gift |

## Derived analytical fields

| Field | Definition |
|---|---|
| Fiscal year | September 1-August 31; named for the ending calendar year |
| Active donor | Constituent with at least one positive completed gift in the fiscal year |
| Retained donor | Prior-year donor who also gave in the immediately following fiscal year |
| Retention rate | Retained donors divided by all prior-year donors |
| Repeat donor | Donor with more than one positive completed transaction |
| Percent of goal | Net campaign revenue divided by campaign goal |
| Stable-source cohort | Transactions from the source with continuous FY21-FY26 coverage |
