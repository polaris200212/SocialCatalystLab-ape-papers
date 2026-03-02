# Revision Plan: apep_0445 v3

## Context

Paper apep_0445 v2 asks "Do Place-Based Tax Incentives Attract Data Center Investment?" using an RDD at the OZ poverty threshold with NAICS 51 employment as the outcome. The #1 criticism from ALL reviewers (GPT-5.2, Grok, Gemini) was that NAICS 51 is a terrible proxy for data center activity. Two new papers demand engagement:

1. **Gargano & Giacoletti (2025)** "Subsidizing the Cloud" (SSRN 5881105): State-level staggered DiD with *actual facility data* finds incentives DOUBLE data center construction (+50% hyperscale facilities, +200% UPS capacity), but NO tech employment gains.
2. **Jaros (2026)** "Tax Abatements for Data Centers and Government Output" (SSRN 6137769): Finds public expenditures rise after data center arrival; tax abatements work as 20-30 year contracts locking in tax rates.

## Workstreams

### WS1: Add Direct Data Center Location Outcome (HIGHEST PRIORITY)
- EIA Form 860 + EPA GHGRP data, geocoded to census tracts
- New outcomes: dc_any (binary), dc_count, LPM at cutoff
- MDE calculation for power assessment

### WS2: Engage with Gargano & Giacoletti and Jaros
- Major rewrite of Literature and Discussion sections
- Incentive hierarchy framework

### WS3: Strengthen the Null with Direct Measurement
- MDE for DC presence outcome
- Descriptive analysis of DC locations relative to OZ boundaries

### WS4: Address Remaining Reviewer Concerns
- Local randomization covariate balance checks
- DC outcome bandwidth/donut robustness
- Missing references (Kolesar & Rothe, Crane, etc.)

### WS5: Minor Prose/Framing Updates
- Updated abstract with direct DC measurement
- Revision footnote
- Incentive hierarchy in introduction and discussion
