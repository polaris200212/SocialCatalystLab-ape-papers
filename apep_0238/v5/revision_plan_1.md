# Revision Plan: apep_0238 v5

## Summary
This revision fixes verified code-paper inconsistencies in apep_0238 v4. No new analysis or structural changes — purely consistency corrections.

## Changes Made

### CRITICAL Fixes

1. **Data source mismatch (QCEW → CES):** Paper body (Section 4.1) incorrectly said industry employment came from "QCEW." Code fetches BLS CES state-level series via FRED (`{ST}MFG`, etc.). Updated paper to "BLS Current Employment Statistics (CES) program, accessed through FRED."

2. **Control variable mismatch ("log population" → log nonfarm employment):** Paper (Sections 5.1, 5.3) said control vector includes "log population." Code uses `log(emp_2007)` = log nonfarm payrolls at recession peak. Updated paper to "log nonfarm employment at the recession peak."

3. **Missing PBS sector (9 → 10 supersectors):** Paper claimed "10 BLS supersectors" including Professional and Business Services, but code only fetched 9 (PBS missing). Added PROF/PBS to `01_fetch_data.py` INDUSTRIES dict with proper FRED mnemonics (`{ST}PBSV`). Now 34/50 states have PBS data.

4. **Figure 10 hard-coded rescaling:** The 0.30 rescale factor was hard-coded in `06_figures.py`. Replaced with dynamically computed `bartik_sd / hpi_sd` from actual data. New computed value: 0.1607.

5. **Appendix Eq A.2 notation:** Paper used level-change formula; code uses `np.log(loo_end/loo_start)`. Updated equation to log notation: $g_{-s,j} = \ln\left(\frac{E_{j,t_1} - E_{s,j,t_1}}{E_{j,t_0} - E_{s,j,t_0}}\right)$.

### MODERATE Fixes

6. **COVID horizon (52 → 48 months):** Paper said "52 months" but code `covid_horizons = list(range(0, 49, 1))` computes max h=48. Updated paper and table notes.

7. **Discount rate (4.8% → 4.7%):** $1 - 0.996^{12} = 0.047$. Updated calibration table target column.

8. **Code headers (apep_0234 → apep_0238):** All code files and references.bib had wrong paper ID. Fixed in 00_packages.py, 01_fetch_data.py, 02_clean_data.py, 08_tables.py, references.bib.

## Verification
- All scripts re-run from data fetch through table generation
- LP results consistent with v4 (same coefficients, same significance)
- Model results identical (33.52% demand welfare loss, 0.23% supply)
- Figure 10 rescaling now computed from data
- No remaining "QCEW", "log population", "apep_0234", or "52 months" in paper/code
