# Initial Research Plan: Vacancy Tax Expansion and Housing Markets in France

## Research Question

Does expanding vacancy taxation to tourism and secondary-home communes reduce housing vacancies and affect local housing markets? We exploit the August 2023 expansion of France's Taxe sur les Logements Vacants (TLV) — which added 2,263 communes to the regime — to estimate the causal effect on property transaction prices, volumes, and market composition.

## Policy Background

France's TLV taxes residential properties left vacant for more than one year. Introduced in 1999 for 8 large agglomerations (~811 communes), it was expanded in 2013 to 28 zones tendues (~1,151 communes). Décret n° 2023-822 (August 25, 2023) massively expanded coverage to ~3,697 communes, adding 2,263 predominantly coastal and mountain tourism communes effective January 1, 2024. The tax rates were simultaneously increased: 17% of rental value in year 1 (up from 12.5%), 34% in subsequent years (up from 25%).

The 2023 expansion represents a fundamentally different economic context from prior waves. Original designees were large urban agglomerations where vacancy was driven by speculation or urban decay. The new designees are small tourism communes where housing vacancies are often seasonal second homes — a different mechanism with different policy implications.

## Identification Strategy

**Design:** Difference-in-differences comparing newly designated communes (2023 expansion) to similar never-designated communes, before (2020-2022) and after (2024-2025) the effective date (January 1, 2024).

**Primary specification:**
$$Y_{ct} = \alpha_c + \gamma_t + \beta \cdot \text{TLV}_{c} \times \text{Post}_t + X_{ct}'\delta + \varepsilon_{ct}$$

where:
- $Y_{ct}$: outcome in commune $c$, year $t$ (log median price/m², transaction volume, share of first-time buyers)
- $\alpha_c$: commune fixed effects
- $\gamma_t$: year fixed effects (or département × year)
- $\text{TLV}_c$: indicator for communes added in 2023 expansion
- $\text{Post}_t$: indicator for $t \geq 2024$
- $X_{ct}$: time-varying controls (population, tourism indicators)

**Event-study specification:**
$$Y_{ct} = \alpha_c + \gamma_t + \sum_{k \neq 2023} \beta_k \cdot \text{TLV}_c \times \mathbf{1}[t = k] + X_{ct}'\delta + \varepsilon_{ct}$$

Pre-treatment coefficients ($\beta_{2020}, \beta_{2021}, \beta_{2022}$) test parallel trends.

## Exposure Alignment

- **Who is treated:** Communes newly designated for TLV in the 2023 expansion (2,263 communes). Property owners with vacant units face the tax; the policy operates through the rental/sales supply channel.
- **Primary estimand population:** Residential property transactions in treated communes, reflecting market equilibrium price responses.
- **Placebo/control population:** Residential transactions in similar never-designated communes.
- **Design:** Standard two-period DiD with event-study extension.

## Expected Effects and Mechanisms

**Theory:** The TLV increases the holding cost of vacant properties. Owners respond by:
1. Placing properties on the rental market (reducing vacancy, increasing rental supply)
2. Selling properties (increasing transaction volume, potentially reducing prices)
3. Occupying properties themselves (reducing vacancy without market effects)

**Expected signs:**
- Transaction volume: Positive (more sales as owners offload vacant units)
- Prices: Ambiguous. Increased supply → lower prices. But signal of "zone tendue" status → higher prices (confirmation of housing demand). Net effect is empirical.
- Composition: Shift toward smaller/older properties (the typical vacancy stock)

**Mechanism:** The tourism context adds nuance. In these communes, many "vacant" units are seasonal second homes. The TLV may have limited effect if owners (a) claim usage exemptions, (b) absorb the tax given high property values, or (c) convert to Airbnb/short-term rental rather than long-term rental. A well-identified null result is genuinely informative.

## Power Assessment

- **Pre-treatment periods:** 3 years (2020, 2021, 2022)
- **Treated clusters:** 2,263 communes
- **Post-treatment periods:** 2 years (2024, 2025)
- **Control clusters:** ~30,000+ never-designated communes
- **Transactions per commune-year:** Varies widely. Tourism communes average ~30-100 transactions/year. Aggregate across 2,263 communes × 5 years = ~300,000-500,000+ treated observations.
- **MDE:** Given the large sample, we should detect effects ≥2-3% on prices with 80% power.

## Planned Robustness Checks

1. **Département × year FE:** Absorb all regional shocks; identification from within-département variation.
2. **Matched sample:** CEM or propensity score matching on pre-treatment characteristics (population, housing stock, tourism intensity, vacancy rate, secondary home share).
3. **Triple-difference:** TLV × Post × Tourism intensity (high vs. low secondary home share).
4. **Placebo test:** Apply design to 2013 expansion wave using 2020-2022 data.
5. **Donut-hole around announcement:** Exclude 2023 transactions (August-December) to test for anticipation.
6. **Heterogeneity:** By baseline vacancy rate, secondary home share, commune population, département.
7. **STR regulation control:** Include Airbnb/short-term rental regulation as time-varying covariate.
8. **Randomization inference:** Permute treatment assignment and compute RI p-values.
9. **Callaway & Sant'Anna:** Formally treat 2023 as a single cohort in CS framework.

## Data Sources

1. **DVF (Demandes de Valeurs Foncières):** Bulk CSV from data.gouv.fr, 2020-2025. Transaction-level: date, price, property type, surface area, commune code.
2. **TLV commune lists:** From Décret 2023-822 and predecessor decrees. Commune codes for each wave.
3. **INSEE housing census:** Commune-level housing stock, vacancy rates, secondary home shares from recensement.
4. **INSEE BDM/SDMX:** Population, economic indicators at the département/commune level.
5. **Sirene (if needed):** Hotel/gîte counts as tourism controls.
