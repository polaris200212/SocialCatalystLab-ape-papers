# Advisor Review - Gemini-3-Flash

**Role:** Academic advisor checking for fatal errors
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-13T13:28:27.459418
**Route:** Direct Google API + PDF
**Tokens:** 16758 in / 845 out
**Response SHA256:** f044dc26e2b5e108

---

I have reviewed the draft paper "Registered but Not Voting: Felon Voting Rights Restoration and the Limits of Civic Re-Inclusion" for fatal errors.

**ADVISOR REVIEW**

**FATAL ERROR 1: Data-Design Alignment**
- **Location:** Table 2 (page 11) and Abstract (page 1).
- **Error:** The paper claims to study the effects of reforms in 2024 (Minnesota and New Mexico are listed as "First Election 2024"). However, the CPS Voting Supplement is conducted in November. Because the paper was written/dated February 13, 2026, the 2024 data likely exists, but the "First Election" for New Mexico is listed as 2002 on page 11, while the text on page 4 says reforms span to 2024 (Minnesota, New Mexico).
- **Fix:** Ensure the state list in Table 2 correctly identifies which states are 2024 cohorts. If New Mexico was treated in 2002, the text on page 4 is incorrect. If it was 2024, Table 2 is incorrect.

**FATAL ERROR 2: Internal Consistency (Direction of Results)**
- **Location:** Abstract (page 1) vs. Table 3 (page 16) vs. Table 4 (page 18).
- **Error:** The Abstract states "the Black-White turnout gap widens by 3.7 percentage points." In Table 3, the coefficient is -0.0373, which (given the outcome is Black minus White) indeed means the gap widened. However, Table 4 and Figure 5 show the Callaway-Sant'Anna overall ATT as **+0.0532**. Section 7.2 acknowledges this "sign discrepancy" but does not resolve the fact that the two primary estimators of the paper provide opposite conclusions on the direction of the policy effect (one says the gap widened, the other says it narrowed/closed).
- **Fix:** A sign flip of this magnitude between the main DD and the CS estimator suggests a fundamental data processing error or a weighting failure. You must reconcile why the staggered DiD estimator shows a 5.3pp improvement while the OLS shows a 3.7pp decline.

**FATAL ERROR 3: Regression Sanity / Internal Consistency**
- **Location:** Table 3, Column 3 (page 16).
- **Error:** The observation count (N) is **1,375**. In all other columns of the same table, N is **1,370**. The footnote states this is because "additive FE do not drop singleton cells," but adding fixed effects should not increase the sample size; it should, at most, reduce the effective sample size. If 5 observations are missing from the other columns, they should be identified and removed from Column 3 to maintain a consistent sample.
- **Fix:** Standardize the sample size across all columns of Table 3.

**FATAL ERROR 4: Completeness**
- **Location:** Section 6.4 (page 17) and Table 4 (page 18).
- **Error:** The text in Section 6.4 references "event times -6, -4, and -2" and "0, +2, +4, and +6." However, Figure 5 and Table 4 show coefficients for these points. The "Sun-Abraham" analysis mentioned in Appendix C.1 (page 29) states "collinearity issues noted in the output... limit the precision," but the actual results for the Sun-Abraham estimator are not reported anywhere in the paper.
- **Fix:** Include the Sun-Abraham results table if they are used as a robustness check, or remove the claim that they produce qualitatively similar results if the output is too broken to show.

**ADVISOR VERDICT: FAIL**