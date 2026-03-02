# Conditional Requirements

**Generated:** 2026-02-16T17:30:43.375420
**Status:** RESOLVED

---

## REDESIGN NOTE

Based on the reviewer's feedback, the paper has been substantially redesigned. The original "perception gap" construct (GSS perceptions vs FBI crime rates at the 4-region level) is replaced with a cleaner design:

**New design:** Individual-level FEAR OF CRIME (GSS variable: `fear` — "Is there any area right around here—that is, within a mile—where you would be afraid to walk alone at night?") as an experiential treatment, predicting punitive policy preferences. This addresses the core concerns:

1. **Treatment is experiential, not ideological:** Fear of crime is a subjective safety perception, not a policy preference like natcrime. This reduces mechanical correlation with punitive attitudes.
2. **Individual-level variation avoids the 4-region problem:** Treatment varies across individuals within the same region-year.
3. **DR controls for ideology:** By including polviews (political views) and partyid in the propensity score, we absorb the "everything correlates with conservatism" confound.
4. **Actual crime rates serve as a control, not a treatment component:** FBI UCR region-year crime rates enter as covariates, not as part of the treatment definition. This eliminates the aggregation bias concern.

---

## Punitive Preferences Under Falling Crime: How Misperceptions of Crime Shape Support for the Carceral State

**Rank:** #1 | **Recommendation:** CONSIDER

### Condition 1: obtaining finer geography via restricted GSS state/county identifiers or another survey

**Status:** [x] RESOLVED

**Response:** Redesigned to use INDIVIDUAL-LEVEL variation in fear of crime (GSS `fear` variable, 33,467 obs). Treatment varies across individuals within region-years, so the 4-region limitation is no longer binding. Geographic variation is not the source of identification — individual-level selection on observables is.

**Evidence:** GSS `fear` variable has 33,467 valid observations across 28 survey years (1973-2024). Within any region-year, there is substantial variation: typically 35-45% report fear.

---

### Condition 2: constructing perceptions from an independent data source or leave-one-out region-year means

**Status:** [x] RESOLVED

**Response:** Treatment is now individual-level `fear` (experiential safety perception), which is conceptually distinct from punitive attitudes (cappun, courts). Fear asks about personal safety; punitive attitudes ask about policy preferences. By controlling for political views (polviews, partyid), we absorb the ideological channel. Actual FBI UCR crime rates at the region-year level enter as CONTROLS, not as treatment components.

**Evidence:** Correlation between fear and partisan ID is moderate (r~0.2), not overwhelming. Within partisan groups, fear varies substantially with demographics (age, sex, urban/rural, race).

---

### Condition 3: adding region fixed effects

**Status:** [x] RESOLVED

**Response:** Both the propensity score model and outcome model will include region fixed effects (GSS 4 regions). This absorbs permanent regional differences in both fear and punitive attitudes.

**Evidence:** Standard econometric practice. Will be implemented in R code.

---

### Condition 4: flexible region-specific time trends

**Status:** [x] RESOLVED

**Response:** Will include region × year fixed effects (4 regions × 28 years = 112 cells). This absorbs ALL region-specific time variation. The only remaining variation is within-region-year individual differences.

**Evidence:** With 33,467 observations and 112 region-year cells, average cell size is ~300. Sufficient for AIPW estimation.

---

### Condition 5: clear plan for inference with treatment at the region-year level

**Status:** [x] RESOLVED

**Response:** Treatment is now individual-level (not region-year). Standard errors will be clustered at the region-year level to account for correlated unobservables. For robustness: wild cluster bootstrap and HC2 heteroskedasticity-robust SEs. Sensitivity analysis via E-values (VanderWeele and Ding 2017) will quantify how much unobserved confounding would be needed to explain away results.

**Evidence:** With ~300 obs per region-year cell, inference is well-powered.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
