# Revision Plan 1: Addressing External Reviewer Feedback

## Summary of External Reviews

- **GPT-5.2 (Reviewer 1):** Major Revision — compound treatment claims, 3,500 validation interpretation, fuzzy IV exclusion restriction, missing RDD references
- **Grok-4.1-Fast (Reviewer 2):** Minor Revision — missing RDD references, panel extension suggestion
- **Gemini-3-Flash (Reviewer 3):** Minor Revision — Besley et al. reference, spending classification

## Changes Made

### 1. Added Missing References
- Added Besley et al. (2017) "Gender Quotas and the Crisis of the Mediocre Man" — cited in Discussion
- Added citations to Imbens & Lemieux (2008) and Lee & Lemieux (2010) in methodology section

### 2. Compound Treatment Framing (Already Addressed in Advisor Iteration)
- All references to the 3,500 validation exercise have been rewritten as "exposure duration" comparisons, not clean parity isolation
- The main estimand is consistently framed as the "1,000-inhabitant electoral regime change"
- Fuzzy IV exclusion restriction caveats added

### 3. Reply to Reviewers
- Written in `reply_to_reviewers_1.md` with point-by-point responses

### 4. Items NOT Changed (and Rationale)
- **Panel extension:** Not feasible within scope — would require historical census vintages and RNE data from pre-2014 elections
- **Municipal crèche data:** Not available in the DGFIP accounting data
- **Functional spending classification:** Not consistently available for small communes in the downloaded dataset
- **Move exhibits to appendix:** Kept current layout — the diagnostic exhibits (McCrary, balance) support the identification in-text

## Verification
- Paper recompiles with no unresolved references
- All tables and figures are current
- 31 pages total, 25+ main text
- Advisor review: 3/4 PASS
- 3 external reviews completed
