# Research Idea Ranking

**Generated:** 2026-02-26T11:08:21.177827
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 8908

---

### Rankings

**#1: Tearing the Paper Ceiling — Do Skills-Based Hiring Laws Actually Change Who Works in Government?**
- Score: 69/100
- Strengths: High policy salience and a genuinely under-studied reform with many treated states and long pre-periods; ACS microdata can directly measure the education mix of *state-government* workers at scale. Staggered adoption + modern DiD estimators makes this one of the few “current policy” ideas here that could plausibly clear identification hurdles.
- Concerns: The biggest risk is *outcome dilution*: the policy targets **new hires / specific job classifications**, but ACS mostly observes the **stock** of employees (slow-moving), and “state government” in ACS bundles segments (e.g., higher ed) where degree requirements may not change. Also, effective-date-to-measurement timing is messy in ACS because policy starts mid-year and ACS is fielded year-round.
- Novelty Assessment: **Good novelty.** Outside of the 2024 NBER posting-focused work and practitioner reports, there is not yet a mature causal literature on *actual public-sector workforce composition* effects of skills-based hiring reforms.
- DiD Assessment:
  - Pre-treatment periods: **Strong** (ACS 2005–2021 gives ample pre-period for most states)
  - Selection into treatment: **Marginal** (bipartisan helps, but adoption may respond to staffing shortages / tight labor markets)
  - Comparison group: **Marginal** (never-/later-treated states are usable, but states differ structurally; need strong covariate balance + state trends robustness)
  - Treatment clusters: **Strong** (≈20+ treated states)
  - Concurrent policies: **Marginal** (post-2020 period has many coincident HR changes—pay adjustments, remote work, pensions, hiring freezes—some plausibly correlated with adoption)
  - Outcome-Policy Alignment: **Marginal** (ACS outcome = share of *current* state employees without BA; policy acts on *requirements at hiring*, so it’s aligned but indirect and potentially slow)
  - Data-Outcome Timing: **Marginal** (ACS measured year-round; policies often effective on EO date or later implementation—first “treated year” may contain substantial pre-exposure; CPS monthly could help timing checks)
  - Outcome Dilution: **Marginal** (policy directly affects a minority of the observed stock in early years; dilution can be reduced by focusing on subgroups more likely to be new hires—e.g., ages 22–30, specific occupations/agencies, excluding licensed professions and higher-ed)
- Recommendation: **PURSUE (conditional on: (i) tightening the “treated workforce” definition—exclude higher ed / licensed occupations; (ii) explicit exposure timing strategy—month/quarter mapping with CPS or ACS interview month; (iii) a plan to address dilution—young/new-worker subsamples + longer-run effects as 2024–2026 data arrive)**

---

**#2: The Telegraph and the Market for Local Expertise — Did Information Technology Destroy the Knowledge Monopoly? (1850-1880)**
- Score: 45/100
- Strengths: Very novel question with a compelling historical mechanism; if executed well, it could speak to broad “information technology and gatekeepers” debates and be publishable in economic history / political economy.
- Concerns: As proposed, identification is fragile: telegraph placement is tightly linked to railroads and economic development, and the suggested instrument (railroad proximity) is unlikely to satisfy exclusion (railroads themselves change occupations). Census data are decennial, giving too few pre-periods to credibly validate parallel trends.
- Novelty Assessment: **High novelty** for *labor-market composition of professionals* (most telegraph work is trade/finance/city growth, not professional gatekeeping).
- DiD Assessment:
  - Pre-treatment periods: **Weak** (decennial censuses; for many counties you effectively have ≤2 usable pre observations)
  - Selection into treatment: **Weak** (telegraph arrival follows railroads/commerce—high risk it responds to the same forces moving professionalization)
  - Comparison group: **Marginal** (late-adopting counties may be systematically more rural/less developed)
  - Treatment clusters: **Strong** (many counties)
  - Concurrent policies: **Weak** (rail expansion, urbanization, state licensing/professionalization trends, migration—likely coincident and confounding)
  - Outcome-Policy Alignment: **Marginal** (occupation shares can reflect “knowledge monopoly,” but they’re an indirect proxy and confounded by population growth/structural change)
  - Data-Outcome Timing: **Marginal** (census “as-of” dates are specific—typically June 1 in 1850/1860/1870/1880—telegraph arrival within the decade creates partial exposure and misclassification)
  - Outcome Dilution: **Marginal** (professionals are a small share of population; effects on shares may be mechanically small/noisy, though the outcome is constructed as a share)
- Recommendation: **SKIP (unless redesigned)**. To revive: (i) find plausibly exogenous routing shocks (e.g., military/postal imperatives, topographic least-cost paths with strong controls, or planned-but-not-built segments); (ii) add richer pre-periods (earlier occupation measures, city directories) and/or outcomes closer to the mechanism (newspaper content/prices, legal filings, medical advertisements).

---

**#3: Does the Internet Kill God? Broadband Rollout and the Decline of Religious Authority in America**
- Score: 40/100
- Strengths: Extremely policy- and societally-relevant question with high conceptual novelty; county-level variation is potentially rich, and the mechanism is plausible.
- Concerns: The outcome panel (RCMS) is decennial, giving essentially no credible pre-trends testing and very limited timing resolution; broadband rollout is highly endogenous to urbanization, income growth, and demographics that also drive religious change. The US instruments suggested are not yet convincing or clearly feasible.
- Novelty Assessment: **High novelty** specifically for *causal broadband → religion* in the US; related broadband papers exist, but not on religion with clean ID.
- DiD Assessment:
  - Pre-treatment periods: **Weak** (RCMS: 2000/2010/2020 → at best one clean pre-period relative to early rollout)
  - Selection into treatment: **Weak** (deployment/subscription tracks growth and demographics strongly related to religiosity)
  - Comparison group: **Marginal** (counties differ dramatically; matching/controls help but won’t fix few time periods)
  - Treatment clusters: **Strong** (thousands of counties)
  - Concurrent policies: **Weak** (multiple simultaneous secularization drivers—demographic change, political polarization, opioid crisis, etc.—hard to separate with 3 time points)
  - Outcome-Policy Alignment: **Strong** (RCMS adherents/congregations directly capture institutional religious presence)
  - Data-Outcome Timing: **Weak** (broadband changes annually; outcome observed once per decade → exposure is averaged/latent, creating major attenuation and timing ambiguity)
  - Outcome Dilution: **Strong** (religious participation measures cover the full county population)
- Recommendation: **SKIP (unless you can replace/augment the outcome with high-frequency measures)**—e.g., annual administrative denominational data, high-frequency attendance proxies, or repeated surveys with stable county identifiers; otherwise the design will not survive parallel-trends scrutiny.

---

**#4: The Expert Gatekeeper's Scorecard — Does NIH Peer Review Predict Scientific Breakthroughs?**
- Score: 30/100
- Strengths: Important policy question (NIH is huge) and there is a well-known, strong identification design in principle (payline RDD). A “breakthrough” outcome like disruption index is a potentially interesting twist.
- Concerns: The binding constraint is data access: priority scores/percentiles needed for RDD are not public, and the 2025–2026 reform is too recent to observe meaningful downstream publication/citation outcomes. Without scores (or unfunded near-misses), the key causal lever disappears.
- Novelty Assessment: **Moderate to low novelty** on NIH peer review predictive validity (large literature), though the specific “disruption” angle is somewhat new.
- Recommendation: **SKIP** unless you *already* have a credible NIH data use agreement that includes scores for both funded and unfunded applications and are willing to wait years for post-reform outcomes.

---

**#5: ChatGPT and the Decline of Knowledge Work — Occupation-Level Evidence from the CPS**
- Score: 20/100
- Strengths: Data are abundant and timely; the question is policy-relevant and of broad interest.
- Concerns: Identification is the core failure: occupation-level “AI exposure” is correlated with pre-existing trends, and you already cite evidence of violated pre-trends—this is typically fatal for a clean DiD claim. The space is extremely crowded, making marginal contributions hard even with better design.
- Novelty Assessment: **Low novelty** (many papers already; rapid iteration; high risk of being scooped or dominated).
- DiD Assessment:
  - Pre-treatment periods: **Strong** (many pre-2022 months/years)
  - Selection into treatment: **Marginal** (exposure scores are pre-determined, but they load on occupations already on different trajectories)
  - Comparison group: **Marginal** (high- vs low-exposure occupations differ systematically)
  - Treatment clusters: **Strong** (many occupations)
  - Concurrent policies: **Weak** (post-2022 macro shocks/sectoral layoffs and tech-cycle dynamics differentially hit “exposed” occupations)
  - Outcome-Policy Alignment: **Strong** (employment/earnings map to the “knowledge work decline” claim)
  - Data-Outcome Timing: **Marginal** (ChatGPT launched Nov 30, 2022; CPS November reference week is mostly pre-launch—true “post” starts Dec 2022; manageable but must be handled)
  - Outcome Dilution: **Weak** (ChatGPT affects tasks within jobs; occupation-level outcomes average over many workers not using AI, attenuating effects)
- Recommendation: **SKIP** (unless you can find a much sharper shock + adoption measure at worker/firm level, or an instrument for actual AI take-up).

---

### Summary

Only **Idea 1** looks plausibly fundable as a near-term policy evaluation with a defensible causal design, but it needs an explicit plan for **timing** and—most importantly—**outcome dilution** (stock workforce vs new hires, and which segments of “state government” are truly treated). Ideas 2, 4, and 5 fail the institute’s DiD checklist due to **too few pre-periods** (2), **data infeasibility** (4), or **documented pre-trends/dilution** (5); Idea 3 is intriguing but currently not executable without restricted NIH data and time for outcomes to mature.