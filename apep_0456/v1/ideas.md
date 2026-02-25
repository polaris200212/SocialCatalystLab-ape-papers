# Research Ideas

## Idea 1: Low Emission Zone Boundaries and Property Values — Spatial RDD on French ZFE

**Policy:** France's Zones à Faibles Émissions (ZFE) restrict polluting vehicles inside designated urban perimeters. The Loi Climat et Résilience (2021) mandated ZFE for all agglomerations above 150,000 inhabitants. Paris (Métropole du Grand Paris, inside A86) has had restrictions since 2015, progressively tightened. Lyon, Grenoble, Strasbourg, Marseille, and ~8 other cities implemented ZFE between 2019-2024, each with sharp geographic boundaries defined by polygon shapefiles.

**Outcome:** Property transaction prices and volumes from DVF (Demandes de Valeurs Foncières) — 3.8M geocoded transactions per year with 98.6% lat/lon coverage. Running variable: signed geodesic distance from each transaction to the nearest ZFE boundary (positive inside, negative outside).

**Identification:** Spatial regression discontinuity design. Properties just inside the ZFE boundary face cleaner air but vehicle restrictions; properties just outside do not. The key insight: ZFE boundaries typically follow pre-existing roads (Paris: A86 ring road) or commune borders, not drawn for housing market reasons. Validity tests: (1) McCrary density test at boundary, (2) pre-ZFE price smoothness, (3) covariate balance (building age, size, type), (4) event study showing discontinuity appears only after ZFE implementation.

**Why it's novel:** Zero published papers use spatial RDD on any low emission zone boundary worldwide. All existing LEZ-property price literature (Aydin & Kurschner Rauck 2023 on Berlin; JEEM 2025 on German LEZs) uses DiD, not RDD. No study uses French ZFE data for housing outcomes at all. This is the first paper combining spatial RDD + LEZ boundaries + property prices.

**Feasibility check:**
- ✅ ZFE boundary GeoJSON: Downloaded for Paris (55KB polygon with date_debut, Crit'Air levels). Multiple cities have open data portals (Grenoble, Angers, Rennes, Marseille).
- ✅ DVF data: Bulk CSV available (3.8M rows/year), geocoded. Confirmed download and structure.
- ✅ Multiple cities provide cross-boundary variation and external validity.
- ✅ Staggered ZFE implementation (2015-2024) allows event study within spatial RDD.
- ⚠️ Need to collect boundary GeoJSONs from each city's open data portal individually.
- ⚠️ Boundary exogeneity argument requires demonstrating pre-ZFE price smoothness.

**Expected effect:** Ambiguous sign (genuinely interesting). Properties inside may appreciate (cleaner air premium) or depreciate (reduced accessibility for car-dependent residents). The heterogeneity across income levels and proximity to public transit could reveal distributional effects of climate policy.


## Idea 2: Quartiers Prioritaires (QPV) Designation and Local Economic Activity — RDD on Income Concentration Threshold

**Policy:** The 2014 Loi Lamy designated 1,514 Quartiers Prioritaires (QPV) across France using a single, transparent criterion: on a 200m×200m INSEE grid, zones where >50% of the population has income below 60% of the local urban unit's median income, forming contiguous areas of 1,000+ inhabitants. QPV status triggers substantial treatment: 5-year corporate tax (CFE) exemption, property tax (TFPB) exemption, ZFU-TE profit tax exemption (up to €50K/year), dedicated ANRU urban renewal funding, and Contrats de Ville social programs.

**Outcome:** Firm creation and survival from INSEE Sirene (API access confirmed). Property prices from DVF. Employment dynamics.

**Identification:** Standard RDD on the share of low-income population in 200m grid squares, with the 50% cutoff determining QPV designation. Running variable: income concentration ratio from INSEE FILOSOFI carroyage data. This is a textbook RDD — single criterion, explicit threshold, substantial treatment.

**Why it's novel:** No published RDD exploiting the QPV income-concentration threshold exists. Prior QPV research is entirely descriptive (Cerema reports showing 10%+ price gaps, ONPV reports).

**Feasibility check:**
- ✅ QPV boundaries available (city-level shapefiles confirmed; national aggregation needed).
- ✅ Sirene API access confirmed for firm data.
- ✅ DVF for property outcomes.
- ⚠️ FILOSOFI carroyage 200m data (running variable) requires bulk download from INSEE — test showed 500 error. May need alternative download path or request.
- ⚠️ Running variable is somewhat discrete (200m grid squares).
- ⚠️ QPV boundaries were finalized with some local authority input — manipulation concern.


## Idea 3: Education Priority Zone Designation and Housing Price Capitalization — RDD on School Social Composition Index

**Policy:** Since 2015, French schools are classified as REP or REP+ (Réseau d'Éducation Prioritaire) based on the Indice de Position Sociale (IPS), a composite social deprivation score. REP+ schools (~362 collèges) receive substantial additional resources: teacher bonuses (up to €5,000/year), reduced class sizes, additional staff. The IPS threshold creates a fuzzy cutoff: average IPS ~74 for REP+, ~85 for REP, ~106 for non-priority.

**Outcome:** DVF property transactions geocoded near school catchment areas. The hypothesis: REP/REP+ designation signals school quality to the housing market, depressing (or inflating) nearby property prices — the French version of Black (1999, QJE).

**Identification:** Fuzzy RDD on school-level IPS scores, with the designation threshold as the cutoff. Instrument: school IPS → REP designation → property prices in catchment area.

**Why it's novel:** IPS data was only made public in 2022 (after a court order). No paper has used it as an RDD running variable for housing capitalization in France. Predecessor program (RAR) was studied for educational outcomes (Caille et al. 2016) but never for housing prices.

**Feasibility check:**
- ✅ IPS data publicly available on data.gouv.fr (from 2016 onward).
- ✅ REP/REP+ school lists available from Ministry of Education.
- ✅ DVF for geocoded property transactions.
- ⚠️ School catchment boundaries (carte scolaire) not centrally published — need to obtain from individual académies/rectorats.
- ⚠️ REP designation involves some académie discretion — fuzzy RDD required.
- ⚠️ IPS threshold for designation not explicitly published — must be inferred from data.


## Idea 4: Commercial Authorization Threshold and Retail Market Structure — RDD at 1,000 m²

**Policy:** Since the 2008 LME (Loi de Modernisation de l'Économie), any retail establishment exceeding 1,000 m² of sales area requires authorization from the CDAC (Commission Départementale d'Aménagement Commercial). This raised the previous threshold from 300 m² (Loi Raffarin 1996). Below 1,000 m², no authorization needed.

**Outcome:** Retail establishment characteristics from Sirene. Local employment from DADS/DSN. Potentially retail prices (limited data).

**Identification:** RDD on planned store size (m²) at the 1,000 m² cutoff. Stores just below avoid regulatory burden; stores just above face uncertain approval, delays, and conditions.

**Why it's novel:** No RDD on the CDAC threshold exists. The seminal French retail entry paper (Bertrand & Kramarz 2002, QJE) used IV, not RDD. The 2008 threshold change from 300 to 1,000 m² also provides a natural experiment.

**Feasibility check:**
- ⚠️ CRITICAL DATA GAP: Store-level sales area data is not readily available in public datasets. Sirene has establishment data but not floor area. CDAC decisions may be available from prefectures but require systematic scraping.
- ⚠️ The running variable (planned store size) is chosen by the firm — strategic bunching at 999 m² is expected, undermining standard RDD (though bunching itself could be the finding).
- ✅ Employment outcomes available.
- ❌ Without store-size data, this idea cannot proceed without significant data construction effort.


## Idea 5: Close Municipal Elections and Local Public Investment — RDD on Vote Margin

**Policy:** French municipal elections determine the maire and conseil municipal. Close elections (near 50% vote share in second-round runoffs) provide quasi-random variation in the identity and party of the elected mayor. Party affiliation determines access to intergovernmental transfers, alignment with département/regional government, and policy priorities.

**Outcome:** Local public investment from Direction Générale des Collectivités Locales (DGCL) fiscal accounts. Property prices from DVF. Firm activity from Sirene.

**Identification:** RDD on the vote margin in second-round municipal elections. Mayors winning by a narrow margin are quasi-randomly assigned vs. the runner-up.

**Why it's novel:** Close-election RDD is well-established but has been studied less in France than in the US, Brazil, or India. The combination with DVF property data and Sirene firm data could reveal local economic effects of political alignment/partisanship.

**Feasibility check:**
- ✅ Election results available on data.gouv.fr with commune-level detail.
- ✅ Fiscal accounts (DGCL) publicly available.
- ✅ DVF and Sirene for economic outcomes.
- ⚠️ French municipal elections have a two-round list system (not single-candidate), making the vote margin less clean than single-candidate races.
- ⚠️ Novelty is moderate — close-election RDD is a crowded methodology globally.
