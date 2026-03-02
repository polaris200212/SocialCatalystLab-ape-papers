# Research Ideas

## Idea 1: The Visible and the Invisible: Traffic Exposure, Political Salience, and the Quality of Bridge Infrastructure Maintenance

**Policy:** Federal and state bridge maintenance investment, governed by the National Bridge Inspection Standards (NBIS, 23 CFR 650) and funded through the Highway Trust Fund formula allocations (MAP-21 2012, FAST Act 2015, IIJA 2021). States have discretion over which bridges receive maintenance investment, creating observable within-state variation.

**Outcome:** National Bridge Inventory (NBI) bridge condition ratings — deck (Item 58), superstructure (Item 59), substructure (Item 60) — recorded on a 0-9 scale for ~621,000 bridges annually from 1992-2025. Freely downloadable from FHWA (https://www.fhwa.dot.gov/bridge/nbi/ascii.cfm). Also includes Average Daily Traffic (ADT), age, material type, design load, GPS coordinates, and county FIPS.

**Identification:** Doubly robust (DR) estimation exploiting within-state variation in bridge visibility. Treatment: high-ADT bridges (top tercile) vs. low-ADT bridges, conditional on engineering characteristics (age, material, span length, design load, climate zone, functional classification). DR combines inverse probability weighting for "being a high-visibility bridge" with outcome regression for annual condition change. Key falsification: if the mechanism is political visibility (not just economic importance), repair rates should spike before state elections for high-ADT bridges but not low-ADT bridges — the "electoral maintenance cycle."

**Why it's novel:** (1) NBI data is essentially unexploited in economics — used extensively in civil engineering for deterioration modeling but never for causal policy analysis. (2) This is the "Olken for America" paper: Olken (2007 JPE) showed monitoring improves road quality in Indonesia; Glaeser & Ponzetto (2014, 2018) theorize that voter visibility biases infrastructure investment in the US. Nobody has empirically connected these. (3) Traffic volume as a proxy for political monitoring intensity is a natural and credible measure embedded in the data itself.

**Feasibility check:**
- Variation: ~621,000 bridges × 30+ years = massive panel. Top-tercile ADT varies enormously within states. ✓
- Data accessible: NBI freely downloadable as CSV/ASCII, no API key needed. Confirmed available 1992-2025. ✓
- Not overstudied: No economics paper uses NBI condition ratings as causal outcome. Literature search confirms gap. ✓
- Sample size: 18+ million bridge-year observations. ✓


## Idea 2: The Digital Panopticon: Do Online Spending Transparency Portals Improve State Fiscal Management?

**Policy:** State adoption of online "checkbook" or spending transparency portals that allow citizens to search government expenditures (e.g., Texas Comptroller transparency portal 2007, Ohio Checkbook 2014, etc.). Approximately 30+ states have adopted such portals between 2007-2020, creating staggered adoption variation.

**Outcome:** State government fiscal outcomes from the Census Annual Survey of State Government Finances: total expenditure per capita, debt levels, bond credit ratings (Moody's/S&P), and competitive bidding rates.

**Identification:** Staggered DiD using Callaway-Sant'Anna (doubly robust) estimator. Treatment = year state's online transparency portal went live. Outcome = fiscal management indicators. Mechanisms: journalist usage (newspaper stories citing portal data), citizen engagement (portal web traffic).

**Why it's novel:** Most transparency literature focuses on developing countries (Olken 2007, Reinikka & Svensson 2005). US fiscal transparency has been studied at the law level (Alt et al. 2006) but not at the PORTAL level — the distinction between de jure transparency (FOIA) and de facto transparency (easy online access) is understudied.

**Feasibility check:**
- Variation: 30+ states with staggered adoption 2007-2020. ✓
- Data accessible: Census government finances via Census API. ✓
- Not overstudied: Portal-specific effects are novel. ✓
- Concern: Treatment dates require manual verification via web archive; some portals launched incrementally. ⚠️


## Idea 3: Auditing the Auditors: Federal Single Audit Findings and Subsequent Grant Management

**Policy:** The Single Audit Act (1984, amended 1996) requires entities spending ≥$750,000 in federal awards to undergo annual audits. Audit findings (material weaknesses, significant deficiencies, questioned costs) are reported to the Federal Audit Clearinghouse (FAC) and are publicly searchable.

**Outcome:** Subsequent grant spending patterns, measured via USAspending.gov: total federal grants received, questioned costs in follow-up audits, program performance indicators.

**Identification:** Doubly robust estimation. Treatment: entity received material weakness finding in year t. Control: similar entities with clean audits. DR: combine propensity score for receiving a finding (based on entity size, grant portfolio, prior history) with outcome regression for subsequent fiscal behavior.

**Why it's novel:** The FAC data is public but rarely used in economics. Most audit literature focuses on private sector (SOX, etc.). Whether government audit findings actually improve subsequent behavior is an open empirical question with direct Olken parallels (monitoring → performance).

**Feasibility check:**
- Variation: ~100,000 single audits per year, ~20% have findings. ✓
- Data accessible: FAC data publicly searchable at https://facweb.census.gov/. USAspending API for grants. ✓
- Not overstudied: Very few economics papers on Single Audit Act effects. ✓
- Concern: Linking FAC entities to USAspending may require DUNS/UEI matching. ⚠️


## Idea 4: Does Daylight Prevent Crime? Street Light Investment and Public Safety

**Policy:** Municipal street lighting programs and upgrades. Several cities have undertaken major LED conversion programs at different times (e.g., Los Angeles 2009-2014, Detroit 2014-2016, New York 2015-2017). Some cities have also experienced widespread light outages due to infrastructure failure (e.g., Detroit, where 40% of street lights were non-functional by 2012).

**Outcome:** Crime rates by neighborhood/census tract from FBI UCR and city open data portals.

**Identification:** Doubly robust estimation comparing neighborhoods that received early vs. late street light upgrades, conditional on demographics and pre-treatment crime trends. For cities with light outages, the variation is even cleaner: neighborhoods that lost lights vs. those that didn't.

**Why it's novel:** Chalfin et al. (2022 ReStud) studied NYC street lighting using an RCT. But most cities can't randomize. The DR approach using staggered municipal upgrades extends this to a broader US context. The "lights out" natural experiments (Detroit) add a unique angle.

**Feasibility check:**
- Variation: Multiple cities with staggered lighting programs. ✓
- Data accessible: FBI UCR public; city crime data often on open data portals. ✓
- Concern: Getting street light location data at the neighborhood level may require city-specific FOIA requests. ⚠️
- Concern: Chalfin et al. (2022) set a high bar; need to demonstrate clear value-added. ⚠️
