# Initial Research Plan: Back to Work? Early Termination of Pandemic Unemployment Benefits and Medicaid HCBS Provider Supply

## Research Question

Did the early termination of federal pandemic unemployment benefits in 26 U.S. states during June–July 2021 increase the supply of active Medicaid home and community-based services (HCBS) providers, and was this effect concentrated among the lowest-paid segments of the HCBS workforce?

## Identification Strategy

**Staggered Difference-in-Differences (CS-DiD)**

Treatment: Early termination of the $300/week FPUC supplement. 26 states terminated benefits between June 12 and July 31, 2021. 24 states + DC maintained benefits through the federal expiration on September 6, 2021.

For CS-DiD, we define treatment cohorts by the first full month of exposure:
- **July 2021 cohort** (22 states): AL, AK, AR, FL, GA, IA, ID, IN, MS, MO, MT, NE, NH, ND, OH, OK, SC, SD, TX, UT, WV, WY
- **August 2021 cohort** (4 states): AZ, LA, MD, TN
- **Never-treated** (25 units): Remaining 24 states + DC

Key equation (TWFE baseline):
Y_{st} = α_s + γ_t + β × EarlyTermination_{st} + X_{st}'δ + ε_{st}

Primary estimator: Callaway and Sant'Anna (2021) group-time ATTs with never-treated comparison group.

**Identifying assumption:** Absent early UI termination, HCBS provider supply in early-terminating states would have evolved on the same trajectory as in states that maintained benefits. Testable via 41 months of pre-treatment data.

## Expected Effects and Mechanisms

1. **Provider re-entry (extensive margin):** HCBS workers who left to collect UI return to billing. Provider count increases in early-terminating states relative to non-terminators, beginning in the first full month after termination.
2. **Billing intensity (intensive margin):** Existing providers may work more hours as the labor market tightens (substitution from UI to work).
3. **Beneficiary access:** More providers → more beneficiaries served.
4. **Heterogeneity by service type:** Effects should be strongest for personal care (T1019, T1019-HQ) and attendant care (S5125, S5130) — the lowest-paid HCBS services — and weaker for habilitation (T2016, T2020) and behavioral health (H-codes) where workers earn more.

**Theoretical mechanism:** HCBS direct care workers earn $12–15/hr nationally (PHI, 2021). The $300/week FPUC supplement equals $7.50/hr for a 40-hour week. Combined with state UI benefits ($200-400/week), total UI income often exceeded HCBS wages, creating a work disincentive. Ending the supplement shifts the reservation wage below the HCBS wage, inducing return to work.

## Primary Specification

- **Panel:** State × month, January 2018 – December 2024 (84 months × 51 units = 4,284 cells)
- **Outcomes:** (1) log(active HCBS providers), (2) log(total HCBS claims), (3) log(total HCBS paid), (4) log(unique beneficiaries)
- **Treatment:** Binary indicator for post-early-termination × early-terminating state
- **Estimator:** Callaway-Sant'Anna with never-treated comparison, universal base period
- **Standard errors:** Clustered at state level (51 clusters)
- **HCBS definition:** T-codes (T1019, T1020, T2016, T2020, T2022, T2025, T2026, T2030, T2034, T1015) + S-codes for attendant care (S5125, S5130, S5150)

## Planned Robustness Checks

1. **Event-study pre-trends:** CS-DiD event study with 12 pre-treatment periods and 12+ post-treatment periods. Formal pre-trend test.
2. **TWFE baseline:** Standard two-way fixed effects for comparison with CS-DiD.
3. **Bacon decomposition:** Check for problematic negative weights in TWFE.
4. **Placebo: Behavioral health (H-codes):** Workers earn $18-25/hr — above the UI reservation wage. Expect null effect.
5. **Placebo: CPT professional services:** Medical providers (physicians, NPs) — not affected by UI supplement. Expect null effect.
6. **Entropy balancing:** Re-weight control states to match treated states on pre-COVID observables (HCBS provider count, Medicaid enrollment, unemployment, population).
7. **Within-region analysis:** Restrict to South and Midwest, where both treated and control states exist.
8. **COVID controls:** Add time-varying COVID deaths per capita, vaccination rates, and unemployment as covariates.
9. **Randomization inference:** Permute treatment assignment across states (500+ permutations) to test the sharp null.
10. **Alternative treatment timing:** Use actual termination dates (not first full month) as robustness.
11. **Provider-level analysis:** Logistic regression for individual provider re-entry/exit probability.

## Exposure Alignment (DiD)

- **Who is treated:** Medicaid HCBS providers in states that terminated UI benefits early
- **Primary estimand:** ATT — effect on HCBS provider supply in early-terminating states
- **Placebo/control population:** HCBS providers in states that maintained benefits through September 6
- **Design:** Staggered DiD with two treatment cohorts (July 2021, August 2021)

## Power Assessment

- **Pre-treatment periods:** 41 months (Jan 2018 – May 2021) — far exceeds minimum 5
- **Treatment clusters:** 26 states — exceeds minimum 20
- **Post-treatment periods:** ~42 months (July 2021 – Dec 2024)
- **Control units:** 25 (24 states + DC)
- **Total observations:** 4,284 state-months
- **Expected power:** Strong. The feasibility test showed ~2,000 HCBS providers per state-month in Texas, with visible variation around the treatment date. With 51 clusters and 41 pre-periods, we have excellent power to detect even modest effects.
- **MDE estimate:** With 51 clusters, 84 time periods, and ~5% within-state R² from treatment, we can detect effects as small as 3-5% changes in provider counts.

## Data Sources

1. **T-MSIS Medicaid Provider Spending** (local Parquet, 2.74 GB, 227M rows) — primary outcomes
2. **NPPES bulk extract** (local Parquet, 168 MB) — state assignment via practice address
3. **Early UI termination dates** (Ballotpedia, 26 states with exact dates)
4. **Census ACS** (API with CENSUS_API_KEY) — state population, demographics
5. **BLS QCEW** (direct CSV download) — state-quarter employment in healthcare
6. **CDC COVID Data Tracker** (API/CSV) — state-level COVID deaths, vaccinations
