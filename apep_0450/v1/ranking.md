# Research Idea Ranking

**Generated:** 2026-02-24T18:08:37.575002
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 8485

---

### Rankings

**#1: Did India's GST Create a Common Market? Evidence from State-Level Price Convergence**
- **Score:** 78/100
- **Strengths:** Strong dataset (monthly, long pre/post, many goods groups) and a credible intensity design tied to pre-GST tax fragmentation; commodity-group heterogeneity and triple-diff give real bite beyond a single reduced form. High policy relevance: whether GST delivered market integration is a core reform question.
- **Concerns:** The intensity measure (pre-GST indirect tax revenue/GSDP) may proxy for broader state characteristics (development, enforcement capacity) that also drive differential inflation trends; must convincingly address differential pre-trends and contemporaneous shocks (COVID, oil).
- **Novelty Assessment:** **Moderately high.** GST has many papers, but rigorous *price convergence/common-market* evidence using modern continuous-treatment DiD + commodity heterogeneity seems relatively underrepresented versus work on trade frictions/checkposts or firm outcomes.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (Jan 2013–Jun 2017 gives ~54 monthly pre-periods)
  - **Selection into treatment:** **Marginal** (GST is national/exogenous, but *intensity* is not random and may correlate with latent trends)
  - **Comparison group:** **Strong** (all states contribute; identification from cross-state intensity differences)
  - **Treatment clusters:** **Strong** (36 states/UTs)
  - **Concurrent policies:** **Marginal** (demonetization in late 2016; COVID from 2020; fuel price shocks—need flexible time controls/event-study and robustness windows)
  - **Outcome-Policy Alignment:** **Strong** (GST directly changes effective tax wedges affecting retail prices; CPI commodity-group indices map closely to mechanism)
  - **Data-Outcome Timing:** **Strong** (GST effective **July 1, 2017**; CPI is **monthly** and should largely reflect post-reform price collection within July—still worth checking MoSPI fieldwork timing)
  - **Outcome Dilution:** **Marginal** (GST excludes some items and CPI “General” bundles services/housing; but commodity-group analysis greatly reduces dilution risk)
- **Recommendation:** **PURSUE (conditional on: strong differential-pretrend/event-study evidence; alternative intensity measures (e.g., pre-GST VAT/CST reliance by commodity if possible); robustness excluding 2016–2017 transition months and COVID window)**

---

**#2: Jan Dhan Banking Expansion and Rural Credit Growth**
- **Score:** 60/100
- **Strengths:** Long horizon and clear national “shock” with cross-sectional exposure; feasible public data; high policy interest in whether financial inclusion translated into real credit/deposit deepening.
- **Concerns:** The proposed main outcome (state-level *total credit*) is only loosely tied to PMJDY’s primary margin (transaction accounts/DBT rails), creating serious dilution; intensity based on pre-penetration may pick up convergence or differential growth trends unrelated to PMJDY.
- **Novelty Assessment:** **Medium-low to medium.** PMJDY/financial inclusion is heavily studied, but this specific public-data, state-level intensity DiD on *credit/deposit aggregates* is less saturated than household micro studies—still not “new frontier.”
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** (2010–2014 gives ~4 years; workable but not luxurious, especially if outcomes are annual)
  - **Selection into treatment:** **Marginal** (national rollout, but intensity correlated with baseline development and likely with differential trend dynamics)
  - **Comparison group:** **Strong** (all states; intensity design)
  - **Treatment clusters:** **Strong** (36)
  - **Concurrent policies:** **Marginal** (DBT expansion, Aadhaar/JAM, Mudra, later demonetization/GST—hard to separate without careful timing and robustness)
  - **Outcome-Policy Alignment:** **Marginal** (PMJDY → accounts, deposits, payment usage; “credit deployment” is an indirect downstream margin)
  - **Data-Outcome Timing:** **Marginal** (launch **Aug 28, 2014**; annual FY data implies partial exposure in FY2014–15 unless handled explicitly)
  - **Outcome Dilution:** **Weak** *as currently framed* (total state credit is dominated by firms/large borrowers; the treated margin—new low-income accounts—could be <10% of aggregate credit, mechanically attenuating effects)
- **Recommendation:** **CONSIDER (only if re-scoped): switch primary outcomes to margins closer to PMJDY (state PMJDY accounts/ deposits/balances; low-ticket/priority-sector or agri credit; transaction volumes; DBT inflows). If stuck with total credit aggregates, SKIP.**

---

**#3: One Nation, One Ration Card and Rural Labor Market Flexibility**
- **Score:** 45/100
- **Strengths:** Very policy-relevant and plausibly novel; staggered rollout across many states creates the *appearance* of a good DiD setting; MGNREGA administrative series has long pre-periods.
- **Concerns:** COVID-era disruptions overlap heavily with the rollout window, creating a major confounding policy/macro shock; portability usage—especially interstate—appears small, implying severe outcome dilution for state-level labor indicators.
- **Novelty Assessment:** **High.** There is comparatively little causal work on ONORC’s labor-market impacts; most work is descriptive/implementation-focused.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** for PLFS annual outcomes (early adopters have ≈2 pre years); **Strong** for MGNREGA (2006–2019)
  - **Selection into treatment:** **Marginal** (adoption likely related to state administrative capacity/readiness, potentially correlated with labor trends)
  - **Comparison group:** **Marginal** (states differ substantially; “never-treated” doesn’t exist by 2022; relies on not-yet-treated comparisons)
  - **Treatment clusters:** **Strong** (36)
  - **Concurrent policies:** **Weak** (rollout coincides with **COVID-19**, migrant return, relief expansions—directly affects labor and MGNREGA demand)
  - **Outcome-Policy Alignment:** **Marginal** (policy affects food entitlement portability; labor effects are second-stage and may be subtle)
  - **Data-Outcome Timing:** **Marginal/Weak** (PLFS annual is July–June; state activation month creates partial exposure within survey year unless carefully mapped; MGNREGA FY outcomes align better)
  - **Outcome Dilution:** **Weak** (benefits concentrate among migrants/portability users; documented low interstate uptake implies small treated share relative to whole-state labor outcomes)
- **Recommendation:** **SKIP (unless a strong mitigation plan):** e.g., focus on high-migrant districts with district-level outcomes; use outcomes tightly linked to portability (ration offtake portability metrics) and a design that credibly handles COVID (narrow windows, triple-diff with mobility intensity, or excluding 2020–2021 entirely—though that may kill power/variation).

---

**#4: Demonetization, Digital Payments, and the Formalization of India's Economy**
- **Score:** 40/100
- **Strengths:** Big policy event; intensity/event-study design is standard and CPI pre-trends are testable with monthly data; long-run question remains interesting in principle.
- **Concerns:** Extremely crowded literature and identification for “formalization” is weak with the proposed outcomes—PLFS starts after the shock (no true pre), and GST revenue is confounded by GST’s own rollout/design changes.
- **Novelty Assessment:** **Low.** Demonetization has a large economics/policy literature (including high-profile work); incremental contribution would need unusually sharp new data or a new mechanism.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** for CPI (2013–Oct 2016); **Weak** for PLFS formalization outcomes (no pre-demonetization PLFS series)
  - **Selection into treatment:** **Strong** (national surprise)
  - **Comparison group:** **Marginal** (intensity design, but cash-dependence correlates with development and differential trends)
  - **Treatment clusters:** **Strong** (36)
  - **Concurrent policies:** **Weak** (GST begins **July 2017** and directly affects “formalization” proxies; also rapid fintech/UPI expansion and enforcement changes)
  - **Outcome-Policy Alignment:** **Weak** for “formalization” as framed (GST revenue ≠ formal employment; PLFS composition changes can reflect many forces)
  - **Data-Outcome Timing:** **Weak** (key labor outcomes only observed starting 2017–18; first observation is already post and also overlaps GST)
  - **Outcome Dilution:** **Marginal/Weak** (formalization may occur in specific sectors/firm sizes; state aggregates dilute)
- **Recommendation:** **SKIP** (unless you obtain a genuinely new outcome with pre-2016 baseline—e.g., administrative payroll/EPFO/ESIC by state with pre-period—and a strategy to separate GST from demonetization)

---

**#5: NFSA State Implementation and Local Food Price Dynamics**
- **Score:** 25/100
- **Strengths:** Interesting general-equilibrium question and CPI food data are directly relevant; stagger exists on paper.
- **Concerns:** Fatal pre-period problem for early implementers (CPI starts Jan 2013; NFSA begins 2013 and many implement quickly), making parallel trends largely untestable; implementation timing is plausibly endogenous to PDS readiness and food conditions.
- **Novelty Assessment:** **Medium.** NFSA has many studies (leakage, nutrition, targeting); “market food price spillovers” is less common, but not enough to offset weak identification.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (for 2013–2014 implementers, essentially no clean pre in this CPI series)
  - **Selection into treatment:** **Marginal/Weak** (earlier implementation likely tied to administrative capacity/political economy and potentially to food price dynamics)
  - **Comparison group:** **Marginal** (late adopters may be systematically different)
  - **Treatment clusters:** **Strong** (many states, though adoption compressed)
  - **Concurrent policies:** **Marginal** (food procurement/MSP changes, state PDS reforms, inflation regime changes around 2013–2015)
  - **Outcome-Policy Alignment:** **Strong** (NFSA directly affects subsidized grain access; plausible spillovers to market food prices)
  - **Data-Outcome Timing:** **Marginal** (monthly CPI is fine, but exact implementation dates and ramp-up matter; “on paper” date may not equal effective exposure)
  - **Outcome Dilution:** **Strong** (NFSA covers ~67% population; large potential first-stage)
- **Recommendation:** **SKIP** (unless you can secure a much longer pre-period food price series at state level—e.g., older CPI/IW/AL or wholesale price microdata—and credible, audited implementation timing)

---

### Summary

This batch has **one clearly fundable idea**: the GST/common-market study (Idea 1) combines strong data, adequate pre-periods, and a mechanism-aligned outcome with relatively high novelty. The remaining ideas mostly fail on **critical DiD validity dimensions**—especially **timing/pre-period insufficiency (NFSA, PLFS in ONORC/demonetization)**, **major concurrent shocks (ONORC with COVID; demonetization with GST)**, and **outcome dilution/misalignment (Jan Dhan → total credit; demonetization → GST revenue as “formalization”)**. If pursuing a second project, Jan Dhan is viable **only if outcomes are re-scoped** to tighter, less diluted financial-inclusion margins.