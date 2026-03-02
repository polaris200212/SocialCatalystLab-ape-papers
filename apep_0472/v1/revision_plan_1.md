# Revision Plan 1 — apep_0472 v1

## Stage C Revision: Addressing Referee Feedback

### Reviews Received
- GPT-5.2: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MINOR REVISION

### Changes Implemented

1. **Multiple testing correction**: Added Holm and BH adjustments to category results table. Public order and ASB remain significant after correction. Discussion added to Section 5.3.

2. **Leave-one-out sensitivity**: Added jackknife analysis dropping each switcher LA. Coefficient ranges from -0.05 to -0.95, demonstrating stability. Added to Appendix C.

3. **TWFE contamination narrative fixed**: Appendix C.3 now precisely explains the role of always-treated units — collinear with unit FE, do not directly identify β, but can influence time FE and enter Bacon comparisons implicitly.

4. **Power section clarified**: Identification now correctly attributed to 10 switcher LAs rather than "all 28 licensing LAs."

5. **Weapons placebo addressed**: Added discussion of policing intensity confound and reference to Region×Month FE robustness specification.

6. **"Waterbed" reframed**: Clarified as categorical displacement (redistribution across offence types) rather than spatial displacement. Future work with boundary data noted.

### Changes Deferred (noted as limitations/future work)
- Ward-level treatment definition (requires FOI boundary data)
- C&S at LSOA-month level (computationally infeasible)
- Formal Bacon decomposition
- Spatial spillover test with buffer zones
- Poisson quasi-MLE specification
- Crime Survey (CSEW) triangulation
