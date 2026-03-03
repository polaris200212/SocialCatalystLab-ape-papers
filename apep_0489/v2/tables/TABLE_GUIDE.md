# Tables Guide — paper_199

## Tables Planned for Publication

### Table 1: Sample Composition and Covariate Balance

**Content:** Summary statistics for treatment and control groups, pre- and post-period. Tests for balance on baseline covariates.

**Key columns:**
- Treatment group size (N)
- Mean age, years of education (if available)
- Occupation distribution (top 5)
- Industry distribution (top 5)
- p-values for balance tests

**Output file:** `tables/table_1_sample_composition.tex`

---

### Table 2: Main DiD Results — Selected Transition Probabilities

**Content:** Double-difference estimates for the 20 most-affected occupation-industry transition cells.

**Columns:**
- Baseline transition prob (control group pre-period)
- Treatment effect (percentage point change)
- 95% CI
- SVD weight (contribution to principal treatment dimension)

**Key transitions:**
- Agriculture → Manufacturing (expected dominant effect)
- Agriculture → Other services
- Manufacturing → Services (reallocation within manufacturing)

**Output file:** `tables/table_2_main_transitions.tex`

---

### Table 3: Top 10 Affected Occupations

**Content:** Heterogeneous effects by initial occupation. Which occupations benefited most (or least) from TVA?

**Columns:**
- Occupation (1930 Census code)
- Share of TVA treatment group
- Average treatment effect (change in expected destination occupation)
- Mechanisms (% going to manufacturing vs. other industries)

**Output file:** `tables/table_3_occupation_heterogeneity.tex`

---

### Table 4: Heterogeneous Effects by Age Cohort and Race

**Content:** Do young workers respond differently than old workers? Did Black and White workers experience different treatment effects?

**Subgroup analysis:**
- Age 18-35, 36-50, 51-65
- Race: White, Black, Other (if sample size allows)

**Output file:** `tables/table_4_subgroup_analysis.tex`

---

### Table 5: Pre-Trends and Placebo Tests

**Content:** Validation of parallel trends assumption.

**Tests:**
- Pre-period double-difference (1920→1930 for both groups): should be ~0
- Placebo treatment in non-treatment period
- Leads and lags: when did treatment effects begin to appear?

**Output file:** `tables/table_5_pretrends.tex`

---

### Table 6: Robustness Sensitivity

**Content:** How sensitive are results to methodological choices?

**Specifications tested:**
- LoRA rank (4, 8, 16, 32)
- Model size (1.3M, 3.2M, 5.1M params)
- Pre-training strategy (national, regional, alternative data)
- Alternative control groups (same-state only, adjacent counties, proposed-but-rejected TVAs)

**Output file:** `tables/table_6_robustness.tex`

---

### Table 7: Synthetic Validation Results

**Content:** Recovery of known treatment effects in 8 synthetic DGPs.

**DGPs:**
1. Rank-1 treatment (simple shift)
2. Rank-2 treatment (two effects)
3. Heterogeneous treatment (sample-dependent)
4. Noisy treatment (+ Gaussian noise)
5. Partial assignment (imperfect county treatment)
6. Dynamic treatment (time-varying)
7. Cross-sectional heterogeneity (treatment × initial occupation)
8. Null treatment (false positive rate)

**Metrics:** Power, false positive rate, bias, RMSE

**Output file:** `tables/table_7_synthetic_validation.tex`

---

## Appendix Tables

### Appendix Table A1: Full Transition Matrix Results

**Content:** Complete 576×576 transition matrix with DiD estimates (or top 100 transitions if matrix too large for print).

**Format:** Sparse matrix (only non-zero effects shown)

---

### Appendix Table B1: Definition of Life-State Tokens

**Content:** Mapping of 576 tokens to (occupation, industry, marital status, # children) combinations.

**Format:** Lookup table with 576 rows

---

### Appendix Table C1: TVA County List

**Content:** All 125 TVA service area counties, FIPS codes, sample sizes.

---

## Data Sources

All tables are generated from analysis output:
- `data/tva_results.json` — Main results
- `data/tva_heterogeneity.csv` — Subgroup effects
- `data/validation_results.json` — Synthetic validation
- `data/robustness_results.json` — Specification sensitivity

Scripts to generate tables:
```bash
python3 code/05_figures_tables.R
```

## LaTeX Compilation

All `.tex` files are standalone (can be compiled individually) and use the `booktabs` package for professional formatting.

Main document includes via:
```latex
\input{tables/table_1_sample_composition.tex}
\input{tables/table_2_main_transitions.tex}
% ... etc
```

## Status

Table templates: PLANNED (not yet generated)

To regenerate: Complete the analysis scripts (`code/03_tva_analysis.py`) and run `code/05_figures_tables.R`.
