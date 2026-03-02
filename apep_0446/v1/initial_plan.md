# Initial Research Plan — apep_0446

## Research Question

Did the integration of traditional agricultural wholesale markets (mandis) into India's electronic National Agriculture Market (e-NAM) reduce price dispersion and improve price discovery for farmers?

## Policy Background

India's agricultural marketing has historically been fragmented by the Agricultural Produce Market Committee (APMC) Act, which required farmers to sell through licensed mandis within their district. This created geographic segmentation, reduced competition, and generated price dispersion across mandis even for identical commodities. The e-NAM platform (launched April 14, 2016) aims to create a unified national market by enabling electronic bidding, transparent price posting, and inter-mandi trade. Integration was phased: 21 mandis at launch → 250 by Nov 2016 → 585 by Mar 2018 → 1,000+ by May 2020, across 23 states.

## Identification Strategy

**Staggered difference-in-differences** exploiting the phased integration of ~1,000 mandis into e-NAM from 2016–2020.

- **Treatment:** A mandi is "treated" when it is integrated into e-NAM. Treatment timing assigned at the state × phase cohort level using government documentation.
- **Control:** ~1,700 mandis in the CEDA AgMarkNet dataset that were never integrated into e-NAM during our sample period.
- **Estimator:** Callaway and Sant'Anna (2021) heterogeneity-robust estimator, which handles staggered treatment timing and avoids the negative weighting problem of TWFE.
- **Fixed effects:** Mandi FE (absorbs time-invariant mandi characteristics), month-year FE (absorbs common time shocks). Additional robustness with state × year FE, commodity × month FE.

## Expected Effects and Mechanisms

1. **Price convergence (primary).** e-NAM enables price comparison across mandis → arbitrage → prices should converge. Expect reduced coefficient of variation (CV) of prices across mandis within state-commodity cells.
2. **Price levels.** More competitive bidding → higher farm-gate prices, especially in thin markets. Expect modest positive effect on modal prices.
3. **Market participation.** Lower transaction costs → more arrivals and traders. Expect increased arrival quantities at integrated mandis.
4. **Heterogeneity:** Effects may be stronger for (a) perishable commodities (onions, tomatoes) where price information is most valuable; (b) remote mandis with previously thin markets; (c) states with stronger APMC reform compatibility.

## Primary Specification

$$Y_{mct} = \alpha_m + \gamma_t + \beta \cdot \text{eNAM}_{mct} + \varepsilon_{mct}$$

where $m$ indexes mandis, $c$ commodities, $t$ month-years. $\text{eNAM}_{mct} = 1$ after mandi $m$ is integrated into e-NAM.

Implemented via Callaway-Sant'Anna with group-time ATTs aggregated to overall ATT and dynamic event-study coefficients.

**Outcome variables:**
1. $\ln(\text{modal price})_{mct}$ — Price level
2. $CV_{sct}$ — Coefficient of variation of prices across mandis within state $s$ × commodity $c$ × month $t$
3. $\ln(\text{arrivals})_{mct}$ — Market participation (arrival quantities)

**Clustering:** Standard errors clustered at the mandi level (primary) and state level (robustness with wild cluster bootstrap for few-cluster inference).

## Commodities

Focus on 6 major commodities with thick markets, high trading volume, and minimal government procurement distortion:

1. **Onion** — Price-volatile, politically sensitive, no MSP
2. **Tomato** — Perishable, no MSP
3. **Potato** — Storable, no MSP
4. **Soybean** — Major oilseed, MSP exists but limited procurement
5. **Chana (Chickpea)** — Major pulse, some NAFED procurement
6. **Wheat** — Robustness only (heavy FCI procurement in Punjab/Haryana/MP)

## Data Sources

- **Primary outcome data:** CEDA Ashoka AgMarkNet dataset (agmarknet.ceda.ashoka.edu.in). Daily mandi-level prices (min/max/modal) and arrival quantities for 453 commodities across 2,700+ mandis, 2006–2025. Accessed via JSON API.
- **Treatment assignment:** e-NAM Directory PDF (July 2021, 1,000 mandis) + PIB press releases for state-phase timing.
- **Controls:** State-level APMC reform status, FCI procurement volumes (from annual reports).

## Planned Robustness Checks

1. **Event-study plots** showing pre-trend dynamics (±24 months)
2. **Sun and Abraham (2021)** interaction-weighted estimator
3. **Synthetic DiD** (Arkhangelsky et al. 2021) for aggregate effects
4. **HonestDiD** sensitivity analysis (Rambachan & Roth 2023)
5. **Placebo tests:** (a) Non-traded commodities; (b) Fictional treatment dates
6. **Within-state design:** Restrict control to same-state non-e-NAM mandis
7. **Procurement-season interactions** for wheat/rice
8. **Varying treatment windows** (±3 months) to test sensitivity to date imprecision
9. **Leave-one-state-out** jackknife for influence diagnostics
10. **Wild cluster bootstrap** for inference robustness with state-level clustering

## Exposure Alignment (DiD-Specific)

- **Who is treated:** Individual mandis integrated into e-NAM. Farmers, traders, and commission agents at these mandis gain access to electronic bidding and price transparency.
- **Primary estimand:** ATT on mandi-level crop prices and arrival quantities.
- **Placebo/control population:** Non-integrated mandis. Also: commodities not traded on e-NAM within integrated mandis.
- **Design:** Staggered DiD (not DDD).

## Power Assessment

- **Pre-treatment periods:** 8+ years (2007–2015 for April 2016 cohort)
- **Treated clusters:** ~1,000 mandis across 23 states
- **Post-treatment periods:** 4+ years for earliest cohort
- **Total mandi × commodity × month observations:** ~2,700 mandis × 6 commodities × 120 months ≈ 1.9M cell-month observations (before missing data)
- **Expected MDE:** With 1,000+ treated mandis and daily data aggregated to monthly, statistical power is extremely high. Even modest effects (1–2% price changes) should be detectable.

## Timeline

1. Fetch CEDA data for 6 commodities across all states/districts (~32 states × 500+ districts × 6 commodities)
2. Parse e-NAM Directory PDF for treated mandi list
3. Merge treatment assignment with price panel
4. Run main DiD specifications
5. Generate event-study plots and robustness checks
6. Write paper
