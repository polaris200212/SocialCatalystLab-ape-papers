# Initial Research Plan: apep_0452

## Title
Choking the Supply, Signing the Treaty: Mercury Regulation and Artisanal Gold Mining in Africa

## Research Question
Do mercury supply restrictions and international treaty commitments reduce mercury use in Africa's artisanal and small-scale gold mining (ASGM) sector? We evaluate two distinct regulatory approaches: (1) the EU Mercury Export Ban (March 2011), an exogenous supply-side shock that eliminated 25% of global mercury supply, and (2) the Minamata Convention on Mercury (ratification staggered 2014-2024), which requires African countries to develop National Action Plans to eliminate mercury in ASGM.

## Identification Strategy

### Design 1: EU Mercury Export Ban (Supply Shock)
- **Method:** Doubly Robust (DR) with continuous treatment intensity
- **Treatment:** Pre-ban EU mercury import dependence (share of mercury imports sourced from EU, 2005-2010 average)
- **Post period:** 2012-2015 (main), extended to 2020 (robustness)
- **Transition year:** 2011 dropped (ban effective March 15)
- **Controls:** GDP per capita, population, gold production, WGI rule of law, ASGM prevalence, industrial mining presence
- **DR justification:** Treatment intensity is predetermined but not randomly assigned — countries with EU trade ties may differ systematically. DR jointly models treatment assignment and outcomes for doubly robust estimates.

### Design 2: Minamata Convention (Treaty Commitment)
- **Method:** Doubly Robust DiD (Sant'Anna and Zhao 2020; Callaway and Sant'Anna 2021)
- **Treatment:** Staggered ratification across 38 African countries (2014-2024)
- **Second margin:** NAP submission (27 countries, 2019-2024) as "implementation" event
- **Never-treated:** DRC, Sudan, Tunisia (and other non-ratifiers)
- **Pre-treatment covariates for DR:** GDP, governance, gold suitability, ASGM employment, pre-period mercury import trends
- **Group-time ATTs:** Cohort-specific effects by ratification year

### Design 3: Combined
- Joint model incorporating both EU ban exposure and Minamata ratification
- Tests whether countries that lost EU supply AND ratified Minamata showed largest reductions

## Expected Effects and Mechanisms
1. **EU ban → mercury import reduction:** Direct supply restriction. Expect negative effect on EU-sourced mercury imports but potentially offset by trade rerouting through non-EU suppliers.
2. **EU ban → trade partner reallocation:** Mercury supply shifts from EU to non-EU sources (Turkey, UAE, India, China, Mexico). Transit hubs (Togo) may increase.
3. **Minamata → mercury import reduction:** If treaty is effective, ratifying countries should reduce mercury imports. But: weak enforcement suggests possible null result.
4. **Minamata → NAP implementation:** NAP submission (vs. mere ratification) may be the binding margin.
5. **ASGM activity:** If mercury supply falls and no substitute technology adopted, expect reduced ASGM activity (measured by nightlights, gold exports, deforestation). But: inelastic demand for mercury in ASGM may mean smuggling absorbs the regulation.

## Primary Specification (Design 1)

$$Y_{it} = \alpha + \beta \cdot EUShare_i \times Post_t + X_{it}\gamma + \mu_i + \lambda_t + \varepsilon_{it}$$

Where:
- $Y_{it}$: log mercury imports (value or quantity) for country $i$ in year $t$
- $EUShare_i$: pre-ban average share of mercury imports from EU (2005-2010)
- $Post_t$: indicator for $t \geq 2012$
- $X_{it}$: time-varying controls
- $\mu_i, \lambda_t$: country and year fixed effects

DR wrapper: Estimate treatment propensity $\hat{p}(X_i)$ for being "high-EU-dependent" and combine IPW with outcome regression.

## Primary Specification (Design 2)

Callaway-Sant'Anna DR-DiD with staggered adoption:
- Group variable: ratification year cohort
- Time variable: calendar year
- Treatment: binary (ratified or not by year $t$)
- Outcome: log mercury imports
- Covariates for DR: pre-treatment GDP, governance, gold production
- Aggregation: event-study (dynamic effects) and overall ATT

## Planned Robustness Checks
1. **Balanced reporters sample:** Restrict to countries with continuous mercury import reporting
2. **ASGM-heavy subsample:** Restrict to known major ASGM countries
3. **Mirror trade analysis:** Compare importer-reported vs. exporter-reported flows
4. **Trade partner decomposition:** Show rerouting patterns
5. **Transit hub analysis:** Separately examine Togo, South Africa, Kenya
6. **Alternative outcomes:** Gold exports, nighttime lights near mining areas, deforestation
7. **Placebo tests:** Non-mercury commodity imports (e.g., gold ores, fertilizer)
8. **Alternative post windows:** 2012-2014 (narrow), 2012-2020 (extended)
9. **Wild cluster bootstrap:** Clustered inference with few countries
10. **Pre-trend tests:** Event-study plots for both designs

## Data Sources
| Data | Source | Granularity | Years |
|------|--------|-------------|-------|
| Mercury imports (HS 280540) | UN Comtrade via WITS/API | Country × Year | 2000-2024 |
| Gold exports (HS 7108) | UN Comtrade via WITS/API | Country × Year | 2000-2024 |
| Bilateral trade partners | UN Comtrade | Country × Partner × Year | 2000-2024 |
| GDP per capita, population | World Bank WDI | Country × Year | 2000-2024 |
| Governance indicators | World Governance Indicators | Country × Year | 2002-2023 |
| Gold production | USGS Minerals Yearbook / WGC | Country × Year | 2000-2024 |
| Minamata ratification dates | Minamata Convention Secretariat | Country | 2014-2024 |
| NAP submission dates | Minamata Convention Secretariat | Country | 2019-2024 |
| ASGM prevalence | DELVE / planetGOLD | Country | Cross-section |
| Nighttime lights | VIIRS DNB / DMSP-OLS | Grid × Year | 2000-2024 |

## Power Assessment
- **Design 1 (EU ban):** ~54 African countries × 11 years (2005-2015) = ~594 country-years. Treatment intensity varies continuously. With ~15 reporting countries, effective sample may be smaller. MDE depends on within-country mercury import variation.
- **Design 2 (Minamata):** ~54 countries × 25 years (2000-2024) = ~1,350 country-years. 38 treated countries across 10+ cohorts. Pre-treatment periods: 15+ years for earliest cohorts. This well exceeds the 20 treated unit / 5 pre-period minimums.

## Exposure Alignment
- **Design 1:** Treated = countries with any EU-sourced mercury imports pre-ban. Intensity = share from EU. Directly affected population = mercury importers/distributors → ASGM miners.
- **Design 2:** Treated = countries ratifying Minamata. Directly affected = ASGM operations that use mercury amalgamation.
- **Placebo populations:** Non-ASGM countries (e.g., island nations, North African countries without gold mining). Non-mercury commodities.
