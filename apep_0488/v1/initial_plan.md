# Initial Research Plan: apep_0488

## Research Question

What is the welfare cost of Prescription Drug Monitoring Programs (PDMPs)? Must-access PDMP mandates — which require prescribers to query a state database before writing opioid prescriptions — reduced opioid prescribing by 8–12% (Buchmueller and Carey 2018). But prescribing reductions impose real costs on patients with legitimate pain, even as they reduce addiction and overdose deaths. We derive the sufficient statistics for the welfare effect of prescribing regulation under addiction, estimate each statistic from staggered state adoption, and present welfare bounds under three behavioral models of addiction.

## Conceptual Framework

We build on the sufficient statistics approach to welfare analysis (Chetty 2009; Allcott, Lockwood, and Taubinsky 2019 QJE) and extend it to gatekeeper-mediated prescribing regulation with addictive goods.

**Model:** A continuum of patients indexed by type θ ∈ {L, A} (legitimate pain vs. addiction-risk), with quasi-hyperbolic discounting (β, δ) following Gruber and Koszegi (2001 QJE). Physicians prescribe on behalf of patients, introducing an agency wedge. A social planner chooses regulatory stringency τ (the PDMP mandate).

**Welfare formula:**

dW/dτ = (γ̄ + ē + φ̄) · (−dQ̄/dτ) − v̄_L · (−dQ_L/dτ) − C'(τ)

where:
- γ̄ = average internality (present-biased patients underweight future addiction costs)
- ē = average externality (overdose deaths, healthcare costs, diversion, crime)
- φ̄ = physician agency wedge (over-prescribing due to time pressure, industry influence, demand accommodation)
- v̄_L = marginal value of pain management for legitimate patients
- dQ̄/dτ = total prescribing reduction from PDMP (the main DiD estimate)
- dQ_L/dτ = prescribing reduction among legitimate pain patients (heterogeneous effect)
- C'(τ) = marginal administrative cost of the PDMP system

**Three welfare benchmarks (the paper's key deliverable):**
1. **Rational addiction** (Becker and Murphy 1988 JPE): γ̄ = 0. PDMP welfare depends only on externalities minus pain management costs. Welfare ambiguous — could be negative if pain costs exceed externality gains.
2. **Moderate present bias** (Gruber and Koszegi 2001 QJE, β ≈ 0.5–0.7): γ̄ = (1−β) × PV(expected addiction costs). PDMP likely welfare-improving for moderate β values.
3. **Cue-triggered addiction** (Bernheim and Rangel 2004 AER): γ̄ ≈ full expected cost of addiction. PDMP strongly welfare-improving.

**Novel theoretical contributions:**
(a) First application of sufficient statistics to addiction policy (extends Allcott-Lockwood-Taubinsky to addictive goods with bimodal internalities)
(b) Physician agency enters the welfare formula as a new channel not in prior sin-tax models
(c) Supply-side regulation (quantity restriction via gatekeeper) vs. demand-side taxation (the entire prior literature)

## Identification Strategy

**Design:** Staggered Difference-in-Differences (Callaway and Sant'Anna 2021)

**Treatment:** Adoption of a must-access PDMP mandate requiring prescribers to query the state PDMP database before writing controlled substance prescriptions.

**Treatment timing:** The effective date of the must-access requirement, sourced from RAND OPTIC (GitHub: cdigenna/OPTIC-data, variable `date_prescriber_mustaccess`).

**Treated units:** ~36 US states that adopted must-access PDMP mandates between 2012 and 2019, with the bulk of adoption in 2015–2019.

**Control units:** States without must-access mandates during the estimation window (never-treated in the CS framework).

**Key restriction:** Main specification restricts to cohorts adopting 2014 or later (32+ states), giving ≥1 year of pre-treatment data in Medicare Part D. Robustness includes all cohorts (adding KY 2012, TN/NY/WV 2013).

**Clustering:** State-level. With ~36 treated states, standard cluster-robust inference is appropriate. Wild cluster bootstrap reported for robustness.

## Expected Effects and Mechanisms

**First stage (prescribing):**
- Expected: Must-access PDMP → 8–12% reduction in opioid prescribing volume (consistent with Buchmueller-Carey 2018)
- Mechanism 1 (hassle costs): ~70% of prescribing decline comes from hassle costs, not information (Alpert-Dykstra-Jacobson 2024)
- Mechanism 2 (physician agency): High-prescribing physicians reduce more; low-prescribing physicians unaffected
- Mechanism 3 (composition): Long-acting opioids may decline more than short-acting (testable with Part D LA fields)

**Mortality:**
- Rx opioid mortality (ICD-10 T40.2): Expected decrease
- Heroin mortality (ICD-10 T40.1): Possible increase (substitution channel, Mallatt 2020)
- Synthetic/fentanyl mortality (ICD-10 T40.4): Possible increase (substitution)
- Total opioid mortality: Net effect is the key welfare input — genuinely ambiguous

**Welfare:**
- Under rational addiction (γ̄ = 0): PDMP welfare depends entirely on externalities (mortality reduction × VSL) minus pain management costs. Could be negative if substitution to illicit opioids increases total deaths.
- Under moderate present bias: PDMP adds internality correction for at-risk patients. Likely net positive.
- Under cue-triggered model: PDMP strongly positive because preventing initial prescriptions prevents addiction cascades.

## Primary Specification

**Equation (CS-DiD, first stage — prescribing):**

ATT(g,t) = E[Y_{i,t}(g) − Y_{i,t}(∞) | G_i = g]

where Y is opioid prescribing rate (claims per 100 beneficiaries), g is the treatment cohort (year of must-access mandate), and G_i = ∞ for never-treated states. Aggregated to dynamic (event-time) and overall ATT.

**Mortality specification (state × year panel):**

deaths_per_100K_{s,t} = α_s + α_t + Σ_g δ_g · 1[State_s ∈ cohort_g] · 1[t ≥ g] + X'_{s,t}β + ε_{s,t}

with state and year FEs, time-varying controls for co-policies (naloxone access, Good Samaritan, prescribing limits, Medicaid expansion), and state-level clustering.

**Heterogeneous effects (welfare decomposition):**
- By prescriber type: primary care vs. pain specialists vs. surgeons (proxy for patient type L vs. A)
- By pre-PDMP opioid intensity: high-prescribing states vs. low-prescribing states
- By opioid formulation: long-acting vs. short-acting (built into Part D data)
- By beneficiary demographics: dual-eligible (proxy for low-income), race, age

**Welfare calibration:**
- Externality (ē): Overdose deaths averted × VSL ($10.9M, EPA 2024) + healthcare cost savings (from literature)
- Internality bounds: γ̄ ∈ [0, full addiction cost] with intermediate β-calibrated values
- Pain management cost: Proxied by (a) changes in non-opioid pain treatment, (b) disability application rates, (c) ER visits for pain conditions post-PDMP
- Administrative cost: State PDMP implementation budgets (from PDMP TTAC reports)

## Data Sources

| Source | Variable | Geographic Level | Time Period | Access |
|--------|----------|-----------------|-------------|--------|
| Medicare Part D "by Provider" (CMS) | Opioid prescribing volume, cost, beneficiaries, prescriber rate; by formulation (LA vs. all); provider NPI, state, ZIP, specialty | Provider (NPI) | 2013–2023 | Direct CSV download from data.cms.gov |
| Medicare Part D "by Geography" (CMS) | Opioid prescribing rates by state, county, ZIP | State/County/ZIP | 2013–2023 | Direct CSV download |
| CDC WONDER Multiple Cause of Death | Drug overdose mortality by ICD-10 cause (T40.1 heroin, T40.2 Rx opioid, T40.4 synthetic) | State × year | 1999–2023 | CDC WONDER web interface |
| RAND OPTIC (GitHub) | Must-access PDMP dates, any PDMP dates, electronic PDMP dates | State | 2005–2019 | GitHub: cdigenna/OPTIC-data (Stata/Excel) |
| RAND OPTIC — NAL/GSL | Naloxone access law dates, Good Samaritan law dates | State | 2005–2019 | GitHub (same repo) |
| PDAPS (pdaps.org) | Prescribing limit dates (day supply caps, MME limits) | State | 2012–2022 | Direct download |
| Census ACS (API) | State population, demographics, poverty rate | State | 2010–2023 | Census API |
| FRED (API) | State unemployment rate | State | 2010–2023 | FRED API |
| KFF/CMS | Medicaid expansion status and dates | State | 2014–2023 | Public tables |

## Planned Robustness Checks

1. **Pre-trend verification:** CS-DiD event-study plots for prescribing and mortality; pre-trend F-tests; cohort-specific event studies for the 3 largest adoption waves
2. **HonestDiD sensitivity:** Rambachan-Roth bounds on pre-trend violations
3. **Policy bundling controls:** Include naloxone access, Good Samaritan, prescribing limits, Medicaid expansion as time-varying controls; leave-one-out co-policy test (drop states with co-policies ±1 year)
4. **Population restriction:** Main sample = post-2014 adopters; robustness = all cohorts including KY/TN/NY/WV
5. **Sun-Abraham estimator:** Alternative aggregation as robustness
6. **Wild cluster bootstrap:** For inference with ~36 treated state clusters
7. **Leave-one-out states:** Drop each of the 5 largest treated states individually
8. **Mortality decomposition placebo:** Non-opioid drug mortality (expected null); motor vehicle mortality (expected null)
9. **Prescribing placebo:** Non-opioid prescribing (antibiotics, antipsychotics — both in Part D data, expected null)
10. **Internality sensitivity:** Report welfare under γ̄ = 0, (1−0.7) × PV(addiction), (1−0.5) × PV(addiction), full addiction cost

## Exposure Alignment (DiD)

- **Who is actually treated?** Prescribers in states with must-access PDMP mandates (and, indirectly, their patients)
- **Primary estimand population:** (1) Medicare Part D prescribers (prescribing effects); (2) All state residents (mortality effects)
- **Placebo/control population:** (a) States without must-access mandates (never-treated); (b) Non-opioid prescribing within treated states (placebo outcome); (c) Non-opioid mortality (placebo outcome)
- **Design:** Staggered DiD (CS estimator), with welfare calibration

## Power Assessment

**Prescribing (provider-level Part D):**
- ~480,000 opioid prescribers per year × 10 years = ~4.8M provider-year observations
- ~36 treated states, staggered across 2012–2019
- Prior literature finds 8–12% effects (Buchmueller-Carey 2018) — very well-powered
- Pre-treatment mean: ~3.5% opioid prescribing rate; expected change: -0.3–0.4 pp

**Mortality (state × year):**
- 50 states × 25 years (1999–2023) = 1,250 state-year observations
- Opioid overdose deaths: ~47,600 in 2017 (peak Rx opioid era); substantial cross-state variation
- Prior literature detects 5–10% mortality effects — detectable with 50-state panel
- Power concern: State-year mortality is noisier than prescribing. Cause-specific mortality (T40.2 only) may have small counts in low-population states — suppress/aggregate as needed.

## Key Literature

| Paper | Contribution | Relationship to This Paper |
|-------|-------------|---------------------------|
| Buchmueller & Carey (2018 AEJ:EP) | Must-access PDMPs reduce Rx opioid prescribing in Medicare Part D | Our first-stage benchmark |
| Alpert, Dykstra & Jacobson (2024 AEJ:EP) | Hassle costs explain ~70% of PDMP prescribing decline | Identifies the mechanism we model |
| Mallatt (2020) | PDMPs increase heroin mortality via substitution | Our substitution channel |
| Alpert, Powell & Pacula (2018 AER) | OxyContin reformulation → heroin substitution | Supply-side regulation backfire |
| Mulligan (2024 JPE) | Nonconvex budget sets in opioid markets | Closest to welfare, but no welfare quantification |
| Cutler & Donahoe (2024 NBER) | Addiction dynamics and spatial spillovers | Models dynamics but no welfare |
| Allcott, Lockwood & Taubinsky (2019 QJE) | Sufficient statistics for sin taxes | Our methodological template |
| Deshpande & Lockwood (2022 Econometrica) | Sufficient statistics for disability insurance | Second template |
| Finkelstein & Hendren (2020 QJE) | MVPF framework | Welfare comparison framework |
| Gruber & Koszegi (2001 QJE) | Time-inconsistent addiction → internalities | Our internality model |
| Becker & Murphy (1988 JPE) | Rational addiction model | Our lower-bound benchmark (γ = 0) |
| Bernheim & Rangel (2004 AER) | Cue-triggered addiction | Our upper-bound benchmark |
| Chetty (2009 Annual Review) | Sufficient statistics methodology | Our methodological foundation |
| Schnell & Currie (2018) | Physician heterogeneity in opioid prescribing | Motivates physician agency channel |
