# Research Idea Ranking

**Generated:** 2026-02-23T11:10:35.910616
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6794

---

### Rankings

**#1: Roads to Equality? PMGSY and the Gender Gap in Non-Farm Employment (Idea 2)**  
- **Score: 76/100**  
- **Strengths:** Very strong quasi-experimental design anchored in a well-known population-threshold RDD with huge sample size and plausibly non-manipulable running variable (Census 2001 population). The gender-specific labor-market angle is policy-relevant and plausibly underexplored relative to average effects.  
- **Concerns:** “Sharp” eligibility does not imply sharp treatment—PMGSY implementation is staggered and incomplete by 2011, so ITT may be meaningfully diluted (risking false nulls). Also, other programs sometimes use similar population thresholds; if any coincide, interpretation becomes “bundle at 500/250,” not PMGSY alone.  
- **Novelty Assessment:** **Moderately novel.** PMGSY RDD is heavily studied (Asher & Novosad and follow-ons), but rigorous *gendered employment composition* outcomes are much less saturated than consumption/income effects.  
- **Recommendation:** **PURSUE (conditional on: (i) document first-stage discontinuity in roads by 2011 in your analytic sample and by terrain category; (ii) check for other policies tied to the same thresholds; (iii) pre-specify outcome definitions carefully—share among women vs share of total workers—to avoid interpretability problems).**

---

**#2: Party Alternation and Local Economic Development — A Close-Election RDD from Indian State Assemblies (Idea 1)**  
- **Score: 68/100**  
- **Strengths:** Close-election RDD is a credible identification strategy with abundant close races in India, and the question (whether turnover helps or hurts development) is conceptually important and not mechanically signed. Nightlights provide long time coverage, enabling dynamic effects and robustness checks.  
- **Concerns:** Treatment definition (“party alternation”) can be tricky in a multi-party/coalition environment and may conflate party change with candidate quality change; careful coding is essential. Boundary harmonization (pre/post delimitation, `ac07_id`/`ac08_id`) and matching elections to stable geography is a real feasibility/validity constraint—errors here will quietly destroy identification.  
- **Novelty Assessment:** **Moderately novel.** There is a large global close-elections literature and a non-trivial India political economy/RDD literature, but “party alternation → development” in Indian state assembly constituencies using modern nightlights is not obviously over-mined.  
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: (i) you restrict to post-delimitation periods with clean constituency concordance or build a transparent crosswalk; (ii) you show no manipulation around the vote-margin cutoff and strong covariate balance; (iii) you pre-specify how you handle coalitions/party splits/independents).**

---

**#3: Do Criminally-Accused Politicians Worsen Long-Run Development? Extended Evidence from India (Idea 4)**  
- **Score: 60/100**  
- **Strengths:** Identification (close-election RDD) is standard and credible in principle, and the *persistence* question is genuinely policy-relevant (it speaks to long-run costs of criminal politics, not just contemporaneous misgovernance). VIIRS extension beyond earlier DMSP windows is a real data improvement.  
- **Concerns:** Novelty is incremental because it is explicitly an extension of a well-cited paper; the main contribution hinges on cleanly defining and interpreting “long-run/persistence” when subsequent elections/politicians intervene (post-treatment political selection is a serious threat to interpretation). Data assembly risk is non-trivial (criminal-case coding quality/coverage over time; scraping/standardizing affidavits; linking to constituencies consistently).  
- **Novelty Assessment:** **Low-to-moderate.** Criminal politicians in India via close elections is already established; persistence using VIIRS is a worthwhile add-on but not a new research agenda.  
- **Recommendation:** **CONSIDER (conditional on: (i) a clear persistence estimand—e.g., reduced-form effect of electing a criminal at \(t\) on outcomes \(t+k\), with transparent discussion of contamination by later office-holders; (ii) a reproducible pipeline for criminality measures and matching; (iii) strong placebo/falsification tests and sensitivity to alternative criminality definitions).**

---

**#4: Does Political Competition Drive Public Goods? Close Elections and Village Amenities in India (Idea 3)**  
- **Score: 42/100**  
- **Strengths:** Moves to concrete public goods outcomes that policymakers directly care about, and it aims to unpack mechanisms (public spending/provision vs private activity).  
- **Concerns:** As posed, the timing/data structure is a major dealbreaker: village amenities are measured mainly in decennial censuses (2001/2011), while elections occur multiple times within the intercensal window—so “treated vs control” exposure is ambiguous and likely mismeasured, yielding attenuation and interpretational fog. Aggregating village amenities to constituencies also risks severe measurement error (and potentially ecological fallacy) unless the constituency-village mapping is perfect.  
- **Novelty Assessment:** **Moderate.** “Political competition and public goods” is a classic question with many papers globally and in India-adjacent settings; the novelty would come from this specific RDD + SHRUG amenities implementation, but identification/timing limits dominate.  
- **DiD Assessment (because the proposal explicitly relies on 2001→2011 changes):**
  - **Pre-treatment periods:** **Weak** (essentially one pre period; cannot credibly test parallel trends)  
  - **Selection into treatment:** **Marginal** (close-election near-randomness helps, but “treatment” over a decade is not a one-time shock; subsequent elections respond to outcomes)  
  - **Comparison group:** **Marginal** (close races help comparability, but decade-long changes may differ systematically across states/regions)  
  - **Treatment clusters:** **Strong** (many constituencies), but clustering/inference must be constituency/state robust  
  - **Concurrent policies:** **Weak** (2001–2011 saw massive national/state programs—roads, electrification, SSA/NRHM, NREGA—coincident with amenity expansion; hard to isolate political-competition channel with only two census points)  
  - **Outcome-Policy Alignment:** **Marginal** (amenities are relevant, but not tightly mapped to a single election/party alternation event)  
  - **Data-Outcome Timing:** **Weak** (outcome measured at decennial snapshots; many “treated” units will have partial/unclear exposure and multiple post-treatment political regimes)  
  - **Outcome Dilution:** **Marginal** (if treatment is “one close election/alternation,” only part of the 2001–2011 period is actually under that regime; effect diluted by long window and subsequent office-holders)  
- **Recommendation:** **SKIP** *(unless the design is rethought around outcomes with annual timing—e.g., administrative electrification/road completion/school construction data with known commissioning dates—or you reframe it as a pure close-election RDD on outcomes measured soon after a specific election with correct exposure windows).*

---

### Summary

This is a solid batch with two credible RDD-based projects, but only **Idea 2** looks immediately “institute-ready” because it combines a highly credible threshold design with high policy relevance and manageable measurement/timing. **Idea 1** is promising but hinges on careful treatment coding and constituency boundary harmonization. **Idea 3** should be rejected in its current form because the decennial-amenity timing makes the implied DiD/channel story weak on multiple checklist criteria (especially pre-trends and timing), creating a high risk of uninterpretable nulls.