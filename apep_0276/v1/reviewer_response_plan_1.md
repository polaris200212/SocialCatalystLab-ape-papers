# Reviewer Response Plan

## Reviews Summary
- **GPT-5-mini:** MAJOR REVISION (main concern: DD/CS reconciliation, inference, composition accounting)
- **Grok-4.1-Fast:** MINOR REVISION (main concern: explicit CIs, CS decomposition, 3 literature additions)
- **Gemini-3-Flash:** MINOR REVISION (main concern: composition evidence, HonestDiD interpretation)
- **Exhibit Review:** Move Table 4 to appendix, add registration event study, simplify Figures 3/6
- **Prose Review:** Remove roadmap, improve data section opening, tighten contribution paragraphs

## Prioritized Workstreams

### WS1: Inference Strengthening (All reviewers)
- Add number of clusters to all regression tables
- Format p-values consistently
- Add note about explicit CIs (tables report SEs; figures show CIs)
- Add joint pre-trend F-test to event study discussion

### WS2: Composition Accounting (GPT, Gemini)
- Add back-of-envelope calculation: how many new registrants does restoration add?
- Use Sentencing Project estimates (~6M disenfranchised, ~3.5% of Black VAP) to bound the composition effect
- Show whether the implied composition change can mechanically explain the turnout decline

### WS3: DD/CS Reconciliation (GPT, Grok)
- Add explicit statement about preferred estimand (population-weighted)
- Better explain in Section 7.2 why weighting choices affect sign

### WS4: Prose Improvements (Prose review)
- Remove "paper proceeds as follows" roadmap
- Improve data section opening (lead with people, not data source)
- Tighten contribution section on p.3
- Punchier transitions

### WS5: Exhibit Improvements (Exhibit review)
- Move Table 6 (event study coefficients) to appendix
- Keep Figure 8 (Hispanic placebo) in main text (important falsification)
- Note: registration event study would require code changes; defer to revision

### WS6: HonestDiD Interpretation (Gemini)
- Be more explicit that CS turnout ATT is fragile (M~1 overturns)
- Emphasize registration is robust, turnout is sensitive to specification
