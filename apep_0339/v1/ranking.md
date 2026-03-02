# Research Idea Ranking

**Generated:** 2026-02-17T11:13:00.824917
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7567

---

### Rankings

**#1: State Minimum Wage Increases and the Medicaid Home Care Workforce**
- **Score: 72/100**
- **Strengths:** Very high upside: combines a heavily policy-salient labor-market policy with newly available, provider-level Medicaid HCBS data and plausibly large effects on a workforce near the minimum-wage margin. Many treated states and precise effective-date variation make a well-powered event-study feasible.
- **Concerns:** Parallel trends are not guaranteed because minimum-wage adopters differ systematically (region/politics/urbanization) from federal-minimum states, and Medicaid HCBS reimbursement/policy changes may be correlated with minimum-wage hikes. Also, because T‑MSIS begins in 2018, early treatment events have limited pre-periods unless you restrict cohorts.
- **Novelty Assessment:** **High.** Minimum wage is saturated in general labor markets, but “minimum wage → Medicaid HCBS provider supply/entry using T‑MSIS provider billing” is genuinely new largely because the necessary data were not previously accessible/usable at scale.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** — T‑MSIS starts 2018; any 2018–2019 increases have ≤2 years pre (dealbreaker unless you drop early cohorts or require ≥36–60 pre-months by cohort).
  - **Selection into treatment:** **Marginal** — minimum-wage policy is political and may correlate with underlying labor-market/Medicaid trends.
  - **Comparison group:** **Marginal** — “federal-minimum” states are often systematically different; needs strong covariate balance checks, region-specific trends, and/or alternative controls (e.g., bordering-state comparisons).
  - **Treatment clusters:** **Strong** — 30+ treated states, staggered.
  - **Concurrent policies:** **Marginal** — plausible confounding from Medicaid rate changes, HCBS expansions, ARPA-related workforce actions; needs explicit controls/placebos (e.g., non-HCBS Medicaid provider outcomes).
  - **Outcome-Policy Alignment:** **Strong** — provider entry/exit and HCBS billing are direct margins through which wage floors can bind.
  - **Data-Outcome Timing:** **Strong** — monthly billing can be aligned to Jan 1 vs Jul 1 effective dates (avoid annual aggregation).
  - **Outcome Dilution:** **Strong** — outcomes are defined on HCBS codes/workers likely exposed to minimum-wage changes (not diluted by an all-worker or all-provider denominator).
- **Recommendation:** **PURSUE (conditional on: dropping/handling cohorts without adequate pre-period; demonstrating no differential pre-trends using event studies; strengthening the control strategy beyond “never-treated states,” e.g., border-pair / matched-state designs and falsification outcomes).**

---

**#2: Medicaid Postpartum Coverage Extensions and OB/GYN Provider Supply**
- **Score: 64/100**
- **Strengths:** Big policy relevance and large-scale staggered adoption (47 states) make modern staggered DiD feasible, and a provider-supply response is a meaningful complement to the demand-side postpartum literature. T‑MSIS can measure actual Medicaid billing/participation rather than survey proxies.
- **Concerns:** The main identification threat is **outcome dilution/misalignment** if you use broad “maternity-related” billing: the policy expands eligibility specifically for months >60 days postpartum, which may be a modest share of all OB/GYN billing. Also, adoption timing and contemporaneous maternal-health initiatives during/post-COVID could confound estimates.
- **Novelty Assessment:** **Moderate.** Postpartum extensions are already studied extensively for utilization and health outcomes; provider entry/participation is less studied, but “coverage expansions → provider participation” is not brand-new conceptually.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** — earliest adoptions in 2022 give ~4 years pre in 2018–2022, short of the “≥5 years” gold standard but usually enough for event-study diagnostics.
  - **Selection into treatment:** **Marginal** — not random; states may adopt in response to maternal health pressures/politics, though near-universal adoption reduces “treated vs never-treated” selection concerns.
  - **Comparison group:** **Marginal** — mostly “not-yet-treated” controls; composition changes over time and late adopters may differ. (Mitigate with careful cohort diagnostics and alternative control sets.)
  - **Treatment clusters:** **Strong** — 47 treated states.
  - **Concurrent policies:** **Marginal** — overlaps with COVID/PHE unwinding timing, other maternal-health investments, Medicaid MCO/payment reforms.
  - **Outcome-Policy Alignment:** **Marginal** — provider participation could rise via increased postpartum demand, but only if outcomes isolate *post-60-day postpartum* services.
  - **Data-Outcome Timing:** **Strong** — claims/service-month outcomes can be aligned to SPA effective dates; avoid counting partial-exposure months as fully treated.
  - **Outcome Dilution:** **Marginal** — likely 20–50% affected *only if* you restrict to postpartum-months 3–12 (or postpartum-specific codes). If you keep all maternity/OB billing, dilution could be **Weak**.
- **Recommendation:** **CONSIDER (conditional on: redefining outcomes to target months 3–12 postpartum—e.g., postpartum visits after day 60, contraception, depression screening/treatment, lactation support; and constructing a provider panel focused on Medicaid postpartum-service billers rather than all OB/GYN activity).**

---

**#3: ARPA HCBS Rate Increases and Provider Entry**
- **Score: 45/100**
- **Strengths:** High policy importance (did ARPA’s HCBS money actually expand capacity?) and good outcome alignment if you can credibly date rate changes. Provider-level entry is exactly the right object for this question.
- **Concerns:** Identification is fragile because (i) **treatment timing/definition** is messy (plans vs implementation; partial/temporary increases; targeted subsets), and (ii) ARPA-era changes are deeply entangled with COVID labor-market recovery, other ARPA workforce spending, and Medicaid operational shocks—creating serious concurrent-policy and selection concerns.
- **Novelty Assessment:** **Moderate-High.** There’s limited rigorous provider-level work on ARPA 9817, but the main challenge is not novelty—it’s credible identification and clean treatment measurement.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** — ~3 years pre (2018–Mar 2021).
  - **Selection into treatment:** **Marginal** — states choosing rate increases (and timing/magnitude) may do so because of shortages/trends in provider exit.
  - **Comparison group:** **Marginal** — “later/never increasers” may be systematically different.
  - **Treatment clusters:** **Strong** — ~25 states.
  - **Concurrent policies:** **Weak** — COVID/PHE effects, ARPA’s many simultaneous HCBS/workforce provisions, and Medicaid unwinding-era disruptions plausibly move provider entry in correlated ways.
  - **Outcome-Policy Alignment:** **Strong** — rate increases should directly affect provider participation/entry.
  - **Data-Outcome Timing:** **Marginal** — unless you can pin *true* implementation months (not announcement/approval), timing error will attenuate effects.
  - **Outcome Dilution:** **Strong** — focusing on Medicaid-dependent HCBS billing providers is appropriately targeted.
- **Recommendation:** **SKIP (unless you can: (1) build a validated, service-specific, state-month rate-implementation dataset with exact effective dates and affected services; and (2) find a cleaner design such as within-state differential exposure across service types that did vs did not receive increases).**

---

**#4: Certificate of Need Law Changes and Medicaid Provider Market Structure**
- **Score: 30/100**
- **Strengths:** Potentially interesting angle if CON changes truly affected HCBS/behavioral health entry; market-structure outcomes could be informative for competition policy.
- **Concerns:** The proposal itself notes the core problem: **~5 treated states** → inference is very fragile and highly sensitive to idiosyncratic state shocks; also CON reforms are often bundled with other health-system changes, creating confounding.
- **Novelty Assessment:** **Low-Moderate.** CON is a heavily studied policy area; applying T‑MSIS to non-hospital providers is a new data angle, but the small-N reform set kills credibility.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** — 2018–2024 can provide multiple pre-years depending on reform timing.
  - **Selection into treatment:** **Marginal** — reforms are political and may follow market conditions.
  - **Comparison group:** **Marginal** — “non-reforming” states may not be comparable.
  - **Treatment clusters:** **Weak** — <10 treated states (dealbreaker for DiD inference).
  - **Concurrent policies:** **Marginal** — likely coincident regulatory/Medicaid changes.
  - **Outcome-Policy Alignment:** **Marginal** — CON often targets facilities; mapping to the specific provider types observed in T‑MSIS must be tight.
  - **Data-Outcome Timing:** **Strong/Marginal** — feasible with annual/monthly billing, but depends on precise reform effective dates.
  - **Outcome Dilution:** **Marginal** — depends on whether the measured provider categories are actually regulated by CON.
- **Recommendation:** **SKIP.**

---

### Summary

This is a strong batch on **novel Medicaid-provider measurement using T‑MSIS**, but only **Idea 1** looks like a clear “first to run” project because it combines high novelty with strong outcome alignment and adequate variation—provided you handle limited pre-periods for early adopters and improve comparability beyond federal-minimum states. **Idea 2** is viable but must tighten the outcome definition to avoid postpartum-specific dilution. **Ideas 3 and 4** have serious identification risks (concurrent-policy/timing ambiguity; and too few treated states, respectively) and should be deprioritized unless redesigned.