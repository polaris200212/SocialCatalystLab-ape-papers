# Research Idea Ranking

**Generated:** 2026-02-24T15:07:23.991458
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6860

---

### Rankings

**#1: Criminal Politicians and the Composition of Local Development (TOP PICK)**
- **Score: 81/100**
- **Strengths:** Clear, policy-salient question with a credible close-election RDD and unusually rich, *mechanism-relevant* outcomes (SHRUG village amenities, VIIRS, Econ Census) that move well beyond the single-outcome nightlights literature. Data feasibility is unusually strong because SHRUG pre-links core components and the sample of close races should be large.
- **Concerns:** Standard close-election threats still apply (margin manipulation/strategic candidate entry; heterogeneous “criminal” definitions; incumbency/anti-incumbency dynamics), and interpreting “criminal” effects requires careful separation of selection vs. behavior (e.g., crime type, party, wealth jointly determined). Some outcomes (Census VD 2001→2011; Economic Census waves) are infrequent, so exposure windows must be handled carefully to avoid attenuation/mis-timing.
- **Novelty Assessment:** **Moderately high novelty.** There is a known benchmark (Prakash, Rockmore & Uppal 2019) and related work on criminal politicians, but the *decomposition into specific public goods* using SHRUG + VIIRS over multiple cycles is meaningfully new and likely publishable if executed cleanly.
- **DiD Assessment (if applicable):** Not applicable (RDD).
- **Recommendation:** **PURSUE (conditional on: (i) strong manipulation checks—McCrary, covariate balance, donut RD; (ii) pre-specifying exposure windows for decadal/sparse outcomes; (iii) showing robustness to alternative “criminal” definitions—charges vs convictions, serious vs minor, violent vs financial).**

---

**#2: Wealthy Representatives and Local Economic Activity**
- **Score: 72/100**
- **Strengths:** High novelty with a genuinely ambiguous theoretical sign (developmental capacity vs rent extraction), and ADR wealth data are unusually detailed relative to most settings. Close-election designs can credibly “as-if randomize” which candidate (and thus wealth level) governs *within a given matchup*.
- **Concerns:** The proposed “elect the wealthier candidate” treatment needs very careful design: wealth is continuous, self-reported (measurement error/underreporting), and correlated with party strength, criminality, and incumbency. Economic Census outcomes are available only in specific waves (and geography/industry definitions can change), which risks low power and awkward timing relative to MLA terms.
- **Novelty Assessment:** **High novelty.** There is related work on politician wealth (mostly US/other contexts; not much India close-election wealth RDD). This is less “mined” than criminality or alignment.
- **DiD Assessment (if applicable):** Not applicable (RDD).
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: (i) you implement a clean “close-elections as IV for winner wealth” framework—2SLS where Win instruments winner’s wealth; (ii) you validate affidavit wealth against obvious heaping/underreporting patterns; (iii) you can credibly align outcomes to exposure—e.g., rely more on annual VIIRS than sparse Econ Census).**

---

**#3: Party Alignment and Village Public Goods: Evidence from Close State Elections in India**
- **Score: 67/100**
- **Strengths:** Identification via close elections is clean in principle, and the question is policy-relevant in patronage/federalism contexts. Using Village Directory amenities to unpack *what* alignment buys (roads/electricity/schools vs just luminosity) is a concrete contribution.
- **Concerns:** This space is already well-studied conceptually and empirically (alignment → spending/nightlights/jobs), so the bar for novelty is higher. The biggest practical risk is outcome timing: Census Village Directory changes are essentially **2001→2011**, so matching “alignment in a specific election” to a decadal change requires careful exposure definitions (multiple elections, party switches, coalition changes) or you risk a noisy/intention-to-treat estimate.
- **Novelty Assessment:** **Moderate to low novelty.** Alignment effects are a mature literature; the novelty is mainly the amenity decomposition, which is valuable but incremental unless you can isolate specific channels convincingly.
- **DiD Assessment (if applicable):** Not applicable (RDD).
- **Recommendation:** **CONSIDER (conditional on: (i) a tight design for decadal amenities—e.g., restrict to elections that clearly map into 2001–2011 exposure, or build an “alignment share of years 2001–2011” measure; (ii) show results also in annual VIIRS to avoid a single decadal endpoint).**

---

**#4: Educated Politicians and Human Capital Investment: Close-Election Evidence from India**
- **Score: 62/100**
- **Strengths:** Good policy question and plausible mechanisms (administrative capacity, prioritization of schooling). ADR education data plus SHRUG education facility measures make this feasible, and interactions with reservation status could be insightful.
- **Concerns:** Power/feasibility is the main threat: restricting to close races where the top-2 differ meaningfully in education may shrink the sample sharply, and education is tightly bundled with wealth, party rank, dynastic ties, and criminality—RDD helps, but only where there is enough local variation and balance. Like Idea 2, some core outcomes (literacy change 2001→2011) are decadal and may not line up well with specific MLA terms without a careful exposure design.
- **Novelty Assessment:** **Moderate novelty.** Politician education has been studied in multiple contexts, and India has related work on politician identity/quality; India-specific RDD evidence with SHRUG outcomes would still add value but is not “wide open.”
- **DiD Assessment (if applicable):** Not applicable (RDD).
- **Recommendation:** **CONSIDER (conditional on: (i) demonstrating adequate close-race sample size *ex ante*; (ii) prioritizing outcomes with better timing—annual DISE/UDISE+ measures where possible; (iii) pre-registering how you handle covariate bundling—e.g., stratification/controls for wealth/criminality and sensitivity checks).**

---

**#5: Women MLAs and MGNREGA Implementation: Gender and Workfare in India**
- **Score: 49/100**
- **Strengths:** Strong policy relevance (MGNREGA is huge; gender targeting is central) and the outcome measures are tightly aligned with the mechanism (women’s person-days, wage delays, spending composition). If feasible, it could be very influential.
- **Concerns:** Two near-dealbreakers: **(i) sample size** for close mixed-gender contests in unreserved constituencies is likely too small for stable RDD estimates; **(ii) data engineering/mapping** from constituency to blocks/GPs in MGNREGA MIS is nontrivial and measurement error would severely attenuate effects (and may create differential mismeasurement if boundaries differ). Without a credible, validated mapping and a guaranteed extractable panel, the project is high risk.
- **Novelty Assessment:** **Moderately high novelty** for the *specific* link women MLAs → MGNREGA implementation, even though women-politician effects are widely studied.
- **DiD Assessment (if applicable):** Not applicable (RDD).
- **Recommendation:** **SKIP (unless you can secure: (i) a ready-to-use constituency-to-block/GP crosswalk with validation; and (ii) proof that the number of close mixed-gender races yields adequate power).**

---

### Summary

This is a strong batch in terms of identification strategy (close-election RDD) and use of India’s unusually rich political candidate data. **Idea 1** stands out as the clearest “PURSUE” because it combines credible identification with genuinely richer outcomes and a concrete mechanism decomposition that is not yet saturated in the literature. The main weaknesses in the rest are (a) outcome timing/coarseness for decadal Census measures (Ideas 2–3) and (b) feasibility/power constraints (Idea 5).