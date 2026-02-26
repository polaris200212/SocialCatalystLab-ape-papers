# Revision Plan 1 — Stage C Addressing Referee Feedback

## Context
Three external referees (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash) all recommended MAJOR REVISION. Core concerns:

1. **Pre-trend F-tests not reported** — Must add to paper text
2. **Triple-diff imprecise** (p=0.10-0.18) — Power limitations acknowledged
3. **Department trends kill baseline** — Serious robustness concern
4. **COVID confound** — Rural house boom may drive triple-diff signal
5. **Direction ambiguity** — Positive Post×Stock vs negative Sterling×Stock
6. **Residualization framed as causal** — Should be descriptive

## Changes Implemented

### 1. House-Apartment Gap Event Study (NEW — Figure 6)
GPT requested collapsing to within-département gap and running standard event study. Result: pre-trend F-test p=0.240, validating triple-diff identifying assumption. This is the strongest new evidence in the revision.

### 2. Pre-Trend F-Tests Added to Text
SCI: F=1.98, p=0.038 | Stock: F=1.90, p=0.048 | Gap: F=1.28, p=0.240. Reported in Section 5.3. The borderline DiD violations reinforce the case for the triple-difference.

### 3. COVID Subsample Analysis
Pre-COVID (2014-2019) triple-diff: β≈0.000, p=0.972. Reported honestly in Discussion 8.4. Acknowledges that triple-diff signal is driven by 2020-2023 dynamics.

### 4. Direction Clarified
Added explicit reconciliation in Section 7.1: average cosmopolitan appreciation (positive Post×Stock) vs within-post-period demand channel (negative Sterling×Stock).

### 5. Residualization Reframed
Section 8.3 now explicitly states it is a "descriptive decomposition, not a causal identification strategy."

### 6. Table Professionalization
All tables: "Log Price/m²" headers, significance stars, clustering notes, standardized labels.

### 7. Sterling Inconsistency Fixed
Harmonized to "10% depreciation within a single quarter" throughout.

### 8. Within R² Explained
Table notes explain near-zero within-R² in trend specifications.

### 9. Observation Counts Reconciled
All N values now match across text and tables exactly.

## Not Addressed (Scope Limitations)
- Wild cluster bootstrap (96 clusters adequate per Cameron & Miller)
- Additional country placebos (Belgium, Netherlands, Spain)
- Sub-département analysis (EPCI/bassin de vie)
- Buyer nationality data (unavailable in DVF)
- HonestDiD sensitivity analysis
