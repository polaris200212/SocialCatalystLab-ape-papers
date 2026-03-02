# Reviewer Response Plan — Stage C

## Feedback Sources
- GPT-5.2 (Reject & Resubmit)
- Grok-4.1-Fast (Major Revision)
- Gemini-3-Flash (Major Revision)
- Exhibit review (Gemini)
- Prose review (Gemini)
- Internal review (Claude Code)

## Grouped Concerns and Response

### 1. Identification / Pre-Trends (ALL reviewers)
**Concern:** Single pre-period (2018/19) makes pre-trends untestable. Event study cannot distinguish treatment from differential trends.
**Response:** Add honest discussion of this limitation. Relabel as "baseline exposure × year interactions" not "event study." Our data has Attainment 8 for more years — note this limitation but explain Progress 8 is preferred outcome.

### 2. Bartik IV Exclusion (ALL reviewers)
**Concern:** Trend × share is not a standard shift-share. Exclusion likely violated — industry composition predicts local prosperity.
**Response:** Add IV falsification test (instrument on pre-2018 Attainment 8 or non-teacher outcomes). Add region×year FE to IV specification. Report reduced form. Discuss sensitivity.

### 3. Region×Year FE and Controls (GPT, Grok)
**Concern:** Correlated local shocks not controlled. Need region×year FE.
**Response:** Re-estimate main spec with region×year FE. Report as robustness.

### 4. London Effect (ALL reviewers)
**Concern:** Results may be driven by London vs. North divide.
**Response:** Add exclude-London robustness check for main spec and event study.

### 5. Academy DDD Not Credible (GPT, Gemini)
**Concern:** Cross-sectional, not a DDD, confounded by geography.
**Response:** Move to appendix (per exhibit review). Demote from "mechanism" to "descriptive pattern."

### 6. Mechanism Weakness (ALL reviewers)
**Concern:** Vacancy data imprecise. Need teacher retention/turnover.
**Response:** Acknowledge limitation. SWC individual-level data not available in this analysis. Note as important direction for future work.

### 7. IV Magnitude (Gemini, GPT)
**Concern:** IV estimate (1.245) is enormous — 50x OLS.
**Response:** Add explicit economic magnitude discussion. A realistic 0.05 within-LA change → 0.06 Progress 8 points. Discuss LATE interpretation.

### 8. Causal Claim Calibration (ALL reviewers)
**Concern:** Paper leans too heavily on causal interpretation.
**Response:** Reframe throughout as "descriptive evidence + suggestive patterns" rather than definitive causal. Tone down conclusion.

### 9. Exhibit Streamlining (Exhibit review)
**Response:** Move DDD table/figure, LOOR figure, RI figure to appendix. Add reduced form to IV table. Remove redundant LOOR appendix table.

### 10. Prose Improvements (Prose review)
**Response:** Fix table narration in Results (kill "Column X shows"). Simplify contribution paragraph.

## Execution Order
1. R code changes: region×year FE, exclude London, IV falsification, reduced form
2. Re-run analysis scripts
3. Paper.tex: move exhibits to appendix, relabel event study, tone down claims, fix prose
4. Recompile and verify
