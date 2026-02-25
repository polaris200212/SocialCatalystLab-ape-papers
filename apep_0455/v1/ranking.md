# Research Idea Ranking

**Generated:** 2026-02-25T15:50:33.723407
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7516

---

### Rankings

**#1: Vacancy Tax Expansion and Housing Markets**
- Score: **68/100**
- Strengths: Large, sharp nationwide policy change (Jan 2024) with **2,263 treated communes** gives excellent power and credible event-time variation. Outcomes in DVF (prices, volumes, composition) are tightly linked to the policy’s intended mechanism (discouraging vacancy / shifting supply to market).
- Concerns: **Selection into treatment is not quasi-random**—the expansion explicitly targets “tension” indicators that are correlated with housing trends, so naïve DiD risks mean reversion bias. Only **2 post years (2024–2025)** limits ability to separate short-run anticipation from true effects and to assess dynamic adjustments.
- Novelty Assessment: **Moderately high.** Vacancy/empty-home taxes have a literature (France 1999; Vancouver; some European cases), but **the 2023 French expansion to tourism/second-home markets is genuinely new** and economically distinct from prior “big agglomeration” studies.
- DiD Assessment:
  - Pre-treatment periods: **Marginal** (2020–2022 = 3 years pre for a 2024 effective date; adequate but not great)
  - Selection into treatment: **Marginal** (designation uses market tightness metrics; mitigate by using communes near the threshold / boundary designs and rich pre-trend testing)
  - Comparison group: **Strong** if restricted to near-threshold or within-département matched controls; **Weak** if using all never-treated communes (tourism communes differ fundamentally)
  - Treatment clusters: **Strong** (2,263 treated communes)
  - Concurrent policies: **Marginal** (short-term rental restrictions, local housing measures, and post-2022 macro shocks could differentially hit tourist areas; needs controls/robustness)
  - Outcome-Policy Alignment: **Strong** (tax on vacancy should affect transactions/prices/volumes/composition directly through supply/holding incentives)
  - Data-Outcome Timing: **Strong** (DVF has exact transaction dates; treatment effective **Jan 2024** → define post as transactions from 2024-01-01 onward; can drop transition months if needed)
  - Outcome Dilution: **Marginal-to-Strong** (policy targets vacant units, but in many newly treated tourist communes vacancy/second homes are a large share; still, price effects may be diluted if truly vacant share is small—should estimate heterogeneity by baseline vacancy/second-home share)
- Recommendation: **PURSUE (conditional on: near-threshold/border comparison strategy; demonstrate strong pre-trends; pre-register handling of tourism-specific shocks and Airbnb/STR policy overlap; heterogeneity by baseline vacancy/second-home intensity).**

---

**#2: Municipal Mergers and Local Economic Activity**
- Score: **60/100**
- Strengths: Big, policy-relevant institutional change with **hundreds of treated units** and **long-run pre-periods** available in SIRENE—this can support serious pre-trend diagnostics and dynamic/event-study estimates. France is a high-stakes context (very small communes + fiscal incentives) where external validity from Denmark/Japan is limited.
- Concerns: Treatment is **voluntary**, so selection is a first-order threat (mergers may be chosen in response to fiscal stress/decline or stronger local leadership). Also, mergers change administrative codes/boundaries—if not carefully harmonized, you can create **mechanical “effects”** in firm counts due to recoding rather than real activity.
- Novelty Assessment: **Moderate.** Municipal merger effects are well-studied internationally, but **France-specific evidence on economic activity effects is relatively thin**, and the incentive design (DGF guarantees) is unusual.
- DiD Assessment:
  - Pre-treatment periods: **Strong** (SIRENE supports many years pre-treatment for 2015–2025 mergers)
  - Selection into treatment: **Marginal** (voluntary + potentially trend-responsive; must show flat pre-trends and/or use stronger designs—e.g., exploit incentive eligibility rules, neighbor-wave exposure, or administrative constraints if available)
  - Comparison group: **Marginal** (never-merged small communes can be comparable, but geography and local governance capacity differ; matching within département and baseline trends is essential)
  - Treatment clusters: **Strong** (~800 communes nouvelles / many underlying communes)
  - Concurrent policies: **Marginal** (rural development programs, broadband rollout, intercommunality changes; not fatal but must be addressed)
  - Outcome-Policy Alignment: **Strong** (mergers plausibly change administrative capacity/taxes/services that affect firm entry/survival; SIRENE outcomes match mechanism)
  - Data-Outcome Timing: **Strong** if outcomes are constructed annually with clear exposure (many mergers effective **Jan 1**; define post as full calendar years after effective date)
  - Outcome Dilution: **Strong** (the entire commune’s administrative environment changes; not a tiny targeted subgroup)
- Recommendation: **CONSIDER (upgrade to PURSUE if: you can (i) fully harmonize geography/codes over time; (ii) demonstrate strong pre-trends; and ideally (iii) add a plausibly exogenous instrument/eligibility discontinuity or tightly matched within-département event-study design).**

---

**#3: Energy Efficiency Labels and Housing Price Capitalization**
- Score: **48/100**
- Strengths: Very policy-relevant (rental bans on “passoires thermiques” are central in France) and potentially large welfare implications; price capitalization is the right object. If property-level DPE can be reliably linked to transactions, the sample size could be enormous.
- Concerns: As proposed, this is at high risk of **data/measurement failure** and **timing/definition problems**: DPE methodologies changed in 2021, DVF DPE coverage may be incomplete, and linking ADEME DPE to DVF is non-trivial. Treated (F/G) and controls (A–D) differ structurally, so a simple DiD can be badly confounded without very rich controls or repeat-sales/property fixed effects.
- Novelty Assessment: **Moderate-to-low on the outcome (capitalization), higher on the policy.** Energy label capitalization is heavily studied (EPC/DPE-type labels across many countries), but **France’s binding rental ban** is more unusual; still, the empirical “prices vs. labels” question has many predecessors.
- DiD Assessment:
  - Pre-treatment periods: **Weak** (credible DiD needs multiple pre periods with consistent DPE measurement; if DPE appears reliably only post-2021 and/or the rating algorithm changes, pre-trends are not testable in a clean way)
  - Selection into treatment: **Marginal** (ratings are tied to building characteristics, but those characteristics also drive differential price trends and renovation responses)
  - Comparison group: **Marginal** (A–D properties are not naturally comparable to F/G; needs within-small-area × property-type cells, or repeat-sales)
  - Treatment clusters: **Strong** (millions of properties)
  - Concurrent policies: **Weak-to-Marginal** (major overlaps: renovation subsidies like MaPrimeRénov’, credit conditions, local rent controls; can be handled but only with careful design)
  - Outcome-Policy Alignment: **Strong** (future rental prohibition should affect asset prices via expected rental income and renovation costs)
  - Data-Outcome Timing: **Marginal** (key enforcement date for G is **Jan 2025**; DVF “post” is essentially 2025 only, unless you study the **July 2021** opposability/announcement effects—then you need clean pre-2021 ratings/transactions comparability)
  - Outcome Dilution: **Strong** (rating directly tags the affected asset; not diluted)
- Recommendation: **SKIP (unless you can secure: (i) high-coverage transaction-linked DPE with stable measurement over time or a credible way to harmonize pre/post-2021 ratings; (ii) a design like repeat-sales/property fixed effects or very tight geographic/property-type comparisons; (iii) a clear event date with ≥3–5 clean pre years).**

---

**#4: Wind Farms and Property Values in France**
- Score: **42/100**
- Strengths: France is underrepresented in the wind/property value causal literature, and ODRE commissioning dates are a strong starting point. DVF provides rich transaction microdata and exact dates, which is a big advantage if paired with turbine proximity.
- Concerns: As written (commune-level first commissioning + DVF 2020–2025), DiD is likely to fail on **pre-trend length** and especially **outcome dilution**: only a small share of homes in a commune are close enough to be affected, so commune-average effects will be attenuated toward zero. Siting is not random (wind resources + permitting + local politics), so selection on trends is plausible, and the earliest treated cohorts have too little pre-period to test it well.
- Novelty Assessment: **Moderate.** Many hedonic/wind disamenity studies exist (US/UK/Germany/Scandinavia); **France-specific causal evidence is indeed thinner**, which helps, but it’s not a new research question globally.
- DiD Assessment:
  - Pre-treatment periods: **Weak** (for earliest treated cohort in DVF window—e.g., 2022—only **2020–2021** pre = 2 years, a checklist dealbreaker unless you drop early cohorts)
  - Selection into treatment: **Marginal** (wind siting is plausibly unrelated to *short-run* house price shocks, but correlated with rural decline and amenities; must show strong pre-trends and control for local trajectories)
  - Comparison group: **Marginal** (never-treated communes differ systematically; needs tight matching within département and similar rurality + possibly border discontinuities)
  - Treatment clusters: **Strong** (~216 newly treated communes in 2022–2025)
  - Concurrent policies: **Strong-to-Marginal** (few directly coincident national policies tied to the commissioning date, but local infrastructure/compensation packages could coincide)
  - Outcome-Policy Alignment: **Strong** (property transaction prices should reflect local disamenities/amenities from turbines)
  - Data-Outcome Timing: **Strong** (transactions have dates; commissioning date is known—can define exposure precisely by month/quarter)
  - Outcome Dilution: **Weak** (likely <10% of homes are within strong exposure radius/viewshed; commune-level treatment without distance/viewshed will mechanically attenuate effects)
- Recommendation: **SKIP (unless redesigned around micro-geography: geocode transactions and estimate effects by distance/viewshed; and restrict to cohorts with ≥3–5 pre years, which likely requires extending transaction data earlier than 2020 or using alternative price sources).**

---

### Summary

This batch has **one clearly fundable, policy-timely DiD** (vacancy tax expansion) provided the team commits to a near-threshold/border comparison and tight pre-trend validation. Municipal mergers are promising but **selection and boundary harmonization** are major execution risks. The energy-label and wind-farm proposals both currently violate key DiD checklist items (pre-period sufficiency / measurement stability; and outcome dilution), so I would not fund them without a substantial redesign to fix those identification problems.