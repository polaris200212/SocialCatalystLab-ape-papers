# Research Idea Ranking

**Generated:** 2026-02-27T11:12:24.153172
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 9871

---

### Rankings

**#1: Flood Re and the Price of Climate Risk — How Government Reinsurance Recapitalized Flood-Prone Property (Idea 3)**
- **Score:** 78/100
- **Strengths:** Very high novelty with a clean, policy-driven eligibility rule (pre‑2009 construction) that creates a compelling within–flood-zone control. Outcome (transaction prices) is directly policy-relevant and measured at high frequency/scale.
- **Concerns:** The key “built pre‑2009” eligibility variable is not reliably observed in Land Registry PPD (the new-build flag is not a construction-year variable), so misclassification could seriously bias the DDD. Flood-zone assignment at the postcode level can be noisy without high-quality spatial joins (and coastal/surface-water risk may not align with EA river/sea zones).
- **Novelty Assessment:** Highly novel in economics; Flood Re is discussed in policy but (to my knowledge) not yet exploited as a quasi-experiment for price capitalization.
- **Recommendation:** **PURSUE (conditional on: obtaining defensible pre/post‑2009 construction-year data—e.g., EPC “construction age band” or another address-level attribute source; implementing robust GIS assignment + sensitivity to boundary error; pre-trend/event-study checks and placebo zones/bands).**

---

**#2: The Waterbed Effect — Crime Displacement from Selective Licensing of England's Private Rented Sector (Idea 1)**
- **Score:** 68/100
- **Strengths:** Strong “policy debate meets measurable outcomes” framing (crime + displacement + capitalization into prices) with unusually rich, high-frequency crime data and many adopters over time. The displacement/buffer design is a good way to move beyond average treatment effects.
- **Concerns:** The biggest threat is **treatment definition**: selective licensing is typically **sub-LA and boundary-defined**; coding treatment as “LA adopted” will create severe misclassification and attenuation. Adoption is plausibly triggered by persistent ASB/management problems, so selection into treatment is a real risk unless you can show clean pre-trends (and/or use within-LA treated vs untreated areas).
- **Novelty Assessment:** Quite novel—selective licensing has limited causal work and essentially none (to my knowledge) on crime/property prices or spatial displacement.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** (crime data start 2010; early adopters pre‑2010 have no pre-period—must drop them or focus on later waves to get ≥5 pre-years)
  - **Selection into treatment:** **Marginal** (likely adopted due to persistent/local problems; not obviously trend-triggered everywhere, but you must document pre-trends carefully)
  - **Comparison group:** **Strong** (many never-/not-yet-treated English LAs/LSOAs; feasible to match/weight to improve comparability)
  - **Treatment clusters:** **Strong** (30+ adopters, though effective clusters shrink if you drop early adopters)
  - **Concurrent policies:** **Marginal** (local policing/regeneration/housing enforcement can co-move; needs controls and robustness)
  - **Outcome-Policy Alignment:** **Strong** for ASB/property crime mechanisms; **property prices** are a coherent welfare/capitalization outcome if displacement is modeled explicitly
  - **Data-Outcome Timing:** **Marginal** (Police API is monthly; licensing “effective” dates can be mid-month—should define first treated month as the first *full* month after the effective date; property transactions should use completion dates and aggregate to month/quarter)
  - **Outcome Dilution:** **Marginal → Weak if mis-coded at LA-level** (if you correctly tag only designated LSOAs, dilution is manageable; if you treat whole LA, most observations are untreated and effects will be mechanically attenuated)
- **Recommendation:** **PURSUE (conditional on: digitizing/obtaining exact designation boundaries and assigning treatment at LSOA-within-designation level; dropping pre‑2010 treated adopters; pre-trend diagnostics + sensitivity to endogenous designation).**

---

**#3: Last Orders — How Alcohol Cumulative Impact Policies Reshape Local Economies (Idea 2)**
- **Score:** 60/100
- **Strengths:** Large number of policy adoptions (good power) and clear mechanisms; adding firm entry/exit and property values is a genuine contribution beyond the public-health hospital-admissions literature. The proposed within-LA comparison (CIA zones vs non-zones) is the right direction.
- **Concerns:** CIA implementation is zone-based and often targeted to nightlife hot spots—**selection into treatment** and **concurrent policies** (policing surges, BID initiatives, nightlife strategies) are major threats. Data work is nontrivial: post‑2012 CIA dates/boundaries are not centrally compiled, and mis-timing/mis-mapping will undermine the event study.
- **Novelty Assessment:** Moderately novel: there is an existing applied public-health literature (notably the Bristol group), so you are not first to “CIA → outcomes,” but you likely *are* early on modern DiD + economic outcomes (firms/property) and displacement.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Marginal** (Police API starts 2010; many CIAs begin earlier—need to focus on post‑2010 adoptions to get adequate pre-periods)
  - **Selection into treatment:** **Marginal** (often adopted because areas already have alcohol-related disorder; within-LA zone vs non-zone helps, but zone designation is itself outcome-related)
  - **Comparison group:** **Marginal** (treated LAs skew urban; best comparison is within-LA non-zone areas + matched urban never-treated LAs)
  - **Treatment clusters:** **Strong** (75+ LAs / many CIAs)
  - **Concurrent policies:** **Weak → Marginal** (potential dealbreaker unless you explicitly measure/control for co-incident policing/licensing enforcement and other place-based interventions around adoption)
  - **Outcome-Policy Alignment:** **Strong** for **licensed-premises entry/exit**; **Marginal/Strong** for alcohol-related crime (plausible, but needs careful category construction and spillovers)
  - **Data-Outcome Timing:** **Marginal** (adoption vs effective enforcement dates may differ; outcomes monthly—need “full exposure” definitions)
  - **Outcome Dilution:** **Marginal** for crime at LSOA (only some LSOAs are in CIA zones); **Strong** for firm outcomes if you geolocate premises to CIA zones
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: you can compile a validated CIA zone/date panel at LSOA resolution; and you can credibly address concurrent enforcement/policing changes—e.g., explicit controls, stacked DiD around clean adoptions, or focusing on boundary-spillover designs).**

---

**#4: Creative Destruction Deferred — The Local Labor Market Costs of COVID Insolvency Protection (Idea 4)**
- **Score:** 55/100
- **Strengths:** High policy relevance and genuine novelty: CIGA’s suspension/constraints are important and understudied, and the “zombie concentration” measurement effort could be a standalone contribution. The question is timely for evaluating crisis-era business support.
- **Concerns:** Identification is the central weakness: a Bartik/shift-share style exposure design will be vulnerable to “zombie concentration” proxying for underlying local decline, sector mix, or COVID shocks. Data feasibility is also uncertain if the design truly requires accounts/XBRL parsing and many firms lack usable accounts.
- **Novelty Assessment:** High—surprisingly little causal work directly on UK CIGA and its unwind, especially at local labor market level.
- **Recommendation:** **CONSIDER (only if you can strengthen identification—e.g., pre-trend/event-study validations using multiple pre-COVID years; rich controls for sector mix + COVID restrictions exposure; alternative zombie measures not requiring accounts; and transparent inference robust to shift-share concerns).**

---

**#5: Planning by Stealth — Employment Displacement from Office-to-Residential Permitted Development Rights (Idea 5)**
- **Score:** 45/100
- **Strengths:** Important policy topic with clear stakeholder demand (housing supply vs jobs) and long time series availability in principle. Some novelty in using Article 4 variation explicitly.
- **Concerns:** As proposed, DiD credibility is poor: Article 4 adoption is highly endogenous (places with valuable offices/adverse conversion pressures choose to block), treated units are borderline in number and clustered in time (many 2022), and LA-level employment is a diluted outcome for a policy affecting a subset of sites/sectors. Concurrent housing/office-market shocks (Brexit, COVID/WFH) make parallel trends especially doubtful.
- **Novelty Assessment:** Moderate: while rigorous econ DiD may be limited, the policy itself is heavily discussed and there is a sizeable planning/urban studies literature; the main barrier is credible identification, not “no one has looked.”
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (employment series exist well pre‑2013)
  - **Selection into treatment:** **Weak** (Article 4 is a strategic local response to anticipated/ongoing conversions and local office-market conditions)
  - **Comparison group:** **Weak** (Article 4 LAs are atypically dense/central; “no Article 4” LAs are not comparable without very strong design changes)
  - **Treatment clusters:** **Marginal** (≈15–20, with clustering in adoption timing)
  - **Concurrent policies:** **Weak** (major contemporaneous shocks/policies affecting offices and employment—WFH/COVID, city-center recovery policies)
  - **Outcome-Policy Alignment:** **Marginal** (LA-level employment is an indirect proxy; the policy affects specific buildings/areas, not the entire LA economy)
  - **Data-Outcome Timing:** **Marginal** (annual outcomes risk partial exposure and timing ambiguity around Article 4 notice/confirmation periods)
  - **Outcome Dilution:** **Weak** (affected employment is a small share of total LA employment; effects likely swamped in aggregate measures)
- **Recommendation:** **SKIP (unless redesigned around building-level conversion data and much tighter geography—e.g., microdata on actual PDR conversions + boundary-based comparisons).**

---

### Summary

This is a strong batch on **novel UK policies**, but the main fault line is identification: the two zone-based licensing ideas (Ideas 1–2) can be excellent **only if** treatment is mapped at the correct sub-LA geography and timing, and if pre-trends look clean. The standout to pursue first is **Flood Re (Idea 3)** because it has a potentially textbook eligibility-based design—conditional on solving the construction-year measurement problem—while **Idea 5** fails multiple DiD checklist items (endogeneity + dilution) and should be dropped absent a major redesign.