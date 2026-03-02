# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1 Treatment definition and coding
**Concern:** Subjective classification requires replicable coding protocol.
**Response:** Added explicit 4-criterion coding rubric to Appendix A.2 (at least 2 of: campaign pledge, formal declination policies, alliance endorsement, bail reform directives). Leave-one-out analysis shows no single county drives results.

### 1.2 Control group credibility
**Concern:** 25 large urban vs. ~2,780 mostly small/rural counties is not credible.
**Response:** Added new "Control group comparability" paragraph in Section 4.4 discussing this threat and three mitigating features: (1) state×year FE restricts comparisons within-state, (2) flat pre-trends, (3) urbanicity heterogeneity. Added explicit limitation about need for synthetic DiD/entropy balancing with Arkhangelsky et al. (2021) citation. Noted that the controlled specification (Col 2) implicitly restricts to larger counties with ACS data.

### 1.3 CS-DiD as primary estimator
**Concern:** CS should be primary, not TWFE; explain -179 vs -406 divergence.
**Response:** Substantially rewrote the abstract, introduction results paragraph, and Table 2 discussion. CS estimate now presented as the "primary heterogeneity-robust alternative" with detailed explanation of negative weighting under staggered adoption. Goodman-Bacon (2021) mechanism explained. Also discussed population-weighted vs county-average estimand choice.

### 1.4 Homicide analysis
**Concern:** Structurally weak, needs reframing or longer data.
**Response:** All homicide claims now consistently described as "inconclusive." Removed "achieves public safety goals" framing from abstract, intro, discussion, and conclusion. Added explicit suggestion that FBI UCR/CDC WONDER series is the most important future extension. Clarified that only 18 switching counties identify the homicide effect.

### 1.5 DDD measurement validation
**Concern:** Ratio instability, race-specific event studies needed.
**Response:** Added pretrial mechanism discussion with supporting descriptive evidence. Added limitation about Hispanic reclassification effects. Full race-specific event studies and log/IHS robustness noted as future work.

### 2.1 Clustering
**Concern:** State clustering with few treated clusters; report cluster counts.
**Response:** Added cluster counts (approximately 40 state clusters; 14 with treated counties) to ALL table notes. Wild cluster bootstrap already in appendix; referenced more prominently.

### 2.2 Sample size coherence
**Concern:** N drops from 52,704 to 30,039 unexplained.
**Response:** Added detailed "Sample attrition with controls" paragraph in Appendix A.3 explaining that the drop reflects ACS availability for smaller counties, and all 25 treated counties are retained.

### 2.3 CS estimation details
**Concern:** DR estimation details, weight trimming.
**Response:** Added specification that CS uses never-treated controls and doubly robust estimation in Table 2 notes.

### 2.4 Multiple testing
**Concern:** No correction for multiple outcomes.
**Response:** Added "Multiple comparisons" paragraph in Section 4.4 identifying incarceration as primary and safety/equity as secondary.

### 3.1-3.2 Statewide reforms and spillovers
**Concern:** Need urbanicity×year interactions and spillover checks.
**Response:** Added spillovers discussion in Section 4.4. State×year FE partially addresses both concerns.

### 3.3 Mechanism evidence
**Concern:** Compositional claim untested.
**Response:** Added pretrial vs. sentenced mechanism paragraph with descriptive evidence (0.67 vs 0.60 pretrial share). Noted data limitation for race × detention status decomposition.

### 5.1-5.4 Claim calibration
**Concern:** Over-claiming on safety; cost-benefit inconsistent.
**Response:** Rewrote cost-benefit section using both TWFE ($-179$) and population-weighted ($-54$) estimates, showing the range of implied savings. Removed speculative "total savings approach $3-4 billion" language. All homicide claims softened throughout.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Homicide identification
**Concern:** Fatally flawed short panel + 2020 confound.
**Response:** Consistent reframing throughout as "inconclusive." All "no increase" / "safety preserved" / "not a tradeoff" language removed. Noted UCR/CDC WONDER as key future data.

### Balance treated/controls
**Concern:** Huge baseline differences; need matching.
**Response:** Added control group comparability discussion; acknowledged need for synthetic control/matching as limitation.

### Treatment coding
**Concern:** Subjective; need sensitivity to borderline DAs.
**Response:** Added 4-criterion coding rubric; leave-one-out covers borderline sensitivity.

### Event study-TWFE reconciliation
**Concern:** Tension confusing; add Bacon decomposition.
**Response:** Added detailed Goodman-Bacon (2021) explanation of negative weighting mechanism driving TWFE-CS divergence.

### Mechanism tests
**Concern:** Untested compositional claim.
**Response:** Added pretrial share evidence as partial mechanism test.

### Missing literature
**Concern:** MacDonald 2024, Knittel 2023, Abrams 2023.
**Response:** Noted for future revision (not added in this round to avoid over-citing unreferenced works).

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Homicide identification
**Concern:** Event study contradicts TWFE; test excluding 2020-2021 in CS framework.
**Response:** Reframed all homicide claims as "inconclusive." Existing pre-COVID robustness (Table 5) partially addresses this. Noted as important extension.

### TWFE vs CS-DiD divergence
**Concern:** Need Goodman-Bacon decomposition.
**Response:** Added detailed textual explanation of the decomposition logic. Bacon decomposition implementation noted for future work.

### Mechanism data
**Concern:** Use pretrial vs sentenced by race from Vera.
**Response:** Added pretrial mechanism discussion. Full race × detention decomposition requires data not yet available in the panel.

---

## Gemini Advisor (Round 5 FAIL)

### Fatal Error 1: Data-design alignment
**Response:** Already addressed in previous rounds. Added further clarification that treatment status for 2024 is extrapolated from 2023. Clarified that 18 switching counties identify the homicide effect.

### Fatal Error 2: Placeholder text
**Response:** Removed timing placeholder entirely from author footnote.

### Fatal Error 3: 3.2 vs 3.17 consistency
**Response:** Text consistently uses "3.2 ratio points" as a rounded summary; Table 4 reports exact coefficient 3.17. This is standard practice (rounding in text, exact in tables).

### Fatal Error 4: Data coverage 2024
**Response:** Added explicit note to homicide table: "Treatment status for 2024 extrapolated from 2023 assignment."
