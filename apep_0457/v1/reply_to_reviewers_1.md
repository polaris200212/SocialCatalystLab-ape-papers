# Reply to Reviewers — APEP-0457, Round 1

## Response to GPT-5.2

**1. Pre-policy treatment measure (must-fix)**
We acknowledge this is the paper's fundamental design limitation. The ARE Zweitwohnungsinventar was not produced in comparable geospatial form before 2017. We have added extensive discussion of why the 2017 measure is likely stable (housing stock persistence, no demolition/conversion mechanism, stable ARE classification across vintages) while explicitly labeling this a design limitation. We agree that an ideal study would use pre-2012 shares, which are unavailable.

**2. Design addressing pre-trends (must-fix)**
Done. We added municipality-specific linear trends, which absorb the TWFE effect entirely (estimate drops from -2.9% to -1.0%, p=0.18). This is now reported as the most consequential diagnostic in the paper. We also implemented a difference-in-discontinuities design (RDD on employment changes rather than levels), which yields a null (+0.033, p=0.23). The paper is now reframed as a primarily descriptive contribution with honest identification diagnostics.

**3. RDD credibility (must-fix)**
Done. We added the difference-in-discontinuities design, which resolves the magnitude discrepancy between the level-RDD (-0.71) and DiD (-0.03). The level differences reflect baseline employment differences between high- and low-second-home municipalities, not causal effects.

**4. Timing (must-fix)**
We now discuss the 2012 shock vs 2016 consolidation more carefully and show that alternative timing (Post=2013, Post=2015) yields similar results, consistent with either anticipation or a pre-existing trend unrelated to any specific policy date.

**5. Spatial spillovers (high-value)**
Done. Controls in treated cantons show no differential employment trend (+0.8%, p=0.21), providing no evidence of spillover contamination.

**6. Canton × year FE diagnostics (high-value)**
Done. We show the canton × year FE event study, which reveals that pre-trends persist even after absorbing cantonal shocks. This weakens the canton FE result as evidence for causality.

---

## Response to Grok-4.1-Fast

**1. Pre-2012 shares (must-fix)**
Not feasible — data does not exist in comparable format. Acknowledged as limitation.

**2. Spillovers (must-fix)**
Done — canton-level spillover test shows no evidence (p=0.21).

**3. Bacon/Sun-Abraham decomposition (must-fix)**
The Bacon decomposition text has been corrected to acknowledge the TWFE-CS divergence. Since all treated units share a single cohort (2016), the Sun-Abraham estimator is equivalent to the TWFE in this setting.

**4. RDD power analysis (high-value)**
We note the limited sample near the cutoff (~300 municipalities) and the wide confidence intervals. The difference-in-discontinuities design with a wider bandwidth (8pp) provides more power and yields a null.

**5. Tourism-specific channels (high-value)**
Municipality-level NOGA data is only available at the canton level. We have tempered mechanism language to refer to "secondary sector" rather than "construction" specifically.

---

## Response to Gemini-3-Flash

**1. Placebo cutoffs / reframing (must-fix)**
Done. The paper now explicitly states that the evidence does not support a causal interpretation specific to the 20% threshold. The contribution is reframed as descriptive documentation and a methodological case study.

**2. Synthetic control (must-fix suggestion)**
Not implemented in this round due to computational constraints and the need to restructure the paper's design around SCM. However, the municipality-specific linear trends serve a similar purpose (absorbing unit-specific trends) and yield the same conclusion: the TWFE effect is not robust.

**3. Pre-2012 housing data (high-value)**
Not feasible — see response to GPT-5.2 above.

**4. Sectoral granularity (high-value)**
Municipality-level NOGA is not available in STATENT at the necessary granularity. We now note this limitation explicitly.
