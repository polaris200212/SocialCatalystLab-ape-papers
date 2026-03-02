# Advisor Review - Gemini-3-Flash

**Role:** Academic advisor checking for fatal errors
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-24T16:09:39.347689
**Route:** Direct Google API + PDF
**Paper Hash:** 610720adf1dde3bf
**Tokens:** 22478 in / 685 out
**Response SHA256:** ee4ac913d9ead315

---

I have reviewed the draft paper "Criminal Politicians and the Composition of Local Development: Evidence from Close Elections in India" for fatal errors.

**FATAL ERROR 1: Internal Consistency (Claims vs. Evidence)**
- **Location:** Table 3 (page 17) and Figure 4 (page 38).
- **Error:** The text on page 3 and page 17 describes a "significant reduction in commercial bank presence" with an estimate of $\hat{\tau} = -0.134$ and $p = 0.019$ (Table 3, Column 2). However, Figure 4 (page 38), which plots these same RDD estimates for village amenities, shows the point estimate for "Commercial Banks" as **positive** (above 0.0) and explicitly labels it as "**n.s.**" (not significant) via the color key.
- **Fix:** Ensure the figure generation code matches the regression table. If the effect is significantly negative as claimed in the text, Figure 4 must show a negative point estimate with a confidence interval that does not cross zero.

**FATAL ERROR 2: Internal Consistency (Claims vs. Evidence)**
- **Location:** Figure 7 (page 41) vs Table 2 (page 15).
- **Error:** In Table 2, Column 2 (preferred specification), the sample size is $N = 2,034$ with an effective $N$ of $1,780$ ($843 + 937$). However, Figure 7 ("Heterogeneity in the Effect of Criminal Politicians") labels the "Full Sample" as having an **Eff. N = 1249**. This is a massive discrepancy in the number of observations used for the primary result.
- **Fix:** Reconcile the sample sizes. If Figure 7 is using a different bandwidth or subset, it must be clearly stated; otherwise, the effective $N$ should match the main results table.

**FATAL ERROR 3: Data-Design Alignment**
- **Location:** Section 4.3 (page 9) and Table 15 (page 37).
- **Error:** The paper defines the treatment window as "up to 5 years, capped at 2013." For the "2009–2012" cohort in Table 15, elections in 2011 and 2012 would have only 1–2 years of post-treatment data before the satellite series ends. While not strictly impossible, the paper identifies a "13–17 percentage point" increase in growth. If the growth is calculated as (Post-Pre)/Pre, and the "Post" period for a 2012 election is only the year 2013, the timing is extremely tight to capture a 17% shift in infrastructure-driven light.
- **Fix:** Clarify in Table 15 exactly how many post-treatment years are available for the 2011 and 2012 cohorts and ensure the "growth" calculation is not biased by the varying window lengths.

**ADVISOR VERDICT: FAIL**