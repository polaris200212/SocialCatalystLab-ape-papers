# Research Idea Ranking

**Generated:** 2026-02-18T09:29:32.393681
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 8700

---

### Rankings

**#1: Tight Labor Markets and the Crisis in Home Care — Within-State Evidence from Medicaid Provider Billing**
- Score: **74/100**
- Strengths: Uses unusually rich administrative data (T‑MSIS) with a compelling within-state design (county FE + state×quarter FE) and a credible strategy to address reverse causality via a Bartik shift-share IV. High policy salience given widespread HCBS workforce shortages and large Medicaid spending stakes.
- Concerns: The “pre-period” is only 2018–2019 (2 years), which is borderline for diagnosing differential pre-trends; and Bartik exclusion can fail if national industry shocks affect HCBS through channels other than labor tightness (e.g., county income/Medicaid enrollment, local service demand). County assignment via NPPES ZIP may mis-measure where care is delivered (beneficiary county is preferable if available in T‑MSIS).
- Novelty Assessment: **High.** There is a big descriptive literature and lots on nursing homes/long-term care staffing, but **county-level causal estimates for HCBS supply using multi-state T‑MSIS** are not something I’ve seen as a well-developed empirical literature.
- DiD Assessment:
  - Pre-treatment periods: **Weak** (2 years as written; mitigation would be to pull earlier T‑MSIS years if usable or redesign around IV with strong placebo tests)
  - Selection into treatment: **Strong** (national industry shocks × pre-shares is plausibly exogenous to local HCBS shocks; COVID recovery is not “chosen” by counties)
  - Comparison group: **Strong** (within-state, across-county variation; state×quarter absorbs state-level confounders)
  - Treatment clusters: **Strong** (thousands of counties)
  - Concurrent policies: **Marginal** (state-level policies absorbed, but county-level COVID waves, local provider market disruptions, migration, and facility closures may coincide with tightness)
  - Outcome-Policy Alignment: **Strong** (active billing providers/claims are direct measures of HCBS supply/activity)
  - Data-Outcome Timing: **Marginal** (quarterly claims vs contemporaneous tightness risks simultaneity; needs lag structure and/or “exposure” timing clarity—use service dates and lagged labor-market measures)
  - Outcome Dilution: **Strong** (outcomes are directly the affected sector, not a broad population mean)
- Recommendation: **PURSUE (conditional on: extending/strengthening pre-trend diagnostics—ideally add earlier years or very strong placebo tests; validating county location using beneficiary county or service location where possible rather than NPPES mailing ZIP; showing Bartik robustness to alternative industry sets and controlling for Medicaid enrollment/demand shocks).**

---

**#2: Minimum Wage Bindingness and HCBS Provider Supply**
- Score: **59/100**
- Strengths: Clear mechanism and relatively clean within-state heterogeneity design (minimum wage changes × county Kaitz index) that, if implemented with strong state×time controls, can remove many confounders that plague cross-state minimum wage studies. Data construction is feasible (ACS wages + statutory minimum wages + T‑MSIS outcomes).
- Concerns: Minimum wage adoption/timing is politically/economically endogenous at the **state** level; the identification relies on **parallel trends between high- vs low-Kaitz counties within a state**, which is not guaranteed (those counties may have different secular trajectories). Also, “bite” may be modest in many counties if HCBS wages already exceed the new minimum, weakening first stage and making “bindingness” measurement critical.
- Novelty Assessment: **Medium-Low.** Minimum wages and long-term care labor supply have been studied; the **within-state Kaitz approach is a useful twist**, but it’s still close to an existing topic.
- DiD Assessment:
  - Pre-treatment periods: **Weak** (earliest state changes in 2018 imply very limited pre for part of the sample; could be fixed by restricting to later adopters and/or adding earlier T‑MSIS years)
  - Selection into treatment: **Marginal** (state policy choice endogenous; heterogeneity design helps but doesn’t eliminate concerns)
  - Comparison group: **Marginal** (high- vs low-Kaitz counties differ systematically; needs strong evidence of similar pre-trends in HCBS outcomes)
  - Treatment clusters: **Strong** (many states and many counties; inference feasible)
  - Concurrent policies: **Marginal** (state×quarter FE would absorb state-level coincident policies; county-level shocks remain)
  - Outcome-Policy Alignment: **Strong** (policy directly affects wages at the bottom of the distribution where HCBS workers sit)
  - Data-Outcome Timing: **Marginal** (many minimum wage changes effective Jan 1 or Jul 1; quarter-level outcomes create partial-exposure periods—needs careful “first full quarter/year exposed” coding)
  - Outcome Dilution: **Marginal** (depends on how many HCBS workers are near the minimum; must document share below/near new minimum to argue treatment intensity is meaningful)
- Recommendation: **CONSIDER (conditional on: redesigning around “first full quarter/year of exposure” and excluding partial quarters; documenting/validating bindingness with wage distribution evidence; restricting to states with adequate pre-period and stable coding/claims completeness).**

---

**#3: Broadband Access and Telehealth Adoption in Medicaid**
- Score: **55/100**
- Strengths: Big-policy question with clear within-state variation (broadband) and a plausibly important mechanism for Medicaid access. A multi-state T‑MSIS telehealth paper could be quite valuable because much existing work is single-payer/single-state.
- Concerns: Two potential dealbreakers: (i) **Outcome measurement**—telehealth identification in claims is notoriously inconsistent (modifier codes, place-of-service, managed care encounter completeness), so outcome-policy alignment may collapse if telehealth is under-coded or changes mechanically over time; (ii) broadband data quality—FCC Form 477 is known to overstate availability, and timing of broadband improvements vs “pre-existing infrastructure” must be pinned down.
- Novelty Assessment: **Medium.** Telehealth expansion is heavily studied post-COVID, and broadband/telehealth links exist, but **Medicaid multi-state administrative claims evidence** is less saturated.
- DiD Assessment:
  - Pre-treatment periods: **Weak** (2018–2019 gives 2 years pre; COVID is 2020 shock)
  - Selection into treatment: **Marginal** (broadband is pre-determined but correlated with many evolving local traits; improvements may be endogenous)
  - Comparison group: **Strong** (within-state county comparisons with state×quarter FE)
  - Treatment clusters: **Strong** (many counties)
  - Concurrent policies: **Marginal** (state×quarter absorbs state telehealth rules; but local COVID intensity/provider capacity could correlate with broadband and telehealth takeup)
  - Outcome-Policy Alignment: **Marginal** (could become **Weak** if telehealth is not reliably captured in T‑MSIS across states/years—must validate coding and completeness)
  - Data-Outcome Timing: **Marginal** (telehealth policy changes often March 2020; quarter-level outcomes include partial exposure—needs careful timing/exposure definitions)
  - Outcome Dilution: **Strong** (outcome is telehealth-specific utilization, not a diluted average)
- Recommendation: **CONSIDER (conditional on: a rigorous telehealth coding validation plan—modifier/POS crosswalks by state and year; excluding states/periods with poor encounter completeness; using an alternative broadband measure or triangulating FCC with Ookla/Microsoft usage data; and handling partial-exposure quarters).**

---

**#4: Rural Hospital Closures and the Substitution to Home-Based Care**
- Score: **49/100**
- Strengths: Strong policy relevance for rural health infrastructure, and the event-study framing is intuitive. If credible, it would add a new angle on substitution toward HCBS when acute care capacity disappears.
- Concerns: Identification is the core problem: closures are typically **endogenous to deteriorating local conditions** (population loss, worsening payer mix, declining utilization), which likely also affect HCBS supply/demand—classic violated parallel trends. In addition, within 2018–2024 there may be **too few closures** for power, and closure dates map into partial quarters.
- Novelty Assessment: **Medium.** Hospital-closure effects are well studied for many outcomes; HCBS-specific responses are less studied, but this is still adjacent to a known literature.
- DiD Assessment:
  - Pre-treatment periods: **Weak** (for closures near 2018/2019 you have very limited pre; even for later closures you still don’t reach 5 years)
  - Selection into treatment: **Weak** (closures respond to trends and fiscal distress—direct threat to causal claims)
  - Comparison group: **Marginal** (within-state rural non-closure counties can help, but “similarity” is hard; needs matching/synthetic controls)
  - Treatment clusters: **Weak** (likely <20 closure events in-window once you impose data-quality and rural-only restrictions)
  - Concurrent policies: **Marginal** (COVID-era disruptions and state rural health initiatives may coincide)
  - Outcome-Policy Alignment: **Strong** (closure plausibly shifts care patterns; HCBS outcomes measure home-based care activity)
  - Data-Outcome Timing: **Marginal** (closure month vs quarter outcomes → partial exposure)
  - Outcome Dilution: **Marginal** (closure affects the whole county, but HCBS outcomes are Medicaid-only; still potentially meaningful, but effect size uncertain)
- Recommendation: **SKIP (unless you can supply a much stronger identification design—e.g., instrument closures with plausibly exogenous shocks, or use a tightly matched synthetic-control/event design with extensive pre-period data well before 2018).**

---

**#5: Market Power and the Pass-Through of Medicaid Rate Increases**
- Score: **33/100**
- Strengths: Good question and mechanism (market structure mediating pass-through), and HHI construction from T‑MSIS is feasible.
- Concerns: ARPA is close to a **nationwide treatment with limited untreated controls**, so the design leans heavily on timing/implementation and functional-form assumptions; coincident COVID labor shocks and other ARPA-funded initiatives create severe confounding. Also, “rate increases” differ by service and state implementation details; aggregating outcomes risks dilution and misalignment.
- Novelty Assessment: **Medium.** Pass-through/market power is widely studied in other settings; Medicaid HCBS-specific, county-level pass-through is less common, but the identification environment here is unfavorable.
- DiD Assessment:
  - Pre-treatment periods: **Marginal** (2018–2020 gives 3 years pre)
  - Selection into treatment: **Weak** (state rate increases/timing are policy choices plausibly responding to local pressures)
  - Comparison group: **Weak** (near-universal ARPA exposure → no credible never-treated group; “later treated” may not be valid)
  - Treatment clusters: **Strong** (many states, but effective identifying variation is limited)
  - Concurrent policies: **Weak** (ARPA period coincides with major labor-market and health-system shocks and other funding streams affecting HCBS)
  - Outcome-Policy Alignment: **Marginal** (rate increases are service-specific; county-level aggregated HCBS measures may not track the priced services)
  - Data-Outcome Timing: **Marginal** (ARPA April 2021 + heterogeneous state implementation → partial/unclear exposure windows)
  - Outcome Dilution: **Weak** (if only some HCPCS/services received rate increases, aggregation to all HCBS can heavily dilute effects)
- Recommendation: **SKIP (unless redesigned around clearly documented, service-specific rate-change events with a defensible comparison group and clean exposure timing).**

---

### Summary

This is a strong, thematically coherent batch with one standout: **Idea 1** has the best combination of novelty, rich data, and an identification strategy that can be made credible—provided you address the short pre-period and location measurement. **Ideas 2 and 5** are the weakest on identification (near-universal treatment and heavy confounding), and **Idea 3** is likely underpowered/endogenous without a substantially stronger design. If you pursue only one immediately, pursue **Idea 1** first (with the listed conditions).