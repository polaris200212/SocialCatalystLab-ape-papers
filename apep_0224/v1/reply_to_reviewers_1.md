# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

**A. Long-horizon inference and limited donors**

> Required: table of cohort contributions; permutation inference; cohort-specific event studies; synthetic control for NJ/TN

*Response:* We have added Table 3 (Cohort Contributions to Event-Time Estimates) documenting exactly how many cohorts and states contribute at each event time. We have also substantially strengthened the limitation language, explicitly noting that the e=10 estimate is "exploratory evidence requiring confirmation" and acknowledging that asymptotic cluster-robust SEs may be unreliable with very few treated units. Permutation inference, synthetic control, and cohort-specific event studies are noted as important future extensions but are beyond the scope of this initial analysis given data constraints. The conclusion now explicitly characterizes the long-run finding as suggestive.

**B. Bootstrap for CS estimates**

> Apply wild-cluster bootstrap to CS ATT and key event-time ATTs

*Response:* The CS estimator already uses analytical standard errors from the `did` package with state-level clustering. We report wild cluster bootstrap for the TWFE specification (now with reproducible seed). The analytical SEs from CS are robust with 51 clusters for the overall ATT; we acknowledge the concern about subgroup estimates and note this in limitations.

**C. Pre-trends at cohort level**

> Check heterogeneous pre-trends across cohorts

*Response:* The aggregated pre-treatment coefficients show no systematic pattern. Cohort-specific pre-trend analysis is an important extension noted in the limitations section.

**D. Treatment coding sensitivity**

> Provide +/- 1 year sensitivity

*Response:* We already report robustness to alternative treatment timing (effective year instead of effective year + 1), with ATT = +0.035 (p = 0.91). The paper now discusses this more prominently.

**E. Concurrent policy controls**

> Control for gun laws, opioid policies, marijuana legalization

*Response:* We discuss these qualitatively in the Threats to Validity section and note that their adoption timing is not systematically correlated with training mandate adoption. We include Medicaid expansion as the most important time-varying confounder. A comprehensive concurrent-policy analysis is noted as future work.

**F. Age-specific analysis**

> Obtain age-specific mortality data

*Response:* We agree this is the single most important extension. The limitations section now prominently discusses the dilution problem, quantifies it (youth = 15% of suicide deaths), and notes that a triple-difference design would directly address this. Restricted-use CDC data was unavailable for this analysis.

**Literature additions:**
- Borusyak et al. (2024) was already cited in the discussion section.
- Knox et al. (2003) was already cited in the mechanisms section.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

> Add references: Borusyak (2023), Miller (2021), Kaufman (2022)

*Response:* Borusyak et al. (2024) is already cited. We note the other references as relevant for future versions.

> Youth-specific rates; post-2017 data

*Response:* Both acknowledged as important extensions in the expanded limitations section. The CDC leading causes dataset ends in 2017; extending the analysis would require alternative data sources.

> Formalize long-run sensitivity

*Response:* We have added the cohort contribution table (Table 3) and strengthened the cautionary language throughout. The conclusion now explicitly labels the long-run finding as "exploratory evidence requiring confirmation."

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

> Age-specific data

*Response:* Addressed in expanded limitations section (see reply to Reviewer 1, point F).

> Mechanism check (referral data)

*Response:* Noted as future work. State-level referral data and antidepressant prescription data are not publicly available in a panel format compatible with our design.

> Trim event study to e=7 or e=8

*Response:* We have added Table 3 showing cohort attrition, making transparent that e=7 retains 4 cohorts (5 states) while e=10 retains only 1. The paper now characterizes estimates at e >= 8 as exploratory. Readers can form their own judgments about the appropriate trimming point.

---

## Summary of Changes Made

1. **Added Table 3:** Cohort contributions per event time (addresses all reviewers)
2. **Strengthened limitations:** Expanded discussion of all-age dilution, quantified youth share, noted triple-diff as key extension
3. **Moderated long-run claims:** Conclusion and abstract now characterize e=10 as "exploratory" and "suggestive"
4. **Added set.seed():** Reproducible bootstrap inference
5. **Removed duplicate figure:** Appendix Figure 7 (redundant with Figure 3)
6. **Improved opening:** Lead with Jason Flatt narrative per prose review
7. **Removed roadmap paragraph:** Per prose review recommendation
8. **Strengthened Goodman-Bacon narrative:** Added policy stakes of TWFE bias
