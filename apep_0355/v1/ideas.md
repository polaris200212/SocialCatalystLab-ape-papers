# Research Ideas

## Idea 1: When Institutions Close — Nursing Home Exits and the Reallocation of Medicaid Community-Based Care

**Policy:** Nursing home closures across the United States, 2018-2024. Approximately 1,050-1,150 facilities closed during this period, displacing ~30,000+ residents. Closures varied at the county level within states, driven by financial distress, staffing shortages, and declining occupancy — not by local HCBS market conditions.

**Outcome:** County-level HCBS provider supply, spending, and beneficiary counts from T-MSIS (2018-2024). Primary outcomes: (1) number of active HCBS providers (T1019, S5125, H-codes), (2) total HCBS spending, (3) HCBS beneficiaries served, (4) provider entry/exit rates. Secondary: behavioral health provider supply (H-codes), habilitation residential spending (T2016).

**Data sources:**
- CMS Provider of Services (POS) file — nursing home termination dates and county FIPS (NBER mirror, public CSV, no DUA)
- T-MSIS Parquet (local, 2.74 GB) — HCBS outcomes at NPI×HCPCS×month level
- NPPES extract (local) — provider geography (NPI → ZIP → county)
- Census ZCTA-to-county crosswalk — ZIP-to-FIPS mapping
- Census ACS — county-level demographics, poverty, elderly population

**Identification:** Within-state event study DiD with staggered timing. County × month panel with county FE + state × month FE. Treatment = nursing home closure in county c at time t (identified from POS termination dates). Compare HCBS market outcomes in counties experiencing closures to counties in the same state that did not. Callaway-Sant'Anna (2021) estimator for heterogeneity-robust ATT.

**Why it's novel:**
1. No existing paper examines how nursing home closures affect the HCBS provider market using provider-level claims data.
2. T-MSIS provides the first public view of HCBS provider supply at the NPI level — previous studies could only track aggregate Medicaid expenditures.
3. Connects to a decades-long policy priority (Olmstead v. L.C., Money Follows the Person) but provides the first evidence on whether HCBS markets actually absorb displaced institutional residents.
4. Distinct from apep_0353 (labor market tightness → HCBS) — this is a demand-side shock (residents need care) not a supply-side shock (workers leave).

**Feasibility check:**
- ✅ ~1,100 nursing home closures = ample treated units across 40+ states
- ✅ CMS POS file is public, has termination dates and county FIPS
- ✅ T-MSIS provides monthly county-level HCBS outcomes
- ✅ 24+ monthly pre-periods for closures occurring 2020+
- ✅ Not in APEP list; limited existing literature linking NH closures to HCBS supply
- ✅ Within-state variation — state × month FE absorbs all state-level confounders

**Key risks:**
- Nursing home closures may be endogenous to local healthcare market conditions (mitigated by conditioning on pre-trends and using financial distress / quality-rating instruments)
- CMS POS file requires downloading from NBER (~100 MB per year) and constructing closure panel
- Some closures are actually conversions (to assisted living), not true exits — need to verify with facility matching

---

## Idea 2: The Elasticity of Medicaid's Safety Net — Market Responses to Provider Fraud Exclusions

**Policy:** OIG exclusions of Medicaid providers from federal healthcare programs, 2018-2024. 16,134 total exclusions, 3,811 with valid NPIs. 51% in HCBS-related specialties (nurse/aide, personal care, home health, behavioral health). Exclusion removes a provider from the market effective immediately.

**Outcome:** ZIP/county-level HCBS spending, provider counts, and beneficiary access from T-MSIS. Measure market absorption: do remaining providers fill the gap?

**Data sources:**
- OIG LEIE (direct CSV, confirmed working) — exclusion dates, NPIs, specialties
- T-MSIS Parquet (local) — pre/post-exclusion billing at market level
- NPPES extract (local) — provider geography and type

**Identification:** Provider-level event study. For each excluded provider with pre-exclusion T-MSIS billing, examine what happens to total HCBS spending and provider counts in their ZIP code/county after exclusion. ZIP FE + state × month FE. Treatment is quasi-random (driven by federal enforcement timing, not local market conditions).

**Why it's novel:** First study to estimate local Medicaid market elasticity using provider removal events. Reveals whether HCBS markets are resilient (elastic) or fragile (inelastic) — fundamental parameter for all Medicaid policies affecting provider supply.

**Feasibility check:**
- ✅ 3,811 exclusions with NPIs, many matchable to T-MSIS billing records
- ✅ All data sources confirmed accessible (OIG LEIE, T-MSIS, NPPES)
- ✅ Clean identification — enforcement timing is plausibly exogenous to local market trends
- ✅ Not in APEP list; novel question
- ⚠️ Individual exclusion effects may be small at the county level — better at ZIP level
- ⚠️ Some providers may reduce activity before formal exclusion (anticipation effects)

---

## Idea 3: HPSA Designation Changes and Medicaid Provider Supply Responses

**Policy:** HRSA Health Professional Shortage Area (HPSA) designations, with major reassessments in triennial NSDUs (2017, 2021, 2025). The 2021 NSDU proposed withdrawal of ~1,178 primary care and ~515 mental health HPSAs. Designation triggers Medicaid payment bonuses (10% for physicians in HPSAs).

**Outcome:** Medicaid provider supply and spending in designated vs. newly-withdrawn areas from T-MSIS.

**Data sources:** HRSA HPSA Dashboard CSV (public, no restrictions), T-MSIS, NPPES, Census ACS.

**Identification:** DiD around NSDU withdrawal events — areas losing HPSA status vs. areas retaining it. Within-state variation in HPSA status changes.

**Why it's novel:** First study linking HPSA designation changes to provider-level Medicaid billing outcomes.

**Feasibility check:**
- ✅ HPSA data is public with exact dates
- ⚠️ HPSA geography is complex (not county-aligned)
- ⚠️ Designation is endogenous to provider supply — reverse causality concern
- ⚠️ Triennial NSDU creates lumpy, correlated treatment timing

---

## Idea 4: County-Level COVID Mortality and the Reshaping of HCBS Markets

**Policy:** COVID-19 pandemic hit counties within the same state with dramatically different severity. Some counties experienced 3x higher mortality than their neighbors. This differential severity created divergent demand for post-acute and long-term care services.

**Outcome:** County-level HCBS provider supply, spending, and service mix from T-MSIS (pre vs. post COVID).

**Data sources:** CDC county-level COVID mortality, T-MSIS, NPPES, Census ACS.

**Identification:** Within-state variation in COVID severity. Compare HCBS market trajectories in high- vs. low-severity counties within the same state. Instrument: pre-pandemic nursing home bed density × state-level COVID wave timing.

**Feasibility check:**
- ✅ CDC mortality data is public
- ✅ Sharp within-state variation
- ⚠️ COVID has been studied extensively — novelty concern
- ⚠️ Many confounding factors during the pandemic period
