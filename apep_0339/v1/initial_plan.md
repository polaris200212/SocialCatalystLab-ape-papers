# Initial Research Plan: State Minimum Wage Increases and the Medicaid Home Care Workforce

## Research Question

Do state minimum wage increases affect the supply of Medicaid home and community-based services (HCBS) providers? Specifically, when states raise their minimum wages, do HCBS providers — whose workforce earns near-minimum wages — exit the Medicaid market, reduce service volume, or does provider supply remain stable?

## Identification Strategy

**Design:** Staggered difference-in-differences using the Callaway & Sant'Anna (2021) estimator.

**Treatment:** State-level minimum wage increase events, 2018–2024. Over 30 states raised their minimum wages during this period on staggered timelines. Treatment cohorts defined by the year-month of first MW increase during the sample period.

**Control group:** (1) Never-treated states: ~20 states at the federal minimum ($7.25) throughout 2018–2024. (2) Not-yet-treated states as additional controls within the CS framework.

**Key robustness:** Border-county pair design (Dube, Lester, Reich 2010) using NPPES geography to construct contiguous county pairs straddling state borders with differential MW treatment.

## Expected Effects and Mechanisms

**Two competing channels:**

1. **Cost-push channel (-):** MW increases raise HCBS labor costs. If Medicaid reimbursement rates do not adjust, provider margins are squeezed → provider exit, reduced hours, fewer beneficiaries served.

2. **Retention channel (+):** MW increases raise HCBS worker pay directly → improved retention, lower turnover → providers can maintain or expand capacity.

**Ex ante prediction:** Ambiguous. The net effect depends on (a) pass-through of MW to Medicaid rates, (b) initial wage distribution of HCBS workers relative to the new MW, and (c) labor supply elasticities. A null result would itself be important — it would suggest the HCBS market absorbs MW increases without supply disruption.

## Exposure Alignment (DiD-Specific)

**Who is actually treated?** HCBS providers whose workforce earns near or below the new minimum wage. Personal care aides (T1019), home health aides (S5125), and direct support professionals (T2016 habilitation) earn median wages of $14–15/hr nationally, with significant variation below that in low-cost states.

**Primary estimand population:** Individual and organizational NPIs billing T, H, or S HCPCS codes (Medicaid-specific HCBS services). These are 100% Medicaid-dependent.

**Placebo/control population:** NPIs billing CPT codes (physician services) — higher-wage providers unaffected by MW changes at the relevant margin.

**Design:** Standard two-group DiD (HCBS providers in treated vs. control states) with triple-diff extension (HCBS vs. non-HCBS providers within the same state, differencing out state-level trends).

## Power Assessment

- **Pre-treatment periods:** 24–72 months depending on cohort (restrict to ≥24 months pre)
- **Treated clusters:** 30+ states with MW increases
- **Post-treatment periods:** 12–72 months depending on cohort
- **Unit of analysis:** State × month (primary), county × month (border design)
- **Cluster count:** 50 states + DC — well above conventional thresholds
- **MDE:** With 30+ treated states, monthly data over 84 months, and ~600K providers, power should be sufficient to detect economically meaningful effects (5–10% changes in provider counts/billing).

## Primary Specification

```
Y_{s,t} = ATT(g,t) via Callaway-Sant'Anna

where:
  Y = {provider_count, entry_rate, exit_rate, billing_volume, beneficiaries_per_provider}
  g = cohort (year-month of first MW increase)
  s = state
  t = year-month
  Controls: state FE, month FE, state-specific linear trends (robustness)
  Clustering: state level
```

**Continuous treatment intensity:** Dollar amount of MW increase (or % increase) as treatment intensity in a dose-response specification.

## Planned Robustness Checks

1. **Event-study plots** with 24+ months pre/post, joint pre-trend F-test
2. **HonestDiD** (Rambachan & Roth 2023) sensitivity to parallel trends violations
3. **Border-county pairs** (Dube, Lester, Reich 2010) — within-pair DiD absorbing local conditions
4. **Region × month FE** — restrict comparisons to within-Census-division
5. **Falsification outcomes:** Non-HCBS providers (CPT), high-wage specialties, drug/DME codes
6. **Triple-diff:** HCBS vs. non-HCBS providers within treated states
7. **Dose-response:** Continuous MW level rather than binary treatment
8. **Bacon decomposition** (Goodman-Bacon 2021) — diagnose 2×2 comparisons underlying TWFE
9. **Leave-one-out:** Drop each treated state and re-estimate
10. **Placebo dates:** Assign fake treatment to never-treated states

## Data Sources

| Source | Purpose | Access |
|--------|---------|--------|
| T-MSIS Medicaid Provider Spending | HCBS billing outcomes | Local Parquet (2.74 GB) |
| NPPES | Provider geography, specialty, entity type | Bulk CSV download |
| FRED | State minimum wage levels | API (STTMINWG series) |
| Vaghul-Zipperer MW Dataset | Monthly MW panel through 2022 | GitHub download |
| BLS QCEW | Healthcare employment validation | Direct CSV |
| Census ACS | State demographics, poverty rates | API (CENSUS_API_KEY) |
| Census ZCTA-County Crosswalk | ZIP-to-county mapping | Direct download |
| Census TIGER/Line | Border county identification | Direct download |

## Paper Structure

1. Introduction — Hook: HCBS crisis, invisible workforce, MW debate
2. Background — HCBS workforce, minimum wage literature, Medicaid reimbursement
3. Data — T-MSIS, NPPES linkage, MW panel construction
4. Empirical Strategy — CS DiD, border design, identification threats
5. Results — Main effects, event studies, heterogeneity
6. Robustness — Border pairs, triple-diff, falsification, HonestDiD
7. Mechanisms — Rate adjustment, worker composition, entry vs. exit
8. Conclusion — Policy implications for MW-Medicaid interaction
