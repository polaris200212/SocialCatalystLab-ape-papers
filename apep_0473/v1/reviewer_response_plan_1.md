# Reviewer Response Plan

## Reviews Received
- **GPT-5.2:** MAJOR REVISION
- **Grok-4.1-Fast:** MINOR REVISION
- **Gemini-3-Flash:** MINOR REVISION

## Grouped Concerns and Planned Responses

### Workstream 1: Identification Clarity (GPT #1.3, #1.2; Grok #1)
**Concern:** CS identification horizon unclear; which group-time ATTs are identified?
**Plan:** Add a paragraph in Section 4.2 explicitly documenting the identification structure:
- 2016 cohort: post-treatment ATTs in 2016 (controls: 2017+2018) and 2017 (controls: 2018)
- 2017 cohort: post-treatment ATT in 2017 (controls: 2018)
- 2018 cohort: no post-treatment ATTs identifiable
- Overall ATT aggregation weights (approximate via group sizes and post-periods)
- Soften event-study interpretation for longer horizons

### Workstream 2: Treatment Assignment Robustness (GPT #1.1; Gemini #HV2)
**Concern:** Fuzzy matching and unmatched-to-2018 assignment may attenuate.
**Plan:** Add robustness check in 04_robustness.R dropping all fuzzy-matched/unmatched LAs (keep only exact matches). Report result in Table 4. Also note this is conservative (attenuation toward null).

### Workstream 3: Dose Dilution / Treatment Intensity (GPT #3.3; Gemini #MF1; Grok #MF2)
**Concern:** LA-level ITT diluted; need back-of-envelope TOT scaling.
**Plan:** Add formal back-of-envelope in Discussion: ~12% working-age on benefits × some UC uptake fraction → implied TOT. Also note this is a limitation of aggregate data design.

### Workstream 4: Claim Calibration (GPT #5.1, #5.2; Grok)
**Concern:** "Precisely estimated null" and gig economy narrative claims too strong.
**Plan:** Soften conclusion language. Replace "definitively refutes" type language with "finds no evidence consistent with..." bounded by identified horizon and ITT nature.

### Workstream 5: Prose improvements (from prose review)
- Improve results narration
- Tighten transition sentences

### Workstream 6: Exhibits (from exhibit review)
- Already addressed in prior rounds

### Not Addressed (Future Work)
- APS microdata access (GPT #2.1): requires restricted data, beyond scope
- Dose-response with UC caseload data (GPT #3.3): requires administrative data not available
- Alternative estimators (Sun-Abraham, BJS): would improve but not change null finding
- Sector-specific analysis with BRES (Gemini #HV1): requires additional data pull
- Spatial/Conley SEs (GPT #2.2): would be valuable but unlikely to change inference given null
