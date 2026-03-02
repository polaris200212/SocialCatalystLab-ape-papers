# Reply to Reviewers: apep_0069 v2

## Reviewer 1: GPT-5-mini (MINOR REVISION)

### Concern 1: Clarify SE/inference in table notes
**Response:** Added explicit citation to Calonico et al. (2014) bias-corrected inference in the RDD table note (Table 3). Clarified that confidence intervals use robust bias-corrected procedures and that p-values are from bias-corrected t-statistics. Added that CS estimator uses never-treated controls with canton-clustered SEs.

### Concern 2: Discuss Conley SEs
**Response:** Added a sentence in the OLS results section (Section 5.1) noting Conley spatial SEs as a potential sensitivity check, explaining why canton-clustered CRVE with WCB is prioritized as the primary inference approach (treatment varies at canton level; WCB already addresses few-cluster concern).

### Concern 3: Explain donut RDD pattern
**Response:** Expanded the donut RDD discussion (Section 5.3, paragraph 4) with an explanation of the mechanism: near-border municipalities experience cross-canton economic integration (commuting, shopping, media consumption) that creates treatment spillovers. Removing this contaminated zone reveals the "pure" cantonal effect.

### Concern 4: Suggest synthetic control as additional robustness
**Response:** Not addressed. Synthetic control would require substantial new R code and methodological development (constructing donor pools for 5 treated cantons across 4 referendum periods). This is beyond the scope of a minor revision and is noted as a direction for future work.

---

## Reviewer 2: Grok-4.1-Fast (MINOR REVISION)

### Concern 1: Add de Chaisemartin-D'Haultfoeuille and Sun-Abraham discussion
**Response:** Added explicit discussion in Section 4.4 (Panel Analysis) explaining how dCDH's negative weighting result and Sun-Abraham's interaction-weighted estimators motivate the time-varying treatment coding and CS estimator choice. Both were already in the bibliography; now they are discussed in the methods text.

### Concern 2: Minor literature additions (Egger et al., Erikson et al.)
**Response:** Not added. Egger et al. (2022) addresses generalized DiD for continuous treatments, which is not directly applicable to our binary spatial RDD. Erikson et al. (2002) on the macro polity is tangential to the Swiss direct democracy setting. The existing bibliography (60+ entries) is comprehensive.

---

## Reviewer 3: Gemini-3-Flash (MINOR REVISION)

### Concern 1: Discuss GR-SG outlier (+13 pp)
**Response:** Added a full paragraph in the border-pair heterogeneity appendix section (Appendix B.3) discussing Graubünden's early adoption (2011, longest exposure), Alpine tourism economy (positive spillovers from environmental branding), geographic isolation reducing "federal overreach" concerns, and the wide confidence interval making the estimate highly uncertain.

### Concern 2: Suggest individual-level survey evidence
**Response:** Not addressed. Selects/Voto survey data are not available via API and would require manual data acquisition and IRB considerations. Acknowledged as a limitation in Section 7.2 (Treatment Measurement paragraph).

### Concern 3: Language coding at Gemeinde level
**Response:** Not addressed. Gemeinde-level language shares from census data would require additional data harmonization. Already acknowledged as a limitation in Section 7.2 (Canton-Level Language Assignment paragraph), which discusses the imprecision for bilingual cantons and notes that Gemeinde-level data could provide finer resolution.

---

## Summary of Changes Made

| Change | Section | Revision Plan Item |
|--------|---------|-------------------|
| RDD table note: Calonico citation, SE details | Table 3 note | A |
| GR-SG outlier discussion | Appendix B.3 | B |
| Donut RDD pattern explanation | Section 5.3 | C |
| Conley SEs note | Section 5.1 | D |
| dCDH + Sun-Abraham discussion | Section 4.4 | F |

## Items Not Addressed (Beyond Minor Revision Scope)

- Synthetic control (new R code + significant expansion)
- Individual-level survey data (data not available via API)
- Gemeinde-level language shares (additional data harmonization needed)
- Egger et al. and Erikson et al. references (tangential)
