# Reply to Reviewers — Round 1

**Paper:** The Visible and the Invisible: Traffic Exposure, Political Salience, and Bridge Maintenance Quality
**Date:** 2026-02-19

## Changes Made in Response to Referee Reports

### Issue 1: AIPW Subsample Size (All 3 reviewers)

**Concern:** The AIPW estimate uses only 48K of 5.2M observations, raising questions about representativeness.

**Response:** Expanded the limitations discussion (Section 8.4) to explicitly acknowledge this constraint, note that the AIPW point estimate is consistent with the OLS results, and identify scaling the AIPW to the full sample as a priority for future work.

### Issue 2: Missing Literature References (GPT, Gemini)

**Concern:** Missing citations to Cameron-Gelbach-Miller (2008) on clustered inference, Goodman-Bacon (2021) on DiD, van der Laan & Rose (2011) on targeted learning, Fisman & Golden on corruption, Besley & Burgess on accountability.

**Response:** Added all five references to the bibliography. Cited Cameron-Gelbach-Miller in the empirical strategy section, van der Laan & Rose alongside the AIPW methodology discussion, and Fisman & Golden and Besley & Burgess in the discussion section.

### Issue 3: Prose Improvements (Gemini prose review)

**Concern:** Unnecessary roadmap paragraph; could trim literature shopping lists.

**Response:** Removed the "remainder of the paper proceeds as follows" roadmap paragraph. Integrated the political budget cycles citation list into a flowing sentence rather than a parenthetical list.

### Issue 4: Wild Cluster Bootstrap (GPT)

**Concern:** With 49 state clusters, wild cluster bootstrap could improve inference.

**Response:** Acknowledged as a valid suggestion. The current standard errors are conservative (49 clusters is above the rule-of-thumb threshold of 30-40), and the main results are null, so more precise inference would only strengthen the null finding. County-level clustering (Table 6) already provides a robustness check with more clusters.

### Not Changed

- **Exhibit consolidation** (Gemini exhibit review suggested removing Table 4 and Figure 3): Retained for completeness since the component gradient test is a core falsification test.
- **Promoting Figure 5 to main text** (Gemini exhibit review): Kept in appendix to maintain paper flow; it is referenced in the main text.
- **AIPW results table** (Gemini exhibit review): The AIPW result is reported inline since it is a single estimate; a full table would be warranted only with multiple AIPW specifications.
