# Research Ideas

## Idea 1: The Speed of Death: Departmental Reversals of France's 80 km/h Speed Limit and Road Safety

**Policy:** In July 2018, France reduced the speed limit on two-lane secondary roads from 90 to 80 km/h nationwide. The December 2019 Loi d'Orientation des Mobilités (LOM) allowed departmental councils to restore 90 km/h on their routes départementales. By February 2026, 52 of 96 metropolitan départements have reversed (fully or partially), with staggered adoption from January 2020 through 2026. The bulk of reversals occurred in 2020-2022.

**Outcome:** BAAC (Bulletin d'Analyse des Accidents Corporels de la Circulation Routière), the official French road accident microdata. Available 2005-2024 on data.gouv.fr. Contains accident-level records with department, road category (route départementale = catr 3), agglomeration status, geocoordinates, and severity (killed, hospitalized, light injury). Approximately 10,000 corporal accidents and 475 fatalities per year on routes départementales outside agglomeration across metropolitan France. ~100 accidents per département per year provides solid statistical power.

**Identification:** Staggered difference-in-differences exploiting the heterogeneous timing of departmental 90 km/h reversals. Treatment group: ~52 départements that restored 90 km/h (at different dates). Control group: ~40 départements that maintained 80 km/h plus 4 urban départements without eligible roads. Callaway-Sant'Anna (2021) estimator handles staggered adoption and heterogeneous treatment effects. Event-study specification tests parallel pre-trends. Placebo tests on autoroutes (never affected) and routes within agglomeration (speed limit unchanged). Can also exploit treatment intensity (share of departmental road network restored to 90 km/h) as a continuous measure.

**Why it's novel:** ONISR published a crude comparison finding ~74 excess deaths in 2021 among reversal départements, but this used a simple group comparison without parallel trends testing, event-study dynamics, or controls for COVID-19 mobility changes. No academic paper applies modern staggered DiD (CS-DiD, Sun-Abraham, de Chaisemartin-D'Haultfoeuille) to this setting. The only published paper (Carnis & Garcia 2024, Journal of Safety Research) studies the original 2018 reduction using aggregate time series — not the departmental reversal variation. This is a genuine gap in a politically salient debate.

**Feasibility check:**
- Variation: 52 treated départements across 6 years of staggered adoption ≥ 20 ✓
- Pre-periods: Using quarterly data from Q3 2018 (when 80 km/h started): 6 quarters before first reversals in Q1 2020 ≥ 5 ✓. Using annual data from 2015: 5 pre-periods ✓
- Data: BAAC downloaded and verified — CSV structure confirmed with dep, catr, agg, grav fields
- Treatment compilation: requires web scraping from Ligue des Conducteurs observatory, L'Argus maps, and ONISR reports. Moderate effort but feasible.
- Power: ~100 corporal accidents per département per year; ONISR's 13% effect estimate implies ~13 additional accidents/dept/year. Detectable.
- COVID confound: 2020-2021 reversals overlap pandemic. Mitigated by (a) control départements also experienced COVID, (b) event-study absorbs common shocks, (c) later 2022-2024 adopters provide cleaner variation, (d) mobility controls from Google/Apple data.

## Idea 2: Size Without Scale? The Fiscal Effects of France's Municipal Merger Wave

**Policy:** Since 2015, France has experienced a wave of voluntary municipal mergers ("communes nouvelles"), incentivized by a temporary bonus in the Dotation Globale de Fonctionnement (DGF, central government grant). Approximately 780+ communes nouvelles were created, merging ~2,500 old communes. Timing is staggered: ~317 in 2016, ~37 in 2017, ~37 in 2018, ~238 in 2019, near-zero in 2020 (electoral moratorium), and a trickle thereafter.

**Outcome:** OFGL (Observatoire des Finances et de la Gestion publique Locale) commune-level consolidated accounts, 2012-2024, available on data.ofgl.fr. Contains ~70 financial aggregates: total expenditure, operating revenue, debt, savings rate, investment per capita, tax rates (taxe foncière, taxe d'habitation). Also: DVF for housing prices, Sirene for firm creation/destruction.

**Identification:** Staggered DiD with Callaway-Sant'Anna estimator. Treated: communes that merged (timing varies 2016-2019). Never-treated: ~34,000 communes that did not merge. Event-study plots for pre-trends. Municipality-level financial data allows testing whether mergers improved fiscal efficiency (lower spending per capita, higher investment, lower debt) as proponents claimed.

**Why it's novel:** While municipal merger effects have been studied in Germany (Blesse & Baskaran 2016), Japan (Nakazawa 2018), and Denmark (Lassen & Serritzlew 2011), no clean causal study exists for France despite its massive merger wave. DGCL published a descriptive comparison (BIS 199, 2025) showing higher revenues post-merger, but without causal identification. Tricaud (2021) studies intercommunal cooperation structures, not actual mergers.

**Feasibility check:**
- Variation: ~780 treated communes across 4 cohorts ≥ 20 ✓
- Pre-periods: OFGL data from 2012; for 2016 cohort: 4 pre-periods (borderline). For 2019 cohort: 7 pre-periods ✓
- Data: OFGL is open access, no API key needed. DVF from 2014. Both verified accessible.
- Selection concern: Mergers are voluntary — communes that merge may be systematically different (smaller, rural, fiscally stressed). Mitigation: conditional parallel trends, covariate-adjusted CS-DiD, exploit DGF bonus deadline as cost-shifter.
- Power: 780 treated units is very large. Financial outcomes are continuous with reasonable variance.

## Idea 3: Does Building Bike Lanes Save Lives? Evidence from France's Cycling Infrastructure Boom

**Policy:** France's Plan Vélo national (2018) and the COVID-19 "coronapistes" (temporary bike lanes, many made permanent from 2020) led to a massive, staggered expansion of cycling infrastructure across French cities. Cities adopted cycling lanes at very different speeds — Paris and Lyon moved early (2019-2020), while others followed in 2021-2023. The total network grew from ~4,000 km in 2019 to ~14,000 km by 2024 in the 200 largest urban areas.

**Outcome:** BAAC road accident microdata (same source as Idea 1), filtered to cycling accidents (pedestrian/cyclist involvement) within agglomeration. GPS coordinates allow matching accidents to specific cycling infrastructure. Also possible: cycling counter data (available from many cities via open data portals).

**Identification:** Staggered DiD at the commune/urban area level, with treatment defined as the year the municipality installed significant cycling infrastructure. Treatment timing from Géovélo open data or OpenStreetMap cycling network snapshots. Outcome: cycling-involved corporal accidents per commune per year.

**Why it's novel:** Most cycling safety literature is descriptive or uses cross-sectional comparisons. A staggered DiD exploiting the sharp COVID-induced acceleration of bike lane construction in France would be novel. The question of whether dedicated cycling infrastructure reduces or increases accident risk (by attracting more inexperienced cyclists) is theoretically ambiguous.

**Feasibility check:**
- Variation: 200+ cities with staggered adoption ≥ 20 ✓
- Pre-periods: BAAC from 2005, cycling infrastructure mainly from 2019-2020. Many pre-periods ✓
- Data: BAAC confirmed accessible. Cycling infrastructure data needs verification — Géovélo or OSM historical snapshots may be hard to compile.
- Treatment measurement challenge: Defining "when" a city adopted cycling infrastructure is less clean than a binary policy switch. Infrastructure buildout is gradual, not a sharp event.
- Power concern: Cycling accidents at the city level may be sparse for smaller cities.
