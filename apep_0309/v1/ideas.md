# Research Ideas

## Idea 1: PDMP Network Spillovers — How Neighboring States' Must-Query Mandates Reshape the Geography of Opioid Mortality

**Policy:** Prescription Drug Monitoring Program (PDMP) must-query mandates, adopted by 43+ states between 2012 and 2023. Kentucky was first (2012); staggered rollout continues. A "must-query" mandate requires prescribers to check the PDMP before writing controlled substance prescriptions.

**Outcome:** State-level drug overdose mortality by drug type (total overdose, prescription opioids T40.2, heroin T40.1, synthetic opioids/fentanyl T40.4, cocaine T40.5, psychostimulants T43.6). Source: CDC VSRR provisional data via Socrata API (endpoint `xkb8-kh2a`), 2015–2024, all 50 states + DC. Supplemented by CDC NCHS Drug Poisoning Mortality (endpoint `jx6g-fdh6`) for 1999–2015 to extend the panel.

**Identification:** Doubly Robust Difference-in-Differences (DRDID, Sant'Anna & Zhao 2020). Treatment = binary indicator for high PDMP network exposure, defined as the share of contiguous neighboring states that have enacted must-query mandates exceeding a threshold (e.g., ≥50%). For each state-year, I construct a network exposure variable from the state adjacency graph, weighted by shared border length or neighboring-state population. The DR estimator combines inverse probability weighting (modeling why some states face high network exposure) with outcome regression (modeling overdose deaths), providing double protection against misspecification.

**Why it's novel:**
- First formal network approach to PDMP spillovers using graph-theoretic exposure measures (prior work uses simple "neighboring state" dummies)
- First application of doubly robust DiD to PDMP policy evaluation (existing literature uses standard TWFE)
- Decomposition by drug type reveals substitution across the network: do PDMPs push prescription opioid prescribing to neighbors, while increasing heroin/fentanyl deaths locally?
- Network position heterogeneity: do "border states" (high degree centrality) experience larger spillovers than "interior states"?

**Feasibility check:** Confirmed: CDC VSRR API returns state-level overdose deaths by drug type for 2015–2024 (tested). Census ACS API returns state-level demographics for covariates (tested). PDMP must-query dates published in PDAPS, Buchmueller & Carey (2018, AEJ:EP), and Wen et al. (2019). State adjacency matrix is standard. Prior spillover papers (Meinhofer 2018, Shakya & Hodges 2023) use DiD — no DR approach exists.


## Idea 2: The Cannabis Border Network — Doubly Robust Estimation of Neighboring-State Recreational Legalization Spillovers

**Policy:** Recreational cannabis legalization, adopted by 24 states between 2012 (Colorado, Washington) and 2024. Creates dramatic geographic discontinuities at state borders — legal on one side, illegal on the other.

**Outcome:** State-level employment in accommodation/food services (NAICS 72, capturing "cannabis tourism" effects), state tax revenue, and drug-related arrest rates. Sources: Census QWI for employment, BLS QCEW, state revenue departments, FBI Crime Data API.

**Identification:** Doubly Robust estimation where treatment = share of contiguous neighbors that have legalized recreational cannabis. States with more legal neighbors face greater "network exposure" to cross-border effects. DR conditioning on: own legalization status, demographics, political composition, prior drug arrest rates, median income, urbanization.

**Why it's novel:** Applies network exposure methodology to cannabis policy — most papers study within-state effects. The adjacency-weighted exposure measure captures the cumulative pressure of surrounding legalization.

**Feasibility check:** Cannabis legalization dates are well-documented (NCSL). QWI confirmed accessible. ~24 treated states with staggered timing provides good variation. CONCERN: FBI crime data has reporting gaps; tax revenue data requires state-by-state collection.


## Idea 3: Metcalfe's Law in Healthcare — Network Externalities of the Enhanced Nurse Licensure Compact

**Policy:** The Enhanced Nurse Licensure Compact (eNLC), allowing nurses to practice in member states with one license. Original compact (2000); enhanced version rolled out 2018–present. Currently 42 member states. Each new member increases the compact's value for all existing members (Metcalfe's law: network value ∝ N²).

**Outcome:** Nurse employment, nurse wages, hospital staffing ratios, health professional shortage area designations. Sources: Census QWI (NAICS 622 = hospitals, 621 = ambulatory care), Census ACS occupation-level wages, HRSA AHRF.

**Identification:** Doubly Robust estimation. Treatment = eNLC membership interacted with compact network size at time of joining (capturing Metcalfe's law). DR conditions on pre-joining nurse shortage levels, rural population share, healthcare spending per capita, political composition. Key test: does the SAME policy (joining the compact) have LARGER effects when the network is bigger?

**Why it's novel:** Tests Metcalfe's law in a regulatory network setting. Prior NLC papers study membership effects but ignore network size dynamics. The interaction of treatment × network size is the key contribution.

**Feasibility check:** eNLC membership dates published by NCSBN. QWI and ACS data confirmed accessible. 42 member states provides substantial variation. Strong network mechanism with testable prediction.


## Idea 4: Data Privacy Laws and the Unraveling of Digital Advertising Networks — Employment Effects in the Information Sector

**Policy:** State comprehensive data privacy laws: CCPA (CA, 2020), VCDPA (VA, 2023), CPA (CO, 2023), CTDPA (CT, 2023), UCPA (UT, 2024), plus 10+ more through 2025. These laws restrict the data-sharing networks that underpin targeted advertising.

**Outcome:** Employment and wages in NAICS 51 (Information) and NAICS 5418 (Advertising/PR), business establishment counts. Source: Census QWI (state-quarter-industry).

**Identification:** Doubly Robust estimation. Treatment = passage of comprehensive data privacy law. DR conditioning on: pre-existing tech employment share, GDP per capita, bachelor's degree attainment, political composition, broadband penetration. Double robustness needed because privacy law adoption is highly endogenous (correlated with tech sector presence).

**Why it's novel:** Very few causal studies of data privacy laws' economic effects exist. The "network disruption" framing — these laws fragment the data-sharing network that connects advertisers, platforms, and data brokers — is original.

**Feasibility check:** QWI data confirmed accessible. Privacy law dates well-documented. CONCERN: Most laws took effect 2023+, limiting post-treatment data to ~4–6 quarters. California (2020) provides the longest post-treatment window but is a single state. May be underpowered.


## Idea 5: Telehealth Parity Laws and the Expansion of Virtual Provider Networks in Rural America

**Policy:** Permanent telehealth parity laws requiring insurers to reimburse telehealth visits at the same rate as in-person visits. At least 28 states enacted permanent parity laws between 2019 and 2023 (accelerated by COVID-19).

**Outcome:** Health insurance coverage, healthcare utilization, health professional shortage area designations, potentially mortality. Sources: Census ACS for insurance and demographics, HRSA AHRF for provider supply, CDC for health outcomes.

**Identification:** Doubly Robust estimation. Treatment = enactment of permanent telehealth parity law. DR conditioning on: pre-existing broadband penetration, rural population share, prior telehealth adoption, provider shortage levels, Medicaid expansion status. The parity law effectively expands the provider "network" accessible to rural patients from local providers only to the entire state (or interstate for compact members).

**Why it's novel:** Most telehealth papers study utilization changes, not the network expansion mechanism. The interaction of telehealth parity × rural isolation tests whether network expansion matters more where the local network is thinnest.

**Feasibility check:** ACS and HRSA data confirmed accessible. Parity law dates from CCHP/ATA. CONCERN: COVID-19 is a massive confound — all states expanded telehealth during the pandemic regardless of parity laws. Separating the law's effect from the pandemic response is extremely difficult.
