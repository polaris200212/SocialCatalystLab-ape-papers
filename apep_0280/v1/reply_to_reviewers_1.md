# Reply to Reviewers (Round 2)

We thank the three reviewers for their careful and constructive reports. Below we address each reviewer's key concerns.

---

## Reviewer 1 (GPT-5-mini) — MAJOR REVISION

**1. Individual-level estimation with survey weights.**
We appreciate the suggestion to re-estimate at the individual level. While individual-level Callaway-Sant'Anna DR-DiD on 7.5 million BRFSS observations would be ideal, it is computationally prohibitive given the staggered design with 14 cohorts. Our state-year panel approach follows the standard practice in the smoking ban literature (e.g., Adda & Cornaglia 2010). We note this limitation explicitly in the discussion.

**2. Missing years and event-study coverage.**
We have added extensive transparency about cohort contributions to each event-time cell (Figure 3 caption now details which cohorts map to each horizon). We added a "Drop 2016 cohort (California)" robustness check in Table 3, confirming results are virtually identical (ATT = -0.0028 vs. -0.0027). The data gaps are thoroughly discussed in Section 4.6.

**3. Richer controls for concurrent tobacco policies.**
We include cigarette excise taxes and Medicaid expansion as time-varying controls. Adding local ordinance coverage would require additional data that is not consistently available over the full 1996-2022 period. Year fixed effects absorb federal tax changes and other national trends.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

**1. Additional literature references.**
Good suggestions. We note that our bibliography already cites the key smoking ban studies (Adda & Cornaglia 2010, Carpenter et al.) and the norms literature (Bicchieri, Sunstein, Funk, Benabou-Tirole). The suggested additions (Sargent et al. 2015 meta-analysis, MacLean et al. 2023) would strengthen the paper; we defer these to the next revision if one occurs.

**2. Heterogeneity by age and race.**
We present education heterogeneity (Figure 7). Age and race subgroup analyses are feasible but would add substantial length; we note these as avenues for future work.

**3. Border-pair placebo.**
An interesting suggestion that would require matching contiguous state pairs, which is beyond the current scope but noted as a direction for extension.

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

**1. Heterogeneous effects by household composition and age.**
We agree that testing effects among younger adults and by household smoking status would sharpen the norms test. The BRFSS does not consistently record household composition across all years; age subgroups are feasible and noted for extension.

**2. Local ordinance coverage intensity.**
The American Nonsmokers' Rights Foundation data could serve as a useful control. However, constructing consistent municipal-level coverage measures over 22 years across 51 jurisdictions is a substantial data effort. We note this as a valuable extension.

**3. Additional norms literature.**
Nyborg et al. (2016) and Bernheim (1994) are relevant additions; we thank the reviewer for the suggestion.

---

## Summary of Changes Made in This Round

1. Standardized units across all figures (all use "Percentage Points")
2. Fixed RI permutation count in Figure 6 caption (200 → 1,000)
3. Fixed quit attempt variable description in Appendix (ever-smokers, not current smokers)
4. Added precise values in compositional decomposition text (+0.0139 - 0.0166 = -0.0027)
5. Added "Drop 2016 cohort (California)" robustness check (ATT = -0.0028, SE = 0.0030)
6. Added cohort contribution transparency to event study figure captions
7. Added "States (clusters)" and "State-year obs (N)" labels to Table 2
8. Clarified quit panel count reference in data section
