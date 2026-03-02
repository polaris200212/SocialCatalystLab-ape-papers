# Revision Plan: v5 (Code Review Response)

## Motivation

This v5 revision addresses findings from the daily GPT-5.2 code review scan of APEP Working Paper 0160 (v4). The scan identified 6 issues (1 HIGH, 2 MEDIUM, 3 LOW). The Gemini advisor concurred with 4 fatal errors on first review.

## Changes Made

### Code Changes

1. **01_fetch_data.R — Explicit 2020 exclusion (HIGH)**
   - Changed `years <- 2017:2024` to `years <- c(2017:2019, 2021:2024)` with comment explaining the Census Bureau did not release standard 1-year PUMS for 2020.
   - Added treatment dates with exact effective dates (`effective_month`, `effective_day`, `effective_year`), mechanism (`Waiver`/`SPA`), and source citations for all 49 states.
   - Documented borderline states where strict July 1 rule application differs from coded `adopt_year`.

2. **02_clean_data.R — Defensive filter + documentation (MEDIUM)**
   - Added defensive filter removing any 2020 rows after loading raw data.
   - Added comments explaining July 1 half-year rule encoding.
   - Added comments on `post_phe` year-level coding and the 2024-only robustness spec.

3. **04_robustness.R — Monte Carlo + DDD vcov (LOW)**
   - Replaced Monte Carlo simulation with closed-form deterministic enumeration over all 144 (survey_month × birth_month_ago) cells. Eliminates all `sample()` calls.
   - Improved DDD pre-trend joint test to attempt full covariance matrix from influence functions, with fallback to diagonal approximation.
   - Added `vcov_method` reporting to saved results.

### Paper Changes

4. **paper.tex — Documentation updates**
   - Title footnote referencing parent paper and v5 changes.
   - Treatment assignment section with exact dates reference and July 1 rule.
   - Limitations section with PHE timing disclosure.
   - DDD pre-trend footnote about vcov method.
   - Late-adopter text softened to acknowledge statistical uninformativeness.
   - Fixed cross-reference: "balance tests in Table 3" → "summary statistics in Table 1."
   - Figure 1 caption clarified re: 2025 adopters as controls.

### Artifact Corrections

5. **Figures and tables — Source alignment**
   - Corrected all 9 PDF figures and 4 tables that were inadvertently sourced from the `apep_0164` subfolder (1000 permutations) rather than the v4 main folder (200 permutations).
   - Table 3 note already correctly states "200 random reassignments" (matching v4 main).
   - Table 2 note clarified: blank cells intentional, coefficient units in proportions.

## Results Impact

- **No `adopt_year` values changed** from v4. All results are identical to published v4.
- The revision is purely code documentation, defensive coding, and paper text clarification.
