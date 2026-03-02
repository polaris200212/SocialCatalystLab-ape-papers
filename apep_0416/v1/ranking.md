# Research Idea Ranking

**Generated:** 2026-02-19T08:20:41.598391
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6110

---

### Rankings

**#1: When the Safety Net Frays — Unwinding Intensity and Behavioral Health Provider Market Concentration (Idea 3)**
- **Score: 74/100**
- **Strengths:** The **DDD (H-codes vs T-codes within the same state-month)** is a meaningful identification upgrade because it soaks up many state-level concurrent shocks that would otherwise contaminate a pure state-level DiD. Market structure outcomes (exit/entry/HHI) are directly tied to the hypothesized mechanism (revenue shock → consolidation/exit).
- **Concerns:** “Disenrollment intensity” (especially procedural disenrollment share) is plausibly **endogenous to state administrative capacity** and could proxy for broader Medicaid dysfunction that differentially affects behavioral health vs HCBS (violating DDD parallel trends). HHI measured from claims can also move mechanically due to encounter-data reporting artifacts and changes in managed-care routing rather than true consolidation.
- **Novelty Assessment:** **Moderately high novelty.** A lot is being written on unwinding and on behavioral health access, but **provider market structure responses to the unwinding using T‑MSIS (and a within-state DDD vs HCBS)** is not yet a crowded space.
- **DiD Assessment (staggered/continuous DiD + DDD):**
  - **Pre-treatment periods:** **Strong** (2018–early 2023 gives many pre-periods).
  - **Selection into treatment:** **Marginal** (disenrollment *intensity* reflects state choices/capacity; not plausibly quasi-random).
  - **Comparison group:** **Strong** for the **within-state DDD** (HCBS is a credible internal comparator if pre-trends match); **Marginal** for the cross-state intensity comparison alone.
  - **Treatment clusters:** **Strong** (≈51 states/DC).
  - **Concurrent policies:** **Marginal → Strong with DDD** (DDD helps, but only if concurrent policies affect H- and T-code providers similarly; e.g., 988 rollout, opioid settlement spending, MCO carve-in/out changes could differentially hit behavioral health).
  - **Outcome-Policy Alignment:** **Strong.** Unwinding reduces covered Medicaid patients; provider exit/entry, caseload, and HHI in Medicaid claims are direct measures of supply-side response.
  - **Data-Outcome Timing:** **Strong (conditional).** T‑MSIS has service dates allowing **state-month** outcomes; unwinding starts April–July 2023 and effects should appear in subsequent service months. Main risk is **claims runout/lag**—you’ll need to ensure late-2024 data are mature and use service month (not paid month).
  - **Outcome Dilution:** **Strong.** Outcomes are defined on **Medicaid behavioral health provider activity**, where the treated population share is large; dilution is much less severe than using population-wide outcomes like overall mortality.
- **Recommendation:** **PURSUE (conditional on: (i) demonstrate tight pre-trends in H vs T outcomes within states; (ii) document T‑MSIS encounter completeness/reporting stability around 2023–2024; (iii) sensitivity to alternative intensity measures—overall disenrollment vs procedural share vs ex parte rates).**

---

**#2: The Behavioral Health Cliff — Medicaid Unwinding and Community Mental Health Provider Supply (Idea 1)**
- **Score: 68/100**
- **Strengths:** Strong policy importance and a clean, interpretable outcome set (billing volume, exit, caseload) using a dataset (T‑MSIS H-codes) that many researchers still cannot exploit well. Long pre-period supports credible event-study diagnostics.
- **Concerns:** The **staggering is only April–July 2023**, giving limited “not-yet-treated” time and making estimates sensitive to any **national 2023 shocks** to behavioral health (workforce changes, telehealth policy evolution, 988-related dynamics) plus differential state implementation. State start timing may reflect administrative readiness correlated with underlying provider trends.
- **Novelty Assessment:** **Moderate novelty.** There will be many unwinding papers; fewer on **provider supply**, and fewer still specifically on **behavioral health providers in T‑MSIS**, so it’s not saturated—but it’s adjacent to a fast-growing literature.
- **DiD Assessment (staggered DiD):**
  - **Pre-treatment periods:** **Strong** (≥5 years pre).
  - **Selection into treatment:** **Marginal** (states had discretion/constraints over timing and procedures; not clearly exogenous).
  - **Comparison group:** **Marginal** (with only 4 months of staggering, “not-yet-treated” controls are thin; composition of early vs late states may differ).
  - **Treatment clusters:** **Strong** (≈51).
  - **Concurrent policies:** **Marginal** (multiple contemporaneous behavioral-health and Medicaid delivery-system changes; two-way FE pitfalls mitigated by Callaway–Sant’Anna, but confounding remains possible).
  - **Outcome-Policy Alignment:** **Strong.** Coverage loss should translate into fewer Medicaid-covered visits and revenue, affecting billing volume and exits for Medicaid-dependent providers.
  - **Data-Outcome Timing:** **Strong (conditional).** Monthly service-date outcomes should line up with April–July 2023 starts; but you must handle mid-month terminations and claims runout (otherwise first “treated months” can be partially untreated or underreported).
  - **Outcome Dilution:** **Strong.** You’re measuring outcomes among providers whose patient base is heavily Medicaid; the affected share is substantial.
- **Recommendation:** **CONSIDER → PURSUE if you add a stronger control strategy** (e.g., incorporate **Idea 3’s H-vs-T DDD** as a main specification or key robustness, and pre-register checks for differential pre-trends across early/late states).

---

**#3: Cross-Payer Musical Chairs — Do Medicaid Behavioral Health Providers Shift to Medicare When Beneficiaries Lose Coverage? (Idea 2)**
- **Score: 45/100**
- **Strengths:** Conceptually interesting (payer substitution / capacity constraints) and genuinely novel to link Medicaid T‑MSIS with Medicare provider billing at NPI level if the data line up.
- **Concerns:** High risk of a **data/measurement failure**: Medicare PUF is typically **annual, lagged, and incomplete** (often FFS-focused and may miss Medicare Advantage), which creates serious timing misalignment and dilution. The “dual-billing behavioral health providers” sample could be small and unrepresentative, and shifts could reflect coding/setting changes rather than real substitution.
- **Novelty Assessment:** **High novelty in execution**, but the broader “payer shifting” question is well-studied in other settings; this specific unwinding/provider-level cross-payer implementation is not common.
- **DiD Assessment (provider-level DiD with state timing):**
  - **Pre-treatment periods:** **Strong** (you can likely assemble many pre-years).
  - **Selection into treatment:** **Marginal** (same issues as Ideas 1/3).
  - **Comparison group:** **Weak** (annual Medicare outcomes + only April–July 2023 staggering means you effectively lose the not-yet-treated structure; cross-state comparisons become very exposed to confounding).
  - **Treatment clusters:** **Strong** (many states), but effective identifying variation is weak given annual aggregation.
  - **Concurrent policies:** **Marginal** (Medicare telehealth/payment changes and behavioral health billing expansions could coincide).
  - **Outcome-Policy Alignment:** **Marginal.** Unwinding primarily removes Medicaid coverage; Medicare billing only increases if providers have latent Medicare demand and capacity—plausible but indirect.
  - **Data-Outcome Timing:** **Weak.** If Medicare PUF is annual (and possibly only through 2022/2023), you may not observe true post-unwinding exposure, and any 2023 measure is partly pre-treatment for April–July starts.
  - **Outcome Dilution:** **Weak.** Medicare Advantage and non-captured settings mean large shares of Medicare activity may be missing; plus only a subset of Medicaid BH providers treat Medicare patients, making the treated share likely <10–20%.
- **Recommendation:** **SKIP (unless: (i) you secure monthly/quarterly Medicare claims with MA visibility; and (ii) you can define a large, stable dual-eligible/provider sample with validated exposure timing).**

---

### Summary

This is a strong batch conceptually, centered on an important, timely policy shock with unusually rich administrative data. **Idea 3 is the most promising** because the **within-state DDD** substantially strengthens identification relative to a purely staggered state DiD in a period with many national shocks. **Idea 2 has multiple dealbreakers (timing + dilution + data availability)** in its current form and should be deferred unless you can access more granular Medicare data.