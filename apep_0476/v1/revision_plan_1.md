# Stage C Revision Plan

## Summary

Address feedback from tri-model referee panel (GPT-5.2: Major Revision, Grok-4.1-Fast: Minor Revision, Gemini-3-Flash: Minor Revision). All three reviewers praised the paper's scale, transparency, and descriptive contribution. Revisions focus on calibrating claims, adding scope disclaimers, and strengthening literature positioning.

## Changes

### 1. Calibrate Consistency Claims
- **Issue:** Abstract and Appendix G overstate cross-pair consistency as "100%" and claim "strong evidence of genuine matches"
- **Fix:** Change to "near-perfect (>99%)" in abstract; qualify Appendix G to note pipeline consistency vs external validation

### 2. Remove Causal Language
- **Issue:** Sections describing Great Depression and GI Bill effects use causal language inappropriate for a descriptive paper
- **Fix:** Replace "direct evidence of Depression's impact" → "consistent with Depression's disruption"; "capture the GI Bill's impact" → "captures patterns consistent with the GI Bill's effect"

### 3. Add Scope Disclaimer
- **Issue:** Reviewers want explicit acknowledgment that the paper is descriptive, not causal
- **Fix:** Add paragraph after threefold contribution statement: "This paper is descriptive... we do not attempt to identify causal effects"

### 4. Add Mortality Decomposition Caveat
- **Issue:** GPT-5.2 and Gemini reviewers both flag that link rates confound algorithmic performance with mortality/emigration
- **Fix:** Add paragraph in Section 3 (link rates) explaining that forward-link shares reflect both mortality and algorithm performance, and recommending life table adjustment for causal work

### 5. Strengthen Literature Positioning
- **Issue:** Missing citations to key linking-bias and mobility measurement papers
- **Fix:** Add Mill 2020 citation in IPW section; add Feigenbaum 2018 citation in introduction for Iowa 1915-1940 mobility context

### 6. Fix ABE Comparison Text
- **Issue:** Text in multiple places says "three decade pairs" but Table 4 only uses two adjacent pairs (1920→1930, 1930→1940); the 1920→1940 pair is not directly comparable
- **Fix:** Already corrected in advisor round — verify consistency
