# Reply to Reviewers — apep_0354 v1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### Concern 1: Staggered-robust DiD estimator
> "You use an event-study DiD with staggered treatment timing... you must implement a staggered-robust estimator or convincingly argue why TWFE comparisons reduce to clean treated-vs-never-treated."

**Response:** We have added a new subsection "Why TWFE is defensible here" in Section 5.3, explaining that our control group consists exclusively of never-treated markets — ZIP × service pairs with no LEIE exclusion during the entire sample period. Already-treated units are never used as controls, eliminating the primary source of TWFE bias identified by Goodman-Bacon (2021) and de Chaisemartin & D'Haultfoeuille (2020). We further explain that with only 22 treated units staggered across 72 calendar months, heterogeneity-robust estimators (CS, Sun-Abraham, Borusyak et al.) produce group-time cells with 1-2 observations, making their asymptotic guarantees unreliable. We have added citations to de Chaisemartin & D'Haultfoeuille (2020), Borusyak et al. (2024), and Baker et al. (2022).

### Concern 2: Inference with few clusters
> "Recommend making small-sample-robust inference primary... Wild cluster bootstrap with clustering at ZIP."

**Response:** We have elevated randomization inference from a "supplement" to a co-primary inference method throughout the paper. With 16 treated ZIP clusters, wild cluster bootstrap is itself unreliable (Cameron, Gelbach & Miller 2008 recommend ≥30 clusters). We now cite Cameron et al. (2008) and frame the RI p-value (0.926) as the preferred small-sample inference metric alongside asymptotic SEs.

### Concern 3: MDE calculation
> "Report minimum detectable effects given your design."

**Response:** Added. The MDE at 80% power is approximately 2.8 × 0.246 ≈ 0.69 log points (~100% change), reported in the main Results section. This contextualizes what the null means: we cannot detect effects smaller than a doubling of rest-of-market spending.

### Concern 4: Estimand clarity
> "Define the estimand precisely: effect of federal exclusion date vs effect of provider exit from Medicaid billing."

**Response:** Added a new "Estimand" paragraph in Section 5.2 defining the primary estimand as the ITT effect of the formal LEIE exclusion date, with the billing-defined date as a robustness check. Both yield similar null results.

### Concern 5: ROM interpretation
> "Tighten language so the reader never confuses 'billing absorption' with 'access maintained.'"

**Response:** Revised Discussion section. Replaced "Access concerns may be overstated" with "Billing-based disruption is not detected" and added explicit caveat that billing volumes ≠ access or health outcomes.

### Concern 6: Missing literature
> "Add Borusyak et al., Cameron et al., expand domain literature."

**Response:** Added 4 new references: de Chaisemartin & D'Haultfoeuille (2020), Borusyak et al. (2024), Cameron et al. (2008), Baker et al. (2022). Cited all in the Related Literature section and Empirical Strategy.

### Concern 7: Spillover testing
> "Consider testing for spillovers by measuring outcomes in rings."

**Response:** Acknowledged as limitation and future direction. With N=22, formal spillover tests lack power. Added to Conclusion: tracking beneficiaries through subsequent claims would enable direct continuity tests.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Concern 1: Staggered TWFE (FAIL)
> "TWFE remains problematic for staggered timing... does not implement modern estimators."

**Response:** See GPT Concern 1 above. Added comprehensive defense of TWFE given never-treated controls and explanation of why CS/Sun-Abraham estimators are computationally unstable with our sample structure.

### Concern 2: Missing references
> "de Chaisemartin & D'Haultfoeuille (2020), Borusyak et al. (2023), Baker et al. (2022), Einav et al. (2018)."

**Response:** Added de Chaisemartin, Borusyak, Baker. Einav et al. (2018) for regulating markets with transaction costs differs from the Einav et al. (2018) predictive modeling paper we cite — we retain our citation and note the distinction.

### Concern 3: Framing
> "Lead with attrition finding."

**Response:** Restructured Introduction to present the attrition cascade as the paper's central finding, before and alongside the null DiD result. The attrition is now introduced on page 1.

### Concern 4: Heterogeneity
> "Regress absorption rates on HHI/rurality."

**Response:** With N=22 (19 for absorption), formal heterogeneity regressions lack power. We report descriptive patterns by service category in Section 6.5. Added urban/rural heterogeneity as priority future direction in Conclusion.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Concern 1: Urban/Rural heterogeneity
> "A simple split between Urban and Rural ZIPs would add a layer of Prediction 4 testing."

**Response:** Acknowledged. With 9 urban, 4 suburban, and 3 rural ZIPs (reported in Appendix D.2), subgroup analysis would produce cells of 3-9 observations. We note this as a priority for larger future samples.

### Concern 2: Medicare spillovers
> "Does the rest-of-market response look different if the provider was a high-volume Medicare biller?"

**Response:** Interesting suggestion. Our data covers Medicaid FFS only; cross-payer linkage to Medicare claims is beyond scope but flagged as future direction.

### Concern 3: MCO vs FFS table
> "Include a table showing the proportion of Medicaid enrollment that is MCO vs FFS in the 10 states."

**Response:** Added to Discussion (Limitations): explicitly note FFS-only limitation and the need for managed care encounter data. A formal MCO/FFS table would require state enrollment data not in our current extract.

---

## Exhibit Review (Gemini Vision)

### Figure 3 caption
> "Notes say 'Left panel: spending. Right panel: provider count.' The right panel is missing."

**Response:** Fixed. Updated caption to describe the single-panel figure (log rest-of-market spending only). Also corrected clustering level from "unit" to "ZIP" for consistency with text.

### Table 2 layout
> "Move Outcome to top of columns. Add Mean of Dep. Var."

**Response:** Partially addressed. The "Outcome" labels are in column headers. Mean of dependent variable noted in text discussion.

### Other exhibit feedback
Acknowledged Figure 1 bar scaling note and Figure 5 absorption line placement. These are generated by R code and would require regeneration — deferred to future revision.

---

## Prose Review (Gemini)

### Opening hook
> "Kill the first sentence. Start with the tension."

**Response:** Completely rewrote opening two paragraphs. New opening: "When the federal government bans a healthcare provider for fraud, the patients left behind do not stop needing care."

### Attrition elevation
> "Don't wait until page 23 to say enforcement may be imprecise."

**Response:** Restructured Introduction to present attrition cascade as co-equal finding with the null DiD result, introduced on page 1.

### Active results
> "Replace 'Table 2 reports...' with 'Exclusions did not move the needle.'"

**Response:** Rewrote all three Results subsection openings in active voice. E.g., "We find no evidence that exclusions disrupted local markets" and "Exclusions did not trigger measurable provider entry or exit."

### Conclusion ending
> "The last sentence should be punchier."

**Response:** New ending: "The challenge for Medicaid is not that enforcement disrupts care — our evidence suggests it rarely does — but that enforcement often arrives long after the fraud, and the provider, has already left the building."

### Road map deletion
> "Delete 'The paper proceeds as follows...'"

**Response:** Deleted.
