# Revision Plan: apep_0460 v4

## Parent: apep_0460 v3 (Across the Channel)

## Referee Feedback Summary (v3)
- 2 MAJOR REVISION + 1 MINOR REVISION
- German placebo dominates baseline DiD (SCI_DE × Post β=0.043, p=0.008)
- Triple-diff statistically weak (p≈0.10)
- Pre-trends marginal (joint F-test p=0.038 for SCI)
- Only 96 clusters → asymptotic SEs unreliable
- Only DE/CH placebos tested

## Five Improvements Implemented

### 1. Wild Cluster Bootstrap (fwildclusterboot)
- boottest() on all key specifications
- Addresses finite-cluster concern with 96 départements

### 2. SCI-Based Triple-Diff Pre-2020
- Test SCI triple-diff on pre-2019 subsample
- Compare with stock-based null from v3

### 3. Multi-Country Placebos (BE, NL, IT, ES)
- Extract FR→{BE,NL,IT,ES} from GADM1 SCI data
- Individual DiD and triple-diff placebos
- Horse race: all countries simultaneously

### 4. HonestDiD Sensitivity Analysis
- Rambachan & Roth (2023) on census stock event study
- Breakdown frontier for relative magnitudes

### 5. Commune-Level Triple-Diff
- Rebuild from raw DVF at commune level
- More precise estimates with ~50-100× more observations
