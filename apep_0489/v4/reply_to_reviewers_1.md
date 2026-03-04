# Reply to Reviewers — apep_0489 v4, Round 1

## Summary of Changes

All three reviewers converge on the need for uncertainty quantification beyond the "population quantities" stance. We substantially expanded the Inference Framework section to address this:

1. **Acknowledged design-based uncertainty explicitly** — the counterfactual is unobserved regardless of sample size
2. **Added cell reliability classification** — robust/plausible/uncertain based on cross-estimator agreement and sample size
3. **Reframed placebo as quasi-RI** — the placebo provides an informal randomization check with a 1.5pp benchmark
4. **Strengthened RI discussion** — described as "principled design-based framework," not just "future work"
5. **Added linkage selection discussion** — new limitation paragraph quantifying the issue
6. **Expanded Farmer column analysis** — two competing mechanisms (composition vs. regularization)

## Reviewer 1 (GPT-5.2)

**1.1 Pre/post terminology and Depression confounding**
- Clarified that 1920→1930 is "entirely before TVA establishment in 1933" and 1930→1940 is the "treated interval" (Section 4.1)
- Depression confounding acknowledged; placebo test addresses method artifacts; additional pre-period (1910→1920) listed as future work

**1.2 Parallel trends evidence insufficient**
- Acknowledged single pre-period limitation prominently in Section 7
- The 1910→1920 extension requires additional IPUMS linking that is beyond current scope
- Pre-trends MAE of 0.0002 at token level remains strong evidence

**1.3 Control group spillovers**
- Alternative control group excluding TVA states already reported (Section 6.5, corr=0.86)
- Acknowledged attenuation from spillovers in limitations

**1.4 Migration**
- Added as sixth limitation with explicit discussion

**1.5 Transformer estimand not pinned down**
- Expanded discussion in frequency benchmark section about composition-adjusted vs. composition-including estimands
- Acknowledged that the divergence on the Farmer column reflects this distinction

**2.1 "No inference needed" stance**
- Substantially rewritten. Now acknowledges three sources of uncertainty (design-based, optimizer noise, linkage selection)
- Cell reliability classification added
- Placebo framed as quasi-RI

## Reviewer 2 (Grok-4.1-Fast)

**No uncertainty on matrix**
- Added cell reliability classification (robust/plausible/uncertain)
- Placebo maximum (1.5pp) as benchmark for minimum detectable effect
- RI described concretely; acknowledged as needed extension

**Linkage selection unquantified**
- Added new limitation paragraph discussing linkage rates, bias direction, and suggested test

**Race heterogeneity**
- Already acknowledged in limitations (fourth point); sample sizes insufficient for race-specific matrices

**Aggregation robustness**
- Population-weighted aggregation already reported (Δπ_k formula, Section 4.3)

## Reviewer 3 (Gemini-3-Flash)

**Implement RI**
- Strengthened discussion; acknowledged this is the correct framework
- Placebo provides informal evidence; formal RI implementation deferred

**Address linkage selection**
- New limitation paragraph added

**Reconcile Farmer column**
- Expanded analysis: two mechanisms (composition vs. regularization)
- Suggested "residualized frequency" as resolution for future work
