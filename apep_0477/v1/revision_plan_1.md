# Revision Plan 1 — Addressing Referee Feedback

## Overview

Three referees provided feedback: GPT-5.2 (Major Revision), Grok-4.1-Fast (Major Revision), Gemini-3-Flash (Minor Revision). This plan addresses the key concerns.

## Changes Made

### 1. Decomposition Benchmark (All 3 referees)
- **Issue:** D/E boundary fails density test; cross-cutoff comparison not credibly identified
- **Action:** Switched to C/D-only as preferred informational benchmark. Added explicit caveats about cross-cutoff assumptions. Reframed within-cutoff tenure comparison as primary identification.

### 2. Postcode Matching Limitations (All 3 referees)
- **Issue:** Postcode matching introduces measurement error; not property-level
- **Action:** Added new paragraph in Section 4.5 discussing non-classical measurement error, attenuation bias interpretation, and clustering concerns. Noted UPRN matching as future work.

### 3. Pre-MEES Anticipation (GPT, Grok)
- **Issue:** Large pre-MEES E/F effect (16.1%) complicates regulatory narrative
- **Action:** Added discussion paragraph on MEES announcement (2015 Energy Act) and market anticipation. Noted tenure-specific pre-MEES estimates are imprecise.

### 4. Moderate "Information is Zero" Claims (GPT)
- **Issue:** Cross-cutoff evidence insufficient to prove labels have no informational value
- **Action:** Changed "near zero" to "small" throughout. Added caveat that small discrete label effects don't preclude continuous score effects. Revised abstract.

### 5. Data Date Consistency (Advisor reviews)
- **Issue:** Tables said "2015-2025" while text said "through December 2024"
- **Action:** Standardized all references to "January 2015 through December 2024". Fixed Table 1 notes and Table 3 headers.

### 6. Table 4 Overall Column (GPT advisor)
- **Issue:** Text claimed "overall 7.5pp" not shown in table
- **Action:** Added Overall column to Table 4 decomposition.

### 7. Polynomial Significance (GPT advisor)
- **Issue:** Text said "both at 1%" but quadratic p=0.047
- **Action:** Corrected to "linear at 1%, quadratic at 5%".

## Changes NOT Made

- **Diff-in-discontinuities framework** (GPT): Would require complete redesign; noted as promising future direction
- **UPRN matching** (all): Data infrastructure change beyond current scope
- **Cluster-robust inference** (GPT): rdrobust clustering at postcode level infeasible with current sample structure
- **Multiple testing adjustments** (GPT): Pre-specified primary estimand (E/F) makes this less critical
