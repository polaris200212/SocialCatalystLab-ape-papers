# Research Idea Ranking

**Generated:** 2026-02-22T22:17:34.416762
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7740

---

### Rankings

**#1: The First Retirement Age — Civil War Pensions and Elderly Labor Supply at the Age-62 Threshold**
- **Score: 82/100**
- **Strengths:** Credible design: a plausibly sharp statutory eligibility cutoff with huge sample size, multiple age cutoffs (62/70/75), and an unusually strong placebo group (Confederate veterans). Outcomes (labor force participation, occupation, living arrangements) match the mechanism of an income floor affecting retirement and household structure.
- **Concerns:** The design is “sharp” in law but likely **fuzzy in exposure** (take-up/application lags; some below 62 already on disability pensions), and the 1910 Census doesn’t directly measure pension receipt—so you’ll estimate an ITT effect of eligibility unless you link pension rolls for a first stage. Need to address age misreporting and ensure no other veteran-related discontinuities at 62 (e.g., institutional rules) and that the sample definition doesn’t change at the cutoff.
- **Novelty Assessment:** **High within mainstream applied micro.** Civil War pensions are well-studied in econ history, but an explicit age-62 RDD with modern diagnostics and Confederate placebo/multi-cutoff structure is much less common than OLS/matching/IV approaches.
- **Recommendation:** **PURSUE (conditional on: documenting fuzziness/take-up with external pension-roll evidence or framing clearly as eligibility ITT; running full McCrary/age-heaping checks and donut/binned-age robustness; confirming no contemporaneous age-62 rules for veterans besides the pension act).**

---

**#2: City Limits — Population Thresholds and the Rise of Municipal Public Health (1900-1920)**
- **Score: 63/100**
- **Strengths:** Clever RDD concept with direct policy relevance: threshold-triggered mandates are exactly the kind of quasi-random assignment policymakers recognize. Potential to connect mandated capacity (health departments/sanitation) to mortality and human capital in a tight local comparison.
- **Concerns:** “Many states had thresholds” is not yet an identification design—this lives or dies on (i) assembling the actual statutes, (ii) confirming the threshold is **administratively binding and uniform** (not overridden by charters/exemptions), and (iii) having consistent **city-level outcomes**, especially mortality (often limited to the vital registration area, creating selection and small-N near cutoffs). Also need to confirm the running variable is the **population figure actually used for classification** (often prior census population), otherwise the cutoff can become fuzzy/manipulable (annexations, incorporation).
- **Novelty Assessment:** **Moderately high.** Progressive-era public health impacts are well studied, but exploiting *population-threshold mandates* as an RDD is much less saturated than aggregate panel approaches.
- **Recommendation:** **CONSIDER (conditional on: a clean statute-by-state threshold database; verifying sharpness/fuzziness; securing a mortality dataset with broad city coverage or using alternative outcomes with wide coverage).**

---

**#3: The Age of Innocence — State Age-of-Consent Reform and Female Human Capital Formation (1880s-1920s)**
- **Score: 58/100**
- **Strengths:** Substantively important and genuinely underexplored in economics; could speak to how legal protections for girls affected marriage timing, fertility, and schooling. If you can credibly isolate the reform’s binding margin, the contribution would be real.
- **Concerns:** The proposed **RDD at the age threshold is not automatically credible**: age-of-consent laws criminalize male behavior, but it’s unclear outcomes for girls will change discontinuously exactly at the threshold (enforcement, norms, and exceptions—especially marriage exceptions—may make “treatment” weak). There’s also serious risk of **confounding with other age-based institutions** (schooling/child labor ages) and of weak measurement for key endpoints (e.g., age at marriage not broadly available until later; school attendance is noisy and age-graded).
- **Novelty Assessment:** **Very high** in econ; mostly legal/gender-history literature rather than causal microeconometrics.
- **Recommendation:** **CONSIDER (conditional on: redesign toward a difference-in-discontinuities / event-study around reform dates, documenting bindingness and exceptions; careful choice of outcomes that plausibly move at the margin—e.g., marriage status at ages just below/above, or fertility later by cohort exposed).**

---

**#4: Workers' Compensation and the Moral Hazard of Safety — Occupational Sorting After State Workers' Comp Laws (1911-1948)**
- **Score: 45/100**
- **Strengths:** Interesting mechanism (sorting/moral hazard vs. employer safety investment) and good topical relevance. Large-scale staggered adoption provides surface-level variation, and occupation/industry measures exist in IPUMS.
- **Concerns:** With decennial censuses, the DiD is likely **not credible for parallel trends** (too few pre-periods for early adopters) and extremely vulnerable to **concurrent Progressive-era labor/industrial policies** and industrialization trends that also shift occupational structure. Coverage and generosity varied (often excluding agriculture/domestic/small firms), so “treated” is heterogeneous and may create serious attenuation unless you build coverage-weighted treatment and restrict to plausibly covered workers.
- **Novelty Assessment:** **Moderate.** Workers’ comp has a large literature; the specific “occupational sorting” angle is less crowded, but not so novel that it offsets weak identification.
- **DiD Assessment (mandatory 8 criteria):**
  - **Pre-treatment periods:** **Weak** (for early adopters you effectively have only 1900/1910 pre; ≤2 pre-periods is a dealbreaker for PT testing in a staggered setting)
  - **Selection into treatment:** **Weak** (adoption likely correlated with industrialization, injury risk, labor conflict, court liability regimes—i.e., outcome-related trends)
  - **Comparison group:** **Marginal** (late adopters as controls are systematically different; no never-treated group within sample window)
  - **Treatment clusters:** **Strong** (many states)
  - **Concurrent policies:** **Weak** (factory acts, child labor laws, safety regulation, unionization, and broader structural change coincide)
  - **Outcome-Policy Alignment:** **Strong** (occupation/industry sorting is directly tied to incentives under workers’ comp)
  - **Data-Outcome Timing:** **Marginal** (effective dates vary; census is a point-in-time snapshot; first “post” may reflect partial exposure depending on adoption date and enumeration timing)
  - **Outcome Dilution:** **Marginal** (unless you restrict to covered industries/employee classes, a large share of workers are unaffected → attenuation)
- **Recommendation:** **SKIP (unless substantially redesigned)**—e.g., add annual administrative/industry employment data, construct coverage-weighted treatment intensity, and focus on narrower sets of industries with clearer exposure and more frequent outcomes.

---

**#5: The Pension Before Pensions — State Old-Age Pension Laws and Elderly Independence (1923-1935)**
- **Score: 35/100**
- **Strengths:** High policy relevance historically (precursor to Social Security) and outcomes like living arrangements and labor force participation among the elderly are tightly linked to the program’s intent.
- **Concerns:** The DiD timing is fundamentally weak with decennial census data: essentially **one pre-period (1920)** before the first adoptions, plus massive **Great Depression/New Deal** confounding that differentially affected adopting states. Means-testing and local administration imply heterogeneous and endogenous intensity; without strong pre-trends and richer timing, estimates will be hard to interpret.
- **Novelty Assessment:** **Moderately high** (less studied than Social Security, but not entirely untouched in economic history/public finance). Novelty does not rescue identification.
- **DiD Assessment (mandatory 8 criteria):**
  - **Pre-treatment periods:** **Weak** (1920 is basically the only clean pre; ≤2 pre-periods)
  - **Selection into treatment:** **Weak** (adoption plausibly responds to elderly poverty and fiscal/political conditions—trend-related)
  - **Comparison group:** **Marginal** (non-adopters/late adopters likely structurally different, especially during the Depression)
  - **Treatment clusters:** **Strong** (28 states)
  - **Concurrent policies:** **Weak** (Depression relief, county poor relief changes, and then Social Security/other New Deal programs)
  - **Outcome-Policy Alignment:** **Strong** (labor supply and co-residence/independence are direct margins a pension should affect)
  - **Data-Outcome Timing:** **Marginal** (census reference date issues; many laws mid-decade; “1930” mixes partial/heterogeneous exposure)
  - **Outcome Dilution:** **Strong** *if the analysis is restricted to elderly (65+)*; otherwise weak mechanically—but this is easy to fix by design
- **Recommendation:** **SKIP** (unless you can move to higher-frequency outcomes or a different design—e.g., county-level administrative caseloads/expenditures over time, or discontinuities in eligibility rules such as age/asset cutoffs with observed eligibility measures).

---

### Summary

This is a mixed batch: one standout (Idea 1) with unusually clean quasi-experimental structure and feasible data, and four ideas where the main challenge is making the assignment mechanism truly “as-good-as-random” with the available data. I would **pursue Idea 1 first**; Ideas **5 and 2** are the most promising among the remainder but require substantial upfront legal/data work to avoid a fuzzy, non-binding “threshold” story. Both DiD proposals (Ideas 2 and 4) fail the pre-trends/timing standard with decennial censuses and should be treated as **non-starters without redesign**.