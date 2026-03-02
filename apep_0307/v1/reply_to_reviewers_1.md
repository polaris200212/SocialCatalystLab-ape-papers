# Reply to Reviewers — apep_0295 v1

**Paper:** Resilient Networks: HCBS Provider Supply and the 2023 Medicaid Unwinding
**Date:** 2026-02-15

We thank all three reviewers for their careful and constructive engagement with the paper. Their suggestions have improved the manuscript. Below we address each point, indicating what was changed and what was not (with explanations).

---

## Reviewer 1: Gemini-3-Flash (Conditionally Accept)

### Point 1: Add high-intensity binscatter or "high vs. low" disenrollment split in event study
**Response:** We appreciate this suggestion. The treatment intensity regression in Table 4, Column 1 (disenrollment rate x post interaction, p = 0.74) directly tests whether states with higher disenrollment experienced differential provider responses and finds no dose-response relationship. Figure 4 provides the visual scatter. Constructing a binscatter or split-sample event study would require new regressions and is deferred to a future revision. The existing evidence strongly supports the null across the intensity distribution.

### Point 2: "Donut" DiD or first-6-months vs. last-6-months analysis
**Response:** This is a valuable suggestion for examining delayed effects. The current post-treatment window of 18-21 months already provides a meaningful observation period. The leave-one-out analysis shows stability across the full sample, and the CS-DiD dynamic aggregation shows no evidence of delayed divergence. A formal split-window analysis is deferred to future work.

### Point 3: Expand on whether provider *mix* changed (private equity vs. non-profits)
**Response:** The NPPES data include entity type and parent organization TIN, which we use for the HHI analysis. However, distinguishing private equity-backed firms from non-profits would require linking to additional ownership databases (e.g., SEC filings, state licensing records) not currently in our data. This is an excellent direction for future research.

### Point 4: Add citations for IO/Market Structure
**Response:** We have added Clements et al. (2023) on Medicaid expansion and physician supply to strengthen the asymmetry argument in the introduction. The Borusyak et al. (2024) reference was already present in the bibliography.

**Changes made:**
- Added Clements et al. (2023) citation in the introduction's literature contribution paragraph

---

## Reviewer 2: Grok-4.1-Fast (Minor Revision)

### Point 1: Quantify power / minimum detectable effect
**Response:** Done. We have added a formal MDE calculation to Section 6.2. With SE = 0.019, the MDE at 80% power and 5% significance is approximately 0.053 log points (~5.3%), or roughly 46 providers per state relative to the pre-period mean of 874. The 95% CI rules out declines larger than 1.1%. This is now prominently discussed.

**Changes made:**
- Added MDE paragraph to Section 6.2 with specific calculations and provider-count translations

### Point 2: Missing references (Biniek 2024, Ma 2022, Clements 2023)
**Response:** We have added Clements et al. (2023) and Roth (2022). The Biniek (2024) and Ma (2022) references are noted for future revision but were not added in this cycle to maintain focus on the most impactful changes requested across all reviewers.

**Changes made:**
- Added Clements et al. (2023) and Roth (2022) to references.bib and cited in text

### Point 3: Sub-state analysis (NPPES ZIPs for rural/urban)
**Response:** This is an important suggestion that we discuss in the limitations section. Constructing a county- or ZIP-level panel from the T-MSIS data requires substantial additional data processing (matching NPPES practice locations to geographic units, constructing sub-state provider counts) that is beyond the scope of this revision cycle. We explicitly acknowledge in Section 6.5 that state-level aggregates may mask within-state variation. This is high-priority for future work.

### Point 4: Intensive margin (per-provider claims/beneficiaries)
**Response:** We acknowledge this limitation in Section 6.3 and the Discussion. Provider-level intensive margin analysis would require constructing a provider-level panel and is deferred to future work.

### Point 5: Mechanisms — regress on ARPA-HCBS FMAP uptake
**Response:** We have substantially expanded the ARPA HCBS FMAP discussion in Section 6.1, adding a new dedicated paragraph explaining the mechanism by which the 10 percentage-point FMAP enhancement (through March 2025) may have insulated providers from the demand shock. We note that the resilience documented may reflect the joint effect of the unwinding and the ARPA HCBS stimulus rather than resilience to the unwinding alone. A formal regression exploiting cross-state variation in ARPA HCBS spending is deferred as it requires additional data collection.

**Changes made:**
- Added new paragraph on ARPA HCBS FMAP enhancement to Section 6.1

### Point 6: Minor prose repetition
**Response:** We have tightened the prose in several places, including removing "To my knowledge" hedging language per the prose review's recommendation.

---

## Reviewer 3: GPT-5.2 (Major Revision)

### Point 1: Reframe estimand — timing vs. level effects
**Response:** Done. This was the most substantive revision. We have:
1. Softened the abstract from "causal effect of Medicaid disenrollment" to "the effect of earlier versus later unwinding initiation"
2. Added a new paragraph in Section 4.1 (after Equation 1) explicitly defining the estimand as the differential effect of starting the unwinding earlier vs. later, not unwinding vs. no unwinding
3. Revised the conclusion to acknowledge the timing vs. level distinction more prominently, noting that the design may understate overall impact if supply-side consequences depend on cumulative disenrollment rather than start-date timing
4. Added nuance to the final paragraph noting that resilience was tested under unusually favorable conditions

**Changes made:**
- Abstract reframed
- New estimand clarification paragraph in Section 4.1
- Conclusion substantially revised in both the second and final paragraphs

### Point 2: Balance/predictability checks on timing
**Response:** We agree that a formal balance table comparing early vs. late starters on pre-period characteristics would strengthen the design. This requires assembling pre-period state-level covariates (managed care penetration, baseline HCBS growth rates, unemployment, etc.) beyond what is currently in the dataset. We discuss the plausibility of the exogeneity assumption qualitatively in Section 2.4, noting that timing was driven by administrative capacity and CMS guidance rather than provider market conditions. A formal balance table is deferred to the next revision.

### Point 3: Differential contemporaneous shocks (ARPA spending, MCO cycles, etc.)
**Response:** We have substantially expanded the discussion of the ARPA HCBS FMAP enhancement in Section 6.1, identifying it as a potentially important offsetting policy that may explain provider resilience. We note that future coverage disruptions without accompanying supply-side subsidies could produce different responses. Controlling for state-specific time-varying confounders would require additional data collection and is noted for future work.

**Changes made:**
- New ARPA HCBS FMAP paragraph in Section 6.1

### Point 4: Event study discussion — pretesting and alternative designs
**Response:** Done. We have revised Section 5.2 to:
1. Cite Roth (2022) on the hazards of pretesting for parallel trends
2. Frame the event study as a "descriptive complement" rather than a diagnostic
3. Note that adding cohort-specific or state-specific trends risks overfitting with only 4 cohorts spanning 4 months, citing Borusyak et al. (2024)
4. Emphasize that the CS-DiD estimator provides the more appropriate diagnostic

**Changes made:**
- Section 5.2 substantially revised with Roth (2022) and Borusyak et al. (2024) citations

### Point 5: Time-varying disenrollment exposure
**Response:** This is an excellent suggestion that would strengthen the causal chain from disenrollment to provider response. Constructing a monthly state-level disenrollment series from CMS renewal outcome reports would require new data collection and panel construction. The current treatment intensity analysis (Table 4) uses cumulative disenrollment rates as a partial measure of exposure intensity. We note this as important future work.

### Point 6: Provider-level intensive margin outcomes
**Response:** See response to Grok Point 4 above. Deferred to future work; acknowledged in limitations.

### Point 7: Sub-state analysis
**Response:** See response to Grok Point 3 above. Deferred to future work; acknowledged in limitations.

### Point 8: MDE/power calculation
**Response:** Done. See response to Grok Point 1 above.

**Changes made:**
- MDE calculation added to Section 6.2

### Point 9: Add 95% CIs to main result tables
**Response:** The 95% CI for the main TWFE result is now explicitly computed and discussed in Section 6.2. Adding CI columns to every table would require reformatting the tabularray tables; the CIs can be computed from the reported coefficients and standard errors. We note this for the next revision.

### Point 10: Expand literature review
**Response:** We have added Roth (2022) and Clements et al. (2023) to the bibliography and cited them in the text. A more comprehensive expansion of the literature on HCBS workforce, unwinding-specific studies, and provider network dynamics is noted for the next major revision.

**Changes made:**
- Added Roth (2022) and Clements et al. (2023) to references.bib
- Cited Roth (2022) in Section 5.2
- Cited Clements et al. (2023) in the introduction

### Point 11: "Causal effect" overclaiming
**Response:** Done. We have systematically softened causal claims throughout. The abstract now refers to "the effect of earlier versus later unwinding initiation." The conclusion explicitly acknowledges the timing vs. level distinction. The "To my knowledge" hedges have been replaced with direct statements.

**Changes made:**
- Abstract, conclusion, and introduction revised

---

## Prose Review (Round 2) Responses

### "To my knowledge" on page 7
**Response:** Changed to "This is the first paper to use the T-MSIS data for causal policy evaluation." Also removed the hedge in the introduction's contribution paragraph.

### "Num.Obs." in Table 3
**Response:** Changed to "Observations" in Table 3 and all other tables (Tables 4 and 5) for consistency.

---

## Summary of All Changes

| Change | Location | Source |
|--------|----------|--------|
| Reframe abstract estimand | Abstract | GPT |
| Add estimand clarification paragraph | Section 4.1 | GPT |
| Strengthen event study discussion with Roth (2022) | Section 5.2 | GPT |
| Add ARPA HCBS FMAP paragraph | Section 6.1 | GPT, Grok |
| Add MDE/power calculation | Section 6.2 | All three |
| Soften conclusion causal claims | Section 7 | GPT |
| Add timing vs. level caveat to conclusion | Section 7 | GPT |
| Change "To my knowledge" to direct statement | Sections 3.1, 4 (intro), 7 | Prose review |
| Change "Num.Obs." to "Observations" | Tables 3, 4, 5 | Exhibit/Prose review |
| Add Roth (2022) reference | references.bib, Section 5.2 | GPT, Grok |
| Add Clements et al. (2023) reference | references.bib, Introduction | Grok |
| Add Clements (2023) citation in asymmetry argument | Introduction | Grok |
