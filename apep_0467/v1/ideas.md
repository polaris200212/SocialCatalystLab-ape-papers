# Research Ideas

## Idea 1: Priced Out of Care — Medicaid Wage Competitiveness and Home Care Workforce Fragility

**Policy:** State-level Medicaid HCBS reimbursement rate-setting creates persistent cross-state variation in what personal care aides earn relative to competing low-wage sectors (retail, food service, warehousing). This "wage competitiveness gap" is determined by state rate-setting decisions interacted with local labor market conditions — a structural feature of the Medicaid monopsony, not a discrete policy shock. COVID-19 (March 2020+) provides an exogenous stress test that reveals the fragility embedded in this wage structure.

**Outcome:** T-MSIS Medicaid Provider Spending (227M rows, Jan 2018 – Dec 2024). Outcomes measured at state × month:
- Active HCBS provider count (unique billing NPIs for T/S codes)
- Total beneficiaries served (T/S code beneficiary counts)
- Total HCBS spending (T/S code payments)
- Provider entry/exit rates (appearance/disappearance of NPIs in monthly billing)
- Per-provider intensity (claims per active provider)

**Treatment variable:** Pre-COVID (2019) Medicaid-to-outside-wage ratio by state.
- *Medicaid side:* BLS OES median hourly wage for SOC 39-9021 (Personal Care Aides) by state, 2019
- *Outside option:* BLS OES median hourly wage for composite competing occupations by state: SOC 41-2011 (Cashiers), 35-3021 (Combined Food Prep/Serving), 53-7062 (Laborers/Freight/Stock Movers)
- *Ratio:* Personal care aide wage / weighted-average competing-sector wage
- *Validation:* T-MSIS implied per-claim rate for T1019 by state correlates with BLS wage measure

**Identification:** Continuous-treatment difference-in-differences with pre-determined treatment.
- Y_st = Σ_t β_t × (WageRatio_s × 1[Month=t]) + γ_s + δ_t + X_st'λ + ε_st
- Pre-trend test: β_t ≈ 0 for all t < March 2020
- Identifying assumption: Conditional on state FE, the 2019 wage ratio is uncorrelated with pandemic severity
- Controls: COVID cases/deaths per capita, state unemployment rate, lockdown stringency index
- Clustering: State-level (wild bootstrap for ≤50 clusters)

**Key innovations:**
1. **Monopsony stress test framework:** Medicaid is a monopsonist in HCBS labor markets. The wage ratio measures the monopsony markdown. COVID is an exogenous stress test that reveals structural fragility — connecting to Manning (2003), Azar/Marinescu/Steinbaum (2022 QJE), Dube/Jacobs/Naidu/Suri (2020 QJE).
2. **Triple-difference Medicare placebo:** Compare Medicaid HCBS disruption to Medicare home health disruption within the same states. Medicare rates are federally set → not subject to state monopsony → should NOT respond to the Medicaid wage ratio. This is a powerful within-state falsification test using Medicare Physician/Supplier PUF.
3. **ARPA repair test:** States with lowest pre-COVID ratios received the largest ARPA-funded rate increases (most catch-up needed). Test whether ARPA rate increases reversed the workforce disruption — and whether recovery depends on actually closing the competitiveness gap, not just raising rates.
4. **Distribution effects:** Show that the monopsony stress test disproportionately affected small providers (sole proprietors) vs. large organizations, increasing market concentration in low-competitiveness states.

**Why it's novel:**
- Distinct from 5 existing Medicaid APEP papers: 0353 (labor tightness Bartik IV), 0448 (UI termination timing), 0447 (lockdown stringency), 0341 (rate increases), 0327 (minimum wages). Each uses a discrete policy shock; this paper uses the pre-existing structural wage gap × exogenous stress test.
- First paper to apply the monopsony stress test framework to healthcare labor markets
- First to use the Medicaid-to-outside-wage ratio as a continuous treatment variable
- First to validate with within-state Medicaid-vs-Medicare comparison

**Feasibility check:**
- ✅ T-MSIS: 52 states with T-code billing, 32 with ≥50 providers, 84 months (verified)
- ✅ BLS OES: Public download, state × annual × occupation (direct CSV/Excel)
- ✅ NPPES extract: 9.4M providers with state, exists locally (verified)
- ✅ Medicare PUF: data.cms.gov Socrata API, no key needed (confirmed working)
- ✅ COVID data: NYT/CDC state × day cases/deaths (public)
- ✅ 26 pre-COVID months for parallel trends, 58 post-COVID months for effects
- ✅ Treatment is pre-determined (2019 values) → no mechanical pre-trends

**DiD feasibility screen:**
| Criterion | Value | Status |
|-----------|-------|--------|
| Pre-treatment periods | 26 months (Jan 2018 – Feb 2020) | ✅ |
| Treated clusters | All 50 states (continuous treatment) | ✅ |
| Selection into treatment | Pre-determined by 2019 wage structure | ✅ |
| Comparison group | High-ratio states as implicit control | ✅ |
| Outcome-policy alignment | HCBS provider supply directly affected by wage competitiveness | ✅ |


## Idea 2: The HCBS Pipeline Problem — Does Medicaid Wage Competitiveness Determine Who Enters the Home Care Workforce?

**Policy:** Same structural variation as Idea 1 — state-level Medicaid wage competitiveness — but focuses on the ENTRY margin rather than exits. States with higher Medicaid-to-outside-wage ratios should attract more new providers into HCBS over time.

**Outcome:** New provider entries into HCBS billing (first observed T-code billing month for each NPI in T-MSIS). NPPES enumeration dates provide a second measure of workforce pipeline flow. State × quarter panel of new HCBS entrant counts.

**Treatment variable:** Same as Idea 1 — BLS OES personal care aide wage / composite competing-sector wage ratio by state, measured annually.

**Identification:** Panel regression exploiting within-state variation over time as outside-option wages change (Amazon $15 minimum in 2018, state minimum wage increases, pandemic labor market tightening). Entry_st = f(WageRatio_st, State FE, Time FE).

**Why it's novel:** Complements the exit-focused literature (including Idea 1). Understanding entry dynamics is crucial for workforce planning — even if exits slow, inadequate pipeline means the crisis persists.

**Feasibility check:**
- ✅ NPPES enumeration dates available for all NPIs
- ✅ T-MSIS first-billing month identifiable from data
- ✅ BLS OES provides annual wage data for the ratio
- ⚠️ Challenge: Disentangling "new to HCBS" from "new NPI" — some entrants may be experienced workers changing organizations
- ⚠️ Challenge: Time-varying wage ratio requires careful treatment of endogeneity (states that lose workers may raise wages in response)


## Idea 3: When Medicaid Can't Compete — Cross-Payer Substitution from Medicaid to Medicare Home Health

**Policy:** When Medicaid HCBS reimbursement is uncompetitive, providers who serve both Medicaid and Medicare populations may shift effort toward better-paying Medicare home health. This is a cross-payer substitution story: the same providers (identified by NPI) billing less Medicaid and more Medicare over time, especially in low-reimbursement states.

**Outcome:** For dual-billing NPIs (those appearing in BOTH T-MSIS and Medicare Physician/Supplier PUF): Medicaid share of total billing (T-MSIS paid / [T-MSIS paid + Medicare PUF paid]) by NPI × year. Aggregated to state × year panel.

**Treatment variable:** State-level Medicaid-to-Medicare reimbursement ratio for comparable home health services. Constructed from T-MSIS implied rates vs. Medicare PUF rates for overlapping HCPCS codes (e.g., 99211-99215 office visits, G0151-G0154 home health therapy).

**Identification:** Panel DiD exploiting state-level variation in the Medicaid-Medicare rate gap. States with larger gaps should see faster Medicaid-to-Medicare substitution, especially post-COVID when workforce is scarce.

**Why it's novel:** First paper to use the T-MSIS + Medicare PUF NPI linkage to track cross-payer substitution at the provider level. Existing literature discusses "cream-skimming" abstractly; this paper measures it directly. Distinct from all existing APEP Medicaid papers (none use cross-payer linkage as the primary research design).

**Feasibility check:**
- ✅ T-MSIS and Medicare PUF both have NPI × HCPCS
- ✅ Medicare PUF available on data.cms.gov (Socrata, no key needed)
- ⚠️ Challenge: Only ~15-20% of T-MSIS NPIs also appear in Medicare PUF (most T/H/S codes have no Medicare equivalent)
- ⚠️ Challenge: Dual-billing providers may be fundamentally different from Medicaid-only providers (selection)
- ⚠️ Challenge: The Medicaid-Medicare rate gap may not be the binding constraint (workforce allocation may depend on patient referrals, contracts, regulatory requirements)


## Idea 4: The Price of Being Essential — Healthcare Worker Wage Compression During the Pandemic

**Policy:** State minimum wage increases during 2018-2024. As minimum wages rose toward $15/hour, they compressed the premium HCBS workers earned over unskilled alternatives, potentially driving exit from the sector.

**Outcome:** T-MSIS HCBS provider outcomes (same as Idea 1). But treatment is the time-varying compression ratio: (HCBS worker wage - state minimum wage) / HCBS worker wage.

**Identification:** Staggered DiD exploiting state minimum wage increases (28 states raised during period, 23 at federal minimum). Treatment intensity measured by how much the increase compressed the HCBS wage premium.

**Why it's novel:** Differs from apep_0327 and apep_0339 in measuring the COMPRESSION of the premium (relative to HCBS wages) rather than the absolute minimum wage change. Same shock, different mechanism: not "minimum wage raised costs" but "minimum wage eliminated the incentive to stay in HCBS."

**Feasibility check:**
- ✅ State minimum wage dates well-documented (DOL, NCSL)
- ✅ BLS OES provides HCBS wage data
- ✅ 28 treated states, staggered timing
- ⚠️ Challenge: Substantial overlap with apep_0327 and apep_0339 in design space
- ⚠️ Challenge: Compression ratio is endogenous to HCBS wage changes (which may also respond to policy)
