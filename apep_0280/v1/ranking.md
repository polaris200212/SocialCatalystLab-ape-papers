# Research Idea Ranking

**Generated:** 2026-02-13T15:02:34.796265
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 8747

---

### Rankings

**#1: From Workplace to Living Room — Do Indoor Smoking Bans Cultivate Anti-Smoking Norms Beyond Their Legal Reach?**
- **Score:** 73/100
- **Strengths:** Large, long-running microdata (BRFSS) with many treated states and long pre-periods makes this a feasible, well-powered staggered-adoption design. Outcomes (smoking status, intensity, quit attempts) tightly match the hypothesized “internalization/norms” channel.
- **Concerns:** Adoption is plausibly endogenous to pre-existing anti-smoking sentiment and declining smoking trends; “never-treated” states are regionally/politically different, raising parallel-trends risk. Other contemporaneous tobacco policies (tax hikes, media campaigns, cessation coverage) may coincide with bans and confound effects if not carefully controlled.
- **Novelty Assessment:** **Moderate.** There is a huge literature on smoking bans and smoking/health outcomes; however, the explicit “beyond-venue norms/internalization over time” framing is less saturated and could add value if you can show distinctive predictions (e.g., delayed/growing effects, changes in home rules, quit attempts among baseline smokers).
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (BRFSS pre-period is long for all cohorts; early adopters still have many pre-years).
  - **Selection into treatment:** **Marginal** (states often adopt as part of broader tobacco-control climates; not plausibly exogenous).
  - **Comparison group:** **Marginal** (never-treated states disproportionately differ—often more Southern/low-regulation—so credibility hinges on pre-trends + covariate balance + robustness).
  - **Treatment clusters:** **Strong** (≈28+DC treated; inference at state level is workable).
  - **Concurrent policies:** **Marginal** (taxes, cessation benefits, tobacco-control spending, local bans pre-dating state bans; must measure/control and run sensitivity checks).
  - **Outcome-Policy Alignment:** **Strong** (BRFSS smoking, intensity, quit attempts directly capture voluntary smoking behavior—well aligned with “norm internalization” vs “pure relocation”).
  - **Data-Outcome Timing:** **Marginal** (BRFSS interviews occur throughout the year; many bans take effect mid-year—“treated year” may have partial exposure unless you use month-of-interview or define exposure windows).
  - **Outcome Dilution:** **Marginal-to-Strong** (prevalence effects dilute across non-smokers, but quit attempts/intensity can be analyzed among baseline smokers, greatly reducing dilution).
- **Recommendation:** **PURSUE (conditional on: using month-of-interview to construct full-exposure measures or dropping partial-exposure first years; explicitly controlling for cigarette taxes, tobacco-control funding, and major cessation-coverage expansions; demonstrating clean pre-trends and running “leave-one-region-out”/border-state robustness)**

---

**#2: Legislating Parental Responsibility — Do Social Host Liability Laws Change Youth Drinking Norms?**
- **Score:** 60/100
- **Strengths:** Interesting mechanism (parent/host liability as social enforcement) with long policy variation and multiple outcomes (self-reported YRBS and objective fatality data). Potential to triangulate “norms” via teen behaviors plus alcohol-involved teen crashes/fatalities.
- **Concerns:** YRBS is **biennial and not a complete state panel** (participation varies), which can sharply reduce usable treated/control clusters and complicate event studies. Social-host laws often co-move with other youth-alcohol policies (zero-tolerance enforcement, compliance checks, MIP changes), making confounding a serious risk.
- **Novelty Assessment:** **Moderate.** Alcohol policy is heavily studied, but social-host liability gets less attention than taxes/MLDA; still, it is not entirely new, and identification will matter more than novelty here.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (policy adoption spans decades; outcomes available for long windows via FARS/WONDER; YRBS from 1991).
  - **Selection into treatment:** **Marginal** (states may adopt in response to teen drinking/drunk-driving concerns—potentially trend-responsive).
  - **Comparison group:** **Marginal** (plausible within-region comparisons exist, but states differ in enforcement capacity/culture).
  - **Treatment clusters:** **Marginal** (31+ states adopt, but effective clusters may be far smaller once restricted to balanced YRBS participation; FARS is better here).
  - **Concurrent policies:** **Marginal** (need a convincing policy-controls set and/or designs leveraging within-policy features/intensity).
  - **Outcome-Policy Alignment:** **Strong** (teen binge drinking and alcohol-involved teen crashes are directly related to the targeted behavior).
  - **Data-Outcome Timing:** **Marginal** (**YRBS is typically fielded in spring (often Feb–May)**; if laws take effect July 1, the “adoption year” YRBS wave is mechanically pre-treatment—must align by using the *next* YRBS wave or focusing on annual outcomes like FARS).
  - **Outcome Dilution:** **Marginal** (law targets hosting contexts; not all teen drinking occurs at house parties—effects on overall binge prevalence may be diluted).
- **Recommendation:** **CONSIDER (conditional on: anchoring the main analysis on FARS/WONDER annual outcomes to avoid YRBS timing gaps; carefully constructing a consistent YRBS panel if used; pre-specifying a narrow set of concurrent alcohol-policy controls and showing robustness to alternative policy bundles)**

---

**#3: From “Snitching” to Saving — Do Good Samaritan Laws Change Social Norms Around Drug Treatment-Seeking?**
- **Score:** 45/100
- **Strengths:** High policy relevance in an ongoing crisis, with near-universal adoption and clear legal dates (PDAPS). TEDS has a long time series and a potentially informative mechanism outcome (self vs criminal-justice referral).
- **Concerns:** The biggest threat is **endogenous adoption during sharply changing overdose trends** plus massive, overlapping opioid-policy changes (naloxone access laws, PDMP strengthening, prescribing limits, Medicaid expansion, fentanyl waves). Also, “self-referral share” is an indirect proxy for “norms,” and TEDS reporting/comparability across states can be uneven.
- **Novelty Assessment:** **Low-to-Moderate.** Many papers already estimate GSL effects on overdoses; shifting to referral-source composition is a novel angle, but the core policy is extensively studied and the mechanism proxy is debatable.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong (for TEDS as primary)** / **Weak (for CDC 2015–2024 mortality as primary)**.
  - **Selection into treatment:** **Weak** (adoption plausibly responds to worsening overdose conditions and advocacy pressure that tracks crisis severity).
  - **Comparison group:** **Marginal-to-Weak** (very few never-treated states; identification relies on not-yet-treated late adopters, which may be systematically different).
  - **Treatment clusters:** **Strong** (≈47 treated).
  - **Concurrent policies:** **Weak** (overdose-era policy stacks are dense and co-timed; confounding risk is extreme).
  - **Outcome-Policy Alignment:** **Marginal** (GSL directly reduces legal risk of calling 911; linking that to *treatment* self-referrals requires a longer, less direct behavioral chain).
  - **Data-Outcome Timing:** **Marginal** (annual data can be aligned to effective dates, but many changes are mid-year and crisis dynamics are fast).
  - **Outcome Dilution:** **Marginal-to-Weak** (GSL directly affects overdose-call situations; TEDS admissions reflect a broader population and many pathways into treatment).
- **Recommendation:** **SKIP** (unless redesigned around a sharper source of exogenous variation—e.g., court rulings, sudden enforcement guidance changes, or discontinuities in eligibility/scope that create more credible quasi-random exposure)

---

**#4: Can You Ban Stigma? State Anti-Conversion Therapy Bans and LGBTQ+ Mental Health**
- **Score:** 35/100
- **Strengths:** Important policy question with clear relevance; conversion-therapy bans are a salient, values-driven intervention where “signal effects” are conceptually plausible. Policy timing and adoption dates are well documented.
- **Concerns:** The proposed outcomes are largely **population-wide**, but the affected group is primarily LGBTQ youth—a small share of the population—creating severe dilution and interpretability problems. Adoption is highly correlated with broader LGBTQ-friendly policy bundles and underlying attitudinal trends, making causal attribution very difficult without subgroup-identified outcomes.
- **Novelty Assessment:** **Moderate.** There are fewer papers than in tobacco/opioids, but research on LGBTQ policies and mental health is sizable; this specific policy is not untouched, and the “signal” framing doesn’t rescue weak measurement/ID.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (BRFSS/WONDER offer long panels).
  - **Selection into treatment:** **Weak** (adoption in progressive states with pre-trending acceptance and different mental-health trajectories).
  - **Comparison group:** **Marginal** (never/late adopters differ structurally in politics, religion, and healthcare systems).
  - **Treatment clusters:** **Strong** (~22 treated).
  - **Concurrent policies:** **Weak** (anti-bullying laws, nondiscrimination protections, Medicaid expansion, mental-health initiatives, broader LGBTQ rights changes co-move).
  - **Outcome-Policy Alignment:** **Weak** as proposed (BRFSS general mental-health days largely reflect non-LGBTQ respondents; suicide mortality by age is not LGBTQ-identified in WONDER).
  - **Data-Outcome Timing:** **Strong-to-Marginal** (annual outcomes can be lagged to ensure exposure; timing is not the main issue).
  - **Outcome Dilution:** **Weak** (LGBTQ youth are likely <10% of the state youth population; conversion-therapy exposure is smaller still; population means will severely attenuate effects).
- **Recommendation:** **SKIP** (unless the design is rebuilt around LGBTQ-identified outcomes with adequate pre-periods—e.g., consistent state YRBS sexual-orientation modules, or other datasets with stable subgroup IDs—and a strategy to separate the ban from the broader LGBTQ-policy package)

---

**#5: The Internalization Puzzle — Do Mandatory Calorie Labels Change Dietary Norms or Just Dining Choices?**
- **Score:** 20/100
- **Strengths:** Conceptually interesting “nudge vs norms” question with clear policy interest, especially for information disclosure regulation. Early adopters exist pre-2018.
- **Concerns:** Treatment is primarily **city/county-level**, but outcomes are **state-level** (BRFSS obesity/diet), causing major mismeasurement and attenuation; the 2018 federal mandate contaminates controls. Outcomes like BMI move slowly and are far from the policy margin (restaurant menu info), yielding poor alignment and heavy dilution.
- **Novelty Assessment:** **Low.** Menu labeling has been studied extensively in public health and economics; the “norms” framing is not enough to overcome weak identification/data match here.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** (available, but meaningful treated-vs-control contrast collapses post-2018).
  - **Selection into treatment:** **Weak** (early adopters are atypical, health-progressive cities/states).
  - **Comparison group:** **Weak** (state-level comparisons won’t capture city policy exposure cleanly).
  - **Treatment clusters:** **Weak** (effective treated units pre-2018 are far fewer than 20).
  - **Concurrent policies:** **Marginal-to-Weak** (other obesity initiatives co-occur in early-adopting localities).
  - **Outcome-Policy Alignment:** **Weak** (BMI/obesity and broad diet proxies are distant from menu-label exposure; strongest outcomes would be item purchases/calories per transaction).
  - **Data-Outcome Timing:** **Weak** (behavioral response is immediate; obesity outcomes are lagged and noisy; plus partial-year exposures).
  - **Outcome Dilution:** **Weak** (only a share of residents eat at covered chain restaurants; state averages dilute heavily).
- **Recommendation:** **SKIP** (unless you can move to transaction-level purchase data or restaurant receipts at the city level with a clean untreated comparison set)

---

### Summary

This batch has **one clearly actionable proposal**: the smoking-ban/BRFSS design is feasible and (with careful timing and confound controls) potentially publishable despite a crowded literature. The social-host liability idea is the best “second-tier” option but needs serious work on **YRBS panel completeness and timing** plus confounding from other alcohol policies. The remaining three proposals have **dealbreaker identification/measurement problems** as written—especially **outcome dilution and confounding policy bundles** (conversion therapy; Good Samaritan laws) and severe **treatment mismeasurement** (calorie labeling).