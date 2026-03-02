# Research Idea Ranking

**Generated:** 2026-02-16T15:00:08.674820
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7787

---

### Rankings

**#1: Compensating Danger: Workers' Compensation Laws and Industrial Safety in the Progressive Era — Evidence from Historical Newspaper Reports and Census Microdata (Idea 1)**
- **Score:** 76/100  
- **Strengths:** Very strong novelty from building a state-year safety-information outcome from digitized newspapers, paired with a classic high-stakes policy (workers’ comp) and rich staggered adoption variation across many states. The newspaper panel (1900–1920) gives enough pre-periods for serious event-study diagnostics, and the setting is policy-relevant (injury externalities, moral hazard, liability design).  
- **Concerns:** The headline outcome (newspaper accident coverage) is not a direct measure of accidents and may move because of digitization/composition, editorial choices, or litigation/insurance incentives that change reporting rather than underlying safety. Progressive Era confounding is a real threat (factory inspection regimes, unionization, safety regulations, industrial mix shifts) and the **secondary** census occupational-sorting outcome has very weak time-series leverage (1910 vs 1920 only), making pre-trend validation essentially impossible for that piece.  
- **Novelty Assessment:** **Moderately high.** Workers’ comp effects have a substantial literature (Fishback & Kantor and many others), but *text-as-data “accident salience/coverage”* as an outcome and linking it to adoption timing is genuinely novel; the occupational sorting angle is less novel substantively but new at micro scale for this policy.  
- **DiD Assessment (staggered adoption DiD via Callaway–Sant’Anna DR):**
  - **Pre-treatment periods:** **Strong** for the newspaper outcome (1900–1910+ pre for early adopters); **Weak** for occupational sorting (only one clean pre census in 1910).
  - **Selection into treatment:** **Marginal** (early adoption clearly correlated with industrialization/progressivism; conditional parallel trends is plausible but not guaranteed).
  - **Comparison group:** **Marginal** (late adopters/never adopters differ structurally from early adopters; needs careful reweighting + event-study balance).
  - **Treatment clusters:** **Strong** (large number of states adopting; inference much less fragile than typical policy DiD).
  - **Concurrent policies:** **Marginal** (many contemporaneous Progressive reforms plausibly affect accidents/coverage; must measure/adjust or narrow windows).
  - **Outcome-Policy Alignment:** **Marginal** (coverage intensity captures *salience/reporting* of accidents, not accidents themselves; the paper must frame this as “information environment” and/or validate against any available injury/fatality series where possible).
  - **Data-Outcome Timing:** **Marginal** (state-year aggregation risks partial exposure if effective dates are mid-year; should code exposure shares or drop adoption year).
  - **Outcome Dilution:** **Marginal** (policy affects workers, but coverage is averaged over all newspapers/pages; the relevant affected “share” depends on industrial composition and newspaper market mix—needs weighting/normalization and ideally industry-tagged accident mentions).
- **Recommendation:** **PURSUE (conditional on: (i) strong normalization/measurement strategy for newspaper coverage—e.g., accidents per 1,000 pages, state-newspaper fixed effects, digitization controls; (ii) event-study pre-trend evidence and placebo terms; (iii) a plan to handle concurrent Progressive Era policies; (iv) treat the occupational-sorting result as secondary unless you can add more time points or alternative pre-trend checks).**

---

**#2: The Ink Before the Law: Did Media Coverage of the Triangle Fire Accelerate Workers' Compensation Adoption? (Idea 2)**
- **Score:** 58/100  
- **Strengths:** A clear, compelling mechanism (national attention shock → reform acceleration) and a historically important, plausibly exogenous trigger event. If you can credibly isolate *exogenous* cross-state variation in exposure to Triangle coverage, this could be a neat contribution to the media-and-policy diffusion literature.  
- **Concerns:** The key identifying variation—coverage intensity by state—is very likely correlated with exactly the determinants of early adoption (urbanization, immigrant/garment-industry presence, progressivism, union strength). With only ~42 adoption events, survival/hazard models can be underpowered and sensitive to specification, and “DR” does not solve endogeneity if both the propensity and outcome models are misspecified in the same way.  
- **Novelty Assessment:** **Moderate.** Disaster-driven regulation and agenda-setting are studied in many contexts; Triangle Fire is famous, but a systematic cross-state quantitative media-exposure design is less common. The main novelty hinges on a truly credible exposure instrument.  
- **DiD Assessment:** *Not a DiD design as written (hazard/event-history); checklist not applicable.*  
- **Recommendation:** **CONSIDER (only if you can build a strong quasi-instrument for media exposure, e.g., pre-1911 newspaper network linkages/telegraph wire-service membership, distance-based exposure interacted with pre-period syndication patterns, or other predetermined connectivity measures; otherwise SKIP).**

---

**#3: Mothers' Pensions and Children's Economic Mobility: Evidence from IPUMS Linked Census Data, 1920–1940 (Idea 4)**
- **Score:** 53/100  
- **Strengths:** High policy relevance (early welfare state; intergenerational mobility) and potentially important external validity relative to single-state administrative studies. If the linked data are large enough, you could study heterogeneous effects (by baseline poverty, widowhood, local labor markets) and produce historically important evidence.  
- **Concerns:** The proposed treatment is at the state-adoption level but receipt is highly targeted, so naïve ITT estimates risk severe **outcome dilution** unless you restrict to plausibly eligible families (e.g., widowed mothers with children). Identification is threatened by strong selection (progressive states adopt earlier) and many coincident reforms and macro shocks between 1911–1935 and 1940; linkage quality/representativeness (match bias by name commonness, migration, race) is a serious feasibility and inference issue.  
- **Novelty Assessment:** **Moderate.** Mothers’ pensions have a known flagship long-run study (Aizer et al. 2016) and follow-on work exists, but a credible *national* design using linked census microdata could still be a contribution—if identification is tightened.  
- **DiD Assessment:** *Not a standard DiD as written (more like cohort-by-state exposure with long-gap outcomes); checklist not directly applicable.*  
- **Recommendation:** **CONSIDER (conditional on: (i) restricting the sample to likely-eligible households observed pre-treatment to reduce dilution; (ii) transparent linkage-rate diagnostics and bounding for linkage bias; (iii) a design that leverages within-state cohort exposure plus strong controls/state-specific cohort trends and falsification tests).**  

---

**#4: From Schoolhouse to Factory: State Child Labor Laws and Human Capital Accumulation, 1880–1920 (Idea 3)**
- **Score:** 42/100  
- **Strengths:** Very feasible data-wise (IPUMS is ideal for attendance/literacy; large samples) and the question is intrinsically important for human-capital policy history.  
- **Concerns:** Low novelty (this is among the most studied Progressive Era policy topics), and the proposed identification (“unconfoundedness given observables”) is not very credible because adoption/enforcement respond to economic structure and trends that also affect schooling and literacy. Enforcement heterogeneity is likely first-order and will contaminate “law on the books” estimates; with only a few census waves, validating trends is difficult unless you substantially redesign around sharper variation (e.g., enforcement shocks, bordering designs, or truly staggered event studies with better time resolution).  
- **Novelty Assessment:** **Low.** There is a deep literature on child labor laws, compulsory schooling, and human capital using similar periods and outcomes; “modern DR methods” is unlikely to be viewed as sufficient novelty on its own.  
- **DiD Assessment:** *Not a DiD as written; if converted to DiD, the sparse time periods would make pre-trends and timing alignment hard.*  
- **Recommendation:** **SKIP (unless you can locate a sharper, plausibly exogenous enforcement/policy discontinuity or substantially new data that changes the novelty/ID calculus).**

---

### Summary

This is a better-than-average batch on historical policy, with **Idea 1** standing out as the most promising because it combines genuinely new measurement (digitized newspaper safety salience) with strong staggered-adoption variation and enough pre-periods for credible diagnostics—though it needs careful handling of measurement and concurrent reforms. **Idea 2** is conceptually elegant but lives or dies on whether you can isolate plausibly exogenous variation in *media exposure* beyond underlying progressivism/industrial structure. **Ideas 3 and 4** face the classic historical-policy problem: selection and dilution; Idea 4 is potentially salvageable with an eligibility-restricted linked-sample design, while Idea 3 is too crowded and too endogenous without a sharper source of variation.