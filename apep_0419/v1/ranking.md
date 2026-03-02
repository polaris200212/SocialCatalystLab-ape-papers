# Research Idea Ranking

**Generated:** 2026-02-19T18:13:47.476937
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 9845

---

### Rankings

**#1: Virtual Snow Days and the Weather-Absence Penalty for Working Parents**
- **Score:** 73/100  
- **Strengths:** Clever use of plausibly exogenous *within-state* snowfall shocks plus a policy “attenuator” (virtual snow-day authorization) gives a more credible design than a plain treated-vs-untreated DiD. CPS absence reason codes are unusually well-matched to the mechanism (weather/childcare-related absences).  
- **Concerns:** “Treatment” is authorization, not guaranteed district use—take-up and implementation heterogeneity could attenuate effects. Clean identification likely relies heavily on a small set of pre-COVID adopters (<10), and post-2020 schooling/labor-market disruptions are a serious confound.  
- **Novelty Assessment:** High. Snow days are studied for student outcomes, but the parental labor-supply/absence channel tied to *virtual snow-day laws* is largely unmined in economics.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (CPS monthly goes back decades; ample pre-2011)
  - **Selection into treatment:** **Marginal** (states with frequent closures may be more likely to adopt; snowfall-interaction helps but doesn’t eliminate endogeneity)
  - **Comparison group:** **Marginal** (non-adopting states may differ climatically/institutionally; mitigate via region×month fixed effects and snowfall-based DDD)
  - **Treatment clusters:** **Marginal** (pre-COVID “clean” treated states are <10; full sample has more)
  - **Concurrent policies:** **Marginal** (post-COVID remote-learning capacity and labor-market changes coincide with many adoptions; pre-2020 subsample is cleaner)
  - **Outcome-Policy Alignment:** **Strong** (policy affects school closure modality; outcome is parents’ work absence explicitly attributed to weather/childcare)
  - **Data-Outcome Timing:** **Marginal** (CPS absence is measured in the **reference week**; must align snowfall in that week and ensure policy is effective for that school year/winter)
  - **Outcome Dilution:** **Marginal** (only parents of school-age children in districts that actually use virtual days are affected; restrict sample to working parents with children and test stronger effects on heavy-snow days)
- **Recommendation:** **PURSUE (conditional on: primary analysis restricted to 2011–2019 adoptions; explicit validation of implementation/take-up where possible; careful timing alignment using CPS reference week + local snowfall; inference robust to small treated-cluster counts in the pre-COVID sample)**

---

**#2: State Drought Emergency Declarations and Agricultural Employment Adjustment**
- **Score:** 63/100  
- **Strengths:** Strong policy relevance and good data feasibility (QCEW + Drought Monitor are high-quality, high-frequency, county-level). A drought-shock interaction (policy regime × drought intensity) is the right conceptual approach.  
- **Concerns:** Adoption of formal frameworks is plausibly endogenous to prior drought experiences and political economy in arid states; “western vs non-western” comparisons are not credible without tight geographic restriction. Also, the “treatment” is the framework, but outcomes move when restrictions bind—timing and measurement of binding restrictions is critical.  
- **Novelty Assessment:** Moderate. Drought impacts are heavily studied, but the *labor market adjustment* channel tied specifically to *policy-triggered restrictions* is less crowded than crop-yield/price papers.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (QCEW available well before 2013–2015 adoptions)
  - **Selection into treatment:** **Marginal** (frameworks often adopted after salient drought episodes; mitigate by focusing within the West and using event-study + state-specific trends)
  - **Comparison group:** **Marginal** (best comparison is *within-West* late adopters / never-formal-framework states, not the full US)
  - **Treatment clusters:** **Marginal** (~15ish relevant states → inference needs care; consider county-level clustering + randomization inference)
  - **Concurrent policies:** **Marginal** (drought years trigger many simultaneous actions—water banking, emergency relief, local restrictions)
  - **Outcome-Policy Alignment:** **Strong** (binding water restrictions plausibly reduce irrigated production → labor demand in ag)
  - **Data-Outcome Timing:** **Marginal** (QCEW is quarterly; restrictions and drought intensity are weekly—must define exposure windows carefully, likely lagged)
  - **Outcome Dilution:** **Marginal** (restrictions primarily hit irrigated/subsector crops; county “ag” includes unaffected segments—could stratify by irrigated-share using USDA water/irrigation measures)
- **Recommendation:** **CONSIDER (conditional on: restricting to Western states; measuring “binding restriction” timing—not just declarations; pre-registering an event-study that tests pre-trends; exploring heterogeneity by irrigated share/crop mix)**

---

**#3: FEMA Pre-Disaster Mitigation Grants and Subsequent Weather Damage Reduction**
- **Score:** 48/100  
- **Strengths:** Extremely policy-relevant (billions in mitigation spending) and potentially high upside if a credible counterfactual can be built. Large-N county panel offers statistical power *if* treatment timing and exposure can be correctly defined.  
- **Concerns:** As written, identification is very vulnerable: grant receipt is endogenous to risk and capacity, and OpenFEMA typically does **not** give a clean “applied but rejected” universe with scores. Award date is not completion/operational date (major timing mismatch), and county-level damage is a noisy, diluted outcome for often-localized projects.  
- **Novelty Assessment:** Moderately high. There’s disaster economics work, but credible causal evaluation of PDM/BRIC effectiveness is not saturated—however, the empirical hurdles are real.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (long panels available)
  - **Selection into treatment:** **Weak** (high-risk/high-capacity places are more likely to apply/receive; “rejected applicants” control group is not feasible unless you obtain non-public FEMA application/score data)
  - **Comparison group:** **Weak** (non-recipient counties are systematically different absent an application-based design)
  - **Treatment clusters:** **Strong** (many counties)
  - **Concurrent policies:** **Marginal** (post-disaster HMGP, insurance changes, local investments confound; needs careful controls)
  - **Outcome-Policy Alignment:** **Marginal** (property damage is relevant, but NOAA Storm Events damage measures are noisy and may change in reporting)
  - **Data-Outcome Timing:** **Weak** (award ≠ project completion; benefits should start *after completion* and may phase in)
  - **Outcome Dilution:** **Weak** (a drainage project or safe-room program may affect a small area/subpopulation; county-event totals dilute effects)
- **Recommendation:** **SKIP (unless: you can obtain FEMA application/score data or another quasi-random assignment margin; project completion dates and geographies; and can measure outcomes at a finer spatial level or for directly affected assets/hazards)**

---

**#4: State Building Code Modernization and Severe Weather Property Damage**
- **Score:** 44/100  
- **Strengths:** The policy question is important and multi-state variation is attractive in principle. Could become compelling if you can isolate exposure to *new-code buildings* and credible adoption variation.  
- **Concerns:** The core design has major, likely fatal issues: code adoption often follows disasters (endogenous timing), enforcement is local and heterogeneous (state adoption ≠ compliance), and damages are driven by the existing building stock (not the marginal new-code stock), creating severe timing mismatch and outcome dilution.  
- **Novelty Assessment:** Moderate-to-low. Building codes and disaster losses have a meaningful existing literature (often engineering + some economics), and “national staggered code adoption” has been contemplated; the novelty hinges on doing it credibly, which is hard.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong**
  - **Selection into treatment:** **Weak** (adoption plausibly responds to recent storms/losses and insurer/lender pressure)
  - **Comparison group:** **Marginal** (states differ systematically; would need tight region/hazard-specific comparisons)
  - **Treatment clusters:** **Strong** (many states)
  - **Concurrent policies:** **Marginal** (post-disaster rebuilding, insurance reforms, mitigation programs coincide)
  - **Outcome-Policy Alignment:** **Weak** (codes affect *new/permitted construction*; outcome is total county damage across all vintages)
  - **Data-Outcome Timing:** **Weak** (benefits accrue as stock turns over; immediate “post-adoption” years should show little effect mechanically)
  - **Outcome Dilution:** **Weak** (new-code structures are a small share of exposed stock for many years)
- **Recommendation:** **SKIP (unless redesigned around building-vintage exposure—e.g., parcel/claims data with construction year, or restricting to post-adoption new builds and storms hitting those areas)**

---

**#5: State Winter Utility Disconnection Moratoriums and Cold-Weather Mortality**
- **Score:** 32/100  
- **Strengths:** High humanitarian and policy relevance; the hypothesized mechanism is direct (prevent shutoffs → maintain heat → reduce cold exposure). Data access for mortality and temperature is straightforward.  
- **Concerns:** Credible DiD variation is likely missing: many protections are old with few clean reforms; cross-state comparisons are confounded because colder states are precisely the ones that adopt protections. Outcomes are also heavily diluted (only a small share of households face shutoff risk) and hypothermia deaths are rare, creating power problems.  
- **Novelty Assessment:** Moderate. There’s related work on utility moratoria (especially COVID-era shutoff bans), but the cold-mortality-specific causal link is not well established—mostly because it’s empirically difficult, not because it’s ignored.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (for most states, the “treatment” predates modern data or has no sharp reform timing; reform-based design may have too few cases)
  - **Selection into treatment:** **Weak** (strong correlation with climate, demographics, and baseline winter preparedness)
  - **Comparison group:** **Weak** (warm vs cold states is not a credible counterfactual for winter mortality)
  - **Treatment clusters:** **Weak** (meaningful reforms likely <10)
  - **Concurrent policies:** **Marginal** (LIHEAP, weatherization, housing quality initiatives, emergency shelters)
  - **Outcome-Policy Alignment:** **Marginal** (hypothermia is aligned but rare; all-cause winter mortality is a noisy proxy with many channels)
  - **Data-Outcome Timing:** **Strong** (monthly mortality can align to moratorium season and cold snaps)
  - **Outcome Dilution:** **Weak** (policy affects the subset at imminent disconnection risk—likely far <10% of the population)
- **Recommendation:** **SKIP (unless you can obtain utility shutoff/arrears microdata and focus on directly affected households/zip codes, or identify a sharp, well-documented reform with many treated jurisdictions)**

---

### Summary

This is a relatively strong batch on *policy relevance* and creative use of administrative/public data, but most ideas face the common DiD failure modes: endogenous adoption, timing mismatch, and severe outcome dilution. **Idea 1** is the clearest “first to pursue” because it has a tightly matched outcome and a credible weather-shock interaction design (especially pre-COVID). **Idea 5** is the best “second bet” if you tightly restrict the geography and precisely measure when restrictions bind; Ideas 2–4 would require major redesign or non-public data to clear identification hurdles.