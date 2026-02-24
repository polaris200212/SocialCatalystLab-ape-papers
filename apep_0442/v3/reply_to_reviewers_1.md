# Reply to Reviewers — apep_0442 v3

## Summary of Changes

This revision addresses the concerns raised by three external referees (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash) and two internal reviews. The major changes are:

1. **Falsification bandwidth sensitivity (new Appendix Table A3):** Tests the pre-treatment LFP(1900) discontinuity across bandwidths 2-15 years. Results show the falsification passes at narrow bandwidths (2-3 years, p>0.14) but fails at wider bandwidths (4+ years, p<0.04). This finding is discussed prominently in Section 10.3.

2. **Unified inference framework:** All tables now consistently report conventional coefficients with robust standard errors, and p-values computed as 2*pnorm(-|coef/SE|). Table notes have been audited for consistency.

3. **Missing references added:** Armstrong & Kolesár (2020), Lee & Card (2008), Behaghel & Blau (2012).

4. **"Definitive" claims toned down:** Changed to "substantially more informative" in abstract and introduction.

5. **Covariate balance p-values fixed:** Table 2 now uses consistent p-values (coef/robust SE).

6. **Pre-treatment concern strengthened:** Section 10.4 references the new falsification bandwidth table and explicitly links the bandwidth sensitivity of the main results to the falsification pattern.

---

## Point-by-Point Responses

### Reviewer 1 (GPT-5.2): MAJOR REVISION

**1. Pre-treatment discontinuity (p=0.067).**
- **Response:** We now present a comprehensive falsification bandwidth sensitivity analysis (Appendix Table A3). The falsification passes at the MSE-optimal bandwidth (p=0.143 at BW=2, p=0.347 at BW=3) but fails at wider bandwidths (p<0.04 at BW=4+). We have updated Section 10.3 to explicitly note that this pattern explains the bandwidth sensitivity of the panel RDD — the significance at wider bandwidths likely reflects composition differences. We believe this transparent presentation strengthens the paper.

**2. Inconsistent inference framework.**
- **Response:** All tables now uniformly report conventional coefficients with robust standard errors and p-values computed as z = estimate/SE. Table notes have been audited for consistency. The distinction between rdrobust approaches is clarified in the empirical strategy section.

**3. Discrete running variable.**
- **Response:** We cite Lee & Card (2008) on specification error with discrete running variables. The randomization inference (Table 7) provides finite-sample valid p-values following Cattaneo, Frandsen, & Titiunik (2015). A full local randomization RD implementation is noted as a direction for future work.

**4. Covariate imbalance.**
- **Response:** Covariate-adjusted specifications are already reported as companion estimates in Table 4. The balance table (Table 2) now has consistent p-values and sample sizes per row. We note that literacy and homeownership imbalance at narrow bandwidths (1.3 and 3.3 years respectively) reflects different MSE-optimal windows rather than a uniform imbalance problem.

### Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

**1. Pre-treatment discontinuity robustness.**
- **Response:** See response to GPT #1. The new falsification bandwidth table (A3) directly addresses this request.

**2. "Definitive" overclaiming.**
- **Response:** Changed to "substantially more informative" throughout.

**3. Table note inconsistencies.**
- **Response:** All table notes now explicitly state the inference framework (conventional estimates, robust SE, z-based p-values).

**4. Trim version comparison.**
- **Response:** Acknowledged as a reasonable suggestion; the comparison table in Section 10.5 is retained as it helps readers understand the value-added of the Costa data, but could be moved to appendix in a future revision.

### Reviewer 3 (Gemini-3-Flash): MINOR REVISION

**1. Pre-treatment imbalance biases results.**
- **Response:** We now quantify this more precisely via the falsification bandwidth table. The falsification coefficient (~0.13 at wider bandwidths) is positive, meaning veterans below 62 had *higher* LFP in 1900. If this represents mean reversion, it would bias the panel RDD toward finding a negative effect. We discuss this explicitly in Section 10.4.

**2. Cite Behaghel & Blau (2012).**
- **Response:** Added to the literature review (Section 3).

**3. Clarify "definitive" relative to p=0.165.**
- **Response:** Changed language to "substantially more informative evaluation" throughout.

---

## Not Addressed (Noted for Future Work)

- **Local randomization RD implementation** (GPT suggestion): Acknowledged as valuable; would require substantial additional code infrastructure. Current RI provides related inference.
- **1920 Census linkage** (Gemini suggestion): Not available in the Costa Union Army dataset. Would require additional archival data collection.
- **Subsample to "no prior pension" veterans** (Grok suggestion): Current subgroup analysis includes this split (Table 8, "No pension (pre-1907)"). The estimate is 0.017 (p=0.703), indicating no detectable effect among this group.
