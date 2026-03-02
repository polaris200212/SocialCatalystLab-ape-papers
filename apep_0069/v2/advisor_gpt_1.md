# Advisor Review - GPT-5-mini

**Role:** Academic advisor checking for fatal errors
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-10T14:59:51.789363
**Route:** OpenRouter + LaTeX
**Tokens:** 29915 in / 3211 out
**Response SHA256:** 3e79a1b15cae23af

---

FINDINGS SUMMARY (focus on fatal problems only)

I examined the draft for the four classes of FATAL errors you asked me to check: Data-Design Alignment, Regression Sanity, Completeness, and Internal Consistency. I did not flag any regressions with impossibly large coefficients/standard errors, missing SEs, R² outside [0,1], or placeholder strings (NA/TBD/TODO). However I did find a fatal internal-consistency issue (sample counts) that must be resolved before submission. Because any fatal error forces a FAIL, see details and fixes below.

FATAL ERRORS

FATAL ERROR 1: Internal Consistency — Inconsistent sample counts across the paper
  Location: Main text Table~\ref{tab:summary} (Section 4), Table~\ref{tab:ols_main} (Section 6), Figure/Table captions, and many RDD/diagnostic tables and figures (Sections 6, Appendix)
  Error:
    - The paper repeatedly states the full Gemeinde sample is N = 2,120 (e.g., Section 4: "N = 2,120 Gemeinden"; Table~\ref{tab:summary} reports Treated N=716 + Control N=1,404 = 2,120).
    - Multiple RDD and diagnostic tables/figures use N = 2,108 (e.g., McCrary density description and Figure~\ref{fig:density} caption: "Within the MSE-optimal bandwidth (8.6 km), there are 738 Gemeinden on the treated side and 230 on the control side" and several tables list N = 2,108 in headers/notes; Table~\ref{tab:balance} reports N = 2,108; Table~\ref{tab:placebos} reports N = 2,108; Appendix robustness tables report other Ns like 1,698, 1,632 etc).
    - These different totals (2,120 vs 2,108 vs other Ns) are never explained. It is unclear whether 12 Gemeinden were dropped for particular analyses (missing data, merged municipalities, border calculations, excluded islands) or whether there are coding/harmonization errors.
    - Because many identification strategies rely on exact sample definitions (RDD bandwidth selection, McCrary density, permutation pools), an unexplained mismatch in the base sample is a fatal issue: reviewers/journal editors will consider this a data/documentation error that can produce misleading SEs, p-values, and coverage statements.
  Why fatal:
    - Internal consistency of sample construction and reporting is fundamental: readers and referees must be able to reconcile the N used in each table/figure with the described data pipeline. Unexplained differences create doubt about which observations were included in which analysis, whether treatment coding aligns with the outcome data, and whether diagnostics (density tests, permutations) are valid for the claimed sample.
  Fix:
    1. Add a clear, single canonical statement in the Data section (and repeat in Appendix Data Appendix) that documents exactly how the full sample is constructed: starting BFS municipal master list, any municipality mergers harmonization, how many municipalities are present after harmonization, and the precise reason(s) why any municipalities are excluded from any analysis (e.g., missing referendum result, missing centroid geometry, island municipalities not adjacent to any treated-control border, municipalities with ambiguous canton code).
    2. Produce and include a short table (or list) showing the municipalities that are excluded relative to the "full" sample: show Municipality ID, canton, reason for exclusion (e.g., missing vote, geometry error), and which analyses exclude them. If the difference (12 municipalities) is due to merges or dropped observations, show that explicitly.
    3. Re-run all analyses so that every table/figure uses a clearly labeled sample and make the N consistent with that label. For example:
       - If the full harmonized sample is 2,120, state that and use that N in OLS tables; if RDD necessarily restricts to municipalities within X km of a border, report the RDD-specific N and explain it in the table note.
       - Where you report N = 2,108, add a table note ("Sample restricted to municipalities with non-missing centroid and referendums; 12 Gemeinden excluded because ...") and cross-reference the exclusion list.
    4. Update the text that currently implies "full sample" to precisely mention when analyses use subsamples (RDD bandwidth subset, donut exclusions, border-pair subsets) and ensure each table/figure caption states the exact N used and why it differs from the full N.
    5. Recompute and confirm that any permutation / stratified RI pools are drawn from the exact sample and report the permutation pool and sample in the RI appendix (you already report 5 of 17 German-speaking; ensure that 17 is computed from the same harmonized canton list used elsewhere).
    6. Re-run McCrary and balance tests after clarifying sample and report the exact counts (left/right) used in those tests, with a footnote explaining any asymmetry (e.g., larger land area on one side).
  Evidence to include after fixing:
    - A short ".csv" (or appendix table) listing the municipalities and a column "included_in_analysis = yes/no" and reason; or if data-sharing policy forbids listing names, report counts broken down by canton and reason for exclusion.
    - Revised tables/figures with consistent N labelling and updated notes.

FATAL ERROR 2: Internal Consistency — Ambiguous treatment-cohort coding and exclusion rules for Callaway–Sant'Anna
  Location: Section 5.5 (Panel Analysis), Table~\ref{tab:cs_detail} (Appendix), and Summary Table~\ref{tab:summary_results}
  Error:
    - The main text states that cohort timing uses in-force years GR=2011, BE=2012, AG=2013, BL=2016, and that Basel-Stadt (BS) is excluded from Callaway–Sant'Anna because "treatment coincides with the final period." That is plausible, but the Appendix Callaway--Sant'Anna table includes group-time ATTs for periods 2016 and 2017 for the 2011 cohort, 2012 cohort, etc., and the aggregate ATT is reported as computed with Basel-Stadt excluded. It is not explicitly documented which cantons are included in each cohort for the CS estimator, whether BS was excluded from the whole CS sample (i.e., canton dropped) or only from cohort-specific ATTs, and whether the panel uses 25 or 26 cantons (some tables show 25×4=100 observations). The footnote says "Basel-Stadt is excluded because its treatment coincides with the final period," but later the Callaway table's "N = 25 cantons × 4 referendum periods = 100 canton-period observations" line is present; this must be stated clearly in the main methods and appendix and aligned with the sample-count inconsistency above.
  Why fatal:
    - Modern DiD estimators (Callaway–Sant'Anna) are sensitive to cohort definition and sample composition; leaving cohort inclusion/exclusion ambiguous undermines the interpretability of the ATT and the validity of the comparison to TWFE.
  Fix:
    1. Explicitly state, in the main methods and in the Appendix where the CS results appear, the exact set of cantons used in the Callaway–Sant'Anna estimation and the reason for excluding BS (and confirm whether any other canton was excluded).
    2. State whether the CS estimator uses all four referendum time points or whether first/last periods are omitted for certain cohorts (common in practice). Provide the exact event-time window used to compute group-time ATTs.
    3. Re-run and report the CS estimator both with and without BS (and show robustness). If BS is excluded, include a short sensitivity table showing the aggregate ATT when BS is included (if feasible) and explicitly document why it cannot be included (e.g., no post period).
    4. Ensure the "N" reported for CS (100 canton-period obs) is reconciled with the full-sample N and with the number of cantons used in other analyses.

Notes on other checks (not fatal)
  - Regression Sanity: I inspected all regression tables for impossible SEs, coefficients, or R² values; none violate the numeric sanity checks you asked me to enforce (no SE > 1000, no |coeff| > 100 for outcomes, R² in [0,1], etc.).
  - Completeness: I found no placeholders (NA/TBD/TODO), and standard errors and Ns are reported in the main regression tables. However, the unexplained sample-count mismatch triggers the fatal internal-consistency problem above.
  - Data-Design Alignment: Treatment timing vs data coverage appears consistent (BL in force July 2016 → treated for Nov 27 2016 referendum; BS in force Jan 2017 → treated for May 21 2017 referendum). The stated rule "treatment if in force by referendum date" appears consistently applied in text, tables, and the timing crosswalk. Just ensure the earlier fixes reconcile any municipality exclusions so the max(treatment year) ≤ max(data year) check remains verifiable.

CONCLUSION (required)

ADVISOR VERDICT: FAIL

(Resolve the two fatal internal-consistency issues above—especially the unexplained sample-count mismatches and the explicit documentation of Callaway–Sant'Anna cohort inclusion/exclusion—then re-run analyses/tables/figures and produce corrected tables with clear notes explaining any analyses that use subsamples. Once those fixes are made and the Ns and sample construction are fully documented and consistent across the paper and appendix, the manuscript can be re-assessed for referee-ready submission.)