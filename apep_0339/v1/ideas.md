# Research Ideas

## Idea 1: State Minimum Wage Increases and the Medicaid Home Care Workforce

**Policy:** State minimum wage increases, 2018–2024. Over 30 states raised their minimum wage during this period, with staggered effective dates (mostly January 1, some July 1 or other dates). The federal minimum ($7.25) has been unchanged since 2009, providing a natural control group of ~20 states.

**Outcome:** HCBS provider supply and billing activity from T-MSIS. Specifically: (1) provider entry/exit rates (new/disappearing NPIs in T-code billing), (2) billing volume per active provider, (3) beneficiaries served per provider, (4) total HCBS spending per capita. Focus on personal care (T1019), attendant care (S5125), and habilitation (T2016) — the three largest HCBS codes, all delivered by low-wage direct care workers.

**Identification:** Staggered difference-in-differences using the Callaway & Sant'Anna (2021) estimator. Treatment: state minimum wage increase events. Each state-year with a MW increase constitutes a new cohort. Never-treated states (those at federal minimum throughout) serve as the comparison group. Continuous treatment intensity: dollar amount of MW increase relative to prevailing HCBS reimbursement rate.

**Why it's novel:** The minimum wage literature has extensively studied employment and hours in restaurants, retail, and general labor markets. Zero papers examine the effect on Medicaid HCBS provider supply — because until T-MSIS was released (February 2026), no provider-level HCBS data existed. HCBS workers (personal care aides, home health aides) earn median wages of $14–15/hour, placing them directly at the minimum wage margin in many states. The interaction between minimum wage policy and Medicaid provider supply is an unstudied but first-order policy question: if MW increases squeeze provider margins without corresponding Medicaid rate adjustments, HCBS supply could contract, harming the very low-income populations the minimum wage is designed to help.

**Feasibility check:**
- Variation: 30+ treated states with staggered timing ✓
- Pre-periods: T-MSIS covers Jan 2018–Dec 2024 = 84 months ✓
- Data access: T-MSIS (local Parquet), NPPES (bulk download), FRED API for MW data (confirmed working), BLS QCEW (direct CSV) ✓
- Novelty: No APEP papers on minimum wage + HCBS. No prior literature combining MW with provider-level Medicaid data ✓
- Sample size: 617K billing NPIs, 227M rows ✓

---

## Idea 2: Medicaid Postpartum Coverage Extensions and OB/GYN Provider Supply

**Policy:** State adoption of 12-month postpartum Medicaid coverage extensions, 2022–2024. 47 states adopted on staggered timelines under the American Rescue Plan Act and subsequent state legislation. This extends coverage from 60 days to 12 months postpartum.

**Outcome:** OB/GYN and maternal health provider participation in Medicaid from T-MSIS. Specifically: (1) new OB/GYN NPIs appearing in Medicaid billing, (2) billing volume for maternity-related HCPCS codes, (3) beneficiaries per provider. Provider specialty identified via NPPES taxonomy codes.

**Identification:** Staggered DiD with CS estimator. Treatment: month of state adoption. Control: states not yet adopted (clean staggered design with 47 treated states).

**Why it's novel:** APEP paper 0149 studies postpartum extensions from the DEMAND side (maternal outcomes). This paper examines the SUPPLY side: do providers respond to expanded coverage by entering Medicaid? The supply-side response to coverage expansion is theoretically important (Finkelstein 2007) but rarely studied for Medicaid.

**Feasibility check:**
- Variation: 47 treated states with staggered adoption ✓
- Pre-periods: Earliest adoption ~April 2022, giving 4+ years pre-data ✓
- Data access: T-MSIS + NPPES for provider specialty ✓
- Novelty: Different angle from 0149 (supply vs demand) ✓
- Risk: OB/GYN codes are CPT (not T/H/S), so T-MSIS comparative advantage is weaker

---

## Idea 3: ARPA HCBS Rate Increases and Provider Entry

**Policy:** American Rescue Plan Act Section 9817 (April 2021) provided a 10 percentage point FMAP increase for HCBS, conditional on states maintaining eligibility and using savings to strengthen HCBS. States submitted spending plans to CMS on staggered timelines (2021–2023). Many directed funds to provider rate increases: NC +40%, CO +6–10%, VA +12%, NM +8.5%.

**Outcome:** HCBS provider entry rates, active provider counts, and billing volume from T-MSIS. Focus on T-code providers who are 100% Medicaid-dependent.

**Identification:** Staggered DiD. Treatment: month of state HCBS rate increase implementation. Control: states that did not increase rates or increased later.

**Why it's novel:** First provider-level evaluation of ARPA HCBS spending. Prior research focuses on aggregate Medicaid spending or enrollment. T-MSIS reveals whether rate increases actually attracted new providers.

**Feasibility check:**
- Variation: ~25 states implemented rate increases, staggered 2021–2023 ✓
- Pre-periods: 3+ years pre-ARPA (Jan 2018–March 2021) ✓
- Data access: T-MSIS + NPPES ✓
- Risk: Implementation dates are harder to pin down than minimum wage dates; concurrent with COVID recovery and unwinding. MODERATE feasibility.

---

## Idea 4: Certificate of Need Law Changes and Medicaid Provider Market Structure

**Policy:** Several states reformed or repealed Certificate of Need (CON) laws during 2018–2024, affecting healthcare facility entry barriers.

**Outcome:** Provider market concentration (HHI), entry rates, organizational billing structure from T-MSIS.

**Identification:** DiD comparing reforming vs non-reforming states.

**Why it's novel:** CON research typically focuses on hospital markets. HCBS/behavioral health provider entry under CON has not been studied.

**Feasibility check:**
- Variation: Only ~5 states made significant CON changes in this period ✗
- REJECT: Insufficient treated states for credible DiD (<10)
