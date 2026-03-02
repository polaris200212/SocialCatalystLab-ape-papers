# Revision Plan: APEP-0445 v2

## Context

Paper 0445 ("Building the Cloud in Distressed Communities: Do Opportunity Zones Attract Data Center Investment?") uses an RDD at the 20% poverty threshold to test whether OZ eligibility attracts data center investment. Main finding: precisely estimated null. Three referees reviewed: GPT-5.2 (MAJOR REVISION), Grok (MINOR REVISION), Gemini (MINOR REVISION). All three converge on the same core issues.

**Parent:** `papers/apep_0445/v1/`
**New workspace:** `output/apep_0445/v2/`

---

## Workstream 1: Official OZ Designation Data + Fuzzy RDD (CRITICAL)

All 3 reviewers demand real CDFI designation data instead of the approximation (top 25% by poverty rank).

**Code changes:**
- `01_fetch_data.R`: Replace OZ download with confirmed CDFI URL (`designated-qozs.12.14.18.xlsx`). Add `readxl` for xlsx parsing. Keep approximation as last-resort fallback with loud warning.
- `02_clean_data.R`: Remove silent approximation fallback (lines 83-95). Merge real designation status. Compute actual first-stage jump near cutoff.
- `03_main_analysis.R`: Report first-stage F-statistic for fuzzy RDD. Structure results as: (a) first stage, (b) reduced-form ITT, (c) Wald LATE. If first stage is weak near cutoff, frame transparently — the ITT remains the primary estimand.
- `06_tables.R`: New first-stage table; update summary stats with real OZ rates.

**Paper changes:**
- Section 4.2: Replace "approximation" language with description of official CDFI data
- New subsection in Results: "First Stage and Fuzzy RDD"
- Remove all instances of "approximated" in table notes, figure captions, appendix
- Update Figure 2 caption from "Approximated OZ Designation Pattern" to "First Stage: OZ Designation Probability"

---

## Workstream 2: Systematic Placebo Grid + Local Randomization (HIGH)

GPT flags significant placebos at 10%/15% as concerning. Requests local randomization inference to address McCrary rejection.

**Code changes:**
- `00_packages.R`: Add `rdlocrand` package
- `04_robustness.R`: Replace 6-point placebo with systematic grid (every 1pp from 5-35%, excluding ±2pp around 20). Add `rdlocrand::rdrandinf()` within narrow windows (±1pp, ±0.75pp). Report Fisher exact test p-values.
- `05_figures.R`: New figure — histogram of placebo t-statistics with vertical line at true cutoff. Update existing placebo figure to show full grid.

**Paper changes:**
- Section 6.2: Replace ad-hoc placebo paragraph with systematic grid results
- New paragraph on local randomization inference, citing Cattaneo, Frandsen & Titiunik (2015)
- Strengthens response to McCrary rejection without relying solely on donut RDD

---

## Workstream 3: Spatial Inference + Covariate-Adjusted RDD (HIGH)

GPT requests county-clustered SEs and covariate-adjusted rdrobust.

**Code changes:**
- `03_main_analysis.R`: Add covariate-adjusted `rdrobust(..., covs = covs_matrix)` specifications. Add county-clustered parametric specifications via `feols(..., cluster = ~county_fips)`.
- `05_appendix_tables.R` or new table: Inference robustness table — columns: (a) baseline rdrobust, (b) rdrobust with covariates, (c) parametric HC1, (d) parametric county-clustered.

**Paper changes:**
- New appendix table for inference robustness
- Brief paragraph in Section 6.2 noting robustness to clustering and covariate adjustment

---

## Workstream 4: Infrastructure Heterogeneity (MEDIUM-HIGH)

GPT + Gemini want a direct test of the infrastructure-dominance mechanism.

**Code changes:**
- `01_fetch_data.R`: Fetch ACS internet/broadband variable (B28002 series, same Census API) as infrastructure proxy. If feasible, also try FCC broadband data.
- `02_clean_data.R`: Create `has_broadband` indicator at tract level.
- `04_robustness.R`: Add split-sample RDD by broadband availability. Key test: null persists even in infrastructure-ready tracts.
- `05_figures.R`: New heterogeneity figure (RDD estimates by infrastructure quartile).

**Paper changes:**
- New subsection "Infrastructure Heterogeneity" after urban/rural analysis
- Strengthen Section 6.5 (Mechanisms) with empirical evidence rather than just assertion

---

## Workstream 5: Literature + Framing + Compound Treatment (MEDIUM)

**References to add (`references.bib`):**
- Cattaneo, Idrobo & Titiunik (2020) — RD foundations book
- Cattaneo, Frandsen & Titiunik (2015) — local randomization RD
- Bartik (1991) — classic place-based policy book
- Kassam et al. (2024) — OZ RDD on business entry (AEA P&P)
- Census LODES technical documentation
- Frandsen (2017) or similar — discrete running variables

**Paper changes:**
- Section 5.4 (Compound Treatment): Expand NMTC discussion. Be explicit that ITT captures the full LIC eligibility bundle. Frame as honest limitation, not fatal flaw.
- Abstract: Add sentence acknowledging compound treatment and fuzzy RDD. Keep ≤150 words.
- Consider minor title adjustment to acknowledge the eligibility bundle (e.g., "Do Place-Based Tax Incentives Attract Data Center Investment?")
- Add LODES measurement discussion paragraph citing technical documentation

---

## Workstream 6: Minor Polish (LOW)

- Parametric Table 5: Add explicit dependent variable column headers (Grok)
- Dynamic RDD figure: Label individual years on x-axis (Grok)
- Consistent significance stars across all tables
- Revision footnote in title linking to parent paper

---

## Execution Order

1. Create workspace (`output/apep_0445/v2/`), copy parent code/data
2. **Workstream 1** — OZ data fix (all other analyses depend on corrected dataset)
3. **Workstreams 2-4** — Can partly overlap after W1 completes
4. **Workstream 5** — Literature/framing (parallel with code work)
5. **Workstream 6** — Polish
6. Recompile PDF, visual QA
7. Full review cycle (advisor → exhibit → prose → external → revision)
8. Publish with `--parent apep_0445`

## Verification

- All R scripts run end-to-end producing figures/tables
- PDF compiles with no `??` references
- Page 1 = front matter only, 25+ pages main text
- First-stage F-stat reported for fuzzy RDD
- Local randomization p-values reported
- County-clustered SEs shown
- Infrastructure heterogeneity results present
- All new references resolve in bibliography
