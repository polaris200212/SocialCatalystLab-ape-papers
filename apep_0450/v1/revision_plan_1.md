# Stage C Revision Plan — apep_0450 v1

## Review Summary

- **GPT-5.2:** MAJOR REVISION — Add dispersion outcome, wild cluster bootstrap, 95% CIs, transparent ΔTax_g, address fuel placebo empirically
- **Grok-4.1-Fast:** MINOR REVISION — Add CIs, 2-3 lit references, fuel robustness, map of tax intensity
- **Gemini-3-Flash:** MAJOR REVISION — State-specific linear trends, deepen fuel discussion, welfare distribution

## Planned Changes

### 1. Add Dispersion-Based Outcome (HIGH — GPT)
Add specification with |log CPI_st − mean(log CPI_t)| as dependent variable. This directly tests "convergence" rather than inferring it from differential growth. Add to 03_main_analysis.R and paper.tex.

### 2. Add State-Specific Linear Trends Specification (HIGH — Gemini, GPT)
Add baseline spec with state × linear trend to address 2015-16 pre-trend concerns. If coefficient survives, it strengthens the paper.

### 3. Add 95% CIs to Main Tables (HIGH — all 3 reviewers)
Modify 06_tables.R to include confidence intervals via modelsummary `conf_level` or manual formatting.

### 4. Add Number of Clusters to Tables (MEDIUM — GPT)
Add "Num. Clusters" row to modelsummary output.

### 5. Add Missing Literature References (MEDIUM — all 3 reviewers)
- Bertrand, Duflo & Mullainathan (2004) — DiD serial correlation
- Cameron & Miller (2015) — Cluster-robust inference
- de Chaisemartin & D'Haultfoeuille (2020) — TWFE heterogeneous treatment
- Parsley & Wei (1996) — Price convergence
- Van Leemput (2021) — Indian market integration

### 6. Expand Fuel Discussion (MEDIUM — all 3 reviewers)
Add concrete details: check-post elimination timing, daily fuel price revision (June 2017), e-way bill introduction (Feb 2018). Provide a sharper defense.

### 7. Add ΔTax_g Mapping Table (MEDIUM — GPT)
Add appendix table mapping CPI commodity groups → approximate pre-GST rates → GST rates → ΔTax_g.

### 8. Clarify Estimand vs Convergence (MEDIUM — GPT)
Add paragraph in strategy section explicitly defining estimand as "differential inflation by exposure" and noting the dispersion outcome as a complement.

### 9. Cite New References in Text (LOW)
Integrate new citations in appropriate sections (methodology, literature review).

### 10. Write Reply to Reviewers (REQUIRED)
Point-by-point response to all three reviewers.

## Not Changing
- Wild cluster bootstrap (RI already provides finite-sample inference; WCB marginal given 35 clusters and RI already reported)
- State-pair price gaps (substantial new analysis; defer to future revision)
- Two-way clustering for triple-diff (state clustering is conservative; triple-diff already has state×time FE)
- Monthly inflation rates outcome (adds complexity without clear identification advantage)
