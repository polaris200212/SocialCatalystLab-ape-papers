# Reply to Reviewers — apep_0185 v17

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1–1.2 Exclusion restriction and identification
**Concern:** IV exclusion not convincingly defended; SCI weights may capture economic integration corridors.
**Response:** We acknowledge this concern explicitly in the revised discussion, noting that "magnitudes could partly reflect violations of the exclusion restriction (e.g., correlated origin-state policy bundles)." We prioritize the qualitative finding (information > migration) over precise magnitudes. The placebo tests (GDP, employment shocks through identical weights), distance monotonicity, and industry heterogeneity collectively narrow the channel space, though we agree they do not fully close it.

### 1.3 Event study methodology
**Concern:** "Interaction-weighted specification" insufficiently described.
**Response:** Fair point. The event study follows Sun & Abraham (2021) using interaction-weighted estimators. We clarify the pre-trend F-test as a level imbalance test (p=0.007 from employment levels, not differential trends) and add three supporting diagnostics.

### 1.4 Distance restrictions interpretation
**Concern:** Monotonic rise could reflect changing LATE, not improved validity.
**Response:** We agree this is a valid concern and note it in the discussion. The primary value is the pattern, not the point estimate at any threshold.

### 2.1 Shift-share inference
**Concern:** State clustering insufficient; need AKM/BHJ shock-level inference.
**Response:** Noted for future revision. Current inference includes multiple alternative procedures (two-way clustering, network clustering, AR, RI). We acknowledge AKM as the gold standard.

### 2.2 Permutation inference
**Concern:** RI breaks shift-share structure.
**Response:** We add a note to Table 7 clarifying that RI does not account for within-cluster correlation, explaining the divergence between RI p<0.001 and cluster-robust p=0.07 for probability-weighted specification.

### 4.2 Policy diffusion under-identified
**Concern:** State-year regression is correlational.
**Response:** Agreed. We reframe this section as descriptive with explicit caveats about omitted political variables.

### 5.1 Magnitude plausibility
**Concern:** 9% employment too large.
**Response:** We add explicit caution about LATE weighting and exclusion restriction violations in the magnitude discussion.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Must-fix 1: Pre-trend test
**Response:** We clarify the joint F-test (p=0.007) as reflecting level differences absorbed by county FE, and add three supporting diagnostics (distance-improving balance, baseline×trend stability, Rambachan-Roth sensitivity).

### Must-fix 2: SCI endogeneity
**Response:** We acknowledge this in the limitations section. Multiple SCI vintages are not publicly available; we rely on validation against pre-2012 migration patterns and the finding that distance-restricted instruments (less susceptible to endogenous formation) produce stronger results.

### Must-fix 3: Migration full-period
**Response:** IRS SOI data was discontinued after 2019. We note this limitation and show the pre-COVID employment coefficient is larger (1.10 vs 0.83), indicating attenuation from pandemic, not from migration.

### High-value: Magnitude calibration
**Response:** We add explicit magnitude caution and note the qualitative finding is more robust than point estimates.

### High-value: Diffusion causality
**Response:** Reframed as descriptive.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Must-fix 1: LATE characterization
**Response:** The complier characterization table (Appendix) shows complier counties have slightly lower average earnings and employment. Industry heterogeneity (Section 10.2) provides the most informative demographic cut: effects concentrate in high-bite sectors.

### Must-fix 2: Pre-trend clarity
**Response:** Addressed as above with clarified F-test interpretation and three supporting diagnostics.

### High-value: Political economy extension
**Response:** Interesting suggestion for future work. Current version frames diffusion as descriptive.
