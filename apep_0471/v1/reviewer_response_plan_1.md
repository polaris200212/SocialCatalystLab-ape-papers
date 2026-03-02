# Reviewer Response Plan (Round 1)

**Paper:** apep_0471 — Does Welfare Simplification Encourage Entrepreneurship?
**Reviews:** GPT-5.2 (MAJOR REVISION), Grok-4.1-Fast (MINOR REVISION), Gemini-3-Flash (MINOR REVISION)
**Internal:** Claude Code (MINOR REVISION)

## Cross-Reviewer Theme Synthesis

### Theme 1: Outcome Mismatch / Sole Traders (ALL 3 referees)
- **GPT:** "Central external- and internal-validity limitation" — need triangulation or formal attenuation bounds
- **Grok:** "Sole traders missed... low power" — add HMRC RTI aggregates or ONS bounds
- **Gemini:** "Most significant threat" — incorporate VAT data or back-of-envelope calibration
- **Action:** Expand the attenuation calculation already in Section 7.2 into a formal subsection. Compute explicit bounds mapping individual-level effects to LA-level detectability. Reference ONS Labour Force Survey data on sole trader vs limited company shares.

### Theme 2: MIF Timing Test Validity (GPT major, Gemini moderate)
- **GPT:** "Not credibly identified as claimed" — LA-level 12-month split doesn't identify individual MIF binding
- **Gemini:** Increasing point estimate "contradicts the theoretical model"
- **Action:** Reframe MIF test as exploratory/suggestive rather than "novel contribution." Add explicit caveats about ecological fallacy. Downweight in introduction and abstract.

### Theme 3: Treatment Exposure Mapping (GPT major)
- **GPT:** Multi-jobcentre LAs create measurement error in treatment intensity
- **Action:** Add discussion paragraph about within-LA treatment heterogeneity. Note that taking the first office date creates attenuation bias (conservative). Discuss robustness implications.

### Theme 4: Rollout Timing Exogeneity (GPT major)
- **GPT:** "As-good-as-random" asserted not demonstrated — need predictive regressions
- **Grok:** Notes no LA covariates
- **Action:** Add discussion of what empirical validation exists. Note region×time FE as desirable robustness. Acknowledge limitation more explicitly.

### Theme 5: CS Estimation Details (GPT)
- **GPT:** Quarterly aggregation + scaling unclear; need CI in table; specify aggregation weights
- **Action:** Add explicit CI to main results. Clarify quarterly outcome definition. Specify simple aggregation weights.

### Theme 6: Reframe High-Formation LAs (GPT)
- **GPT:** Not a valid placebo — should be heterogeneity
- **Action:** Rename from "placebo" to "heterogeneity" in text and table notes.

### Theme 7: Temper Null Claims (GPT)
- **GPT:** "Precisely estimated null" is overstated given estimand disconnect
- **Action:** Qualify to "precisely estimated null *for the incorporation margin*"

### Theme 8: Never-Treated Group (GPT)
- **GPT:** Are these late-treated or truly never-treated?
- **Action:** Clarify in Section 2.3 and add note about CS using not-yet-treated comparisons.

### Theme 9: Prose Improvements (Prose Review)
- Punch up abstract, results section, transitions
- **Action:** Revise abstract, improve results prose per Katz style.

### Theme 10: Missing References
- Roth (2022) on pre-trend testing, Borusyak et al. (2021) imputation estimator
- **Action:** Add citations in methodology discussion.

## Changes NOT Made (with justification)

1. **New data sources** (VAT registrations, HMRC self-assessment, APS/NOMIS self-employment): Would require re-running the entire analysis pipeline. Addressed through discussion and bounds instead.
2. **Region×time FE**: Would require R code changes and re-estimation. Noted as desirable future robustness.
3. **Treatment intensity construction**: Would require jobcentre-level data we don't have. Discussed as limitation.
4. **Poisson/PPML estimation**: Noted as potential robustness but not implemented.
5. **Remove Table A2**: Exhibit review suggested removal but it provides value for comparing estimators.
