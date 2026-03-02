# Initial Research Plan: The Waterbed Effect — Crime Displacement from Selective Licensing of England's Private Rented Sector

## Research Question

Does selective licensing of private rented housing reduce crime, or does it merely displace it to adjacent unlicensed areas? What is the net welfare effect when spatial displacement is accounted for?

## Identification Strategy

**Staggered Difference-in-Differences** exploiting the voluntary, time-varying adoption of selective licensing across English Local Authorities.

### Treatment Definition

- **Unit of analysis:** LSOA × month (Lower Layer Super Output Area, ~33,000 in England)
- **Treatment:** An LSOA is "treated" when its Local Authority activates a selective licensing scheme
- **Primary approach:** LA-level intent-to-treat (any scheme adopted → all LSOAs in the LA are treated)
- **Secondary approach:** For borough/city-wide schemes (Newham, Liverpool, Nottingham, Waltham Forest, Brent, Tower Hamlets, Lambeth), run at LSOA level with full treatment intensity

### Treatment Timing (Confirmed Staggered Dates)

| Cohort | Local Authority | Adoption Date | Coverage |
|--------|----------------|---------------|----------|
| 2013 | Newham | Jan 2013 | Borough-wide |
| 2015 | Liverpool | Apr 2015 | City-wide |
| 2015 | Rotherham | 2015 | Sub-area |
| 2015 | Doncaster | 2015 | Sub-area |
| 2015 | Hartlepool | 2015 | Partial |
| 2018 | Harrow | Mar 2018 | 2 wards |
| 2018 | Nottingham | Aug 2018 | City-wide |
| 2020 | Waltham Forest | May 2020 | Borough-wide |
| 2021 | Middlesbrough | Jun 2021 | Ward |
| 2021 | Enfield | Sep 2021 | 14 wards |
| 2022 | Salford | Sep 2022 | Sub-area |
| 2022 | Burnley | Jul 2022 | Multiple areas |
| 2022 | Bradford | 2022 | Sub-area |
| 2023 | Birmingham | Jun 2023 | 25 of 69 wards |
| 2023 | Sefton | Mar 2023 | Sub-area |
| 2023 | Middlesbrough | Jul 2023 | Ward (expanded) |
| 2024 | Brent | Apr 2024 | Borough-wide |
| 2024 | Tower Hamlets | Apr 2024 | Borough-wide |
| 2024 | Lambeth | Sep 2024 | Borough-wide |
| ... | 10+ additional LAs | Various | Various |

**Total treated LAs: ≥25** (with verifiable adoption dates post-2010, ensuring ≥3 pre-treatment years in Police API data which begins December 2010).

### Estimator

- **Primary:** Callaway & Sant'Anna (2021) — group-time ATTs with not-yet-treated and never-treated controls
- **Robustness:** Sun & Abraham (2021), de Chaisemartin & D'Haultfœuille (2020), TWFE (for comparison, noting bias)
- **Inference:** Cluster at the LA level (treatment unit); wild cluster bootstrap for robustness

### Control Group

- **Never-treated LAs:** English LAs that have never adopted selective licensing
- **Not-yet-treated LAs:** LAs that adopt later (used in Callaway–Sant'Anna framework)
- **Matching/weighting:** Pre-treatment matching on deprivation index (IMD), PRS share (Census), population density, baseline crime rate

## Expected Effects and Mechanisms

### Mechanism Chain

1. **Licensing → Landlord Accountability:** Landlords must pass "fit and proper person" test, maintain property standards, manage tenancies actively
2. **Accountability → Tenant Screening:** Landlords screen tenants more carefully to protect their license
3. **Screening → Local Crime Reduction:** Properties with better-managed tenancies → less antisocial behavior, drug activity, violent crime
4. **Local Reduction → Spatial Displacement:** Problem tenants/landlords relocate to adjacent unlicensed areas → crime rises in neighbors
5. **Net Welfare = Local Reduction − Displacement:** If displacement is substantial, net effect approaches zero

### Expected Effect Sizes

- **Local crime reduction:** 5–15% reduction in antisocial behavior and property crime in licensed LAs (based on Jarden et al. 2022 finding of reduced ASB)
- **Displacement:** Unknown — this is the key empirical question. Possibly 30–80% of local reduction displaced to adjacent areas
- **Property prices:** 1–3% increase in licensed areas if crime genuinely falls (based on crime-property capitalization literature)

## Primary Specification

### Main Regression (LA-level DiD)

```
Y_{it} = α_i + γ_t + β × Licensed_{it} + X_{it}'δ + ε_{it}
```

Where:
- Y_{it}: crime rate (crimes per 1,000 population) in LSOA i, month t
- α_i: LSOA fixed effects
- γ_t: month-year fixed effects
- Licensed_{it}: indicator for LSOA in a LA with active selective licensing
- X_{it}: time-varying controls (population estimates, deprivation rank)
- Clustering at LA level

### Displacement Specification

```
Y_{it} = α_i + γ_t + β₁ × Licensed_{it} + β₂ × Adjacent_{it} + X_{it}'δ + ε_{it}
```

Where:
- Adjacent_{it}: indicator for LSOA in an unlicensed LA that shares a boundary with a licensed LA
- β₁: direct effect (expected negative)
- β₂: displacement effect (expected positive if waterbed hypothesis holds)
- Net welfare ∝ β₁ + β₂ (if ≈0, displacement is ~complete)

### Distance Gradient

```
Y_{it} = α_i + γ_t + Σ_d β_d × Ring_{dit} + X_{it}'δ + ε_{it}
```

Where Ring_{dit} indicates LSOA i is in distance ring d (0–5km, 5–10km, 10–15km, 15–20km, >20km) from the nearest licensing boundary. Estimates the spatial decay of displacement.

## Planned Robustness Checks

1. **Pre-trends test:** Joint F-test on event-study pre-period coefficients; HonestDiD bounds
2. **Placebo crime categories:** Fraud, drug trafficking, other categories unlikely affected by landlord regulation
3. **Placebo timing:** Fake treatment dates (1, 2, 3 years before actual adoption)
4. **Borough-wide only:** Restrict to LAs with borough/city-wide schemes (cleaner treatment)
5. **Crime category decomposition:** ASB, violent crime, burglary, criminal damage separately
6. **Donut analysis:** Drop LSOAs within 1km of licensing boundaries (boundary effects)
7. **Randomization inference:** Permute treatment across LAs (wild cluster bootstrap)
8. **Multiple estimators:** CS-DiD, SA-DiD, dCDH, TWFE comparison

## Exposure Alignment (DiD Checklist)

- **Who is actually treated?** Private landlords in designated areas — required to obtain licenses, maintain standards, screen tenants
- **Primary estimand population:** Residents of licensed LSOAs (entire LSOA populations exposed to licensing effects)
- **Placebo population:** Residents of never-licensed LAs with similar baseline characteristics
- **Design:** Staggered DiD with 25+ treated LAs and hundreds of control LAs

## Power Assessment

- **Pre-treatment periods:** ≥3 years (Police API data from Dec 2010; focusing on 2013+ adopters)
- **Treated clusters:** ≥25 LAs
- **Post-treatment periods per cohort:** Varies (Newham 2013 has 11+ years post; 2024 adopters have <1 year)
- **LSOA-month observations:** ~5.5M (33,000 LSOAs × 14 years × 12 months)
- **MDE:** With 25+ LA clusters and large LSOA-month panel, likely well-powered to detect 5%+ changes in crime rates

## Data Sources

| Source | Variables | Granularity | Period |
|--------|-----------|-------------|--------|
| UK Police API | Crime counts by category | LSOA × month | Dec 2010–present |
| Land Registry PPD | Transaction prices | Postcode | 1995–present |
| NOMIS | Population, employment, benefits | LA × year/quarter | Various |
| ONS/NSPL | Postcode→LSOA→LA lookup | Postcode | Current |
| postcodes.io | Geocoding | Postcode | Current |
| Council websites / NRLA | Licensing adoption dates | LA | Compiled |

## Paper Structure (Planned)

1. Introduction (3 pages) — waterbed hypothesis, stakes, contribution
2. Institutional Background (3 pages) — Housing Act 2004, selective licensing mechanics, adoption patterns
3. Data (4 pages) — Police API, Land Registry, licensing dates, descriptive statistics
4. Empirical Strategy (4 pages) — staggered DiD, displacement design, identification threats
5. Results (5 pages) — main effects, event study, crime category decomposition
6. Displacement Analysis (4 pages) — spatial spillovers, distance gradient, net welfare
7. Property Price Capitalization (3 pages) — Land Registry DiD, hedonic model
8. Robustness (3 pages) — placebos, alternative estimators, HonestDiD
9. Welfare Implications (2 pages) — net effect, policy counterfactual
10. Conclusion (1 page)

Total: ~32 pages main text
