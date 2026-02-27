# Reviewer Response Plan

## Feedback Sources
- **GPT-5.2 (MAJOR REVISION)**: Treatment timing, downtown geography, control selection, count modeling, RI clarification, claim calibration
- **Grok-4.1-Fast (MINOR REVISION)**: Control selection transparency, heterogeneity, intensive margin, post-treatment joint test
- **Gemini-3-Flash (MINOR REVISION)**: Selection on dependent variable, matching ratio, intensive margin, treatment intensity
- **Exhibit Review**: Consolidate Table 5 into Table 3; promote Figure 6; label appendix table; simplify Figure 2 x-axis
- **Prose Review**: Delete roadmap; punch up abstract; active voice; real-world summary stats; standalone "pushing on a string"

---

## Workstream 1: Control Group Transparency [ALL 3 REVIEWERS — MUST FIX]

**Concern:** Control selection described vaguely ("similar characteristics"); no replicable algorithm.

**Fix:** Rewrite Section 4.4 to explicitly describe: nearest-neighbor matching on pre-2017 downtown establishment stock, total establishment stock, and population; same-département geographic restriction; 1:4 control-to-treated ratio constraint yielding 58 controls. Provide enough detail for replication.

## Workstream 2: Claim Calibration & Estimand Framing [GPT — MUST FIX]

**Concern:** Over-claiming "downtown revitalization" when outcome is commune-level; treatment timing uncertain.

**Fix:**
- Reframe abstract and conclusion: "no detectable effect on commune-level entry in downtown-facing sectors" rather than claiming ACV "did not work"
- Add explicit discussion of announcement vs implementation timing estimand in Section 5.1
- Acknowledge commune-level measurement dilution more prominently in Section 5.3.4 and Discussion
- Soften mechanism claims in Discussion

## Workstream 3: Statistical Model & Inference [GPT, GROK — MUST FIX]

**Concern:** Zero-heavy count outcome needs Poisson/PPML justification; log(1+y) not clarified; pre-trend joint F-test not reported; RI 222 vs 244 mismatch.

**Fix:**
- Add PPML (Poisson pseudo-ML) with commune + quarter FE as robustness column
- Add wild cluster bootstrap p-value as robustness
- Explicitly state log(1+y) transformation
- Report joint F-test statistic and p-value in event study section
- Clarify RI: permutes 244 (not 222) across eligible communes; fix text

## Workstream 4: Spillover Discussion [GPT, GROK]

**Concern:** Same-département controls risk contamination from spillovers.

**Fix:** Add subsection 5.3.5 "Potential Spillovers" discussing: same-département selection increases comparability but creates spillover risk; note that if ACV generates positive spillovers to nearby controls, the DiD is biased toward zero (conservative); acknowledge as limitation.

## Workstream 5: Exhibits [EXHIBIT REVIEW]

**Fix:**
- Consolidate Table 5 (Robustness) columns into Table 3 as columns 6-7, creating single comprehensive results table
- Promote Figure 6 (period coefficient plot) to main text; move Table 4 to appendix
- Label appendix sector classification as "Table A1"
- Keep Figure 2 x-axis as-is (quarters provide useful granularity for policy analysis)

## Workstream 6: Prose [PROSE REVIEW]

**Fix:**
- Delete roadmap paragraph from introduction
- Rewrite abstract mid-section to lead with English before stats
- Switch to active voice in Section 4.4
- Add real-world context to summary stats (what 0.23 means for a typical town)
- Make "pushing on a string" a standalone paragraph

## Workstream 7: Literature [GPT, GROK]

**Fix:** Add citations for:
- Kline and Moretti (2014, QJE) on local multipliers
- Ahlfeldt et al. (2015, ECMA) on agglomeration
- Silva and Tenreyro (2006, REStat) for PPML rationale (in robustness section)

## Not Addressed (Acknowledged as Limitations)

- **Downtown geography** (GPT): Would require geocoding Sirene addresses to define city-center polygons. This is a major data construction exercise beyond the scope of this revision. Acknowledged as limitation with suggestion for future work.
- **Convention signing dates for staggered DiD** (GPT): Data available in ACV dataset but analysis would require fundamentally different design. Acknowledged in discussion of estimand.
- **Treatment intensity/dosage** (GPT, Gemini): Would require ANCT/CDC/ANAH funding data not publicly available. Acknowledged as future work.
- **Synthetic control** (Grok): With 244 treated units, synthetic control is impractical. Noted.
- **McCrary density test** (Grok): Not applicable — selection was administrative, not score-based.

---

## Execution Order

1. R code changes: Add PPML, wild cluster bootstrap, report F-test → re-run scripts
2. LaTeX: Control group section rewrite
3. LaTeX: Claim calibration (abstract, intro, conclusion, discussion)
4. LaTeX: Statistical clarifications (log, F-test, RI)
5. LaTeX: Spillover discussion
6. LaTeX: Exhibit restructuring
7. LaTeX: Prose improvements
8. LaTeX: Literature additions
9. Recompile and visual QA
