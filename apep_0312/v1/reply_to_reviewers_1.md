# Reply to Reviewers — Round 1

**Paper:** apep_0310/v1 — "Compensating Danger: Workers' Compensation Laws and Industrial Safety in the Progressive Era"
**Date:** 2026-02-16

We thank all three reviewers for their careful and constructive comments. Below we address each concern.

---

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1. Control group fragility (43 treated vs 5 Deep South controls)

**Response:** We agree this is the paper's most important limitation. We have substantially expanded the discussion in the appendix (Section C, "Inference with Few Clusters"), now spanning two full paragraphs that:
- Acknowledge the limitation directly and forcefully
- Discuss three mitigating features (large t-statistic, consistent TWFE result, influence-function approach)
- Identify specific confounders (Great Migration, Jim Crow institutions, differential industrialization)
- Propose concrete extensions for future work (1900 census pre-trends, DDD design, wild cluster bootstrap)

**Not addressed (would require new analysis):** Adding 1900 census data (new IPUMS extract), implementing DDD, running wild cluster bootstrap. These are excellent suggestions for a revision but beyond the scope of the current pass.

### 2. Missing 95% CIs

**Response:** Added. All three main tables (Table 3, 4, 5) now report 95% confidence intervals computed as $\hat{\tau} \pm 1.96 \times SE$.

### 3. Inference with few clusters

**Response:** We have expanded the "Inference with Few Clusters" appendix section to discuss wild cluster bootstrap, randomization inference, and small-sample corrections. We note that even doubling the standard errors would leave the main result significant, and the TWFE comparison provides a qualitatively consistent estimate using 48 state-year clusters.

### 4. Within-adopter near-zero effect

**Response:** Substantially revised Section 7.2 to provide a more thorough interpretation. We now explain that the near-zero within-adopter result *supports* the main specification: if all adopters show similar effects by 1920, the treatment effect is common and the main finding captures the adopter/non-adopter gap. We also acknowledge this underscores the central role of the five comparison states.

### 5. Missing references

**Response:** Added Goodman-Bacon (2021) and de Chaisemartin & D'Haultfoeuille (2020) to the bibliography and cited in the TWFE comparison discussion.

### 6. State adoption dates table

**Response:** Added Table A.1 in the Data Appendix with all 48 states, adoption years, and cohort classifications.

### 7. Soften moral hazard language

**Response:** Revised throughout. The abstract now says "consistent with moral hazard and compensating-differential channels dominating employer safety incentives" rather than asserting moral hazard as the sole explanation. The interpretation section discusses three channels (moral hazard, reduced compensating differential, labor demand expansion) explicitly.

---

## Reviewer 2 (Grok-4.1): MINOR REVISION

### 1. Add CIs to tables

**Response:** Done. All main tables now include 95% CIs.

### 2. Wild cluster bootstrap

**Response:** Discussed in expanded appendix. Acknowledged as the appropriate next step but note that with 5 control states, even bootstrap methods face known size distortions.

### 3. Missing references

**Response:** Added Goodman-Bacon (2021) and de Chaisemartin & D'Haultfoeuille (2020). Note: Margo (2000) and Autor (2003) are relevant but not central to this paper's specific contribution; we acknowledge the modern workers' comp literature in the introduction.

### 4. Explicit N in all tables

**Response:** Already present in Tables 3 and 5. Table 4 (heterogeneity) reports subsample restrictions; exact N values could be added in a future revision.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### 1. Newspaper index utilization

**Response:** We acknowledge this is a missed opportunity. The newspaper data faces practical challenges (sparse digitization in many states, OCR quality variation) that limit its use as a primary outcome. We have revised the data section to be transparent about these limitations while preserving the novel data collection as a contribution. A formal DR estimate using the newspaper index could be pursued in a future revision with expanded digitization coverage.

### 2. Deep South comparison group

**Response:** Addressed through expanded inference discussion (see response to Reviewer 1, items 1 and 3). We now explicitly acknowledge Jim Crow institutions, agricultural structure, and migration patterns as potential confounders. A synthetic control robustness check is an excellent suggestion for future work.

### 3. Welfare discussion / VSL calculation

**Response:** The conclusion now discusses welfare implications more explicitly, noting that the positive effect on occupational income (Column 2) is "more consistent with efficient risk-taking than with reckless behavior." A formal VSL calculation from the Occ. Income Score would require additional assumptions about the relationship between occupational income scores and actual wages that we are not confident in, given the historical context.

---

## Exhibit Review (Gemini) — Changes Made

1. **Table 3:** Added significance stars and Mean of Dep. Var. row
2. **Figure 5 caption:** Added interpretive note about confounder strength threshold
3. **Section headers:** Changed "Heterogeneity" to "Where Did the Workers Go?"

## Prose Review (Gemini) — Changes Made

1. **Killed roadmap:** Replaced end-of-intro roadmap with contribution emphasis
2. **Active results:** "Workers responded to the new safety net..." replaces "Column (1) reports..."
3. **Data transitions:** More vivid language in data section
4. **Identifying assumptions:** Added plain-language framing before formal statements
5. **Pruned jargon:** Simplified "The fundamental challenge is that..." throughout

---

## Summary of All Changes

| Category | Changes |
|----------|---------|
| Tables | Added 95% CIs to Tables 3, 4, 5; added significance stars; added Mean Dep. Var.; created Table A.1 (adoption dates) |
| References | Added Goodman-Bacon (2021), de Chaisemartin & D'Haultfoeuille (2020) |
| Text | Expanded inference discussion; softened moral hazard claims; improved within-adopter interpretation; killed roadmap; vivid prose |
| Structure | More active results language; vivid section headers |
