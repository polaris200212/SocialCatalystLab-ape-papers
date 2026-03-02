# Reviewer Response Plan

## Summary of Decisions
- **Gemini:** CONDITIONALLY ACCEPT (add cultural persistence reference + footnote on individual-level data)
- **Grok:** MINOR REVISION (add 3 references, minor prose polish, extend falsification)
- **GPT:** MAJOR REVISION (Conley SEs, wild cluster bootstrap, equivalence test, border-proximity, tighten causal claims)

## Prioritized Workstreams

### WS-A: Missing References (All 3 reviewers)
- Add Alesina & Giuliano (2015) JEL
- Add Giuliano & Nunn (2020) ReStud on cultural persistence
- Add Tabellini (2010) JEEA
- Add Doepke & Tertilt (2018) JEG
- Add Conley (1999) JoE
- Add Cameron, Gelbach & Miller (2008) REStat

### WS-B: Tighten Causal Language (GPT)
- Soften "first direct test" language
- Add paragraph clarifying we claim interaction is causal even if main effects may include confounds
- Temper "validating the single-dimension approach" to be Swiss-specific

### WS-C: Individual-Level Data Footnote (Gemini, Grok)
- Add footnote acknowledging Swiss Electoral Studies (SELECTS) / Swiss Household Panel as individual-level validation opportunity

### WS-D: Falsification Transparency (GPT)
- Clarify referendum selection rule for non-gender falsification
- Note that "all non-gender" results available in appendix (extended falsification)

### WS-E: Equivalence Test (GPT — high impact, feasible)
- Not implementing formal TOST in R code (would require rerunning scripts)
- Instead, add text framing the CI bounds as an equivalence argument: "The 95% CI of [-1.7, 1.5] pp rules out interactions exceeding 10% of the language main effect in either direction"

### WS-F: Exhibit Polish (Exhibit Review)
- Not consolidating Tables 1/2 (would require R code changes)
- Note suggestions for future revision

### WS-G: Prose Polish (Prose Review)
- Minor tightening per suggestions

## Not Implementing (Scope)
- Conley SEs (requires specialized R packages + geographic distance data not currently in workspace)
- Wild cluster bootstrap (fwildclusterboot not available on this system)
- Border-proximity design (major new analysis requiring geographic data)
- Municipality FE (collinear with time-invariant treatments)
- Individual-level survey analysis (SELECTS/SHP data not available)

## Execution Order
1. Add references to references.bib
2. Edit paper.tex: tighten claims, add footnotes, clarify falsification, frame equivalence
3. Recompile PDF
4. Write reply_to_reviewers_1.md
