# Research Ideas — Ghana Policy Evaluation

## Idea 1: The Cocoa Boom and Human Capital in Ghana

**Policy:** World cocoa prices tripled from ~$900/mt in 2000 to ~$2,800/mt in 2010, driven by global demand and supply shocks. Ghana (world's #2 producer) has four high-cocoa regions (Western, Ashanti, Brong-Ahafo, Eastern) that account for ~95% of production. The government's Cocoa Marketing Board (COCOBOD) sets farmgate prices annually, transmitting world price movements to farming households with some dampening.

**Outcome:** Education attainment, school enrollment, child labor, employment status, and sector of employment — measured in IPUMS International Ghana census microdata (2000 and 2010, ~4.4M individual observations with 10-region identifiers).

**Identification:** Doubly-robust difference-in-differences (Sant'Anna and Zhao, 2020). Treatment group = individuals in high-cocoa regions (Western, Ashanti, Brong-Ahafo, Eastern). Control group = low-cocoa regions (Greater Accra, Northern, Upper East, Upper West). Pre-period = 2000 census. Post-period = 2010 census. AIPW estimator combining propensity score for cocoa region residency (based on age, sex, education, urban/rural, household characteristics) with outcome regression. Wild cluster bootstrap for inference with 10 clusters.

**Why it's novel:** The literature on commodity booms and human development is well-established (Dube & Vargas 2013 on Colombia; Allcott & Keniston 2018 on US oil), but no study uses individual-level census microdata to examine how the 2000s cocoa price boom affected education and employment in Ghana. Cocoa is labor-intensive (unlike oil), so the income and substitution effects on schooling operate through different channels. The child labor vs. schooling tradeoff in cocoa regions is a major policy concern (ILO Cocoa Protocol).

**Feasibility check:**
- Data access: IPUMS International extract confirmed working — 1.89M (2000) + 2.47M (2010) person records. GEO1_GH available for regional identification.
- Variation: Cocoa production is heavily concentrated in 4 of 10 regions (sharp cross-sectional variation). World prices moved dramatically in the 2000-2010 period.
- Sample size: 4.4M individuals with rich covariates. Power is not a concern at individual level.
- Not overstudied: No census-based DR DiD study of cocoa boom effects in Ghana exists.
- Concern: Only 10 clusters for inference (addressed with wild bootstrap). Central/Volta are intermediate cocoa producers (robustness check with different cutoffs).


## Idea 2: District Creation and Local Development in Ghana

**Policy:** Ghana created new administrative districts in major waves — 28 new districts in 2004 (110→138), 32 in 2008 (138→170), 46 in 2012 (170→216). Creation was politically motivated (Resnick 2017, Political Geography) but brought new district capitals, government offices, and DACF fiscal transfers.

**Outcome:** Education, employment, housing quality, water/sanitation access from IPUMS International Ghana census (2000, 2010). Treatment measured at district level using GEO2_GH harmonized geography (102 zones consistent across both years).

**Identification:** DR estimator. Treatment = living in a harmonized zone that experienced district splitting between 2000 and 2010 (primarily the 2004 wave). Propensity score models probability of zone experiencing creation based on pre-treatment characteristics (population, ethnic composition, urbanization, distance from regional capital). Doubly-robust estimator for ATT on development outcomes.

**Why it's novel:** No credible causal study of district creation effects on health, education, or economic outcomes exists for Ghana (Iddrisu 2025 studied fiscal efficiency only; Grossman & Pierskalla 2017 is cross-national). Massive literature gap for one of Africa's most prominent administrative experiments.

**Feasibility check:**
- Data access: IPUMS extract confirmed — 102 harmonized district zones in both 2000 and 2010.
- Variation: 28+ districts created in 2004 wave, falling within multiple harmonized zones.
- Sample size: 4.4M individuals.
- CRITICAL RISK: IPUMS harmonizes districts to consistent boundaries, so new and parent districts share a single code. Need external mapping of which harmonized zones experienced creation. If the mapping cannot be constructed, this idea fails.
- Not overstudied: Huge gap — most existing work is political science (causes of creation) not economics (effects on development).


## Idea 3: Ghana's NHIS and Maternal/Child Health: A Regional Panel Approach

**Policy:** Ghana's National Health Insurance Scheme (NHIS) launched 2003-2005, with district-level phased rollout. Free Maternal Health Care Policy (FMHCP) integrated into NHIS in 2008. Coverage rose from ~30% in 2008 to ~85% in 2022 with substantial regional variation.

**Outcome:** Facility delivery rates, antenatal care (4+ visits), infant mortality, neonatal mortality, child nutrition (stunting, wasting) — all available from DHS STATcompiler API at the regional level for 7 DHS rounds (1988-2022).

**Identification:** DR DiD. Treatment = high-NHIS-uptake regions (defined by 2008 insurance coverage rates). Pre = 1988-2003 DHS rounds. Post = 2008-2022 DHS rounds. AIPW estimator on 10 regions × 7 rounds = 70 region-year observations.

**Why it's novel:** Garcia-Mandico et al. (2021, JPubE) studied NHIS effects on financial outcomes using district rollout; Keats (2024 WP) studied maternal care reforms broadly. No study uses the full 7-round DHS panel with DR methods to estimate NHIS effects on health outcomes.

**Feasibility check:**
- Data access: DHS API confirmed working — rich health indicators by region × survey round.
- Variation: Sharp increase in insurance coverage across regions, particularly post-2008 FMHCP.
- CRITICAL RISK: Only 70 region-year observations (10 regions × 7 rounds). Very small N. Inference is problematic — wild cluster bootstrap with 10 clusters is at the edge of reliability. Power likely insufficient for meaningful results.
- Garcia-Mandico (2021, JPubE) already published using district-level rollout — this would be a weaker identification strategy at the region level.
