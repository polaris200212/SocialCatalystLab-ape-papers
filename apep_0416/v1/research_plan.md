# Research Plan: When the Safety Net Frays — Medicaid Unwinding and Behavioral Health Provider Market Dynamics

## Research Question

Did the 2023 Medicaid unwinding — the largest mass disenrollment in Medicaid history — differentially destabilize behavioral health provider markets compared to home and community-based services (HCBS) markets? Specifically, do behavioral health providers (H-code billers) experience larger declines in billing volume, higher exit rates, and greater market concentration than HCBS providers (T-code billers), who were shown to be resilient in prior work (APEP-0307)?

## Motivation

The Medicaid continuous enrollment provision, implemented during COVID-19, prevented states from disenrolling beneficiaries. When it expired on April 1, 2023, states began redetermination processes that ultimately removed over 25 million people from Medicaid rolls. This created a massive, staggered demand shock to Medicaid-dependent providers.

Prior work (APEP-0307) found that HCBS providers were "far more resilient than anticipated." But this null result may not generalize to behavioral health. HCBS providers serve long-term enrollees (elderly, disabled) who are largely exempt from redetermination. Behavioral health providers serve episodic patients — people with mental health and substance use conditions who cycle in and out of coverage and are disproportionately subject to procedural disenrollments. Community mental health centers derive 80–90% of revenue from Medicaid, making them uniquely vulnerable.

## Identification Strategy

### Primary Design: Difference-in-Differences-in-Differences (DDD)

**First difference (time):** Pre-unwinding (Jan 2018 – Mar 2023) vs. post-unwinding (Apr 2023 – Dec 2024).

**Second difference (across states):** States varied in unwinding start dates (April–July 2023) and intensity (disenrollment rates: 12–57%).

**Third difference (within state, across service types):** Behavioral health providers (H-code billers) vs. HCBS providers (T-code billers). The within-state comparison controls for state-level confounders (economic conditions, political climate, Medicaid generosity) that affect all providers equally.

### Why DDD is credible here:

1. **HCBS providers are a valid within-state control group.** They serve Medicaid populations but were demonstrated to be unaffected by the unwinding (APEP-0307). Their services target long-term enrollees less subject to redetermination.
2. **Staggered state adoption** provides cross-state variation in timing — not all states started at once.
3. **Treatment intensity** varies continuously across states (disenrollment rate), allowing dose-response analysis.
4. **No anticipation:** The unwinding end date was uncertain until the Consolidated Appropriations Act of 2023 (Dec 2022), giving at most 3 months of potential anticipation.

### Exposure Alignment

- **Who is treated:** Behavioral health providers (H-code billers) in states that begin unwinding.
- **Primary estimand population:** Active behavioral health NPIs billing H-codes.
- **Placebo/control population:** HCBS providers (T-code billers) in the same states.
- **Design:** Triple-difference (DDD).

### Power Assessment

- **Pre-treatment periods:** 63 months (Jan 2018 – Mar 2023). Far exceeds 5-year minimum.
- **Post-treatment periods:** 9–20 months depending on cohort (Apr 2023 – Dec 2024).
- **Treated clusters:** 51 states/territories. All states unwound; variation is in timing and intensity.
- **Treated × control comparison:** ~50K behavioral health NPIs vs. ~106K HCBS NPIs.
- **MDE:** With 51 clusters and 84 time periods, we expect good power for moderate effects.

## Expected Effects and Mechanisms

**Hypothesis 1 (Differential vulnerability):** Behavioral health providers experience larger billing volume declines than HCBS providers following unwinding, because behavioral health patients are more likely to be procedurally disenrolled.

**Hypothesis 2 (Market concentration):** Provider exit following the unwinding increases market concentration (HHI) in behavioral health, potentially reducing access for remaining enrollees.

**Hypothesis 3 (Dose-response):** Effects are larger in states with higher disenrollment rates and higher shares of procedural (vs. eligibility-based) terminations.

**Mechanism:** Procedural disenrollments disproportionately affect people who struggle with paperwork — a population that overlaps heavily with mental health and substance use disorder patients. When these patients lose coverage, behavioral health providers lose revenue. Community mental health centers, which cannot substitute to Medicare (H-codes have no Medicare equivalent), face acute financial stress.

## Primary Specification

$$Y_{s,c,t} = \beta_1 \text{Post}_t \times \text{BH}_c + \beta_2 \text{Post}_t \times \text{BH}_c \times \text{Intensity}_s + \gamma_{s,t} + \delta_{c,t} + \alpha_{s,c} + \varepsilon_{s,c,t}$$

Where:
- $Y_{s,c,t}$: Log billing volume (claims or paid amount) for state $s$, service category $c$ (BH vs. HCBS), month $t$
- $\text{BH}_c$: Indicator for behavioral health (H-code) vs. HCBS (T-code)
- $\text{Post}_t$: Indicator for post-unwinding period (state-specific timing)
- $\text{Intensity}_s$: State-level disenrollment rate (continuous treatment dosage)
- Fixed effects: State×month ($\gamma_{s,t}$), category×month ($\delta_{c,t}$), state×category ($\alpha_{s,c}$)

$\beta_1$ captures the average differential effect on behavioral health vs. HCBS.
$\beta_2$ captures the dose-response: whether higher-intensity unwinding states show larger differential effects.

## Planned Robustness Checks

1. **Callaway-Sant'Anna estimator** with staggered adoption timing for the state-level DiD (within behavioral health only).
2. **Event study** showing dynamic treatment effects and pre-trend validation.
3. **Placebo test on CPT-code providers** (standard medical codes) — should show smaller effects since these providers can substitute to Medicare.
4. **Alternative outcomes:** Provider count, exit rate, new entry rate, HHI, per-provider caseload.
5. **Bacon decomposition** of the TWFE estimate.
6. **Honest DiD** sensitivity analysis for parallel trends violations.
7. **Heterogeneity by provider type:** Individual vs. organizational behavioral health NPIs.
8. **Heterogeneity by procedural disenrollment share:** States with >50% procedural terminations vs. those with <50%.

## Data Sources

1. **T-MSIS Medicaid Provider Spending** (local Parquet, 227M rows, Jan 2018–Dec 2024). Core outcome data.
2. **NPPES** (CMS bulk extract). State assignment via practice ZIP.
3. **KFF Medicaid Unwinding Tracker.** State-level disenrollment rates, procedural vs. eligibility shares, start dates.
4. **Census ACS** (via API). State-level population denominators, poverty rates for controls.
5. **FRED** (via API). State unemployment rates as time-varying controls.
6. **CDC PLACES** (Socrata). County-level mental health prevalence for heterogeneity analysis.

## Code Pipeline

- `00_packages.R` — Load libraries
- `01_fetch_data.R` — Open T-MSIS Parquet, load/build NPPES extract, fetch Census/FRED/KFF data
- `02_clean_data.R` — Construct state × service-category × month panel, merge unwinding dates
- `03_main_analysis.R` — DDD estimation, TWFE, event study, Callaway-Sant'Anna
- `04_robustness.R` — Placebo tests, Bacon decomposition, Honest DiD, heterogeneity
- `05_figures.R` — Event study plots, trend plots, maps, distributional figures
- `06_tables.R` — Summary statistics, regression tables, robustness tables
