# Revision Plan: apep_0069 v2 — Stage C (Post-Referee)

## Reviewer Verdicts (Stage B)
- GPT-5-mini: MINOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MINOR REVISION

## Key Concerns from Referees

1. **GPT**: Clarify SE/inference in table notes; discuss Conley SEs; explain donut RDD pattern; suggest synthetic control as additional robustness
2. **Grok**: Add de Chaisemartin-D'Haultfoeuille and Sun-Abraham discussion; minor lit additions
3. **Gemini**: Discuss GR-SG outlier (+13 pp); suggest individual-level survey evidence; language coding at Gemeinde level

## Changes to Make

### A. Table note clarifications
- Add SE method details to RDD and DiD table notes (bias-corrected RD CIs, canton-clustered)
- Clarify CS uses never-treated controls with canton-clustered SEs

### B. GR-SG outlier discussion
- Add paragraph to border-pair heterogeneity discussing Graubünden's early adoption (2011), Alpine tourism economy, and potential positive spillovers from environmental tourism branding

### C. Donut RDD pattern explanation
- Expand discussion: near-border municipalities experience cross-canton economic integration (commuting, shopping) that attenuates treatment effects; removing these reveals the "pure" cantonal effect

### D. Conley SEs note
- Add sentence in OLS section noting Conley SEs as potential sensitivity check; explain canton clustering + WCB is primary

### E. RI sharp null clarification
- Already explicit in text; no change needed

### F. Literature
- de Chaisemartin-D'Haultfoeuille and Sun-Abraham already cited in bibliography; add brief mention in methods section

## Items NOT addressed (scope beyond minor revision)
- Synthetic control (would require new R code and significant expansion)
- Individual-level survey data (Selects/Voto — data not available via API)
- Gemeinde-level language shares (census data not fetched; acknowledged as limitation)
