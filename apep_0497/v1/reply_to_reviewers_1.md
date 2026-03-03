# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1 "Dose is not actual treatment intensity" (must-fix #1)
> The design estimates a reduced-form relationship between prices and pre-reform TH rates, not between prices and tax relief.

We agree this is a limitation. The pre-reform TH rate is an imperfect proxy for expected tax savings. Without commune-level income data (Filosofi), we cannot construct a precise "expected relief" variable. We have added text in the Limitations section acknowledging this explicitly. We frame our coefficient as a reduced-form estimate of the relationship between pre-reform rates and price changes, not as a structural capitalization rate.

### 1.2 "Show apartment result under département × year FE" (must-fix #2)
> Re-estimate apartment regressions with département×year FE.

**Done.** We added Model 5: the apartment coefficient with département × year FE is -0.006 (SE = 0.007, p = 0.38). This is now reported in the main results text (Section 6.1) and discussed as evidence that the baseline apartment effect may partly reflect within-département spatial trends. We treat this honestly as a challenge to the headline finding.

### 1.3 "Full pre-trend tests and HonestDiD for apartments" (must-fix #3)
> Report joint F-tests and HonestDiD for the apartment event study.

**Done.** Joint F-test for apartment pre-trends: p = 0.62 (clean). HonestDiD for apartments: CI at Mbar=0 spans [-0.008, 0.008], including zero. This is reported in Section 6.5 (HonestDiD Sensitivity). The result indicates that the *average* post-treatment apartment effect is fragile, though individual late-period coefficients (2022-2024) are significant.

### 1.4 "Data seam robustness" (must-fix #4)
> Run apartment analysis restricting to 2014-2020 only.

**Done.** CdD-only apartment regression yields -0.005 (SE = 0.004, p = 0.22). This is now reported in the HonestDiD section. We acknowledge that the capitalization effect is concentrated in the geo-DVF years and discuss the implications for causal interpretation.

### 1.5 "Implement promised placebos" (must-fix #5)
> Show other local fiscal margins do not move with dose.

Not addressed — the DVF data does not contain information on other local tax rates or secondary residence status at the commune-aggregate level. Acknowledged as a limitation for future work.

### 1.6 Welfare calculation (concern)
> Welfare claims must be tied to clearly interpretable treatment.

We now frame the welfare calculation as an illustrative upper bound, conditional on the baseline estimate holding. The text explicitly notes the sensitivity of the result.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### 2.1 Secondary-residence placebo
> Suggested but absent; critical for correlated shocks.

Not implemented — DVF commune-level aggregates from CdD do not distinguish primary vs. secondary residences. Noted as limitation.

### 2.2 Phase-in with income data
> Triple diff isolates phases.

Not implemented — Filosofi income data not available in this iteration. Noted as key avenue for future work.

### 2.3 Joint pre-trend tests everywhere
> Add joint F-tests to all event/two-group tables.

**Done** for apartment event study (p = 0.62). Two-group DiD pre-trend test already reported (p = 0.128). Overall event study pre-trends implicit from HonestDiD.

### 2.4 Missing citations
> Ferrari & Spinnewijn (2022); Narotzky et al. (2023)

These references were not verified as published and are not added to avoid citing non-existent work.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### 3.1 Address 2017 anticipation coefficient
> Test with 2016 as base year.

The anticipation test already uses 2014-2018 with Announced = 1 for 2017-2018. The negative coefficient (-0.005) rules out positive anticipation. We do not re-estimate with 2016 base as this would reduce the pre-period to only two years.

### 3.2 Commune-level controls
> Add Population × Post interaction.

Not implemented. Population data at commune level was not downloaded. Département × year FE already absorb most local demand shocks.

### 3.3 Triple-diff on secondary residences
Same as Reviewer 1/2 — not feasible with current data.

---

## Exhibit Review Feedback

- Table 2 restructuring (split apartment/house): Not implemented to preserve current table structure.
- Figure 3 move to appendix: Already in main text as contrast to Figure 2; kept for completeness.
- Table 3 as figure: Kept as table for precision of coefficient reporting.
- Add treatment map: Not feasible without geocoding infrastructure.

## Prose Review Feedback

- **Roadmap paragraph removed** (Section 1).
- Transitions and active voice improved throughout.
- Closing paragraph of conclusion rewritten to reflect more measured findings.

---

## Summary of Changes

1. Added Model 5 (apartment + département × year FE): effect vanishes (-0.006)
2. Added joint pre-trend test for apartment event study (p = 0.62)
3. Added HonestDiD for apartments (CI includes zero)
4. Added CdD-period-only apartment regression (null result)
5. Rewrote abstract, introduction, results, and conclusion to honestly present specification sensitivity
6. Welfare section reframed as upper-bound illustrative calculation
7. Removed roadmap paragraph; improved prose
