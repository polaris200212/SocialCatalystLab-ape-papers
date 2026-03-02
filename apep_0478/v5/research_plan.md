# Revision Plan: apep_0478 v3 — The Real Structural Overhaul

## Context

v2 was supposed to reframe the paper away from causal SCM claims toward descriptive economic history centered on individual transitions. It failed: the abstract still opens with the 1945 strike, the SCM is still a main-text section (Section 6), and the paper still frames itself as quasi-causal. The user explicitly directed: "the whole causal emphasis needs to go away."

v3 executes what v2 promised. The paper's identity becomes: **definitive descriptive economic history of the only fully automated occupation**, with individual-level linked transitions as the analytical core.

## Structural Goals (for Stage 0 Verification Gate)

| # | Goal | v2 Status | v3 Target |
|---|------|-----------|-----------|
| 1 | Abstract opens with adoption puzzle / workers, not strike | FAILED | Opens with the 40-year puzzle or the 38,562 workers |
| 2 | SCM section moved to appendix | FAILED | SCM in appendix only |
| 3 | No causal language about strike | FAILED | All causal claims removed |
| 4 | Individual transitions = unambiguous core | PARTIAL | Sections 4-5 are ~60% of main text, framed as the contribution |
| 5 | Paper identity = descriptive economic history | FAILED | Descriptive throughout |
| 6 | Intro frames 3 contributions without causal claim | FAILED | 3rd contribution = NYC paradox as descriptive finding |

## Workstreams

### WS1: Rewrite Abstract
Open with adoption puzzle, not strike. 150 words max.

### WS2: Rewrite Introduction
Keep strike scene as hook, pivot immediately to puzzle. Reframe 3 contributions.

### WS3: Restructure Sections
Move SCM to appendix. New structure: Intro, Background, Data, Lifecycle, Transitions, Robustness, Discussion, Conclusion.

### WS4: Kill Causal Language
Remove all "causal effect of the strike", "treatment", "post-treatment" from main text.

### WS5: Rewrite Discussion Lesson 3
"Institutional embeddedness predicts displacement speed" — descriptive, not causal.

### WS6: Rewrite Conclusion
NYC paradox framed descriptively. Land on distributional finding.

### WS7: Update Appendix
Move SCM to Appendix B with brief descriptive framing.

## R Code Changes
None. Analysis unchanged — only paper framing changes.

## Exposure Alignment (Descriptive)

**Who is studied:** U.S. elevator operators (OCC1950 = 761) in full-count census microdata, 1900-1950.

**Primary estimand population:** 38,562 elevator operators linked from 1940 to 1950 via MLP v2.0, compared to ~445,000 linked building service workers.

**Comparison group:** Building service workers (janitors, porters, guards) who did not face direct automation during 1940-1950.

**Design:** Descriptive lifecycle analysis + individual-level conditional associations (NOT causal). State-level synthetic control presented as corroborating appendix evidence only.
