# Revision Plan 1

## Summary of Reviews
- GPT-5-mini: MAJOR REVISION (discrete RD inference, table reporting detail)
- Grok-4.1-Fast: MINOR REVISION (missing refs, fiscal source, transparency)
- Gemini-3-Flash: MINOR REVISION (framing, welfare depth, contribution clarity)

## Planned Changes

### 1. Discrete Running Variable Discussion (GPT concern)
- Add paragraph in Section 6.3 acknowledging that standard rdrobust inference may understate variance with discrete RV
- Note that the year-by-year stability (8 independent estimates all positive) provides informal validation
- Add reference to Cattaneo, Jansson & Ma (2020) for density estimation discussion
- Note McCrary test limitation for discrete RV in Section 9.1

### 2. Table Reporting Enhancement (GPT concern)
- Table 2 already reports SEs, CIs, p-values, and N within bandwidth
- Add bandwidth value to Table 2 footnote
- Add explicit note about subsample size vs. full sample N in table notes

### 3. Missing References (Grok concern)
- Add Cattaneo, Jansson & Ma (2020)
- Add Imbens & Kalyanaraman (2012)

### 4. Fiscal Estimate Source (Grok concern)
- Add citation for Medicaid payment rate ($5,500 per delivery)

### 5. Reframe Contribution (Gemini concern)
- Adjust abstract/intro to emphasize the fiscal/payer-mix finding as primary contribution
- Frame null health outcomes as secondary (though informative) finding

### 6. Welfare Discussion (Gemini concern)
- Add sentence about administrative costs of churning in Discussion

### NOT ADDRESSED (acknowledged limitations)
- Restricted-use data for state identifiers (not available)
- Mass-point-level aggregated RD (rdrobust with jitter already addresses this)
- Multiple subsample robustness (year-by-year stability serves this role)
