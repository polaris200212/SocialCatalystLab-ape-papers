# Research Ideas

## Idea 1: Back to Work? Early Termination of Pandemic Unemployment Benefits and Medicaid HCBS Provider Supply

**Policy:** In June–July 2021, 26 U.S. states voluntarily ended the $300/week Federal Pandemic Unemployment Compensation (FPUC) supplement before the federal expiration date of September 6, 2021. Termination dates were staggered: June 12 (AK, IA, MS, MO), June 19 (AL, ID, IN, NE, NH, ND, WV, WY), June 26 (AR, FL, GA, OH, OK, SD, TX, UT), June 27 (MT), June 30 (SC), July 3 (MD, TN), July 10 (AZ), July 31 (LA). The remaining 24 states + DC maintained benefits through September 6.

**Outcome:** Monthly HCBS provider billing from T-MSIS: (1) count of active billing providers (T-codes: personal care, habilitation, attendant care), (2) total claims submitted, (3) total Medicaid payments, (4) unique beneficiaries served. Separate extensive margin (provider count) from intensive margin (claims per provider).

**Identification:** Staggered DiD using Callaway-Sant'Anna (2021) heterogeneity-robust estimator. Treatment = month of early UI termination for each state. Never-treated = 24 states + DC that maintained benefits through September 6. Pre-treatment: Jan 2018 – month before state's termination date (~41 months). Post-treatment: termination month through December 2024 (~42 months). State-level clustering (51 clusters).

**Why it's novel:** Existing literature on early UI termination (Holzer, Hubbard, & Strain 2021; Coombs et al. 2022; Ganong et al. 2022) measures aggregate employment effects using CPS/UI claims data. No paper has measured the sector-specific effect on Medicaid home care delivery. HCBS direct care workers earn $12–15/hr — often less than the $300/week UI supplement — making this sector uniquely vulnerable to the UI work disincentive. The T-MSIS data provides the first opportunity to measure whether UI termination restored home care access for vulnerable Medicaid beneficiaries.

**Feasibility check:**
- Variation: 26 treated states, staggered across 7 distinct dates over 7 weeks; 25 never-treated units. Well above the ≥20 treated threshold.
- Pre-treatment periods: 41 months (Jan 2018 – May 2021). Far exceeds ≥5 requirement.
- Data access: T-MSIS Parquet (local, confirmed), NPPES extract (local, confirmed), UI termination dates (Ballotpedia, confirmed). Test query returns 959K HCBS provider-months for 2020-2022 with 99.1% state match rate.
- Novelty: Not in APEP list. No existing paper connects early UI termination to Medicaid HCBS provider supply. Distinct from apep_0447 (lockdowns × HCBS/BH triple-diff) — different policy (UI benefits, not lockdowns), different time period (mid-2021, not spring 2020), different mechanism (labor supply incentive, not physical access restriction).
- Sample size: 54 states × 84 months = 4,536 state-month cells. Provider-level panel has 959K+ provider-months for T-codes alone.

---

## Idea 2: Hazard Pay for Heroes? State Direct Care Worker Bonuses and Medicaid HCBS Provider Retention

**Policy:** During 2020–2021, approximately 18 states provided temporary hazard pay, retention bonuses, or wage supplements specifically for direct care workers (HCBS aides, home health aides, personal care attendants) funded through a mix of state appropriations, FEMA reimbursements, and later ARPA Section 9817. Examples: Pennsylvania ($3/hr premium, May–Sept 2020), Vermont ($2/hr, March 2020), Minnesota ($0.75/hr, March–June 2020), Connecticut ($2/hr, March–May 2020). Amounts, timing, and eligibility varied by state.

**Outcome:** HCBS provider retention rate (share of providers active in month t who were also active in t-6), provider entry (new NPIs billing T-codes), and billing volume from T-MSIS.

**Identification:** DiD comparing states that implemented hazard pay vs. those that did not, with staggered adoption dates. Continuous treatment intensity (bonus amount per hour). Pre-trends in provider retention rates before COVID.

**Why it's novel:** No paper has measured whether hazard pay actually retained HCBS providers using claims-level data. Existing evidence is survey-based (PHI, KFF). T-MSIS allows measurement of actual billing behavior, not reported intentions.

**Feasibility check:**
- Variation: ~18 treated states, staggered March 2020 – early 2021
- Data: T-MSIS (confirmed), state hazard pay policies (KFF compilation exists, needs verification of exact dates/amounts)
- Risk: Manual coding of hazard pay policies required; dates/eligibility may be imprecise. Some states provided bonuses only to nursing home workers, not HCBS. Verification burden is high.
- Novelty: Not in APEP list. Not overstudied.

---

## Idea 3: The Pandemic Churn Freeze: Continuous Enrollment and Provider Revenue Stability

**Policy:** The Families First Coronavirus Response Act (FFCRA, March 2020) required states to maintain continuous Medicaid enrollment as a condition of the 6.2% enhanced FMAP. States could not disenroll beneficiaries for any reason through the end of the PHE (April 2023). This created a massive enrollment surge — from ~71M (Feb 2020) to ~93M (March 2023) — but the intensity of the enrollment shock varied dramatically by state depending on pre-COVID churn rates.

**Outcome:** HCBS provider entry, billing volume, and beneficiary panels per provider from T-MSIS. Beneficiaries served is the key outcome — if continuous enrollment locked in clients, providers should show more stable (or growing) beneficiary counts.

**Identification:** Cross-sectional variation in treatment intensity, measured by the state's pre-COVID Medicaid disenrollment rate (2018-2019 average). States with high pre-COVID churn experienced the largest enrollment shock from the continuous enrollment condition. DiD interaction: high-churn × post (March 2020+).

**Why it's novel:** Existing papers on continuous enrollment focus on the demand side (enrollment counts, coverage gaps). This flips the perspective to the supply side: did the revenue stability from locked-in beneficiaries help retain HCBS providers during the pandemic?

**Feasibility check:**
- Variation: Continuous state-level variation in pre-COVID churn rates. 50+ states.
- Data: T-MSIS (confirmed), CMS Medicaid enrollment data (confirmed, monthly snapshots available via Medicaid.gov)
- Risk: No staggered adoption — the continuous enrollment condition applied to all states simultaneously. The identification relies on cross-sectional variation in treatment intensity, which is weaker than staggered DiD. Pre-COVID churn rates may correlate with other state characteristics.
- Novelty: Not in APEP list. apep_0307 and 0417 study the UNWINDING (end of continuous enrollment); this studies the BUILD-UP.

---

## Idea 4: Did COVID Kill Home Care? Excess Mortality and the Permanent Depletion of the HCBS Beneficiary Pool

**Policy:** COVID-19 disproportionately killed elderly and disabled individuals — the primary users of Medicaid HCBS services. State-level excess mortality among the 65+ population varied dramatically (from ~200 to ~600+ excess deaths per 100K by end of 2021), driven by differences in population density, health infrastructure, nursing home penetration, and vaccination rates.

**Outcome:** HCBS billing volume, unique beneficiaries served, and provider exit from T-MSIS. Focus on whether high-mortality states saw permanent declines in HCBS demand that triggered provider exit.

**Identification:** Continuous DiD using state-level cumulative excess mortality among 65+ as the treatment variable, interacted with post-COVID indicators. Alternative: event study around mortality wave peaks. The key identifying assumption is that pre-COVID trends in HCBS billing were parallel across high- and low-mortality states.

**Why it's novel:** Most COVID-Medicaid research focuses on enrollment or policy responses (telehealth, continuous enrollment). This examines the direct demographic shock — COVID literally removed beneficiaries from the HCBS system through death.

**Feasibility check:**
- Variation: Continuous state-level variation in excess mortality. All 50+ states.
- Data: T-MSIS (confirmed), CDC excess mortality estimates (WONDER, confirmed), Census population by age (ACS, confirmed)
- Risk: Excess mortality is endogenous to state policies, health infrastructure, and demographics. Hard to isolate a causal channel. Mortality among Medicaid HCBS beneficiaries specifically is not observable — only population-level mortality.
- Novelty: Not in APEP list. Creative angle on the demand-side demographic shock.
