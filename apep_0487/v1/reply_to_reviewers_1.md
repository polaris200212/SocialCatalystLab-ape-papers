# Reply to Reviewers

## Common Theme: Inference Validity

**All three referees:** RI p=0.342 undercuts TWFE cluster-robust p<0.01.

**Response:** We agree that randomization inference is the appropriate inferential benchmark in this few-cluster setting. We have:
1. Increased RI permutations from 199 to 999 for more stable p-values
2. Reframed RI as the primary inference throughout the paper
3. Replaced "preferred specification" with "TWFE DDD specification"
4. Added explicit power discussion (new Section 7.4) explaining why the design lacks power to detect effects of this magnitude
5. Added Cameron, Gelbach & Miller (2008) citation for cluster inference

## Common Theme: TWFE vs CS-DiD Divergence

**All three referees:** Need to reconcile TWFE (0.0037***) vs CS-DiD (0.0014, n.s.)

**Response:** Added detailed reconciliation paragraph in Section 6.4 explaining three possible sources: (1) different estimands (slope effect vs. binary ATT), (2) potential negative weighting in TWFE from already-treated cohorts as implicit controls, (3) lower power of CS estimator in few-state setting. We note the CS pre-test rejection (p=0.01) may reflect small-sample instability rather than genuine violations, given flat visual pre-trends.

## GPT-5.2 Specific Concerns

**1.1 Estimand clarity:** We now clearly state the estimand as "the change in the slope of donations with respect to baseline Medicaid dependence induced by expansion." The event study uses HighMed (binary) for visual clarity; we acknowledge this is a different estimand than the continuous specification.

**1.2 Cross-state event study:** We added text explicitly noting the event study tests within-expansion-state parallel trends only, with cross-state evidence from Figure 1. A full DDD event study including non-expansion states would require pseudo-event-time assignment; we note this as a direction for future work.

**1.3 Treatment timing:** We added a dedicated paragraph in Threats to Validity explaining partial pre/post contamination and arguing it produces attenuation bias. We acknowledge GPT's point that the sign of bias is ambiguous if donations are concentrated near elections; however, for the extensive margin (any donation in the cycle), the attenuation argument holds.

**2.1 RI as primary:** Done. RI with 999 permutations is now the primary inferential benchmark.

**2.4 Donors-only regressions:** We agree these are descriptive given endogenous selection into donating. The text already treats them as supplementary. We clarify that the causal claim rests on the extensive margin only.

## Grok-4.1-Fast Specific Concerns

**Replace TWFE with CS-DiD as primary:** We chose not to make CS-DiD the primary specification because the DDD interaction estimand differs fundamentally from the CS group-time ATT. We now present both transparently, with RI as the primary inference benchmark.

**Full cross-state event study:** Noted as a direction for future work. The current event study within expansion states, combined with descriptive evidence in Figure 1 across state groups, provides partial support.

**Expand RI to 999 permutations:** Done.

**Medicare data:** Not available at the time of analysis. The percentile rank of Medicaid revenue is a monotone transformation that preserves ordering.

## Gemini-3-Flash Specific Concerns

**Reconcile CS-DiD and TWFE:** See reconciliation discussion above.

**Wild cluster bootstrap:** We added Cameron et al. (2008) citation and note this as an alternative. Given the RI result already contradicts TWFE significance, the marginal value of wild bootstrap is limited.

**Annual data:** We agree this would reduce cycle-contamination bias but maintain cycle-level aggregation for consistency with FEC reporting periods. Noted as high-value future improvement.

**Mechanism analysis:** The partisan share SE of 8.2pp reflects low power (N~970 donors). More granular outcome coding (health committee donations, pro-expansion candidates) is a promising direction but requires additional data construction beyond the scope of this paper.

## Prose and Exhibit Improvements

- Killed the roadmap paragraph (prose review suggestion)
- Active voice in data section
- Added representativeness paragraph for linkage validation
- Added statistical power subsection
