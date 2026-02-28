# Research Ideas

## Idea 1: When Revenue Falls, Branches Follow — The Durbin Amendment, Bank Restructuring, and the Decline of the Bank Teller

**Policy:** The Durbin Amendment (Section 1075 of the Dodd-Frank Act), effective October 2011, capped debit card interchange fees at approximately $0.21 + 0.05% per transaction for banks with assets exceeding $10 billion. This stripped an estimated $6–8 billion annually from large banks' revenue streams, creating a sharp regulatory shock to bank profitability.

**Outcome:** County-level banking employment from BLS QCEW (NAICS 52211, Commercial Banking), MSA-level teller employment from BLS OES (SOC 43-3071, Tellers), and FDIC Summary of Deposits (SOD) for branch-level data on openings, closures, and deposit structure. FRED series for national banking aggregates.

**Identification:** Bartik/shift-share difference-in-differences. Treatment intensity at the county level = pre-Durbin (2010) share of county deposits held in banks with assets >$10B (Durbin-affected). National policy shock × local exposure variation. Event-study specification from 2006–2018 allows testing for pre-trends over 5 pre-periods. Triple-difference (DDD) using non-banking employment as within-county control to absorb county-specific macro shocks (e.g., crisis recovery). Standard errors clustered at the state level (~50 clusters).

**Why it's novel:** Existing Durbin literature (Kay et al. 2014 Fed paper; Wang et al. 2014) studies bank profitability and consumer fees. Nobody has examined the **labor market restructuring** — specifically how the revenue shock reshaped physical banking infrastructure (branches, tellers) and whether it accelerated the transition from branch-heavy to digital banking. This connects the Durbin Amendment to the Bessen (2015) ATM-teller paradox: the complementarity between ATMs and tellers was sustained partly by interchange-funded branch expansion. Strip the revenue, and banks shed physical infrastructure.

**Feasibility check:**
- FDIC SOD API confirmed working: 2.8M branch-level records, 1994–present
- FDIC Financials API confirmed: bank-level asset data to identify >$10B threshold
- BLS QCEW bulk download confirmed (annual zip files, county × industry)
- BLS OES data available at MSA level for teller occupation
- Pre-periods: 2006–2010 (5 years before October 2011 implementation)
- Post-periods: 2012–2018 (7 years)
- Counties: 3,000+ with banking employment data
- States for clustering: 50+
- DiD feasibility: Continuous treatment, all states have variation, >5 pre-periods ✓


## Idea 2: The Digital Cliff — How Mobile Banking Adoption Broke the ATM-Teller Complementarity

**Policy:** The staggered rollout of 4G LTE mobile broadband across U.S. counties (2010–2016), which enabled smartphone-based mobile banking applications. Unlike ATMs (which reduced per-branch costs, enabling branch expansion), mobile banking reduced the *value of branches to consumers*, triggering closures.

**Outcome:** FDIC SOD branch counts and deposits at the county level; BLS QCEW banking employment; FCC Form 477 broadband deployment data for mobile LTE coverage at the census-tract level; Census ACS for demographic controls.

**Identification:** Bartik/IV design using county-level variation in 4G LTE coverage timing (FCC Form 477). Instrument: terrain ruggedness interacted with carrier rollout schedules. The argument: tower siting is cheaper in flat terrain → earlier 4G access → earlier mobile banking adoption → earlier branch closures. Event study traces dynamic effects.

**Why it's novel:** Directly tests why Bessen's (2015) ATM-teller complementarity broke down post-2010. Distinguishes "process automation" (ATMs reducing costs of existing workflow) from "platform automation" (mobile banking replacing the workflow). High stakes for current AI/automation debates.

**Feasibility check:**
- FCC Form 477 data available semi-annually (complex but accessible)
- FDIC SOD confirmed working
- Identification relies on terrain instrument — needs validation
- Risk: exclusion restriction fragile (4G affects many industries, not just banking)
- Backup: Use shift-share with national mobile banking adoption × pre-existing broadband gaps


## Idea 3: Merger Waves and Teller Displacement — The Labor Market Cost of Bank Consolidation

**Policy:** Bank merger waves, particularly post-2008 FDIC-assisted acquisitions and voluntary consolidation (2008–2016). When banks with overlapping geographic footprints merge, they close redundant branches. The degree of branch overlap is quasi-predetermined (based on pre-merger branch networks).

**Outcome:** FDIC SOD for branch-level openings/closures; BLS QCEW for county banking employment; FDIC merger/acquisition records; ACS for displaced-teller reemployment outcomes.

**Identification:** Predicted branch closures from merger overlap. For each merger, compute county-level "exposure" = number of overlapping branches (both banks present in same county). DiD: High-overlap vs. low-overlap counties, pre vs. post-merger. Can also use FDIC-assisted acquisitions (failed bank purchases) as more exogenous variation.

**Why it's novel:** Connects bank consolidation literature to labor market outcomes. Most merger studies focus on market power, pricing, or credit supply — not on displaced banking workers. The teller is the face of the branch; mergers destroy branches; what happens to tellers?

**Feasibility check:**
- FDIC merger data needs verification (specific API endpoint)
- FDIC SOD confirmed: can identify overlapping branches pre-merger
- BLS QCEW confirmed
- Risk: merger timing may be endogenous to local economic conditions
- FDIC-assisted acquisitions provide cleaner variation (bank failure is less endogenous to local labor markets)


## Idea 4: Cash or Card? ATM Surcharge Deregulation and the Restructuring of Bank Labor

**Policy:** In April 1996, Visa and MasterCard lifted their network-level prohibition on ATM surcharges. States responded heterogeneously: Iowa and Connecticut enacted explicit ATM surcharge bans; most states allowed surcharges. Over time, some bans were lifted through litigation (Iowa, 8th Circuit ~2002). This created staggered state-level variation in ATM usage costs.

**Outcome:** BLS QCEW banking employment; BLS OES teller employment; FDIC SOD branch structure; potentially FDIC bank fee data.

**Identification:** Staggered DiD exploiting state-level surcharge ban variation. Treatment: states that banned surcharges (lower ATM costs for consumers → more ATM usage → potentially fewer teller transactions). Callaway-Sant'Anna estimator for heterogeneous treatment effects.

**Why it's novel:** Tests whether ATM pricing policy affects the composition of bank labor. If surcharges deter ATM use, consumers visit branches more → more tellers needed. If surcharges are allowed, consumers use ATMs more → tellers shift to advisory roles.

**Feasibility check:**
- Only 2–3 states with persistent bans (Iowa, Connecticut, briefly Kansas)
- Too few treated units for credible staggered DiD
- Legal challenges blur clean treatment timing
- REJECT: Insufficient state-level variation for DiD requirements (need ≥20 treated states)
