# Research Idea Ranking

**Generated:** 2026-02-25T17:41:20.520096
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 10625

---

### Rankings

**#1: The Lex Weber Shock: Second Home Caps and Tourism Labor Markets**
- **Score:** 78/100
- **Strengths:** Very compelling policy shock with a *sharp* rule (20% cap) at the municipality level and lots of units (≈2,100), enabling both DiD and credible “local” designs (RDD / diff-in-discontinuities near 20%). Clear policy relevance well beyond Switzerland.
- **Concerns:** The key design choice is *when treatment starts* (2012 vote vs 2016 implementation); using 2012 risks having essentially no pre-period, while using 2016 risks anticipatory effects (2012–2015). You must also lock treatment status using **pre-2012** second-home shares to avoid endogenous reclassification.
- **Novelty Assessment:** Moderately novel. Lex Weber is studied (notably on house prices), but labor-market/sectoral employment effects at municipality level remain much less explored.
- **DiD Assessment (if applicable):**
  - **Pre-treatment periods:** **Strong** (if you treat **2016** as the main start: 2011–2015 gives 5 pre-years; if you treat 2012 as start it becomes **Weak**)
  - **Selection into treatment:** **Strong** (above/below 20% is predetermined; low scope for manipulation if fixed at baseline)
  - **Comparison group:** **Strong** (especially near the 20% threshold; can implement RDD-style local comparisons)
  - **Treatment clusters:** **Strong** (hundreds of treated municipalities; inference feasible)
  - **Concurrent policies:** **Marginal** (CHF appreciation ~2015, tourism cycles, COVID—need year FE and sector-specific checks; but these are plausibly common shocks)
  - **Outcome-Policy Alignment:** **Strong** (policy restricts second-home construction → affects construction/real estate/tourism activity and thus sector employment)
  - **Data-Outcome Timing:** **Marginal → Strong** (implementation is **Jan 1, 2016**; STATENT is annual—**confirm the STATENT reference period/date**; if it’s an end-year or annual average, 2016 is post; if mid-year, adjust/drop partial exposure years)
  - **Outcome Dilution:** **Marginal** (municipality-wide employment includes many unaffected workers; mitigated by focusing on *tourism-linked sectors* and/or distributional outcomes like small-firm employment)
- **Recommendation:** **PURSUE (conditional on: (i) defining treatment using pre-2012 second-home shares; (ii) making 2016 the main “onset” with an explicit 2012–2015 anticipation window; (iii) implementing a near-threshold design as the credibility anchor)**

---

**#2: Fiscal Transparency and Government Spending: HRM2 Accounting Reform**
- **Score:** 66/100
- **Strengths:** High novelty and a rare staggered rollout across essentially the full set of cantons. If outcomes are chosen carefully, this can speak directly to a big policy question (does transparency change fiscal behavior?).
- **Concerns:** Serious risk that “effects” are **accounting artifacts** (mechanical breaks in measured debt/deficits) rather than real policy changes. Adoption timing may correlate with unobserved administrative capacity or fiscal preferences (endogenous “readiness”).
- **Novelty Assessment:** High. The IPSAS/HRM2 literature is mostly descriptive; credible causal evidence is scarce.
- **DiD Assessment (if applicable):**
  - **Pre-treatment periods:** **Strong** (early adopters 2009; many late adopters → long pre for later cohorts)
  - **Selection into treatment:** **Marginal** (readiness/IT capacity is not random; could correlate with fiscal management trends)
  - **Comparison group:** **Strong** (other cantons are plausible controls; also not-yet-treated can serve as controls)
  - **Treatment clusters:** **Strong** (up to 26 cantons; still “small-N” but workable with wild bootstrap/randomization inference)
  - **Concurrent policies:** **Marginal** (cantonal fiscal rules, tax reforms, debt-brakes may coincide; must inventory and control/event-study them)
  - **Outcome-Policy Alignment:** **Marginal** (*Good* if you focus on outcomes not mechanically redefined—e.g., tax rates, spending composition in real terms, borrowing costs, voter approval; *problematic* if you use “debt” that changes definition under accrual)
  - **Data-Outcome Timing:** **Marginal** (adoption often applies to a fiscal year; **confirm fiscal-year alignment** and whether the first “treated” year is a partial reporting year)
  - **Outcome Dilution:** **Strong** (reform applies to essentially the whole public sector accounting/reporting environment)
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: you pre-register “non-artifact” outcomes—tax rates, bond yields/credit spreads, expenditure composition; and document comparability/bridge tables across HRM1→HRM2)**

---

**#3: Cantonal Energy Laws and the Building Heating Transition**
- **Score:** 58/100
- **Strengths:** Extremely policy-relevant and plausibly under-studied as a *causal* question; many treated cantons (≈22) gives better DiD mechanics than most Swiss federalism projects.
- **Concerns:** Two identification threats are first-order: (i) **endogenous adoption** (greener cantons with steeper pre-trends adopt earlier), and (ii) using **building-stock shares** risks severe **outcome dilution** because regulations primarily affect *marginal replacements/new installs*, not the whole stock immediately.
- **Novelty Assessment:** Moderately high. There is building-energy economics work, but using MuKEn staggered cantonal reforms as the core identification is less common.
- **DiD Assessment (if applicable):**
  - **Pre-treatment periods:** **Strong** (late adopters have long pre; early adopters less so, but overall enough)
  - **Selection into treatment:** **Weak** (likely correlated with climate preferences, subsidy aggressiveness, and pre-existing heat-pump trends unless you find quasi-exogenous timing—e.g., close referendum outcomes / legal deadlines)
  - **Comparison group:** **Marginal** (only ~4 never-treated by 2023; not-yet-treated helps, but late adopters may be systematically different)
  - **Treatment clusters:** **Strong** (many cantons treated; cluster inference feasible)
  - **Concurrent policies:** **Marginal → Weak** (subsidies, federal CO₂ levy changes, energy-price shocks; if these differ by canton and coincide with law changes, bias risk is real)
  - **Outcome-Policy Alignment:** **Marginal** (laws target *heating choice at replacement/new build*; a stock-share outcome is only an indirect proxy unless you can measure flows)
  - **Data-Outcome Timing:** **Marginal** (need exact effective dates vs BFS stock measurement date; partial exposure likely in first year)
  - **Outcome Dilution:** **Weak** (annual heating replacements are a small fraction of the stock—likely <10%—so stock-share effects attenuate heavily; you need flow outcomes: permits/installs, or changes among “buildings with heating system updated in year t” if observable)
- **Recommendation:** **SKIP unless redesigned**. **CONSIDER only if** you can (i) shift to **flow** outcomes (new installs/replacements), and/or (ii) exploit **close canton referenda / rejected proposals** as quasi-random timing, and (iii) produce strong pre-trend diagnostics by cohort.

---

**#4: Cantonal Minimum Wages and Low-Wage Employment in Switzerland**
- **Score:** 48/100
- **Strengths:** Great administrative outcome data (STATENT census) and a clean, well-defined policy change. Sector triple-differences are a sensible way to improve credibility and interpretability.
- **Concerns:** The design is fundamentally constrained by **too few treated cantons (5)**—standard DiD inference is fragile, and treated cantons are linguistically/structurally distinct (GE/NE/JU/TI/BS). COVID overlap for later adopters further contaminates staggered timing.
- **Novelty Assessment:** Low-to-moderate. Minimum wages are extremely studied globally; Switzerland/cantonal variation is less studied, but not enough to offset identification limits from only five treated units.
- **DiD Assessment (if applicable):**
  - **Pre-treatment periods:** **Strong** (2011–2016 pre for first adopter)
  - **Selection into treatment:** **Marginal** (referenda help, but adoption plausibly responds to local low-wage conditions/politics)
  - **Comparison group:** **Marginal → Weak** (treated cantons differ systematically from many controls; within-canton sector DDD helps but doesn’t solve canton-level confounding)
  - **Treatment clusters:** **Weak** (**5 treated** cantons; sector-level observations do *not* create independent treatment clusters)
  - **Concurrent policies:** **Marginal → Weak** (COVID for 2020–2022 cohorts; also cantonal labor-market policies may differ)
  - **Outcome-Policy Alignment:** **Strong** (minimum wage should affect employment in low-wage sectors)
  - **Data-Outcome Timing:** **Marginal** (several effective dates are mid-year—Aug 2017, Nov 2020, Jul 2022; annual employment measures imply partial exposure unless you drop/adjust first year—**confirm STATENT timing**)
  - **Outcome Dilution:** **Marginal** (sector employment includes many workers above the minimum; without wage-distribution data, estimated effects may be attenuated)
- **Recommendation:** **SKIP (unless you can add a stronger design element)**—e.g., border discontinuities at canton borders with municipality-level employment, or compelling small-sample inference + robustness focused only on early adopters (NE/JU) pre-COVID.

---

**#5: Professionalization of Child Protection: The KESB Reform and Family Outcomes**
- **Score:** 40/100
- **Strengths:** Very high novelty and genuine policy importance; the reform is controversial and evidence would be valuable.
- **Concerns:** Identification is weak: the main reform is nationwide (no untreated controls), and cross-canton “intensity” choices are highly endogenous (politics, baseline caseload, urbanization). Outcomes likely reflect reporting/threshold changes, not necessarily child well-being.
- **Novelty Assessment:** Very high (credible causal evidence is scarce), but novelty cannot compensate for weak identification.
- **Recommendation:** **SKIP (for now)**. Revisit only if you can find a sharper source of exogenous variation (court rulings, funding discontinuities, boundary changes in KESB catchment areas, or discontinuous staffing formulas) and richer outcome data beyond case counts.

---

### Summary

This is a strong batch on **novel Swiss federalism policy variation**, but only one idea (Lex Weber) is immediately “publication-grade” on identification. HRM2 is the best second option if you aggressively guard against **mechanical accounting breaks**. The energy-laws and minimum-wage proposals are interesting but currently face major DiD threats (respectively **endogenous adoption + stock-outcome dilution**, and **too few treated clusters + COVID/timing issues**).