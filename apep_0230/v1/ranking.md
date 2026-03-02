# Research Idea Ranking

**Generated:** 2026-02-11T18:40:29.472220
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7627

---

### Rankings

**#1: Neighbourhood Planning and House Prices — Does Community Control Over Land Use Raise Property Values?**
- **Score: 76/100**
- **Strengths:** Very large-scale, policy-relevant setting with rich transaction microdata and many treatment cohorts (1,197 parishes) over a long window; outcome is tightly linked to the policy channel (land-use control → expected supply/amenities → prices). Staggered adoption with exact “made” dates makes modern CS-DiD/event-study designs feasible with high power.
- **Concerns:** Adoption is plausibly **endogenous to local development pressure/price dynamics** (parishes mobilize because they anticipate growth or fear it), so parallel trends is the central threat; also need to ensure treatment timing is aligned (referendum vs “made” date vs when policies bite in planning decisions). Local authority planning changes (local plan updates, site allocations) could coincide with NDP activity and contaminate estimates if not handled.
- **Novelty Assessment:** **High.** UK planning constraints and prices are heavily studied, but **neighbourhood plans as a staggered, referendum-based institutional shock** has not (to my knowledge) been the subject of a mature causal DiD literature—this is meaningfully new.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (Land Registry back to 1995; ample pre-period for post-2013 adopters).
  - **Selection into treatment:** **Marginal** (community choice; likely correlated with local trends/anticipated development). Mitigation: restrict to within-local-authority comparisons; add LA×year fixed effects; show strong pre-trends balance and use HonestDiD.
  - **Comparison group:** **Strong/Marginal** (can be **Strong** if controls are parishes within same local authority and similar baseline urban/rural status; otherwise **Marginal** due to systematic differences in where NDPs occur).
  - **Treatment clusters:** **Strong** (>>20).
  - **Concurrent policies:** **Marginal** (national shocks are fine with time FE, but **local plan revisions, greenbelt reviews, major infrastructure projects** may be spatially correlated with NDP adoption).
  - **Outcome-Policy Alignment:** **Strong** (house prices are a direct capitalization measure of expected future supply restrictions/amenities/planning certainty).
  - **Data-Outcome Timing:** **Strong/Marginal** (transactions are dated precisely; **but** if you collapse to annual parish means, partial-year exposure around adoption attenuates effects). Best practice: monthly/quarterly panels; define treatment at “made” date; exclude/weight the adoption year by exposure share.
  - **Outcome Dilution:** **Strong** (policy plausibly affects the whole parish housing stock via expectations; not a tiny targeted subgroup).
- **Recommendation:** **PURSUE (conditional on: (i) tight within-LA research design and controls for local plan changes; (ii) timing handled at monthly/quarterly frequency; (iii) clear evidence against differential pre-trends for adopters vs non-adopters).**

---

**#2: Academy School Conversions and Teacher Labour Markets**
- **Score: 62/100**
- **Strengths:** Big policy with many treated units and clear conversion dates; teacher retention/pay outcomes are directly policy-relevant and less saturated than test-score effects. School-level panels allow rich fixed effects and heterogeneity (converter vs sponsored academies; phases; baseline Ofsted).
- **Concerns:** **Selection into treatment is the core risk**: sponsored academies are often forced due to poor performance; converter academies self-select, plausibly based on leadership/trajectory—both threaten parallel trends for teacher outcomes. Data access is nontrivial: the School Workforce Census is typically restricted and may limit feasibility/timeliness.
- **Novelty Assessment:** **Moderate.** “Academies” are extensively studied, but **teacher labour-market outcomes** are less so; still, this won’t read as a brand-new policy area.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** (for teacher outcomes, SWC-era consistent measures are not as long as attainment series; early conversions may have limited clean pre-period).
  - **Selection into treatment:** **Marginal/Weak** (can become **Marginal** if you (a) separate converter vs sponsored, (b) restrict to plausibly comparable eligibility sets, or (c) use an instrument/threshold design around Ofsted/eligibility; otherwise it’s **Weak**).
  - **Comparison group:** **Marginal** (credible if you compare within local area/phase and baseline Ofsted/prior attainment bands; otherwise converting and non-converting schools differ structurally).
  - **Treatment clusters:** **Strong** (>>20).
  - **Concurrent policies:** **Marginal** (many national education reforms; less problematic with year FE, but could interact with academy status or local authority dynamics).
  - **Outcome-Policy Alignment:** **Strong** (academies’ autonomy over pay/HR plausibly maps directly to retention, turnover, pay distributions).
  - **Data-Outcome Timing:** **Marginal** (conversions often effective September; SWC snapshot is typically autumn—first “post” measure may reflect very partial exposure). Safer to define first treated outcome as the following school year.
  - **Outcome Dilution:** **Strong** (teacher outcomes measured at the treated school; no dilution).
- **Recommendation:** **CONSIDER (conditional on: (i) secured SWC access; (ii) a design that addresses selection—at minimum converter vs sponsored stratification + rich pre-trend/event-study, ideally an eligibility/Ofsted-based quasi-exogenous lever; (iii) treatment timing defined to ensure full-year exposure).**

---

**#3: Universal Credit Rollout and the Self-Employment Trap — Does the Minimum Income Floor Reduce Entrepreneurship?**
- **Score: 44/100**
- **Strengths:** Administratively scheduled rollout across many Jobcentres offers potential quasi-experimental variation; the MIF is a sharp policy margin that policymakers care about (self-employment incentives vs fraud/targeting).
- **Concerns:** Two serious identification problems: (i) **Outcome dilution**—the MIF only affects *UC-claiming* self-employed (and even then often after a start-up period), while LA-level self-employment rates mostly reflect people never exposed to UC/MIF; (ii) **timing/intensity mismatch**—“UC full service” rollout does not instantly move the stock of self-employed onto MIF, and the MIF is typically not binding during an initial start-up period, so first treated periods may have near-zero exposure.
- **Novelty Assessment:** **Moderate.** UC has a sizable literature; the *MIF-specific* causal effect on self-employment is less developed, but the overall space is not new.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (in principle).
  - **Selection into treatment:** **Marginal** (rollout is administratively scheduled, but early sites may differ in capacity/urbanization; needs documentation).
  - **Comparison group:** **Marginal** (local areas differ; plausible with rich controls/region trends, but not automatic).
  - **Treatment clusters:** **Strong** (>>20).
  - **Concurrent policies:** **Marginal/Weak** (UC bundles multiple reforms—conditionality, payment frequency, digital-by-default—so attributing effects specifically to **MIF** is hard without an outcome directly tied to MIF exposure).
  - **Outcome-Policy Alignment:** **Marginal** (self-employment rate is an indirect proxy; better would be **UC self-employed claimant counts**, self-employed claim entry/exit, or earnings distributions among UC self-employed).
  - **Data-Outcome Timing:** **Weak** (UC rollout ≠ immediate MIF exposure; plus start-up period delays; measured outcomes likely reflect lots of non-exposed months even “after” rollout).
  - **Outcome Dilution:** **Weak** (affected group is plausibly far below 10% of the LA self-employment denominator, especially pre-managed-migration).
- **Recommendation:** **SKIP (unless you can obtain/administer data on UC claimants’ self-employment status and MIF binding exposure, or a design leveraging the COVID-era MIF suspension with outcomes measured within the UC self-employed claimant population).**

---

**#4: Business Improvement Districts and Local Economic Vitality — Does Collective Action Save the High Street?**
- **Score: 33/100**
- **Strengths:** Clear policy object with many adoptions and direct relevance to “town centre decline” policy; crime and business churn are plausible outcomes if measured at the correct geography.
- **Concerns:** As proposed, **data feasibility and alignment are major blockers**: UK Land Registry Price Paid Data is primarily **residential**, not a clean measure of commercial property values, and BID areas rarely align with LSOA/LA boundaries (high risk of misclassification and severe dilution). Identification is also weak because BID formation is typically a response to (or anticipation of) local decline/redevelopment—strong selection concerns.
- **Novelty Assessment:** **Moderate.** There is a sizable international BID literature (especially US); UK-wide modern causal evidence may be thinner, but the topic is not untouched.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (in principle, many years available for crime and other admin series).
  - **Selection into treatment:** **Weak** (BIDs are typically created because areas are changing/struggling—selection on trends is very plausible).
  - **Comparison group:** **Weak/Marginal** (finding truly comparable non-BID micro-areas is hard; within-city comparisons help but require strong spatial design).
  - **Treatment clusters:** **Strong** (>>20).
  - **Concurrent policies:** **Weak/Marginal** (regeneration funding, pedestrianization, policing initiatives often coincide with BID creation).
  - **Outcome-Policy Alignment:** **Marginal** (crime aligns; “commercial values via Land Registry” does **not** align well as described; business demography at LA is too coarse).
  - **Data-Outcome Timing:** **Marginal** (ballot vs operational start dates; effects may phase in with levy cycles).
  - **Outcome Dilution:** **Weak** (if outcomes are at LA/LSOA rather than true BID polygon, treated share can be small and mismeasured).
- **Recommendation:** **SKIP (unless you first secure accurate BID boundaries + a credible outcome at that exact geography—e.g., VOA non-domestic rating list/rents, footfall, vacancies, or card-spend—and a design that better addresses selection, such as close-ballot RDD or matched-neighborhood synthetic controls).**

---

### Summary

This is a strong batch on policy relevance, but only **Idea 1** currently clears the “credible DiD + feasible data + novel contribution” bar without major redesign. **Idea 4** is potentially publishable but hinges on (i) restricted data access and (ii) a sharper strategy for selection into academy conversion. **Ideas 2 and 3** fail key DiD checklist items—especially **timing/intensity and outcome dilution (Idea 2)** and **data/outcome mismatch plus severe selection (Idea 3)**—and should be deprioritized unless redesigned around better-aligned outcomes or quasi-random variation.