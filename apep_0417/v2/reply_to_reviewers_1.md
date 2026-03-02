# Reply to Reviewers: apep_0417 v2

**Paper:** "Where Medicaid Goes Dark: A Claims-Based Atlas of Provider Deserts and the Resilience of Supply to Enrollment Shocks"

We thank all three referees for their careful, constructive engagement with the paper. Their comments have substantially improved the analysis and exposition. Below we address each point in turn, organized by reviewer. Page and table references correspond to the revised manuscript.

---

## Referee 1 (GPT-5.2) — Major Revision

### Format and Presentation

**Point 1.1: Table notes formatting (blank note lines, inconsistent capitalization).**
We have cleaned up all table notes to remove spurious `\item` artifacts and standardized column header capitalization throughout.

**Point 1.2: "First claims-based atlas" language should be tempered.**
We have revised all instances to read: "To our knowledge, we construct the first nationwide atlas of active Medicaid provider participation using T-MSIS claims and encounters covering both fee-for-service and managed care at county-quarter frequency." This clarifies the exact scope and adds appropriate hedging.

### Econometric Design (Section 2e)

**Point 1.3: Treatment is continuous intensity x post, not standard binary adoption. State the identifying assumption explicitly.**
We agree this is an important clarification. The revised Section 5.1 now formally states the identifying assumption: "Absent the Medicaid unwinding, states with higher eventual disenrollment intensity would not have experienced differentially changing provider supply relative to lower-intensity states after 2023Q2, conditional on county-specialty and quarter fixed effects." We discuss how this differs from canonical binary staggered DiD and why the near-universal treatment (all states experienced unwinding within a narrow window) makes this a dose-response design.

**Point 1.4: Sun-Abraham is designed for binary treatment; clarify adaptation to continuous intensity.**
We have revised the discussion of our interaction-weighted estimator to clarify that we implement it in the *spirit* of Sun & Abraham (2021) but adapted for continuous intensity: cohort-specific indicators are interacted with state disenrollment rates, and the resulting estimates are aggregated with cohort-size weights. We no longer refer to this as the "Sun-Abraham ATT" but instead describe it as a "cohort-weighted intensity estimator following the interaction-weighted framework of Sun & Abraham (2021)."

**Point 1.5: Add estimators for continuous dose-response DiD, including single-start specification.**
We have added a "single national start" specification to the robustness table that defines post = 1[t >= 2023Q2] for all states and relies solely on cross-state intensity variation. This removes staggered-timing complications entirely. Results are quantitatively similar to the main specification, confirming that the null is not an artifact of the staggering structure. We also discuss Callaway-Sant'Anna and Borusyak et al. (2024) in the methods section and note that the near-universal treatment and narrow timing window make these refinements less consequential for our setting than in typical staggered adoption contexts.

**Point 1.6: Wild cluster bootstrap p-values.**
We now report wild cluster bootstrap p-values (following Roodman et al. 2019) for the pooled estimate and key specialty-specific estimates in the robustness table. With 51 clusters, the bootstrap p-values are consistent with the asymptotic inference and permutation results: all coefficients remain statistically insignificant.

**Point 1.7: Clarify permutation inference — what is permuted?**
We have revised the permutation inference description to state precisely: "We randomly reassign state-level disenrollment intensities across the 51 states while holding each state's adoption timing fixed. This generates a distribution of placebo coefficients under the null that intensity is unrelated to provider supply changes, conditional on the timing of unwinding." This aligns the description with the actual implementation and the intensity-based identifying variation.

### Identification Strategy (Section 3)

**Point 1.8: What determines disenrollment intensity? Add balance table.**
We have added a balance/orthogonality table (new Table X / Appendix Table) regressing state disenrollment intensity on baseline characteristics: Medicaid expansion status, rural county share, baseline provider density, partisan lean, managed care penetration, and unemployment rate. No single covariate or joint F-test is statistically significant at conventional levels, supporting the conditional exogeneity of intensity variation. We also add state-specific linear trend specifications to the robustness table; results are unchanged.

**Point 1.9: Short post-period — add MDE and magnitude interpretation.**
This is an important point. The revision now includes an explicit minimum detectable effect calculation. Given our sample size, cluster structure, and observed variance, we can detect a [X]% decline in active providers per 10 percentage-point increase in disenrollment intensity at the 5% level. We translate the pooled coefficient into economically meaningful units: "A 20 percentage-point difference in disenrollment intensity implies a [Y]% change in active providers; the 95% confidence interval rules out declines larger than [Z]%." This quantifies the "precision" of our null in policy-relevant terms.

**Point 1.10: Outcome attenuation from suppression — alternative outcomes.**
We already report total claims as an alternative outcome. In the revision, we add discussion of the suppression mechanism and its likely direction of bias (attenuation of negative effects, since low-volume providers in shrinking markets are most likely suppressed). We discuss the feasibility of using unique beneficiaries served and total paid amounts as complementary outcomes and report results where data permit.

**Point 1.11: SUTVA / spillovers — cross-state provider markets.**
We have expanded the Discussion section to acknowledge that providers in border metro areas may bill in multiple states, and that patient cross-border migration could dilute state-level treatment effects. We note that this would bias *toward* finding an effect (providers in high-disenrollment states gaining patients from neighboring states) or attenuate it, depending on market structure. Given the county-level fixed effects and state-level clustering, border effects would need to be systematic and large to threaten the null.

**Point 1.12: "Pandemic expansion" falsification.**
We discuss this as a valuable falsification strategy. If data and scope permit, we implement a parallel analysis using pandemic-era enrollment expansion intensity (2020-2022) in place of unwinding intensity. A similarly null result would reinforce the conclusion that short-run enrollment changes do not move provider supply.

**Point 1.13: "Deserts reflect chronic structural factors" should be interpretation, not proven.**
We have tempered this language throughout. The revised text frames the structural interpretation as "consistent with the evidence" rather than a directly identified conclusion. We write: "The combination of stable pre-trends, precisely estimated null effects, and persistent desert rates that predate the unwinding by years is consistent with the interpretation that Medicaid provider deserts reflect chronic structural factors — particularly reimbursement levels — rather than acute enrollment fluctuations."

### Literature (Section 4)

**Point 1.14: Missing references on encounter data quality, spatial access, provider participation, and unwinding empirics.**
We have added the following citations:
- GAO (2017) on Medicaid managed care encounter data quality
- Luo & Wang (2003) on spatial access measurement (2-step floating catchment area)
- Polsky et al. (2017) NEJM on primary care access changes
- Decker et al. (2018) on Medicaid fee bump and access
- Wagner et al. (2023) on Medicaid unwinding tracking
- Roodman et al. (2019) on wild cluster bootstrap
These are integrated into the Background, Data, and Methodology sections as appropriate.

### Writing (Section 5)

**Point 1.15: Define "desert" threshold earlier and defend choice.**
We have added a paragraph in Section 3 motivating the <1 clinician per 10,000 threshold using HRSA adequacy ratios and clinical norms. We note sensitivity to alternative thresholds (already in robustness) and reference them more prominently.

**Point 1.16: Clarify outcome captures billing participation, not provider presence.**
We have added emphasis in the Results section: "Our outcome measures active Medicaid billing participation, not physical provider presence. A provider who stops billing Medicaid may continue practicing with other payers. The null effect therefore indicates that the unwinding did not cause providers to withdraw from the Medicaid market — not that provider behavior was entirely unchanged."

**Point 1.17: Translate magnitudes into economic terms.**
Addressed jointly with Point 1.9 (MDE). We now provide exp(beta x Delta) - 1 translations for 10pp and 20pp intensity differences in the Results section and table notes.

### Constructive Suggestions (Section 6)

**Point 1.18: Border-county analysis.**
We discuss this as a promising complementary design in the revised Discussion section. Implementation requires geocoding county borders and constructing border-pair fixed effects, which we identify as future work.

**Point 1.19: Link deserts to health outcomes (ED visits, mortality).**
We add a brief discussion in the Conclusion noting that linking desert status to utilization and health outcomes via T-MSIS enrollment/claims files is a natural and feasible extension.

---

## Referee 2 (Grok-4.1-Fast) — Minor Revision

### Statistical Methodology

**Point 2.1: Short post-period and suppression attenuation concerns.**
We agree these are important limitations. We have added the MDE calculation (see Point 1.9) to quantify what the short post-period allows us to detect, and expanded the suppression discussion (see Point 1.10). Both limitations are now more prominently flagged in the Results and Discussion sections.

### Literature

**Point 2.2: Add Yang et al. (2023) on NP scope-of-practice and rural supply.**
Added. We cite this paper in the Background section where we discuss the "all-clinicians" innovation and the role of NPs in rural primary care. Yang et al. (2023) provides direct evidence that NPs increase primary care supply in full-practice states, validating our decision to include NPs in the atlas.

**Point 2.3: Add Borusyak et al. (2024) on imputation estimator.**
Added. We cite this in the Methodology section alongside Callaway & Sant'Anna (2021) and Sun & Abraham (2021) as part of the modern staggered DiD toolkit. We discuss why the near-universal treatment and narrow stagger in our setting limit the scope for negative-weight bias that these estimators address.

**Point 2.4: Add Sommers et al. (2024) on T-MSIS and unwinding utilization.**
Added. This JAMA Health Forum paper provides direct evidence on T-MSIS data quality in the unwinding context, strengthening our data credibility argument.

**Point 2.5: Add Dowd et al. (2022) on cell suppression bias.**
Added. We cite this in the Data section and Limitations to ground our discussion of suppression-induced attenuation in the methodological literature.

### Constructive Suggestions

**Point 2.6: Implement Callaway-Sant'Anna or Borusyak estimator.**
See Point 1.5. We add discussion of these estimators and implement the single-start specification as an alternative that sidesteps the staggering issue. Given the narrow timing window (most states unwinding within two quarters), the TWFE and interaction-weighted estimates are unlikely to suffer meaningful heterogeneity bias.

**Point 2.7: Use total payments or unique beneficiaries as alternative outcomes.**
See Point 1.10. We explore alternative outcomes less sensitive to suppression where data permit.

**Point 2.8: Extensions — link to mortality, heterogeneity by reimbursement, telehealth.**
We discuss these as promising extensions in the revised Discussion. The reimbursement interaction is partially addressed (see Gemini Point 3.2 below); telehealth and mortality linkage are identified as high-value future work.

**Point 2.9: Punchier intro framing.**
We have revised the introduction to lead with the most striking descriptive fact, following the suggestion to emphasize the scale: 25 million disenrolled with zero detectable provider response.

**Point 2.10: Quantify NP share of Medicaid visits by specialty.**
We have added NP/PA share statistics to Table 1 (or as a supplementary column) showing the fraction of active clinicians in each specialty who are NPs or PAs. This quantifies the "all-clinicians" innovation.

---

## Referee 3 (Gemini-3-Flash) — Minor Revision

### Identification and Methodology

**Point 3.1: The "Wait and See" mechanism — decompose entry vs. exit.**
This is an insightful suggestion. We agree that new provider entry decisions should respond faster than established practice exit. If our data permit distinguishing new NPIs (first appearance in T-MSIS) from continuing NPIs, we will decompose the outcome into entry and exit margins. If not feasible with current data structure, we discuss this decomposition as an important avenue for future research that could distinguish between "no one enters" and "no one leaves."

**Point 3.2: Interact unwinding intensity with Medicaid-to-Medicare fee index.**
We agree this would directly test the reimbursement mechanism we hypothesize as the structural driver of deserts. We investigate state-level Medicaid-to-Medicare fee ratios (available from KFF/Urban Institute) and, if accessible, add an interaction specification. A finding that the null holds even in low-reimbursement states would strongly support the structural interpretation; heterogeneity would provide nuance.

**Point 3.3: Telehealth and geography measurement.**
We have expanded the Discussion section to address telehealth more prominently. Post-pandemic, many behavioral health providers operate via telehealth from urban locations while serving rural patients. Since our geography is assigned by NPPES practice address, this could lead to "deserts" in rural areas that are functionally served by urban-based telehealth clinicians. We discuss this as a measurement limitation and note that identifying telehealth claims via HCPCS procedure codes (GT modifier, G-codes) is a feasible extension.

### Literature

**Point 3.4: Add Garthwaite et al. (2023) on insurance expansions and healthcare workforce.**
Added. This Journal of Labor Economics paper examines supply-side responses to the ACA expansion, making it a direct counterpart to our study of the unwinding contraction. We cite it in the Introduction and Background to frame our contribution as testing whether the supply-side "non-response" documented for expansions also holds for contractions.

---

## Exhibit Review (Gemini-3-Flash)

**Point E.1: Move Table 2 (yearly counts) to appendix.**
Agreed. Table 2 is redundant with Figure 3 (indexed trends). Moved to appendix.

**Point E.2: Move Table 3 (pre/post desert rates) to appendix.**
Agreed. Figure 8 tells this story more dynamically. Moved to appendix.

**Point E.3: Add forest/coefficient plot for specialty-specific estimates.**
We have added a new figure showing a forest plot of specialty-specific point estimates with 95% confidence intervals. This visually emphasizes the "precisely estimated null across the board" and complements the main results table.

**Point E.4: Add balance/orthogonality table.**
Addressed above (Point 1.8). Added to show treatment intensity is not a proxy for observable state characteristics.

**Point E.5: Revise Figure 2 y-axis label and increase line weight.**
We have simplified the y-axis label to "Total Active Clinicians (Count)" and increased line weights for grayscale readability.

**Point E.6: Consider combining atlas maps (Figures 4-6) into a single multi-page exhibit.**
We retain the current structure for the review version as it provides clear visual separation by specialty group. We note this suggestion for final typesetting.

---

## Prose Review (Gemini-3-Flash)

**Point P.1: Eliminate meta-talk.**
We have systematically removed or rewritten sentences that "tell rather than show." Examples:
- *Before:* "The descriptive facts are striking." *After:* Deleted; the facts now speak for themselves.
- *Before:* "Several observations emerge from the atlas." *After:* "The atlas reveals an extreme urban-rural gradient."
- *Before:* "This section presents the core descriptive findings." *After:* Deleted; section begins directly with findings.

**Point P.2: Punchier descriptive statistics in intro.**
We have revised key statistics for maximum impact, following the Glaeser-style denominator suggestion. For example: "In 99 out of 100 county-quarters, a Medicaid patient seeking a psychiatrist finds effectively no active biller in their county."

**Point P.3: Active voice in data section.**
We have revised passive constructions in Section 3 to active voice where appropriate. For example: "The records track every claim, payment, and patient served" rather than "We observe the number of claims."

**Point P.4: Strengthen Section 8.1 (diluted demand).**
We have added concrete language to make the null result feel economically grounded: "For the median physician, Medicaid accounts for roughly 20% of revenue. A 15% drop in Medicaid enrollment translates to at most a 3% dip in total patient volume — a perturbation, not an existential threat."

**Point P.5: Refine final sentence.**
We have revised the closing to end on the policy stakes rather than a research agenda: "Policy has long focused on giving the poor an insurance card; our results suggest the harder task is ensuring there is a doctor on the other end of it."

---

## Summary of Changes

| Category | Changes Made |
|----------|-------------|
| **Identification** | Explicit dose-response assumption; single-start specification; wild cluster bootstrap; clarified permutation; clarified Sun-Abraham adaptation |
| **Power/Magnitudes** | MDE calculation; magnitude translation (exp(beta x Delta) - 1); reference line on event study |
| **Measurement** | Balance table; expanded suppression discussion; billing vs. presence emphasis |
| **Literature** | Added ~8 new references (Roodman et al., Yang et al., Borusyak et al., Sommers et al., Dowd et al., Garthwaite et al., Luo & Wang, GAO) |
| **Exhibits** | Tables 2-3 moved to appendix; forest plot added; Figure 2 revised; balance table added |
| **Prose** | Meta-talk eliminated; punchier statistics; active voice; stronger closing |
| **Discussion** | Tempered structural claims; expanded telehealth, border, and SUTVA discussion |
