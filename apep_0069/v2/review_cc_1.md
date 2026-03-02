# Internal Review: apep_0069 v2

**Reviewer:** Claude Code (claude-opus-4-6)
**Timestamp:** 2026-02-10T15:07:00

## Summary

This is a revision of apep_0069 v1 ("The Thermostatic Voter"). The revision addresses all code integrity issues from v1 (SUSPICIOUS verdict with 2 HIGH, 3 MEDIUM issues) and incorporates referee feedback from Stage B reviews (all 3 MINOR REVISION).

## Code Integrity Fixes (WS1)

1. **Panel DiD**: Replaced static `treated * post` with time-varying `D_ct` using in-force years (GR=2011, BE=2012, AG=2013, BL=2016, BS=2017)
2. **CS estimator**: Updated to use in-force years for `first_treat`, excluded BS (treatment = final period)
3. **Same-language border filter**: Implemented per-segment distance computation, verifying both sides of nearest border are German-speaking
4. **WCB inference**: Added wild cluster bootstrap with Webb 6-point weights
5. **Stratified RI**: Permutation now restricted to 17 German-speaking cantons
6. **Treatment provenance**: Added LexFind URLs for all treated cantons

## Identification Improvements (WS2)

- Border-pair forest plot with per-segment estimates
- Covariate balance tests at same-language borders
- Donut RDD with full specification table

## Paper Rewrite (WS5)

- Reframed identification hierarchy: same-language RDD = primary, pooled = upper bound
- Updated all hardcoded numbers to v2 analysis results
- Added placebo outcomes section
- Added summary of results table
- Grounded mechanism discussion in heterogeneity evidence

## Stage C Fixes

- Enhanced RDD table note with Calonico citation
- Added GR-SG outlier discussion (early adoption, tourism economy)
- Expanded donut RDD pattern explanation (cross-border spillovers)
- Added Conley SEs note in OLS results
- Added dCDH and Sun-Abraham discussion in panel methods

## Issues Remaining

- Synthetic control not implemented (beyond minor revision scope)
- Individual-level survey data not available
- Gemeinde-level language shares not fetched

## Verdict

Paper is substantially improved from v1. All code integrity issues resolved. All feasible referee suggestions addressed. Ready for publication.
