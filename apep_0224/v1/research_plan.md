# Initial Research Plan: School Suicide Prevention Training Mandates and Suicide Rates

## Research Question

Do state mandates requiring school personnel to receive suicide prevention gatekeeper training reduce suicide mortality? Through what mechanism — direct gatekeeping or broader social norm change?

## Identification Strategy

**Staggered difference-in-differences** exploiting variation in the timing of mandatory suicide prevention training laws across US states, 2006-2017.

- **Treatment:** State adoption of mandatory school personnel suicide prevention training (Jason Flatt Act or equivalent mandatory training laws)
- **Treatment coding:** First full calendar year after law's effective date (e.g., law effective July 2012 → treated from 2013)
- **Control group:** Not-yet-treated and never-treated states
- **Estimator:** Callaway & Sant'Anna (2021) heterogeneity-robust estimator, with Sun & Abraham (2021) as robustness check
- **Inference:** Clustered at state level (treatment unit); wild cluster bootstrap for small-cluster robustness

## Expected Effects and Mechanisms

**Primary hypothesis:** Mandates reduce suicide rates through two channels:
1. **Gatekeeping channel:** Trained school personnel identify at-risk youth and refer them to services
2. **Social norms channel:** Mandatory training creates institutional culture where mental health help-seeking is normalized, reducing stigma

**Expected direction:** Negative (reduction in suicide rates)

**Expected magnitude:** Small. Youth (10-24) account for ~15% of suicides. A 10% reduction in youth suicide would translate to ~1.5% reduction in all-age suicide. We expect estimated effects of 1-3% on total suicide, implying 7-20% reductions in youth suicide.

**Null result interpretation:** If effects are precisely estimated zero, this is an important finding — it would suggest that "soft" social norms interventions (training, awareness) are insufficient to reduce "hard" outcomes (mortality), challenging the policy rationale for 30+ state mandates.

## Exposure Alignment (DiD-specific)

- **Who is actually treated?** School-age youth (K-12) exposed to environments where personnel have received suicide prevention training. Indirect treatment of parents, community members through norm diffusion.
- **Primary estimand population:** All state residents (using all-age suicide as outcome). Conservative test.
- **Placebo/control population:** Cancer mortality, heart disease mortality (should be unaffected by school training mandates)
- **Design:** Standard staggered DiD (not triple-diff, since age-specific data is unavailable programmatically)

## Power Assessment

- **Pre-treatment periods:** 7-18 years (1999 to year before adoption)
- **Treated clusters:** 25+ states by 2017
- **Post-treatment periods per cohort:** 1-11 years (varies by adoption timing)
- **Sample:** ~51 units × 19 years = ~969 state-year observations
- **MDE:** With σ ≈ 3 per 100K, clustered SE ≈ 0.4, and N=969, MDE ≈ 0.8 per 100K (about 6% of mean). Adequate for detecting meaningful effects.

## Primary Specification

```
Y_{st} = α_s + γ_t + β * Treat_{st} + X_{st}δ + ε_{st}
```

Where:
- Y_{st} = age-adjusted suicide death rate per 100K in state s, year t
- α_s = state fixed effects
- γ_t = year fixed effects
- Treat_{st} = 1 if state s has mandatory training in year t
- X_{st} = time-varying controls (unemployment rate, per capita income, Medicaid expansion, other policies)

Preferred: Callaway-Sant'Anna group-time ATT with not-yet-treated controls.

## Planned Robustness Checks

1. **Pre-trends:** C-S event study with 5+ pre-treatment leads
2. **HonestDiD:** Rambachan & Roth (2023) sensitivity analysis
3. **Placebo outcomes:** Cancer mortality, heart disease mortality (from same dataset)
4. **Alternative treatment coding:** (a) effective year rather than first full year, (b) continuous exposure fraction
5. **Heterogeneity:** By youth population share, by baseline suicide rate, by mandate type (Jason Flatt Act vs. other mandatory)
6. **Leave-one-out:** Drop each treatment cohort and re-estimate
7. **Alternative estimator:** Sun & Abraham (2021) interaction-weighted estimator
8. **Wild cluster bootstrap:** Robust inference with 50 clusters
9. **Bacon decomposition:** Goodman-Bacon (2021) diagnostic of TWFE bias

## Data Sources

| Data | Source | Access |
|------|--------|--------|
| Suicide deaths by state-year | CDC NCHS Leading Causes of Death (Socrata bi63-dtpu) | API |
| Treatment dates | Lang et al. 2024 + Jason Foundation records | Manual compilation |
| State population | Census API | API |
| Unemployment rate | BLS LAUS | API/manual |
| Medicaid expansion | KFF records | Manual compilation |
| Youth population share | Census API (age distribution) | API |
