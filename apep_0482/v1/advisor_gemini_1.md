# Advisor Review - Gemini-3-Flash

**Role:** Academic advisor checking for fatal errors
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-02T11:52:11.295863
**Route:** Direct Google API + PDF
**Paper Hash:** 91db768868c68392
**Tokens:** 18318 in / 904 out
**Response SHA256:** b156ab536f1b66a0

---

I have reviewed the draft paper "Looking Within: Gender Quotas and the Composition of Municipal Education Spending in Spain" for fatal errors.

**FATAL ERROR 1: Regression Sanity / Internal Consistency**
- **Location:** Table 1 (Summary Statistics, page 10) vs Table 5 (Main Results, page 16) and Table 9 (Heterogeneity, page 23).
- **Error:** In Table 1, the variable "Secondary Education" has a reported Mean of 0.003 and a Max (P90) of 0.000, suggesting it is a very small budget share with many zeros. However, in Table 5, the RD estimate for Secondary Education at the 3,000 cutoff is -0.0022 with SE = 0.0025. In Table 9, the Pre-LRSAL estimate for Secondary Education is **-0.0119** (SE = 0.0096).
- **Why it is fatal:** A point estimate of -0.0119 (roughly a 1.2 percentage point drop) is impossible if the sample mean for that variable is only 0.003 (0.3 percentage points). A coefficient cannot be four times larger than the mean of a non-negative share variable in a direction that would imply a massive negative budget share for the treated group. This indicates either a scaling error in the regressions (e.g., using 0-100 for some and 0-1 for others) or a major data processing error.
- **Fix:** Verify the units of the dependent variables across all tables. Ensure that budget shares are defined consistently (either 0-1 or 0-100) and that regression coefficients are interpreted relative to the actual sample means.

**FATAL ERROR 2: Internal Consistency**
- **Location:** Table 1, page 10.
- **Error:** Statistical impossibility in the distribution. For the variables "Secondary Education," "University Education," and "Special Education," the Mean is positive (0.003, 0.001, 0.004 respectively), but the P90 (90th percentile) is reported as 0.000. 
- **Why it is fatal:** For a non-negative variable (budget shares), it is mathematically impossible for the mean to be greater than zero if the 90th percentile is zero, unless the remaining 10% of the data contains extreme values that would be visible in the SD. More importantly, the regression results in Table 5 and Table 9 report significant N-left and N-right counts (hundreds of municipalities) for these variables. If 90% of the data is zero, an RDD is likely invalid or the coefficients are artifacts of a few outliers.
- **Fix:** Re-calculate summary statistics. If these categories are truly 90% zeros, they should likely be excluded or aggregated, as an RDD on a variable that is almost entirely zero is not reliable.

**FATAL ERROR 3: Regression Sanity**
- **Location:** Table 4, page 15.
- **Error:** "Total Spending p.c. (EUR)" has a reported SD of 15,882.38 in Table 1, but the Covariate Balance test in Table 4 reports a point estimate of -145.53 with a Standard Error of **430.36**. 
- **Why it is fatal:** While not as large as the coefficient-to-SE limit, the text in Section 3.5 (page 10) admits to "extreme outliers" in this variable. In Table 1, the Mean is ~3,972 but the SD is ~15,882. Performing a linear RD on a variable where the SD is 4x the mean due to outliers without winsorizing or logging creates mechanically unreliable SEs and point estimates.
- **Fix:** Log-transform or winsorize per-capita spending variables before running balance tests to ensure outliers are not driving the sanity check.

**ADVISOR VERDICT: FAIL**