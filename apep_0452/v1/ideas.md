# Research Ideas

## Idea 1: Paper Treaties — Does the Minamata Convention Reduce Mercury Use in Africa's Artisanal Gold Mines?

**Policy:** The Minamata Convention on Mercury (adopted 2013, entered into force August 2017). Article 7 specifically targets artisanal and small-scale gold mining (ASGM), requiring ratifying countries to develop National Action Plans (NAPs) to reduce and eliminate mercury use. 38 African countries have ratified between 2014 and 2024, with staggered adoption providing excellent temporal variation. A second treatment margin exists: 27 African countries have submitted NAPs (substantive policy action beyond formal ratification), also staggered (2019-2024).

**Outcome:** Primary: Mercury imports by country-year (UN Comtrade, HS 280540), available from the 1990s onward. Secondary: Gold exports (UN Comtrade), nighttime light emissions in gold-prone grid cells (VIIRS/DMSP via World Bank Light Every Night), tree cover loss in mining areas (Global Forest Watch/Hansen). WDI indicators for controls.

**Identification:** Doubly Robust Difference-in-Differences (Sant'Anna and Zhao 2020). Treatment is staggered ratification of the Minamata Convention across African countries. The DR-DiD estimator jointly models (i) the propensity to ratify based on pre-treatment covariates (GDP, governance quality, gold production, ASGM prevalence, EU mercury trade dependence) and (ii) the outcome regression for mercury imports. This addresses the key concern that early ratifiers (e.g., Djibouti 2014, Gabon 2014) differ systematically from late ratifiers (e.g., Ethiopia 2024, Kenya 2023). Important hold-outs — DRC and Sudan, both major ASGM countries — serve as never-treated controls. Callaway and Sant'Anna (2021) group-time ATTs handle heterogeneous treatment effects across adoption cohorts.

**Why it's novel:** No causal evaluation of the Minamata Convention's effect on ASGM exists. The convention's first formal effectiveness evaluation is not scheduled until 2027. Preliminary evidence from the 2024 Progress Report suggests mercury use in ASGM has NOT decreased and may have increased — making a rigorous null result both publishable and policy-relevant. Girard, Molina-Millán, and Vic (2025, Economic Journal) published a top-5 paper studying ASGM impacts (deforestation, wealth) using geological suitability × gold prices, establishing that rigorous causal work on African ASGM is viable at the highest level. Our paper evaluates POLICY effectiveness, not mining impacts — a complementary and distinct contribution.

**Feasibility check:**
- Variation: 38 African ratifiers staggered across 2014-2024 (well above 20 treated units). Two treatment margins (ratification + NAP). Hold-out controls (DRC, Sudan, Tunisia).
- Data: Mercury imports confirmed accessible via WITS/UN Comtrade (HS 280540). 15+ African countries with mercury import records. Gold exports similarly accessible. WDI, WGI confirmed via World Bank API. Nightlights via VIIRS (2012+) and DMSP (1992-2013).
- Novelty: Zero existing causal evaluations confirmed via extensive literature search.
- Sample: ~54 African countries × 20+ years (2000-2024) = 1,000+ country-years. ~38 treated × 10+ pre-treatment years for parallel trends testing.


## Idea 2: Choking the Supply — The EU Mercury Export Ban and Artisanal Gold Mining in Africa

**Policy:** EU Regulation No 1102/2008, effective March 15, 2011, banning all exports of metallic mercury and certain mercury compounds. The EU was the world's largest mercury exporter, responsible for approximately 25% of global supply. The US followed with its own Mercury Export Ban Act in January 2013. These supply-side restrictions created an exogenous shock to mercury availability for ASGM in Africa.

**Outcome:** Mercury import volumes and values by country-year (UN Comtrade, HS 280540). Trade partner composition (share from EU pre vs. post ban). Gold exports. Mirror trade discrepancies (importer-reported vs. exporter-reported mercury flows) as a proxy for smuggling, following Fritz et al. (2022, ES&T).

**Identification:** Doubly Robust (DR) estimator with continuous treatment intensity. Treatment exposure = pre-ban EU mercury import dependence (share of total mercury imports sourced from EU countries in 2005-2010). Countries with higher pre-ban EU dependence are "more treated" by the ban. DR jointly models treatment assignment (which countries were EU-dependent) and outcomes. Pre/post comparison: 2005-2010 vs. 2012-2020. Controls: GDP, governance, gold production, industrial mining, geographic region.

**Why it's novel:** No causal evaluation of mercury export bans on ASGM exists. The literature documents that the EU ban rerouted mercury through East Asian and Latin American intermediaries, created smuggling networks, and may have simply changed supply chains rather than reducing mercury access. A rigorous evaluation would be the first to quantify these effects and test whether supply-side restrictions can reduce artisanal mining mercury use when demand is inelastic.

**Feasibility check:**
- Variation: Single shock (March 2011) with continuous cross-country exposure intensity. EU import dependence varies substantially across African countries.
- Data: Mercury imports from WITS/UN Comtrade confirmed. Trade partner decomposition available. Mirror statistics for smuggling detection.
- Novelty: No existing evaluation. Fritz et al. (2022) developed detection method for illegal trade but did not do a causal evaluation of the ban itself.
- Sample: ~54 African countries × 15 years (2005-2020). CONCERN: Mercury import data may be sparse for many African countries, limiting effective sample size. Only ~15 countries show non-zero mercury imports in 2023 WITS data.


## Idea 3: When Treaties Meet Price Booms — Gold Shocks, Mining Governance, and ASGM Expansion in Africa

**Policy:** Interaction of Minamata Convention ratification with gold price shocks. Building on Girard et al. (2025, EJ) who show ASGM expands when gold prices rise (using geological suitability × price variation), this paper asks: does the Minamata Convention moderate the relationship between gold prices and ASGM expansion? If the treaty works, it should dampen the mercury-intensive ASGM response to gold price booms.

**Outcome:** Tree cover loss in gold-suitable grid cells (Global Forest Watch/Hansen), nighttime light emissions in mining areas (VIIRS/DMSP), gold exports. Mercury imports as mediator.

**Identification:** DR panel estimator with triple interaction: Gold geological suitability (cell-level, time-invariant) × Gold price (global, time-varying) × Minamata ratification (country-level, staggered). The DR component models the propensity of being in a "high-suitability" cell and the outcome regression jointly. Parallels the shift-share / Bartik approach where gold suitability is the "share" and gold prices are the "shift."

**Why it's novel:** Girard et al. (2025) study ASGM impacts on deforestation and wealth, but do not evaluate any policy. This paper adds the policy dimension — does international environmental treaty ratification change the ASGM expansion response to economic incentives? Novel triple-interaction of geology × prices × policy.

**Feasibility check:**
- Variation: Gold suitability (continuous, cell-level), gold prices (continuous, time-varying), Minamata ratification (binary, country-level, staggered). Rich three-way variation.
- Data: Geological suitability available from Girard et al. methodology (bedrock mapping). Gold prices from FRED/World Gold Council. Tree cover loss from Hansen/GFW. Nightlights from VIIRS.
- Novelty: The specific triple interaction has not been studied.
- Sample: Following Girard et al., ~10,628 grid cells × 20+ years. Very large sample, high power.
- CONCERN: Complex triple interaction with many fixed effects may be difficult to estimate precisely. The Minamata variation is at the country level (N~54), limiting effective identifying variation. Also requires replicating/extending the Girard et al. geological suitability mapping, which is non-trivial.


## Idea 4: EITI Membership and Artisanal Mining Governance in Africa

**Policy:** Extractive Industries Transparency Initiative (EITI). 24 African countries are members with staggered candidate/compliant status dates spanning 2003-2020s.

**Outcome:** Control of corruption (WGI), resource governance indicators, mining revenues, gold exports.

**Identification:** DR-DiD exploiting staggered EITI compliance.

**Why it's novel:** MODERATE — Multiple DiD evaluations of EITI exist (Corrigan 2014, Kasekende et al. 2016, several 2024 papers using heterogeneity-robust DiD). The specific angle on ARTISANAL mining outcomes (vs. general governance) would be somewhat novel but builds on well-trodden ground.

**Feasibility check:**
- Variation: 24 African EITI members, staggered. PASS.
- Data: WGI, WDI, Comtrade. PASS.
- Novelty: LOW. Well-studied policy.
- REJECT on novelty grounds.
