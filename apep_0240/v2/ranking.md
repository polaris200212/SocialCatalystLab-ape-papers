# Research Idea Ranking

**Generated:** 2026-02-12T13:16:11.673186
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7928

---

### Rankings

**#1: Flood Risk Disclosure Laws and Housing Market Capitalization of Flood Risk (Idea 1)**
- **Score: 78/100**
- **Strengths:** Strong policy shock (mandatory disclosure) with a large recent adoption wave and a compelling **within-state triple-diff** (flood-exposed vs non-exposed counties) that greatly improves credibility. Monthly ZHVI provides high-frequency outcomes and supports rich event-study diagnostics.
- **Concerns:** Adoption may be **responsive to recent floods** (endogenous timing), and county-level ZHVI likely suffers **treatment dilution** because only a subset of homes within a “flood county” are truly affected. Concurrent changes (NFIP reforms, state insurance market interventions after disasters) could coincide with disclosure laws.
- **Novelty Assessment:** **High.** Some single-state/episode studies exist (e.g., Texas), but a multi-state staggered design on flood-specific disclosure laws is not yet saturated.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (ZHVI monthly back many years; for 2019–2024 adopters you can easily get 5+ pre-years)
  - **Selection into treatment:** **Marginal** (likely correlated with flood salience/disasters; mitigate with state FE + county FE + flood-county × time designs and pre-trend/event-time tests)
  - **Comparison group:** **Strong** (within-state flood vs non-flood counties; plus never-treated states)
  - **Treatment clusters:** **Strong** (~28 treated states; many county observations)
  - **Concurrent policies:** **Marginal** (insurance/NFIP/state resilience programs can move with disasters and legislation)
  - **Outcome-Policy Alignment:** **Strong** (disclosure changes information at transaction → should affect prices/permits specifically in flood-risk locations)
  - **Data-Outcome Timing:** **Marginal** (ZHVI is monthly but smoothed/lagged; laws often effective mid-year—must code **effective date** and treat first partial-exposure months carefully)
  - **Outcome Dilution:** **Marginal** (even in “flood counties,” SFHA share may be 5–30%; consider scaling by % parcels in SFHA or using finer geography if feasible)
- **Recommendation:** **PURSUE (conditional on: (i) coding law *effective* dates not passage; (ii) implementing an event-study with strong pre-trend checks; (iii) reducing dilution by interacting treatment with SFHA share or parcel-level flood-risk measures where possible; (iv) explicitly controlling/flagging coincident NFIP/insurance reforms).**

---

**#2: FEMA Flood Map Revisions and Local Fiscal Impacts (Idea 3)**
- **Score: 74/100**
- **Strengths:** Very **novel mechanism** (risk reclassification → tax base → local fiscal incentives) with clear policy relevance. Potentially quasi-administrative timing (FEMA mapping pipeline) and very large N (many communities over time) makes an event-study feasible.
- **Concerns:** “Administrative” timing is not automatically exogenous—updates can be driven by **post-disaster remapping**, local lobbying, or known rising risk; you must demonstrate no differential pre-trends. County-level fiscal outcomes are annual and can create **timing attenuation** around mid-year “effective” map dates; also dilution if only a small land share changes SFHA status.
- **Novelty Assessment:** **High.** There is literature on flood maps affecting prices/insurance take-up, but the **local public finance** channel is much less studied and policy-relevant.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (government finance series are long-running annually; permits/ZHVI add richer panels)
  - **Selection into treatment:** **Marginal** (mapping schedule partly bureaucratic, but can correlate with evolving risk/disasters and political pressure)
  - **Comparison group:** **Strong** (use not-yet-treated counties as controls + event-study; can also compare within-state)
  - **Treatment clusters:** **Strong** (many counties/communities with revisions)
  - **Concurrent policies:** **Marginal** (post-disaster aid/mitigation, local zoning changes, buyouts may coincide with remapping)
  - **Outcome-Policy Alignment:** **Strong** (property tax revenue/base is directly linked to assessed values affected by SFHA expansion)
  - **Data-Outcome Timing:** **Marginal** (annual fiscal-year measurement vs exact FIRM effective date; must map dates to fiscal years and avoid misclassifying pre-exposure as treated)
  - **Outcome Dilution:** **Marginal** (county-wide revenue includes many unaffected parcels; better to use continuous treatment: change in % parcels/area newly in SFHA)
- **Recommendation:** **PURSUE (conditional on: (i) measuring treatment intensity as ΔSFHA share, not a dummy; (ii) aligning outcomes to fiscal-year exposure; (iii) excluding/removing windows around major floods or explicitly controlling for event severity; (iv) strong pre-trend/event-time placebo tests).**

---

**#3: State Building Code Stringency and Weather-Related Disaster Losses (Idea 4)**
- **Score: 43/100**
- **Strengths:** Important policy question (resilience ROI) and the “code × hazard intensity” interaction is directionally sensible. If executed with the *right* outcome and exposure measure, it could be valuable.
- **Concerns:** As proposed, this likely fails on **Outcome Dilution** and **Timing**: code updates affect **new construction**, but NOAA/FEMA loss totals are dominated by older stock for many years. Also, code adoption is often **responsive to disasters** (endogenous), and NOAA damage measures are noisy and inconsistently reported across states/events.
- **Novelty Assessment:** **Medium.** There is substantial work on specific reforms (e.g., Florida) and mitigation; cross-state code-version DiD is less common, but not wholly new.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (long panel available)
  - **Selection into treatment:** **Marginal/Weak** (states often update after major events or political shifts correlated with risk)
  - **Comparison group:** **Marginal** (states differ structurally in hazard exposure, enforcement, and building stock)
  - **Treatment clusters:** **Strong** (many states, multiple code cycles)
  - **Concurrent policies:** **Marginal** (mitigation grants, insurance regulation, land-use changes often bundled)
  - **Outcome-Policy Alignment:** **Marginal** (aggregate losses are affected by many margins beyond code; better alignment would be claims for post-adoption vintages)
  - **Data-Outcome Timing:** **Weak** (recent adoptions won’t affect losses quickly; “treated” period has little exposure to code-compliant stock)
  - **Outcome Dilution:** **Weak** (new-code structures are a small share of exposed stock for many years; effects swamped in aggregate losses)
- **Recommendation:** **SKIP (unless redesigned)**. A viable redesign would (i) use **structure-vintage-specific** outcomes (insured claims by year-built, NFIP/insurer microdata), and/or (ii) restrict to code changes far enough back that a meaningful share of stock is post-code.

---

**#4: FEMA Disaster Declarations and Local Employment Recovery (Idea 5)**
- **Score: 40/100**
- **Strengths:** High policy salience (does federal disaster designation speed recovery?) and excellent data availability (OpenFEMA + QCEW/QWI) with many events.
- **Concerns:** The key identification problem is **selection into declaration**: declarations are triggered by **severity and capacity**, which directly predict employment losses and recovery. Without a credible threshold/RDD/IV or a clearly “as-good-as-random” comparison, a staggered event study is not causal.
- **Novelty Assessment:** **Low-to-medium.** Disaster impacts on labor markets and federal aid have large literatures; isolating the *declaration* margin is interesting but not new enough to compensate for weak ID.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (QCEW/QWI provide long pre-periods)
  - **Selection into treatment:** **Weak** (declarations are endogenous to damage; major dealbreaker as proposed)
  - **Comparison group:** **Weak** (non-declared counties/events are systematically different—less severe)
  - **Treatment clusters:** **Strong** (many counties/events)
  - **Concurrent policies:** **Weak** (the disaster itself and other relief flows coincide; hard to separate “declaration” from severity/aid bundle)
  - **Outcome-Policy Alignment:** **Marginal** (employment is plausible, but many channels besides FEMA; need to link to actual aid flows)
  - **Data-Outcome Timing:** **Marginal** (quarterly measurement can mis-time immediate shocks vs declaration/aid disbursement)
  - **Outcome Dilution:** **Strong** (county employment is broadly exposed to local shocks/aid)
- **Recommendation:** **SKIP (unless redesigned)**. The only path is a design closer to **RDD around administrative thresholds** (if a credible forcing variable exists) or a compelling within-disaster comparison with exogenous damage measures (e.g., storm track/wind field) plus a strong first stage for declaration/aid.

---

**#5: State Climate Action Plans and Clean Energy Employment (Idea 2)**
- **Score: 35/100**
- **Strengths:** Policymakers care about whether “planning” and broad climate commitments translate into jobs and capacity. Data are available from EIA and BLS sources.
- **Concerns:** A “climate action plan” is an extremely **diffuse treatment** that usually bundles (or merely signals) many other policies; adoption is highly **political and trend-responsive**. This is a classic case where DiD estimates will mostly reflect pre-existing trajectories and coincident policy packages, not the plan itself.
- **Novelty Assessment:** **Low.** While “CAP as a single treatment” is less common than studying RPS/cap-and-trade, the underlying question (state climate policy → clean energy jobs) is heavily studied, and CAPs are not a cleanly isolatable lever.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong**
  - **Selection into treatment:** **Weak** (adoption likely responds to political economy and underlying energy/employment trends)
  - **Comparison group:** **Marginal/Weak** (never-treated states often structurally different in energy mix/politics)
  - **Treatment clusters:** **Strong** (~30+ states)
  - **Concurrent policies:** **Weak** (RPS, tax credits, utility regulation, IRA-era investments, regional compacts—high overlap)
  - **Outcome-Policy Alignment:** **Weak** (CAP may not directly implement policy; outcomes respond to specific instruments, not plan publication)
  - **Data-Outcome Timing:** **Marginal** (plans updated/iterative; “adoption date” may not map to implementation timing)
  - **Outcome Dilution:** **Marginal** (clean energy employment is targeted, so not diluted per se, but levels are small/noisy in many states/years)
- **Recommendation:** **SKIP.** If pursued at all, it should be reframed around **specific, dated, enforceable instruments** (RPS, net metering rules, clean electricity standards) rather than “plan adoption.”

---

### Summary

This is a strong batch on climate-risk policy, but only **Ideas 1 and 3** clear the bar for credible causal inference with feasible data and genuine novelty. **Ideas 2, 4, and 5** each hit at least one DiD dealbreaker (endogenous adoption, outcome/timing mismatch, or severe dilution); they should be skipped unless substantially redesigned around sharper treatments and better-aligned outcomes. The institute should start with **Idea 1** (most implementable, strong within-state design) and pursue **Idea 3** in parallel if GIS capacity is available.