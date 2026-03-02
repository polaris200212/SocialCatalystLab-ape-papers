# Revision Plan: apep_0448 v3 — NPI Entity Type Decomposition

## Context

apep_0448 is the #1 ranked APEP paper (22.6 conservative, 10W-0L). v2 fixed code integrity (hand-edited tables). Three referees then gave MAJOR/MAJOR/MINOR, converging on two substantive concerns:

1. **Billing NPI ≠ workers.** The paper claims "providers returning to work" but billing NPIs can be organizations. Both GPT and Grok want NPPES Entity Type decomposition (individual vs organization).
2. **ARPA §9817 confounding.** All referees flagged it. The paper discusses it but doesn't test it empirically.

**Critical discovery:** The paper's Limitations section (line 394) says "The T-MSIS extract used here does not include the NPPES entity type classification, so I cannot decompose the effect along this margin." This is **factually wrong** — `01_fetch_data.R` line 28 already extracts `entity_type` from NPPES, merges it into `hcbs_npi_month.rds`, then aggregates it away at lines 64-69 when rolling up to state×month. The data is sitting there. We just need to use it.

**Goal:** Deliver the NPI entity type decomposition (the single highest-value revision), increase RI permutations, and let the results speak. Don't chase every referee suggestion — the ARPA concern is fundamentally hard to resolve and the existing mitigations (partisan lag, uniform FMAP, BH placebo) are as far as we can credibly go without data that doesn't exist at the needed granularity.

## What This Revision Does

### 1. Entity Type Decomposition (new analysis)

Build entity-type-stratified state×month panels from `hcbs_npi_month.rds` (which already has `entity_type`). Run CS-DiD separately for:
- **Type 1 (Individual):** If the effect concentrates here → validates "workers returning to labor force" interpretation
- **Type 2 (Organization):** If concentrated here → reframes as "agency billing reactivation," still meaningful but different story

**New code: `02b_entity_type_panels.R`**
- Read `hcbs_npi_month.rds` (has billing_npi, state, entity_type, paid, claims, benes, CLAIM_FROM_MONTH)
- Create two state×month panels: `hcbs_type1.rds` and `hcbs_type2.rds`
- Merge treatment timing from `ui_termination.rds`
- Add same variables as `02_clean_data.R`: g_period, state_id, period, ln_providers, etc.

**New code: `03b_entity_type_analysis.R`**
- Run CS-DiD (`att_gt` + `aggte`) on each panel for providers outcome
- Run event studies for each entity type
- Save results to `entity_type_results.rds`

**New exhibits:**
- **Table (in paper):** Entity type decomposition table showing ATT for Type 1 vs Type 2
- **Figure (in paper):** Side-by-side event studies for Type 1 vs Type 2 providers
- **Appendix table:** Pre-treatment NPI counts by entity type × treatment status (balance check)

### 2. Increase CS-DiD RI Permutations (200 → 1,000)

In `04_robustness.R`, change `n_perms_cs <- 200` to `n_perms_cs <- 1000`. Each permutation takes ~3-5 seconds, so ~1 hour of compute. This is the realistic middle ground — stabilizes the p-value and shrinks Monte Carlo error without the 5-7 hours GPT wants.

Also increase TWFE RI from 500 → 1,000 for consistency (TWFE is fast, ~10 minutes total).

### 3. Fix the Factual Error in Limitations

Replace the incorrect claim at line 394 with the actual entity type results. This section becomes a strength, not a limitation.

### 4. Update Paper Text

- **New subsection in Results (Section 6):** "Entity Type Decomposition" presenting the Type 1 vs Type 2 results
- **Limitations:** Remove the incorrect "cannot decompose" claim, replace with actual findings
- **Mechanism discussion:** Strengthen or reframe based on which entity type drives the effect
- **Abstract/conclusion:** Update if entity type results change the interpretation

## What This Revision Does NOT Do

- **No ARPA spending analysis.** State-level ARPA HCBS plan submission dates don't exist at monthly granularity. The existing mitigations (Section 7.4) are adequate.
- **No dose-response by replacement rate.** Interesting but thin variation (most states have similar Medicaid reimbursement rates for HCBS). Risk of null that muddies rather than clarifies.
- **No Rambachan-Roth sensitivity.** Computationally uncertain with 41 pre-periods in CS-DiD. The event study pre-trends are visually clean.
- **No COVID controls.** Post-treatment variables; conditioning on them could introduce bias.
- **No border-county design.** Data is state-level billing NPIs, no sub-state geography.
- **No additional placebo sectors.** BH placebo is adequate for the wage mechanism channel.

## Execution Order

1. Create v3 workspace, copy from v2
2. Write `02b_entity_type_panels.R` — build Type 1/Type 2 panels from existing `hcbs_npi_month.rds`
3. Write `03b_entity_type_analysis.R` — CS-DiD by entity type
4. Edit `04_robustness.R` — increase RI to 1,000 permutations
5. Edit `05_figures.R` — add entity type event study figure
6. Edit `06_tables.R` — add entity type decomposition table
7. Edit `paper.tex` — new results subsection, fix limitations, update abstract/conclusion
8. Re-run full pipeline: `01` through `06` plus new `02b` and `03b`
9. Compile PDF
10. Review pipeline (advisor → exhibit → prose → referee → Stage C)
11. Publish with `--parent apep_0448`

## Files Modified

| File | Change |
|------|--------|
| `code/02b_entity_type_panels.R` | **NEW** — Build Type 1/Type 2 state×month panels |
| `code/03b_entity_type_analysis.R` | **NEW** — CS-DiD by entity type, event studies |
| `code/04_robustness.R` | Increase CS-DiD RI 200→1,000, TWFE RI 500→1,000 |
| `code/05_figures.R` | Add entity type event study figure |
| `code/06_tables.R` | Add entity type decomposition table |
| `paper.tex` | New results subsection, fix limitations, revision footnote |

## What Does NOT Change

- Research question, identification strategy, treatment definition
- Main CS-DiD ATT estimates (unchanged — entity type is additive analysis)
- Behavioral health placebo
- Triple-difference
- Regional robustness (South, Midwest)
- 2019 placebo timing test

## Verification

1. After `02b`: Check that `hcbs_type1.rds` and `hcbs_type2.rds` exist, have correct dimensions, and n_providers_type1 + n_providers_type2 ≈ n_providers (may not sum exactly due to NPIs billing under both types)
2. After `03b`: Check `entity_type_results.rds` has CS-DiD results for both types
3. After `04`: Check `robustness_results.rds` has 1,000 CS-DiD permutations
4. After compile: Visual QA — entity type table and figure appear, limitations text updated
5. Key interpretive check: Does the Type 1 vs Type 2 split change the story? If Type 2 dominates, we need to reframe from "workers returning" to "organizational billing reactivation" — be honest about this
