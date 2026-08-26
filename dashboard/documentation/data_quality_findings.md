# Data-Quality Findings

## Constituent records

- Leading/trailing and repeated whitespace required normalization.
- State and city values contained inconsistent capitalization.
- Honorifics were embedded in display names and were separated into a dedicated field.
- Name casing and a small set of high-confidence misspellings required correction.
- 190 synthetic email usernames contained consecutive periods and were rebuilt using deterministic name-based logic after collision testing.
- Acquisition sources contained synonymous labels such as `E-news`, `Newsletter`, and `Email Newsletter`.
- Preferred contact methods were unusable where the corresponding email, phone, or mailing fields were missing; these records were flagged for remediation rather than discarded.

## Gift records

- Missing gift methods were retained as `Unknown` rather than inferred without evidence.
- Gift-method synonyms were standardized into common reporting categories.
- Seventy-two missing campaign IDs were mapped where campaign name had a unique ID relationship.
- Seventy-six negative transactions represented refunds or adjustments and were retained to preserve financial accuracy.
- Merged gift IDs revealed a second source with incomplete date coverage.

## Campaign and solicitation records

- Campaign dates required corrections for year-end and event records plus month-end alignment for seasonal appeals.
- Gift and campaign relationships were checked after campaign-ID mapping.
- Solicitation-to-gift relationships contained timing and campaign inconsistencies in the synthetic source. Dates and successful-gift campaign IDs were regenerated deterministically, then revalidated.

## Quality-control principle

Valid exceptions were documented rather than deleted. Corrections were limited to deterministic transformations, unique mappings, and high-confidence records reviewed during profiling.
