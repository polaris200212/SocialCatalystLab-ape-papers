# Initialization: APEP 0149 v5

## Session Metadata
- **Date:** 2026-02-09
- **Contributor:** @olafdrw
- **Parent Paper:** apep_0149
- **Mode:** Revision

## Revision Information
- **Parent Paper:** apep_0149
- **Parent Version:** v4 (paper_id: apep_0160)
- **Revision Type:** Code review response
- **Trigger:** GPT-5.2 code scan flagged 6 issues (1 HIGH, 2 MEDIUM, 3 LOW)

## Revision Rationale

Paper apep_0160 received a **SUSPICIOUS** verdict from the daily GPT-5.2 code review scan (scan_report.json, 2026-02-06). The scan flagged 6 issues (1 HIGH, 2 MEDIUM, 3 LOW). This revision (v5) addresses all 6 code-paper mismatches.

### Issues Addressed

| # | Severity | Category | File | Summary |
|---|----------|----------|------|---------|
| 1 | HIGH | METHODOLOGY_MISMATCH | 01_fetch_data.R:15 | Code requests 2017:2024 (includes 2020) but paper states 2020 excluded |
| 2 | MEDIUM | METHODOLOGY_MISMATCH | 02_clean_data.R:43-51 | Treatment coding uses adopt_year only; no month/day to verify July 1 rule |
| 3 | LOW | DATA_PROVENANCE_MISSING | 01_fetch_data.R:80-131 | Treatment dates hardcoded without source citations |
| 4 | LOW | DATA_FABRICATION | 04_robustness.R:420-434 | Monte Carlo labeled as calibration but could be clearer |
| 5 | MEDIUM | SUSPICIOUS_TRANSFORMS | 02_clean_data.R:50-52 | post_phe = year >= 2023 is coarser than PHE end date (May 11, 2023) |
| 6 | LOW | METHODOLOGY_MISMATCH | 04_robustness.R:583-588 | DDD pre-trend joint test uses diagonal vcov approximation |

### Key Finding

The 2020 issue (HIGH) is a **documentation mismatch, not data contamination**. The sample size table in the paper shows 7 years (2017-2019, 2021-2024) totaling 3,683,347 women. The Census API returned null for 2020 ACS 1-year PUMS (experimental product due to COVID), and the code's null check silently skipped it. The fix makes the exclusion explicit rather than relying on API behavior.

### Planned Changes

1. **01_fetch_data.R:** Explicit 2020 exclusion; treatment dates with month/day/source
2. **02_clean_data.R:** Defensive 2020 filter; July 1 rule and PHE timing comments
3. **04_robustness.R:** Monte Carlo comment strengthening; DDD vcov improvement
4. **paper.tex:** Title footnote, treatment assignment text, limitations, DDD footnote, acknowledgements
