# Initial Research Plan — apep_0428

## Research Question

Do rural roads improve development outcomes in India's most remote tribal and hill areas? Specifically, what is the causal effect of PMGSY road eligibility at the 250-population threshold on structural transformation, human capital, and gender outcomes in designated tribal, hill, and desert areas?

## Identification Strategy

**Design:** Fuzzy Regression Discontinuity at the 250-population threshold (Census 2001) for PMGSY eligibility in designated areas (Special Category States, Schedule V tribal areas, Desert Development Programme areas).

**Running variable:** Village population from Census 2001 (`pc01_pca_tot_p`)

**Treatment:** Eligibility for PMGSY road construction (above 250 in designated areas)

**Bandwidth:** Optimal bandwidth selected via `rdrobust` (Calonico, Cattaneo, Titiunik 2014). Expected range: ±100-200 around threshold.

**Designated areas:**
- 11 Special Category/Hill States (Arunachal Pradesh, Assam, Manipur, Meghalaya, Mizoram, Nagaland, Sikkim, Tripura, Himachal Pradesh, J&K, Uttarakhand)
- Schedule V tribal districts (compiled from Ministry of Tribal Affairs official list)
- Desert Development Programme districts
- Robustness: ST share > 50% as proxy

## Expected Effects and Mechanisms

**Primary mechanism:** All-weather road connectivity reduces transportation costs, connecting remote tribal/hill villages to markets, schools, and health centers.

**Expected effects:**
1. **Structural transformation (ambiguous):** Roads may facilitate labor movement out of agriculture — but could also destroy local artisan/cottage industries through market competition. Asher & Novosad (2020) found labor reallocation but no income gains at 500.
2. **Human capital (positive):** Improved access to schools → higher literacy, especially for girls in areas where distance is the binding constraint.
3. **Gender gap (ambiguous):** Roads could empower women (school/market access) OR increase male out-migration (leaving women in subsistence agriculture). Net effect is an empirical question.
4. **Night-time economic activity (positive or null):** If roads generate economic gains, nightlights should increase.

**Comparison to 500 threshold:** We expect effects may be LARGER at 250 because:
- More remote villages have lower baseline connectivity → larger marginal return to roads
- But: implementation quality may be worse in these areas → potentially weaker first stage

**Null results are valuable:** If roads don't help the most remote communities, this challenges the conventional wisdom that infrastructure is the key to rural development.

## Primary Specification

**Reduced form (ITT):**
$$Y_{i,2011} = \alpha + \tau \cdot \mathbb{1}(Pop_{i,2001} \geq 250) + f(Pop_{i,2001}) + X_{i,2001}\beta + \epsilon_i$$

where $f(\cdot)$ is a local polynomial in the running variable and $X_{i,2001}$ are optional baseline controls.

**Estimated via:** `rdrobust` package in R with:
- Local linear regression (default)
- Triangular kernel
- MSE-optimal bandwidth
- Robust bias-corrected confidence intervals

## Planned Robustness Checks

1. **McCrary density test** at 250 (no manipulation)
2. **Covariate balance** for pre-treatment characteristics
3. **Bandwidth sensitivity** (50%, 75%, 100%, 125%, 150% of optimal)
4. **Polynomial order** (linear, quadratic)
5. **Donut-hole RDD** (exclude observations within ±5 of 250)
6. **Placebo thresholds** (200, 300, 350, 400 — should show no effect)
7. **Comparison to 500 threshold** in non-designated areas
8. **Different designated area definitions** (state only vs. Schedule V vs. ST share proxy)
9. **Gender-stratified outcomes** (male vs. female literacy, workers)
10. **Nightlights event study** (annual RDD estimates 1994-2023)

## Outcome Variables

### Primary Outcomes (Census 2001 → 2011)
| Variable | Construction | Source |
|----------|-------------|--------|
| Literacy rate | p_lit / tot_p | PCA 2011 |
| Female literacy rate | f_lit / tot_f | PCA 2011 |
| Non-agricultural worker share | 1 - (cultivators + ag_laborers) / tot_work | PCA 2011 |
| Female worker participation | tot_work_f / tot_f | PCA 2011 |
| Population growth | (pop_2011 - pop_2001) / pop_2001 | PCA 2001, 2011 |
| Nightlights (log) | log(total_light_cal + 1) | DMSP/VIIRS |

### Secondary Outcomes
| Variable | Construction | Source |
|----------|-------------|--------|
| Male literacy rate | m_lit / tot_m | PCA 2011 |
| Gender literacy gap | male_lit_rate - female_lit_rate | PCA 2011 |
| Main vs marginal workers | mainwork / tot_work | PCA 2011 |
| SC/ST population share change | | PCA 2001, 2011 |
| Household industry workers | main_hh / tot_work | PCA 2011 |

## Power Assessment

- **Designated area villages near threshold:** ~44K villages in 200-299 range; with ~50% in designated areas ≈ 22K observations
- **Within optimal bandwidth (±150):** ~15-20K villages expected
- **Comparison:** Asher & Novosad had ~640K villages total, ~75K in bandwidth around 500
- **MDE estimate:** With N≈15K and standard RDD efficiency, we should detect effects of ~0.03 SD (small but meaningful)

## Data Requirements

All data available locally in `data/india_shrug/`:
- `pc01_pca_clean_shrid.csv` — Census 2001 PCA (running variable + baseline)
- `pc11_pca_clean_shrid.csv` — Census 2011 PCA (outcomes)
- `dmsp_shrid.csv` — DMSP nightlights 1994-2013
- `viirs_annual_shrid.csv` — VIIRS nightlights 2012-2023
- `shrid_pc11dist_key.csv` — SHRID to district mapping
- `pc11_td_clean_shrid.csv` — Town directory (infrastructure, amenities) — need to verify availability

Additional data needed:
- Schedule V district list (web compilation)
- Desert Development Programme district list (web compilation)
- PMGSY OMMAS road construction data (from SHRUG downloads, if available)
