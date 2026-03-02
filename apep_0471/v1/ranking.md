# Research Idea Ranking

**Generated:** 2026-02-27T11:18:45.515400
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7982

---

### Rankings

**#1: Does Welfare Simplification Encourage Entrepreneurship? Universal Credit Rollout and Firm Formation in the UK**
- Score: **71/100**
- Strengths: Very high-potential setting (large-N, plausibly administrative staggered rollout across ~300 LAs) with unusually rich, high-frequency outcomes (monthly Companies House). Clear policy relevance given ongoing UC reform for the self-employed (MIF).
- Concerns: Pre-period is short for many cohorts and rollout timing may correlate with local “readiness” or labour-market conditions (selection). Biggest risk is **outcome dilution**: UC affects claimants, while aggregate LA firm formation is broad—effects could be mechanically small and hard to interpret if null.
- Novelty Assessment: **High** on the entrepreneurship/self-employment margin specifically; UC has a sizable causal literature on hardship/food banks/mental health and some labour-market outcomes, but far less on entrepreneurship and essentially none using Companies House at LA-month frequency in a causal design.
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Marginal** (you cite ~2013–2015 before full service; that’s only ~3 years, and some LAs adopt early in 2015–16 so the effective pre-window can be tight)
  - Selection into treatment: **Marginal** (rollout is administrative, but not random; may track IT readiness, Jobcentre capacity, or local conditions)
  - Comparison group: **Strong** (later-treated LAs are a natural comparison set; large number of cohorts enables modern staggered DiD with good overlap checks)
  - Treatment clusters: **Strong** (hundreds of LAs; many cohorts)
  - Concurrent policies: **Marginal** (UK-wide shocks and welfare reforms occur in this era; time FE help, but any *differential* coincident local initiatives could bias)
  - Outcome-Policy Alignment: **Marginal** (APS self-employment aligns well; Companies House incorporations capture a subset of “entrepreneurship” and not necessarily UC-eligible self-employment)
  - Data-Outcome Timing: **Strong/Marginal** (Companies House is monthly and lines up with rollout months; APS is annual/rolling so first “treated year” may contain partial exposure—needs careful timing rules)
  - Outcome Dilution: **Marginal** (UC exposure is a minority of residents; you’ll likely estimate an ITT on LA-level totals. Mitigate by focusing on sectors/types of incorporations plausibly started by low-income/self-employed claimants, or by using outcomes closer to claimant populations if available)
- Recommendation: **PURSUE (conditional on: (i) demonstrating no differential pre-trends using event studies with multiple pre-period bins; (ii) a credible argument/diagnostic for rollout timing exogeneity; (iii) an explicit plan to address dilution—e.g., sectoral outcomes, low-capital industries, or alternative claimant-proximate outcomes; (iv) clear timing conventions for APS vs monthly rollout)**

---

**#2: The Living Wage Bite: How the National Living Wage Reshaped Local Firm Dynamics**
- Score: **66/100**
- Strengths: Good policy relevance and a plausible mechanism linking wage floors to entry/exit (creative destruction), with feasible data (ASHE-based bite + Companies House). Long pre-period is available, improving credibility of parallel-trends diagnostics.
- Concerns: Identification hinges on a **dose-response DiD** where “bite” is correlated with many persistent local traits (industrial structure, productivity, long-run decline), so parallel trends is a real empirical hurdle. Novelty is moderate because UK minimum wage effects (including some firm outcomes) are already studied.
- Novelty Assessment: **Medium-Low**. There is extensive minimum-wage literature and some UK firm-side work; the specific LA-level firm entry/exit angle is less saturated than employment effects, but it’s not “white space.”
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Strong** (you can plausibly assemble ≥5 years pre-2016)
  - Selection into treatment: **Marginal** (bite is predetermined but not exogenous—low-wage places differ systematically)
  - Comparison group: **Strong/Marginal** (all LAs contribute; credibility depends on whether high-bite vs low-bite areas can be shown to trend similarly pre-2016)
  - Treatment clusters: **Strong** (hundreds of LAs)
  - Concurrent policies: **Marginal** (Brexit referendum period, sector shocks, other labour-market changes; mostly national but could differentially hit low-wage places)
  - Outcome-Policy Alignment: **Strong** (firm births/deaths are directly linked to cost shocks from NLW)
  - Data-Outcome Timing: **Strong** (April 2016 start; Companies House monthly outcomes can be aligned cleanly; ASHE is annual—bite measurement is pre (2015) so fine)
  - Outcome Dilution: **Marginal** (NLW affects a nontrivial share in high-bite areas, but still a subset; effects on total firm dynamics may be modest)
- Recommendation: **CONSIDER (strongly)** if you can (i) show very tight pre-trend fit; (ii) run robustness to local linear trends / interactive FE; (iii) use sectoral heterogeneity where bite is mechanically strongest.

---

**#3: The Immigration Cliff: Brexit, EU Worker Loss, and Firm Dynamics in Exposed Local Labour Markets**
- Score: **58/100**
- Strengths: Policy relevance is extremely high, and the shift-share structure is a reasonable way to extract quasi-experimental variation in exposure. Firm dynamics angle is more novel than wages/employment alone.
- Concerns: The **COVID overlap (2020–2022)** is a first-order confound for firm entry/exit and vacancies; separating a 2021 immigration regime effect from pandemic recovery and policy supports is very hard. Also, LA×sector EU-share measures from surveys can be noisy (weak first-stage / measurement error in exposure).
- Novelty Assessment: **Medium**. Brexit and immigration restriction effects are heavily studied; firm entry/exit is less studied but not untouched. The main incremental value would come from especially credible separation from COVID and careful validation of the shift-share design.
- Recommendation: **CONSIDER** only with a concrete mitigation strategy for COVID confounding (e.g., designs leveraging sector-specific reopening constraints, falsification tests on pre-2020, alternative shocks/periodization, or complementary admin data on migrant workers). Otherwise, the identification risk is high.

---

**#4: Punishing Poverty or Pushing Into Work? The Employment Effects of Council Tax Support Localisation**
- Score: **45/100**
- Strengths: Large number of LAs and a salient policy lever (local benefit generosity) with intensity variation that, in principle, could identify behavioural responses.
- Concerns: Multiple potential dealbreakers: (i) **selection into intensity** (cuts likely chosen due to fiscal stress and local trends), (ii) **major concurrent reforms in 2013** (e.g., other welfare/housing changes) that plausibly co-move with CTS choices and labour outcomes, and (iii) novelty is low given recent IFS work.
- Novelty Assessment: **Low**. This policy has been analyzed, and you already note a comprehensive IFS causal study (Jan 2026). To beat that, you’d need a sharply different outcome and cleaner identification story.
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Strong** (ample pre-2013 data exist)
  - Selection into treatment: **Weak** (local scheme generosity/cuts are plausibly endogenous to local fiscal conditions and labour-market trajectories)
  - Comparison group: **Marginal** (passthrough vs cutting LAs likely differ systematically)
  - Treatment clusters: **Strong** (hundreds of LAs)
  - Concurrent policies: **Weak** (2013 is crowded with overlapping welfare/housing reforms; differential exposure is likely)
  - Outcome-Policy Alignment: **Strong/Marginal** (employment/claimant counts are relevant, but CTS is targeted—aggregate employment rates are noisy proxies)
  - Data-Outcome Timing: **Strong** (April 2013 start; claimant counts monthly)
  - Outcome Dilution: **Weak** (working-age CTS recipients are a modest share of the full working-age population; aggregate LA employment rates will substantially dilute effects)
- Recommendation: **SKIP** (unless you can credibly isolate exogenous variation in CTS generosity—e.g., an instrument based on pre-2013 mechanical funding rules—and use outcomes tightly tied to the treated population).

---

**#5: From Welfare to Enterprise? Scotland's Devolved Employment Services and Self-Employment Outcomes**
- Score: **40/100**
- Strengths: Clear and interesting policy contrast (voluntary/holistic vs mandatory/sanctions-driven) and high policy salience for devolved governance.
- Concerns: Fundamental inference problem: effectively **two treated clusters (Scotland vs England)**, making standard DiD inference unreliable regardless of LA-level outcome measurement. Any credible design likely needs a different identification strategy (e.g., spatial RDD at the border with strong assumptions and limited power).
- Novelty Assessment: **Medium**. The topic is not saturated, but novelty cannot compensate for the severe identification/inference limits in the proposed setup.
- DiD Assessment (if applicable):
  - Pre-treatment periods: **Strong** (data exist pre-2018)
  - Selection into treatment: **Strong** (institutional devolution timing is largely external to short-run local outcomes)
  - Comparison group: **Marginal** (England is not a “similar” control for Scotland without much stronger structure; border-LA restriction helps comparability but not inference)
  - Treatment clusters: **Weak** (effective number of clusters is ~2 at the policy level)
  - Concurrent policies: **Marginal** (other Scotland-specific policies and COVID-era differences can contaminate)
  - Outcome-Policy Alignment: **Marginal** (employment services plausibly affect employment/self-employment, but Companies House incorporations are a noisy proxy for the program’s target group)
  - Data-Outcome Timing: **Strong** (April 2018 start; outcomes can be measured after full exposure windows)
  - Outcome Dilution: **Marginal/Weak** (program targets a subset of jobseekers; aggregate LA self-employment and firm formation dilute effects)
- Recommendation: **SKIP** (unless redesigned as a border discontinuity with credible bandwidth/power and a convincing plan for inference—still hard).

---

### Summary

Only **Idea 1** is both highly novel and plausibly identifiable at scale, but it needs careful work on rollout endogeneity, timing (APS), and especially **outcome dilution**. **Idea 4** is the most “workhorse credible” if you can win the pre-trends battle, but it is less novel. Ideas **3 and 5** face major identification obstacles (2013 concurrent reforms/endogenous intensity for CTS; effectively N=2 for Scotland), and should not be prioritized without substantial redesign.