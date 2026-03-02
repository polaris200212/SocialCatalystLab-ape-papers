# Reviewer Response Plan — apep_0354 v1

## Summary of Feedback

**Decisions:** GPT = MAJOR REVISION, Grok = MAJOR REVISION, Gemini = MINOR REVISION

### Grouped Concerns

#### 1. Staggered DiD Estimator (GPT, Grok — Critical)
All three external reviewers flag that the paper uses TWFE event study with staggered timing but does not implement modern staggered-robust estimators (Callaway-Sant'Anna, Sun-Abraham, Borusyak et al.). Grok marks this as a FAIL.

**Response:** We cannot implement CS-DiD or Sun-Abraham with N=22 treated units — the `did` package requires sufficient group-time cells, and our staggered structure (22 events across different months/years) makes this computationally infeasible. However, we will:
- Add explicit discussion of why TWFE is defensible here (controls are never-treated only, no already-treated-as-controls contamination)
- Add citations to de Chaisemartin & D'Haultfoeuille (2020) and Borusyak et al. (2024)
- Explain that RI preserves the staggered structure and serves as our primary small-sample inference method
- Note this as a limitation and direction for future work with larger samples

#### 2. Inference with Few Clusters (GPT — Critical)
GPT recommends wild cluster bootstrap and RI-inverted CIs as primary inference.

**Response:** With 16 treated ZIP clusters, wild cluster bootstrap is also unreliable (Cameron et al. 2008 recommend ≥30 clusters). We already use RI as our primary robustness check. We will:
- Elevate RI from "supplement" to co-primary inference method
- Add Cameron, Gelbach & Miller (2008) citation
- Report MDE calculation to contextualize what the null means
- Note that RI p-value (0.926) and asymptotic p-value agree

#### 3. MDE Calculation (GPT)
Readers need to understand what effect size we could detect.

**Response:** Add MDE calculation based on SE and conventional power (80%). MDE ≈ 2.8 × 0.246 ≈ 0.69 log points (≈100% of baseline). Discuss implications.

#### 4. Estimand Clarity (GPT)
Need to define precisely whether estimand is effect of federal exclusion date vs. provider billing exit.

**Response:** Add paragraph clarifying estimand. Primary estimand is the market-level ITT effect of the formal exclusion date; billing-defined date is a robustness check.

#### 5. Missing References (GPT, Grok, Gemini)
Key missing papers:
- de Chaisemartin & D'Haultfoeuille (2020) — staggered DiD
- Borusyak, Jaravel & Spiess (2024) — imputation DiD
- Cameron, Gelbach & Miller (2008) — wild cluster bootstrap
- Baker, Larcker & Wang (2022) — staggered DiD motivation

**Response:** Add all four to references.bib and cite in text.

#### 6. ROM Interpretation (GPT)
Tighten language: "billing absorption" ≠ "access maintained." Avoid sliding into access claims.

**Response:** Revise Discussion section to be more precise. Replace "markets appear to adjust" with "billing-based measures show absorption" etc.

#### 7. Prose Improvements (Prose Review)
- Kill the generic opening → start with the tension/hook
- Elevate attrition finding to page 1
- Active results narration (not "Column 3 shows")
- Punch up conclusion ending
- Remove "The paper proceeds as follows" paragraph

**Response:** Implement all five suggestions. This is high-impact, low-cost.

#### 8. Exhibit Fixes (Exhibit Review)
- Figure 3 notes: fix reference to "Right panel" (single-panel figure)
- Table 2: move "Outcome" to top → already in column headers; add mean of dep var
- Table 4: add descriptive column headers
- Figure 5: verify "Full absorption" line placement

**Response:** Fix LaTeX notes for Figure 3. Other table changes would require R code modifications — address what's feasible in LaTeX.

#### 9. Additional Suggestions (Gemini)
- Urban/rural heterogeneity split
- MCO vs FFS table
- Medicare spillovers

**Response:** Acknowledge in Discussion as directions for future work. Sample too small (N=22) for formal heterogeneity analysis.

---

## Execution Order

### Workstream A: References (5 min)
1. Add 4 missing BibTeX entries to references.bib

### Workstream B: Prose Revision (30 min)
1. Rewrite opening paragraph (hook)
2. Restructure Introduction to elevate attrition finding
3. Active voice in Results section
4. Remove "paper proceeds as follows" paragraph
5. Punch up conclusion ending
6. Trim Data section technical details

### Workstream C: Methodology Discussion (20 min)
1. Add paragraph on why TWFE is defensible (never-treated controls)
2. Elevate RI to co-primary inference method
3. Add MDE calculation to Results
4. Clarify estimand in Empirical Strategy

### Workstream D: Interpretation Tightening (15 min)
1. Replace "access" claims with "billing-based" language
2. Add paragraph on ROM limitations
3. Acknowledge urban/rural heterogeneity as future direction

### Workstream E: Exhibit Fixes (10 min)
1. Fix Figure 3 caption (remove "Right panel" reference)
2. Fix Table 2 notes

### Workstream F: Recompile & QA (10 min)
1. Full pdflatex + bibtex sequence
2. Visual QA on all pages
