# Reply to Reviewers — apep_0445 v1

## Reviewer 1 (GPT-5.2): Major Revision

### Treatment measurement / approximated OZ designation
**Concern:** OZ designation is approximated rather than using official CDFI Fund tract list.
**Response:** We acknowledge this limitation and have softened OZ-specific claims throughout. The paper now explicitly frames the estimand as "crossing the federal low-income community poverty threshold" which triggers eligibility for multiple programs including OZs. We added a compound treatment discussion noting NMTC shares the same cutoff. The ITT estimand remains well-defined regardless of the designation approximation.

### McCrary density rejection / RDD validity
**Concern:** Rejected density continuity test and covariate discontinuities.
**Response:** We provide donut RDD specifications (±0.5, ±1.0, ±2.0 pp) that exclude tracts near the heaping mass point, with results reported in Appendix Table 7. Results are stable across all donut specifications. We acknowledge covariate imbalances are expected given poverty correlation and control for them in parametric specifications (Table 5).

### NMTC compound treatment
**Concern:** 20% threshold shared with NMTC.
**Response:** Added explicit discussion in Section 7.2 acknowledging compound treatment. Softened conclusion to frame as LIC-threshold effect with OZ as the most recent and prominent component.

### Missing RDD references
**Response:** Added Lee (2008), Imbens & Lemieux (2008), Lee & Lemieux (2010), and Calonico et al. (2014) to the bibliography and cited in the Empirical Strategy section.

### Economic interpretation of null
**Response:** Added MDE/power paragraph converting CI bounds to economic magnitudes (design rules out more than ~1 information-sector job per tract, well below the 50-100 permanent employees at a typical hyperscale facility).

## Reviewer 2 (Grok-4.1-Fast): Minor Revision

### Add canonical RDD references
**Response:** Added Lee (2008), Imbens & Lemieux (2008), Lee & Lemieux (2010). Cited in Empirical Strategy.

### Report bandwidths in Table 3 notes
**Response:** Table 2 (main RDD) notes now report MSE-optimal bandwidths for each outcome: Total emp = 7.9 pp, Info emp = 6.0 pp, Construction emp = 6.6 pp.

### Official OZ data
**Response:** Acknowledged as a future improvement. Current ITT estimand is valid without actual designation data.

## Reviewer 3 (Gemini-3-Flash): Minor Revision

### More granular NAICS data
**Response:** Acknowledged as limitation. LEHD/LODES provides 2-digit NAICS only; no finer disaggregation available at block level.

### Official OZ designation list
**Response:** See response to Reviewer 1. Softened claims and reframed estimand.

### Power analysis / MDE
**Response:** Added MDE discussion converting confidence interval bounds to job equivalents.

## Exhibit Review Feedback

### Swap Table 2 for Figure 8
**Response:** Noted for future revision. Both remain in current version for completeness.

### Consolidate appendix tables
**Response:** Noted for future revision. Tables remain separate for clarity of each robustness dimension.

### Label threshold in Figures 3-4
**Response:** Noted for future revision.

## Prose Review Feedback

### Opening sentence
**Response:** Revised to lead with the Georgia $2.5 billion audit finding — a vivid, concrete hook.

### Results narration
**Response:** Converted "Table X presents..." passages to interpretive storytelling language.

### Active voice
**Response:** Improved active voice in key passages throughout Results and Discussion.
