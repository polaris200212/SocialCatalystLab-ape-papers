# Research Idea Ranking

**Generated:** 2026-02-26T14:41:22.737929
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6999

---

### Rankings

**#1: Does Oil Hurt? Resource Dependence and Child Survival After the 2014 Price Crash**
- **Score: 74/100**
- **Strengths:** Clear, plausibly exogenous global price shock with strong cross-country “exposure” variation (pre-2014 oil rents) and ample pre/post years to run event studies and probe mechanisms via public spending. Outcomes (U5MR, immunization, health spending) are tightly linked to the hypothesized fiscal channel and highly policy-relevant for diversification/stabilization design.
- **Concerns:** Parallel trends is not automatic: high–oil-rent countries differ systematically (institutions, conflict risk, baseline health trajectories), and 2014–2016 also coincides with region-specific shocks (e.g., Ebola in West Africa; conflict escalation in parts of MENA) that may correlate with oil dependence. WDI mortality and maternal mortality series can be modeled/estimated (not purely vital registration), creating attenuation and comparability concerns.
- **Novelty Assessment:** **Moderate-high.** Commodity-price-shock designs are common, and “resource curse” is heavily studied, but the *specific* 2014 crash as a quasi-experiment for *health/child survival mechanisms* is less saturated than cross-sectional resource-curse work; novelty is real if executed with a serious event-study and mechanism validation.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (2005–2013 gives 9 pre-years)
  - **Selection into treatment:** **Strong** (baseline oil rents largely geological/predetermined; still, oil *dependence* can co-move with institutions—needs robustness)
  - **Comparison group:** **Marginal** (never-/low-oil countries differ; mitigate via region×year FE, income-group trends, matching/weighting, or restricting to plausible comparators like non-oil SSA)
  - **Treatment clusters:** **Strong** (≥25 high-oil-rent countries; and continuous treatment uses broad sample)
  - **Concurrent policies:** **Marginal** (Ebola, conflict, IMF programs/austerity may correlate with oil dependence; must control/exclude/stratify)
  - **Outcome-Policy Alignment:** **Strong** (health spending, immunization, U5MR directly reflect the fiscal/health-service channel)
  - **Data-Outcome Timing:** **Marginal** (WDI annual outcomes; shock begins mid-2014. **Mitigation:** define treatment as 2015 onward, treat 2014 as “partial exposure”/exclude, and show dynamic effects)
  - **Outcome Dilution:** **Strong** (macro-fiscal shock plausibly affects a large share of population/country-level outcomes)
- **Recommendation:** **PURSUE (conditional on: (i) event-study showing flat pre-trends; (ii) careful timing—post=2015+; (iii) robustness excluding Ebola-affected countries and major conflict escalations; (iv) mechanism checks linking oil crash → gov’t health spending → immunization → mortality rather than relying on mortality alone).**

---

**#2: Guns Over Vaccines: Military Spending Rigidity and Health Outcomes in Oil-Dependent States**
- **Score: 62/100**
- **Strengths:** Interesting mechanism refinement (“composition” of austerity) that is policy-relevant (budget rules, earmarking, security-state tradeoffs) and can, in principle, be tested using spending shares plus health service proxies (immunization).
- **Concerns:** The third-difference dimension (“high military spending share/rigidity”) is plausibly endogenous to unrest/conflict and governance—precisely things that also affect child mortality and immunization—so the DDD may *reduce* credibility unless you can argue quasi-random rigidity (e.g., constitutional rules, external threats, legacy procurement contracts). WDI military spending coverage/quality is uneven; missingness may be nonrandom and could drive results.
- **Novelty Assessment:** **Moderate.** “Guns vs butter” is classic, and crisis-driven compositional shifts have been studied, but tying the 2014 oil crash to *health* via *military budget rigidity* is less common; novelty depends on demonstrating truly exogenous rigidity.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (same 2005–2013 pre)
  - **Selection into treatment:** **Marginal** (oil dependence is strong; “high military share/rigidity” likely selected/endogenous)
  - **Comparison group:** **Marginal** (high- vs low-military oil states are structurally different; need strong controls or an instrument for rigidity)
  - **Treatment clusters:** **Strong** (country clusters sufficient in principle)
  - **Concurrent policies:** **Marginal** (conflict/austerity/IMF programs may co-move with military prioritization)
  - **Outcome-Policy Alignment:** **Marginal** (spending composition aligns well; mapping to child outcomes is plausible but more indirect than Idea 1—needs immunization/service delivery as nearer outcomes)
  - **Data-Outcome Timing:** **Marginal** (annual; same partial-2014 exposure issue—prefer post=2015+)
  - **Outcome Dilution:** **Strong** (national budget composition plausibly affects broad population outcomes)
- **Recommendation:** **CONSIDER (only if you can: (i) operationalize “rigidity” using pre-determined rules or plausibly exogenous predictors; (ii) address missing/nonrandom military spending data; (iii) focus on nearer-term service outcomes like immunization and facility delivery, not just mortality).**

---

**#3: Petrodollars and Protests: Oil Revenue Shocks and Social Unrest in Developing Countries**
- **Score: 52/100**
- **Strengths:** Policy-relevant question (stability risks of fiscal dependence) and the same exposure design can be informative if paired with high-frequency, credible unrest data.
- **Concerns:** Outcome measurement is the core problem: WGI governance indicators are slow-moving, perception-based, and often cannot detect short-run shocks; that is a major outcome–policy mismatch for “protests/unrest.” The proposal also flags that better event data (ACLED/GDELT) may be inaccessible; without them, identification may be “clean” on paper but uninformative in practice.
- **Novelty Assessment:** **Moderate-low.** Commodity shocks and political instability/conflict/protest are well-trodden; novelty would come from unusually good measurement and mechanism separation (austerity → services → unrest), which is not yet secured here.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (ample pre)
  - **Selection into treatment:** **Strong** (oil dependence plausibly predetermined)
  - **Comparison group:** **Marginal** (oil vs non-oil differ; can mitigate with stratification/weighting)
  - **Treatment clusters:** **Strong** (many countries)
  - **Concurrent policies:** **Marginal** (many contemporaneous geopolitical shocks affect unrest, with heterogeneous incidence)
  - **Outcome-Policy Alignment:** **Weak** *(dealbreaker as currently written)* — WGI is not a direct measure of protests/unrest; it’s a broad governance perception index. CNTS protest indicators can work, but only if coverage/definitions are credible and consistent.
  - **Data-Outcome Timing:** **Strong/Marginal** (annual is okay for governance, but too coarse for protest dynamics; attenuation risk)
  - **Outcome Dilution:** **Strong** (country-level unrest affects country-level outcomes)
- **Recommendation:** **SKIP (unless you secure high-quality event protest/unrest data and use outcomes that directly measure unrest—e.g., protest events, riots, strikes—then it becomes a viable “CONSIDER”).**

---

**#4: The Oil Crash and Nigerian Children: Subnational Evidence from DHS**
- **Score: 45/100**
- **Strengths:** Subnational Nigeria focus is substantively compelling and DHS outcomes are well-aligned with child health mechanisms; geographic treatment assignment (oil-producing states) is plausibly exogenous.
- **Concerns:** The DiD is not credible as a standalone: only one clear pre-period at the state level (2013) and only **9 treated states** (<10 clusters) makes inference fragile and pre-trends essentially untestable. Nigeria also has strong region-specific concurrent shocks (notably conflict/insecurity in the North East) that differentially affect “control” states and could mechanically generate spurious DiD estimates.
- **Novelty Assessment:** **Moderate.** Nigeria oil/fiscal dependence is heavily studied, but DHS-based subnational health impacts of the 2014 crash are less common; still, novelty cannot compensate for weak design.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** *(dealbreaker)* (state-level: effectively 1 pre wave, 2013)
  - **Selection into treatment:** **Strong** (oil geography)
  - **Comparison group:** **Marginal** (non-oil Nigerian states differ a lot; north/south, conflict exposure)
  - **Treatment clusters:** **Weak** *(dealbreaker)* (9 treated states)
  - **Concurrent policies:** **Marginal/Weak** (major security and macro shocks differentially hit regions)
  - **Outcome-Policy Alignment:** **Strong** (DHS health outcomes match mechanism)
  - **Data-Outcome Timing:** **Strong** (2018/2024 are clearly post-2014 shock)
  - **Outcome Dilution:** **Strong** (state-level fiscal shock plausibly affects broad state population)
- **Recommendation:** **SKIP as standalone; CONSIDER only as a supplementary/triangulation exercise inside Idea 1 (e.g., micro validation of immunization/service channels), not as the main identification.**

---

**#5: Nigeria’s 2023 Fuel Subsidy Removal and Household Welfare**
- **Score: 28/100**
- **Strengths:** Extremely policy-relevant reform with large first-stage price changes; potentially important distributional impacts.
- **Concerns:** Two-period DiD (2018 vs 2024) cannot test pre-trends and is overwhelmed by massive concurrent shocks (COVID-19, inflation/exchange-rate crisis, insecurity, other reforms). “Exposure” definitions (urbanization/transport dependence/distance to depots) are likely endogenous proxies for development and pre-existing trends, making selection into treatment very weak.
- **Novelty Assessment:** **High topic novelty (very recent)**, but novelty does not rescue identification/data limitations here.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** *(dealbreaker)* (only one pre point)
  - **Selection into treatment:** **Weak** *(dealbreaker)* (exposure index likely correlated with underlying trends and levels)
  - **Comparison group:** **Marginal** (high- vs low-exposure states structurally different)
  - **Treatment clusters:** **Marginal** (36 states exist, but effective treatment variation is not clearly exogenous)
  - **Concurrent policies:** **Weak** *(dealbreaker)* (2018–2024 spans multiple major shocks)
  - **Outcome-Policy Alignment:** **Marginal** (fuel price affects welfare/health indirectly; DHS outcomes are slow-moving and multi-causal)
  - **Data-Outcome Timing:** **Marginal/Weak** (subsidy removal May 2023; DHS 2024 fieldwork timing varies—many observations may have partial exposure)
  - **Outcome Dilution:** **Marginal** (policy is broad, but measurable impacts on DHS health outcomes within ~months may be limited/noisy)
- **Recommendation:** **SKIP (unless you obtain high-frequency household expenditure/price data with multiple pre-periods—e.g., phone surveys, market prices—and a stronger design).**

---

### Summary

This batch has **one clearly fundable lead idea**: **Idea 1** is the most promising because it combines a major exogenous shock, large-N panel data, and outcomes tightly linked to the fiscal-health mechanism—with enough pre-periods to actually test identification. **Ideas 3 and 5 fail on critical DiD criteria (outcome alignment and/or pre-trends/concurrent shocks), and Ideas 4 and 5 have “Weak” dealbreakers** as standalone projects; **Idea 2** is potentially publishable but only if “military rigidity” can be made plausibly exogenous and the spending data issues are solved.