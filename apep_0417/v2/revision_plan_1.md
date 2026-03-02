# Revision Plan: apep_0417 v2 → v3

**Paper:** "Where Medicaid Goes Dark: A Claims-Based Atlas of Provider Deserts and the Resilience of Supply to Enrollment Shocks"

**Parent version:** apep_0417/v2
**Reviews received:** GPT-5.2 (Major Revision), Grok-4.1-Fast (Minor Revision), Gemini-3-Flash (Minor Revision), Exhibit Review (Gemini), Prose Review (Gemini), Internal (Minor Revision)

---

## Theme 1: Econometric Design — Continuous Intensity + Staggered Timing

### 1.1 Clarify identifying assumption for dose-response DiD
**Source:** GPT-5.2 (Section 2e, Item 1)
**Concern:** Treatment is post x state disenrollment rate (continuous intensity), not standard binary adoption. The identifying assumption should be stated explicitly as parallel trends in outcomes *with respect to intensity*.
**Action:** Revise Section 5.1 to formally state: "Absent unwinding, states with higher eventual disenrollment intensity would not have experienced differentially changing provider supply after 2023Q2 relative to lower-intensity states." Add discussion of how this differs from standard binary staggered DiD.
**Status:** For this revision.

### 1.2 Clarify Sun-Abraham implementation with continuous intensity
**Source:** GPT-5.2 (Section 2e, Items 2-3)
**Concern:** Sun & Abraham (2021) is designed for binary treatment timing; calling the interaction-weighted estimator with intensity "Sun-Abraham ATT" may be misleading. Document how intensity interacts with the IW estimator.
**Action:** Revise the Sun-Abraham robustness discussion to clarify implementation: we implement interaction-weighted estimates following the spirit of Sun & Abraham (2021) but adapted for continuous intensity by interacting cohort-specific indicators with state disenrollment rates. Add footnote distinguishing this from the canonical binary implementation.
**Status:** For this revision.

### 1.3 Add single-start intensity specification
**Source:** GPT-5.2 (Section 6A, Item 1); Grok-4.1-Fast (Section 6)
**Concern:** Using a common start date (2023Q2 for all states) as post and relying solely on cross-state intensity variation removes staggered-timing complications entirely.
**Action:** Add to robustness table: specification with post = 1[t >= 2023Q2] for all states, treatment = post x intensity. Report alongside existing results.
**Status:** For this revision.

### 1.4 Add Callaway-Sant'Anna or Borusyak estimator
**Source:** Grok-4.1-Fast (Section 6); GPT-5.2 (Section 2e, Item 3)
**Concern:** Modern heterogeneity-robust estimators would strengthen credibility.
**Action:** Add Callaway-Sant'Anna group-time ATT estimation as additional robustness specification. Cite Borusyak et al. (2024) in methods discussion.
**Status:** For this revision (if feasible with continuous intensity); otherwise discuss and cite as future work.

### 1.5 Wild cluster bootstrap p-values
**Source:** GPT-5.2 (Section 2e, Item 4; Section 6A, Item 3)
**Concern:** With 51 clusters, wild cluster bootstrap would strengthen inference for the null result.
**Action:** Report wild cluster bootstrap p-values (Roodman et al. 2019) for main pooled and key specialty estimates alongside existing permutation inference.
**Status:** For this revision.

### 1.6 Clarify permutation inference implementation
**Source:** GPT-5.2 (Section 2e, Item 4)
**Concern:** Text says "randomizations of state treatment timing" but earlier describes reassigning "intensities." Must clarify what is permuted.
**Action:** Add precise description: permutation reassigns state-level disenrollment intensities across states while holding adoption timing fixed, consistent with the intensity-based identifying variation.
**Status:** For this revision.

---

## Theme 2: Power, Null Interpretation, and Magnitude

### 2.1 Minimum detectable effect (MDE) calculation
**Source:** GPT-5.2 (Section 3, Item 2; Section 6B); Grok-4.1-Fast (Section 2)
**Concern:** "Precisely estimated near zero" must be quantified. What elasticities can you rule out?
**Action:** Add explicit MDE calculation for pooled and key specialties. Report: "Given 51 clusters and observed variance, we can detect a [X]% decline in active providers for a 10pp increase in disenrollment intensity at the 5% level." Translate beta into economically meaningful units: exp(beta x Delta) - 1 for 10pp and 20pp intensity differences.
**Status:** For this revision.

### 2.2 Visual magnitude interpretation on event study
**Source:** GPT-5.2 (Section 6B, Item 2)
**Concern:** Adding a horizontal reference line for an economically meaningful negative effect helps readers see what the CIs rule out.
**Action:** Add dashed horizontal line at -5% effect on event study figure to visually show what magnitudes are ruled out.
**Status:** For this revision.

---

## Theme 3: Measurement Validation and Data Quality

### 3.1 Balance/orthogonality table for treatment intensity
**Source:** GPT-5.2 (Section 3, Item 1); Exhibit Review (Missing Exhibit #3)
**Concern:** Intensity could correlate with state baseline characteristics (politics, managed care share, rurality, baseline provider supply). Need to show intensity is not a proxy for confounders.
**Action:** Add balance table regressing state disenrollment intensity on baseline covariates (Medicaid expansion status, rurality share, baseline provider density, partisan lean, managed care penetration, unemployment rate). Include in main text or appendix.
**Status:** For this revision.

### 3.2 External validation of provider counts
**Source:** GPT-5.2 (Section 6C, Item 1)
**Concern:** Compare active provider counts to AHRF or other external benchmarks for credibility of the "atlas" claim.
**Action:** Add brief validation comparing 2018-2019 T-MSIS-based provider counts to AHRF county-level physician counts. Report correlation and systematic gaps. Even if imperfect, demonstrates the measure is not disconnected from reality.
**Status:** For this revision if AHRF data accessible; otherwise discuss limitations more extensively.

### 3.3 Managed care encounter completeness
**Source:** GPT-5.2 (Section 6C, Item 3; Section 4B)
**Concern:** T-MSIS encounter data quality varies across states and time. Managed care encounters may be incomplete.
**Action:** Add discussion of CMS DQ Atlas metrics for T-MSIS completeness. If feasible, show robustness restricting to FFS claims or states with high encounter completeness scores. At minimum, cite GAO (2017) and CMS T-MSIS documentation.
**Status:** For this revision (discussion and citations); FFS restriction if feasible.

### 3.4 Alternative outcomes less sensitive to suppression
**Source:** GPT-5.2 (Section 3, Item 3; Section 6D); Grok-4.1-Fast (Section 6)
**Concern:** Cell suppression in T-MSIS may attenuate effects. Additional outcomes less prone to suppression would strengthen null.
**Action:** Already partially addressed with total claims outcome. Add unique beneficiaries served if available in the data. Consider total paid amounts as an alternative measure.
**Status:** For this revision if data permits.

### 3.5 Billing vs. servicing NPI
**Source:** GPT-5.2 (Section 6C, Item 2)
**Concern:** Billing NPI may not capture who actually provides services.
**Action:** Strengthen existing discussion. If Type 1 NPI restriction is feasible (individual providers only), add as robustness check. Otherwise, expand limitations discussion noting direction of potential bias.
**Status:** Discussion for this revision; empirical check if feasible.

---

## Theme 4: Literature Gaps

### 4.1 Claims-based provider measurement and encounter data quality
**Source:** GPT-5.2 (Section 4B)
**Action:** Add citations: GAO (2017) on Medicaid managed care encounter data quality; CMS T-MSIS documentation.
**Status:** For this revision.

### 4.2 NP scope-of-practice and Medicaid substitution
**Source:** Grok-4.1-Fast (Section 4, Item 1)
**Action:** Cite Yang et al. (2023) on NP scope and rural primary care supply. Relevant to the all-clinicians measure innovation.
**Status:** For this revision.

### 4.3 Staggered DiD advances
**Source:** Grok-4.1-Fast (Section 4, Item 2); GPT-5.2
**Action:** Cite Borusyak et al. (2024) for imputation estimator; Roodman et al. (2019) for wild cluster bootstrap. Already cite Callaway-Sant'Anna, Sun-Abraham, Goodman-Bacon.
**Status:** For this revision.

### 4.4 T-MSIS data validation and unwinding utilization
**Source:** Grok-4.1-Fast (Section 4, Item 3)
**Action:** Cite Sommers et al. (2024) JAMA Health Forum on T-MSIS utilization after unwinding.
**Status:** For this revision.

### 4.5 Cell suppression bias in administrative data
**Source:** Grok-4.1-Fast (Section 4, Item 4)
**Action:** Cite Dowd et al. (2022) on cell suppression disclosure risk.
**Status:** For this revision.

### 4.6 Spatial access measurement
**Source:** GPT-5.2 (Section 4D)
**Action:** Cite Luo & Wang (2003) on 2-step floating catchment area methods. Acknowledge that county-level measurement is coarser than ideal spatial access metrics.
**Status:** For this revision.

### 4.7 Insurance expansions and healthcare workforce
**Source:** Gemini-3-Flash (Section 4)
**Action:** Cite Garthwaite et al. (2023) JoLE on supply-side response to ACA expansion. Natural counterpart to the unwinding contraction.
**Status:** For this revision.

### 4.8 Medicaid unwinding empirical literature
**Source:** GPT-5.2 (Section 4E)
**Action:** Add Wagner et al. (2023) Health Affairs Forefront and additional policy-tracker references. Be transparent about non-peer-reviewed nature of much unwinding evidence.
**Status:** For this revision.

---

## Theme 5: Exhibits and Visual Presentation

### 5.1 Move Table 2 and Table 3 to appendix
**Source:** Exhibit Review
**Concern:** Table 2 (yearly counts) is redundant with Figure 3; Table 3 (pre/post desert rates) is redundant with Figure 8.
**Action:** Move both to appendix. Free main-text space for balance table or forest plot.
**Status:** For this revision.

### 5.2 Add coefficient/forest plot for specialty estimates
**Source:** Exhibit Review (Missing Exhibit #1)
**Concern:** A forest plot of specialty-specific point estimates and 95% CIs would visually emphasize the "precisely estimated null across the board" more effectively than Table 4 alone.
**Action:** Add forest plot figure. Keep Table 4 in main text as well (numbers needed for reference).
**Status:** For this revision.

### 5.3 Revise Figure 2 axis label
**Source:** Exhibit Review
**Concern:** Y-axis label "Active Clinicians (county-quarter sum)" is clunky. Increase line weight for grayscale readability.
**Action:** Simplify to "Total Active Clinicians (Count)." Increase line weights.
**Status:** For this revision.

---

## Theme 6: Writing and Prose

### 6.1 Eliminate meta-talk
**Source:** Prose Review (Improvement #1)
**Concern:** Sentences like "The descriptive facts are striking" or "Several observations emerge from the atlas" tell rather than show.
**Action:** Delete or rewrite all meta-talk sentences. Replace with direct statements of findings.
**Status:** For this revision.

### 6.2 Punchier descriptive statistics
**Source:** Prose Review (Improvement #2)
**Concern:** Use Glaeser-style denominators. "In 99 out of 100 American county-quarters, a Medicaid patient seeking a psychiatrist will find effectively no one to bill for their care."
**Action:** Revise intro statistics for maximum impact.
**Status:** For this revision.

### 6.3 Temper "first claims-based atlas" language
**Source:** GPT-5.2 (Section 5, Item 2)
**Concern:** Add "to our knowledge" hedge and specify the exact scope.
**Action:** Revise to: "To our knowledge, we construct the first nationwide atlas of active Medicaid provider participation using T-MSIS claims/encounters covering both FFS and managed care at county-quarter frequency."
**Status:** For this revision.

### 6.4 Clarify outcome captures billing participation, not provider presence
**Source:** GPT-5.2 (Section 5, Item 3)
**Concern:** Null effects could mean providers stay but reallocate payer mix.
**Action:** Emphasize more prominently in Results interpretation that we measure Medicaid billing activity, not physical presence. A provider stopping Medicaid billing may still be practicing.
**Status:** For this revision.

### 6.5 Strengthen the "diluted demand" interpretation
**Source:** Prose Review (Improvement #4)
**Concern:** Make the null result feel "inevitable" by grounding in concrete terms.
**Action:** Add language: "For the median physician, a 15% drop in Medicaid enrollment amounts to roughly a 3% reduction in total patient volume — a perturbation, not a catastrophe."
**Status:** For this revision.

### 6.6 Refine final sentence
**Source:** Prose Review (Improvement #5)
**Concern:** End on stakes, not a research agenda.
**Action:** Revise closing to something like: "Policy has long focused on giving the poor an insurance card; our results suggest the harder task is ensuring there is a doctor on the other end of it."
**Status:** For this revision.

### 6.7 Minor formatting fixes
**Source:** GPT-5.2 (Format fixes)
**Concern:** Table notes formatting; capitalization consistency in "Specialty" labels.
**Action:** Clean up table note formatting. Standardize capitalization.
**Status:** For this revision.

---

## Theme 7: Extensions (Future Work / If Feasible)

### 7.1 New provider entry vs. established provider exit
**Source:** Gemini-3-Flash (Section 6, Item 1)
**Concern:** New practitioners' decisions to start billing Medicaid should respond faster than established practices with sunk costs.
**Action:** If data permits, decompose outcome into entry (new NPIs appearing) vs. exit (existing NPIs disappearing). Otherwise discuss as important future extension.
**Status:** Discuss; implement if feasible.

### 7.2 Interaction with Medicaid-to-Medicare fee index
**Source:** Gemini-3-Flash (Section 6, Item 2)
**Concern:** Does the null hold even in states where Medicaid pays the least? Would directly test the reimbursement mechanism.
**Action:** If state-level Medicaid-to-Medicare fee ratios are accessible, add interaction term to main specification. Otherwise discuss as future work.
**Status:** For this revision if data accessible.

### 7.3 Telehealth measurement
**Source:** Gemini-3-Flash (Section 6, Item 3)
**Concern:** Post-pandemic telehealth may mean rural "deserts" are served by urban clinicians. Geography assigned by NPPES address may misclassify.
**Action:** Acknowledge more prominently in limitations. Check for telehealth procedure codes (HCPCS G-codes) in data if feasible. Otherwise discuss as important caveat to desert measurement.
**Status:** Discussion for this revision; empirical check if feasible.

### 7.4 Border-county analysis
**Source:** GPT-5.2 (Section 3, Item 1); Internal Review
**Concern:** Complementary identification comparing counties near state borders with different intensities.
**Action:** Discuss as future extension. Implementation requires geocoding and border-pair construction beyond current scope.
**Status:** Future work.

### 7.5 Link deserts to health outcomes
**Source:** GPT-5.2 (Section 6E)
**Concern:** "So what?" beyond mapping. Linking desert status to ED visits, avoidable hospitalizations, or mortality raises stakes.
**Action:** Discuss feasibility briefly in conclusion as natural extension.
**Status:** Future work.

### 7.6 State-specific linear trends
**Source:** GPT-5.2 (Section 3, Item 1)
**Concern:** Robustness to state-specific trends would address confounding.
**Action:** Add specification with state-specific linear trends to robustness table. Note this is a demanding specification that may absorb treatment if intensity correlates with trends.
**Status:** For this revision.

### 7.7 "Pandemic expansion" falsification
**Source:** GPT-5.2 (Section 3, Placebos)
**Concern:** If volume mattered, supply should have risen more in states with larger pandemic-era enrollment growth (2020-2022).
**Action:** Add falsification test using pandemic expansion intensity in place of unwinding intensity. A similarly null result reinforces inelastic supply.
**Status:** For this revision if feasible.

---

## Summary of Priority Actions for v3

| Priority | Action | Theme |
|----------|--------|-------|
| High | Add MDE calculation and magnitude interpretation | 2 |
| High | Add balance table for treatment intensity | 3 |
| High | Clarify dose-response DiD identifying assumption | 1 |
| High | Clarify Sun-Abraham implementation with intensity | 1 |
| High | Add wild cluster bootstrap p-values | 1 |
| High | Add single-start specification to robustness | 1 |
| High | Add 8+ literature citations | 4 |
| Medium | Add forest plot of specialty estimates | 5 |
| Medium | Move Tables 2 and 3 to appendix | 5 |
| Medium | Eliminate meta-talk throughout | 6 |
| Medium | Clarify permutation implementation | 1 |
| Medium | Temper "first atlas" claim | 6 |
| Medium | Strengthen billing vs. presence discussion | 6 |
| Medium | Revise Figure 2 axis label | 5 |
| Lower | External validation against AHRF | 3 |
| Lower | Entry vs. exit decomposition | 7 |
| Lower | Reimbursement fee interaction | 7 |
| Lower | Pandemic expansion falsification | 7 |
| Future | Border-county analysis | 7 |
| Future | Link deserts to health outcomes | 7 |
| Future | Extend post-period with 2025 data | 7 |
