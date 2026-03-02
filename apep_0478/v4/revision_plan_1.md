# Revision Plan — Stage C

## Reviews Received
- **GPT-5.2:** Major Revision
- **Grok-4.1-Fast:** Minor Revision
- **Gemini-3-Flash:** Minor Revision
- **Internal (Claude Code):** Minor Revision
- **Exhibit Review:** Constructive feedback
- **Prose Review:** Constructive feedback

## Key Issues Identified Across All Reviews

### 1. Causal vs. Descriptive Claims (GPT, Grok)
**Issue:** Paper implies causal mechanisms (institutional thickness "slowed" automation, discourse "preceded" decline) without credible identification.
**Action:** Rewrite all mechanism claims as suggestive/consistent-with rather than causal. Add explicit caveats in abstract, introduction, newspaper section, and discussion.

### 2. Comparison Group Exit Rate Benchmark (Internal, GPT)
**Issue:** The 84% exit rate is meaningless without context. Data shows janitors (81%), porters (83%), and guards (84%) had nearly identical exit rates.
**Action:** Add comparison rates directly in Section 6.1. Reframe the story from "whether they left" to "where they went."

### 3. Summary Statistics Table (Internal, Exhibit)
**Issue:** No summary statistics for the linked panel.
**Action:** Generate and include Table 0 with means/SDs for operators vs. comparison workers.

### 4. "First" Occupation Language (GPT)
**Issue:** Claim of "first occupation fully eliminated" is contestable (switchboard operators, lamplighters, etc.).
**Action:** Soften to "one of the clearest cases."

### 5. IPW Discrepancy (GPT)
**Issue:** OCCSCORE change shifts from -0.132 (ns) to -0.342*** under IPW — contradicts "substantively unchanged" claim.
**Action:** Acknowledge honestly, explain why reweighting changes the estimate, note that unweighted is conservative.

### 6. Involuntary Displacement (GPT)
**Issue:** Cannot distinguish voluntary from involuntary exits in linked data.
**Action:** Soften language throughout. Note the similar exit rates across all building service occupations.

### 7. Newspaper Validation (GPT)
**Issue:** LLM-based classification without validation statistics.
**Action:** Add caveat about reproducibility. Note findings hold with high-signal KEEP articles only.

### 8. Regression Specifications (GPT)
**Issue:** Estimating equations not fully specified.
**Action:** Add explicit equation with covariates, FE, and cluster information.

### 9. WWII Confounding (GPT)
**Issue:** 1940-1950 includes massive labor market disruption.
**Action:** Add WWII acknowledgment in limitations. Note comparison group helps separate occupation-specific from macro patterns.

### 10. Roadmap Paragraph (Prose, Internal)
**Issue:** "The paper proceeds as follows" is unnecessary.
**Action:** Delete.

### 11. Abstract Length
**Issue:** Was over 150 words after revisions.
**Action:** Trim to exactly 150 words.

## Changes NOT Made (and Why)

- **Wild cluster bootstrap** (GPT): Would require rerunning R scripts with substantial computation. With 49 state clusters, conventional CRVE is standard in the field. Noted as limitation.
- **Building-code event study** (GPT): Would require new data collection (code reform dates) beyond the scope of this revision.
- **Move SCM to main text** (Grok): The SCM has acknowledged weaknesses (4 pre-periods, state-level aggregation); keeping it in the appendix is the right choice.
- **Labor cost data** (Gemini): IPUMS INCWAGE is poorly measured in 1940/1950 full-count data. Would not be reliable.
- **Newspaper sentiment analysis** (Gemini): Classification pipeline produced UNCLASSIFIED results; thematic analysis not feasible for this version.
