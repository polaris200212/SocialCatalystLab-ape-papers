# Research Idea Ranking

**Generated:** 2026-02-26T17:43:50.120003
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7810

---

### Rankings

**#1: Priced Out of Care — Medicaid Wage Competitiveness and Home Care Workforce Fragility (Idea 1)**
- **Score: 74/100**
- **Strengths:** Clever “stress-test” design: a *pre-determined* cross-state wage competitiveness measure interacted with an arguably exogenous aggregate shock (COVID) and high-frequency administrative outcomes that tightly match the mechanism (provider supply/entry/exit). The within-state **Medicaid vs Medicare** placebo is an unusually strong falsification angle for this space.
- **Concerns:** Biggest risk is that the 2019 wage ratio proxies for broader state features (politics, LTC system structure, urbanicity, nursing home reliance) that also shape COVID-era disruption and recovery, so the interaction may not be as “as-good-as-random” as hoped. Also, the pre-period is only ~2 years in T‑MSIS as written; that limits credibility of parallel-trends tests for a design that leans heavily on pre-trends.
- **Novelty Assessment:** **High.** There is a large Medicaid HCBS/workforce literature and many COVID-era papers, but *this* “pre-existing monopsony markdown × aggregate shock” framing + T‑MSIS provider supply + Medicaid-vs-Medicare within-state falsification is meaningfully less mined than standard rate-change or minimum-wage DiDs.
- **DiD Assessment (continuous-treatment event study):**
  - **Pre-treatment periods:** **Marginal** (Jan 2018–Feb 2020 ≈ 26 months; lots of observations, but not long-run years)
  - **Selection into treatment:** **Strong** (treatment is fixed at 2019 and pre-determined relative to COVID; remaining concern is correlation with omitted state characteristics)
  - **Comparison group:** **Marginal** (high-ratio states are not “similar” mechanically; need rich controls/diagnostics and possibly region×time or state trends sensitivity)
  - **Treatment clusters:** **Strong** (≈50 states; continuous treatment)
  - **Concurrent policies:** **Marginal** (COVID-era Medicaid HCBS appendices, ARPA, emergency orders, nursing-home spillovers—must document and test sensitivity)
  - **Outcome-Policy Alignment:** **Strong** (provider counts/entry/exit and beneficiaries served in HCBS are direct objects affected by wage competitiveness)
  - **Data-Outcome Timing:** **Strong** (monthly outcomes; COVID shock starts March 2020 so “treated months” are truly post-shock—still verify billing/processing lags)
  - **Outcome Dilution:** **Strong** (outcomes are defined on HCBS providers/claims—affected population is essentially the whole analytic sample)
- **Recommendation:** **PURSUE (conditional on: (i) extending pre-period earlier than 2018 if feasible in T‑MSIS/legacy MSIS or showing robustness with alternative pre-trend checks; (ii) explicitly addressing omitted-variable risk with rich state covariates, region×month shocks, and negative-control outcomes; (iii) pre-specifying inference/aggregation choices given serial correlation and 50 clusters).**

---

**#2: When Medicaid Can’t Compete — Cross-Payer Substitution from Medicaid to Medicare Home Health (Idea 3)**
- **Score: 63/100**
- **Strengths:** The **NPI-level cross-payer linkage** is genuinely valuable and could speak directly to “cream-skimming/substitution” rather than inferring it. Policy relevance is strong (whether low Medicaid rates actively divert capacity toward Medicare).
- **Concerns:** Identification hinges on the Medicaid–Medicare “rate gap” being plausibly exogenous; in reality Medicaid rates may change *because* access is deteriorating (reverse causality). External validity is limited because dual-billing NPIs are selected (systematically different from Medicaid-only HCBS providers), and “comparable code” mapping across payers is noisy.
- **Novelty Assessment:** **Medium-High.** Cross-payer substitution is discussed in prior work, but directly measuring it with linked T‑MSIS + Medicare PUF at the provider level is less common; still, payer-mix/provider response to relative prices has a sizeable existing literature in other contexts.
- **DiD Assessment (panel/continuous treatment):**
  - **Pre-treatment periods:** **Marginal** (T‑MSIS window as described is 2018+; if the design leans on COVID/post periods, pre is short)
  - **Selection into treatment:** **Marginal** (rate gaps likely correlated with unobservables and can respond to trends; could be improved by using *pre-period gap (e.g., 2019)* × COVID as in Idea 1)
  - **Comparison group:** **Marginal** (states with different Medicaid generosity/managed care penetration differ structurally)
  - **Treatment clusters:** **Strong** (many states; can also use provider-level panels for power, but inference still needs state-level clustering for policy variation)
  - **Concurrent policies:** **Marginal** (COVID-era policy changes affect both Medicaid and Medicare utilization/referrals; must document)
  - **Outcome-Policy Alignment:** **Marginal** (billing-share is aligned with “effort shifting,” but Medicare PUF captures Part B/supplier billing and may not cleanly represent the same service bundle as Medicaid HCBS; code overlap may be thin)
  - **Data-Outcome Timing:** **Marginal** (annual Medicare PUF + potentially mid-year Medicaid rate changes ⇒ partial exposure/attenuation risk)
  - **Outcome Dilution:** **Strong** (analysis sample is explicitly dual-billing providers—treatment is relevant to nearly all observations, though not representative)
- **Recommendation:** **CONSIDER (conditional on: (i) redesign around pre-determined rate gap × COVID (or other external shocks) to strengthen exogeneity; (ii) provider fixed effects + event-study around discrete Medicaid rate changes where possible; (iii) very explicit code-mapping validation and sensitivity to restricting to genuinely comparable services).**

---

**#3: The HCBS Pipeline Problem — Does Medicaid Wage Competitiveness Determine Who Enters the Home Care Workforce? (Idea 2)**
- **Score: 49/100**
- **Strengths:** Entry is an important, policy-relevant margin and T‑MSIS can measure “new billing NPIs” at scale; the NPPES enumeration-date auxiliary measure is a thoughtful supplement.
- **Concerns:** As written, identification is weak: wage competitiveness evolves with local labor markets *and* states may raise rates/wages in response to shortages (clear reverse causality). “New to billing” is not “new worker,” so the outcome may mix true entry with organizational switching, credentialing, and billing/contracting changes.
- **Novelty Assessment:** **Medium.** The specific “entry using T‑MSIS first-billing + NPPES enumeration” angle is less common, but “wages and workforce entry” is heavily studied; the novelty here depends entirely on achieving credible identification.
- **DiD Assessment (FE panel with time-varying treatment):**
  - **Pre-treatment periods:** **Weak** (no clear treatment start; hard to define/validate pre-trends in a continuously evolving treatment)
  - **Selection into treatment:** **Weak** (high risk wages/rates respond to entry/shortages; confounding by local demand shocks)
  - **Comparison group:** **Marginal** (states differ structurally; local labor shocks differ)
  - **Treatment clusters:** **Strong** (many states)
  - **Concurrent policies:** **Marginal** (many overlapping post-2018 labor market/pandemic policies)
  - **Outcome-Policy Alignment:** **Marginal** (“new billing NPI” is only a proxy for new workforce entrants)
  - **Data-Outcome Timing:** **Marginal** (annual wage measures vs quarterly entry; timing misalignment can attenuate)
  - **Outcome Dilution:** **Strong** (if outcome is defined as “entrants,” it’s mechanically targeted—main issue is mismeasurement, not dilution)
- **Recommendation:** **SKIP (unless it is re-identified with a credible instrument/shock—e.g., predetermined Medicaid rate schedules, court/ballot mandates, or a clearly exogenous outside-option wage shock interacted with baseline exposure—and with validated “true entry” definitions).**

---

**#4: The Price of Being Essential — Healthcare Worker Wage Compression During the Pandemic (Idea 4)**
- **Score: 42/100**
- **Strengths:** Minimum-wage policy is salient and the “compression of premium” framing is intuitive for policymakers thinking about retention.
- **Concerns:** This is very crowded terrain (minimum wage and employment/healthcare staffing), and the proposed compression measure is endogenous because HCBS wages can adjust contemporaneously to minimum-wage changes and to the same shocks driving exits. The T‑MSIS window starting in 2018 creates **very weak pre-treatment** for early adopters, and the pandemic period is saturated with confounders.
- **Novelty Assessment:** **Low.** Many papers study minimum wage effects on low-wage labor markets and healthcare support occupations; this is a re-parameterization of an extensively studied policy.
- **DiD Assessment (staggered adoption):**
  - **Pre-treatment periods:** **Weak** (data begin 2018; some states treated immediately ⇒ essentially no pre-period for them)
  - **Selection into treatment:** **Marginal** (policy adoption is political and may correlate with trends; not a clean mandate shock)
  - **Comparison group:** **Marginal** (never/late-treated differ systematically)
  - **Treatment clusters:** **Strong** (≈28 treated states)
  - **Concurrent policies:** **Weak** (pandemic-era HCBS, ARPA, emergency rules, demand shocks coincide; hard to isolate min-wage effect)
  - **Outcome-Policy Alignment:** **Marginal** (provider supply could respond, but mechanism runs through wages measured imperfectly and not directly in T‑MSIS)
  - **Data-Outcome Timing:** **Marginal** (min-wage effective dates often Jan/Jul; outcome monthly is good, but HCBS wage data are annual ⇒ misalignment)
  - **Outcome Dilution:** **Strong** (if min wage binds for a large share of aides, effect could be broad—problem is identification, not dilution)
- **Recommendation:** **SKIP.**

---

### Summary
This is a strong batch conceptually, but only **Idea 1** pairs high novelty with a plausibly credible design and well-aligned administrative outcomes; it’s the clear first project to run. **Idea 3** is promising but needs a redesign toward more exogenous variation (e.g., pre-determined gaps × shock, or discrete rate-change events) to avoid policy endogeneity. **Ideas 2 and 4** have identification problems severe enough that I would not fund them without a substantially different research design.