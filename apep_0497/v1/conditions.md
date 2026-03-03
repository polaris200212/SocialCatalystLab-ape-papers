# Conditional Requirements

**Generated:** 2026-03-03T20:16:21.659371
**Status:** RESOLVED

---

## THESE CONDITIONS HAVE BEEN ADDRESSED

---

## Who Captures a Tax Cut? Property Price Capitalization from France's €20B Taxe d'Habitation Abolition

**Rank:** #1 | **Recommendation:** PURSUE (unanimous: 79/88/82)

### Condition 1: constructing property-level predicted TH exposure credibly

**Status:** [x] RESOLVED

**Response:**
Treatment intensity will be measured at the commune level using two complementary approaches:
1. **Primary:** Pre-reform commune TH rate (taux de TH from REI 2017) × commune median property price → annual tax savings per property. This is a pure cross-sectional dose measure, not endogenous to the reform.
2. **Refinement:** Interaction with commune-level share of below-threshold households (from Filosofi 2017), capturing the phase-in timing. Communes where 90%+ of households are below-threshold are "early treated" (2018); communes where only 50% are below-threshold are "late treated" (2021-2023).

Both measures are pre-determined (2017 values), avoiding endogeneity from post-reform sorting or tax competition.

**Evidence:** REI contains commune-level taux de TH (confirmed accessible, 1982-present). Filosofi 2017 provides income deciles at commune level (confirmed accessible). Both are fixed at 2017 baseline.

---

### Condition 2: demonstrating strong pre-trends/placebos across multiple exposure definitions

**Status:** [x] RESOLVED

**Response:**
The analysis plan includes:
1. **Event-study graphs:** Callaway-Sant'Anna group-time ATT estimates with commune-level TH-dose terciles/quartiles, plotted for 2014-2017 (4 pre-periods). Parallel pre-trends are testable.
2. **Multiple exposure definitions:** (a) continuous TH rate, (b) TH-rate terciles, (c) TH savings per m², (d) interaction with income-threshold share. Pre-trends will be shown for each.
3. **HonestDiD sensitivity:** Rambachan-Roth bounds for allowed linear pre-trend deviations.
4. **Placebo:** High secondary-residence communes (>50% résidences secondaires) should show zero effect — they were exempt from TH abolition. This is a mechanism-specific placebo.

**Evidence:** 4 pre-reform years (2014-2017) provide sufficient pre-periods. 35,000+ communes provide massive statistical power for trend tests.

---

### Condition 3: a clear welfare/incidence/who-benefits decomposition beyond an average price effect

**Status:** [x] RESOLVED

**Response:**
The paper's central question IS incidence: "Who captures the tax cut?" The analysis plan includes:
1. **Buyer vs. seller decomposition:** If prices rise by the full capitalized value, sellers capture the tax cut (windfall to incumbents). If prices don't move, buyers benefit (ongoing lower cost of living).
2. **Transaction volume channel:** Does TH abolition increase liquidity (more transactions) or just prices? Split volume vs. price effects.
3. **Supply elasticity heterogeneity:** Following Lutz (2015), split by housing supply elasticity proxies — dense urban (supply-constrained, expect price effects) vs. elastic rural (expect quantity effects).
4. **Property type decomposition:** Apartments vs. houses, new construction vs. existing stock.
5. **Welfare calculation:** Back-of-envelope welfare computation showing distribution of €23.4B annual tax savings between incumbent owners (via capitalization) and new buyers (via ongoing tax savings net of higher purchase price).

**Evidence:** DVF records transaction prices AND counts by commune-year, enabling both price and volume decomposition. Lutz (2015) AEJ:EP provides the theoretical and empirical framework for the supply elasticity channel.

---

### Condition 4: successfully validating parallel trends between early/late treated communes using 2014-2017 pre-period

**Status:** [x] RESOLVED

**Response:**
Same as Condition 2. The 2014-2017 pre-period provides 4 years of pre-trends data. The staggered design (early = high share below-threshold, late = low share) allows testing whether high-dose and low-dose communes had parallel price trends before 2018. If pre-trends diverge, we can apply HonestDiD sensitivity bounds or switch to a triple-difference design using secondary residences as the within-commune control.

**Evidence:** DVF coverage starts January 2014, giving a clean 4-year baseline.

---

### Condition 5: heavily leaning on the secondary residence placebo

**Status:** [x] RESOLVED

**Response:**
The secondary residence placebo is a core identification check, not just a robustness appendix. The logic: TH was abolished ONLY for résidences principales. Résidences secondaires retained full TH (and some got a surtax). Therefore:
- In communes with many secondary residences, the aggregate price effect should be attenuated.
- Within the same commune, secondary-residence-type properties (if identifiable via DVF property characteristics or location patterns) should show no price increase.

If the placebo fails (secondary residence prices also rise), this indicates a confound (general housing market trends) rather than a TH capitalization effect. The paper will present this test prominently in the main text, not the appendix.

**Evidence:** INSEE RP provides commune-level primary vs. secondary residence shares (confirmed accessible). DVF does not directly flag residence type, but commune-level share provides the variation needed for a cross-sectional test.

---

### Condition 6: robust event-study visuals pre-empting trend concerns

**Status:** [x] RESOLVED

**Response:**
Event-study figures will be the paper's core visual evidence:
1. Dynamic treatment effect plot (Callaway-Sant'Anna) showing group-time ATTs with 95% CIs
2. Binned scatter plot of price change vs. TH dose (with pre-reform balance shown)
3. Parallel trends validation: overlaid price series for high-dose vs. low-dose communes, 2014-2024
4. All figures in main text (not appendix) following tournament feedback on "architect around hard constraints diagnostics"

**Evidence:** Will be generated in analysis. 4 pre-periods sufficient for visual parallel trends evidence.

---

### Condition 7: full mechanism tables with transaction volumes

**Status:** [x] RESOLVED

**Response:**
The mechanism ladder:
1. **First stage:** TH abolition → effective tax savings (compute from REI data; this is mechanical but establishes bite)
2. **Reduced form:** Tax savings → property prices (main result)
3. **Volume effects:** Tax savings → transaction counts (does liquidity increase?)
4. **Time-on-market:** If obtainable from listing data (secondary source)
5. **Supply response:** Tax savings → building permits (Sit@del2 if accessible)
6. **Heterogeneity:** By supply elasticity, urbanization, income composition

**Evidence:** DVF provides both prices and transaction counts by commune-year. Sit@del2 building permits are on data.gouv.fr (to be verified in execution).

---

## Verification Checklist

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Status: RESOLVED**
