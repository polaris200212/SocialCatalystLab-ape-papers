# Reviewer Response Plan

## Summary of Feedback

Three external referees reviewed the paper:
- GPT-5.2: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MINOR REVISION

Plus exhibit and prose reviews from Gemini.

## Grouped Concerns and Actions

### 1. Summary Statistics Mismatch (All advisors)
**Status:** FIXED. Text now matches Table 1 exactly (299 NPIs, 295K claims, 58K beneficiaries, $34.5M).

### 2. TWFE vs CS Sign Discrepancy (Gemini advisor, GPT referee)
**Status:** FIXED. Added explicit paragraph reconciling TWFE (-0.104) and CS (+0.010) estimates with Bacon decomposition explanation.

### 3. 95% Confidence Intervals (GPT referee, Grok referee)
**Status:** FIXED. Added 95% CI column to Table 3 (CS ATT table).

### 4. Emergency vs Permanent Parity Timeline (GPT referee)
**Status:** FIXED. Added new paragraph in Section 2.2 distinguishing emergency telehealth waivers from permanent parity laws.

### 5. CMS Suppression Bias (GPT referee)
**Status:** FIXED. Added paragraph in Data section discussing suppression threshold and mitigation strategies.

### 6. Data Completeness (Gemini advisor)
**Status:** FIXED. Added note about T-MSIS reporting lags and 2024 data verification.

### 7. Missing set.seed() (Codex advisor)
**Status:** FIXED. Added set.seed(2024) before all bootstrap-based estimation calls.

### 8. Significance Notation (Gemini advisor)
**Status:** FIXED. Added explicit note to Table 2 that no coefficient reaches p < 0.10.

### 9. Roadmap Paragraph (Prose review)
**Status:** FIXED. Removed "The remainder of the paper proceeds as follows..." paragraph.

### 10. Abstract Closing (Prose review)
**Status:** FIXED. Strengthened to "While parity removes a financial penalty for remote care, it cannot overcome the structural barriers..."

### Not Addressed (scope/feasibility constraints)
- Treatment heterogeneity coding (audio-only vs video-only): Would require re-running analysis with new treatment definitions; beyond scope of this revision cycle
- Provider type split (organizational vs individual NPI): Requires additional data processing
- Geographic heterogeneity (rural vs urban): Requires ZIP-to-RUCA crosswalk not available
- Wild cluster bootstrap: Package not available for R 4.3.3
- Additional placebo (dental): Would require significant data extraction and analysis
