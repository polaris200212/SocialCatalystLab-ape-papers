# Research Ideas

## Idea 1: Does Workfare Catalyze Long-Run Development? Fifteen-Year Evidence from India's Employment Guarantee

**Policy:** MGNREGA (Mahatma Gandhi National Rural Employment Guarantee Act) — India's flagship rural employment program. Three-phase staggered rollout:
- Phase I: February 2006, 200 most backward districts
- Phase II: April 2007, additional 130 districts
- Phase III: April 2008, all remaining rural districts (~310)
Assignment based on Planning Commission backwardness index (agricultural productivity, wages, SC/ST share).

**Outcome:** Village-level nighttime luminosity from SHRUG (DMSP 1994–2013, VIIRS 2012–2023), providing continuous annual measurement of economic activity for ~640,000 villages over 30 years.

**Identification:** Staggered difference-in-differences exploiting the three-phase rollout. Callaway and Sant'Anna (2021) heterogeneity-robust estimator with never-treated or not-yet-treated as comparison groups. Dynamic treatment effects traced over 15 years post-treatment for Phase I.

**Why it's novel:**
- Cook & Shah (2022, *Review of Economics and Statistics*) studied MGNREGA + nightlights but only through 2013 (7 years post), at district level, with biased TWFE. We extend to 15+ years, use village-level granularity (640K vs 640 units), and apply modern heterogeneity-robust methods.
- The core question shifts from "does MGNREGA increase output?" (established: yes, 1–2% per Cook & Shah) to "does it catalyze long-run structural transformation or merely provide transitory transfers?" This requires exactly the long horizon our data provides.
- Heterogeneity analysis by baseline SC/ST share, literacy, worker composition tests whether gains compound differentially.
- Massive statistical power: 640K villages × 30 years = ~19M village-year observations.

**Feasibility check:**
- ✅ Variation: Clean 3-phase stagger with 200/130/310 districts, 5+ pre-treatment years
- ✅ Data: SHRUG nightlights on disk (DMSP + VIIRS at village level)
- ✅ Phase assignment: Available from Imbert & Papp (2015) replication files on openICPSR
- ✅ Novelty: Distinguished from Cook & Shah by horizon, method, and granularity
- ✅ Power: 640K villages, massive sample

**Literature:** Cook & Shah (2022, REStat), Imbert & Papp (2015, AEJ:Applied), Muralidharan et al. (2023, Econometrica), Zimmermann (2022, JDE), Adukia (2019)


## Idea 2: Saubhagya and the Light at the End of the Wire: Rural Electrification's Impact on Village Economic Activity

**Policy:** Saubhagya scheme (Pradhan Mantri Sahaj Bijli Har Ghar Yojana) — launched October 2017. Electrified 28.6 million previously unconnected rural households by March 2019. Near-universal coverage achieved.

**Outcome:** Village-level VIIRS nightlights (2012–2023), providing ~5 years pre and ~5 years post.

**Identification:** Intensity-based difference-in-differences. Treatment intensity = pre-Saubhagya share of un-electrified households at the district level (from Census 2011 VD or SECC). High-intensity districts received more connections per capita. Event study around October 2017.

**Why it's novel:**
- No rigorous causal study of Saubhagya exists despite being the world's largest electrification push
- Direct mechanistic link: electricity → lights → nightlights (unlike most policies where nightlights are a distant proxy)
- Tests whether last-mile electrification generates economic returns or merely provides consumption amenity

**Feasibility check:**
- ⚠️ Variation: Fast rollout (Oct 2017 – Mar 2019) limits staggered variation; intensity design weaker than stagger
- ⚠️ Data: Village Directory (electrification status) NOT in local SHRUG files — would need additional download
- ✅ Novelty: No published causal study
- ⚠️ Power: Moderate — intensity variation across ~640 districts
- ⚠️ Concern: Mechanical relationship between electrification and nightlights could be a feature or a bug (measures infrastructure directly, not economic activity)

**Literature:** Burlig & Preonas (2016, unpublished), Lee et al. (2020, REStat — Kenya electrification), Dinkelman (2011, AER — South Africa), van de Walle et al. (2017, JDE — Vietnam)


## Idea 3: MGNREGA and the Feminization of Rural Work: Long-Run Effects on Female Workforce Participation

**Policy:** Same MGNREGA 3-phase rollout as Idea 1. MGNREGA has a statutory 33% female participation mandate.

**Outcome:** Female worker share from Census PCA (1991, 2001, 2011) — specifically the ratio of female main/marginal workers to total female population, by worker type (cultivator, agricultural laborer, household industry, other).

**Identification:** Staggered DiD at village level using Census cross-sections. Phase I villages (treated 5 years by Census 2011) vs Phase III villages (treated 3 years). Pre-treatment: Census 1991 and 2001 female workforce. Triple-diff: female vs male workforce changes in early vs late MGNREGA districts.

**Why it's novel:**
- Afridi et al. (2023, JDE) study MGNREGA and female labor but use NSS microdata at state level with 2-3 years post. We use village-level Census data with full 1991/2001/2011 panel.
- Tests whether the 33% mandate created lasting structural change in female labor force participation or merely reflected program participation during MGNREGA work season
- Worker-type decomposition (cultivator vs ag laborer vs household industry vs other) reveals whether women moved up the occupational ladder

**Feasibility check:**
- ✅ Variation: Same 3-phase stagger
- ✅ Data: Census PCA on disk with gender-disaggregated worker data (all 3 rounds)
- ✅ Novelty: Village-level, long-run, occupational decomposition is new
- ⚠️ Concern: Only 3 Census cross-sections (1991, 2001, 2011) — cannot do annual event study. Limited to 2x2 or long-difference designs.
- ⚠️ Concern: Census 2001 is pre-MGNREGA for all phases, so effectively only 2001→2011 change with differential treatment timing


## Idea 4: Scheduled Caste Concentration and the Returns to Public Works: Heterogeneous Effects of MGNREGA

**Policy:** Same MGNREGA 3-phase rollout. SC/ST communities are primary beneficiaries.

**Outcome:** Village-level nightlights (DMSP + VIIRS, 1994–2023).

**Identification:** Same staggered DiD as Idea 1, but with heterogeneous treatment effects by baseline SC/ST population share (Census 2001). Tests whether MGNREGA's long-run effects differ for high-SC/ST vs low-SC/ST villages — probing whether the program reduced or reinforced caste-based economic inequality.

**Why it's novel:**
- No study examines caste-disaggregated long-run MGNREGA effects at village level
- SC/ST villages are theoretically most affected (higher program take-up, greater asset creation, more binding labor market constraints)
- Speaks to whether targeted public works can reduce spatial caste inequality

**Feasibility check:**
- ✅ This is essentially a heterogeneity analysis within Idea 1 — same data, same design
- ✅ SC/ST share from Census 2001 PCA is on disk
- ⚠️ Could be incorporated as a section within Idea 1 rather than standalone paper
