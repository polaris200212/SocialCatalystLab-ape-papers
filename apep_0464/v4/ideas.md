# Research Ideas — apep_0464

## Idea 1: Connected Backlash: Social Networks, Carbon Tax Incidence, and the Political Economy of Climate Policy in France

**Policy:** France's carbon tax (contribution climat-énergie), introduced in 2014 at €7/tCO2 and rising to €44.60/tCO2 by 2018, frozen after the Gilets Jaunes movement. The tax is national but incidence varies enormously by département: rural, car-dependent areas face 11× the commuting CO2 burden of Paris (INSEE 2024). The planned increase to €55/tCO2 in January 2019 was canceled after mass protests, permanently freezing the rate and derailing France's climate policy trajectory.

**Outcome:** Rassemblement National (RN) vote share across French elections 2012-2024, measured at the commune level (35,000+ communes) using the consolidated Parquet election dataset from data.gouv.fr. Six election waves: presidential 2012, European 2014, presidential 2017, European 2019, presidential 2022, European 2024. Secondary outcomes: turnout, blank/null votes, vote share for other parties.

**Data sources (all confirmed accessible):**
- Facebook Social Connectedness Index (SCI) at NUTS3/département level (96 metropolitan pairs), from HDX `nuts_2024.zip`
- Election results: `candidats_results.parquet` from data.gouv.fr (158 MB, commune-level, all elections 1999-2024)
- Fuel consumption by département: SDES petroleum product sales data (annual, 2005+)
- Station-level fuel prices: prix-carburants.gouv.fr XML archives (2007+)
- Income/poverty: INSEE Filosofi (département-level, 2012-2021)
- Commuting CO2 emissions: INSEE/SDES (commune-level, 2019/2021/2022)
- Demographics: INSEE census (population, urbanization, age, education)
- NUTS3→département mapping: Eurostat correspondence table

**Identification:**
1. **Shift-share IV:** Pre-existing SCI connections (shares, 2020 vintage) × fuel vulnerability in connected départements (shifts). A département's network exposure to carbon tax costs = Σ_j SCI_dj × FuelIntensity_j. Instrument for RN vote share changes.
2. **Event study around GJ movement (Nov 2018):** Compare high-network-exposure vs. low-network-exposure départements across elections before (2012, 2014, 2017) and after (2019, 2022, 2024) the GJ catalytic event.
3. **Distance-restricted SCI:** Following apep_0185, restrict SCI to connections beyond 200km to purge geographic confounders. If network effects strengthen with distance restriction, this confirms information transmission over spatial proximity.
4. **Placebo outcomes:** Test network exposure to fuel vulnerability against outcomes that should NOT respond (e.g., left-party vote share, agricultural policy votes).

**Structural model:** Network-mediated political preference formation (DeGroot learning with heterogeneous agents). Voters update beliefs about policy costs using own experience + SCI-weighted signals from connected départements. Parameters: (1) direct cost sensitivity β, (2) network amplification γ (the KEY parameter), (3) switching threshold δ, (4) signal noise σ. Counterfactuals: (a) RN vote share without network amplification (γ=0), (b) carbon tax with compensating transfers reducing c_dt, (c) implications for climate policy feasibility.

**Why it's novel:**
- First paper combining SCI + political radicalization + structural estimation
- Differentiated from Flückiger & Ludwig (2025, JPubE): different outcome (voting, not protests), different country, structural model
- Builds on Douenne & Fabre (2022, AEJ:EP) who study carbon tax attitudes but lack the network dimension
- Connects to the most important policy debate: can democracies implement carbon pricing without populist backlash?
- Perfect setting: the GJ movement was explicitly organized through Facebook (the network SCI measures)

**Feasibility check:**
- Variation: 96 départements × 6 elections = 576 département-election obs; commune-level gives 210,000+ obs ✓
- Data access: ALL sources confirmed freely accessible, tested endpoints ✓
- Novelty: No existing paper on SCI + electoral radicalization + carbon tax. Checked Google Scholar, NBER, SSRN ✓
- Sample size: 35,000+ communes × 6 elections with rich cross-sectional variation in SCI and fuel exposure ✓
- Identification: National policy with 11:1 spatial variation in incidence; SCI structure provides network moments ✓

---

## Idea 2: Networks of Resistance: Social Connections and the Spatial Propagation of the Gilets Jaunes Movement

**Policy:** The Gilets Jaunes protest movement (November 2018 – mid 2019), a spontaneous mass mobilization against fuel tax increases that spread explosively across France. At peak, 300,000+ participants at 2,000+ locations weekly. The movement was organized primarily through Facebook groups.

**Outcome:** Département-level weekly protest intensity (Nov 2018 – May 2019), constructed from: (a) Interior Ministry weekly national counts disaggregated by press reports, (b) archived KML data from blocage17novembre.com (713+ geolocated blockade points), (c) Google Trends for "gilets jaunes" by region.

**Identification:** SCI-weighted exposure to initial protest propensity (fuel vulnerability × car dependency × rural share) as shift-share instrument. Following Flückiger & Ludwig (2025) methodology adapted to French context.

**Structural model:** Granovetter (1978) threshold model of collective action embedded in the SCI network. Citizens have participation thresholds; they observe network participation and join when threshold exceeded. First structural estimation of threshold distribution using real network data.

**Why it's novel:** First application of SCI to Gilets Jaunes; first structural estimation of threshold model with observed network; French setting where Facebook (the SCI network) was the literal organizing platform.

**Feasibility check:**
- Variation: 96 départements × ~25 weeks = 2,400 obs ✓
- Data access: SCI confirmed ✓. Protest data is the CRITICAL GAP — no single public dataset exists at département-week level. Would require construction from multiple sources (Wikinews compilations, regional press, archived maps). Boyer et al. (CREST) have the best data but it's not publicly released ⚠️
- Novelty: No existing SCI + Gilets Jaunes paper ✓
- Sample size: 96 départements is modest compared to US county-level papers (3,000+) ⚠️
- Risk: Protest data construction may be infeasible within paper production timeline ⚠️

---

## Idea 3: Social Networks and the Diffusion of Firm Creation Across French Départements

**Policy:** France's auto-entrepreneur regime (Loi de modernisation de l'économie, August 4, 2008, effective January 1, 2009) and subsequent reforms — Loi Pinel (June 18, 2014) renaming it micro-entrepreneur; Loi PACTE (May 22, 2019) raising revenue thresholds. These reforms created staggered shocks to entrepreneurship across départements with differential pre-existing business density and sectoral composition. Zone Franche Urbaine (ZFU) designations (1996, 2004, 2006 waves) provide additional localized treatment variation.

**Outcome:** Firm births by département-quarter-sector from INSEE Sirene (universe of French firms, creation dates, locations, NACE sectors). Available via API (credentials confirmed).

**Identification:** SCI-weighted exposure to sector-specific firm creation shocks. Bartik-style: pre-existing sectoral composition × national sector growth rates, weighted by SCI. Instrument: policy shocks affecting firm creation in specific areas (Zone Franche Urbaine designations, BPIfrance credit guarantees).

**Structural model:** Information diffusion model: potential entrepreneurs learn about business opportunities from network connections. Network connections reduce uncertainty about demand conditions in unfamiliar sectors/markets. Estimate: information precision parameter, uncertainty cost, network decay.

**Why it's novel:** First paper on SCI + entrepreneurship diffusion. Rich Sirene data (millions of firms) provides statistical power.

**Feasibility check:**
- Variation: 96 départements × 60 quarters (2009-2024) × multiple sectors ✓
- Data access: Sirene API confirmed, SCI confirmed ✓
- Novelty: No existing paper on SCI + firm creation ✓
- Risk: Identification of network effects vs. spatial correlation is the perennial SCI challenge. The Bartik IV may be weak if sectoral composition doesn't vary enough across départements ⚠️

---

## Idea 4: Social Networks and Housing Market Information Transmission: A Structural Approach Using French Property Transactions

**Policy:** France's Zones à Faibles Émissions (ZFE, Low Emission Zones), mandated by the Loi d'Orientation des Mobilités (December 24, 2019) and Loi Climat et Résilience (August 22, 2021). ZFEs were adopted in staggered fashion across 11 metropolitan areas from 2019-2025 (Paris Sept 2015, Lyon Jan 2020, Grenoble July 2020, Strasbourg Jan 2022, Toulouse March 2022, etc.), creating exogenous shocks to housing demand in affected vs. unaffected areas. Additional variation from the Pinel investment tax credit (September 1, 2014) with zone-based eligibility, and local vacancy taxes (taxe sur les logements vacants, expanded January 1, 2023).

**Outcome:** Property prices from DVF (Demandes de Valeurs Foncières) — millions of real estate transactions with exact prices, dates, and locations. Aggregated to département-quarter level.

**Identification:** SCI-weighted exposure to housing supply shocks (ZFE adoptions, construction permit changes, natural disasters) in connected départements. Instrument: exogenous supply shocks in connected areas affect local prices through information channels.

**Structural model:** Housing search model with network information. Buyers receive price signals from connected areas through social networks. Estimate: signal precision, search cost, network information weight. Counterfactual: housing market efficiency without network information.

**Why it's novel:** First structural housing search model with network information estimated on real data. DVF is world-class property transaction data.

**Feasibility check:**
- Variation: 96 départements × 40 quarters (2014-2024) = 3,840 obs ✓
- Data access: DVF confirmed freely accessible; SCI confirmed ✓
- Novelty: apep_0460 did SCI + French housing but only cross-border (UK→France) and reduced-form. This is within-France with structural estimation ✓
- Risk: SCI is at département level while DVF is at address level — aggregation required. Housing price dynamics may be driven more by credit conditions and national policy than by network information ⚠️

---

## Idea 5: Digital Networks and Democratic Contagion: Social Connections and the Spatial Diffusion of RN Voting in France, 2002-2024

**Policy:** A sequence of French economic policy shocks with differential spatial incidence: (1) Great Recession (2008-2009) with industrial restructuring concentrated in northern/eastern France; (2) Loi El Khomri labor reform (August 8, 2016) with staggered firm-level adoption; (3) Carbon tax (contribution climat-énergie, 2014-2018, €7→€44.60/tCO2) with rural incidence; (4) COVID lockdowns (March 17, 2020) with differential economic impact by sector/geography; (5) Inflation crisis (2022-2023) with heterogeneous energy price exposure. Each shock differentially affected départements, creating variation in grievance that propagated through social networks to shift political preferences.

**Outcome:** RN/FN vote share at commune level across all available elections (presidential, European, legislative) from 2002 to 2024, using the consolidated Parquet dataset.

**Identification:** Panel model with département and election fixed effects. SCI-weighted lagged RN vote share in connected départements as the key regressor, instrumented with SCI-weighted economic shocks (unemployment changes, plant closures from Sirene cessation data, immigration flows from OFPRA).

**Structural model:** Dynamic DeGroot learning model: voters update political positions based on own economic conditions + network-weighted political signals. Strategic complementarities create cascades/tipping points. Estimate persistence, direct experience weight, network influence weight.

**Why it's novel:** Longest panel of any SCI + political outcomes study (22 years, 10+ elections). Studies network-mediated political diffusion rather than protest diffusion.

**Feasibility check:**
- Variation: 96 départements × 10+ elections = 960+ obs; commune-level = 350,000+ ✓
- Data access: Elections confirmed, SCI confirmed, Sirene for plant closures confirmed ✓
- Novelty: No existing SCI + electoral diffusion paper ✓
- Risk: Longer panel requires assuming SCI is stable (it captures a snapshot, not a time series). Pre-2012 RN vote share data may have different nuance codes (FN not RN). The broad scope may dilute identification compared to Idea 1's focused carbon tax shock ⚠️
