# Research Idea Ranking

**Generated:** 2026-02-17T12:32:30.346899
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6866

---

### Rankings

**#1: State Minimum Wage Increases and the HCBS Provider Supply Crisis**
- Score: 76/100
- Strengths: Strong data-outcome match and unusually rich administrative outcomes (provider entry/exit, beneficiaries served) at monthly frequency; credible within-state triple-diff (HCBS vs non-HCBS Medicaid providers) directly targets the “outside option” mechanism. Large number of treated states and a clean never-treated group help inference.
- Concerns: Minimum wage changes are not fully exogenous (often correlated with local labor-market conditions and political economy), and 2018–2024 contains major shocks (COVID, ARPA-era HCBS changes) that may differentially affect HCBS supply; you’ll need a careful concurrent-policy/controls strategy and strong pre-trend diagnostics.
- Novelty Assessment: **Moderately high**. Minimum wage is heavily studied, but *minimum wage → Medicaid HCBS provider network supply using T‑MSIS/NPI claims* appears genuinely underexplored and is a meaningful angle.
- DiD Assessment:
  - Pre-treatment periods: **Strong** (T‑MSIS can provide multiple pre-years before 2018 for many states; proposed design suggests ≥5 years is feasible)
  - Selection into treatment: **Marginal** (MW increases may respond to state conditions; mitigate via triple-diff + controls for labor-market trends/political timing; separate “indexed” vs discretionary hikes)
  - Comparison group: **Strong** (19 never-treated states + within-state non-HCBS comparison in triple-diff)
  - Treatment clusters: **Strong** (≈32 treated + 19 controls)
  - Concurrent policies: **Marginal** (COVID-era HCBS waivers, state Medicaid rate adjustments, ARPA HCBS spending; needs explicit controls/flags and sensitivity dropping heavily confounded windows)
  - Outcome-Policy Alignment: **Strong** (policy changes low-wage outside options; outcome is HCBS provider participation/volume where wages are plausibly near-binding)
  - Data-Outcome Timing: **Strong** (outcomes are state-month; MW effective dates are typically known to the month—often Jan 1 or Jul 1—so you can code exposure precisely and avoid “treated-but-not-exposed” months)
  - Outcome Dilution: **Strong** (outcome is *HCBS provider counts/claims*, not all Medicaid providers; directly concentrates on the likely-affected workforce)
- Recommendation: **PURSUE (conditional on: (i) explicit event-study pre-trends and placebo outcomes; (ii) careful coding of effective-date month and excluding partial-exposure months; (iii) systematic concurrent-policy controls—especially HCBS rate changes and COVID-era policy flags; (iv) present results with and without the triple-diff comparator group)**

---

**#2: Medicaid Postpartum Coverage Extensions and Maternal Health Provider Supply**
- Score: 62/100
- Strengths: Highly policy-relevant and timely; staggered, well-documented adoption dates create a natural event-study setting, and the question (supply response) is distinct from demand/enrollment analyses.
- Concerns: Only **3 never-treated states** makes the comparison set fragile, and adoption timing may correlate with maternal health initiatives or broader Medicaid/OB policy changes; additionally, defining “maternal health provider supply” from claims risks dilution/misclassification if codes are noisy or the relevant billing is a small share of T‑MSIS volume.
- Novelty Assessment: **Medium**. Postpartum extensions have a fast-growing literature (mostly coverage/utilization outcomes). Provider-supply effects using T‑MSIS are less saturated but no longer “wide open.”
- DiD Assessment:
  - Pre-treatment periods: **Marginal** (2018–2021 gives 4 years pre; acceptable but not ideal; confirm earlier T‑MSIS years if available)
  - Selection into treatment: **Marginal** (not random; policy adoption may respond to maternal mortality/politics; widespread adoption helps but does not eliminate endogeneity in *timing*)
  - Comparison group: **Weak** (3 never-treated states may be unrepresentative; identification leans heavily on “not-yet-treated” comparisons—credible only if timing is plausibly as-good-as-random after conditioning)
  - Treatment clusters: **Strong** (47 treated states)
  - Concurrent policies: **Marginal** (simultaneous maternal health investments, abortion restrictions, Medicaid MCO changes, provider payment changes; must inventory and control/sensitivity-test)
  - Outcome-Policy Alignment: **Marginal** (coverage extension plausibly raises postpartum demand and thus Medicaid billing, but provider *counts* may not move much if existing providers simply deliver more visits; consider outcomes like number of distinct Medicaid-billing OB clinicians + visit volume per clinician)
  - Data-Outcome Timing: **Marginal** (effects require time: women must deliver, remain covered, then seek postpartum care; first “treated” months may show mechanical partial exposure—best to analyze 6–18 months post-implementation)
  - Outcome Dilution: **Marginal** (only a subset of providers/services are truly “postpartum”; mitigate by restricting to clearly postpartum-coded visits and/or providers with high maternity share)
- Recommendation: **CONSIDER (conditional on: (i) a credible comparison strategy with near-universal adoption—e.g., early vs late adopters with strong covariate/balance checks and robustness; (ii) sharper outcome construction to avoid dilution; (iii) explicit lag structure and exposure windows; (iv) a thorough concurrent-policy timeline)**  
  *Note:* Under the institute’s “any Weak ⇒ SKIP” rule, this would be a SKIP unless you can convincingly fix the **comparison-group weakness** (e.g., supplement with alternative identification such as bordering-county designs near adoption-time differences, or strong evidence that timing is quasi-random conditional on observables).

---

**#3: Electronic Visit Verification Mandates and HCBS Provider Participation**
- Score: 48/100
- Strengths: Substantively important administrative mandate with plausible supply-side effects (compliance burden vs billing integrity), and claims data are well-suited to detect small-provider exit/entry.
- Concerns: The **Jan 1, 2020 federal deadline** creates heavy bunching and likely weak effective staggering; the personal-care EVV rollout also coincides with **COVID**, which severely disrupted HCBS utilization and provider participation in state-specific ways—this is a major concurrent-shock problem.
- Novelty Assessment: **High**. EVV has limited causal evidence on provider supply, especially using national claims, so the topic is attractive if identification can be repaired.
- DiD Assessment:
  - Pre-treatment periods: **Weak** (as written, a 2018 start gives only ~2 years pre for the main 2020 wave; you would need earlier T‑MSIS years or a different design)
  - Selection into treatment: **Marginal** (federal mandate helps, but state-specific implementation timing/exemptions likely correlate with state administrative capacity and pre-trends)
  - Comparison group: **Marginal** (in practice, “late implementers” vs “on-time” states; few truly never-treated and bunching reduces quality)
  - Treatment clusters: **Marginal** (likely <20 meaningfully distinct timing cohorts once you account for bunching at the deadline)
  - Concurrent policies: **Weak** (COVID-era HCBS disruptions, telehealth/payment flexibilities, and state emergency policies line up with EVV timing for personal care)
  - Outcome-Policy Alignment: **Strong** (EVV directly changes the administrative cost of providing personal care visits; provider participation is a direct margin)
  - Data-Outcome Timing: **Marginal** (implementation is often phased—soft launches, partial enforcement—so “compliance date” may not equal exposure date; needs granular rollout/enforcement data)
  - Outcome Dilution: **Strong** (targets a large share of personal care providers; outcomes restricted to relevant T-codes)
- Recommendation: **SKIP (unless redesigned)**. A salvage path would be to (i) focus on a later wave (e.g., the 2023 home-health EVV deadline) with ample pre-periods and less COVID overlap, and (ii) obtain *enforcement/transaction-level* EVV adoption metrics rather than nominal compliance dates.

---

**#4: Cross-Payer Substitution — Do Medicaid Providers Shift to Medicare When Rates Diverge?**
- Score: 35/100
- Strengths: Conceptually interesting and potentially very novel if you can truly link provider billing across payers and observe substitution at the NPI level.
- Concerns: The proposed “treatment” (ARPA HCBS rate increases) is **fuzzy and plausibly endogenous**—all states received enhanced FMAP, and “how funds were used” likely responds to state conditions and provider shortages (reverse causality). Medicare PUF is also limited (aggregate/public-use constraints) and may not support clean provider-level share construction comparable to T‑MSIS.
- Novelty Assessment: **High** in concept, but novelty cannot compensate for weak identification and likely data limitations for payer-share measurement.
- DiD Assessment:
  - Pre-treatment periods: **Marginal** (could have pre-2021 history, but depends on consistent cross-payer measures)
  - Selection into treatment: **Weak** (state ARPA implementation choices are highly endogenous to outcomes and political/administrative factors)
  - Comparison group: **Weak** (no clear never-treated; “later implementers” are not plausibly comparable)
  - Treatment clusters: **Marginal** (50 states, but effective treated/control separation depends on a defensible intensity measure)
  - Concurrent policies: **Weak** (ARPA coincides with many COVID/post-COVID payment and utilization shifts across both Medicaid and Medicare)
  - Outcome-Policy Alignment: **Marginal** (billing-share shifts are plausible, but ARPA HCBS dollars may not translate into provider-specific relative price changes versus Medicare)
  - Data-Outcome Timing: **Marginal** (timing of rate changes vs observed billing may not line up; Medicare PUF release cadence further complicates)
  - Outcome Dilution: **Marginal** (only dual-billers are affected/observed; they may be a minority and selected)
- Recommendation: **SKIP** (unless you can (i) find a sharply defined, plausibly exogenous Medicaid fee shock relative to Medicare—e.g., mandated fee schedule changes, court orders, or discontinuities—and (ii) use restricted Medicare claims rather than PUF to measure provider-level volumes comparably).

---

### Summary

This is a strong batch on substantive relevance, and the data assets (T‑MSIS + NPI infrastructure) are a major advantage. **Idea 1** is the clear front-runner because it combines a credible comparison structure (including triple-diff) with high-frequency, well-aligned outcomes and ample treated/control units. **Ideas 2 and 3** are attractive topics but currently fail key DiD identification checks (COVID-era confounding/bunching for EVV; endogenous and fuzzy treatment for ARPA cross-payer substitution). **Idea 4** is promising policy-wise but needs a much stronger comparison strategy given near-universal adoption and only three never-treated states.