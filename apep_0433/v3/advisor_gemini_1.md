# Advisor Review - Gemini-3-Flash

**Role:** Academic advisor checking for fatal errors
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-21T22:21:15.978251
**Route:** Direct Google API + PDF
**Tokens:** 22478 in / 654 out
**Response SHA256:** 39130cc0b28a4027

---

I have reviewed the draft paper for fatal errors that would preclude submission to a journal.

**FATAL ERROR 1: Data-Design Alignment**
- **Location:** Section 3.1 (Data Sources) and Table 1 (Summary Statistics).
- **Error:** The paper claims to study the effects of the 2020 municipal election (2020–2026 mandate). However, the primary labor market outcomes are sourced from the **INSEE RP2021** census vintage, which the text admits (page 6) covers the **2018–2022 survey cycles**. Furthermore, the text states that **40% of the observations were collected in 2018–2019**, which is *before* the 2020 treatment occurred. 
- **Fix:** You cannot use a 2018-2022 rolling average as a "post-treatment" outcome for a 2020 treatment, as nearly half the data is pre-treatment. You must either restrict the sample to the 2021-2022 survey cycles (if commune-level identification is possible) or use data that post-dates the mandate commencement for all observations.

**FATAL ERROR 2: Regression Sanity**
- **Location:** Table 7 (Fuzzy RD-IV), page 31.
- **Error:** The Standard Error for "Female LFPR (IV)" is **1.0904**. As stated in Section 4.3, all rate/share variables are on a 0–1 scale. An SE of 1.09 means the standard error is larger than the entire possible range of the dependent variable. This indicates a total failure of the IV specification (likely due to an underpowered first stage, as the text admits).
- **Fix:** While the text includes a disclaimer, reporting a coefficient where the SE exceeds the logical bounds of the data (0–1) is a regression sanity failure. Remove the IV table or use a method suited for weak instruments; do not report results with SE > 1.

**FATAL ERROR 3: Internal Consistency**
- **Location:** Abstract (page 1) vs Table 1 (page 9) and Section 5.1 (page 12).
- **Error:** The Abstract states the regime change increases female councillor share by **2.74 percentage points**. However, Table 1 shows the mean female councillor share is **36.9%** below the threshold and **47.7%** above—a raw difference of **10.8 percentage points**. While 2.74 is the RDD local estimate, the abstract presents it as the primary descriptive result of the "regime change," creating a massive discrepancy for a reader looking at the Summary Statistics.
- **Fix:** Clarify the distinction between the raw difference in Table 1 and the RD estimate in the Abstract to ensure the numbers cited "match" the evidence presented in the tables.

**ADVISOR VERDICT: FAIL**