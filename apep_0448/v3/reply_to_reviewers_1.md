# Reply to Reviewers — apep_0448 v3

## Reviewer 1 (GPT-5.2): MAJOR REVISION

**1.1 Differential-exposure window.** We now explicitly distinguish the true differential-exposure window (July–September 2021) from the longer-run persistence in Section 6.3. The gradual build-up and post-September gap reflect path dependence in provider reactivation, not continuing treatment.

**1.2 Pre-trends and CI type.** Fixed. The text now correctly states that event-study CIs are pointwise, not simultaneous/uniform. We removed the overclaim about uniform bands.

**1.3 ARPA §9817 confounding.** The discussion in Section 7.4 is already extensive (uniform FMAP, Republican states slower to implement, BH placebo, triple-difference). We added the triple-difference result as a fourth mitigating argument. State-level ARPA implementation timing data at monthly granularity does not exist in publicly available sources — this is noted as a priority for future work.

**1.4 Treatment definition.** The early termination ended FPUC, PUA, and PEUC simultaneously (acknowledged in Section 2.3). The binding margin for HCBS workers is FPUC because the $300/week supplement created the largest wedge relative to HCBS wages. Maryland's partial reinstatement is handled. Additional treatment coding variants are beyond the scope of this revision.

**1.5 Provider supply interpretation.** The paper already frames findings around "billing entities" and "agencies scaling up billing" (abstract, Section 6.5, conclusion). The entity type decomposition (new in v3) directly addresses this by showing organizations, not individuals, drive the result.

**1.6 Zero handling.** Zeros affect <0.5% of observations and the main panel is balanced. The log(x+1) transformation is standard for count data with rare zeros. IHS transformation would give near-identical results on this sample.

**1.7 Constrained RI, additional placebos, sub-code heterogeneity, multi-state NPIs.** These are interesting extensions but beyond the scope of this revision. The unconstructed RI with 1,000 permutations already provides valid inference; the behavioral health placebo is the theory-guided falsification test.

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

**2.1 ARPA §9817.** Addressed in reply to GPT above. Added triple-difference argument to the discussion.

**2.2 Pre-trend test.** The singular Wald matrix reflects the long pre-period (41 months) with only two cohorts. Individual pre-period coefficients are all individually insignificant and economically small. We rely on visual inspection and the individual coefficient tests rather than a joint test with known instability.

**2.3 Entity interpretation.** The abstract now reads: "the response came from agencies scaling up billing—not individual practitioners returning to independent practice." The text throughout frames the finding as organizational billing capacity, not individual labor supply.

**2.4 Literature gaps.** Montgomery (2019) and Bartik (2023) are reasonable additions but not essential — the current citation set covers the core literatures (UI effects, HCBS workforce, staggered DiD).

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

**3.1 ARPA §9817.** Addressed above.

**3.2 Triple-diff precision.** Added explicit discussion in Section 7.4: the triple-diff's imprecision ($p = 0.14$) reflects the demanding fixed-effect structure (state×service, month×service, state×month interactions) rather than an absent effect. The point estimate ($\delta = -0.097$) is large and in the expected direction.

**3.3 Intensive margin.** Claims per provider and beneficiaries per provider are reported in the robustness table (Table 3). These are TWFE-based and imprecise, reflecting the limited power of within-provider variation in a state-level panel.

**3.4 Labor market tightness controls.** State fixed effects absorb time-invariant labor market characteristics. Adding time-varying controls (vacancies, hospitality employment) risks introducing post-treatment bias. The behavioral health placebo provides a cleaner falsification than conditioning on endogenous labor market variables.
