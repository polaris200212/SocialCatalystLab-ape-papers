# Research Idea Ranking

**Generated:** 2026-02-13T18:05:13.893009
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7084

---

### Rankings

**#1: Mandatory Energy Disclosure and the Information Premium in Commercial Real Estate (Idea 2)**
- **Score: 78/100**
- **Strengths:** Very clean *within-city* sharp RDD at a clear statutory cutoff (25,000 sq ft) with enormous sample size and high-quality administrative data (PLUTO/DOB/DOF). High policy relevance: directly informs whether benchmarking/disclosure laws move markets via an “information channel” rather than mandates.
- **Concerns:** Must rule out sorting/manipulation around 25,000 sq ft via building design/alterations (especially for post-2009 construction/major renovations), and ensure no other requirements “kink” at 25,000. Energy performance outcomes exist only for treated buildings (LL84), so the core causal outcomes should be market outcomes observed for *all* buildings (sales/assessments), not energy use.
- **Novelty Assessment:** **Moderately novel.** There is a literature on energy labels/benchmarking (incl. EPC-style disclosures and some US city benchmarking work), but an NYC-only *size-threshold RDD* focused on valuation/transaction responses is less common and is a valuable design improvement over cross-city DiD.
- **DiD Assessment:** N/A (RDD design).
- **Recommendation:** **PURSUE (conditional on: (i) density/bunching tests and “donut” RDD around 25,000; (ii) split by building cohort—pre-policy stock vs post-policy/new builds; (iii) show no coincident regs at 25,000 and no discontinuities in predetermined covariates like age, use type, neighborhood).**

---

**#2: SNAP Work Requirements, the Age-50 Cliff, and Labor Supply (Idea 5)**
- **Score: 67/100**
- **Strengths:** Conceptually elegant sharp age cutoff (age not manipulable) and a genuinely different identification strategy than the common waiver-expiration DiDs. Strong policy relevance (work requirements remain an active federal/state policy lever).
- **Concerns:** Biggest threat is **weak/unclear first stage**: the age-50 exemption only matters for a subset (ABAWDs without dependents, not disabled, potentially subject to requirements in their state/county/year). In many places/periods ABAWD rules were waived or lightly enforced, so treatment intensity may barely jump at 50 (and CPS SNAP misreporting can further attenuate).
- **Novelty Assessment:** **High.** Age-threshold RDD for SNAP ABAWD rules is much less studied than DiDs around waiver policy changes; the design is a fresh way to learn about compliance burden vs labor supply effects.
- **DiD Assessment:** N/A (RDD design).
- **Recommendation:** **CONSIDER (upgrade to PURSUE if you can strengthen the first stage)** by: restricting to likely-affected subpopulations (no dependents; low income; not SSI/SSDI; prime SNAP eligibility), focusing on periods/places with active ABAWD enforcement (no statewide waivers), and ideally validating with administrative SNAP caseload data (even at state-year level) to show a discontinuity in participation at 50.

---

**#3: PM2.5 Nonattainment and the Green Industrial Transition (Idea 1)**
- **Score: 63/100**
- **Strengths:** Good policy question with a credible quasi-experiment structure (nonattainment designations) and rich outcomes spanning local labor markets, firm dynamics, pollution trajectories, and health. The “composition/green transition” angle is more novel than standard employment-level analyses.
- **Concerns:** The key risk is whether the assignment is truly **sharp at the county level**: PM2.5 nonattainment is often designated for multi-county areas and can involve monitor geography and administrative discretion (making this potentially a **fuzzy RD**, not sharp). Monitoring coverage/measurement error near 12 μg/m³ can blur the running variable; treated sample is modest (~47 counties), which becomes thin once you slice by industry and do multiple outcomes.
- **Novelty Assessment:** **Moderate.** Nonattainment/regulation impacts are heavily studied under the Clean Air Act (ozone, PM2.5 2005), but the 2012 revision and an explicit “green reallocation/Porter channel” focus is less saturated.
- **DiD Assessment:** N/A (RDD design).
- **Recommendation:** **CONSIDER (conditional on: (i) verifying designation rules produce a usable assignment variable at the county/area level; (ii) being explicit that it’s fuzzy RD if needed; (iii) pre-specifying a small set of primary outcomes to avoid “multiple testing by outcome buffet”; (iv) demonstrating enough monitors/observations near cutoff).**

---

**#4: Hospital Readmission Penalties and the Quality-Gaming Tradeoff (Idea 3)**
- **Score: 54/100**
- **Strengths:** Important policy program and strong motivation (“teaching to the test,” observation-stay gaming). Data are accessible and outcomes are salient for CMS decision-making.
- **Concerns:** The proposed “sharp RDD at ERR = 1.0” is **not as sharp as stated**: HRRP penalties are computed through a multi-condition formula and can be effectively continuous in intensity; hospitals can respond strategically in ways that may also affect the running variable (coding, admission/observation practices), threatening RD continuity. Hospital Compare ERR values may be rounded/heaped, weakening RD precision unless you can obtain unrounded assignment metrics.
- **Novelty Assessment:** **Low-to-moderate.** HRRP has a very large literature (mostly DiD/event-study); threshold-based designs and gaming margins have also been discussed, so the incremental novelty hinges on a truly clean RD implementation and a clearly new outcome angle.
- **DiD Assessment:** N/A (RDD design).
- **Recommendation:** **CONSIDER (only if you can: (i) clearly define the true assignment variable used for the penalty with minimal rounding; (ii) map condition-level ERR to the hospital-level penalty formula; (iii) show no manipulation/bunching around 1.0 in the pre-period and use “predetermined” baseline ERR for assignment).** Otherwise, **SKIP**.

---

**#5: Hospital Star Ratings and the Winner-Take-All Effect in Healthcare Markets (Idea 4)**
- **Score: 43/100**
- **Strengths:** Strong conceptual question (discrete labels and market tipping) and high policy relevance given consumer-facing quality reporting. Large national sample of hospitals.
- **Concerns:** Identification is the core problem: hospital star ratings are generated by a complex latent-variable methodology with periodic redesigns, missingness rules, and potentially distribution-based cutoffs—this often means there is **no stable, known, single running variable with a deterministic cutoff** suitable for a credible RD. Reconstructing the composite score risks measurement error that mechanically breaks RD; methodology changes create additional discontinuities unrelated to “just above vs just below” comparisons.
- **Novelty Assessment:** **Moderate.** Hospital star ratings are newer than many report cards, but “ratings/grades as discrete labels” is a heavily studied topic across sectors (including health care), so novelty is not enough to compensate for design fragility.
- **DiD Assessment:** N/A (RDD design).
- **Recommendation:** **SKIP (unless you can obtain the exact CMS continuous summary score used for assignment, verify fixed cutpoints for the period studied, and show stable assignment rules without major redesign).**

---

### Summary

This is a relatively strong batch because several proposals use RDD rather than the more failure-prone DiD. The clear first-choice to pursue is **Idea 2 (NYC energy disclosure RDD)**: it combines clean identification, excellent data, and direct policy relevance. **Idea 5** is highly novel but likely suffers from first-stage weakness/outcome dilution unless tightly targeted to enforced ABAWD settings; **Idea 4** should be avoided unless the star-rating running variable/cutpoints can be made truly RD-credible.