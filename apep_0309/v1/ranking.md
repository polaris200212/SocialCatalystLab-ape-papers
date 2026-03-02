# Research Idea Ranking

**Generated:** 2026-02-16T12:14:09.928932
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 8094

---

### Rankings

**#1: PDMP Network Spillovers — How Neighboring States' Must-Query Mandates Reshape the Geography of Opioid Mortality**
- **Score: 74/100**
- **Strengths:** Strong policy relevance and a plausible spillover mechanism; rich outcome measurement by drug type makes substitution/cross-drug displacement testable rather than hand-wavy. Long pre-period is feasible using NCHS mortality and the “network exposure” design is more original than standard “any neighbor treated” indicators.
- **Concerns:** DRDID does not fix the core threat: regional opioid shocks and coordinated multi-policy responses (naloxone access, pill mill laws, Medicaid expansion, synthetic opioid waves) can jointly drive adoption and mortality. Timing (mid-year mandate effective dates vs calendar-year mortality) can mechanically attenuate effects unless handled carefully.
- **Novelty Assessment:** **Moderately novel.** PDMP must-query mandates have many papers; *network spillovers by drug type with modern staggered/DR estimators* is meaningfully less saturated, but not empty.
- **DiD Assessment (mandatory 8 criteria):**
  - **Pre-treatment periods:** **Strong** (NCHS 1999–2015 gives >5 pre-years for essentially all adoptions).
  - **Selection into treatment:** **Marginal** (must-query adoption responds to opioid conditions/politics; “neighbor exposure” is partly external but still correlated with regional epidemics).
  - **Comparison group:** **Marginal** (low-exposure states are often in different regions; need strong covariate/event-study support and possibly region-specific trends).
  - **Treatment clusters:** **Strong** (43+ adopters; exposure varies continuously across all states/years).
  - **Concurrent policies:** **Marginal** (high risk in opioid policy space; must control for other opioid-related laws and consider synthetic opioid periodization).
  - **Outcome-Policy Alignment:** **Strong** (overdose mortality by drug type directly reflects the hypothesized mechanism: reduced Rx opioid supply and substitution).
  - **Data-Outcome Timing:** **Marginal** (mortality is typically by calendar year; many mandates start mid-year—need monthly VSRR or define treatment as “first full calendar year,” or use lags).
  - **Outcome Dilution:** **Strong** (policy targets controlled-substance prescribing, and the outcomes are overdoses—still not “everyone,” but far less diluted than broad labor-market outcomes; drug-type outcomes reduce dilution further).
- **Recommendation:** **PURSUE (conditional on: (i) explicit event-study plots for both own-policy and neighbor-exposure; (ii) treatment timing aligned to effective dates using monthly outcomes or first-full-year exposure; (iii) control/robustness for major concurrent opioid policies and the fentanyl era via interactions or period splits).**

---

**#2: Metcalfe's Law in Healthcare — Network Externalities of the Enhanced Nurse Licensure Compact**
- **Score: 66/100**
- **Strengths:** The “network size at joining” interaction is a clear, testable implication (effects should scale with compact size), and the policy is highly relevant for workforce mobility and staffing shortages. Many treated units (eventually ~42) gives scope for staggered-adoption methods beyond TWFE.
- **Concerns:** Comparison groups are fragile because remaining non-members are atypical large states (CA/NY/others), and COVID-era nurse labor markets are dominated by confounding shocks (travel nursing, federal funds, hospital surges). Outcomes risk dilution if measured at hospital-industry level rather than nurse occupations.
- **Novelty Assessment:** **Moderately novel.** NLC/eNLC membership effects exist in policy discussions and some empirical work, but *explicitly testing network-size externalities (Metcalfe-style scaling)* is less common.
- **DiD Assessment (mandatory 8 criteria):**
  - **Pre-treatment periods:** **Strong** (QWI/ACS allow many pre-years before 2018+ eNLC expansions).
  - **Selection into treatment:** **Marginal** (joining likely responds to shortages/politics; not a clean external mandate).
  - **Comparison group:** **Marginal** (usable “not-yet-treated” controls exist early on, but never-treated are few and structurally different).
  - **Treatment clusters:** **Strong** (large number of adopters; staggered timing).
  - **Concurrent policies:** **Marginal** (COVID shocks, scope-of-practice changes, staffing mandates in some states; needs policy controls and period restrictions).
  - **Outcome-Policy Alignment:** **Marginal → Strong if redesigned** (strong if using nurse occupation wages/employment and staffing measures; weaker if relying on NAICS hospital totals that include many non-nurses).
  - **Data-Outcome Timing:** **Marginal** (membership effective dates vary; labor-market adjustment may lag—need quarter/year lags and “first full quarter” exposure).
  - **Outcome Dilution:** **Marginal** (potentially severe if using NAICS 622 aggregates; much less if using ACS nurse occupations or other nurse-specific measures).
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: primary outcomes are nurse-occupation specific; analysis isolates/pre-registers a pre-COVID window or models COVID explicitly; and inference is robust to few/atypical never-treated states).**

---

**#3: The Cannabis Border Network — Doubly Robust Estimation of Neighboring-State Recreational Legalization Spillovers**
- **Score: 49/100**
- **Strengths:** The spillover question is policy-relevant (cross-border purchasing, tourism, enforcement displacement), and staggered legalization provides variation. If implemented at sub-state geography (border counties), the mechanism is tight.
- **Concerns:** As written (state-level NAICS 72 employment), outcome dilution is a dealbreaker: cross-border tourism effects are concentrated near borders but you average over an entire state. Timing is also easily misaligned (legalization date ≠ retail sales start), and post-2020 outcomes are heavily confounded by COVID sector shocks for accommodation/food.
- **Novelty Assessment:** **Low-to-moderate.** Recreational legalization has a very large literature (crime, labor markets, tax, health). Spillovers exist but are less saturated; still, not “new territory.”
- **DiD Assessment (mandatory 8 criteria):**
  - **Pre-treatment periods:** **Strong** (QWI/QCEW provide long pre-period).
  - **Selection into treatment:** **Marginal** (endogenous political adoption; DR doesn’t solve parallel trends).
  - **Comparison group:** **Marginal** (non-legal neighbors can work, but regions differ; also widespread diffusion shrinks clean controls over time).
  - **Treatment clusters:** **Strong** (~24 treated states).
  - **Concurrent policies:** **Weak** (COVID-era shocks to NAICS 72; criminal justice reforms and policing changes also confound arrest outcomes).
  - **Outcome-Policy Alignment:** **Marginal** (arrests align better; NAICS 72 is an indirect proxy for “cannabis tourism,” and tax revenue is mechanically tied to *own* legalization more than neighbor exposure).
  - **Data-Outcome Timing:** **Weak** unless treatment is keyed to *retail sales start dates* (often 6–18 months after legalization) and outcomes are measured after full exposure.
  - **Outcome Dilution:** **Weak** at the state level (border spillovers affect a minority of the state’s employment/arrests; the treated “border zone” is far below 50% of the sample).
- **Recommendation:** **SKIP (unless redesigned):** move to **county- or commuting-zone-level** outcomes with an explicit **border-band design** (e.g., counties within X miles of a legal-border) and define treatment by **sales start** rather than legalization.

---

**#4: Data Privacy Laws and the Unraveling of Digital Advertising Networks — Employment Effects in the Information Sector**
- **Score: 30/100**
- **Strengths:** High novelty and high policy salience; a credible contribution *if* there were enough treated units and post-period and a sharper outcome tightly linked to ad-tech/data brokerage.
- **Concerns:** Identification is currently very weak: few effective treated clusters with meaningful post periods, extreme heterogeneity (CA vs newer/smaller states), and massive coincident shocks to the sector (COVID, tech layoffs, interest rate regime change). NAICS 51 and even 5418 are broad; likely effect sizes are small relative to noise.
- **Novelty Assessment:** **High.** There are not many credible causal state-level studies on comprehensive privacy laws’ labor-market effects.
- **DiD Assessment (mandatory 8 criteria):**
  - **Pre-treatment periods:** **Strong** (QWI long pre).
  - **Selection into treatment:** **Weak** (adoption strongly related to tech sector size, preferences, and political economy; hard to argue plausibly exogenous timing).
  - **Comparison group:** **Weak** (few treated; CA is not comparable; newer adopters differ systematically from never-treated).
  - **Treatment clusters:** **Weak** (effective “N” with enough post is small; most laws are 2023+).
  - **Concurrent policies:** **Weak** (macro/industry shocks dominate 2020–2025).
  - **Outcome-Policy Alignment:** **Marginal/Weak** (laws target data processing/ads; NAICS 51 includes many unrelated activities; 5418 closer but still broad).
  - **Data-Outcome Timing:** **Weak** (too few post-treatment quarters for most states to see adjustment).
  - **Outcome Dilution:** **Weak** (only a slice of firms/workers are in ad-tech/data brokerage; state-industry aggregates dilute heavily).
- **Recommendation:** **SKIP** (promising topic, but the state-level DiD/QWI design is not yet credible; would need firm-level ad-tech data, longer post, or a more discrete enforcement shock).

---

**#5: Telehealth Parity Laws and the Expansion of Virtual Provider Networks in Rural America**
- **Score: 28/100**
- **Strengths:** Policy-relevant and potentially important distributional implications for rural access. There is a coherent heterogeneity hypothesis (larger effects where local provider networks are thin).
- **Concerns:** COVID-era telehealth expansions are an overwhelming confound (temporary waivers, emergency orders, Medicare/Medicaid payment changes), making it very hard to isolate permanent parity laws. Proposed outcomes (insurance coverage, HPSA designations, mortality) are poorly aligned or slow-moving relative to the reimbursement mechanism.
- **Novelty Assessment:** **Low-to-moderate.** Telehealth policy has a large literature post-2020; parity-law-specific causal evidence is thinner, but the space is crowded and identification is hard.
- **DiD Assessment (mandatory 8 criteria):**
  - **Pre-treatment periods:** **Strong** (ACS/HRSA provide long pre).
  - **Selection into treatment:** **Weak** (adoption tightly linked to pandemic response and pre-trends in telehealth/provider shortages).
  - **Comparison group:** **Marginal** (many states adopt; remaining controls likely differ; also “all states expanded telehealth” reduces contrast).
  - **Treatment clusters:** **Strong** (~28 states).
  - **Concurrent policies:** **Weak** (pandemic-era policies directly affect telehealth utilization/payment—same outcomes, same timing).
  - **Outcome-Policy Alignment:** **Weak** (parity affects reimbursement/utilization and provider participation; insurance coverage and mortality are distant; HPSA designations are administrative and lagged).
  - **Data-Outcome Timing:** **Weak** (pandemic timing dominates; parity laws’ effective dates vs measurement windows will be misaligned and swamped).
  - **Outcome Dilution:** **Weak** (telehealth parity mainly affects insured telehealth-eligible populations; rural subgroup is a minority of state outcomes without granular data).
- **Recommendation:** **SKIP** (unless you obtain claims/EHR utilization data with clear payer-specific parity exposure and can credibly net out COVID-era policy shocks).

---

### Summary

Only **Idea 1** clears the bar as written: it has the best combination of feasible data, meaningful variation, and outcomes tightly tied to the policy mechanism—though it still needs careful timing alignment and aggressive handling of concurrent opioid policies. **Idea 3** is conceptually strong but must be redesigned around nurse-specific outcomes and credible controls; the remaining three have “Weak” DiD checklist failures (especially timing/dilution/COVID confounding) that make them poor bets in their current form.