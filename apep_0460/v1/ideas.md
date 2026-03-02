# Research Ideas

## Idea 1: Across the Channel — Social Networks and the Cross-Border Economic Effects of Brexit on French Local Economies

**Policy:** Brexit — UK withdrawal from the EU, with referendum on June 23, 2016 (uncertainty shock) and end of transition period on December 31, 2020 (trade friction shock). This is not a French domestic policy but a massive exogenous European shock with differential exposure across French regions via social networks.

**Outcome:** Multiple margins of French local economic activity:
- Housing prices and transaction volumes (DVF, commune-level, 2014-2023)
- Firm creation and destruction rates (INSEE BDM CREATIONS-ENTREPRISES, département-quarterly)
- Local unemployment rates (INSEE BDM TAUX-CHOMAGE-LOCALISE, département-quarterly)
- Salaried employment levels (INSEE ESTEL, département-annual)

**Identification:** Shift-share IV following Borusyak, Hull, and Jaravel (2022). Shares = pre-Brexit Facebook SCI weights from each French NUTS-3 département to UK NUTS-3 regions (from HDX gadm1.zip, Oct 2021 vintage). Shocks = differential Brexit economic impact across UK regions (ONS ITL3 regional GVA changes, or Bloom et al. 2025 firm-level exposure index aggregated to regions). The instrument exploits within-France variation: two départements facing identical French macro conditions but with different historical social connections to UK regions. French départements more connected to harder-hit UK regions should experience larger negative spillovers.

Key diagnostics: (1) German exposure placebo — identical SCI-weighted measure using German regions should have no effect; (2) Pre-trends test — no effects before June 2016; (3) Permutation inference — randomly reassign UK regional shocks, 2000 draws; (4) Swiss franc shock (Jan 2015) as positive placebo — SCI-weighted Swiss exposure should predict effects; (5) Distance-credibility test following apep_0185 — restrict to more distant UK connections; (6) Population-weighted vs probability-weighted SCI comparison.

**Why it's novel:** Burchardi and Hassan (2013, QJE) showed social ties transmit positive shocks (German reunification) within a country. Mastrosavvas (2024, RSUE) used SCI for within-UK Brexit voting spillovers. No paper has used cross-border SCI to study how Brexit economic effects transmitted to a neighboring country's local economies. This is the first cross-border shift-share IV using the Facebook SCI.

**Feasibility check:** CONFIRMED. SCI data downloadable (gadm1.zip, 76.6 MB, Oct 2021 vintage). DVF bulk download available 2014-present. INSEE BDM SDMX API confirmed for unemployment and firm creations at département level 2014-2022. ONS provides ITL3 UK regional data through 2023. 96 French metropolitan départements × 179 UK ITL3 regions. No API keys needed for SCI or DVF; INSEE BDM is open; ONS is open.


## Idea 2: The Franc Shock Next Door — Social Networks and the Swiss Currency Crisis Transmission to French Border Economies

**Policy:** Swiss National Bank abandonment of EUR/CHF floor on January 15, 2015. Overnight 20% franc appreciation. Massive exogenous monetary shock affecting cross-border economic relationships.

**Outcome:** French housing prices (DVF), employment in border départements (INSEE), and frontalier (cross-border worker) dynamics.

**Identification:** Spatial DiD combined with SCI-weighted exposure. Compare French départements with high vs. low social connectivity to Swiss cantons, before and after January 15, 2015. Alternative: pure RDD at French-Swiss border (communes within X km on each side).

**Why it's novel:** The frontalier phenomenon is well-documented but no study links SCI to the transmission of the Swiss franc shock to French local housing and labor markets.

**Feasibility check:** PARTIALLY CONFIRMED. SCI data available for France-Switzerland pairs. DVF covers French side but Alsace-Moselle (3 départements on German border) excluded — not directly relevant since Swiss border is further south (Ain, Haute-Savoie, Doubs, Haut-Rhin — the latter IS excluded from DVF). This limits the design. INSEE employment data available. Swiss cantonal data accessible (no API keys needed). Risk: limited geographic variation — only ~10 départements have meaningful Swiss connectivity.


## Idea 3: Europe's Information Superhighway — Do Social Networks Transmit Trade Shocks Across EU Borders?

**Policy:** EU-UK Trade and Cooperation Agreement (TCA) implementation on January 1, 2021. Non-tariff barriers (customs checks, regulatory divergence) immediately disrupted UK-EU trade flows.

**Outcome:** French département-level trade-related employment (INSEE), firm births in export-oriented sectors (Sirene), port activity near cross-Channel infrastructure (Calais, Dunkerque).

**Identification:** Triple-difference design: (1) French départements with high vs. low SCI to UK, (2) sectors with high vs. low UK trade exposure, (3) before vs. after January 2021. This isolates the trade friction channel specifically, separate from the earlier uncertainty effects.

**Why it's novel:** Extends the SCI-trade literature (Bailey et al. 2021, JIE) from cross-sectional correlation to causal identification using a sharp policy shock.

**Feasibility check:** PARTIALLY CONFIRMED. Same data as Idea 1 but focused on the 2021 trade shock rather than the 2016 uncertainty shock. The COVID confound in 2020-2021 is a major threat — hard to separate trade friction effects from pandemic recovery effects.


## Idea 4: Digital Ties and the Eurozone Crisis — Did Social Networks Amplify Sovereign Debt Contagion to French Regions?

**Policy:** European sovereign debt crisis (2010-2012). Greek, Italian, Spanish, and Portuguese sovereign debt crises with massive economic contractions.

**Outcome:** French housing prices (DVF from 2014 only — too late for crisis onset), firm dynamics, unemployment at département level.

**Identification:** SCI-weighted exposure to crisis countries (Greece, Italy, Spain, Portugal) as shift-share IV.

**Why it's novel:** Tests whether social networks transmitted financial crisis effects across European borders.

**Feasibility check:** REJECTED. DVF data only starts in 2014, 2+ years after the peak of the crisis. Cannot construct adequate pre/post comparison. INSEE employment data exists from 2007 but SCI was released for Oct 2021 vintage — social ties in 2021 may poorly proxy for 2010-2012 connections. The Eurozone crisis is also multi-country and messy — no clean single shock.


## Idea 5: Friends Across Borders — How German Energiewende Shocks Propagate to French Energy Markets via Social Networks

**Policy:** German nuclear phase-out (Energiewende) accelerated after Fukushima (March 2011), with progressive reactor shutdowns through 2022. Final three reactors closed December 31, 2022.

**Outcome:** French energy prices and generation mix (RTE eCO2mix, high-frequency), industrial employment near interconnection points, local electricity costs.

**Identification:** SCI-weighted exposure to German regions with nuclear shutdowns. French regions with higher SCI connections to German nuclear regions should see differential energy market effects.

**Why it's novel:** The Franco-German energy interconnection is massive (4.6 GW capacity). No study links social network connections to cross-border energy spillovers.

**Feasibility check:** PARTIALLY CONFIRMED. RTE eCO2mix provides high-frequency French energy data. German nuclear shutdown dates are known. But the causal channel is weak — energy markets are connected through the physical grid, not through social networks. SCI is the wrong network measure here; grid interconnection capacity would be more appropriate. The social network channel lacks theoretical justification for energy markets.
