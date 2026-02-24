# Revision Plan 1 — Addressing External Reviewer Feedback

## Reviewers
- GPT-5.2: MAJOR REVISION
- Grok-4.1-Fast: MAJOR REVISION
- Gemini-3-Flash: MINOR REVISION

## Changes Implemented

### 1. Inference Strengthening (GPT, Grok)
- Added leave-one-out jackknife analysis (51 iterations)
- Result: coefficient remains negative in all iterations, range [-2.93, -1.07]
- Added MacKinnon & Webb (2017) and Young (2019) references for RI/bootstrap justification

### 2. Multiple Placebo Tests (GPT, Grok)
- Added 3 placebo dates: April 2019, October 2019, January 2020
- All placebos ~-1.1, all insignificant — consistent pre-period pattern
- Strengthened discussion acknowledging pre-existing heterogeneity

### 3. Provider Entry/Exit Dynamics (GPT)
- Computed annual provider churn using billing NPI persistence
- High-stringency states: exit rate rose from 8.6% (2019) to 10.3% (2020)
- Entry rates similar across groups — divergence from exit, not entry

### 4. N per Row in Robustness Table (GPT, Grok)
- Added observation count column to Table 4
- All specifications now report N and can be compared

### 5. Log(0) Handling (GPT)
- Added note to Tables 2 and 4: "All log outcomes use log(Y+1)"

### 6. Literature Additions (GPT, Grok, Gemini)
- Gruber (1994) — canonical DDD reference
- Goolsbee & Syverson (2021) — lockdown vs voluntary behavior
- MacKinnon & Webb (2017) — wild bootstrap inference
- Young (2019) — randomization inference in econ

### 7. Prose Improvements
- Strengthened opening hook per prose review
- Removed roadmap paragraph
- More active voice

## Acknowledged but Not Implemented
- Telehealth policy index: data not available in standardized form
- BLS OEWS workforce data: API requires key not configured
- Restricted RI permutations: would require state-level covariate data
- FFS vs managed care decomposition: T-MSIS does not distinguish
- Sub-state stringency: OxCGRT is state-level only
