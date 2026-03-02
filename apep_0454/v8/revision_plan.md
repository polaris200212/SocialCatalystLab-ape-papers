# Revision Plan: apep_0454 v8 — Analytical Revision

## Context

Paper 454 v7 (just published) successfully reframed the paper from causal to predictive/descriptive. All three referees recommended MAJOR REVISION, primarily requesting **new analysis** that the text-only v7 could not provide. This revision addresses those analytical demands.

**Parent:** `papers/apep_0454/v7/` (text-only honest reframe, published 2026-02-26)
**New workspace:** `output/apep_0454/v8/`

### Core Problem the Referees Identified

The exit rate (theta_s) is constructed from post-treatment information (2018-2019 active, absent after Feb 2020), creating mechanical pre-trends. Three of four sensitivity checks fail (HonestDiD Mbar=0, augsynth ATT~0, state trends p=0.29). Only conditional RI (p=0.038) supports the finding. The broken-trend model is the key test: does the post-COVID trajectory *accelerate* relative to the pre-existing differential trend?

## Scope: Analytical

New R code in all scripts (01-06). New specifications, new robustness checks, new figures/tables. Paper.tex updated to incorporate new results.

---

## What Changes (6 Workstreams)

### WS1: Pre-Period Exit Rate (01_fetch_data.R) — MUST-FIX [GPT, Grok]

**Problem:** Current theta_s uses post-Feb-2020 absence to classify exits → post-treatment contamination.

**Fix:** New primary measure `exit_rate_pre` = share of 2018-active providers absent from ALL of 2019 billing. Purely pre-treatment.

Changes to `01_fetch_data.R`:
- Identify `active_2018` = NPIs with >=1 claim in 2018
- Identify `active_2019` = NPIs with >=1 claim in 2019
- `exited_pre` = active in 2018 but NOT in 2019
- `exit_rate_pre` = state-level mean(exited_pre)
- Also compute `hcbs_exit_rate_pre` (HCBS-specific)
- Recompute Bartik instrument using pre-period definition: national specialty exit rates (2018→2019) × local 2018 specialty composition
- Retain old `exit_rate_pandemic` for robustness comparison
- Save `state_exits.rds` with both measures

### WS2: Data Truncation (02_clean_data.R) — MUST-FIX [Gemini Advisor]

**Problem:** Late 2024 has reporting lags → provider counts drop to near-zero → contaminates ARPA recovery estimates.

**Fix:** Primary analysis truncated at June 2024. Full sample kept for appendix sensitivity.

Changes to `02_clean_data.R`:
- Filter `panel[month_date <= "2024-06-01"]` for primary analysis
- Save `panel_full.rds` for sensitivity
- Add `time_num` = dense-ranked month index (0, 1, 2, ...) for broken-trend
- Build broken-trend interactions: `exit_x_trend`, `exit_x_post`, `exit_x_post_trend`
- Rename primary exit rate: `panel[, exit_rate := exit_rate_pre]`

### WS3: Broken-Trend Model (03_main_analysis.R) — MUST-FIX [All 3 referees]

**The single most important analytical addition.** Specification:

```
Y_st = alpha_s + delta_t + lambda(theta_s * t) + beta(theta_s * Post_t) + kappa(theta_s * Post_t * t) + gamma*X_st + epsilon_st
```

- `lambda`: ongoing differential trend (identified from pre-period)
- `beta`: level shift at COVID onset
- `kappa`: slope change post-COVID (the key parameter — does the trajectory *accelerate*?)

fixest syntax:
```r
feols(ln_providers ~ exit_x_trend + exit_x_post + exit_x_post_trend + unemp_rate | state + month_date, cluster = ~state)
```

No multicollinearity: month FE absorb common time path; exit_rate_pre provides cross-sectional variation within each month. Pre-period identifies lambda; post-period identifies beta and kappa conditional on pre-trend extrapolation.

Run for: providers, beneficiaries, claims_per_bene, spending_per_bene.

### WS4: Collapsed Cross-Sectional Analysis (03_main_analysis.R) — MUST-FIX [GPT]

Simple pre/post state averages:

```r
delta_ln_s = mean(ln_providers | post) - mean(ln_providers | pre)
lm(delta_ln ~ exit_rate_pre)  # N=51, HC2/HC3 SEs
```

Avoids serial correlation concerns, reduces to 51 cross-sectional obs, directly tests whether higher pre-period attrition → larger pandemic drops. Report alongside panel result.

### WS5: Alternative RI Stratifications (04_robustness.R) — MUST-FIX [GPT]

Current conditional RI permutes within Census divisions (p=0.038). Referees want robustness to alternative conditioning:

1. **Census regions** (4 strata, ~12 states each) — best resolution
2. **Urbanicity quartiles** (from population) — different confound structure
3. **Governor party 2019** (2 strata, ~25 each) — political economy control
4. Keep original unconditional RI and conditional-on-division RI

Use 1,000 permutations per stratification (computation-feasible). Report table of p-values.

### WS6: Entity Type Heterogeneity (04_robustness.R) — MUST-FIX [Gemini]

Split by NPI Entity Type 1 (individual) vs Type 2 (organization). Organization exits may represent dozens of workers. Entity type is available in NPPES data already merged into provider_monthly.

Create entity-type panel in 01_fetch_data.R, clean in 02, run main DiD and event study separately for Type 1 and Type 2. Promote to main table (currently not in paper).

---

## What Also Changes (paper.tex)

- Report broken-trend results (new Table + Figure)
- Report collapsed regression (new Table row or panel)
- Report stratified RI p-values (new Table row)
- Report entity-type split (new Table columns)
- Update all references to "exit rate" to clarify pre-period definition
- Update robustness synthesis paragraph with new results
- Add broken-trend figure (pre-trend extrapolation vs actual)
- Add collapsed scatter plot (exit_rate_pre vs delta_ln)
- Update abstract/results with new primary specification results

## What Does NOT Change

- Overall framing (predictive, established in v7)
- Conceptual framework (Section 3)
- ARPA DDD (Section exploratory — insufficient data for referee demands on ARPA intensity)
- IV section (acknowledge as uninformative per Gemini advisor; retain but don't claim support)
- Deaths-of-despair analysis

## What Is Deferred (acknowledged in reply to reviewers)

- ARPA state-level spending intensity data (requires external CMS data collection)
- Sub-state geographic analysis (ZIP/county — memory-intensive, separate paper scope)
- Waitlist/waiver controls (requires external HCBS waiver data)
- Additional literature citations (McGinn 2021, Ladd 2023, Yamamoto 2022) — add to .bib

---

## Execution Order

1. Create workspace `output/apep_0454/v8/`
2. Copy parent artifacts from `papers/apep_0454/v7/`
3. Modify `01_fetch_data.R` (WS1: pre-period theta, entity-type panel)
4. Modify `02_clean_data.R` (WS2: truncation, time_num, broken-trend interactions)
5. Modify `03_main_analysis.R` (WS3: broken-trend model, WS4: collapsed analysis)
6. Modify `04_robustness.R` (WS5: stratified RI, WS6: entity-type split)
7. Modify `05_figures.R` (broken-trend figure, collapsed scatter, RI comparison)
8. Modify `06_tables.R` (new tables for all new analyses)
9. Run ALL R scripts (00-06) sequentially
10. Update `paper.tex` with new results and figures/tables
11. Add new literature citations to `references.bib`
12. Recompile PDF (pdflatex x3 + bibtex)
13. Visual QA
14. Run full review pipeline (advisor → exhibit → prose → lit audit → referee)
15. Stage C revisions if needed
16. Publish with `--parent apep_0454`

## Verification

- [ ] Primary exit rate is purely pre-treatment (2018 active, absent 2019)
- [ ] Analysis truncated at June 2024
- [ ] Broken-trend model reported (lambda, beta, kappa) for all outcomes
- [ ] Collapsed cross-sectional regression reported (N=51, HC2/HC3)
- [ ] At least 3 RI stratifications reported (division, region, urbanicity/political)
- [ ] Entity Type 1 vs 2 split reported
- [ ] Old exit rate shown as robustness (results similar = no contamination concern)
- [ ] Broken-trend figure shows pre-trend extrapolation vs actual trajectory
- [ ] All existing figures/tables updated with new theta definition
- [ ] Paper is 25+ pages
- [ ] All exhibits regenerated from new R scripts
