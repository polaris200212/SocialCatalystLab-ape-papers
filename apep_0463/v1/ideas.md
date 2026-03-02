# Research Ideas

## Idea 1: Cash Scarcity and Food Prices: Evidence from Nigeria's 2023 Currency Redesign

**Policy:** In October 2022, the Central Bank of Nigeria (CBN) announced a redesign of the ₦200, ₦500, and ₦1,000 banknotes. Old notes ceased to be legal tender on January 31, 2023 (extended to February 10). Severe cash shortages followed—banks ran out of new notes, ATMs were empty for weeks, and POS terminal commissions surged 400–1,000%. The Supreme Court intervened on March 3, 2023, restoring old notes. The acute crisis lasted approximately 6–8 weeks (late January–mid March 2023).

**Outcome:** Weekly food prices from FEWS NET Staple Food Price Data (305,289 observations, 15 states, 20 commodities including rice, maize, cowpeas, gari, millet, sorghum, groundnuts). Weekly frequency from 2003–2024 provides exceptional pre-treatment depth.

**Identification:** Continuous difference-in-differences. Treatment intensity = pre-existing state-level financial exclusion (inverse of banking infrastructure density). States with fewer bank branches per capita, lower ATM density, and higher cash dependence experienced more severe shortages. The CBN policy was a federal decision exogenous to state-level food price trends. Design parallels Chodorow-Reich et al. (2020, QJE) on India's 2016 demonetization, which used cross-district variation in pre-demonetization cash intensity.

**Why it's novel:** Zero causal studies exist on the naira redesign's economic effects. The event is well-known but has attracted only descriptive/qualitative analysis. This would be the first quasi-experimental study of any outcome of this policy.

**Feasibility check:**
- ✅ FEWS NET data confirmed accessible via direct API (CSV download, 305K rows)
- ✅ 15 states with consistent weekly coverage through the crisis period (Jan–Mar 2023)
- ✅ 20+ years of pre-treatment data (2003–2022) for robust parallel trends testing
- ✅ Treatment intensity variable constructable from CBN banking statistics (bank branches by state, published in Annual Statistical Bulletin Table A.15)
- ⚠️ 15 state clusters requires wild cluster bootstrap for inference (Webb weights)
- ✅ Multiple commodities allow heterogeneity analysis (cash-intensive vs less cash-intensive goods)
- ✅ Not in APEP list. Not on Google Scholar as a causal study.

---

## Idea 2: Closing the Gate: The Price Effects of Nigeria's 2019 Border Closure

**Policy:** Nigeria closed all land borders on August 20, 2019 and maintained the closure until December 15, 2020 (16 months). The closure targeted smuggling of rice, frozen poultry, vehicles, and small arms. Authorities seized 159,506 bags of smuggled rice during enforcement. The closure disrupted massive informal cross-border trade with Benin, Niger, Cameroon, and Chad.

**Outcome:** Same FEWS NET weekly food price data. Rice prices are the primary outcome (50kg bag of imported rice rose from ₦14,500 to ₦27,000).

**Identification:** DiD with treatment = border state (shares international land border) vs interior state. Nigeria has 17 border states sharing borders with Benin (7), Niger (7), Cameroon (6), and Chad (1). Of the 15 FEWS NET states, approximately 10 are border states and 5 are interior.

**Why it's novel:** One unpublished CEU thesis (2025) used paired t-tests and basic DiD, finding a 14.7% price increase. No peer-reviewed journal article with modern DiD methods (Callaway-Sant'Anna, event study) exists. Room for substantial methodological improvement.

**Feasibility check:**
- ✅ FEWS NET data covers the period (2019–2020) with weekly frequency
- ✅ Clear treatment/control distinction (border vs interior states)
- ⚠️ Only 15 total clusters (10 border + 5 interior). Few-clusters problem.
- ⚠️ Less novel than Idea 1 (one prior study exists, albeit unpublished)
- ✅ 16 months of treatment provides sustained exposure for analysis
- ✅ Rice prices specifically affected—direct mechanism through trade disruption

---

## Idea 3: Cash Crises and Democratic Participation: Nigeria's Currency Redesign and the 2023 Election

**Policy:** Same naira redesign as Idea 1. The acute cash crisis coincided precisely with the February 25, 2023 presidential election. Citizens in cash-scarce areas could not afford transport to polling stations or purchase food/water while queuing.

**Outcome:** State-level election turnout from INEC (2011, 2015, 2019, 2023 presidential elections). Data available from ERAD (Excel downloads) and Wikipedia (state-by-state tables). Variables: registered voters, valid votes, turnout rate, vote shares by party.

**Identification:** Continuous DiD. Treatment intensity = state-level financial exclusion rate (from EFInA Access to Financial Services 2020 survey). States with higher cash dependence experienced more severe disruption, potentially suppressing turnout or shifting vote patterns.

**Why it's novel:** No causal study of the naira redesign's electoral effects exists. Connects to growing literature on economic shocks and democratic participation.

**Feasibility check:**
- ✅ Election data available (ERAD, Wikipedia, INEC reports)
- ⚠️ Only 4 elections (2011, 2015, 2019, 2023) = 3 pre-treatment periods (below ≥5 threshold)
- ⚠️ Confounded by election-specific factors (candidates, party dynamics)
- ✅ 37 states (all) provide sufficient clusters
- ❌ Pre-treatment periods fail DiD feasibility gate (≤2 years between elections also problematic)

---

## Idea 4: Conflict and Food Security: How Armed Violence Affects Agricultural Markets in Nigeria

**Policy:** Escalation of armed conflict across Nigerian states at staggered dates: Boko Haram insurgency in the northeast (July 2009 onset, major escalation June 2013 state of emergency), farmer-herder clashes in the Middle Belt (escalation from January 2015), and armed banditry in the northwest (major escalation from 2018). Federal and state emergency declarations, military operations (Operation Lafiya Dole 2015, Operation Sharan Daji 2016), and civilian displacements followed at different times across different states.

**Outcome:** FEWS NET weekly food prices (same dataset) and UCDP conflict events (9,787 events, 1990–2023, geo-coded to state level with fatality counts).

**Identification:** Instrumented DiD or local projections. Use sudden conflict escalations (defined by sharp increases in monthly UCDP events above state-specific thresholds) as treatment shocks. Staggered timing across states provides variation.

**Why it's novel:** While the conflict-agriculture nexus has been studied in other contexts, Nigeria's unique combination of high-frequency market price data and granular conflict data is underexploited.

**Feasibility check:**
- ✅ Both UCDP and FEWS NET data confirmed accessible
- ⚠️ Endogeneity concern: conflict may respond to food prices (reverse causality), or both may respond to common shocks (rainfall, economic downturns)
- ⚠️ Requires careful instrumental variable or timing-based identification
- ✅ Rich time series depth (20+ years in both datasets)
- ✅ 15 states with price data, many affected by different conflict waves
