# Reviewer Response Plan

## Critical Issues to Address

### 1. Wild cluster bootstrap (all reviewers)
With only 9 treated states, asymptotic cluster-robust SEs may be unreliable. Add wild cluster bootstrap p-values.
**Action:** Add `fwildclusterboot` to 03_main_analysis.R.

### 2. ARPA confounding (all reviewers)
ARPA Section 9817 HCBS funds overlapped with 2021-2024.
**Action:** Add pre-2021 subsample analysis as robustness check.

### 3. Alternative outcome measures (GPT + Gemini)
Provider count may reflect consolidation.
**Action:** Add beneficiaries-served and claims-volume outcomes.

### 4. Prose improvements (prose review)
Lead with findings not table locations. Strengthen opening.
**Action:** Rewrite results paragraphs and opening hook.

### 5. Missing references (all reviewers)
**Action:** Add Dube 2019, Clemens & Gottlieb 2014, and others.

## Not Addressed (Scope Limitations)
- Hand-collecting T1019 reimbursement rates (data not available in API)
- Extending pre-period data (T-MSIS starts 2018)
- Formal MDE calculation (would require power simulation)
