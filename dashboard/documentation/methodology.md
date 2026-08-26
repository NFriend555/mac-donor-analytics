# Methodology

## Workflow

1. **Source preparation:** Excel Power Query was used for initial file review, schema alignment, and repeatable source preparation.
2. **Raw landing layer:** Source values were loaded into MySQL as text to preserve the original inputs.
3. **Profiling:** SQL measured completeness, uniqueness, type validity, category consistency, date ranges, and referential integrity.
4. **Cleaning:** Analysis-ready tables standardized dates, nulls, names, geographic values, acquisition sources, gift methods, campaign mappings, and solicitation attribution.
5. **Validation:** Row preservation, key uniqueness, orphan checks, financial exceptions, campaign windows, and response-to-gift relationships were tested.
6. **Analytical layer:** Reusable MySQL views calculated fiscal-year donor activity, retention, campaign performance, solicitation response, acquisition conversion, and repeat giving.
7. **Visualization:** Tableau presented donor retention and engagement alongside fundraising and campaign performance.

## Reproducible SQL sequence

Run the scripts in `/sql` from `01` through `06`. Scripts assume MySQL 8.0 or later. The source CSV files are not published; the setup script documents the landing schemas required to reproduce the workflow with equivalent data.

## Important analytical decisions

- Fiscal years run September 1-August 31.
- Refunds and adjustments remain in the dataset as negative values rather than being deleted.
- Donor participation uses positive completed gifts; financial totals may use net transaction value.
- Missing campaign IDs are filled only where a campaign name maps uniquely to one campaign ID.
- A stable-source cohort is used for comparable retention trends when merged-source coverage is incomplete.
- Synthetic solicitation dates were regenerated deterministically inside valid campaign windows. The deterministic procedure supports reproducibility but is not evidence of real donor timing behavior.
