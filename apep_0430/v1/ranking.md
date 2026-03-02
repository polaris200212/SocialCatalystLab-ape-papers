# Research Idea Ranking

**Generated:** 2026-02-20T20:49:25.243931
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6833

---

### Rankings

**#1: Does Workfare Catalyze Long-Run Development? Fifteen-Year Evidence from India's Employment Guarantee**
- **Score:** 74/100
- **Strengths:** Exceptionally strong data environment (village × year nightlights over ~3 decades) and a well-defined, policy-important rollout with enough treated clusters to support modern staggered DiD estimators and long-run dynamics. The “15-year horizon + village granularity + heterogeneity-robust DiD” package is meaningfully beyond the existing MGNREGA/nightlights literature.
- **Concerns:** Phase assignment is based on “backwardness,” so treated districts may have different underlying trends (and may also receive other “catch-up” programs), putting parallel trends at risk even with long pre-periods. DMSP→VIIRS harmonization and first-year partial exposure (Feb/Apr start dates) can mechanically attenuate or distort dynamics if not handled carefully.
- **Novelty Assessment:** **Moderate-high.** MGNREGA is heavily studied, and nightlights have been used (notably Cook & Shah 2022), but *long-run (15+ years), village-level, modern staggered DiD with credible dynamics* is still comparatively underexplored and valuable.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (1994–2005 provides many pre years for Phase I)
  - **Selection into treatment:** **Marginal** (backwardness-index targeting is predetermined but correlated with development trajectories; must show flat/parallel pre-trends and robustness to differential trends)
  - **Comparison group:** **Marginal** (Phase III “less backward” areas may not be comparable to Phase I; not-yet-treated helps but composition differs)
  - **Treatment clusters:** **Strong** (~640 districts; plenty of clusters for inference)
  - **Concurrent policies:** **Marginal** (mid-2000s India had multiple rural development pushes; risk they correlate with “backwardness” and rollout phase)
  - **Outcome-Policy Alignment:** **Marginal** (nightlights are a proxy for broad economic activity; plausible for long-run development/structural change, but not a direct measure of income/productivity)
  - **Data-Outcome Timing:** **Marginal** (policy starts Feb 2006 / Apr 2007 / Apr 2008; annual nightlights are calendar-year composites—Year 1 is partial exposure unless you shift treatment to the next full year or model exposure fractions)
  - **Outcome Dilution:** **Marginal** (MGNREGA targets a subset of households; village mean nightlights reflect everyone—effects may be diluted unless there are strong general equilibrium spillovers)
- **Recommendation:** **PURSUE (conditional on: (i) extensive pre-trend/event-study validation by phase; (ii) explicit handling of partial first-year exposure; (iii) robustness to alternative comparison sets / district-specific trends; (iv) careful DMSP–VIIRS harmonization and sensitivity to the 2012–2013 overlap period).**

---

**#2: Saubhagya and the Light at the End of the Wire: Rural Electrification's Impact on Village Economic Activity**
- **Score:** 58/100
- **Strengths:** High policy relevance and genuinely under-studied as a *named* policy (Saubhagya), with a tight mechanism linking electrification to lights—measurement is unusually “close” to the intervention. VIIRS-only (2012–2023) avoids the hardest DMSP-era issues.
- **Concerns:** Intensity DiD is vulnerable: districts with high baseline non-electrification may have different underlying growth paths (and may be targeted by other infrastructure programs), threatening parallel trends. Nightlights may capture electrification *mechanically* rather than broader economic gains, making interpretation (“amenity vs productivity”) delicate.
- **Novelty Assessment:** **High.** Surprisingly few rigorous causal evaluations explicitly of Saubhagya exist, though electrification more broadly has a large literature.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (~2012–2016/17 gives ~5+ pre years)
  - **Selection into treatment:** **Marginal** (intensity = baseline un-electrified share is predetermined but strongly correlated with remoteness/poverty and possibly differential trends)
  - **Comparison group:** **Marginal** (low-intensity vs high-intensity districts differ substantially; needs rich controls, state×year FE, and strong pre-trend diagnostics)
  - **Treatment clusters:** **Strong** (~600+ districts)
  - **Concurrent policies:** **Marginal** (other power-sector and rural infrastructure initiatives around 2015–2019 could be correlated with electrification gaps)
  - **Outcome-Policy Alignment:** **Marginal** (very direct for “are there more lights?”, less direct for “economic activity”; you’ll need complementary outcomes or interpretation discipline)
  - **Data-Outcome Timing:** **Marginal** (launch Oct 2017; annual VIIRS 2017 is mostly pre-treatment—primary “post” should start 2018; avoid mislabeling 2017 as treated)
  - **Outcome Dilution:** **Marginal** (treatment affects previously unconnected households; if they’re a minority of village light emissions, effects on total radiance may be muted; conversely could be large if they were near-zero before)
- **Recommendation:** **CONSIDER (only if: (i) you show very clean pre-trends by intensity; (ii) define post-period starting 2018; (iii) add non-nightlights outcomes if feasible—e.g., enterprise counts, assets, consumption proxies—or at least separate “electrification lights” from “growth” via heterogeneity/tests).**

---

**#3: Scheduled Caste Concentration and the Returns to Public Works: Heterogeneous Effects of MGNREGA**
- **Score:** 56/100
- **Strengths:** Substantively important distributional question (caste inequality) using the same strong underlying design/data as Idea 1; feasible and likely to produce policy-relevant heterogeneity. If carefully executed, this can be a publishable *angle* even if the average effect is known.
- **Concerns:** As framed, it is not really a standalone research design—more a heterogeneity module of Idea 1—so incremental novelty is limited. Heterogeneity by SC/ST share risks “proxying” for many baseline differences (poverty, remoteness, political targeting), so interpretation needs careful conditioning and pre-trend checks within SC/ST strata.
- **Novelty Assessment:** **Moderate.** MGNREGA and distributional questions are studied, but *village-level long-run heterogeneity by caste concentration using nightlights* is less common; still, it’s naturally nested in Idea 1 rather than distinct.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (same as Idea 1)
  - **Selection into treatment:** **Marginal** (same as Idea 1)
  - **Comparison group:** **Marginal** (same as Idea 1, plus compositional differences by caste share)
  - **Treatment clusters:** **Strong**
  - **Concurrent policies:** **Marginal**
  - **Outcome-Policy Alignment:** **Marginal** (nightlights proxy; heterogeneity interpretation further from mechanism)
  - **Data-Outcome Timing:** **Marginal** (same partial-exposure issue)
  - **Outcome Dilution:** **Marginal** (same dilution issue; may be less severe in high-SC/ST villages if take-up is much higher, but must be shown)
- **Recommendation:** **CONSIDER (best as a chapter/section within Idea 1, not as the institute’s lead standalone project).**

---

**#4: MGNREGA and the Feminization of Rural Work: Long-Run Effects on Female Workforce Participation**
- **Score:** 45/100
- **Strengths:** Outcome is tightly aligned with the policy’s explicit female participation mandate, and Census worker-type decomposition is substantively rich and policy-relevant. Triple-diff (female vs male) is a reasonable attempt to strengthen identification.
- **Concerns:** The Census structure gives only **two pre-treatment cross-sections (1991, 2001)** and essentially one long post window (2011), making parallel trends hard to validate and dynamics impossible; treatment timing differences (Phase I vs III) are small relative to a decadal outcome measurement. With so few time points, results risk being driven by differential long-run convergence/divergence unrelated to MGNREGA.
- **Novelty Assessment:** **Moderate.** Female labor supply and MGNREGA are studied (often with NSS), and “long-run via Census” is a twist, but the design constraints are severe.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (only 2 pre observations; cannot credibly assess parallel trends in any meaningful way)
  - **Selection into treatment:** **Marginal** (backwardness targeting)
  - **Comparison group:** **Marginal** (Phase III systematically less backward)
  - **Treatment clusters:** **Strong** (many districts/villages)
  - **Concurrent policies:** **Marginal** (multiple gender/workforce-related and rural programs over 2001–2011 could confound)
  - **Outcome-Policy Alignment:** **Strong** (female workforce participation is directly related to the policy’s female employment channel)
  - **Data-Outcome Timing:** **Marginal** (2011 is post, but exposure differs only by ~2 years between phases and is averaged over a decade-long change)
  - **Outcome Dilution:** **Marginal** (MGNREGA affects working-age women most; workforce measures are for all women—less severe than test-score dilution, but still not tightly targeted)
- **Recommendation:** **SKIP** (unless you can add higher-frequency labor outcomes—e.g., NSS/PLFS microdata with enough pre years and clean timing—or a different design entirely).

---

### Summary

This is a strong batch in terms of data ambition and policy importance, but only **Idea 1** clearly clears the bar on feasibility and (with careful execution) credible identification. **Idea 2** is unusually novel and relevant, yet its intensity-based DiD demands unusually strong pre-trend evidence and careful interpretation of nightlights as “electrification vs growth.” **Idea 3** is best treated as a heterogeneity extension to Idea 1, while **Idea 4** fails the DiD pre-trends standard due to sparse Census time points and should not be the institute’s priority.