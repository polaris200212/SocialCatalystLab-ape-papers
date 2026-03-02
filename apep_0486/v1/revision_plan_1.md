# Revision Plan 1 — Stage C Response to Referee Reviews

## Summary of Feedback
All 3 referees: MAJOR REVISION. Gemini advisor: FAIL (round 5).

## Changes Organized by Priority

### Must-Fix (paper.tex)

1. **Remove placeholder timing text** from author footnote (Gemini advisor Fatal Error 2)
2. **Make CS-DiD the primary estimand** in abstract/narrative; demote TWFE to "benchmark" (GPT, Grok, Gemini all flag -179 vs -406 divergence)
3. **Add Bacon decomposition discussion** explaining what drives TWFE-CS divergence (GPT §1.3, Gemini §2)
4. **Downgrade homicide claims further** — abstract still says "no increase" but should say "inconclusive"; remove "achieves public safety goals" framing entirely (GPT §5.1, Grok §5)
5. **Add cluster counts** to all table notes (GPT §2.1)
6. **Harmonize data coverage years** — treatment coding should extend to 2024 for homicide sample, or homicide sample should be flagged as including one year post-treatment-coding (Gemini advisor Fatal Error 4)
7. **Add sample construction flow** explaining N drop from 52,704 to 30,039 (GPT §2.2)
8. **Strengthen treatment coding appendix** with explicit criteria checklist (GPT §1.1, Grok)
9. **Fix cost-benefit section** — use population-weighted estimate or add uncertainty bounds (GPT §5.4)

### High-Value Improvements (paper.tex)

10. **Add pretrial vs sentenced mechanism discussion** — describe compositional evidence from available Vera data (GPT §3.3, Grok, Gemini)
11. **Discuss matched controls as limitation** — acknowledge urban-rural imbalance and note robustness to state×year FE as partial mitigation (GPT §1.2)
12. **Add population-weighted CS-DiD** mention or acknowledge its absence (GPT §2.3)
13. **Add multiple testing discussion** (GPT §2.4)
14. **Discuss spillovers** briefly (GPT §3.2)

### Not Addressing (with rationale)
- Full synthetic control/SDID implementation: Would require major new analysis; discuss as future work
- FBI UCR/NIBRS longer homicide series: Data acquisition beyond scope of this revision; note as limitation
- Randomization inference: Note as robustness for future work
- Log jail rates / IHS functional form: Robustness check noted for future work
