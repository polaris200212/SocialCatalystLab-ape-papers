# Reply to Reviewers: apep_0238 v5

## Overview

This revision addresses code-paper inconsistencies identified in apep_0238 v4. All changes are corrective — no new analysis, data, or methods were added.

---

## Response to Code Scanner Flags

### Flag 1: Paper claims QCEW data, code uses CES via FRED
**Response:** Fixed. Section 4.1 now correctly states: "State-level employment by major industry sector from the BLS Current Employment Statistics (CES) program, accessed through FRED." The FRED mnemonics (e.g., `{ST}MFG`, `{ST}CONS`) are CES series, not QCEW.

### Flag 2: Paper says "log population" control, code uses log(emp_2007)
**Response:** Fixed. All references to "log population" in Sections 5.1 and 5.3 now read "log nonfarm employment at the recession peak," which accurately describes `log(emp_2007)` in the code.

### Flag 3: Paper claims 10 supersectors, code fetches only 9
**Response:** Fixed. Added Professional and Business Services (PROF/PBS) to the state-level industry fetching in `01_fetch_data.py`. Coverage: 34/50 states. The national series `USPBS` was already fetched in v4. All analysis scripts re-run with the complete 10-sector Bartik instrument.

### Flag 4: Figure 10 uses hard-coded 0.30 rescaling
**Response:** Fixed. The rescale factor is now computed dynamically as `bartik_sd / hpi_sd` from the actual data (value: 0.1607). Figure note documents the methodology.

### Flag 5: Appendix Eq A.2 uses level changes, code uses log changes
**Response:** Fixed. Equation now reads: $g_{-s,j} = \ln\left(\frac{E_{j,t_1} - E_{s,j,t_1}}{E_{j,t_0} - E_{s,j,t_0}}\right)$, matching `np.log(loo_end/loo_start)` in the code.

### Flag 6: COVID horizon mismatch (52 vs 48 months)
**Response:** Fixed. Paper text and table notes updated to reflect the actual LP horizon of 48 months.

### Flag 7: Discount rate calculation (4.8% vs 4.7%)
**Response:** Fixed. $1 - 0.996^{12} = 0.0469 \approx 4.7\%$. Calibration table target column updated.

### Flag 8: Code headers say apep_0234
**Response:** Fixed. All code file headers and references.bib comment updated to apep_0238.

### Flag 9: LFPR table claimed N=20, actual coverage is 50 states
**Response:** Fixed. Updated LFPR LP table (Table 9) with correct values from re-run analysis using all 50 states. Added clarifying note about large COVID Bartik coefficients reflecting the small standard deviation of the instrument.

### Flag 10: Text-table coefficient mismatches after Bartik recomputation
**Response:** Fixed. After adding PROF sector to Bartik, COVID β_3 changed from 0.7034 to 0.8279, β_48 from -0.060 to -0.010, R² at h=3 from 0.52 to 0.51, and Bartik SD from 0.029 to 0.023. All in-text references updated to match tables.

### Flag 11: Table 6 note referenced non-existent "n/a" entries
**Response:** Fixed. Replaced with note explaining ranking methodology ("States are ranked by trough employment change").

### Flag 12: Table 3 peak horizon (h=45) not in Table 2
**Response:** Added note to Table 3: "The peak horizon is computed from LP estimates at all monthly horizons; Table 2 reports selected horizons only."

---

## Response to External Referee Feedback

### GPT-5-mini (Major Revision)
The reviewer requested additional inference details (exposure-robust SEs in main table, permutation CIs), fiscal policy controls, and migration quantification. These are substantive suggestions for future work. This revision focused exclusively on fixing code-paper inconsistencies; content extensions are beyond scope.

### Grok-4.1-Fast (Minor Revision)
The reviewer noted the paper is well-executed and suggested adding Goodman-Bacon (2021) and Sun & Abraham (2021) citations, plus wild cluster bootstrap. These are reasonable additions for a subsequent revision.

### Gemini-3-Flash (Minor Revision)
The reviewer praised the paper as "top-5 caliber" and suggested heterogeneity by skill/education, migration controls using IRS data, and model calibration sensitivity. These are excellent suggestions for a future content revision.
