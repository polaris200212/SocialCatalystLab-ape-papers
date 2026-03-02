# Reply to Reviewers — v5 Revision

This revision (v5) primarily addresses findings from the GPT-5.2 code review scan. We also address actionable points from the tri-model referee panel below.

---

## Response to GPT-5.2 Code Scan (6 issues)

### Issue 1 (HIGH): 2020 data included in fetch range
**Response:** Fixed. Changed `years <- 2017:2024` to `years <- c(2017:2019, 2021:2024)` with explicit comment. Added defensive filter in `02_clean_data.R`. The 2020 exclusion was always operative (Census API returns error for 2020 1-year PUMS), but the code now makes this explicit.

### Issue 2 (MEDIUM): Treatment dates lack month/day granularity
**Response:** Fixed. Added `effective_month`, `effective_day`, `effective_year` columns with source citations for all 49 states. Documented July 1 half-year rule and borderline cases.

### Issue 3 (LOW): Treatment dates lack source citations
**Response:** Fixed. Each state now has a `source` column citing CMS press releases, KFF tracker, ASPE Appendix Table 1, state Medicaid agency announcements, or multiple cross-referenced sources.

### Issue 4 (LOW): Monte Carlo calibration could be confused for analysis data
**Response:** Fixed. Replaced Monte Carlo simulation with closed-form deterministic enumeration (144 cells, no random draws). Eliminates any ambiguity about simulated data.

### Issue 5 (MEDIUM): post_phe year-level coding coarser than PHE end date
**Response:** Documented. Added comments explaining that ACS is annual data, `post_phe = year >= 2023` is the appropriate coding, and the 2024-only robustness spec addresses the mixed-2023 issue. Added disclosure in Limitations section of paper.

### Issue 6 (LOW): DDD vcov diagonal approximation
**Response:** Improved. Code now attempts full covariance matrix from CS-DiD influence functions, with documented fallback to diagonal approximation. Added footnote in paper text.

---

## Response to External Referee Panel

### Reviewer 1 (GPT-5-mini): MAJOR REVISION

**Thin control group (4 states):** We acknowledge this limitation throughout. The DDD design provides within-state variation that partially mitigates this. Leave-one-out analysis confirms no single control state drives results.

**Increase permutation count to 1000+:** We note this recommendation for future revisions. The current 200 permutations are computationally intensive (each reruns the full CS-DiD pipeline) and the resulting p-value (0.750) is far from any significance boundary, so additional permutations would not change inference.

**Permutation design details:** The permutation reassigns adoption timing across states while maintaining the number of states in each cohort. We will add this documentation in a future revision.

### Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

The review was highly positive ("gold-standard robust" inference, "exemplary" methodology). Minor suggestions noted for future improvements.

### Reviewer 3 (Gemini-3-Flash): MINOR REVISION

**Units clarification (proportions vs. pp):** Added note to Table 2 clarifying that coefficients are in proportions. Text consistently uses percentage points for readability.

**Blank cells in Table 2:** Added note clarifying that blank cells in Panels B–D are intentionally omitted specifications.

---

## Exhibit Review Response

**Balance test p-values:** Noted for future revision. The summary statistics table shows broad comparability; formal tests with 4 control states would have low power.

**Move Figure 5 to appendix:** Retained in main text for this revision; will consider reorganization in future versions.

## Prose Review Response

**Opening hook:** Noted for future revision. The current opening is informative if less dramatic.

**Meta-discussion removal:** Will consider streamlining in future versions.

---

*All code scan issues are addressed in this v5 revision. Referee panel suggestions that require additional computation or major restructuring are deferred to future revisions.*
