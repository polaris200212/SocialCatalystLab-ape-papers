# Research Ideas

## Idea 1: Where the Money Moves — Within-Category Budget Reallocation Under Gender Quotas in Spain

**Policy:** Spain's 2007 Equality Law (Ley Orgánica 3/2007) mandates 40-60% gender balance on municipal candidate lists for municipalities above 5,000 inhabitants (Article 44 bis LOREG). Extended to municipalities above 3,000 in 2011. Enforcement: non-compliant lists are rejected by the Junta Electoral — hard veto, not a fine.

**Outcome:** CONPREL executed municipal budgets (liquidaciones) from Ministerio de Hacienda. Post-2010 program classification (Orden EHA/3565/2008) provides spending at 3-digit program level. Key education subcategories:
- Program 321: Infant and primary education centers (construction, equipment)
- Program 323: Operations for infant/primary and special education
- Program 326: Complementary education services (school meals, transport, extracurricular)
- Program 334: Cultural promotion and libraries
- Program 132: Security and public order (placebo: "male-coded")
- Program 231: Primary social assistance
- Program 311/312: Health promotion and hospitals

Within-education composition shares (321 vs 323 vs 326 as shares of total education) are the primary outcomes. HHI within education is a secondary outcome.

**Identification:** Multi-cutoff population-threshold RDD.
- **Cutoff 1:** 5,000 inhabitants (2007 and 2011 elections)
- **Cutoff 2:** 3,000 inhabitants (2011, 2015, 2019, 2023 elections)
- Running variable: official Padrón Municipal population (INE, annual)
- First stage: female councillor share (directly measured via `sexo` field in Ministry of Interior candidate files)
- Reduced form: budget composition shares around thresholds
- Fuzzy RD: instrument female councillor share with threshold indicator

**Why it's novel:** Every existing paper (Bagues & Campa 2021 Spain, Ferreira & Gyourko 2014 US, Geys & Sørensen 2019 Norway, apep_0433 France, Casarico et al. 2022 Italy) finds null effects of female politicians on budget composition at the broad category level (total education vs total health vs total infrastructure). NONE decomposes within categories. The contribution is testing whether aggregate nulls mask within-category reallocation — e.g., total education spending stays flat while the composition shifts from secondary toward early childhood and school meals.

**Feasibility check:**
- Variation: Clean population threshold with two cutoffs. Bagues & Campa validated the design.
- Data: CONPREL .accdb files downloadable without registration (HTTP 200 confirmed, ~55MB/year). 659K program-level spending records per year for ~8,900 municipalities. Election data from Ministry of Interior with direct gender coding.
- Novelty: Not in APEP list. No paper on Google Scholar does within-education budget decomposition.
- Sample: ~8,100 municipalities × 14 years (2010-2023) = ~113K municipality-years. ~2,000 municipalities near the 5,000 cutoff (bandwidth ±2,000). ~3,000 near the 3,000 cutoff.

**Puzzle-resolver framing:** "Why do all European gender-quota papers find null effects on budgets? Because they look at the wrong level of aggregation. Female politicians don't increase total education spending — they shift what education money buys."


## Idea 2: From Councils to Crèches — Gender Quotas and Downstream Service Provision in Spain

**Policy:** Same as Idea 1 — Spain's 2007/2011 Equality Law.

**Outcome:** Instead of budget data, use the EIEL (Encuesta de Infraestructuras y Equipamientos Locales) — a national census of infrastructure and facilities for municipalities under 50,000. Reports counts of childcare centers, schools, health centers, cultural facilities, sports facilities by municipality. Combined with INE demographic data (births, female employment by sector).

**Identification:** Same multi-cutoff RDD.

**Why it's novel:** Tests whether the budget-composition null translates to a facility-provision null. If female politicians shift budgets toward early childhood within the education category, this should eventually show up in more childcare facilities and better school infrastructure. The EIEL is underused in the academic literature.

**Feasibility check:**
- EIEL data available on datos.gob.es with municipality-level facility counts
- INE demographic data (births, employment) available via API
- However: EIEL is periodic (not annual), coverage varies by province, and facility counts are slow-moving stocks that may not respond to 4-year council terms
- Risk: Stock outcomes unlikely to move in short horizons (a known tournament penalty)


## Idea 3: The Zipper and the Zero — Reconciling Global Evidence on Gender Quotas and Public Finance

**Policy:** Multi-country comparative design: Spain (5,000 threshold), France (1,000 threshold, from apep_0433 data), and Italy (5,000 threshold, from Andreoli et al. 2022).

**Outcome:** Standardized budget composition measures across three countries, using country-specific administrative data.

**Identification:** Meta-RDD: estimate discontinuities at each country's threshold, then compare magnitude and sign of within-category effects across institutional contexts.

**Why it's novel:** No cross-country study of within-category budget effects exists. Tests whether the "fiscal constraints" explanation for European nulls (apep_0433) holds across different levels of fiscal decentralization.

**Feasibility check:**
- Spain data confirmed accessible
- France data limited to broad categories (no functional data below 3,500)
- Italy data (OpenBDAP) not yet tested
- Risk: Heroic data collection across 3 countries. Inconsistent granularity across countries' budget classifications. May be too ambitious for a single paper.


## Idea 4: Do Female Politicians Protect Education Spending During Austerity? Evidence from Spain's LRSAL Reform

**Policy:** The 2013 Ley de Racionalización y Sostenibilidad de la Administración Local (LRSAL) reduced municipal fiscal autonomy, especially in social services. Combined with the gender quota at 5,000/3,000 thresholds.

**Outcome:** Change in education subcategory spending before/after LRSAL, interacted with female councillor share.

**Identification:** Triple-difference: above/below population threshold × pre/post LRSAL × spending category. Tests whether female-dominated councils resist austerity cuts to family-relevant services.

**Why it's novel:** García & Hayo (2023) found that gender-balanced governments in Madrid-region municipalities maintained social spending despite LRSAL, but they used a narrow geographic sample and broad spending categories. A national sample with within-education decomposition and the quota-driven RDD would be much stronger.

**Feasibility check:**
- Clean DDD design exploiting both quota threshold and LRSAL timing
- LRSAL is a known, well-documented policy shock (effective December 2013)
- Same CONPREL data
- Risk: Bundling LRSAL + quota creates a 2-dimensional treatment; may be hard to separate mechanisms
