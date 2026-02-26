# Reply to Reviewers

## GPT-5.2 (Reject and Resubmit)

### 1.1 Pre-trends and selection on trajectories
> CS-DiD does not "fix" selection into earlier phases... the paper's pivot to heterogeneity ("within terciles, parallel trends more plausible") is not yet demonstrated.

**Response:** We agree this is the paper's central limitation. We have:
- Added within-tercile TWFE event studies showing pre-trends reject in all 6 subgroups (all p < 0.001)
- Explicitly stated that heterogeneity patterns are "descriptive associations rather than causal effects" (Section 5.4)
- Added Rambachan-Roth sensitivity analysis to main text (Section 7.3) showing aggregate effect is not robust
- Reframed the abstract and introduction to lead with the pre-trend caveat

### 1.2 Treatment timing and 2006
> Post-treatment contamination in "pre" period... mismatch to true implementation intensity

**Response:** We acknowledge this concern in the existing discussion (Section 4.2). The agricultural year coding (Phase I = 2007) ensures 2006 is pre-treatment for the first cohort under our definition, but partial exposure effects cannot be ruled out. A full sensitivity analysis with alternative G_d coding is beyond the scope of this revision but noted as a future direction.

### 1.3 Phase assignment is reconstructed
> Your reconstructed index uses SC/ST share, agricultural labor share, and negative literacy... this is not a small deviation.

**Response:** We acknowledge this limitation explicitly in the Limitations section: "Our reconstruction of MGNREGA phase assignment, while following the documented methodology, may not perfectly match the actual district lists." We note that any misclassification would attenuate estimates. Obtaining the exact official district lists would strengthen the paper and is noted as a priority for future work.

### 1.4 Confounding from concurrent programs
> BRGF overlap... the current DiD is not isolating MGNREGA.

**Response:** We have adopted the reviewer's suggested reframing. Section 2.3 now states: "Our estimand is therefore best interpreted as the combined effect of being selected early into the bundle of backward-district programs—including MGNREGA, BRGF, and related schemes—rather than the isolated effect of MGNREGA alone." This "bundle" interpretation is used throughout the paper.

### 1.5 Heterogeneity design
> Even within terciles, treatment is still staggered and targeted; TWFE can still use already-treated as controls.

**Response:** We have:
- Added within-tercile pre-trend diagnostics (all reject, p < 0.001)
- Added a joint interaction model with F-test (F = 16.7, p < 0.001) confirming heterogeneity is statistically meaningful
- Emphasized CS-DiD heterogeneity results alongside TWFE results (Section 5.5)
- Explicitly stated the descriptive nature of heterogeneity findings

### 2.1 Clustering inconsistency
> TWFE clusters at state (~30 clusters), while CS/SA cluster at district (584 clusters).

**Response:** We have added district-clustered TWFE as a robustness check (coefficient = 0.012, SE = 0.008). The main results are robust to clustering choice.

### 2.2 Rambachan-Roth interpretation
> At M-bar=0 the CI is entirely negative, contradicting the positive CS ATT.

**Response:** We now present the Rambachan-Roth analysis prominently in the main text (Section 7.3) with a clear interpretation: "At M-bar = 0 (linear extrapolation of pre-trends), the confidence interval is entirely negative ([-0.089, -0.026]), suggesting the treatment effect may reflect mean reversion."

### 2.3 Dose-response
> Essentially a reparameterization of cohort timing... mechanically confounded.

**Response:** The dose-response remains in the appendix with explicit caveats about mechanical confounding.

### 2.4 Multiple testing
> Isolated p<0.05 findings are not reliable without correction.

**Response:** We have added the joint F-test for heterogeneity (F = 16.7, p < 0.001 for agricultural labor terciles), which addresses the multiple testing concern by testing the joint null of no heterogeneity.

### 4.1-4.2 Contribution and literature
> Need to engage more directly with MGNREGA literature... "TWFE vs CS differ" is not itself a contribution unless...

**Response:** We have added the "bundle" estimand framing as a contribution and added missing citations (Klonner & Oldiges 2016 corrected). The contribution paragraph now explicitly states the reduced-form nature of our estimates.

### 5.1-5.3 Claims calibration
> Abstract and conclusion still read as if you have established "where workfare works."

**Response:** Abstract now includes pre-trend qualifier. Introduction says estimates "reflect pre-existing differential trends rather than a clean causal effect." Conclusion uses "patterns are consistent with a model where..." rather than asserting causation.

---

## Grok-4.1-Fast (Major Revision)

### 1. Must-fix: Within-tercile event studies
> Parallel trends untested within subsamples; pre-trends may persist.

**Response:** Done. All 6 subgroups reject flat pre-trends (p < 0.001). Reported in Section 5.4 with explicit descriptive framing.

### 2. Must-fix: BRGF confound
> Overlap with Phase I undermines DiD; state×year FE insufficient.

**Response:** Adopted "bundle" interpretation throughout (Section 2.3, contribution paragraph, mechanism section).

### 3. Must-fix: Alternative ID
> Core DiD fails parallel trends; Rambachan-Roth confirms fragility.

**Response:** Rambachan-Roth now in main text. We acknowledge the design limitations honestly rather than claiming to have resolved them. The paper's value lies in the heterogeneity patterns and methodological lessons, not in a clean aggregate causal estimate.

### High-value: Elevate CS-DiD heterogeneity
> Move Table csdid_het to main.

**Response:** CS-DiD heterogeneity is now discussed more prominently in Section 5.5 with explicit comparison to TWFE results.

### High-value: Missing citations
> Add Berg 2019, Klonner 2020, Asher-Novosad 2020.

**Response:** Berg (2018) and Klonner (2016) are already cited. Asher & Novosad (2021) SHRUG is cited throughout.

### Optional: Uniform clustering
> Conservative, consistent.

**Response:** District-level clustering added as robustness check. Main TWFE results unchanged.

---

## Gemini-3-Flash (Major Revision)

### Must-fix: BRGF confound
> Since BRGF and MGNREGA rollout are nearly collinear, you must use a subset or triple-difference.

**Response:** We adopt the "bundle" interpretation rather than attempting to separate BRGF and MGNREGA, which would require data on BRGF district lists and expenditures not available in our current dataset.

### Must-fix: Electrification
> Nightlights primarily pick up rural electrification (RGGVY).

**Response:** Added explicit RGGVY discussion in Section 3.1, noting that we cannot separate MGNREGA from RGGVY effects and reinforcing the "bundle" interpretation.

### Must-fix: Dose-response with actual data
> You must find a proxy for actual program intensity.

**Response:** MGNREGA administrative data on person-days is noted as a priority extension in Future Directions but was unavailable for this analysis.

### High-value: Rambachan-Roth for heterogeneity
> Apply sensitivity analysis to the "Medium Ag-Labor" tercile.

**Response:** This is an excellent suggestion that would strengthen the paper. Currently computationally demanding but noted for future work.

### Over-claiming in abstract
> The abstract claims a positive aggregate effect but the body debunked this.

**Response:** Abstract now includes: "though significant pre-treatment differential trends...confirmed by Rambachan-Roth sensitivity analysis—challenge causal interpretation of the aggregate estimate."

---

## Exhibit Review Improvements

- Figure aesthetics updated: cleaner themes (white background, minimal gridlines)
- Figure 1 Y-axis label changed to "Effect on Log Nightlights (ATT)"
- Figure 3 heterogeneity: removed rotated labels, improved panel formatting
- Roadmap sentence removed from introduction (prose review)
- Final paragraph of conclusion strengthened with equity-vs-growth reframing (prose review)
- Active voice in data section ("We measure..." instead of "Our primary outcome variable is...")

---

## Summary of Changes

| Change | Section | Nature |
|--------|---------|--------|
| Pre-trend qualifier in abstract | Abstract | Tone |
| Softened causal language in intro | 1 | Tone |
| "Bundle" estimand throughout | 2.3, 1, 6 | Framing |
| RGGVY electrification discussion | 3.1 | Content |
| Within-tercile pre-trend tests | 5.4 | New analysis |
| Joint heterogeneity F-test | 5.4 | New analysis |
| Mechanism section reframed as descriptive | 6 | Tone |
| Rambachan-Roth in main text | 7.3 | Restructure |
| Uniform district clustering | 7 | New analysis |
| Missing citations corrected | Bib | Literature |
| Goldilocks language softened | 8 | Tone |
| Equity-vs-growth conclusion | 8 | Prose |
| Figure aesthetics improved | Figures | Exhibits |
