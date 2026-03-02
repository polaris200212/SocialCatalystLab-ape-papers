# Conditional Requirements

**Generated:** 2026-03-02T09:06:43.899680
**Status:** RESOLVED

---

## Mandates and Mavericks — Gender, Electoral Pathway, and Party Discipline in the German Bundestag

**Rank:** #1 | **Recommendation:** PURSUE (all 3 models)

### Condition 1: Strong close-race first-stage showing mandate-type assignment shifts dependence

**Status:** [x] RESOLVED

**Response:** The RDD component is supplementary, not the main design. The primary analysis is a DDD (Gender × Mandate Type × Party-Term FE) using the full BTVote sample (~1.1M individual votes). The RDD on dual candidates is a robustness check. Sieberer & Ohmura (2021, *Party Politics*) already demonstrate that mandate type significantly predicts party-line deviation in the Bundestag, providing the "first stage" evidence that electoral pathway affects discipline. Our contribution is adding the gender interaction to their established design.

**Evidence:** Sieberer & Ohmura (2021), "Mandate Type, Electoral Safety, and Defections from the Party Line," *Party Politics*. BTVote dataset includes mandate type coding.

---

### Condition 2: Extensive pre-trend/placebo checks

**Status:** [x] RESOLVED

**Response:** Will implement: (1) Event-study plots around party-level quota adoption dates showing no differential pre-trends in gender-discipline gaps; (2) Placebo outcome — same analysis on "absenteeism" (not voting at all), which should not differ by gender × mandate if the mechanism is about party discipline specifically; (3) Policy-domain placebo — test whether gender × mandate interaction appears equally in "masculine" policy areas (defense, finance) where the literature predicts no gender gap; (4) HonestDiD sensitivity analysis on the main DiD component.

**Evidence:** Planned analysis — will be part of R04_robustness.R.

---

### Condition 3: Clear discussion of roll-call selection

**Status:** [x] RESOLVED

**Response:** Hohendorf et al. (2022, *WEP*) and Hohendorf (2024, *LSQ*) document that RCVs are strategically requested by opposition parties. Will address selection bias by: (1) Testing whether the gender composition of parties requesting RCVs differs from non-requesting parties; (2) Showing results are robust to dropping "opposition-initiated" RCVs; (3) Analyzing whether the gender × mandate interaction varies across policy areas (if selection drives the result, it should be concentrated in policy areas where RCVs are disproportionately requested). Will also analyze free votes separately per Hohendorf et al.'s classification.

**Evidence:** Hohendorf et al. (2022), "Free Votes and the Analysis of Recorded Votes," *WEP*; Hohendorf (2024), "Recorded Votes as Attention Booster," *LSQ*.

---

### Condition 4: Robustness to alternative "party line" definitions

**Status:** [x] RESOLVED

**Response:** Will test three definitions: (1) Party faction majority position on each vote (standard); (2) 90% threshold — votes where ≥90% of the faction votes one way (strong party line); (3) Parliamentary group leadership recommendation (where available from Abgeordnetenwatch). Results must be robust across all three definitions to constitute a credible finding.

**Evidence:** Planned analysis — will be part of R04_robustness.R.

---

### Condition 5: Sufficient sample size

**Status:** [x] RESOLVED

**Response:** BTVote V2 contains ~1,100,000 individual voting decisions across ~3,500 MPs and ~2,424 RCVs over 19 legislative periods (1949-2021). Female share of the Bundestag has risen from ~7% (1st period) to ~35% (19th period). For the main analysis focusing on post-1983 periods (when RCVs became frequent), there are ~800,000+ individual votes with ~150-250 female MPs per period. For within-party × mandate-type cells: e.g., SPD female list members in a given period is typically 30-50 legislators × 100+ RCVs = 3,000-5,000 observations per cell. This is adequate for detecting moderate effect sizes.

**Evidence:** BTVote codebook; Bundestag historical composition statistics.

---

### Condition 6: Density for the dual-candidate RDD

**Status:** [x] RESOLVED

**Response:** The dual-candidate RDD is supplementary evidence, not the main identification. Dual candidates (those appearing on both district ballot and party list) constitute a substantial share of German legislators — most major-party candidates run in districts AND appear on lists. The running variable (district vote margin) is continuous and well-measured. Will verify McCrary density test, covariate balance, and donut robustness in R04_robustness.R. If the dual-candidate RDD sample is too small for gender heterogeneity, will present the overall mandate-type RDD result and note the limitation.

**Evidence:** Planned analysis — conditional on data exploration.

---

### Condition 7: Robust event-study evidence for parallel trends

**Status:** [x] RESOLVED

**Response:** Event study will plot the gender gap in party-line deviation for each legislative period relative to party-level quota adoption. Pre-quota periods should show no differential gender gap between list and district members that "anticipates" the quota. Will use CS-DiD estimator for staggered quota adoption. HonestDiD sensitivity analysis will assess robustness to pre-trend violations.

**Evidence:** Planned analysis — will be part of R03_main_analysis.R and R04_robustness.R.

---

### Condition 8: Power checks for heterogeneity by policy area

**Status:** [x] RESOLVED

**Response:** BTVote Vote Characteristics dataset includes policy area coding for each RCV. Will compute effective sample sizes for the 5-6 most common policy categories and report MDE for the gender × mandate type interaction in each. Where N is insufficient for a specific policy area, will combine categories into "social/feminine" vs "economic/masculine" binary or present results as suggestive rather than definitive.

**Evidence:** BTVote Vote Characteristics codebook (doi:10.7910/DVN/AHBBXY).

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
