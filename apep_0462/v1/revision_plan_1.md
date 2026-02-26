# Revision Plan — Round 1

Based on internal review `review_cc_1.md`.

## Priority 1: Code Fixes (Reproducibility)

1. **Add `set.seed(42)` to 03_main_analysis.R** before first `att_gt()` call
2. **Clean DDD formula in 04_robustness.R** — remove redundant `ddd` variable, use `post:dept_road + post | cell_num + t` to match Equation (3)

## Priority 2: DDD Event Study (New Analysis)

3. **Add DDD event-study specification** in 04_robustness.R:
   - Create relative-time indicators in stacked DDD data
   - Interact `dept_road × rel_time` dummies
   - Plot as new Figure 9 showing how road-type gap evolves around reversal

## Priority 3: Treatment Intensity in DDD Framework

4. **Add DDD intensity specification** in 04_robustness.R:
   - Interact share_pct with dept_road in the stacked data
   - Report in Section 6.5 alongside caveated confounded results

## Priority 4: Paper Text Fixes

5. **Fix intro roadmap** — mention Section 3 (Related Literature)
6. **Clarify 52 vs 50** — note in intro that 52 reversed but 2 excluded
7. **Add COVID mobility citations** to Section 3.2
8. **Break up Limitations** into numbered points
9. **Add 2-3 citations** to Related Literature

## Priority 5: Figures/Tables

10. **Add DDD event study figure** (Figure 9)
11. **Re-run 05_figures.R and 06_tables.R** after code changes
12. **Recompile PDF** and visual QA
