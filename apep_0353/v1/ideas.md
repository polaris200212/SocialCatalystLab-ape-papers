# Research Ideas

## Idea 1: Tight Labor Markets and the Crisis in Home Care — Within-State Evidence from Medicaid Provider Billing

**Policy:** The COVID-19 pandemic and subsequent recovery created unprecedented within-state variation in local labor market tightness. Some counties recovered rapidly (unemployment below 3%, hiring surging in retail/food service), while others in the same state lagged. HCBS workers — personal care aides, home health aides, attendant care providers — earn median wages of $14-17/hour and compete directly with Amazon warehouses, fast food, and retail. When local labor markets tighten, theory predicts these low-wage workers exit Medicaid caregiving for better-paying alternatives.

**Outcome:** HCBS provider supply from T-MSIS at the county-quarter level: (1) number of active HCBS billing providers, (2) total HCBS claims, (3) total HCBS spending, (4) claims per beneficiary, (5) provider entry/exit rates. Measured via T-code HCPCS codes (T1019 personal care, T2016 habilitation, T1015 FQHC) linked to county through NPPES ZIP-to-county crosswalk.

**Identification:** Two-way fixed effects DiD with county FE and state×quarter FE. The state×quarter FEs absorb ALL state-level time-varying confounders (Medicaid rate changes, unwinding timing, ARPA spending, minimum wage laws). Remaining variation: within-state, across-county differences in labor market conditions. Instrumented with a Bartik shift-share IV: national employment growth in each 2-digit NAICS industry × pre-period county industry employment shares (from BLS QCEW). Bartik IV addresses reverse causality (local health shocks simultaneously affecting labor markets and provider supply).

**Data sources (all confirmed working):**
- T-MSIS Parquet (local, 227M rows) → HCBS outcomes
- NPPES extract (local, 9.3M providers) → state, ZIP-to-county mapping
- BLS QCEW API (county-quarter, no key) → employment by industry, Bartik shares
- Census ACS API → county demographics, controls
- Census ZCTA-to-county crosswalk → ZIP-to-county mapping

**Why it's novel:** MACPAC (2022) and KFF (2025) report descriptively that HCBS workforce shortages affect all 50 states, with 77% of agencies turning away referrals. But no causal analysis exists linking local labor market conditions to Medicaid HCBS provider supply at the county level. This is the first paper to use T-MSIS provider-level data to measure the causal elasticity of HCBS supply with respect to local labor market tightness.

**Feasibility check:**
- Variation: 3,000+ counties across 50 states, 28 quarters (2018Q1-2024Q4)
- Pre-treatment: 8 quarters (2018Q1-2019Q4) before COVID shock
- Bartik instrument: 15+ 2-digit NAICS industries per county from QCEW
- HCBS coverage: $321B total, 57 states/territories, 99% NPI match rate
- DiD feasibility: Far exceeds ≥20 treated units and ≥5 pre-periods


## Idea 2: Market Power and the Pass-Through of Medicaid Rate Increases

**Policy:** ARPA HCBS spending (April 2021+) provided 10 percentage point FMAP increase. States implemented rate increases for HCBS services. The effect should differ by local market concentration: competitive counties see new entry while concentrated counties see rent capture.

**Outcome:** Provider entry rates, spending growth, beneficiaries per provider at county level from T-MSIS.

**Identification:** Triple-difference: pre/post ARPA × high/low county HHI × state implementation timing. HHI computed from T-MSIS at county-HCPCS category level using pre-treatment (2018-2020) data.

**Why it's novel:** No existing research on how market structure mediates Medicaid rate increase pass-through at the county level.

**Feasibility check:**
- Treatment: Nearly all states received ARPA — limited cross-state control group is a weakness
- HHI construction feasible from T-MSIS
- 28 quarters, adequate pre-periods
- Risk: Weak control group (virtually all states treated)


## Idea 3: Rural Hospital Closures and the Substitution to Home-Based Care

**Policy:** 130+ rural hospitals have closed since 2010 (UNC Sheps Center). When hospitals close, communities lose inpatient, ER, and primary care. Theory predicts ambiguous effects on HCBS: demand may increase (patients seek home-based alternatives) or decrease (general health infrastructure collapse makes home care unsustainable).

**Outcome:** HCBS provider entry, claims, and spending in affected counties from T-MSIS.

**Identification:** Event study around hospital closure dates. Compare counties experiencing closures to similar rural counties in the same state without closures. Within-state design with county and state×quarter FEs.

**Why it's novel:** "Bystander effect" studied for hospitals, but not for HCBS/community-based services.

**Feasibility check:**
- Treatment: ~130 closures since 2010, but need to overlap with 2018-2024 T-MSIS window
- Hospital closure data requires manual download from UNC Sheps Center — may not be API-accessible
- Small sample of closures limits power
- Risk: Data access barrier for closure dates


## Idea 4: Broadband Access and Telehealth Adoption in Medicaid

**Policy:** COVID-19 prompted rapid telehealth expansion in Medicaid. All states relaxed telehealth restrictions. But the ability to use telehealth depends on broadband infrastructure, which varies enormously within states.

**Outcome:** Telehealth-related billing (modifier codes, telehealth HCPCS) from T-MSIS at county level.

**Identification:** DiD with state×quarter FEs. Within-state variation from pre-existing broadband infrastructure. FCC Form 477 data provides county-level broadband availability.

**Why it's novel:** Most telehealth research uses claims from a single state or insurer.

**Feasibility check:**
- FCC broadband data may require manual download
- Telehealth codes in T-MSIS unclear (may be bundled into standard HCPCS)
- Risk: Data access for broadband; unclear telehealth code identification in T-MSIS


## Idea 5: Minimum Wage Bindingness and HCBS Provider Supply

**Policy:** State minimum wage increases during 2018-2024 (many states raised to $12-15+). The "bite" varies by county within the state based on local wage levels (Kaitz index = minimum wage / median wage).

**Outcome:** HCBS provider counts, claims, entry/exit from T-MSIS.

**Identification:** County-level dose-response DiD. State minimum wage increase × county Kaitz index. Within-state variation from Kaitz index heterogeneity.

**Why it's novel:** apep_0339 studied minimum wages and Medicaid HCBS using cross-state variation. This uses within-state variation (Kaitz index), which is much stronger causally — state FEs absorb all state-level confounders.

**Feasibility check:**
- ~25 states raised minimum wages during window
- Kaitz index from ACS + state minimum wage laws
- Risk: Similar topic to apep_0339, though identification is fundamentally different
