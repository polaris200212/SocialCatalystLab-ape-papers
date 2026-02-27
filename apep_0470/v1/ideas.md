# Research Ideas

## Idea 1: The Unequal Legacies of the Tennessee Valley Authority — Individual-Level Evidence from Linked Census Microdata, 1920–1940

**Policy:** The Tennessee Valley Authority (TVA), established May 18, 1933, was the largest place-based development program in American history. It built 16 dams, electrified rural areas, and reshaped the economy of parts of seven Southern states (Tennessee, Alabama, Mississippi, Kentucky, Virginia, North Carolina, Georgia). Kline and Moretti (2014, QJE) showed large, persistent effects on manufacturing employment using county-level aggregate data.

**Outcome:** Individual-level outcomes from the IPUMS Multigenerational Longitudinal Panel (MLP) linking the same individuals across the 1920, 1930, and 1940 decennial censuses. The 1940 census uniquely provides wage income and years of education — unavailable in earlier censuses. Key outcomes: (1) occupational upgrading (agricultural → manufacturing), (2) wage income (1940 only, but individual FE controls for pre-treatment occupation), (3) labor force participation, (4) home ownership, (5) migration (movers vs. stayers), (6) literacy/education for children.

**Identification:** A spatial gradient difference-in-differences design exploiting continuous variation in distance from TVA infrastructure:

1. **Individual-level DiD:** Link individuals across 1920→1930 (pre-period) and 1930→1940 (treatment period). Individual fixed effects difference out all time-invariant characteristics. TVA exposure = residing in a TVA-service county in 1930.

2. **Distance gradient:** Treatment intensity measured as distance from county centroid to (a) nearest TVA dam, (b) TVA service boundary. Effects should decay with distance if driven by electrification/employment access rather than broader Southern economic trends. This is NOT a spatial RDD — it's a continuous treatment model. The economic model predicts monotone decay, not a sharp discontinuity, because electricity transmission, commuting, and labor market spillovers are continuous in distance.

3. **Border-county subsample:** Restrict to counties within 100km of the TVA boundary for tightest comparison. Adjacent counties share geography, culture, and pre-TVA economic structure — the only difference is TVA exposure.

4. **Pre-trend validation:** The 1920→1930 transition (entirely pre-TVA) serves as a placebo. If the parallel trends assumption holds, individuals in future-TVA counties should show similar occupational/economic trajectories to individuals in non-TVA counties during 1920-1930.

5. **Selection on migration:** Track individuals who stayed vs. moved. TVA may have attracted in-migrants (selection into treatment) or pushed out agricultural workers (displacement). The linked panel lets us decompose: (a) stayers in TVA counties, (b) in-migrants to TVA, (c) out-migrants from TVA, (d) stayers in non-TVA counties.

**Why it's novel:**

1. **First individual-level panel study of TVA.** Kline and Moretti (2014) used county-level aggregates. Every subsequent paper (Kitchens 2014, Kitchens and Fishback 2015, Rappaport 2023) also uses aggregate data. No one has tracked individual lives through the TVA transformation.

2. **Race and gender heterogeneity in the Jim Crow South.** TVA was a federal program operating in the Jim Crow South. Did its benefits reach Black workers? Women? The aggregate data cannot answer this. Our individual-level data can decompose effects by race × gender × age, revealing whether TVA was a tide that lifted all boats or a program that primarily benefited white men.

3. **Mechanism chain at the individual level.** We can trace the causal chain: TVA → electrification → manufacturing jobs → individual occupational transitions → wage gains. This is a genuine A→B→C chain observable within individual careers.

4. **The data revolution.** The IPUMS MLP linking 175 million people across censuses was not available when Kline and Moretti wrote. This is a genuine case where new data enables fundamentally new questions. The panel structure allows individual fixed effects, pre-trend tests, and decomposition of place effects vs. person effects — none of which are possible with aggregate data.

5. **Distance decay as mechanism test.** The distance gradient approach doesn't just improve identification — it tests the economic model. If effects decay sharply with distance, the mechanism is local (direct employment, electrification). If effects are flat, the mechanism is regional (agglomeration, demand spillovers). This directly adjudicates between the Kline-Moretti agglomeration story and simpler local employment stories.

**Feasibility check:**

- **IPUMS API key:** Configured and verified ✓
- **Census availability:** Full-count data available for 1920, 1930, 1940 ✓
- **MLP linking:** HISTID provides cross-census individual links ✓
- **Geographic identification:** TVA county list and dam locations are well-documented ✓
- **Sample size:** Southeast states contain ~25M people per census; after linking, expect 1M+ individuals in the TVA region ✓
- **Memory:** 96GB RAM can handle full-count data for relevant states ✓
- **Variation:** TVA service area covers ~125 counties across 7 states, with hundreds of non-TVA counties as controls ✓
- **Pre-trends:** 1920-1930 transition available as pre-period ✓
- **Not overstudied at individual level:** Zero papers use linked census microdata for TVA ✓

**Risk assessment:**
- **Link quality:** Census linking has known selection issues (literate people link better). We address this with (a) inverse probability weighting, (b) bounding exercises, (c) comparison of linked vs. unlinked samples.
- **1940 income data limitations:** Wage income doesn't capture farm income (many TVA-area residents were farmers). We use occupational transitions and labor force participation as complementary outcomes.
- **TVA boundary endogeneity:** The TVA region was not randomly assigned. We address this with (a) distance gradient, (b) border-county restriction, (c) pre-trend tests, (d) controlling for pre-TVA county characteristics.


## Idea 2: [BACKUP] The Electrification Dividend — Gender and the TVA

**Policy:** The Tennessee Valley Authority (TVA), established May 18, 1933. Built 16 dams and brought electricity to rural areas of 7 Southern states (TN, AL, MS, KY, VA, NC, GA). By 1940, TVA had electrified thousands of rural households that previously lacked power, fundamentally changing domestic labor.

**Outcome:** Women's labor force participation rates from IPUMS MLP linked census data (1920, 1930, 1940). The 1940 census provides employment status, occupation, and wage income. Track individual women's transitions from "not in labor force" to "employed" across the TVA treatment period, with occupation detail (textiles, services, manufacturing).

**Identification:** Individual-level difference-in-differences comparing women in TVA counties vs. adjacent non-TVA counties, with 1920-1930 as pre-trend validation. Distance to nearest TVA dam as continuous treatment intensity. Triple-diff: TVA × Post × Female to isolate gender-specific effects of electrification.

**Why it's novel:** Focused gender story with clearer mechanism than Idea 1 — electrification reduced domestic labor burden and created light manufacturing jobs. But strictly narrower in scope.

**Feasibility check:** Same data infrastructure as Idea 1. IPUMS API key configured, MLP linking available, 96GB RAM sufficient. Confirmed: full-count data for 1920, 1930, 1940 available with HISTID.

**Status:** Backup only. Idea 1 is strictly superior as it subsumes this question.


## Idea 3: [BACKUP] Intergenerational TVA — Did Children Benefit?

**Policy:** The Tennessee Valley Authority (TVA), established May 18, 1933. Comprehensive regional development including dam construction, electrification, agricultural modernization, and educational programs across 7 Southern states.

**Outcome:** Educational attainment and early labor market outcomes from IPUMS MLP linked census data. Track children (ages 0-10 in 1930) who grew up in TVA counties to 1940 (ages 10-20). Outcomes: years of schooling (1940 census), school enrollment, literacy, and early occupation for older teens.

**Identification:** Individual-level difference-in-differences comparing children in TVA vs. non-TVA counties, with distance gradient to nearest TVA infrastructure. Parent-child links in MLP allow controlling for parental characteristics. Age-cohort variation: children born earlier were exposed at older ages (less exposure during formative years).

**Why it's novel:** Intergenerational effects of place-based policy using individual-level panel data. Can test whether TVA's human capital effects compound across generations.

**Feasibility check:** Same data infrastructure as Idea 1. IPUMS API key configured, MLP linking available, 96GB RAM sufficient. Parent-child links available through HISTID household linkage.

**Status:** Backup only. Can be incorporated as a section within Idea 1.
