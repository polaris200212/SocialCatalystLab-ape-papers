# Human Initialization
Timestamp: 2026-02-24T13:26:00Z

**Parent Paper:** apep_0447

## Contributor (Immutable)

**GitHub User:** @olafdrw

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Questions Asked

1. **Research agenda:** Which research agenda?
   - Options: Medicaid provider spending (T-MSIS), India economic development (SHRUG), Open topic (any policy/data)

**Medicaid Path:**
2. **Method:** Which identification method?
3. **API keys:** Are Census and FRED keys configured?
4. **External review:** Include external model reviews?
5. **Other preferences:** Any other preferences or constraints?

## User Responses

1. Medicaid provider spending (T-MSIS)
2. DiD (Recommended)
3. Yes
4. Yes (Recommended)
5. "write a paper on covid and the medicaid data we have. try to exploit variation across or within states (e.g. lockdowns)." — Surprise me on specific angle.

## Setup Results

- **Research agenda:** Medicaid
- **Domain:** Health/Medicaid
- **Method:** DiD
- **Data era:** Modern
- **Risk appetite:** Novel angle (COVID × Medicaid lockdown variation — not previously studied in APEP)
- **Other preferences:** Exploit COVID lockdown variation across states

## Revision Information

**Parent Paper:** apep_0447
**Parent Title:** Locked Out of Home Care: COVID-19 Lockdown Stringency and the Persistent Decline of Medicaid HCBS
**Parent Decision:** MAJOR REVISION (from GPT-5.2 and Grok-4.1-Fast), MINOR REVISION (from Gemini-3-Flash)
**Revision Rationale:** Address reviewer concerns about HCBS classification contamination, DDD decomposition, inference robustness, and missing literature

## Key Changes Planned

- WS1: Clean HCBS classification (restrict T-codes to genuinely in-home care)
- WS2: DDD decomposition (separate HCBS-only and BH-only DiD regressions)
- WS3: BLS OEWS workforce evidence (external labor data)
- WS4: Improved RI (5000 perms) and wild cluster bootstrap attempt
- WS5: Add ~7 missing references
- WS6: Exhibit improvements (de-clutter, restructure, add CIs)

## Original Reviewer Concerns Being Addressed

1. **GPT-5.2:** HCBS classification contamination; need DDD decomposition; inference strengthening
2. **Grok-4.1-Fast:** Missing literature; power concerns; workforce evidence needed
3. **Gemini-3-Flash:** Exhibit improvements; placebo discussion; reimbursement heterogeneity

## Inherited from Parent

- Research question: Effect of COVID-19 lockdown stringency on Medicaid HCBS
- Identification strategy: Triple-difference (HCBS vs BH x pre/post x stringency)
- Primary data source: T-MSIS Medicaid Provider Spending (2018-2024)
