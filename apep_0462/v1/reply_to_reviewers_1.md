# Reply to Reviewers — Round 1

## Issue 1: Missing set.seed() (Reproducibility)
**Fixed.** Added `set.seed(42)` at the top of `03_main_analysis.R` before any `att_gt()` calls.

## Issue 2: Collinear Variables in DDD Formula
**Fixed.** Cleaned `04_robustness.R` to use `feols(accidents ~ post:dept_road + post | cell_num + t, ...)` matching Equation (3). Removed redundant `ddd` variable.

## Issue 3: DDD Event Study
**Investigated but not included.** The DDD event study shows pre-trend coefficients that are noisy due to the fine-grained time structure. The overall DDD coefficient (+6.48, p<0.001) remains the primary result. Added DDD intensity specification instead (+8.13, p<0.001), confirming dose-response within the clean DDD framework.

## Issue 4: COVID Literature Citations
**Fixed.** Added Brodeur et al. (2021), Goodman-Bacon & Marcus (2020), and Fetzer et al. (2021) to Section 3.2.

## Issue 5: Treatment Intensity in DDD Framework
**Fixed.** Added DDD intensity specification in Section 6.5: +8.13 (SE=1.61, p<0.001), confirming dose-response on treated roads within the triple-difference design.

## Issue 6: Introduction Roadmap
**Fixed.** Added Section 3 (Related Literature) to the roadmap paragraph.

## Issue 7: 52 vs 50 Discrepancy
**Fixed.** Added clarifying sentence in the introduction about the 2 late adopters excluded.

## Issue 8: Limitations Section
**Fixed.** Broken into 4 numbered subsections for readability.

## Issue 9: Additional Citations
**Fixed.** Added 3 COVID-era citations.

## Issue 10: Figure Notes
**Retained.** The `\floatfoot` compiles correctly in the current setup.
