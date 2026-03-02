# Reviewer Response Plan

## Overview

Three external referees reviewed the paper. Decision consensus: 2 MINOR REVISION, 1 MAJOR REVISION.
- **GPT-5.2:** MAJOR REVISION (interference formalization, CIs, drug-type suppression, endogeneity)
- **Grok-4.1-Fast:** MINOR REVISION (CIs, 3-4 lit cites, mechanism data)
- **Gemini-3-Flash:** MINOR REVISION (border-county analysis, PMP InterConnect, synthetic opioid discussion)

Exhibit review: "AER-ready" — minor polish only.
Prose review: "Shleifer-ready" — no rewrites needed.

## Workstreams

### WS1: Confidence Intervals (ALL THREE REVIEWERS)
**Priority: HIGH** — All reviewers flagged missing CIs.

- Compute 95% CIs for all headline coefficients in Tables 2-5 and 7
- Add CI columns or bracket notation to main tables
- Report CS ATT CI explicitly in text
- Add CIs to event-study figure (already present as bands — verify)

### WS2: Interference Framework (GPT — core concern)
**Priority: HIGH** — GPT's most substantive point.

- Add new subsection "Estimand Under Interference" in Section 5 (Empirical Strategy)
- Define potential outcomes Y_jt(d_jt, E_jt) under exposure mapping
- State partial interference assumption: only contiguous neighbors' mandates matter
- Cite Aronow & Samii (2017) and Hudgens & Halloran (2008)
- Add second-order exposure (neighbors-of-neighbors) as robustness check in R code
- Report second-order robustness result

### WS3: Literature Additions (GPT + GROK)
**Priority: MEDIUM**

Add to references.bib and cite in text:
- Sun & Abraham (2021) — heterogeneous treatment effects in event studies
- Roth (2022) — pretest sensitivity for parallel trends
- Aronow & Samii (2017) — exposure mappings under interference
- Hudgens & Halloran (2008) — causal inference with interference
- Dube, Lester & Reich (2010) — border discontinuity designs (already cited by Gemini)

### WS4: Drug-Type Suppression Analysis (GPT)
**Priority: MEDIUM**

- Add table/discussion showing suppression rates by drug type and by exposure status
- Report whether missingness correlates with treatment
- Discuss in limitations section

### WS5: Specification Without OwnPDMP (GPT)
**Priority: MEDIUM**

- Run main regression without OwnPDMP control
- Report as robustness — interpret as "total spillover effect"
- Discuss mediator vs bad-control concern

### WS6: Common Support Period Robustness (GPT)
**Priority: MEDIUM**

- Run main specification restricted to 2011-2019 (before near-universal exposure)
- Report as robustness check

### WS7: Table Notes Enhancement (GPT)
**Priority: LOW**

- Clarify covariates included in main regressions
- Add exposure variable definition to table notes
- Ensure clustering description is explicit

### WS8: Synthetic Opioid Discussion (GEMINI)
**Priority: LOW**

- Add brief discussion of negative (insignificant) synthetic opioid coefficient
- Interpretation: displacement may maintain access to prescription opioids, reducing demand shift to fentanyl

### NOT ADDRESSED (infeasible in one revision cycle):
- Border-county analysis (requires new county-level data infrastructure)
- ARCOS/prescribing mechanism data (not publicly available)
- PMP InterConnect interaction (requires separate data collection)
- Conley spatial HAC SEs (complex implementation)
- Wild cluster bootstrap (would need boottest package — can attempt)

## Execution Order
1. WS3 (add references to .bib)
2. WS2 (interference subsection in paper.tex)
3. WS1 (add CIs to R code and tables)
4. WS5 + WS6 (additional robustness in R)
5. WS4 (suppression analysis)
6. WS7 + WS8 (paper text improvements)
7. Recompile and visual QA
