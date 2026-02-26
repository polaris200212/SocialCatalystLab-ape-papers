# Initial Research Plan — apep_0461

## Research Question

Does resource dependence cause worse child health outcomes? Specifically, does the exogenous reduction in oil revenue caused by the 2014 global oil price crash lead to higher child mortality in oil-dependent countries, and does this effect operate through reduced government health expenditure?

## Motivation

Nigeria — Africa's largest oil exporter — derives approximately 60% of government revenue from petroleum. When Brent crude prices collapsed from $110/bbl in June 2014 to $30/bbl in January 2016, Nigeria and other oil-dependent nations faced massive fiscal contractions. Understanding whether these fiscal shocks translate into worse human development outcomes is critical for policy: it determines the welfare cost of resource dependence and the urgency of revenue diversification.

The "resource curse" hypothesis (Sachs & Warner 1995, 2001) is one of the most debated propositions in development economics. Yet the literature suffers from a fundamental identification problem: cross-sectional comparisons between resource-rich and resource-poor countries are confounded by selection, geography, institutions, and history. We contribute the first cross-country DiD estimate exploiting the 2014 oil crash as a large, plausibly exogenous shock to resource-dependent fiscal systems.

## Identification Strategy

**Design:** Continuous difference-in-differences with Bartik-style treatment intensity.

**Treatment variable:**
$$Treatment_{it} = OilRents_i^{pre} \times Post2014_t$$

Where:
- $OilRents_i^{pre}$ = Average oil rents as % of GDP, 2010-2013 (pre-crash mean, WB indicator NY.GDP.PETR.RT.ZS)
- $Post2014_t$ = indicator for year ≥ 2014

**Main specification:**
$$Y_{it} = \alpha_i + \gamma_t + \beta \cdot OilRents_i^{pre} \times Post2014_t + X_{it}'\delta + \varepsilon_{it}$$

Where:
- $Y_{it}$ = under-5 mortality rate (per 1,000 live births) in country $i$, year $t$
- $\alpha_i$ = country fixed effects
- $\gamma_t$ = year fixed effects
- $X_{it}$ = time-varying controls (log GDP per capita, population growth, urbanization rate, conflict indicator)
- Clustered standard errors at the country level

**Identifying assumption:** Conditional on country and year fixed effects, pre-2014 oil dependence is orthogonal to differential trends in child mortality. Oil endowments are determined by geology, not by health policy choices.

**Pre-trends test:** With 9 pre-treatment years (2005-2013), we estimate event-study coefficients:
$$Y_{it} = \alpha_i + \gamma_t + \sum_{k=-9}^{10} \beta_k \cdot OilRents_i^{pre} \times \mathbf{1}(t = 2013+k) + X_{it}'\delta + \varepsilon_{it}$$

Null pre-trends (β_k ≈ 0 for k < 0) support the identifying assumption.

## Expected Effects and Mechanisms

**Primary hypothesis:** Higher pre-crash oil dependence → larger increase in under-5 mortality post-2014.

**Expected magnitude:** Countries in the top quartile of oil dependence (~30% oil rents/GDP) experienced ~40% revenue declines. If this translates to proportional health spending cuts and health spending has non-zero returns, we expect a detectable divergence.

**Mechanism chain:**
1. Oil price crash → reduced oil rents → lower government revenue
2. Lower revenue → cuts to government health expenditure
3. Reduced health spending → fewer vaccinations, fewer health workers, worse maternal care
4. → Higher child mortality

**Testable implications:**
- Government health expenditure (% GDP) should decline more in oil-dependent countries post-2014
- Vaccination rates (DPT immunization) should decline
- Effects should be larger in countries with lower fiscal buffers (no sovereign wealth fund)

## Primary Data Sources

| Variable | Source | Indicator | Coverage |
|----------|--------|-----------|----------|
| Under-5 mortality | World Bank WDI | SH.DYN.MORT | 226 countries, 2000-2024 |
| Oil rents (% GDP) | World Bank WDI | NY.GDP.PETR.RT.ZS | ~170 countries |
| Health expenditure | World Bank WDI | SH.XPD.CHEX.GD.ZS | ~190 countries |
| Military expenditure | World Bank WDI | MS.MIL.XPND.GD.ZS | ~170 countries |
| DPT immunization | World Bank WDI | SH.IMM.IDPT | ~195 countries |
| GDP per capita | World Bank WDI | NY.GDP.PCAP.CD | ~200 countries |
| Population | World Bank WDI | SP.POP.TOTL | ~200 countries |
| Urbanization | World Bank WDI | SP.URB.TOTL.IN.ZS | ~200 countries |
| Oil prices | FRED | DCOILBRENTEU | Monthly, 2010-2024 |
| School enrollment | World Bank WDI | SE.PRM.ENRR | ~180 countries |

**Supplementary (Nigeria case study):**
| Variable | Source | Coverage |
|----------|--------|----------|
| State-level health | DHS API | 37 states, 2013/2018/2024 |
| State-level demographics | DHS API | 37 states, 2013/2018/2024 |

## Exposure Alignment (DiD Requirements)

- **Who is treated?** All countries, with continuous treatment intensity based on pre-2014 oil rents (% GDP)
- **Primary estimand population:** ~150 developing countries (excluding OECD high-income)
- **High-treatment group:** ~25-30 countries with oil rents >5% GDP (Kuwait, Saudi Arabia, Libya, Iraq, Angola, Nigeria, Gabon, etc.)
- **Control group:** ~120 countries with negligible oil rents (<1% GDP)
- **Placebo/falsification:** (1) Outcomes that shouldn't be affected by fiscal cuts (e.g., adult literacy, which changes slowly); (2) Mineral-rich but non-oil countries; (3) Pre-period placebo treatments

## Power Assessment

- **Pre-treatment periods:** 9 (2005-2013)
- **Post-treatment periods:** 11 (2014-2024)
- **Treated clusters:** ~25-30 countries with oil rents >5% GDP
- **Total units:** ~150 developing countries
- **Panel observations:** ~150 × 20 = ~3,000
- **MDE estimation:** With 150 countries, 20 years, and ~25 treated at 5% significance, the minimum detectable effect is approximately 2-3 deaths per 1,000 live births (well within plausible range given mean under-5 mortality of ~50/1,000 in developing countries)

## Planned Robustness Checks

1. **Event study:** Dynamic treatment effects to verify parallel pre-trends
2. **Alternative treatment definitions:** Binary (top quartile vs rest), terciles, continuous
3. **Callaway-Sant'Anna estimator:** Heterogeneity-robust DiD (though treatment is continuous, not binary staggered)
4. **Dropping major oil exporters:** Sensitivity to removing top 5 oil producers
5. **Including OECD countries:** Check if results hold when including Norway, Canada, etc.
6. **Alternative outcomes:** Maternal mortality, infant mortality, neonatal mortality, vaccination rates
7. **Mechanism test:** Government health expenditure as mediator
8. **Placebo outcomes:** Adult literacy, access to electricity (slow-moving, shouldn't respond to short-run fiscal shocks)
9. **Sovereign wealth fund interaction:** Countries with fiscal buffers may be protected
10. **Bacon decomposition:** If using binary treatment, verify no negative weights
