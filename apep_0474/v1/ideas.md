# Research Ideas

## Idea 1: Downtown for Sale? Commercial Displacement Effects of France's Action Cœur de Ville Program

**Policy:** Plan Action Cœur de Ville (ACV) — a €5 billion place-based revitalization program targeting 222 medium-size French city centers, announced March 26, 2018. Investment axes include housing rehabilitation, commercial development, public space enhancement, accessibility, and public services. Phase 2 (ACV2) extended 2023–2026 with convention renewals and new additions. Convention signing dates span October 2018 through 2024, providing staggered treatment timing.

**Outcome:** INSEE Sirene establishment registry (open data, data.gouv.fr). Universe of all French establishments (active + ceased) since 1973, with creation date, cessation date, commune code (INSEE), NAF sector code, and employee size range. ~36 million establishments, 2.1 GB parquet. Construct a **Downtown Commercial Vitality Index**: net establishment creation in retail (NAF 47.xx), hospitality (55-56.xx), and personal services (96.xx) for ACV communes relative to surrounding non-ACV communes in the same département. Supplementary outcomes: sector composition shifts, new establishment size, employment (employee size codes).

**Identification:** Staggered DiD with Callaway–Sant'Anna estimator. 222+ treated communes vs matched untreated communes. Treatment defined as (a) ITT at March 2018 announcement for Phase 1 cities, and (b) convention signing dates for Phase 2 additions. Pre-treatment: 2012–2017 (6 years, quarterly Sirene establishment counts). Post-treatment: 2018–2025 (7+ years). Matched control group from ~35,000 French communes using propensity score on pre-treatment population, commercial density, unemployment rate, and housing vacancy.

**Why it's novel:**
- The Cour des Comptes (2022) explicitly stated "les indicateurs actuels ne permettent pas d'établir précisément l'impact du programme." No causal evaluation exists.
- Zero published DiD, RDD, or experimental economics papers on ACV (searched Google Scholar, NBER, CEPR, HAL, SSRN).
- Novel measurement object: the center-periphery commercial gradient from Sirene, testing whether ACV displaced activity rather than creating it.
- Counter-intuitive equilibrium question: did a €5B downtown program merely reshuffle economic activity within metropolitan areas?

**Feasibility check:**
- ✅ Commune list with INSEE codes: downloadable CSV from data.gouv.fr (13.8 KB, 244 communes, includes `date_signature`)
- ✅ Sirene data: open, free, 2.1 GB parquet, covers all years
- ✅ Treated units: 222+ cities (far above 20 minimum)
- ✅ Pre-periods: 6+ years (2012–2017) from Sirene
- ✅ Not overstudied: zero causal papers
- ⚠️ Selection not random (prefect discretion) — requires careful matching and HonestDiD
- ⚠️ Bundled policies (Denormandie tax incentive Jan 2019, ORT) — discuss as treatment package
- ⚠️ COVID (2020–2021) differentially affected medium vs large cities — time FE, urban/rural controls

---

## Idea 2: Does Rental Licensing Improve Housing Quality or Just Reduce Supply? Evidence from France's Permis de Louer

**Policy:** The "Permis de Louer" (rental licensing), created by Loi ALUR (March 2014), implemented via decree (December 2016), and expanded by Loi ELAN (November 2018). Requires landlords to obtain prior authorization or file a declaration before renting properties in designated zones. Over 500 communes have adopted it at different dates since 2017, targeting areas with significant substandard housing ("habitat indigne").

**Outcome:** DVF (Demandes de Valeurs Foncières) property transaction data — universe of French real estate transactions with prices, commune codes, property characteristics. Available 2020H2–2025. Supplementary: DPE energy performance ratings from ADEME (proxy for housing quality), Sirene for property management firms.

**Identification:** Staggered DiD. 500+ treated communes with different adoption dates vs never-treated communes. Callaway–Sant'Anna estimator. For communes adopting in 2022+, DVF provides 6–16 quarters of pre-treatment data. The key question: does the rental permit reduce property sale prices (regulatory burden → lower asset value) or increase them (quality signal → premium)?

**Why it's novel:**
- Zero published causal economics papers on the French permis de louer (searched Google Scholar, NBER, CEPR)
- Thin international literature: only Petersen et al. (2022, BMJ Open) on UK selective licensing
- Tests the classic quality-quantity tradeoff in housing regulation with administrative universe data
- First-order stakes: 600,000 substandard housing units in France

**Feasibility check:**
- ✅ Treated units: 500+ communes (well above 20 minimum)
- ✅ Staggered timing: 2017–2025 (continuous adoption)
- ✅ DVF data: open, free, transaction-level
- ✅ Novelty: essentially zero causal papers
- ❌ **CRITICAL**: No centralized dataset of commune-level adoption dates. Must be compiled from scattered sources (departmental shapefiles exist for Hérault and Pas-de-Calais; rest requires scraping préfecture records)
- ⚠️ DVF only covers 2020H2+, limiting pre-periods for early adopters

---

## Idea 3: The Energy Penalty — How France's Rental Ban on Low-DPE Housing Reshaped Property Values

**Policy:** Loi Climat et Résilience (August 22, 2021) established staggered rental bans by DPE energy performance rating: G-rated properties banned from rental market January 2025, F-rated January 2028, E-rated January 2034. Combined with the DPE reform of July 1, 2021 (new stricter methodology). Affects ~4.8 million "passoires thermiques" (energy sieves).

**Outcome:** DVF property transactions (2020H2–2025) linked to ADEME DPE database (14M+ records since July 2021, 10.7M pre-2021). Construct the "energy penalty" — the DPE-specific price discount in property sales, measured as the G-D price gap before vs after the Loi Climat announcement.

**Identification:** DDD (triple-difference): DPE rating (G/F vs D/C) × Time (pre/post August 2021 announcement) × Property characteristics. Or event study around announcement date with rating-specific trends. G-rated properties are most exposed to the ban; D-rated are unaffected — this rating-based variation substitutes for geographic staggering.

**Why it's novel:**
- Live policy frontier — G-ban just started January 2025
- 4.8 million affected units (massive scale)
- No causal paper with transaction-level DVF × DPE linked data
- Counter-intuitive mechanism possible: forced renovation may improve housing stock value in the long run

**Feasibility check:**
- ✅ DVF and DPE both freely downloadable, large N
- ✅ Scale: millions of transactions and DPE assessments
- ⚠️ DVF-DPE linkage requires address matching (feasible but non-trivial)
- ⚠️ Short pre-announcement period: 2020H2 to 2021Q3 (4–5 quarters)
- ⚠️ DPE rating is a property characteristic, not geographic treatment — less "sharp edge"
- ⚠️ DPE rating may be endogenous to unobserved property quality

---

## Idea 4: Rent Control and Firm Creation — Evidence from France's Staggered Encadrement des Loyers

**Policy:** Encadrement des loyers (rent level caps) staggered across French cities: Paris (July 2019), Lille (March 2020), Plaine Commune (June 2021), Lyon+Villeurbanne (November 2021), Est Ensemble (December 2021), Montpellier (July 2022), Bordeaux (July 2022), Pays Basque (November 2024), Grenoble (January 2025). 69 communes across 9 territories as of early 2026.

**Outcome:** Sirene establishment registry — firm creation counts by commune × quarter × sector. Test whether rent control reduces housing costs for potential entrepreneurs, encouraging firm creation (Xiao & Xiao 2020 mechanism), or freezes labor mobility, reducing firm entry.

**Identification:** Staggered DiD or synthetic control. 9 treatment cohorts with 6 distinct adoption dates (2019–2025). For Paris and Lille, long pre/post windows exist. Sirene provides deep pre-treatment data.

**Why it's novel:**
- Zero papers linking French rent control to firm dynamics
- Only 1 published paper on modern French rent control (Morin et al. 2025 JHE, Paris only, rents not firms)
- Tests competing mechanisms: housing stability → entrepreneurship vs. mobility lock-in → reduced entry

**Feasibility check:**
- ✅ Sirene data: excellent, free, deep coverage
- ✅ Novelty: completely unstudied angle
- ❌ **CRITICAL**: Only 9 treatment cohorts — FAILS the ≥20 treated unit rule for DiD
- ⚠️ Would need synthetic control for Paris/Lille (feasible but different method)
- ⚠️ DVF doesn't record rents — cannot verify first stage in DVF
