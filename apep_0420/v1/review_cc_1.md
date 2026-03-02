# Internal Review - Round 1

**Reviewer:** Claude Code (internal)
**Paper:** The Visible and the Invisible: Traffic Exposure, Political Salience, and Bridge Maintenance Quality
**Date:** 2026-02-19

## Format Check
- Length: ~25 pages main text, 33 pages total including appendix — PASS
- References: 15 citations covering infrastructure, political economy, monitoring, methodology — adequate
- Prose: Full paragraphs throughout, no bullet-point sections in main text — PASS
- Section depth: All major sections have 3+ paragraphs — PASS
- Figures: 7 figures with visible data, proper axes — PASS
- Tables: 6 tables with real regression output — PASS

## Statistical Methodology
- Standard errors: All coefficients have clustered SEs in parentheses — PASS
- Significance: Stars reported, explicit p-values for AIPW — PASS
- Confidence intervals: 95% CI reported for main spec — PASS
- Sample sizes: N reported in all tables — PASS
- Method: Doubly robust (AIPW) with OLS fixed effects — appropriate for observational design

## Identification Strategy
- Selection on observables with engineering covariates + state×year FE — credible
- AIPW with Super Learner for doubly robust estimation — strong
- Three falsification tests (component gradient, electoral cycle, descriptive heterogeneity) — well-designed
- Cinelli-Hazlett sensitivity analysis — appropriate for null result
- Limitations discussed thoroughly — PASS

## Literature
- Olken (2007), Knight (2015), Burgess et al. (2015) — core references present
- Chernozhukov et al. (2018), Robins et al. (1994) — methodology covered
- Missing: Could cite Fisman & Golden on political corruption, Besley & Burgess on media accountability
- Overall: Adequate for the paper's scope

## Writing Quality
- Strong opening hook ("America's bridges are crumbling")
- Clear narrative arc from motivation through results to implications
- Results tell a story rather than narrating tables
- Good framing of null result as informative contribution
- Conclusion has memorable closing line

## Constructive Suggestions
1. The AIPW subsample (48K of 5.2M) is small — could run on larger subsample
2. Could add geographic heterogeneity (Northeast vs. South)
3. The "three predictions" structure is effective — could be made even more prominent
4. Power analysis could be presented as a formal figure

## Overall Assessment
- **Strengths:** Novel research question, massive dataset, well-designed falsification tests, honest null result
- **Weaknesses:** Observational design (no quasi-experiment), AIPW on small subsample, sensitivity analysis could be expanded
- **Key contribution:** First systematic test of political visibility in U.S. bridge maintenance

DECISION: MINOR REVISION
