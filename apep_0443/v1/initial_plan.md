# Initial Research Plan: PMGSY Roads and the Gender Gap in Non-Farm Employment

## Research Question

Does rural road connectivity reduce the gender gap in non-farm employment? India's Pradhan Mantri Gram Sadak Yojana (PMGSY) provides a clean identification strategy via population eligibility thresholds. We estimate the causal effect of road eligibility on female structural transformation — the shift from agricultural to non-agricultural work — using a sharp regression discontinuity design.

## Identification Strategy

**Design:** Sharp RDD at the PMGSY population eligibility threshold.

**Running variable:** Village population from Census 2001 (`pc01_pca_tot_p`).

**Threshold:** 500 persons for unconnected habitations in plains areas. PMGSY prioritized habitations above this threshold for all-weather road construction. (250 persons for hill/tribal/desert areas — used as extension.)

**Treatment:** Eligibility for PMGSY road construction (intent-to-treat). Villages above the threshold were eligible; those below were not.

**Key assumption:** Villages with population just above 500 are comparable to those just below, conditional on the running variable. Manipulation is unlikely because: (a) population is measured by Census 2001, which predates most PMGSY construction; (b) village populations are administratively determined, not self-reported; (c) the threshold was set at the national level, not by local officials.

## Expected Effects and Mechanisms

**Primary hypothesis:** Road connectivity enables women to access non-farm employment outside the village by reducing transport costs. This shifts female employment from agricultural labor (low-productivity, often unpaid family work) to non-agricultural work (manufacturing, services, household industry).

**Competing hypothesis:** Roads primarily benefit men (who are more mobile), increasing household income through male non-farm employment. The income effect could REDUCE female LFPR — the well-documented "U-shaped" relationship between income and female labor supply in developing countries.

**The theoretical ambiguity makes this empirically important:** the sign of the effect is genuinely uncertain ex ante.

**Expected magnitudes:** Based on Asher & Novosad (2020), PMGSY effects on overall consumption are ~10-15%. If roads shift female employment composition, we'd expect 2-5 percentage point increases in female non-agricultural worker share (from a base of ~15% in rural India).

## Primary Specification

```
Y_i = α + τ · T_i + f(X_i) + ε_i
```

Where:
- Y_i = female non-agricultural worker share in village i (Census 2011)
- T_i = 1 if village population ≥ 500 (Census 2001)
- X_i = running variable (Census 2001 population - 500)
- f(·) = local polynomial (linear, estimated separately on each side of cutoff)

**Estimation:** `rdrobust` with Calonico-Cattaneo-Titiunik (CCT) optimal bandwidth selection and robust bias-corrected inference.

**Clustering:** Standard errors clustered at district level (to account for spatial correlation in PMGSY implementation).

## Outcome Variables

### Primary outcomes (Census 2011):
1. **Female non-agricultural worker share** = (main_ot_f + main_hh_f) / tot_work_f
2. **Female LFPR** = tot_work_f / tot_f
3. **Male non-agricultural worker share** (comparison — tests gender-specificity)

### Secondary outcomes:
4. **Female literacy rate** = p_lit_f / tot_f
5. **Change in female non-ag share** (2011 minus 2001)
6. **Nightlights growth** (annual, 2001-2011 and beyond via VIIRS)
7. **Total village employment** (total workers / total population)

## Planned Robustness Checks

1. **McCrary density test** — no bunching at the 500 threshold
2. **Covariate balance** — pre-determined characteristics (Census 2001 demographics, state, geography) smooth through cutoff
3. **Bandwidth sensitivity** — results robust at 50%, 75%, 125%, 150%, 200% of optimal bandwidth
4. **Placebo cutoffs** — no effect at fake thresholds (400, 450, 550, 600)
5. **Polynomial order** — linear vs. quadratic local polynomial
6. **Alternative kernel** — triangular vs. uniform kernel
7. **Donut hole** — exclude observations very close to cutoff (±10, ±25)
8. **Hill/tribal subsample** — replicate at 250 threshold
9. **Time dynamics** — nightlights as continuous annual outcome (event study around road construction timing)

## Power Assessment

- ~640,000 villages in SHRUG
- In a bandwidth of ±200 around threshold 500: estimated ~50,000+ villages
- CCT optimal bandwidth likely 100-300 → still thousands of observations
- Minimum detectable effect (MDE) at 80% power: ~1-2 pp change in female non-ag share
- This is well-powered relative to expected effects

## Data Sources

All data from SHRUG (present locally in `data/india_shrug/`):
- Census 2001 PCA: `pc01_pca_clean_shrid.csv` — running variable + pre-treatment outcomes
- Census 2011 PCA: `pc11_pca_clean_shrid.csv` — outcome variables
- Census 2011 VD: village amenities (mediating outcomes)
- Nightlights DMSP: `dmsp_shrid.csv` — 1992-2013
- Nightlights VIIRS: `viirs_annual_shrid.csv` — 2012-2023
- Geographic crosswalk: `shrid_pc11dist_key.csv` — village to district mapping

## Timeline

1. Data loading and cleaning
2. Variable construction (running variable, outcomes)
3. Descriptive statistics and visualization
4. McCrary test and covariate balance
5. Main RDD estimates
6. Robustness battery
7. Paper writing
8. Review and revision
