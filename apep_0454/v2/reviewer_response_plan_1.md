# Reviewer Response Plan — apep_0454 v2, Cycle 1

## Overview
Three referee reviews received (GPT MAJOR, Grok MINOR, Gemini MAJOR). Common themes:
1. Mechanical pre-trends from treatment definition
2. Non-HCBS falsification undermines HCBS-specific claim
3. Need wild cluster bootstrap with 51 clusters
4. HCBS-specific exit rate requested

## Changes Made

### R Code Changes
- **03_main_analysis.R**: Added broken-trend specification (state-specific linear trends), HCBS-specific exit rate specs, formal pooled HCBS vs non-HCBS differential test
- **04_robustness.R**: Added Wild Cluster Restricted (WCR) bootstrap (999 replications)
- **06_tables.R**: Updated robustness table with WCB, broken-trend, and HCBS-specific rows

### Paper Changes
- **Section 6.7 (Robustness)**: Added WCR bootstrap discussion (providers p=0.042, beneficiaries p=0.059), broken-trend results (-0.299, p=0.288), HCBS-specific exit rate results (-0.791, p=0.052), formal pooled differential test (+0.141, p=0.638)
- **references.bib**: Added Cameron et al. (2008)
- **Reframing**: θ_s captures broad Medicaid market fragility, not HCBS-specific mechanism. HCBS is the most policy-relevant case.

## Items NOT Changed (with rationale)
- **Core identification strategy**: The broken-trend specification is highly conservative; the main specification is retained with honest caveats
- **ARPA analysis**: Kept as exploratory; state-level implementation data not available
- **Beneficiary measure**: Already noted as encounters, not unique individuals
- **IV**: Already demoted; weak F-stat acknowledged
