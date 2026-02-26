# Research Idea Ranking

**Generated:** 2026-02-26T12:20:17.206718
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6077

---

### Rankings

**#1: Across the Channel — Social Networks and the Cross-Border Economic Effects of Brexit on French Local Economies (Idea 1)**
- **Score: 76/100**
- **Strengths:** Strong combination of (i) a plausibly exogenous foreign shock (Brexit) and (ii) rich within-France heterogeneity via pre-determined social ties; the Borusyak-Hull-Jaravel shift-share framework plus the proposed placebo/permutation diagnostics is close to current best practice. Data feasibility is unusually high (open, granular, long panel; multiple outcomes).
- **Concerns:** Exclusion restriction is the central risk: SCI-to-UK may proxy for other channels directly affected by Brexit (tourism, migration/second homes, port proximity, industry composition) that affect French outcomes even absent the “UK regional shock” component. Also, UK “regional shocks” (e.g., GVA changes) may partly reflect France-linked adjustments (reflection problem), requiring careful shock construction and robustness.
- **Novelty Assessment:** **High.** There is adjacent work (Burchardi-Hassan style social-ties shift-share; Brexit effects papers), but *cross-border* SCI-based spillovers from Brexit to *neighboring-country local outcomes* is still relatively uncrowded and would be a clear contribution if executed well.
- **Recommendation:** **PURSUE (conditional on: (1) very clear “shock” definition that is not mechanically affected by French outcomes; (2) strong robustness to controlling for ports/trade exposure/tourism and to excluding border/port départements; (3) BHJ/AKM-style inference appropriate for shift-share and exposure designs).**

---

**#2: Europe’s Information Superhighway — Do Social Networks Transmit Trade Shocks Across EU Borders? (Idea 3)**
- **Score: 56/100**
- **Strengths:** The triple-difference structure is a sensible attempt to isolate the *trade-friction* channel (post–Jan 2021) from general Brexit uncertainty; sectoral exposure adds needed structure and could be policy-relevant for trade adjustment assistance.
- **Concerns:** **COVID is a first-order confound in exactly the 2020–2021 window** and is highly correlated with sectoral shocks and port activity; without a compelling strategy to net out pandemic dynamics, the design is likely to fail. Data feasibility is also less “plug-and-play” than it appears: département-by-sector outcomes and a clean UK-exposure measure at that level are necessary and may be noisy.
- **Novelty Assessment:** **Moderate.** Many papers estimate TCA/Brexit trade frictions; fewer use SCI and a policy discontinuity, but the space is more crowded than Idea 1 and the COVID overlap makes incremental contribution harder.
- **DiD Assessment (Triple-Diff is still DiD; evaluated on the 8 required criteria):**
  - **Pre-treatment periods:** **Strong** (you can use 2014–2020 pre-periods with multiple years).
  - **Selection into treatment:** **Strong** (TCA implementation is externally timed; SCI/sector exposure are pre-determined).
  - **Comparison group:** **Marginal** (high- vs low-SCI départements and high- vs low-UK-exposed sectors may differ systematically; needs rich controls and convincing event studies by group).
  - **Treatment clusters:** **Strong** (≈96 départements; if inference is clustered appropriately at département×sector or département with two-way clustering).
  - **Concurrent policies:** **Weak (potential dealbreaker)** due to COVID waves, lockdowns, and recovery policies coinciding with Jan 2021 and varying by sector/region.
  - **Outcome-Policy Alignment:** **Strong** if outcomes are tightly trade-linked (e.g., port throughput, export-sector employment, customs-related activity) rather than broad employment.
  - **Data-Outcome Timing:** **Marginal** (Jan 1, 2021 start; many annual outcomes for 2021 blend pre/post within-year dynamics; quarterly/monthly outcomes are needed to avoid partial-exposure attenuation).
  - **Outcome Dilution:** **Marginal** (trade-exposed sectors may be a modest share of département employment; must focus on directly exposed sectors/ports to avoid dilution).
- **Recommendation:** **CONSIDER (conditional on: (1) a credible COVID adjustment strategy—e.g., excluding 2020–2021 waves, using 2022+ as post, or leveraging outcomes uniquely tied to customs frictions; (2) high-frequency outcomes; (3) pre-trend/event-study evidence separately by sector exposure and SCI).**

---

**#3: The Franc Shock Next Door — Social Networks and the Swiss Currency Crisis Transmission to French Border Economies (Idea 2)**
- **Score: 42/100**
- **Strengths:** The SNB floor removal is a very sharp, plausibly exogenous shock with clear cross-border mechanisms (commuting/frontalier labor supply, cross-border shopping, housing demand). In principle, a strong natural experiment.
- **Concerns:** The proposal as written is underpowered and fragile: meaningful Swiss exposure is concentrated in a small number of départements (few treated “clusters”), and DVF coverage gaps (notably Haut-Rhin exclusion) cut into precisely the geography where effects may be largest. The RDD-at-border alternative is not yet specified in a way that ensures comparable outcomes/data on both sides and avoids border-specific discontinuities unrelated to the CHF shock.
- **Novelty Assessment:** **Moderate-to-low.** The CHF appreciation has been studied extensively; cross-border spillovers likely exist in the literature. Adding SCI is novel, but may be viewed as incremental unless it changes the identification/interpretation materially.
- **DiD Assessment (if using the proposed high/low SCI spatial DiD):**
  - **Pre-treatment periods:** **Weak** for housing if relying on DVF starting in 2014 (≤1 year clean pre for a Jan 2015 shock, unless using very high-frequency within-2014/early-2015 trends).
  - **Selection into treatment:** **Strong** (shock is exogenous; “treatment intensity” pre-determined).
  - **Comparison group:** **Marginal** (border vs non-border areas differ structurally; even within border areas, high-SCI places may be systematically different).
  - **Treatment clusters:** **Weak** (≈10 or fewer meaningful Swiss-connected départements; inference and robustness are fragile).
  - **Concurrent policies:** **Marginal** (less severe than COVID-era, but local/regional dynamics and housing cycles could confound; needs strong local trend controls).
  - **Outcome-Policy Alignment:** **Strong** for housing/commuting outcomes; **marginal** for broad employment unless narrowly defined (e.g., sectors employing frontaliers).
  - **Data-Outcome Timing:** **Marginal/Weak** (Jan 15, 2015 shock; annual outcomes for 2015 mix pre/post; requires monthly/quarterly measurement to avoid attenuation).
  - **Outcome Dilution:** **Marginal** (effects concentrated in border labor/housing markets; département averages may dilute unless focusing on communes near the border).
- **Recommendation:** **SKIP** (unless redesigned as a commune-level, high-frequency event-study focusing on a narrow border band, with adequate pre-period and a plan for inference with few clusters).

---

**#4: Friends Across Borders — How German Energiewende Shocks Propagate to French Energy Markets via Social Networks (Idea 5)**
- **Score: 34/100**
- **Strengths:** Energy policy spillovers across France–Germany are unquestionably policy-relevant; high-frequency grid/price data are available and could support credible designs if tied to physical interconnection constraints and dispatch.
- **Concerns:** The proposed *social network (SCI) channel is not well-matched to the mechanism*: wholesale power prices and flows propagate through the grid and market coupling, not through interpersonal ties. This is likely to be viewed as a “wrong network” problem, creating weak conceptual foundations and a high risk of spurious correlation.
- **Novelty Assessment:** **Low-to-moderate.** Energiewende impacts and cross-border electricity spillovers are heavily studied; the SCI angle is novel but not persuasive as a causal channel.
- **Recommendation:** **SKIP** (or **re-scope** entirely: use transmission constraints/interconnector outages, market coupling changes, or plant closure timing with grid-based exposure rather than SCI).

---

**#5: Digital Ties and the Eurozone Crisis — Did Social Networks Amplify Sovereign Debt Contagion to French Regions? (Idea 4)**
- **Score: 8/100**
- **Strengths:** Big historical episode; policymakers care about contagion mechanisms.
- **Concerns:** The timing/data mismatch is fatal: DVF starts in 2014 (post-crisis), and SCI measured in 2021 is a poor proxy for 2010–2012 ties. The “shock” is also multi-country and staggered with many concurrent policies, making credible identification very difficult.
- **Novelty Assessment:** **Low.** Sovereign debt crisis contagion is extensively studied; this version does not add credible identification.
- **Recommendation:** **SKIP**

---

### Summary

This is a mixed batch: **Idea 1** stands out as the only proposal with a strong novelty–identification–data trifecta and a credible modern empirical design (shift-share IV with serious diagnostics). **Idea 3** is conceptually attractive but is likely to fail on DiD due to **a major concurrent-policy confound (COVID) and timing/measurement issues** unless substantially redesigned. The remaining ideas have either fatal feasibility/timing problems (Idea 4), weak mechanism mismatch (Idea 5), or DiD fragility from too few treated clusters and insufficient pre-periods (Idea 2).