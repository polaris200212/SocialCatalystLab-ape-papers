# Revision Plan: apep_0445 v4

## Parent: apep_0445 v3

## Changes Made

### WS1: DC Vintage Analysis
- Added generator-level operating year extraction from EIA-860 3_1_Generator sheet
- Created vintage variables: `dc_any_post2018`, `dc_count_post2018`, `dc_any_pre2018`, `dc_count_pre2018`
- Added vintage RDD analysis in `03_main_analysis.R` (LPM within 15pp bandwidth due to sparsity)
- Added bandwidth robustness for vintage outcomes in `04_robustness.R`
- New Figure 11: DC presence by vintage at cutoff
- New Table 7: DC vintage RDD results (pre-2018 placebo + post-2018 treatment)
- New Section 6.5 in paper: "Data Center Vintage Analysis"

### WS2: Elevate Local Randomization to Co-Primary
- Added Section 5.3: "Local Randomization Framework" explaining dual-framework approach
- Added Section 6.3: "Main Results: Design-Based Estimates (Local Randomization)" with new main-text Table 8
- Added local randomization for DC outcomes and construction employment in `04_robustness.R`
- Reduced LR coverage in robustness section (now cross-references main text)

### WS3: Literature & Citations
- Added BibTeX entries: Lee & Card (2008), Busso et al (2014), GAO (2022), Masanet et al (2020), Kennedy & Wheeler (2022), Roth (2022)
- Integrated citations: McCrary (2008) in density discussion, Lee & Card (2008) in discrete RV discussion, Busso et al (2014) in EZ literature, GAO (2022) and Kennedy & Wheeler in OZ evaluations, Masanet (2020) in infrastructure section

### WS4: Estimand Language Tightening
- Defined estimand precisely in Section 5.1 with footnote about compound LIC treatment
- Consistent "LIC eligibility threshold" terminology throughout
- Renamed Section 6.2 to "Main Results: Continuity-Based Estimates"

### WS5: Minor Fixes
- Converted enumerated incentive hierarchy (lines 106-111) to flowing prose
- Updated title footnote for v4

## Verification
- All R scripts run without error
- Pre-2018 DC placebo shows no discontinuity (validates design)
- Post-2018 DC outcome reported with MDE
- Local randomization results in main text with all outcomes
- No unresolved `??` citations in compiled PDF
- 32 pages main text (well over 25-page minimum)
- All reviewer concerns addressed
