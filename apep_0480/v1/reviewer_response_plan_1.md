# Reviewer Response Plan (Stage C)

## Summary of Feedback

**Decisions:** GPT-5.2 REJECT AND RESUBMIT | Grok-4.1-Fast MAJOR REVISION | Gemini-3-Flash MAJOR REVISION

### Grouped Concerns

**1. Post-treatment density variable (ALL 3 reviewers, #1 issue)**
- Treatment measured from current (post-closure) register, not pre-policy
- Could induce non-classical measurement error
- GPT: "first-order design flaw"; Grok: "unverified"; Gemini: "Must-fix"
- **Response:** Cannot obtain historical GC data in this session. Strengthen acknowledgment, remove "first causal estimates" claim, add explicit section on this limitation. Note as top priority for future revision.

**2. Property price causal claims too strong (GPT, Grok)**
- GPT: "unambiguous" and "strong evidence" over-claimed given design
- Need event study / placebos for prices (GPT must-fix #3)
- Grok: "causal language overstates without density-specific placebos"
- **Response:** Tone down causal language for property prices. Add caveats about COVID/urban cycle confounding. Note event study as future work (requires code changes beyond scope of this revision cycle).

**3. COVID confound (ALL 3)**
- Post-period bundles policy + COVID + urban trends
- GPT: restrict to pre-COVID window or richer controls
- **Response:** Already have COVID exclusion and interaction. Add stronger caveat language.

**4. Multiple testing (GPT)**
- Many crime categories without FDR correction
- **Response:** Add brief note on multiple testing in robustness section.

**5. Mechanism data missing (Grok, Gemini)**
- No vacancy rates, employment, footfall data to test channels
- **Response:** Label mechanism discussion as speculative; note as future work.

### Exhibit Workstream
- Add significance stars to Table 2 (crime results)
- Add "Mean Dep. Var." row to Table 2
- Move balance table (Tab 8) to main text
- Move dose-response (Fig 3/fig:dose) to appendix
- Note: COVID annotation in figures would require re-running R code; skip for this cycle

### Prose Workstream
1. Collapse Data subsections (3.1-3.6) into flowing paragraphs
2. Remove roadmap paragraph from Introduction
3. Lead with honest null in intro, not caveats
4. Humanize magnitudes ("A typical neighborhood with three betting shops...")
5. Reduce "specification" and "statistically significant" usage
6. Move headline property price magnitude earlier in results

### What We Will NOT Change
- Core identification strategy (no historical data available)
- R code / figures (too risky at this stage; reserved for future revision)
- DR-DiD methodology
- Core results or numbers

## Execution Order
1. Prose: Rewrite Data section, Introduction, Results narration
2. Exhibits: Add stars to Table 2, mean dep var row, promote balance table
3. Language: Calibrate property price claims, remove "first causal" language
4. Structure: Move dose-response to appendix, remove roadmap
5. Recompile and verify
