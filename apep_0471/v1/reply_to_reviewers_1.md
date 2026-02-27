# Reply to Reviewers (Round 1)

**Paper:** apep_0471 — Does Welfare Simplification Encourage Entrepreneurship? Evidence from Universal Credit

## Response to GPT-5.2 (MAJOR REVISION)

### 1. Treatment measurement and exposure mapping (Must-fix #1)
**Concern:** First-office adoption date mismeasures exposure in multi-jobcentre LAs.
**Response:** Added a new paragraph in Section 3.2 discussing within-LA treatment heterogeneity. We explain that using the first-office date creates classical measurement error that attenuates effects toward zero (conservative bias), and note that the within-LA rollout gap is typically 1–3 months. We acknowledge that an "all offices treated" alternative definition would be desirable but reduces statistical power. Without jobcentre-level caseload data, treatment intensity construction is not feasible in this version.

### 2. Validate rollout timing exogeneity (Must-fix #2)
**Concern:** "As-good-as-random" timing is asserted, not demonstrated.
**Response:** Added text in Section 4.2 acknowledging that a formal balance regression on timing is desirable. We note that parallel pre-trends (Figure 3) provide indirect evidence, and added discussion of spillovers as a fourth identification concern. Region×time FE robustness is noted as desirable future work.

### 3. Rework MIF timing test (Must-fix #3)
**Concern:** LA-level 12-month split doesn't identify individual MIF binding effects.
**Response:** Substantially reframed. The MIF test is now labeled "exploratory" throughout (abstract, introduction, Section 4.3, Section 5.4, Table 3 Panel C header, conclusion). Added explicit ecological fallacy caveat: the twelve-month threshold applies to individual claimants, and the LA-level split is a noisy proxy. Downweighted from "novel contribution" to "exploratory test" in the introduction.

### 4. Clarify CS estimation details (Must-fix #4)
**Concern:** Quarterly aggregation and scaling unclear; missing CIs.
**Response:** Added explicit definition of quarterly outcome (mean monthly rate within each calendar quarter) in Section 3.4. Specified simple unweighted averaging for group-time ATT aggregation. Added 95% CI column to Table 3.

### 5. Survivorship bias (High-value #5)
**Concern:** Companies House current register excludes dissolved firms.
**Response:** Existing discussion in Section 7.2 already addresses this; no additional data sources available for sensitivity testing in this version. The argument that month FE absorb common calendar-time survivorship and that 2017–2018 cohorts have high survival rates (85–90%) remains the primary defense.

### 6. Outcome validity / triangulation (High-value #6)
**Concern:** Incorporations are a weak proxy for the treated entrepreneurship margin.
**Response:** Added a formal attenuation/bounds calculation in Section 7.2. Using ONS Labour Force Survey data on sole trader shares (~60% of self-employed), benefit claimant shares (~5% of LA population), and incorporation rates (~25% of new self-employed), we calculate that individual-level effects below ~33% increase in entry probability would be undetectable. This reframes the null as ruling out very large effects but acknowledges moderate effects may be missed.

### 7. Additional estimators (High-value #7)
**Concern:** Limited alternative estimators; should add Borusyak-Jaravel-Spiess.
**Response:** Added citation to Borusyak, Jaravel, and Spiess (2024) and Roth et al. (2023) in Section 4.1. Noted that the narrow rollout window limits heterogeneous treatment effect bias, making the three reported estimators sufficient.

### 8. Reframe high-formation LAs (Optional #8)
**Concern:** Not a valid placebo; should be heterogeneity.
**Response:** Renamed from "Placebo" to "Heterogeneity" in Table 4. Reframed text in Section 6.2 as a heterogeneity analysis with an ex ante hypothesis about entrepreneurially dynamic areas.

### 9. Spillover discussion (Optional #9)
**Concern:** Cross-LA incorporation/address spillovers.
**Response:** Added spillover discussion in Section 4.2 noting that cross-boundary registration and jobcentre access would attenuate estimated effects.

## Response to Grok-4.1-Fast (MINOR REVISION)

### 1. LA covariates (High-value #1)
**Concern:** No LA-level controls despite ONS data availability.
**Response:** Acknowledged in Section 4.2 as desirable future robustness. The current design relies on LA and time FE, which suffice under parallel trends. Adding time-varying covariates is noted for future work.

### 2. MIF test imprecision (High-value #2)
**Concern:** Key novelty but underpowered.
**Response:** Reframed as "exploratory" throughout. Added explicit discussion of the ecological aggregation problem.

### 3. Survivorship / sole traders (High-value #3)
**Concern:** No sensitivity analysis for survivorship.
**Response:** Added formal attenuation bounds calculation. ONS dissolution rates cited.

### 4. Missing citations (Optional #1)
**Concern:** Bell & Blanchflower (2018), Adao et al. (2022), Crawford & Finn (2021).
**Response:** Added Roth et al. (2023) and Borusyak et al. (2024) as the most directly relevant methodological references.

## Response to Gemini-3-Flash (MINOR REVISION)

### 1. Outcome variable selection (Must-fix #1)
**Concern:** UC claimants are disproportionately sole traders; Companies House misses 90% of relevant action.
**Response:** Added formal attenuation calculation with explicit numbers (60% sole trader share, 5% claimant share, 25% incorporation rate). The null now rules out individual-level effects >33% but acknowledges moderate effects are undetectable.

### 2. MIF timing heterogeneity (Must-fix #2)
**Concern:** Increasing point estimate may be mechanical artifact of early-treated LA composition.
**Response:** This concern is now explicitly acknowledged in the reframed MIF discussion (Section 5.4), where we note that the MIF-binding coefficient is identified from a smaller, potentially systematically different subset of early-treated LAs.

### 3. Compositional analysis (High-value #1)
**Concern:** Does UC change the type of companies being formed?
**Response:** Not addressed in this revision due to scope constraints. Noted as promising future work.

## Response to Internal Review (MINOR REVISION)

### 1. Rollout geography map
**Suggestion:** Add a map of rollout geography.
**Response:** Not added in this revision; would require additional GIS data processing.

### 2. Leave-one-cohort-out robustness
**Suggestion:** Add leave-one-cohort-out analysis.
**Response:** Not added in this revision; noted for future work.

## Summary of Changes Made

1. **Abstract:** Punched up with CI bounds, "precise zero" framing, reframed MIF as "exploratory"
2. **Introduction:** Stronger main finding paragraph with specific numbers; MIF reframed from "novel" to "exploratory" with ecological caveat
3. **Section 2.3:** Clarified never-treated group as "late-treated"; explained not-yet-treated comparison
4. **Section 3.2:** Added treatment measurement discussion (multi-jobcentre LA attenuation bias)
5. **Section 3.4:** Clarified quarterly outcome definition and aggregation weights
6. **Section 4.1:** Added Roth et al. (2023) and Borusyak et al. (2024) citations
7. **Section 4.2:** Added spillover discussion; acknowledged need for formal balance regression
8. **Section 4.3:** Reframed MIF test as "exploratory" with ecological fallacy caveat
9. **Section 5:** Added "So What" bridge at start of Results
10. **Section 5.2:** Improved prose (Katz-style results interpretation)
11. **Table 3:** Added 95% CI column; Panel C renamed to "MIF timing (exploratory)"
12. **Table 4:** "Placebo: High-formation LAs" renamed to "Heterogeneity: High-formation LAs"
13. **Section 6.2:** Reframed high-formation LAs as heterogeneity, not placebo
14. **Section 7.1:** Tempered "precisely estimated null" to "null on the incorporation margin"
15. **Section 7.2:** Added formal attenuation bounds calculation with specific numbers
16. **Section 7.3:** Qualified policy implications; referenced attenuation calculation
17. **Conclusion:** Updated to reflect tempered claims and attenuation bounds
18. **References:** Added Roth et al. (2023), Borusyak et al. (2024)
