# Internal Review — Round 1

**Paper:** Faster and Deadlier? Disentangling Speed Limit Reversals from Pandemic Confounds in France
**Reviewer:** Claude Code (Reviewer 2 + Editor)
**Verdict:** MAJOR REVISION

---

## Summary

This paper studies the staggered reversal of French speed limits from 80 km/h back to 90 km/h across 50 départements. The key contribution is showing that a naive DiD is confounded by COVID-era mobility shocks, demonstrated via an autoroute placebo failure, and developing a triple-difference (DDD) that recovers a positive, significant effect of +6.5 additional accidents per département-quarter. The research question is timely, the identification narrative is compelling, and the DDD solution is well-motivated.

However, several issues require revision before proceeding to external review.

---

## Major Issues

### 1. Missing set.seed() in 03_main_analysis.R
The Callaway-Sant'Anna estimator uses bootstrap for standard errors by default. Without `set.seed()` before `att_gt()` calls, results are not exactly reproducible. This is a replication concern.

**Fix:** Add `set.seed(42)` at the top of 03_main_analysis.R.

### 2. Collinear Variables in DDD Specification
In `04_robustness.R` line 86, the formula is:
```r
feols(accidents ~ ddd + post:dept_road + post | cell_num + t, ...)
```
But `ddd = post * dept_road` (line 82) is identical to `post:dept_road`. This creates perfect collinearity. While fixest silently drops one, this is sloppy and could confuse replicators. The formula should be cleaned to match the paper's equation (3).

**Fix:** Use `feols(accidents ~ post:dept_road + post | cell_num + t, ...)` and rename the coefficient properly.

### 3. No DDD Event Study
The paper's headline result is the DDD, but the event-study figures (Figures 2, 3, 8) show CS-DiD estimates that the paper itself argues are confounded. A DDD event study—showing how the road-type gap evolves relative to reversal timing—would be the most informative visual and would strengthen the case that the DDD captures a genuine treatment effect rather than a pre-existing difference.

**Fix:** Add a DDD event-study specification using relative-time indicators interacted with `dept_road`, and add as Figure 9 or replace one of the less informative CS-DiD event study plots.

### 4. COVID Literature Subsection Lacks Citations
Section 3.2 ("COVID Confounding in Quasi-Experiments") has zero citations. It hand-waves about "several recent papers" documenting analogous challenges without naming any. This is below the standard for a literature review in a top journal.

**Fix:** Add 2-3 citations documenting asymmetric COVID mobility effects and their impact on quasi-experimental research.

### 5. Treatment Intensity Results Are Misleading
Section 6.5 reports a negative intensity coefficient (-20.16) from the confounded DiD framework. The paper acknowledges this reflects the confound but then reports a dose-response pattern among full-coverage départements—also using the confounded design. This sends mixed signals. The intensity analysis should be conducted within the DDD framework (interact share_pct with dept_road) to be informative.

**Fix:** Add a DDD intensity specification or clearly caveat that all intensity results in Section 6.5 are contaminated by the same confound.

---

## Minor Issues

### 6. Introduction Roadmap Skips Section 3
The roadmap paragraph at the end of the introduction goes from Section 2 (Background) to Section 4 (Data), omitting Section 3 (Related Literature).

### 7. 52 vs. 50 Départements Inconsistency
The introduction says "52 of France's 97 metropolitan départements" reversed, but the abstract says "50 metropolitan départements." The discrepancy (2 excluded for data reasons) should be clarified earlier in the abstract or introduction.

### 8. Limitations Section Is Dense
Section 8.7 is a single paragraph with 4 caveats. Breaking these into separate short paragraphs or a numbered list would improve readability.

### 9. Missing Related Literature Citations
Beyond COVID, the Related Literature section is thin (only 9 references total). For a paper targeting top journals, consider adding citations for:
- The broader road safety economics literature
- French transport policy studies
- Behavioral responses to speed limits

### 10. Figure Notes Use \floatfoot Without threeparttable
Figures use `\floatfoot{}` outside of a `threeparttable` environment. If this compiles, it may produce inconsistent formatting. Consider using `\caption*{}` or wrapping in minipage.

---

## Positive Aspects

- The autoroute placebo diagnostic is elegant and compelling
- The research question has clear policy relevance
- The DDD identification strategy is well-motivated
- Writing quality is generally high—the opening hook and narrative arc are strong
- 50 treated clusters is well above the DiD credibility threshold
- RI provides additional confirmation (even though it confirms the confound, not the treatment)

---

## Verdict

**MAJOR REVISION** — Fix the reproducibility issue (set.seed), clean the DDD code, and add DDD-framework visualizations. The paper's narrative arc is strong but currently undermined by presenting confounded results as primary exhibits while relegating the clean DDD to a single coefficient in the robustness table.
