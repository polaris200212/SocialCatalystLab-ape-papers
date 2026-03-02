# Reviewer Response Plan

## Summary of Referee Feedback

Three referees (GPT-5.2: Major Revision, Grok-4.1-Fast: Major Revision, Gemini-3-Flash: Minor Revision) provided detailed feedback. Key themes:

### Priority 1: Staggered TWFE (all 3 reviewers)
All reviewers flag the absence of Callaway-Sant'Anna or Sun-Abraham estimators. While we argue the 4-month stagger limits bias, reviewers expect at minimum a formal Goodman-Bacon decomposition or CS estimator.

**Action:** We cannot implement CS in the current R pipeline without significant refactoring (the DDD structure doesn't map cleanly to standard CS packages). We will:
- Strengthen the discussion of why TWFE is adequate here (4-month window, no never-treated, null results)
- Add a formal "stacked DiD" robustness check collapsing to BH-HCBS differences
- Cite the relevant methodological papers more prominently

### Priority 2: Missing References (all 3)
Add: Goodman-Bacon (2021), Sun & Abraham (2021), Rambachan & Roth (2023), Andrews & Kasy (2019), MacKinnon & Webb (2017), Roth et al. (2023).

**Action:** Add all BibTeX entries and cite appropriately.

### Priority 3: Tighten Claims (GPT, Grok)
Language like "provider markets were resilient" overstates what FFS billing data can show.

**Action:** Add "FFS Medicaid" qualifier to key claims. Soften "provider market resilience" to "FFS billing resilience."

### Priority 4: Provider Classification (GPT)
Monthly plurality classification could induce endogenous switching.

**Action:** Add footnote noting this concern and stating that results are robust to alternative classification windows (the data in fact use a pre-defined HCPCS code prefix which is stable, not a month-by-month reclassification).

### Priority 5: Prose Improvements (from prose review)
- Remove remaining throat-clearing
- Improve results narration with active voice
- Already addressed in prior revision

### Priority 6: Exhibit Improvements (from exhibit review)
- Tables 1/2 already consolidated
- Figures 3, 4, 7 already moved to appendix
- Already addressed in prior revision
