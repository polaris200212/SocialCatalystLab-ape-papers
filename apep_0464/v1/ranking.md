# Research Idea Ranking

**Generated:** 2026-02-26T16:25:53.020326
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 8408

---

### Rankings

**#1: Connected Backlash: Social Networks, Carbon Tax Incidence, and the Political Economy of Climate Policy in France**
- Score: **72/100**
- Strengths: Clever, policy-relevant setting where a *national* policy has large *local incidence* variation, and the Gilets Jaunes episode provides a salient political “shock” that plausibly interacts with network transmission. Data availability is unusually strong (elections, fuel prices/consumption, INSEE covariates, SCI).
- Concerns: The core exclusion restriction is the standard SCI problem: network links are endogenous (homophily) and “connected départements’ fuel vulnerability” may proxy for shared rurality/industrial structure and common political trends. Only three clean pre-period elections limits pre-trend diagnostics for the event-study component.
- Novelty Assessment: **High** for the specific combination (carbon-tax incidence × SCI network exposure × far-right vote response in France). Related literatures exist (SCI diffusion papers; carbon-tax attitudes; far-right voting), but this exact intersection is not yet crowded.
- DiD Assessment (event-study around Nov 2018, high vs low network exposure):
  - Pre-treatment periods: **Marginal** (effectively 2012/2014/2017 = 3 pre elections; not 5+)
  - Selection into treatment: **Marginal** (exposure is “predetermined” but plausibly correlated with persistent geography/culture)
  - Comparison group: **Marginal** (high- vs low-exposure areas likely differ systematically; needs strong balancing/controls and robustness)
  - Treatment clusters: **Strong** (96 départements; commune-level outcomes also available)
  - Concurrent policies: **Marginal** (2017–2019 includes macro trends, immigration/salience shocks, etc.; must argue why exposure interacts specifically with fuel-tax incidence/GJ)
  - Outcome-Policy Alignment: **Strong** (RN vote share is a direct political-economy margin plausibly affected by perceived regressive tax incidence/backlash)
  - Data-Outcome Timing: **Strong** (key “post” election is EU May 2019, clearly after Nov 2018; later elections 2022/2024 also post)
  - Outcome Dilution: **Strong** (fuel taxes affect a large share of households directly/indirectly; not a 5–10% targeted policy)
- Recommendation: **PURSUE (conditional on: (i) strong pre-trend / placebo exercises using earlier elections and non-fuel-tax “pseudo shocks”; (ii) distance-restricted SCI + rich controls + alternative network measures; (iii) shift-share inference consistent with recent Bartik/shift-share diagnostics and standard errors)**

---

**#2: Social Networks and the Diffusion of Firm Creation Across French Départements**
- Score: **63/100**
- Strengths: Sirene is exceptionally rich (near-universe of firms with dates/sectors), giving power and permitting tight outcome definitions (births by sector, survival, composition). A network-diffusion angle on entrepreneurship is genuinely new and could be publishable even in reduced form.
- Concerns: Identification of *network transmission* (vs correlated regional cycles, migration, sector reallocation, or shared demand shocks) will be hard; the proposed Bartik + SCI layering risks “IV on IV” fragility and weak instruments. National reforms (auto-entrepreneur) are not naturally staggered, so credible quasi-experimental variation must come from clearly exogenous sectoral shocks or localized programs (ZFU, guarantees) with clean timing and eligibility.
- Novelty Assessment: **Moderate-High**. Many entrepreneurship/Bartik papers exist, but SCI-based diffusion of firm creation is not saturated (especially in France with Sirene).
- Recommendation: **CONSIDER (conditional on: (i) anchoring identification on a small number of clearly exogenous, well-timed shocks with transparent first stages; (ii) demonstrating that SCI adds predictive power beyond geography via distance-restricted networks and spatial HAC designs; (iii) presenting falsification tests using sectors plausibly unaffected)**

---

**#3: Social Networks and Housing Market Information Transmission: A Structural Approach Using French Property Transactions**
- Score: **52/100**
- Strengths: DVF is outstanding, high-frequency, and spatially granular; housing is a first-order policy area. The “information transmission” mechanism is plausible, and a careful reduced-form could be valuable even without the full structural model.
- Concerns: As written, the policy variation (ZFEs, Pinel zones, vacancy taxes) is geographically narrow (metro areas / specific communes) while the proposed outcome is **département-quarter prices**, creating serious treatment dilution and misalignment. Housing prices are dominated by interest rates/credit conditions and national macro shocks (especially 2019–2024), making exclusion restrictions for “connected-area shocks” very difficult.
- Novelty Assessment: **Moderate**. There is a large housing-information and spatial spillovers literature; SCI + within-France housing is less explored, but the marginal novelty hinges on whether you can credibly isolate an SCI channel.
- DiD Assessment (if using staggered ZFE adoption as the main quasi-experiment):
  - Pre-treatment periods: **Strong** (DVF covers many years pre-2020)
  - Selection into treatment: **Weak** (ZFEs adopted/expanded in places with pollution/traffic and likely different housing trends—endogenous to urban dynamics)
  - Comparison group: **Marginal** (non-ZFE départements differ structurally from big metros)
  - Treatment clusters: **Marginal** (~11 metros; inference is fragile)
  - Concurrent policies: **Weak** (COVID, rate swings, national housing policies coincide; hard to attribute to ZFE timing)
  - Outcome-Policy Alignment: **Weak** (département-level prices are not tightly linked to ZFE zones; the “treated” geography is a small slice)
  - Data-Outcome Timing: **Strong** (transaction dates allow precise alignment to effective dates)
  - Outcome Dilution: **Weak** (ZFE affects a minority of département transactions in many cases—often well below 20%)
- Recommendation: **SKIP (in current form)**. **CONSIDER** only if redesigned around *high-resolution geography* (commune/IRIS) and a cleaner design (e.g., boundary discontinuities around ZFE perimeters; or narrowly targeted policies with clearer exposure).

---

**#4: Networks of Resistance: Social Connections and the Spatial Propagation of the Gilets Jaunes Movement**
- Score: **48/100**
- Strengths: Substantively compelling and genuinely novel: SCI is a natural fit because Facebook coordination was central. Weekly frequency creates a rich diffusion environment for testing propagation models.
- Concerns: Data feasibility is the dealbreaker: no single validated, public département-week protest panel; constructing it from press/KML/Google Trends risks severe measurement error and non-classical bias (media attention correlates with political outcomes). With only 96 départements, inference is also sensitive to specification and outliers.
- Novelty Assessment: **High**, but novelty cannot compensate for shaky measurement.
- Recommendation: **SKIP (unless you secure a credible administrative/archival protest dataset with consistent coverage and definitions, ideally from Interior Ministry or a replicable research archive)**

---

**#5: Digital Networks and Democratic Contagion: Social Connections and the Spatial Diffusion of RN Voting in France, 2002-2024**
- Score: **42/100**
- Strengths: Long panel and high policy salience; could become a descriptive reference if carefully executed. Commune-level elections data are strong.
- Concerns: The scope is too broad to identify anything cleanly: multiple shocks, overlapping mechanisms, many opportunities for specification searching, and very weak exclusion restrictions for “SCI-weighted shocks” (they plausibly affect RN vote through many channels besides network contagion). SCI is time-invariant (snapshot) while the analysis spans 2002–2024, raising additional interpretation issues.
- Novelty Assessment: **Low-Moderate**. Far-right voting and economic shocks is a large literature; “diffusion/contagion” framing is not new, and SCI-based political influence has close cousins in other settings.
- Recommendation: **SKIP (unless narrowed to one shock with crisp timing/incidence, essentially converging toward Idea 1’s focused design)**

---

### Summary

This is a strong batch on *data access* and topical relevance, but only one idea (Idea 1) currently combines novelty with a plausibly defensible identification strategy. I would pursue **Idea 1 first**, with tight pre-trend/placebo work and careful handling of SCI endogeneity; **Idea 3** is the best backup if you can anchor it on truly exogenous, well-timed shocks. The ZFE/housing DiD angle (Idea 4) fails on treatment dilution and endogeneity as stated, and the Gilets Jaunes diffusion idea (Idea 2) is primarily blocked by protest data feasibility.