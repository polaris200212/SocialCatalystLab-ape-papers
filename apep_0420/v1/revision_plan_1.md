# Revision Plan — Round 1

**Paper:** The Visible and the Invisible: Traffic Exposure, Political Salience, and Bridge Maintenance Quality
**Date:** 2026-02-19

## Sources of Feedback

- GPT-5.2 referee review (MAJOR REVISION)
- Grok-4.1-Fast referee review (MINOR REVISION)
- Gemini-3-Flash referee review (MINOR REVISION)
- Internal Claude Code reviews (rounds 1-2)
- Gemini prose review
- Gemini exhibit review

## Priority 1: Address AIPW Subsample Concern (All 3 reviewers)

**Issue:** The AIPW estimate uses only 48K of 5.2M observations. Reviewers question representativeness and external validity.

**Plan:** Expand limitations discussion (Section 8.4) to explicitly acknowledge the subsample constraint, note consistency between AIPW and OLS point estimates, and identify scaling the AIPW to the full sample as a future work priority.

## Priority 2: Add Missing Literature Citations (GPT, Gemini)

**Issue:** Missing references to Cameron-Gelbach-Miller (2008) on clustered inference, Goodman-Bacon (2021) on DiD, van der Laan & Rose (2011) on targeted learning, Fisman & Golden on corruption, Besley & Burgess on accountability.

**Plan:** Add all five references to `references.bib`. Cite Cameron-Gelbach-Miller in the empirical strategy section, van der Laan & Rose alongside AIPW methodology, and Fisman & Golden and Besley & Burgess in the discussion.

## Priority 3: Prose Improvements (Gemini prose review)

**Issue:** Unnecessary roadmap paragraph; literature citation lists read as shopping lists.

**Plan:** Remove the "remainder of the paper proceeds as follows" paragraph. Integrate political budget cycles citation list into a flowing sentence.

## Priority 4: Wild Cluster Bootstrap Discussion (GPT)

**Issue:** With 49 state clusters, wild cluster bootstrap could improve inference.

**Plan:** Acknowledge as valid in limitations. Note that 49 clusters exceeds rule-of-thumb threshold (30-40), main results are null (stronger inference would reinforce null), and county-level clustering (Table 6) already provides a robustness check.

## Not Planned

- **Exhibit consolidation** (removing Table 4 / Figure 3): Retain — component gradient test is a core falsification exercise.
- **Promoting Figure 5 to main text**: Keep in appendix to maintain paper flow.
- **AIPW results table**: Single estimate reported inline; full table warranted only with multiple specifications.
