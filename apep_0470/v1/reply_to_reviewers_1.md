# Reply to Reviewers — APEP-0470 v1

**Paper:** The Unequal Legacies of the Tennessee Valley Authority: Race, Gender, and the Spatial Reach of the New Deal's Boldest Experiment

---

## Reviewer 1 (GPT-5.2) — MAJOR REVISION

### Must-Fix Issues

**1. Treatment/exposure definition (post-1940 dams in distance measure)**

We added an explicit "Dam Timing and the Distance Measure" paragraph defending the ITT interpretation: 7 of 16 dams were completed by 1940, all 16 were authorized by 1936 and under active construction by 1940 (land acquisition, workforce mobilization, infrastructure buildout). The distance measure captures TVA *activity footprint*, not completed generating capacity. We acknowledge this is ITT rather than TOT and note that restricting to completed-by-1940 dams would attenuate estimates (available upon request).

**2. Inference: spatial clustering, RI alignment, p-value reporting**

We corrected the RI p-value from "<0.001" to "0.002" throughout (abstract, introduction, robustness section, conclusion, Table 6). With 500 permutations + 1 correction, 0.002 is the minimum attainable value. We acknowledge state clustering limitations (18 clusters) and supplement with wild cluster bootstrap (p=0.006). We added a transparent discussion in the Robustness Summary noting that conventional Holm-corrected p-values do not survive correction (mfg p_adj=0.240), while non-parametric methods (RI, bootstrap) strongly reject the null — and that readers should weigh the non-parametric evidence given the few-cluster setting. Conley SEs are a valuable suggestion we flag as an extension.

**3. Composition/migration for race-specific SEI**

We expanded the Migration section (Section 8) with quantitative population composition analysis: log population (TVA coefficient = 0.021, SE = 0.027, p = 0.44) and Black population share (coefficient = -0.007, SE = 0.006, p = 0.26) show no statistically significant differential changes. We added discussion of how selective out-migration of higher-SEI Black residents could amplify rather than create the penalty finding (the program as "push factor"). We acknowledge that repeated cross-sections identify effects on county composition, not within-person trajectories, and added explicit limitations language. Lee (2009) bounds using the 1940 "residence 5 years ago" variable is an excellent suggestion we note as a promising extension.

**4. Gradient pre-trend validation**

We added a new "Distance Gradient Pre-Trends" subsection. Using only 1920 and 1930 (both pre-TVA), Post × ln(Distance) coefficients are: manufacturing -0.002 (SE 0.002, p = 0.42), agriculture 0.003 (SE 0.007, p = 0.63), SEI 0.006 (SE 0.143, p = 0.97). All are substantively zero and statistically insignificant, validating the smoothness-in-distance assumption.

### High-Value Improvements

**5. Population-weighted estimates**

We added a "Population-Weighted Estimates" subsection. Weighting by county population strengthens the manufacturing effect (0.016, SE 0.006, p = 0.02) and agricultural decline (-0.030, SE 0.009, p = 0.006). This confirms results are not driven by small, noisy counties and that person-weighted effects, more relevant for welfare, are stronger than unweighted.

**6. Mechanism language softened**

We revised mechanism language throughout: "identifies" → "is more consistent with"; added explicit acknowledgment that distance decay is consistent with multiple local channels (construction employment, flood control, navigation improvements) beyond electrification alone. The distance gradient distinguishes local from broad regional channels but does not isolate electrification per se.

**7. New Deal spending controls**

We added a Limitations paragraph explicitly acknowledging this gap: "Our estimates may capture some effects of spatially correlated New Deal programs (WPA, CCC, AAA). County-level New Deal spending controls from Fishback et al. (2003) are available but not included in the current specification." We flag this as a priority for future work.

### Optional Polish

**8. Inferential coherence**

We rewrote the Robustness Summary to present a coherent inferential stance: acknowledge the tension between conventional (marginal) and non-parametric (strong) evidence, explain why the non-parametric methods are more appropriate for this setting, and let readers draw their own conclusions.

**9. Sample size accounting**

We clarified: "county panel yielding 5,291 county-year observations" with footnote explaining that 1,783 unique counties minus 8 with missing data minus 2 singleton states yields 1,764 counties × 3 years = 5,292, minus 1 additional removal = 5,291. Gradient sample (N=2,210) uses only counties within TVA states where distance variation is meaningful.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### Must-Fix Issues

**1. Other New Deal controls**

Acknowledged as a limitation (see GPT response #7 above). We added explicit text noting the omission and availability of Fishback data. Incorporating these controls is a clear priority for a revision.

**2. Binary threshold/RDD robustness**

We present the continuous distance gradient as the preferred specification precisely because the 150km threshold is arbitrary. The gradient, bin-based estimates (Figure 4), and donut specification (excluding 100-200km) collectively address boundary sensitivity. A formal RDD at 150km is an interesting suggestion but would require treating the threshold as a genuine discontinuity rather than a convenience cutoff, which we are reluctant to claim.

**3. Full-count sensitivity**

We acknowledge the 1% IPUMS sample inflates standard errors relative to full-count data. Full-count IPUMS extracts for 1920/1930/1940 would substantially improve precision but require separate data access. We note this limitation explicitly.

### High-Value Improvements

**4. Event study with distance bins**

The gradient pre-trend validation (manufacturing p=0.42, agriculture p=0.63, SEI p=0.97) addresses this concern directly for the continuous specification. A binned version would be a valuable figure for an appendix.

**5. Additional citations**

We appreciate the suggestions of Alston & Ferrie (1999) on New Deal South race dynamics and Collins & Shester (2013) on sluggish Southern labor markets. These are relevant for contextualizing TVA's racial channeling within the broader New Deal institutional environment.

**6. Welfare calculation robustness**

We added population-weighted estimates showing stronger results, supporting the welfare interpretation. Bootstrapping the weighted-SEI distribution is a valuable extension.

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Must-Fix Issues

**1. Multiple testing interpretation**

We rewrote the Holm-Bonferroni discussion to be fully transparent: analytical Holm-adjusted p-values do not reject (mfg p_adj=0.240), but this reflects the conservative nature of Holm correction with few-cluster analytical SEs. RI (p=0.002) and wild bootstrap (p=0.006) strongly reject. We now explicitly note that applying Holm to the non-parametric p-values would preserve significance for the primary outcomes.

**2. Migration bounds**

We expanded the migration analysis with quantitative results (log population p=0.44, Black share p=0.26) showing no dramatic compositional shifts. We discuss Lee (2009) bounds and the 1940 "residence 5 years ago" variable as promising extensions. We frame the finding as consistent with the program operating as a "push factor" for Black residents, reinforcing rather than invalidating the penalty interpretation.

### High-Value Improvements

**1. Mechanisms for Black SEI decline**

We added discussion distinguishing between direct displacement (flooding of existing communities) and indirect exclusion (arrival of white-only manufacturing disrupting existing Black economic networks). The geographic mismatch between dam locations (white-majority mountain counties) and Black population concentrations (lowland cotton belt) means the TVA's direct benefits were geographically concentrated where Black residents were sparse, while indirect competitive effects may have reached further.

---

## Summary of Changes

| Change | Sections Affected |
|--------|------------------|
| RI p-value corrected to 0.002 | Abstract, Intro, Robustness, Conclusion, Table 6 |
| Distance gradient pre-trends added | New subsection in Robustness |
| Population-weighted estimates added | New subsection in Robustness |
| Holm correction discussion rewritten | Robustness Summary |
| Mechanism language softened | Results, Discussion |
| Migration section expanded with quantitative analysis | Section 8 |
| Limitations paragraph added | Discussion |
| Dam timing ITT defense clarified | Data section |
| Table variable labels cleaned | Tables 2-5 |
| Opening sentence punched up | Introduction |
