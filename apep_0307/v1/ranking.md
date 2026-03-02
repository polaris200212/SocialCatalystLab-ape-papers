# Research Idea Ranking

**Generated:** 2026-02-15T14:09:04.767227
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 9288

---

### Rankings

**#1: Medicaid Unwinding and HCBS Provider Network Destruction**
- **Score:** 82/100  
- **Strengths:** Extremely novel use of newly released T‑MSIS provider spending at scale, with outcomes (exit/entry, volume, concentration) tightly linked to the hypothesized mechanism. The unwinding is a large, policy-relevant shock with ample pre-period and many treated clusters, making a high-quality staggered DiD feasible.  
- **Concerns:** “Timing/aggressiveness” of unwinding is partly a state administrative/political choice, so treatment intensity could correlate with unobserved state trends (must win on pre-trends and robustness). Concurrent post-PHE changes (rate updates, HCBS ARPA spending, workforce shocks) could contaminate estimates if they differentially coincide with unwinding intensity.  
- **Novelty Assessment:** **Very high.** Many papers on unwinding effects on coverage/access; **very little** credible evidence on *provider supply/network destruction*, and essentially no established causal literature using this newly released T‑MSIS provider-spending extract.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (Jan 2018–Mar 2023 gives ~5+ years)
  - **Selection into treatment:** **Marginal** (federal trigger is exogenous, but state timing/“aggressiveness” plausibly correlated with governance/admin capacity that may track health system trends)
  - **Comparison group:** **Marginal** (late unwinders like CA/NY differ systematically; needs covariate balance checks + stacked/event-study with strong pre-trends evidence)
  - **Treatment clusters:** **Strong** (50 states)
  - **Concurrent policies:** **Marginal** (PHE end is national, but state-level HCBS rate changes, ARPA HCBS investments, and workforce dynamics may differ and coincide)
  - **Outcome-Policy Alignment:** **Strong** — Medicaid disenrollment reduces Medicaid-paid demand; T‑MSIS billing/exit directly measures provider participation/volume in the affected payer.
  - **Data-Outcome Timing:** **Strong** — outcomes are monthly (T‑MSIS service/billing months); treatment begins when terminations start (Apr–Jul 2023), with ability to impose lags and exclude partial months if needed.
  - **Outcome Dilution:** **Strong (if restricted to HCBS providers/services)** — HCBS providers are heavily Medicaid-dependent; dilution becomes **Marginal** if estimating on “all Medicaid providers” rather than the HCBS-relevant subset.
- **Recommendation:** **PURSUE (conditional on: (i) very explicit treatment definition—start vs pace vs intensity; (ii) strong pre-trend/event-study diagnostics by outcome; (iii) sensitivity to concurrent HCBS rate/ARPA implementation and reporting changes; (iv) careful “exit” definition to distinguish true exit vs billing gaps).**

---

**#2: CCBHC Expansion and Behavioral Health Provider Supply**
- **Score:** 63/100  
- **Strengths:** Policy-important question with meaningful cross-state variation and potentially large effects; using Medicaid-specific H-codes is a real measurement advantage relative to surveys/aggregate spending. If treatment timing can be pinned down cleanly, staggered DiD could be informative.  
- **Concerns:** Treatment definition is genuinely hard (demo vs SPA vs certification vs PPS payment start), risking misclassification that attenuates effects and undermines timing. Without a credible way to identify *which NPIs are actually CCBHCs*, “provider supply” outcomes risk being too diffuse (dilution) and only indirectly tied to the treated margin.  
- **Novelty Assessment:** **Moderate.** There is gray literature and some empirical work evaluating CCBHC demonstrations on service use/spending, but **provider-supply/participation effects using claims-coded services** are less developed. Not pristine novelty, but still publishable if executed well.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** (T‑MSIS starts 2018; the original 2017 demo states lack sufficient pre—must exclude/handle as always-treated)
  - **Selection into treatment:** **Marginal** (states opting in may be responding to behavioral health crises/trends)
  - **Comparison group:** **Marginal** (never-treated shrink over time; adopters may differ systematically)
  - **Treatment clusters:** **Strong (likely)** if ≥20 states have clearly dated adoption/payment start within 2018–2024; **needs verification**
  - **Concurrent policies:** **Marginal** (opioid settlement spending, telebehavioral expansions, parity/enforcement, Medicaid rate changes can co-move)
  - **Outcome-Policy Alignment:** **Marginal** — H-codes capture relevant community behavioral health services, but they are not necessarily unique to CCBHCs; provider taxonomy counts are an even looser proxy unless limited to CCBHC NPIs.
  - **Data-Outcome Timing:** **Marginal** — implementation ramps and clinic certification timing can create partial exposure within “treated” months.
  - **Outcome Dilution:** **Marginal** (could become **Strong** if restricting outcomes to identified CCBHC NPIs or PPS-billed services; could become **Weak** if using statewide counts of all behavioral health providers)
- **Recommendation:** **CONSIDER (conditional on: (i) constructing a defensible state-month “effective PPS start” date; (ii) linking a CCBHC clinic/NPI roster to isolate treated providers; (iii) showing robust pre-trends for service-specific outcomes).**

---

**#3: Medicaid Unwinding and Cross-Payer Provider Substitution**
- **Score:** 49/100  
- **Strengths:** Interesting, policy-relevant mechanism (cost shifting / payer substitution) and the NPI link is conceptually appealing. Could complement Idea 1 as a “where does volume go?” extension.  
- **Concerns:** The **annual** Medicare PUF creates a serious timing/exposure problem for a policy that turns on mid-2023 and varies by state-month; the first “post” year will mix pre- and post-treatment months mechanically. Also, the analyzable sample (dual-billing providers) may be selectively composed and small for HCBS-relevant providers, creating dilution/selection issues.  
- **Novelty Assessment:** **Moderate-low.** “Cost shifting” and cross-payer substitution are heavily studied in health economics; unwinding-specific evidence would be new, but the core question is not.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (annual 2018–2022 provides ≥5 pre years)
  - **Selection into treatment:** **Marginal** (same issues as Idea 1: intensity and pace are chosen)
  - **Comparison group:** **Marginal** (late vs early unwinders differ; fewer clean controls once nearly all states unwind)
  - **Treatment clusters:** **Strong** (50 states)
  - **Concurrent policies:** **Marginal** (post-PHE changes plus Medicare-side trends; hard to separate in annual data)
  - **Outcome-Policy Alignment:** **Marginal** — Medicare billing changes are an indirect measure of response to Medicaid demand shocks; many providers cannot substitute Medicaid volume with Medicare volume.
  - **Data-Outcome Timing:** **Weak** — Medicare PUF is annual; unwinding starts Apr–Jul 2023, so 2023 Medicare “post” mixes 3–9 months pre-exposure depending on state, causing mechanical attenuation and heterogeneous exposure.
  - **Outcome Dilution:** **Weak** — only dual-billing providers can respond on this margin, and HCBS providers often have no Medicare analogue; the affected share of the provider universe is likely well under 10–20% for the HCBS-relevant segment.
- **Recommendation:** **SKIP** (unless you can obtain **monthly/quarterly Medicare claims** or another high-frequency Medicare measure; otherwise the timing + dilution problems are close to fatal).

---

**#4: Medicaid Postpartum Extension and OB Provider Billing**
- **Score:** 44/100  
- **Strengths:** Highly policy relevant (maternal health) and T‑MSIS billing data could, in principle, measure utilization/provider response with less recall bias than surveys. Large number of adopting states helps with standard errors.  
- **Concerns:** The treated margin is narrow: the extension affects **postpartum care after day 60**, not prenatal care or deliveries—so “OB billing volume” is easily dominated by unaffected services (major dilution). More importantly, correct exposure is **cohort-based (date of birth/delivery + postpartum month)**, so a simple state adoption-date DiD is likely to mis-time treatment and bias toward null.  
- **Novelty Assessment:** **Low-moderate.** Postpartum Medicaid extensions have been studied extensively (coverage, utilization, maternal outcomes); “provider billing” is a twist, but not a big novelty leap relative to the existing literature.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** (earliest adoptions in 2022 imply ~4 years pre in 2018–2021, not ≥5)
  - **Selection into treatment:** **Marginal** (often motivated by maternal mortality/advocacy; not random)
  - **Comparison group:** **Weak** — near-universal adoption leaves very few never-treated states (AR/WI), and “not-yet-treated” controls disappear quickly by 2024, making comparisons fragile.
  - **Treatment clusters:** **Strong** (~40+)
  - **Concurrent policies:** **Marginal** (other maternal health initiatives, eligibility/process changes, managed care reforms)
  - **Outcome-Policy Alignment:** **Marginal** — postpartum E&M beyond 60 days aligns well, but the proposal’s broader “OB-related codes” (prenatal/delivery) largely do not measure the policy’s treated margin.
  - **Data-Outcome Timing:** **Weak** — effects occur months after delivery and depend on birth cohorts; calendar-time adoption indicators will misclassify exposure unless you build postpartum-month measures tied to delivery dates/eligibility spans.
  - **Outcome Dilution:** **Weak** — most OB billing is prenatal/delivery and early postpartum, which the policy does not change; without strict outcome restriction, the affected share is likely <10–20%.
- **Recommendation:** **SKIP** (this could become viable only with a redesign: define outcomes strictly as postpartum-month 3–12 visits tied to delivery dates and eligibility categories, and accept much smaller effective sample sizes).

---

### Summary

This batch has **one clearly fundable, high-upside project (Idea 1)**: it is genuinely novel, data-rich, and close to policy decision-making, with a DiD design that can be made credible if pre-trends and confounding are handled aggressively. Ideas 2 and 4 fail on **critical DiD criteria** (timing and/or dilution; plus weak control structure for Idea 2), and Idea 3 is promising but **hinges on nailing treatment timing and identifying the actually treated providers** to avoid attenuation and misalignment.