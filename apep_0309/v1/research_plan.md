# Initial Research Plan: PDMP Network Spillovers and Opioid Mortality

## Research Question

Do must-query Prescription Drug Monitoring Program (PDMP) mandates in neighboring states affect local drug overdose mortality? Specifically, when a state's neighbors adopt must-query PDMPs, does it experience increased overdose deaths as opioid prescribing is displaced across borders — and does this "balloon effect" differ by drug type (prescription opioids vs. heroin vs. synthetic opioids)?

## Identification Strategy

**Doubly Robust Difference-in-Differences (DRDID)**

Treatment: For each state-year, construct a "PDMP Network Exposure" variable — the population-weighted share of contiguous neighboring states that have enacted must-query PDMP mandates. Binarize at a threshold (≥50% of neighbors treated) for the primary specification. The doubly robust estimator from Sant'Anna & Zhao (2020) combines:

1. **Propensity score model:** Logistic regression of network exposure on pre-treatment state characteristics (demographics, economic conditions, healthcare supply, own-PDMP status, political composition)
2. **Outcome regression:** Linear model of overdose mortality conditional on same covariates
3. **Double robustness:** ATT is consistent if either model is correctly specified

Key identification assumption: Conditional on observables (including own-state PDMP status), variation in PDMP network exposure is as good as random. This is strengthened by controlling for own-PDMP adoption, regional trends, and concurrent opioid policies.

## Expected Effects and Mechanisms

**Primary hypothesis (Balloon Effect):** When neighboring states adopt must-query PDMPs, prescribers in untreated states face increased demand from cross-border patients seeking prescriptions. This should:
- **Increase** prescription opioid overdose deaths (T40.2) in exposed states
- Have **ambiguous** effects on heroin (T40.1) — substitution may occur within neighboring states
- **Increase** synthetic opioid deaths (T40.4) if disrupted supply chains push users to illicit markets

**Alternative hypothesis (Information Diffusion):** Neighboring PDMPs may create demonstration effects, encouraging voluntary PDMP use or complementary policies, leading to **decreases** in overdose deaths.

**Network position heterogeneity:** Border states (high degree centrality) should experience larger spillovers than interior states (low centrality). States sharing longer borders with treated neighbors should be more exposed.

## Primary Specification

$$\hat{\tau}^{DR} = \frac{1}{n_1} \sum_{i: D_i=1} \left[\hat{m}_1(X_i) - \hat{m}_0(X_i) + \frac{D_i(Y_i - \hat{m}_1(X_i))}{\hat{e}(X_i)} - \frac{(1-D_i)(Y_i - \hat{m}_0(X_i))}{1-\hat{e}(X_i)}\right]$$

Where:
- $D_i$: Binary treatment (high PDMP network exposure ≥ 50%)
- $Y_i$: Age-adjusted drug overdose death rate per 100,000
- $X_i$: Pre-treatment covariates
- $\hat{e}(X_i)$: Estimated propensity score
- $\hat{m}_d(X_i)$: Estimated outcome regression for treatment group $d$

Panel structure: State-year, 2006–2023 (using overlap of NCHS + VSRR data).

## Covariates for Propensity Score / Outcome Model

1. Own-state PDMP must-query mandate (binary)
2. State population (log)
3. Median household income
4. Share non-Hispanic white
5. Share age 25-54 (prime opioid-risk demographic)
6. Unemployment rate
7. Share uninsured
8. Physicians per 100,000
9. Medicaid expansion status
10. Opioid prescription rate (MME per capita, if available)
11. Share rural population
12. State political composition (governor party, legislative control)

## Planned Robustness Checks

1. **Event-study plots:** Plot dynamic treatment effects for both own-PDMP adoption and neighbor-exposure, showing pre-trends
2. **Alternative thresholds:** Vary the network exposure threshold (25%, 50%, 75% of neighbors treated)
3. **Continuous treatment:** Use continuous network exposure (share of neighbors) with generalized propensity score methods
4. **Population vs. equal weighting:** Weight neighbor exposure by border-state population vs. equal weights
5. **Period splits:** Pre-fentanyl (2006–2013) vs. fentanyl era (2014–2023) to test whether the balloon effect changes with illicit supply
6. **Placebo outcomes:** Test effects on non-drug mortality causes (e.g., heart disease, cancer) — should be null
7. **Leave-one-out:** Sequentially drop each state to test sensitivity
8. **Concurrent policy controls:** Add controls for naloxone access laws, Good Samaritan laws, pill mill laws, Medicaid expansion
9. **Network position heterogeneity:** Interact treatment with state degree centrality and border length
10. **Callaway-Sant'Anna (2021):** Run CS-DiD as comparison estimator for staggered adoption analysis

## Data Sources

| Source | Variables | Endpoint/Access |
|--------|-----------|-----------------|
| CDC VSRR | State-month overdose deaths by drug type (2015–2024) | `data.cdc.gov/resource/xkb8-kh2a.json` |
| CDC NCHS Drug Poisoning | State-year overdose deaths/rates (1999–2015) | `data.cdc.gov/resource/jx6g-fdh6.json` |
| Census ACS | Demographics, income, insurance, education | `api.census.gov/data/{year}/acs/acs1` |
| PDAPS/Literature | Must-query mandate effective dates | Coded from Buchmueller & Carey (2018), Wen et al. (2019) |
| State adjacency | Border state pairs | Standard 48-state adjacency matrix |

## Power Assessment

- **Units:** 50 states + DC × ~18 years (2006–2023) = ~900 state-years
- **Treated units:** ~35–45 states experience PDMP network exposure ≥50% at some point
- **Pre-treatment periods:** ≥6 years for most states (2006 until neighbors start adopting 2012+)
- **Post-treatment periods:** 5–11 years depending on timing
- **Baseline outcome:** National overdose death rate ~15–30 per 100,000 (varies by year)
- **Expected MDE:** With 50 states and ~20% outcome variation, a 5–10% change in overdose rate (~1.5–3 deaths per 100,000) should be detectable
