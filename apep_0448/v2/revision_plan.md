# Revision Plan: apep_0448 v2 — Integrity Fix

## Context

apep_0448 is the #1 ranked APEP paper (22.6 conservative rating). Code integrity scan flagged SUSPICIOUS: the Randomization Inference in 04_robustness.R uses TWFE, but the paper reports CS-DiD RI results that no committed code produces. Additionally, Table 3 has hand-edited CIs and stars.

## Workstreams

### 1. Fix 04_robustness.R — Add CS-DiD RI
- Add Section 7b after existing TWFE RI
- 200 permutations using att_gt() + aggte() from did package
- Save both ri_pvalue (TWFE) and ri_pvalue_cs (CS-DiD) in robustness_results.rds

### 2. Fix 06_tables.R — Code-generate all table content
- Table 3: Add 95% CI row and significance stars programmatically
- Table 4: Add dual RI rows (CS-DiD and TWFE) from robustness_results.rds

### 3. Re-run full R pipeline (00-06)

### 4. Update paper.tex — revision footnote, verify RI text matches code

### 5. Compile, review, publish with --parent apep_0448

## What does NOT change
- Research question, data, identification, main results, prose, framing
