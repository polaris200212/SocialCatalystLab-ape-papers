# Reply to Reviewers — Round 1

## Overview of Changes

We thank all three referees for detailed and constructive feedback. The revision addresses the major concerns through five categories of changes:

1. **Structural model rewrite** — Fixed three mathematical inconsistencies identified by theory review: (a) the DeGroot→SAR mapping is now algebraically consistent (standard SAR without the (1-ρ) convex-combination scaling), (b) the "network multiplier" is correctly defined as the total effect multiplier 1/(1-ρ) for row-stochastic W (not the average diagonal), and (c) the estimation is correctly described as quasi-ML on within-transformed data.

2. **SAR reframing** — The structural section is now explicitly framed as a *descriptive propagation model*, not causal contagion. Added explicit caveats about ρ capturing correlated effects, absence of SEM comparison as limitation, and clarified that causal evidence rests on the reduced-form specifications.

3. **Additional robustness** — Added region×election FE specification (Row 6 in robustness table). Point estimate stable (0.47 vs 0.48 baseline) but SE doubles and significance is lost, interpreted as demanding upper bound on identifying variation.

4. **RI discord** — Expanded discussion of RI p=0.135 vs clustered p<0.01 with transparent two-sided interpretation (underpowered RI vs fragile spatial configuration).

5. **Treatment timing** — Strengthened caution throughout about the 2012→2014 event study shift, emphasizing it is suggestive but not dispositive given single pre-treatment observation.

---

## Point-by-Point Responses

### Referee 1 (GPT-5.2)

**1.1–1.3 Identification: Pre-trends and treatment timing**

> Single pre-period limits parallel trends assessment. Large 2012→2014 shift could reflect other factors. Treatment timing ambiguous.

We agree this is the paper's most important limitation. The revision:
- Reframes the 2012→2014 shift throughout as "suggestive but not dispositive," explicitly noting it coincides with many other political changes (Eurozone crisis, FN normalization, Hollande→2014 FN surge).
- Removes language implying the shift is causal evidence of carbon tax activation.
- Notes in the event study section that "with only a single pre-treatment observation, this pattern is consistent with the carbon tax activating the network channel, but it could also reflect a pre-existing divergence driven by other factors."
- The limitation on additional pre-periods (legislative, municipal elections) is acknowledged but these raise comparability issues (different electoral rules, candidate sets, turnout patterns) that would require substantial additional analysis beyond this revision's scope.

**1.4–1.5 Network exposure exogeneity and correlated shocks**

> SCI weights encode migration, similarity, culture. Need region×election FE and richer controls.

We add region×election FE (13 regions × 6 elections = 78 FE) as Row 6 of the robustness table. The network coefficient is 0.47 pp (SE = 0.35) — virtually identical in magnitude to the baseline (0.48) but no longer statistically significant. We interpret this transparently: the point estimate stability is reassuring (the effect is not driven by region-specific trends), while the loss of significance reflects reduced identifying variation when region-level trends are absorbed. A new subsection discusses this result.

We acknowledge the referee's point that a single income control is insufficient for a strong causal claim. The paper's identification rests on the combination of: predetermined SCI weights, commune/election FE, distance restriction (>200km), turnout placebo, and leave-one-out stability — collectively suggestive but not airtight.

**1.6 Selection bias from dropping communes without RN candidates**

We acknowledge this concern in the limitations section. The département-level results (Table 2), where the RN list is always present in European elections and Le Pen is always a presidential candidate, serve as a robustness check against selection. The département-level results show both own and network effects are large and significant (population-weighted), suggesting that commune-level selection is not driving the main finding.

**2.1–2.3 Inference: RI discord, wild bootstrap, shift-share**

The RI discussion is substantially expanded. We now present both the "optimistic reading" (RI underpowered with 96 spatial units, citing Young 2019) and the "pessimistic reading" (the network effect is sensitive to the spatial configuration of fuel vulnerability). We state explicitly: "I do not resolve this tension; readers should note both the strong regression-based evidence and the RI caveat."

Wild cluster bootstrap was attempted but the fwildclusterboot R package could not be installed in our environment. We note this as a limitation.

**2.4 SAR model: not credible as causal**

Fully addressed. The structural section is now titled "Interpreting ρ̂=0.97: A Descriptive Propagation Model" and explicitly states that ρ "should be interpreted as a descriptive measure of network-correlated voting patterns rather than a causal estimate of interpersonal contagion." We note the absence of SEM comparison as a limitation and state that "the SAR specification should be understood as an upper bound on network transmission."

**5.1–5.2 Effect sizes and contradictions**

The multiplier language is corrected (total effect multiplier = 1/(1-ρ) ≈ 33.3, not "average diagonal"). Counterfactual language now includes caveat that "some of this 'network' component may reflect correlated unobservables." The 2012→2014 / Post=2017+ tension is addressed by reframing the event study shift as descriptive rather than causal.

**6.6 Reframe SAR section**

Done. See structural model changes described above.

---

### Referee 2 (Grok-4.1-Fast)

**Pre-trends: single 2012 observation**

> No formal pre-trend test; single pre limits credibility for causal claim.

See response to Referee 1, 1.1–1.3. The revision explicitly acknowledges the limitation and removes causal language about the 2012→2014 shift. We note that the temporal pattern is "suggestive but not dispositive."

**Treatment timing: continuous dose**

> Why not continuous dose (CO2 × rate_t)?

The main specification uses standardized CO2 × Post because the tax rate schedule is deterministic (national, not staggered), so CO2 × rate_t is perfectly collinear with CO2 × election FE. The event study specification already provides election-specific coefficients, which is the appropriate continuous-time generalization.

**RI discord: p=0.135 vs p<0.01**

See expanded RI discussion above. Both readings are now presented transparently.

**SAR boundary: ρ=0.97 near 1**

The theory review identified three mathematical inconsistencies that have been fixed:
1. The DeGroot→SAR equation mapping is now algebraically consistent (standard SAR form).
2. The multiplier is correctly defined as 1/(1-ρ) ≈ 33.3 (total effect for row-stochastic W), not the average diagonal.
3. The estimation is correctly labeled quasi-ML on within-transformed data.

The interpretation is now explicitly descriptive, with stability verified through cross-sectional estimates (ρ ranges 0.95–0.98 across elections).

**Missing literature: Geissler/Kesternich, Bargain et al.**

We note these suggestions for future work but do not add citations that we cannot verify in the current bibliography, as fabricating citation details would be worse than omitting them.

**Bartik exogeneity: p=0.054 marginal**

Acknowledged in the text with appropriate caution: "The failure to reject at 5% provides evidence that the SCI shares are approximately exogenous, though the marginal significance at 10% warrants caution."

---

### Referee 3 (Gemini-3-Flash)

**2012–2014 shift: could reflect other factors**

See response to Referee 1, 1.1–1.3. The revision reframes this shift as coinciding with "many other changes in the French political landscape" and notes it is "suggestive but not dispositive."

**ρ=0.97 likely captures correlated shocks, not just contagion**

Fully addressed. The structural section is reframed as a descriptive propagation model with explicit caveats about correlated effects. We note the absence of SEM comparison and state that "the SAR specification should be understood as an upper bound on network transmission."

**RI p-value higher than regression p-value**

See expanded RI discussion above.

**Sensitivity of ρ: horse race with spatial lags of covariates**

We note this as a valuable suggestion. The cross-sectional stability of ρ (0.95–0.98 across elections) provides partial evidence, but a direct test with additional spatial lag terms is not implemented in this revision.

**Distance-restricted SCI as strength**

We appreciate the referee's recognition that the >200km specification is "a major strength." This result (0.39 pp, p<0.01) remains a cornerstone of the identification strategy.

**Rotemberg weight visualization**

The Bartik diagnostics are now in a formal appendix table (Table B.2) with Rotemberg weight concentration and share exogeneity results. A map of top-Rotemberg-weight départements would be a valuable addition for a future revision.

**Heterogeneity by Facebook penetration**

This is an excellent suggestion. Département-level Facebook penetration data is not readily available in the public SCI dataset, but this would be a valuable extension if such data can be obtained.

---

## Summary of Changes Not Made (with rationale)

1. **Additional pre-period elections** — Legislative, municipal, and regional elections use different electoral systems, candidate sets, and turnout patterns that make harmonization non-trivial. We acknowledge this limitation explicitly.

2. **Wild cluster bootstrap** — Package installation failed in our R environment. Noted as limitation.

3. **SEM comparison** — Noted as explicit limitation in the "Interpreting ρ̂=0.97" section. The absence of an SEM comparison means the SAR ρ likely conflates endogenous feedback with correlated effects.

4. **Balanced panel / RN votes per registered** — The département-level results (where the RN is always present) serve as a partial robustness check. Full balanced panel construction is deferred.

5. **Mechanism evidence** (Facebook group data, Google Trends, survey beliefs) — These would substantially strengthen the paper but require data sources not available in this revision.
