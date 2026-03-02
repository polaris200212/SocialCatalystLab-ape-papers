# Research Idea Ranking

**Generated:** 2026-02-21T11:18:32.884869
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7007

---

### Rankings

**#1: Breaking Purdah with Pavement: Caste-Specific Gender Returns to Rural Roads in India (Idea 3)**
- **Score: 72/100**
- **Strengths:** A threshold-based design on a major infrastructure program is policy-relevant and, if the running variable is credible, can deliver relatively clean causal evidence. The **gender × caste heterogeneity** is genuinely underexplored in the PMGSY literature.
- **Concerns:** The key threat is **measurement error/misclassification** because PMGSY eligibility is defined at the *habitation* level, while the running variable is *Census village* population—this can seriously blur the discontinuity and bias toward zero. Also, without OMMAS road-completion data, you risk estimating an ITT with an uncertain first stage.
- **Novelty Assessment:** **Moderately novel**. PMGSY impacts are well-studied (e.g., Asher & Novosad 2020), but **women’s outcomes by caste** at village scale is much less saturated.
- **Recommendation:** **PURSUE (conditional on: obtaining/merging OMMAS PMGSY road completion data to document a strong first stage; showing no manipulation at the population threshold via McCrary and covariate balance; restricting to plausibly single-habitation villages or otherwise validating village↔habitation mapping near the cutoff).**

---

**#2: The Caste Ceiling on Women's Work: How Social Norms Moderate the Returns to India's Rural Employment Guarantee (Idea 1)**
- **Score: 63/100**
- **Strengths:** Excellent question with high policy salience: whether MGNREGA shifts women’s work differently across caste-norm environments. The proposed within-district village caste composition interactions are a thoughtful way to avoid obvious “backwardness index ↔ caste share” mechanical correlations.
- **Concerns:** The biggest issue is **DiD credibility** with **very thin pre-trends for the core outcomes** (often only one pre period for Census/EC village outcomes), plus **non-random phase assignment** (targeted to “most backward” districts). The heterogeneity interaction may be interpretable, but the design still leans heavily on untestable assumptions about differential trends by caste composition.
- **Novelty Assessment:** **Moderately novel.** MGNREGA is heavily studied, including gender-related margins, but **village-level caste × gender heterogeneity at this scale** is not yet “mined out.”
- **DiD Assessment (MANDATORY):**
  - **Pre-treatment periods:** **Weak** — for key village female employment outcomes you effectively have 2001 pre vs 2011 post (and EC 2005 vs 2013), which does not allow credible pre-trend testing.
  - **Selection into treatment:** **Marginal** — rollout targeted “backward” districts; not plausibly as-good-as-random.
  - **Comparison group:** **Marginal** — later-phase districts may differ structurally from early-phase districts; within-state helps but doesn’t solve.
  - **Treatment clusters:** **Strong** — hundreds of districts.
  - **Concurrent policies:** **Marginal** — mid-2000s saw multiple rural initiatives (roads, health, education) that may co-move with phase targeting.
  - **Outcome-Policy Alignment:** **Strong** — Census/EC measures of women’s work are conceptually aligned with a work-guarantee program (labor supply/participation/sector shifts).
  - **Data-Outcome Timing:** **Strong** — treatment begins 2006–2008; Census 2011 employment classification refers to work in the preceding year (so mostly post-exposure), and EC2013 is clearly post.
  - **Outcome Dilution:** **Marginal** — village “female workers / female population” includes children/elderly; the treated margin is working-age women, so effects can be mechanically diluted unless you can approximate working-age shares or use tighter outcomes.
- **Recommendation:** **CONSIDER (only if you can add credible pre-trend evidence—e.g., additional pre outcome years or alternative repeated outcomes that match the mechanism; otherwise the DiD core is too assumption-driven).**

---

**#3: From Fields to Firms: The Gendered Structural Transformation of India's Villages, 1991–2013 (Idea 5)**
- **Score: 58/100**
- **Strengths:** The descriptive contribution could be valuable: a unified village panel using Census+EC at national scale can become a reference for policy discussions on women’s work and structural change. As a “facts + patterns” paper, this is feasible and potentially influential.
- **Concerns:** As soon as it becomes a causal paper, it inherits **the same DiD weaknesses as Idea 1** (limited pre-trends for the relevant outcomes and targeted rollout). There is also a risk of becoming too broad (“three papers in one”) without a sharp estimand.
- **Novelty Assessment:** **Moderate.** Structural transformation and female labor force participation in India are widely studied (mostly with NSS/PLFS); the **village-level long panel** angle is the main novel value-add.
- **DiD Assessment (for the MGNREGA causal component):**
  - **Pre-treatment periods:** **Weak** — limited pre periods for the core village outcomes that match the mechanism.
  - **Selection into treatment:** **Marginal**
  - **Comparison group:** **Marginal**
  - **Treatment clusters:** **Strong**
  - **Concurrent policies:** **Marginal**
  - **Outcome-Policy Alignment:** **Strong** (for the MGNREGA component)
  - **Data-Outcome Timing:** **Strong**
  - **Outcome Dilution:** **Marginal**
- **Recommendation:** **CONSIDER (best framed primarily as a descriptive/patterns paper; treat causal claims as secondary unless you can materially strengthen identification).**

---

**#4: Missing at the Margins: How India's Son Preference Varies with Economic Growth Across the Caste Hierarchy (Idea 2)**
- **Score: 45/100**
- **Strengths:** Important outcome (child sex ratio) and a provocative mechanism (growth → dowry/Sanskritization → worsening sex ratios). Village-level scale is a plus for precision and heterogeneity.
- **Concerns:** The proposed IV is the problem: **distance to rail/highways plausibly affects sex ratios through many non-income channels** (health access, fertility behavior, diffusion of ultrasound technology, migration, norms exposure, state capacity), making the exclusion restriction very hard to defend. More broadly, “development and sex ratios” is already a crowded literature; the causal leverage here is not strong enough.
- **Novelty Assessment:** **Low-to-moderate.** Son preference and development has a large literature; caste-heterogeneity at village scale is somewhat newer, but not enough to overcome weak identification.
- **Recommendation:** **SKIP** (unless you can redesign around a plausibly exogenous growth shock—e.g., a clearly exogenous infrastructure rollout with a sharp design, or an event with tight timing and geography).

---

**#5: The Double Bind: How SC/ST Political Reservation Affects Women's Outcomes Across Caste Lines (Idea 4)**
- **Score: 40/100**
- **Strengths:** The question is policy-relevant and the delimitation episode is often a good source of quasi-exogenous political variation *when the assignment rule is well-defined*.
- **Concerns:** The proposed RDD appears **mis-specified**: reservation assignment is not a clean “SC share crosses a fixed threshold” rule in the way required for credible RDD, so the running variable/threshold may be incorrect or too noisy. Data construction (mapping villages to post-delimitation constituencies, defining the correct assignment rule) is nontrivial and, if wrong, is a dealbreaker.
- **Novelty Assessment:** **Low.** Political reservation effects are extensively studied in India; delimitation has been used before, and adding “women’s outcomes” may not be enough without unusually clean identification.
- **Recommendation:** **SKIP** (unless you can precisely reconstruct the Delimitation Commission’s reservation assignment algorithm and show a genuinely sharp discontinuity with a credible running variable).

---

### Summary

This is a strong batch in terms of substantive questions and data ambition, but **identification is the binding constraint**: the MGNREGA village-outcomes DiD ideas (Ideas 1 and 5) are interesting yet lean heavily on **untestable parallel trends** given sparse pre-periods for the key outcomes. The most promising path is **Idea 3 (PMGSY threshold/RDD)** because it can be made credibly causal if you solve the habitation-village mapping and document a strong first stage with administrative road construction data.