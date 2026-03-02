# Revision Plan 1 — apep_0295 v1

**Paper:** Resilient Networks: HCBS Provider Supply and the 2023 Medicaid Unwinding
**Date:** 2026-02-15
**Reviews:** Gemini (Conditionally Accept), Grok (Minor Revision), GPT (Major Revision)

---

## Summary of Reviewer Consensus

All three reviewers praised the paper's novel dataset (T-MSIS), rigorous staggered DiD implementation, transparent handling of the null result, and high-quality prose. The key concerns cluster around:

1. **Missing MDE/power calculation** (all three reviewers)
2. **Estimand framing** — the design estimates timing effects, not unwinding vs. no unwinding (GPT, partially Grok)
3. **References** — missing Roth (2022), Clements (2023), and other recent work (all three)
4. **Event study discussion** — needs stronger framing, cite Roth (2022) on pretesting (GPT)
5. **ARPA HCBS FMAP** — this offsetting policy should be discussed more prominently (GPT)
6. **Minor prose fixes** — "To my knowledge" phrasing, "Num.Obs." label (prose review)

---

## Changes Planned

### A. Add MDE/Power Calculation (Section 6.2)

**Reviewers:** All three
**Action:** Add a paragraph to Section 6.2 computing the minimum detectable effect:
- MDE at 80% power, 5% significance = 2.8 x SE = 2.8 x 0.019 = 0.053 log points (~5.3%)
- 95% CI is [-0.011, +0.063], ruling out declines > 1.1%
- Translate into provider counts for interpretability

### B. Reframe Estimand Throughout

**Reviewer:** GPT (primary), Grok (secondary)
**Action:**
- **Abstract:** Soften "causal effect of Medicaid disenrollment" to "the effect of staggered state unwinding start dates on"
- **Section 4.1:** Add explicit paragraph after Equation 1 defining the estimand as the differential effect of earlier vs. later unwinding start, not unwinding vs. no unwinding
- **Conclusion:** Soften causal claims; acknowledge timing vs. level distinction more prominently

### C. Expand References

**Reviewers:** All three
**Action:** Add to references.bib:
- Roth (2022) "Pretest with Caution" — AER: Insights
- Clements et al. (2023) "Medicaid Expansion and Physician Supply" — JHE
- (Borusyak et al. 2024 already present in bib)

### D. Strengthen Event Study Discussion (Section 5.2)

**Reviewer:** GPT
**Action:**
- Add reference to Roth (2022) on pretesting hazards
- Note that cohort-specific trends would be desirable but with only 4 cohorts spanning 4 months, adding state-specific trends risks overfitting
- Frame the event study as "a descriptive complement" rather than a failed diagnostic

### E. Add ARPA HCBS FMAP Discussion (Section 6.1)

**Reviewer:** GPT
**Action:** Add a paragraph about the American Rescue Plan Act's 10 percentage-point HCBS FMAP enhancement (through March 2025) as a mechanism for provider resilience. Note that this may have insulated providers from the demand shock.

### F. Minor Prose Improvements

**Source:** Prose review round 2
**Action:**
- Change "To my knowledge" to "This is" (page 7, Section 3.1)
- Change "Num.Obs." to "Observations" in Table 3

---

## Changes NOT Made (with justification)

### Sub-state analysis (county/ZIP-level)
**Requested by:** GPT, Grok
**Reason:** Requires re-processing T-MSIS data at sub-state geographic level, which involves new data construction beyond the scope of this revision cycle. Acknowledged as future work in limitations.

### Intensive margin outcomes (claims per provider)
**Requested by:** GPT
**Reason:** Requires new regressions with provider-level panel construction. Noted as important future work in Discussion.

### Time-varying disenrollment series
**Requested by:** GPT
**Reason:** Monthly state-level disenrollment data from CMS reports would require new data collection and panel construction. The current treatment intensity analysis (cumulative disenrollment rate interaction) partially addresses this concern.

### Cohort-specific raw trends plot
**Requested by:** GPT
**Reason:** Would require new figure generation. The CS-DiD estimator (Figure 3) already addresses this concern by using not-yet-treated comparisons and showing near-zero pre-treatment effects.

### Balance table (early vs. late starters)
**Requested by:** GPT
**Reason:** Requires assembling pre-period state characteristics beyond what is currently in the data. Noted for future revision.

### Detrended event study
**Requested by:** Exhibit review
**Reason:** Detrending event study coefficients requires methodological choices (linear vs. quadratic) that could be contentious. The CS-DiD dynamic plot (Figure 3) already serves this purpose more cleanly.

### Promote Figure 10 (map) to main text
**Requested by:** Exhibit review
**Reason:** Good suggestion but would require restructuring figure numbering. Noted for future revision.

### Binscatter of high vs. low disenrollment event study
**Requested by:** Gemini
**Reason:** Requires new regressions. The treatment intensity regression (Table 4) already tests this hypothesis and finds no dose-response.
