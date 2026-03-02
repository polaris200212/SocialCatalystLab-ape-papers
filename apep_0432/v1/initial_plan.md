# Initial Research Plan: Breaking Purdah with Pavement

## Research Question

Do rural roads have heterogeneous effects on women's economic participation depending on the caste composition of the village? Specifically, does the impact of PMGSY road connectivity on female employment differ across SC (Scheduled Caste), ST (Scheduled Tribe), and upper-caste-dominated villages?

## Identification Strategy

### Primary Design: Regression Discontinuity (RDD)

**Running variable:** Census 2001 village population
**Threshold:** 500 persons (plains areas); 250 persons (hills/tribal/desert areas)
**Treatment:** PMGSY road eligibility (villages above threshold eligible for road construction)
**Estimand:** ITT (Intent-to-Treat) at the population threshold

Villages above the PMGSY population eligibility threshold are significantly more likely to receive paved road access. This is a well-established first stage documented by Asher & Novosad (2020, AER).

### Key Innovation: Caste-Heterogeneous RDD

The main contribution is interacting the RDD treatment with village-level caste composition:
- **SC-dominated villages:** Women have historically high labor force participation due to poverty. Roads may enable transition from agricultural labor to non-farm work.
- **ST-dominated villages:** Gender norms are relatively egalitarian (bride-price traditions). Roads should increase female non-farm employment.
- **Upper-caste-dominated villages:** Purdah/seclusion norms restrict women's mobility. Roads may benefit men disproportionately or even reduce female employment as household income rises and women withdraw from labor.

### Complementary Design: MGNREGA DiD

As a secondary analysis, exploit the staggered MGNREGA rollout (Phase I: 200 districts Feb 2006, Phase II: +130 Apr 2007, Phase III: all remaining Apr 2008) with the same caste × gender heterogeneity. This provides a second independent source of variation testing the same hypothesis.

## Expected Effects and Mechanisms

### Theoretical Framework

**Mechanism 1: Market Access Channel**
Roads reduce travel time to market towns → increase returns to non-farm labor → men and women should both benefit, but gender norms moderate the response.

**Mechanism 2: Income Effect Channel**
Roads increase household income → if income effect on female leisure is strong (as in upper-caste villages with seclusion norms), women withdraw from labor.

**Mechanism 3: Norm Diffusion Channel**
Roads increase exposure to urban/modern gender norms → could liberalize OR could enable "Sanskritization" (lower castes adopting upper-caste practices including female seclusion).

### Expected Signs

| Outcome | SC villages | ST villages | Upper-caste villages |
|---------|-------------|-------------|---------------------|
| Female non-farm work | + (transition from ag) | + (new opportunities) | 0 or − (income effect) |
| Female ag labor | − (exit agriculture) | − (exit agriculture) | − (small, already low) |
| Female non-workers | − (enter labor force) | − (enter labor force) | + (withdraw from labor) |
| Female literacy | + | + | + (but smaller) |
| Child sex ratio | 0 | 0 | − (worsening, dowry channel) |

## Primary Specification

### Local Polynomial RDD

For village v in district d and state s:

```
ΔY_v = α + τ₁·1(Pop_v ≥ 500) + τ₂·1(Pop_v ≥ 500)×SC_Share_v + τ₃·1(Pop_v ≥ 500)×ST_Share_v
        + f(Pop_v) + g(Pop_v)×SC_Share_v + g(Pop_v)×ST_Share_v + X_v'β + δ_s + ε_v
```

Where:
- ΔY_v = change in female employment outcome (Census 2001→2011 or EC 2005→2013)
- 1(Pop_v ≥ 500) = indicator for PMGSY eligibility
- SC_Share_v, ST_Share_v = Census 2001 caste composition
- f(Pop_v) = local polynomial in running variable (separate slopes above/below)
- X_v = baseline covariates (female literacy 2001, distance to town, amenities)
- δ_s = state fixed effects

### Estimating the interaction:
To test heterogeneity, split the sample into terciles by SC share (or ST share) and estimate the RDD separately for each tercile. This avoids functional form assumptions on the interaction.

## Planned Robustness Checks

1. **McCrary density test** at 500 and 250 thresholds
2. **Covariate balance** at threshold (10+ pre-treatment variables)
3. **Bandwidth sensitivity** (IK optimal, half, double, plus donut-hole excluding ±10 around cutoff)
4. **Separate estimation at 250 threshold** (hills/tribal) as independent replication
5. **Placebo thresholds** at 400 and 600 (where no program eligibility exists)
6. **MGNREGA DiD** as complementary evidence (different policy, same hypothesis)
7. **Nightlights** as continuous annual outcome to show economic growth channel
8. **EC data** (2005→2013) for non-farm employment outcomes
9. **SECC data** for household-level poverty × caste decomposition of mechanisms

## Exposure Alignment (DiD Component)

- **Who is actually treated?** Working-age women in rural villages near the PMGSY threshold
- **Primary estimand population:** Villages with Census 2001 population 200-800 (near threshold)
- **Placebo/control population:** Villages below threshold, or villages at placebo thresholds
- **Design:** RDD (primary) + DiD (complementary via MGNREGA phases)

## Power Assessment

- **Sample near threshold (bandwidth ±200):** ~200,000 villages (300-700 pop range)
- **Treated clusters:** ~100,000 villages above threshold in bandwidth
- **Pre-treatment periods:** Census 2001 (baseline), Census 1991 (additional pre)
- **Post-treatment periods:** Census 2011, EC 2013
- **MDE:** With 200K+ villages, even small effects (0.5-1 pp changes in female employment share) should be detectable at conventional levels. Heterogeneity by caste tercile (~67K per tercile) maintains strong power.

## Data Sources (All Available Locally in SHRUG)

| Data | File | Key Variables |
|------|------|---------------|
| Census 2001 PCA | pc01_pca_clean_shrid.csv | Pop, SC/ST, female workers by type, literacy |
| Census 2011 PCA | pc11_pca_clean_shrid.csv | Same as above |
| Census 2011 TD | pc11_td_clean_shrid.csv | Road access, distance to town, amenities |
| EC 2005 | ec05_shrid.csv | Female employment, firm counts by caste |
| EC 2013 | ec13_shrid.csv | Same as above |
| SECC 2011 | secc_rural_shrid.csv | HH income sources, deprivation, land |
| Nightlights DMSP | dmsp_shrid.csv | Annual luminosity 1992-2013 |
| Nightlights VIIRS | viirs_annual_shrid.csv | Annual luminosity 2012-2021 |
| District key | shrid_pc11dist_key.csv | Village → district → state mapping |
