# Reviewer Response Plan — Round 1

## Priority 1: Must-Fix (Methodology/Identification)

### 1. Apartment regression with département × year FE
- **Source:** GPT (must-fix #2), Gemini (optional polish)
- **Fix:** Add m4_dept model in 03_main_analysis.R: feols(log_price_m2 ~ th_dose_std:post | code_commune + code_dept^year). Report in Table 2 or Table 4.

### 2. Joint pre-trend test for apartment event study
- **Source:** GPT (must-fix #3), Grok (must-fix #3)
- **Fix:** Add wald() test on pre-reform apartment event study coefficients. Report in text near Figure 2.

### 3. HonestDiD for apartment outcome
- **Source:** GPT (must-fix #3)
- **Fix:** Run HonestDiD on apartment event study model in 04_robustness.R. Report in robustness section.

### 4. Data seam robustness: restrict to CdD period (2014-2020)
- **Source:** GPT (must-fix #4)
- **Fix:** Re-estimate apartment regression on 2014-2020 only (CdD data source). Report in robustness.

## Priority 2: High-Value Improvements

### 5. Prose improvements
- Remove roadmap paragraph
- Active voice for design choices
- Punchier transition at Section 6.1

### 6. Exhibit improvements
- Minor: keep current structure (restructuring tables is too disruptive at this stage)

## Not Addressed (Data Limitations)

- Secondary-residence placebo: DVF does not distinguish primary/secondary residences in the commune-level CdD aggregates. Acknowledged as limitation.
- Filosofi triple-diff: Income data not downloaded in this iteration. Acknowledged as future work.
- Rental prices: Not available in DVF. Acknowledged as limitation.
- Treatment map: Would require geocoding infrastructure not available.
