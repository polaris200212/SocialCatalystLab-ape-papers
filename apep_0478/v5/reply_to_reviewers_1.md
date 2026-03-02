# Reply to Reviewers — Stage C Revision

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1. Reframe claims as descriptive, not causal
**Response:** Accepted. We have revised the abstract, introduction, and conclusion to clearly distinguish descriptive measurement from causal claims. Key changes:
- Abstract: "preceded occupational decline by a generation" → "visible in the data before the occupation's quantitative collapse"
- Abstract: "created institutional barriers" → "were strongest"
- Abstract: "suggests that automation is mediated by" → "is consistent with automation being mediated by"
- Introduction: Added caveat "though our analysis cannot isolate the causal contribution of any single factor"
- Conclusion: Removed "by at least a generation" and added "sparse temporal sampling" qualifier

### 2. Resolve specification inconsistencies
**Response:** Fixed. The text equation previously described "age, age²" as controls but the actual estimation (and table notes) use age-group fixed effects. Text now correctly states "fixed effects for state, race, sex, and age group (five-year bins)."

### 3. Clustering robustness
**Response:** Acknowledged in new limitations paragraph. We added: "our regression standard errors are clustered at the state level (49 clusters), which is appropriate for national-level inference but may not fully account for within-state correlation... future work could explore metro-level clustering or wild cluster bootstrap." Re-estimating with alternative clustering is noted as future work.

### 4. Discourse timing claims
**Response:** Softened throughout. The "preceded by a generation" phrasing has been removed from all locations. We now describe the pattern as "visible in the data before" the collapse, with explicit caveats about sparse temporal sampling and D.C. dominance.

### 5-9. Additional suggestions (metro FE, IPW expansion, alternative decades, OCCSCORE alternatives, entrant definitions)
**Response:** These are valuable suggestions for future work but exceed the scope of the current text-level revision. We have added several to the limitations section.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Expand linkage selection details
**Response:** IPW methodology is documented in the appendix. The full logit specification is referenced in the table notes. A complete linkage model table is available in the replication materials.

### 2. Cluster SEs finer
**Response:** See response to GPT §3 above. Acknowledged in limitations.

### 3. Full robustness tables
**Response:** "Qualitatively similar" claims are supported by the code in the replication package. Full appendix tables for all specifications would expand the paper beyond current length.

### 4. Missing citations
**Response:** Added Abramitzky et al. (2021 AER), Comin & Hobijn (2010 AER), and Gentzkow, Kelly & Taddy (2019 JEL) to the contributions paragraph.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### 1. Improve SCM fit
**Response:** The SCM is presented in the appendix as supporting evidence, not as the paper's primary identification. We have added stronger caveats to the SCM section: "Pre-treatment: 1900-1930. Dashed vertical line marks treatment onset (1940)." The SCM section already acknowledges the limited donor pool.

### 2. Selection bias in linked panel
**Response:** IPW analysis (Table 9) addresses this directly. The substantial change in OCCSCORE coefficient under IPW is discussed transparently.

### 3. WWII supply shocks
**Response:** Added to limitations: "wartime capital constraints—shortages of steel, electronics, and construction materials during World War II—may have independently delayed elevator automation during the 1940s plateau."

### 4. Discourse analysis granularity
**Response:** Acknowledged limitation. Adding intermediate years (1947-1949) would require additional data processing from the American Stories corpus and is noted for future work.
