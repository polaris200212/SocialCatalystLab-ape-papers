# Research Idea Ranking

**Generated:** 2026-02-25T11:21:51.455500
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 8091

---

### Rankings

**#1: Choking the Supply — The EU Mercury Export Ban and Artisanal Gold Mining in Africa (Idea 2)**
- **Score: 72/100**
- **Strengths:** High novelty and strong quasi-exogeneity: the EU export ban is an external supply shock, and treatment intensity (pre-ban EU dependence) is predetermined. The design directly targets a clear mechanism (supply restriction) and can be validated with partner-trade reallocation and smuggling proxies.
- **Concerns:** Feasibility is the biggest risk: many African countries have sparse/zero recorded mercury imports, and illegal flows could make Comtrade-based outcomes noisy. Also, the **US export ban (2013)** and later Minamata-related changes can contaminate longer post periods.
- **Novelty Assessment:** **High.** There is work on mercury trade rerouting/smuggling and descriptive impacts, but I am not aware of many clean causal papers quantifying the EU ban’s downstream effects on African mercury availability/ASGM-related outcomes.
- **DiD Assessment (8 criteria):**
  - **Pre-treatment periods:** **Strong** (2005–2010 gives 6 pre years)
  - **Selection into treatment:** **Strong/Marginal** (ban is external; *intensity* could correlate with pre-trends—must test)
  - **Comparison group:** **Strong** (low-EU-dependent African countries are plausible controls within the same continent)
  - **Treatment clusters:** **Strong** (≈50+ countries; inference can cluster by country)
  - **Concurrent policies:** **Marginal** (US ban in 2013; Minamata later—can mitigate by focusing on 2012–2014/2015 windows and showing robustness)
  - **Outcome-Policy Alignment:** **Strong** (policy directly restricts *legal EU-origin mercury supply*; outcomes include total imports and partner composition consistent with the mechanism)
  - **Data-Outcome Timing:** **Marginal** (policy effective **March 15, 2011**; Comtrade is **annual** → 2011 has partial exposure; best practice is to drop 2011 or define treatment starting 2012)
  - **Outcome Dilution:** **Marginal** (imports include all uses, not just ASGM; dilution depends on how dominant ASGM is in each country—needs justification/heterogeneity by ASGM prevalence)
- **Recommendation:** **PURSUE (conditional on: (i) pre-register a short post window to reduce contamination from later policies; (ii) document which countries have reliable, non-missing mercury import series and run robustness on that “balanced-reporters” sample; (iii) include reallocation/smuggling checks using partner data and mirror gaps).**

---

**#2: Paper Treaties — Does the Minamata Convention Reduce Mercury Use in Africa's Artisanal Gold Mines? (Idea 1)**
- **Score: 66/100**
- **Strengths:** Extremely novel and highly policy-relevant: evaluating a major global environmental treaty **before** the official effectiveness review is valuable. Staggered ratification and (especially) **NAP submission** provide potentially meaningful treatment variation with many treated units.
- **Concerns:** Biggest identification risk is **what “treatment” actually is**: ratification may not change behavior absent enforcement/financing, and treaty obligations (NAP development timelines) imply delayed effects. Outcomes based on *recorded imports* may miss substitution into informal trade, and “never-treated” controls (e.g., DRC, Sudan) may be structurally different.
- **Novelty Assessment:** **Very high.** I am not aware of credible causal evaluations of Minamata’s ASGM provisions using panel methods; most work is descriptive/engineering/field-based rather than causal cross-country policy evaluation.
- **DiD Assessment (8 criteria):**
  - **Pre-treatment periods:** **Strong** (imports back to 1990s; plenty of pre for most cohorts)
  - **Selection into treatment:** **Marginal** (ratification/NAP submission plausibly related to governance, donor engagement, or mercury problems; DR helps on observables but not on unobserved trend selection)
  - **Comparison group:** **Marginal** (not-yet-treated cohorts are usable, but “never-treated” countries like DRC/Sudan may violate comparability; needs careful cohort-specific pre-trend/event-study validation)
  - **Treatment clusters:** **Strong** (≈38 ratifiers; many cohorts)
  - **Concurrent policies:** **Marginal** (EU/US export bans, domestic mining reforms, conflict shocks; must show robustness to excluding 2011–2013 transition and controlling for major mining-policy changes where measurable)
  - **Outcome-Policy Alignment:** **Marginal** (mechanism is reduced mercury *use* in ASGM; **imports** are an imperfect proxy because of stockpiling, industrial uses, and illegal trade—alignment improves if you: (i) show mercury imports track ASGM intensity historically; (ii) use partner composition/mirror gaps as “illegal substitution” diagnostics)
  - **Data-Outcome Timing:** **Marginal/Weak** unless tightened (ratification years vary; treaty entered into force **Aug 2017**; NAPs often **2019–2024**; annual outcomes → likely need **explicit lag structure**: treat as exposed starting the first full calendar year after entry-into-force for that party, and separately treat NAP submission as the “implementation” event)
  - **Outcome Dilution:** **Marginal** (country-level totals dilute if ASGM is a minority user; can mitigate via heterogeneity focusing on high-ASGM countries, and by using mining-area outcomes like lights/deforestation as complementary evidence)
- **Recommendation:** **CONSIDER (conditional on: (i) redefining treatment timing around “entry into force for the party” + first full-year exposure; (ii) making NAP submission/implementation the primary treatment margin and ratification secondary; (iii) adding at least one outcome that speaks to illegal substitution—e.g., mirror trade gaps/partner rerouting—to interpret nulls).**

---

**#3: When Treaties Meet Price Booms — Gold Shocks, Mining Governance, and ASGM Expansion in Africa (Idea 3)**
- **Score: 50/100**
- **Strengths:** Clever idea that leverages plausibly exogenous global gold price shocks and rich spatial outcomes (deforestation/lights) with huge sample size. The “does policy dampen the suitability × price response?” question is conceptually attractive and testable.
- **Concerns:** As written, **Outcome–Policy Alignment is weak**: Minamata targets *mercury use/handling*, not necessarily ASGM expansion/deforestation (miners could adopt mercury-free techniques without reducing mining/forest loss). Also, the effective identifying variation for the policy interaction is still **country-level (N≈54)**, so inference hinges on few dozen clusters and on no coincident country-level changes that differentially affect high-suitability cells post-ratification.
- **Novelty Assessment:** **Moderate-to-high.** The geology × price ASGM literature is active, but adding *treaty moderation* is newer; still, it’s adjacent to existing “institutions/governance × commodity shock” interaction papers.
- **DiD Assessment (8 criteria):**
  - **Pre-treatment periods:** **Strong** (many years pre)
  - **Selection into treatment:** **Marginal** (ratification may correlate with environmental reform trajectories that also affect land use)
  - **Comparison group:** **Strong** (within-country low-suitability cells provide a natural comparison for high-suitability cells)
  - **Treatment clusters:** **Strong** (country clusters ≈50; treated ≈38, but standard errors must be clustered at country and/or country×year depending on specification)
  - **Concurrent policies:** **Marginal** (forest policies, mining formalization, conflict dynamics could shift around ratification)
  - **Outcome-Policy Alignment:** **Weak** (deforestation/lights measure mining activity; Minamata is about mercury—link is indirect and may not exist even if the treaty “works”)
  - **Data-Outcome Timing:** **Marginal** (Hansen loss is annual; ratification/implementation mid-year; must lag treatment to first full year)
  - **Outcome Dilution:** **Strong** (by focusing on gold-suitable/mining-area cells, the affected share is much higher than in national averages)
- **Recommendation:** **CONSIDER (conditional on major reframing to fix alignment):** make the **primary outcome** something directly tied to mercury (imports, partner rerouting, mirror gaps) and use deforestation/lights as **secondary** “real activity” checks, or explicitly test mercury-free technology adoption channels if data exist. Without that, it risks being an elegant design answering the wrong policy question.

---

**#4: EITI Membership and Artisanal Mining Governance in Africa (Idea 4)**
- **Score: 32/100**
- **Strengths:** High policy relevance in principle and easy-to-access cross-country data. Enough adopting countries to run staggered estimators.
- **Concerns:** This is heavily studied and, more importantly, identification is weak: EITI adoption/compliance is strongly endogenous to governance trends and reform episodes; WGI outcomes are broad, slow-moving, and poorly aligned with “artisanal mining governance.” Early adopters also lack long pre-periods in many governance datasets.
- **Novelty Assessment:** **Low.** EITI has a substantial DiD/event-study literature already; “artisanal angle” is not enough to overcome endogeneity and outcome mismatch unless you have truly ASGM-specific governance outcomes.
- **DiD Assessment (8 criteria):**
  - **Pre-treatment periods:** **Weak** (WGI is annual only from ~2002; countries joining ~2003–2004 have ≤1–2 pre years)
  - **Selection into treatment:** **Weak** (countries often join amid reform pressure or in response to governance challenges)
  - **Comparison group:** **Marginal/Weak** (never-treated vs treated differ systematically in institutions/resource politics)
  - **Treatment clusters:** **Strong** (≈24 members), but not enough to rescue core endogeneity
  - **Concurrent policies:** **Weak** (EITI often bundled with IMF programs, anticorruption drives, mining code overhauls)
  - **Outcome-Policy Alignment:** **Weak** (WGI “control of corruption” is not a measure of artisanal mining governance; gold exports are also a noisy proxy)
  - **Data-Outcome Timing:** **Marginal** (status changes mid-year; annual governance measures; plus slow-moving outcomes)
  - **Outcome Dilution:** **Weak** (ASGM is a small slice of what WGI measures; effects would be heavily diluted)
- **Recommendation:** **SKIP** (unless you can obtain genuinely ASGM-specific governance/enforcement data with long pre-trends and a plausibly exogenous adoption trigger—which is unlikely).

---

### Summary

This is a strong batch on novelty and policy relevance, but only **Idea 2** currently pairs novelty with relatively credible identification. **Idea 1** is very promising but needs tighter treatment timing (entry-into-force/NAP implementation) and a plan to interpret nulls in the presence of informal trade. **Idea 3** has a sophisticated design but currently fails the critical **Outcome–Policy Alignment** test unless reframed around mercury-specific outcomes. **Idea 4** should be deprioritized: it’s both well-trodden and has multiple “Weak” DiD criteria that are hard to fix.