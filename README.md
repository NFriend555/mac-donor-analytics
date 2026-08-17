# Donor Retention & Fundraising Performance Analysis

## Project Overview

This project analyzes donor retention, fundraising growth, acquisition, volunteer engagement, campaign performance, and solicitation response for Murmuration Avian Conservancy, a simulated nonprofit organization.

I used Excel Power Query, MySQL, and Tableau to clean, validate, analyze, and visualize more than 76,000 relational fundraising records spanning FY21–FY26.

[View the Interactive Tableau Dashboards](https://public.tableau.com/views/MAC_Donor_Retention_and_Giving/MACFundraisingPerformance)

### Donor Retention & Engagement

![Donor Retention and Engagement Dashboard](donor-retention-engagement.png)

### Fundraising & Campaign Performance
![Fundraising and Campaign Performance](fundraising-campaign-performance.png)

## Business Questions

- How have donor participation, retention, and giving changed over time?
- Which acquisition sources generate the strongest donor conversion?
- Does volunteer participation relate to repeat giving?
- Which campaigns perform best against their fundraising goals?
- Which solicitation channels generate the strongest response?

## Tools

- **MySQL:** Data cleaning, validation, relational joins, cohort analysis, and analytical views
- **Tableau:** Interactive dashboards and executive visualizations
- **Excel Power Query:** Source preparation and data profiling

## Dataset

The analysis includes:

- 11,202 constituents
- 42,521 gift transactions
- 31 campaigns
- 22,550 solicitations

The data is synthetic and anonymized and does not represent a real nonprofit organization.

## Dashboards

### Donor Retention & Engagement

![Donor Retention and Engagement Dashboard](donor-retention-engagement.png)

### Fundraising & Campaign Performance

![Fundraising and Campaign Performance Dashboard](fundraising-campaign-performance.png)

## Key Findings

- Stable-source active donors increased from 2,078 in FY22 to 3,377 in FY26.
- Donor retention remained between 63.3% and 68.2%, reaching 68.0% in FY26.
- Donor-volunteers achieved a 57.9% repeat-giving rate, compared with 49.8% among non-volunteers.
- Stable-source gross giving increased from approximately $1.27M in FY21 to $2.12M in FY26.
- Email generated the highest solicitation response rate at 9.5%.
- Annual Fund campaigns achieved between 110.7% and 157.3% of goal.

## Data-Quality Finding

Validation revealed that one merged gift source covered only June 2023–June 2025, while the original source covered FY21–FY26. The incomplete coverage reduced apparent FY25 retention to 44.6%.

Rather than deleting valid records or manufacturing activity, I preserved the source difference, documented the limitation, and developed comparable-cohort logic. This produced a stable-source FY25 retention rate of 65.1%.

## Recommendations

- Prioritize volunteer-to-donor stewardship because donor-volunteers demonstrate stronger repeat engagement.
- Use Email for scalable solicitation volume and Event or Mail outreach strategically for larger gifts.
- Investigate Online Advertising’s low conversion before increasing acquisition investment.
- Reassess Annual Fund targets because every displayed annual campaign exceeded goal.
- Apply source-coverage monitoring during CRM migrations and vendor-feed integrations.

## Limitations

This portfolio project uses synthetic and anonymized open-source data. Source-coverage differences require stable-source cohorts for comparable year-over-year analysis. Synthetic solicitation timing should not be interpreted as evidence of an optimal real-world solicitation window.
