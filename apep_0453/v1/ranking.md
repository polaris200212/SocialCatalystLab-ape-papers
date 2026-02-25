# Research Idea Ranking

**Generated:** 2026-02-25T13:55:40.924840
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 8144

---

### Rankings

**#1: Banking Infrastructure, Demonetization, and India's Structural Transformation**
- **Score: 71/100**
- **Strengths:** Uses a plausibly exogenous, nationwide shock with rich cross-sectional variation in *exposure costs* (banking access) and a long post period (through 2023), which is valuable for separating short-run disruption from medium-run reallocation/formalization. District-level sample size is large and nightlights are available consistently.
- **Concerns:** “Bank branch density” is strongly correlated with baseline development and likely with differential trends in electrification/urbanization—so the intensity DiD hinges on a demanding “parallel trends in intensity” assumption with only 4 clean pre-years. Annual VIIRS timing around a November 2016 shock mechanically attenuates the “2016” effect and mixes demonetization with later policies (notably GST in 2017).
- **Novelty Assessment:** **Moderate.** Demonetization has a definitive, high-profile causal literature (e.g., Chodorow-Reich et al. 2020) and some nightlights work already exists; the novelty is mainly (i) a different intensity channel (bank access vs currency replacement), (ii) longer horizon to 2023, and (iii) heterogeneity by pre-structure.
- **DiD Assessment (intensity DiD):**
  - **Pre-treatment periods:** **Marginal** (4 clean years: 2012–2015; 2016 is partially treated after Nov 8)
  - **Selection into treatment:** **Marginal** (bank density is pre-determined but not quasi-random; strongly related to development/state capacity)
  - **Comparison group:** **Marginal** (no never-treated units; identification comes from low- vs high-intensity districts)
  - **Treatment clusters:** **Strong** (~640 districts)
  - **Concurrent policies:** **Marginal** (GST July 2017; broader digitization/financial inclusion trends may correlate with bank density)
  - **Outcome-Policy Alignment:** **Marginal** (nightlights proxy overall activity; demonetization is a cash shock—plausible but not tightly mapped to “structural transformation” without complementary outcomes)
  - **Data-Outcome Timing:** **Marginal** (annual VIIRS: Nov–Dec 2016 is only ~2/12 of “2016”; “2017” includes post-remonetization and pre/post GST—needs careful event-time design)
  - **Outcome Dilution:** **Strong** (shock potentially affected a large share of transactions/economy, not a tiny subgroup)
- **Recommendation:** **PURSUE (conditional on: (i) explicit pre-trend/event-study showing flat differential trends by bank density; (ii) sensitivity to flexible district trends and state×year shocks; (iii) using monthly VIIRS or high-frequency outcomes if possible to align timing around Nov 2016; (iv) explicitly separating demonetization vs GST periods in the interpretation/design).**

---

**#2: Ayushman Bharat PM-JAY and District-Level Health Utilization**
- **Score: 60/100**
- **Strengths:** Substantively important and surprisingly under-evaluated at scale; HMIS (if accessible) offers high-frequency district-month outcomes with many pre-periods, enabling strong timing alignment and rich event-study diagnostics. Outcome-policy linkage is potentially tight for inpatient utilization.
- **Concerns:** Data feasibility is the binding constraint (HMIS accessibility issues; PM-JAY intensity measures not easily downloadable/clean). The proposed “intensity” (e-card issuance, empaneled hospitals) is likely endogenous to health demand, administrative capacity, or contemporaneous rollout effort—without a credible instrument/design refinement, selection threatens causal claims; COVID is a major confound unless the analysis window is constrained.
- **Novelty Assessment:** **High.** Despite PM-JAY’s scale, there is no settled, widely-cited causal district-level evaluation analogous to what exists for many smaller programs; strong publication/policy upside if executed well.
- **DiD Assessment (intensity DiD):**
  - **Pre-treatment periods:** **Strong** (HMIS reportedly 2008–present → many pre-periods)
  - **Selection into treatment:** **Marginal** (likely endogenous intensity; could become **Strong** only with a credible instrument such as pre-policy eligibility shares from SECC/baseline poverty cutoffs, or predetermined hospital supply measures)
  - **Comparison group:** **Marginal** (no never-treated districts; relies on differential intensity; credible if pre-trends are flat across intensity bins)
  - **Treatment clusters:** **Strong** (~640 districts)
  - **Concurrent policies:** **Weak** *as written* (COVID from Mar 2020 massively shifts utilization and reporting). This can be mitigated by **restricting to Sep 2018–Feb 2020** for main estimates and treating COVID as a separate regime.
  - **Outcome-Policy Alignment:** **Strong for IPD/hospitalizations**, **Marginal** for outcomes PM-JAY should not move much (e.g., immunization) unless via spillovers—must prioritize aligned outcomes.
  - **Data-Outcome Timing:** **Strong** (monthly outcomes; policy starts Sep 2018—can define post as Oct 2018 onward, avoiding partial-exposure months)
  - **Outcome Dilution:** **Marginal** (eligible population ~one-third; HMIS counts all users; dilution manageable if focusing on services PM-JAY targets and on poorer districts)
- **Recommendation:** **CONSIDER / PURSUE (conditional on: (i) confirming stable HMIS access + constructing reproducible district panels; (ii) obtaining/constructing downloadable district PM-JAY intensity and/or an instrument based on pre-determined eligibility; (iii) making Sep 2018–Feb 2020 the primary window, with COVID analyzed separately; (iv) focusing on tightly aligned outcomes like inpatient admissions/procedures rather than broad utilization aggregates).**

---

**#3: One Nation One Ration Card (ONORC) and State Economic Activity**
- **Score: 43/100**
- **Strengths:** Policy-relevant and genuinely novel from a causal standpoint; staggered adoption across many states/UTs is attractive on paper, and modern staggered DiD estimators could be used.
- **Concerns:** Identification is severely threatened because rollout timing is heavily entangled with COVID-era conditions and administrative capacity; the proposed outcome (state-level nightlights) is far upstream from the mechanism, and actual interstate portability utilization is low—creating severe outcome dilution and likely underpowered effects even if real.
- **Novelty Assessment:** **High** (credible causal evidence is scarce), but novelty cannot compensate for weak identification/outcome mapping as proposed.
- **DiD Assessment (staggered adoption):**
  - **Pre-treatment periods:** **Strong** (>=5 years pre for all states with VIIRS)
  - **Selection into treatment:** **Marginal** (adoption likely related to state capacity/political economy; not clearly exogenous)
  - **Comparison group:** **Marginal** (not-yet-treated comparisons only; early vs late states may differ systematically)
  - **Treatment clusters:** **Strong** (~36 states/UTs)
  - **Concurrent policies:** **Weak** (COVID lockdowns and recovery policies coincide with key adoption cohorts; likely first-order confounding)
  - **Outcome-Policy Alignment:** **Weak** (PDS portability → migration/consumption smoothing for a subset; aggregate state nightlights is a very indirect proxy)
  - **Data-Outcome Timing:** **Marginal** *only if monthly VIIRS is used aligned to adoption month*; **Weak** if annual is used (partial exposure and mixing within-year)
  - **Outcome Dilution:** **Weak** (interstate transactions reportedly tiny relative to population/economic activity; treated share of “state nightlights” effectively very small)
- **Recommendation:** **SKIP (unless redesigned)**. A salvage path would be to (i) use **ONORC transaction intensity** (interstate portability volumes) rather than adoption, (ii) focus on **high-migrant districts/corridors** and outcomes closer to the mechanism (migration flows, consumption/food security, labor market indicators), and (iii) avoid the COVID adoption window or explicitly model COVID with very strong auxiliary data—otherwise attribution is not credible.

---

**#4: RERA (Real Estate Regulation Act) and Construction Sector Formalization**
- **Score: 35/100**
- **Strengths:** Interesting, under-studied policy with real stakes; cross-state heterogeneity in implementation quality could, in principle, be leveraged.
- **Concerns:** The policy timing is packed into 2017–2018—exactly when GST, demonetization aftereffects, and later NBFC/real estate credit stress are also moving outcomes—making “concurrent policies” a likely dealbreaker. Outcomes proposed (urban nightlights, state-level PLFS aggregates) are noisy and only loosely mapped to “formalization,” with substantial dilution.
- **Novelty Assessment:** **Moderate-High** (limited econometric causal evidence), but the period is empirically “too crowded” for clean inference with this design/outcome set.
- **DiD Assessment (staggered adoption):**
  - **Pre-treatment periods:** **Strong** (nightlights pre-2017 available)
  - **Selection into treatment:** **Marginal** (implementation timing/quality likely correlated with state governance and real estate conditions)
  - **Comparison group:** **Marginal** (late implementers not obviously comparable; no natural never-treated)
  - **Treatment clusters:** **Strong** (many states)
  - **Concurrent policies:** **Weak** (GST and macro/credit shocks hit the same sector around the same time)
  - **Outcome-Policy Alignment:** **Weak** (nightlights/PLFS are indirect for “formalization”; would need administrative measures like project registrations, tax compliance, escrow usage)
  - **Data-Outcome Timing:** **Marginal/Weak** (annual outcomes blur effective dates; construction responds with lags)
  - **Outcome Dilution:** **Weak** (construction/real estate is a small share of state-level nightlights; “formalization” affects a subset within the sector)
- **Recommendation:** **SKIP** (unless the project pivots to tighter outcomes: RERA project registrations/completions, property transaction registries, GST/tax compliance in construction/real estate, or court/complaints data, with a design exploiting sharp implementation/quality discontinuities).

---

### Summary

This is a strong batch on **policy relevance and novelty**, but only **Idea 1** currently has a relatively credible path to identification with feasible data—though it still needs stronger pre-trend evidence and better timing alignment around Nov 2016. **Idea 3 (PM-JAY)** could become the most valuable project in the set if (and only if) data access is solved and intensity endogeneity/COVID are addressed with a tight pre-COVID window and an instrument or quasi-exogenous intensity source. The two staggered-adoption state DiDs (**ONORC, RERA**) have major “dealbreaker” risks (COVID and crowded-policy period, plus weak outcome alignment/dilution) and should not be pursued without substantial redesign.