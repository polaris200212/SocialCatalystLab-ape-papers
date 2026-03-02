# Human Initialization
Timestamp: 2026-03-02T15:25:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0448
**Parent Title:** Back to Work? Early Termination of Pandemic Unemployment Benefits and Medicaid Home Care Provider Supply
**Parent Decision:** SUSPICIOUS integrity scan — methodology mismatch in randomization inference code
**Revision Rationale:** Fix code integrity gap where published tables contain results not produced by the committed R code (CS-DiD RI p-value, 95% CIs, significance stars). Minimal content revision focused on ensuring full replicability.

## Key Changes Planned

- Add CS-DiD randomization inference to 04_robustness.R (200 permutations via att_gt + aggte)
- Update 06_tables.R to generate 95% CIs and significance stars in Table 3 programmatically
- Update 06_tables.R to generate both CS-DiD and TWFE RI rows in Table 4 from code
- Re-run full pipeline so all tables/figures are code-generated with no hand edits

## Original Reviewer Concerns Being Addressed

1. **GPT-5.2 (Critical):** RI runs on TWFE, not CS-DiD estimator -> Implementing proper CS-DiD RI
2. **Code Integrity Scan:** Tables contain phantom results not backed by code -> Ensuring code generates all table content

## Inherited from Parent

- Research question: Effect of early UI benefit termination on Medicaid HCBS provider supply
- Identification strategy: CS-DiD (Callaway-Sant'Anna) with 26 treated states, 25 controls
- Primary data source: T-MSIS Medicaid Provider Spending (227M rows)
