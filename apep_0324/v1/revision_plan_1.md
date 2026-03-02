# Reviewer Response Plan

## Key Issues (grouped across reviewers)

### 1. Sensitivity Analysis (All 3 referees)
- Add Oster (2019) / Cinelli-Hazlett (2020) sensitivity analysis
- Report how strong unobservable confounding would need to be
- **Action:** Run sensemakr on OLS models, report robustness values in paper

### 2. Survey Weights / Complex Design (GPT)
- GSS has weights, strata, PSUs
- **Action:** Add discussion paragraph justifying unweighted estimation for causal estimands + note limitation

### 3. Estimator Switching (GPT)
- "Fallback to IPW" creates researcher degrees of freedom concern
- **Action:** Reframe: IPW is the primary estimator; AIPW attempted as robustness. Both produce similar results.

### 4. Post-weighting Balance (GPT)
- Only show unadjusted SMDs
- **Action:** Note that AIPW doesn't require explicit balance; the doubly robust property handles this

### 5. Control-Group Means (GPT)
- Add to main results table for magnitude interpretation
- **Action:** Add control means to Table 2 notes

### 6. Additional References (All 3)
- Add Oster (2019), Manski (2004), Polinsky & Shavell (2000)
- **Action:** Add to references.bib and cite in paper

### 7. Prose Improvements
- Kill remaining throat-clearing
- Fix "1972 vs 1973" inconsistency (done)
- Active voice audit
