# Research Ideas — apep_0428

## Idea 1: Roads and the Gender Gap — Do Rural Roads Empower Women?

**Policy:** India's Pradhan Mantri Gram Sadak Yojana (PMGSY), which provides all-weather roads to unconnected rural habitations. Villages above 500 population (250 in tribal/hill areas) were prioritized. Program started 2000, ongoing.

**Outcome:** Gender-specific outcomes from SHRUG Census data — female literacy rate, female labor force participation, female non-worker share, gender gap in education and employment. Census 2001 (baseline) vs Census 2011 (10 years post). Nightlights 1994-2023 as continuous annual proxy.

**Identification:** Fuzzy RDD at the 500 population threshold (Census 2001). Villages just above 500 were eligible; those just below were not. First stage: eligibility → road construction. Reduced form: eligibility → gender outcomes. Can also exploit the 250 threshold in tribal/hill areas as a separate RDD.

**Why it's novel:**
- Asher & Novosad (2020 AER) is the benchmark PMGSY RDD paper. They found labor reallocation out of agriculture but NULL effects on income/consumption.
- **No existing study focuses on gender-specific effects of PMGSY using the RDD design.** Roads reduce travel costs to schools, markets, and health centers — but could also increase male out-migration. The net effect on gender outcomes is theoretically ambiguous.
- Gender and development is a first-order policy question in India (female LFPR was only 32.8% in 2017-18).

**Feasibility check:**
- ✅ Running variable: `pc01_pca_tot_p` in `pc01_pca_clean_shrid.csv` (593K villages)
- ✅ Dense around threshold: 39K villages in 400-499, 36K in 500-599 range
- ✅ Gender outcomes: `pc01_pca_*_f` and `pc11_pca_*_f` (female population, literacy, workers) all available
- ✅ Nightlights: DMSP 1994-2013, VIIRS 2012-2023 at village level
- ⚠️ Need PMGSY road construction data for first stage (available via SHRUG PMGSY download or OMMAS portal; ITT works without it)

---

## Idea 2: The Long Road to Development — Dynamic Effects of Rural Roads Over Two Decades

**Policy:** Same PMGSY program. But focus is on the TIME PATH of effects — how do road effects evolve from 0 to 23 years post-construction?

**Outcome:** Annual nightlights (DMSP 1994-2013, VIIRS 2012-2023) as continuous economic activity proxy. Census outcomes at two post-treatment snapshots (Census 2001 baseline, Census 2011 at ~10 years).

**Identification:** Same fuzzy RDD at 500 threshold. But the contribution is the EVENT STUDY: estimate year-by-year RDD treatment effects from 1994 to 2023, showing the full dynamic trajectory.

**Why it's novel:**
- Asher & Novosad had ~12 years of post-treatment nightlights (DMSP through 2012). We have 23 years including high-resolution VIIRS.
- They found null income effects at 4 years. The fundamental question: **do roads eventually deliver returns (compounding) or is the null permanent (roads don't help)?**
- Dynamic infrastructure effects are central to development economics but almost never estimated at this time horizon.
- A null at 23 years would be a powerful challenge to conventional wisdom about infrastructure investment.

**Feasibility check:**
- ✅ Same running variable and threshold as Idea 1
- ✅ VIIRS nightlights 2012-2023 at village level (14M rows across 12 years)
- ✅ DMSP nightlights 1994-2013 at village level (19M rows across 20 years)
- ✅ Calibration possible using 2012-2013 overlap period
- ⚠️ Same PMGSY first-stage caveat as Idea 1

---

## Idea 3: Connecting the Most Remote — Road Access and Development in India's Tribal Areas

**Policy:** PMGSY's lower threshold of **250 population** for tribal/hill/desert designated areas (Fifth Schedule areas, NE hill states, desert districts).

**Outcome:** Census 2001 vs 2011 outcomes (population growth, literacy, worker composition, ST development) and nightlights in tribal villages.

**Identification:** Fuzzy RDD at the 250 threshold, restricted to villages in designated tribal/hill/desert areas. Compare villages just above vs just below 250.

**Why it's novel:**
- The 250 threshold is virtually unstudied. All PMGSY RDD papers use the 500 threshold.
- Tribal areas (102K villages with >50% ST in Census 2001) face distinct development challenges: geographic isolation, weak state capacity, lower baseline human capital.
- PMGSY was explicitly designed with a lower threshold for these areas — testing whether this targeting works is directly policy-relevant.
- Can compare 250-threshold effects to 500-threshold effects to ask: does road access matter MORE for more remote communities?

**Feasibility check:**
- ✅ Running variable: same `pc01_pca_tot_p`
- ✅ 22.6K villages in 200-249 range, 22.0K in 250-299 — sufficient density
- ✅ 102K villages with >50% ST population; 270K with any ST population
- ⚠️ Need to identify "designated tribal/hill/desert areas" — can proxy with state (NE states) + ST population share (>50% = Schedule V area likely)
- ⚠️ Smaller bandwidth may reduce power

---

## Idea 4: Do Aligned Politicians Deliver? Close Elections and Village Development in India

**Policy:** State assembly elections in India, where the margin of victory creates an RDD. Treatment = having an MLA aligned with the state ruling party (vs. opposition).

**Outcome:** Village-level development indicators from SHRUG: nightlights change (annual), Census 2001→2011 changes in infrastructure, literacy, employment. Constituency-level aggregates available in SHRUG con07/con08 files.

**Identification:** Close-election RDD at vote margin = 0. Compare constituencies where the ruling party candidate barely won vs barely lost. Running variable: vote margin from TCPD election data.

**Why it's novel:**
- Political alignment and distributive politics is well-studied but rarely with village-level outcome data.
- SHRUG's constituency-level aggregates link ~640K villages to ~4,000 state assembly constituencies.
- Can examine multiple elections (1990s-2010s) for heterogeneity across time and parties.
- TCPD data is freely available on GitHub (Indian Elections Dataset, 1962-present).

**Feasibility check:**
- ✅ TCPD data downloadable from GitHub (confirmed accessible)
- ✅ SHRUG has constituency-level aggregates (con07, con08 files with rich variables)
- ✅ Nightlights available annually for event study design
- ⚠️ Need to download TCPD data and match constituency IDs to SHRUG
- ⚠️ Need to compile state ruling party data (public knowledge but manual work)
- ⚠️ May face "close elections are not random" critique (De La Cuesta & Imai 2016)
