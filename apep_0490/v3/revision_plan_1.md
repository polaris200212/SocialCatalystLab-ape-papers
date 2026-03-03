# Revision Plan 1

## Summary of Reviewer Feedback

Three external reviewers (GPT-5.2: Major Revision, Grok-4.1: Minor Revision, Gemini-3-Flash: Major Revision) plus internal review and exhibit/prose reviews provided feedback.

## Key Issues Addressed

### 1. Power and MDE Transparency (All reviewers)
- Added MDE discussion to abstract, introduction, and data section
- Made explicit that design can only detect effects >140% of baseline
- Framed null result with appropriate caveats about power limitations

### 2. Compound Treatment Framing (All reviewers)
- Changed title from "Does Visibility Delay Frontier AI?" to "Listing Position, Announcement Delay, and Frontier AI Adoption"
- Made explicit throughout that the cutoff bundles position improvement with announcement delay
- Clarified that "pure visibility effect" cannot be isolated without additional structure

### 3. Outcome Censoring (GPT-5.2)
- Changed "Any frontier citation (any horizon)" to "Any frontier citation (by early 2026)" with explicit right-censoring note
- Updated Cox model censoring to min(1,095 days, days to data end)
- Aligned temporal references (early 2025 → early 2026)

### 4. Data Flow and Sample Consistency (All reviewers)
- Added clear attrition description: 50,000 → 1,845 (matching) → 289 (±120 min) → 86 (MSE-optimal)
- Explained balance tests use unmatched metadata (larger N)
- Added Table 1 notes about control mean vs. full-sample mean differences

### 5. Prose and Presentation (Prose review)
- Rewrote opening paragraph (concrete timestamp example instead of cliché)
- More assertive null result framing
- Improved conclusion with specific policy implications

### 6. Missing Appendix Tables (GPT-5.2 advisor)
- Created Appendix Table A1: Placebo cutoffs (8 cutoffs + real)
- Created Appendix Table A2: Day-of-week heterogeneity
- Created Appendix Table A3: Polynomial × kernel sensitivity (9 specs)

## Issues Not Addressed (Scope Limitations)
- Cannot regenerate figures from v2 (would require re-running R code with actual data)
- Cannot expand sample beyond current matched papers
- Cannot add IV specification or fuzzy RDD without re-running analysis
