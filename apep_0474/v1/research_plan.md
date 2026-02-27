# Initial Research Plan — apep_0474

**Title:** Downtown for Sale? Commercial Displacement Effects of France's Action Cœur de Ville Program

**Date:** 2026-02-27

---

## Research Question

Did France's €5 billion Action Cœur de Ville (ACV) program revitalize commercial activity in targeted city centers, or did it merely displace economic activity from surrounding areas? Specifically:

1. **Primary:** What is the causal effect of ACV designation on downtown-facing commercial establishment dynamics (net entry, creation, cessation) in treated communes?
2. **Secondary (displacement test):** Did ACV communes gain commercial activity at the expense of neighboring non-ACV communes within the same employment zone (zone d'emploi)?

## Policy Background

Action Cœur de Ville was announced by Prime Minister Édouard Philippe on **December 14, 2017**, with the selection of **222 medium-sized cities** (villes moyennes) as beneficiaries. The program officially launched in **March 2018** with a €5 billion multi-year investment envelope combining national subsidies, Caisse des Dépôts loans, Action Logement housing funds, and ANAH renovation grants. Implementation began with convention signatures from **October 2018** onward.

Key companion policies:
- **ORT (Opérations de Revitalisation de Territoire):** Enabled by Loi ELAN, November 2018. Gives ACV mayors regulatory tools (pre-emption, commercial vacancy tax).
- **Denormandie dans l'ancien:** Tax incentive for renovating rental housing in ACV cities, effective January 2019.

The policy-relevant estimand is the **total ACV treatment package** (ACV + ORT + Denormandie), which is what policymakers want to evaluate.

## Identification Strategy

### Design: Difference-in-Differences (DiD)

**Treatment:** 222 ACV-designated communes (selected December 2017, announced March 2018).

**Treatment timing:** Single treatment date for all units. The 222 cities were selected simultaneously by the national government. Convention signing occurred over October 2018 – early 2019, but the announcement itself could trigger anticipation effects. We define:
- **Announcement date:** 2017Q4 (December 2017)
- **Implementation onset:** 2018Q4 (first conventions signed October 2018)
- **Primary specification:** Treatment = post-2018Q1 × ACV commune (captures both announcement and implementation)
- **Robustness:** Donut specification dropping 2018 (transition year)

**Control group:** Non-ACV communes matched from the universe of French communes using:
1. **Population thresholds:** Communes with 10,000–100,000 inhabitants (the "villes moyennes" range)
2. **Urban function:** Communes classified as "pôles" in the INSEE zonage en aires d'attraction des villes (AAV)
3. **Pre-treatment matching:** Propensity score or CEM on 2012–2017 commercial density, population growth, unemployment rate, housing vacancy rate, département fixed effects

### Why Not Staggered DiD?

All 222 communes were selected simultaneously. The convention signing dates (2018–2019) are staggered but endogenous (larger/more organized cities signed first). We use the announcement as the sharp treatment date, avoiding selection-into-timing bias.

### Event-Study Specification

$$Y_{it} = \alpha_i + \gamma_t + \sum_{k=-24}^{K} \beta_k \cdot \mathbb{1}[t - t^* = k] \cdot D_i + X_{it}\delta + \varepsilon_{it}$$

Where:
- $Y_{it}$: Downtown-facing establishment count (or net entry) in commune $i$, quarter $t$
- $\alpha_i$: Commune fixed effects
- $\gamma_t$: Quarter fixed effects (or région × quarter)
- $D_i$: ACV treatment indicator
- $t^* = 2018Q1$: Treatment onset
- $k$: Event-time indicators (24 quarters pre, K quarters post)
- $X_{it}$: Time-varying controls (population, département-level unemployment)

**Pre-trend test:** Joint F-test on $\beta_{-24}$ through $\beta_{-1}$ = 0. HonestDiD sensitivity analysis for bounds under trend violations.

## Exposure Alignment (DiD Required Section)

**Who is actually treated?** The ACV program targets the city center of 222 medium-sized communes. The treated population is commercial establishments in downtown-facing sectors (retail NAF 47.xx, restaurants/cafés NAF 56.xx, personal services NAF 96.xx) located within the commune's urban core.

**Primary estimand population:** All establishments in downtown-facing sectors within ACV communes.

**Placebo/control population:** Establishments in non-downtown sectors (manufacturing, agriculture, wholesale) within ACV communes. These should show zero or minimal effects if the mechanism operates through downtown commercial revitalization.

**Design:** Standard two-group DiD with event-study coefficients. All 222 communes treated simultaneously (announcement: 2017Q4, implementation: 2018Q4). Single treatment date, not staggered.

**Outcome dilution risk:** Moderate. Commune-level outcomes include both downtown and suburban establishments. Mitigated by:
1. Restricting to downtown-facing NAF sectors (retail, hospitality, personal services)
2. Robustness with BAN geocoding to define downtown buffer zones (500m around mairie)

## Power Assessment (DiD Required Section)

**Pre-treatment periods:** 24 quarters (2012Q1–2017Q4, using Sirene creation/cessation dates)

**Treated clusters:** 222 ACV communes (>> 20 threshold)

**Control clusters:** ~500–1,500 matched non-ACV communes in the "villes moyennes" population range

**Post-treatment periods per cohort:** 28 quarters (2018Q1–2024Q4)

**Outcome variation:** Average commune has ~200–500 retail/hospitality establishments. Quarterly net entry is typically ±2–5% of stock. With 222 treated units × 28 post-periods = 6,216 treated observations.

**MDE estimate:** With 222 treated communes, 24 pre-periods, and commune FE + quarter FE, power simulations from similar DiD designs suggest MDE of ~2–4% change in establishment counts. This is plausible given the program's €5B scale.

## Expected Effects and Mechanisms

**Hypothesis 1 (Revitalization):** ACV increases net commercial establishment entry in treated communes, particularly in retail and hospitality. Expected magnitude: 3–8% increase in downtown-facing establishment stock over 5 years.

**Hypothesis 2 (Displacement — null or positive):**
- If positive spillover: ACV attracts customers to the center, benefiting surrounding communes via agglomeration.
- If negative spillover (displacement): ACV shifts activity from periphery to center (zero-sum).
- Tested by: Effect of neighbor's ACV treatment on non-ACV commune's commercial vitality.

**Mechanism:** ACV combines infrastructure investment (streetscaping, parking, digital tools), housing renovation (ANAH), and regulatory powers (commercial vacancy tax, pre-emption). The commercial channel operates through improved attractiveness (more foot traffic) and reduced vacancy (landlords face penalties for empty storefronts).

## Primary Specification

**Outcome variables:**
1. $\log(\text{Establishments}_{it})$: Log stock of downtown-facing establishments (main)
2. $\text{NetEntry}_{it}$: Creations minus cessations per quarter
3. $\text{CreationRate}_{it}$: Quarterly creations / lagged stock
4. $\text{CessationRate}_{it}$: Quarterly cessations / lagged stock

**Main regression (TWFE baseline):**
$$\log(Y_{it}) = \alpha_i + \gamma_t + \beta \cdot \text{Post}_t \times \text{ACV}_i + X_{it}\delta + \varepsilon_{it}$$

Clustered at commune level. Wild cluster bootstrap for finite-sample correction.

## Planned Robustness Checks

1. **Alternative matching:** Propensity score, CEM, entropy balancing on pre-treatment characteristics
2. **Alternative estimators:** Sun & Abraham (2021), de Chaisemartin & d'Haultfœuille (2020), Borusyak et al. (2024) imputation
3. **Alternative outcomes:** Retail-only, hospitality-only, all-sector index, employment-weighted
4. **Wild cluster bootstrap:** Cameron, Gelbach, and Miller (2008)
5. **Randomization inference:** 1,000 random permutations of ACV designation across eligible communes
6. **Leave-one-out:** Drop each ACV city in turn; drop each département
7. **Donut specification:** Drop 2018 (transition year between announcement and implementation)
8. **COVID heterogeneity:** Split pre-COVID (2018–2019) vs COVID (2020–2021) vs post-COVID (2022–2024)
9. **Région × quarter FE:** Absorb regional shocks including differential COVID impacts
10. **Placebo sectors:** Manufacturing (NAF 10–33), wholesale (NAF 46.xx) — should show no effect
11. **Displacement test:** Estimate spillover effect on neighboring non-ACV communes within the same zone d'emploi
12. **Timing decomposition:** Pre-ORT (2018Q1–Q3) vs post-ORT (2018Q4+) vs post-Denormandie (2019Q1+)

## Data Sources

| Source | What | Granularity | Coverage |
|--------|------|-------------|----------|
| Sirene StockEtablissement | All French establishments (active + closed) | Establishment × point-in-time | 1973–2025 |
| Sirene StockEtablissementHistorique | Historical establishment events | Establishment × event | Full history |
| ACV commune list (data.gouv.fr) | 244 communes with INSEE codes + convention dates | Commune | 2018–2025 |
| INSEE COG | Commune geography (codes, names, population) | Commune | Annual |
| INSEE Zonage AAV | Urban area classification | Commune | 2020 |
| INSEE RP (recensement) | Population, housing, employment | Commune | 2012–2021 |

## Analysis Pipeline

```
01_fetch_data.R    — Download Sirene parquet + ACV list + commune metadata
02_clean_data.R    — Construct commune × quarter panel, match controls
03_main_analysis.R — TWFE + event study + displacement test
04_robustness.R    — All sensitivity analyses
05_figures.R       — Event study plots, maps, balance tables
06_tables.R        — Regression tables (modelsummary)
```

---

**Committed before data fetch.** This plan is locked.
