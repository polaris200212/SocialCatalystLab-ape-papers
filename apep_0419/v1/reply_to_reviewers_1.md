# Reply to Reviewers

## Paper: "No Snow Day Left Behind: How Virtual Instruction Policies Reduce the Weather-Absence Penalty for Working Parents"

---

## Overview of Changes

Three external referee reviews were received (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash). The reviews converged on several key concerns. Below I summarize the changes made to address them.

---

## 1. Proxy Outcome Acknowledgment (All 3 Reviewers)

**Concern:** All three reviewers identified the constructed proxy outcome (national BLS absence rates scaled by state storm events) as the paper's primary limitation. GPT-5.2 was most critical, arguing the outcome "is not an observed state-level labor-market variable" and that this "undermines identification." Grok called it "ingenious but indirect." Gemini noted the "mechanical link" between weather and the outcome.

**Changes made:**
- **Abstract**: Now explicitly identifies the outcome as "a proxy for weather-related work absences---constructed from national BLS absence rates and state-level NOAA storm events" and flags CPS microdata as the preferred future path.
- **Introduction**: Added a full paragraph (after the empirical strategy introduction) explaining the measurement challenge, the proxy's construction, and its limitations for causal interpretation---before readers encounter the results.
- **Section 4.6 (Variable Construction)**: Substantially expanded the proxy limitations discussion. Now explicitly addresses the mechanical linkage between storms and the outcome, explains why event-study pre-trends may be less informative for a constructed proxy, and provides a detailed roadmap for CPS microdata analysis (direct state-level measurement, triple-difference designs, occupation heterogeneity using Dingel-Neiman classification).
- **Conclusion**: Now describes this as "the first empirical evidence... using a proxy-based design that motivates direct measurement in future work" rather than claiming definitive causal evidence.

**Not changed:** The outcome variable itself was not replaced (this would require new data and R code). The revisions ensure readers understand the proxy's limitations throughout.

---

## 2. "First Causal Evidence" Claim (GPT-5.2)

**Concern:** GPT-5.2 flagged the claim of "first causal evidence" as "potentially overstated" given the proxy-based design.

**Changes made:** Replaced "first causal evidence" with "first empirical evidence" in both the Introduction and Conclusion. The paper no longer claims causal identification where the proxy design limits it.

---

## 3. Summer Placebo Significance (GPT-5.2, Grok-4.1-Fast)

**Concern:** GPT-5.2 called the significant summer placebo "a red flag" that "signals residual confounding/selection or outcome construction artifacts." Grok flagged it as an "anomaly" needing more discussion.

**Changes made:** Substantially expanded the placebo discussion in Section 6.5. Now explicitly considers three explanations: (1) differential labor market trajectories in adopting states, (2) measurement artifacts from the proxy construction, and (3) trivially small effects amplified by large sample size. Also explicitly notes that the summer placebo undermines clean identification and motivates future work with direct state-level measures.

---

## 4. Missing Literature References (All 3 Reviewers)

**Concern:** GPT-5.2 requested Cameron-Miller (2015), Borusyak-Jaravel-Spiess, Roth (2022), and broader childcare literature. Grok suggested three specific references. Gemini requested deeper engagement with childcare elasticity literature.

**Changes made:**
- Added Cameron & Miller (2015) to references.bib and cited in the inference section alongside existing Cameron-Gelbach-Miller (2008).
- Added citation to Borusyak, Jaravel & Spiess (2024) in the alternative estimators appendix discussion (already in .bib).
- Added citation to Roth (2022) in the pre-trends appendix discussion with an explicit caveat about pre-trend testing limitations.
- Added citation to Roth et al. (2023) in the introduction's methodology paragraph.
- Added discussion of Blau & Robins (1988) and Gelbach (2002) in the context of childcare labor supply elasticities vs. transient snow-day disruptions (Section 7.4, Comparison to Related Literature).
- Added Dingel & Neiman (2020) citation in the conceptual framework heterogeneity predictions.

**Not added:** Grok's three suggested references (Lovenheim-Kimball 2024, Figlio-Rush 2022, Hsiung et al. 2023) were not added as these could not be verified in this revision round.

---

## 5. Conceptual Framework Format (GPT-5.2)

**Concern:** Prediction 3's bullet-point format was flagged as inconsistent with top-journal style.

**Changes made:** Converted the Prediction 3 itemize list into flowing prose, maintaining all four heterogeneity predictions while improving readability.

---

## 6. Confidence Intervals for TWFE (GPT-5.2)

**Concern:** GPT-5.2 noted that the TWFE table lacks confidence intervals for headline estimates.

**Changes made:** Added in-text 95% CIs for the baseline TWFE coefficient and the preferred storm-deviation interaction coefficient in the main results discussion (Section 6.2).

---

## 7. Multiple Testing (GPT-5.2)

**Concern:** GPT-5.2 flagged the need for "multiple-testing discipline" given the many specifications and heterogeneity cuts.

**Changes made:** Added an explicit multiple-comparisons caveat in the main results section, noting that the marginally significant storm-deviation interaction ($p = 0.063$) should be interpreted in the context of specification search and that sharpened $q$-values would likely push it above conventional thresholds.

---

## 8. Treatment Intensity Variation (Gemini-3-Flash)

**Concern:** Gemini suggested testing whether states with unlimited virtual days show larger effects than those capped at 3-5 days.

**Changes made:** Added a new paragraph in the Limitations section (Section 7.5) acknowledging treatment intensity variation as an unexploited dimension and discussing how policy design features (max days, instructional format, whether days count toward minimums) could yield sharper tests. This is framed as a limitation of the current binary treatment coding.

---

## 9. Remote Work Confounding (GPT-5.2, Grok-4.1-Fast)

**Concern:** Multiple reviewers noted that remote work diffusion post-2020 may independently reduce the weather-absence penalty, confounding the policy estimate.

**Changes made:** Expanded the remote work discussion in Limitations (Section 7.5) with a specific reference to Dingel & Neiman (2020) and a concrete suggestion for interacting treatment with state-level remote work feasibility shares.

---

## Summary

The revisions primarily strengthen the paper's transparency about its proxy-based design, add methodological caveats requested by multiple reviewers, expand the literature engagement, and improve exposition. No coefficient values or empirical results were changed. The fundamental limitation (proxy outcome rather than direct state-level absence measurement) is now prominently acknowledged throughout, with a clear roadmap for the CPS microdata approach that all three reviewers recommended.
