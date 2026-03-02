## Discovery
- **Policy chosen:** Spain's 2007 Equality Law gender quota (5,000/3,000 population thresholds) — Provides multi-cutoff RDD with validated design (Bagues & Campa 2021) and uniquely granular program-level budget data (CONPREL) for within-category decomposition.
- **Ideas rejected:**
  - France parity law: Already done by apep_0433 (comprehensive null). Also, M14 functional budget classification only mandatory for communes >3,500 — the same threshold as parity, making within-category RDD impossible.
  - Cross-country comparative (Spain+France+Italy): Heroic data harmonization, inconsistent granularity across budget classifications. All three models ranked SKIP.
  - Downstream facility provision (EIEL): Slow-moving stock outcomes unlikely to respond within 4-year election cycles. Tournament lesson explicitly penalizes this.
  - LRSAL austerity interaction: Bundled treatment too complex for standalone; incorporated as heterogeneity exercise within main paper.
- **Data source:** CONPREL .accdb files (55MB/year, 659K program-level records per year for ~8,900 municipalities) — confirmed accessible via direct HTTP download, no registration. Election data from Ministry of Interior with direct `sexo` field via infoelectoral package.
- **Key risk:** Within-category effects may also be null (like aggregate effects). If so, must frame as a precisely bounded null that rules out the "wrong aggregation" explanation.
- **Country pivot:** Started with France (user preference), pivoted to Spain during deep discovery after finding (1) apep_0433 already exists and (2) French functional budget data not available at treatment boundary. Four parallel research agents validated this pivot.

## Review (v2 revision)
- **Advisor verdict:** 3 of 4 PASS after 7 rounds (GPT persistent on running variable, Gemini on 2007 proxy; Grok and Codex stable PASSes early)
- **v2 key innovation:** Election-term-level RDD with election-year running variable. This was GPT's #1 v1 critique ("breaks sharp assignment") and the single highest-impact code change.
- **v2 findings:** Pre-LRSAL share_321: +0.075 (p=0.008, BH q=0.050) — survives multiple testing. Post-LRSAL: -0.051 (p=0.025, BH q=0.222). 2011-only: +0.080 (p=0.051). Full-sample: all null.
- **v2 external reviews:** GPT=Major, Grok=Minor, Gemini=Minor.
- **Top v2 criticism:** GPT flagged (1) clustering from stacked municipality obs, (2) discrete running variable/mass points, (3) council size confound (estimand not quota but threshold bundle). Addressed clustering with 2011-only single-obs-per-municipality result. Estimand language tightened throughout.
- **What changed in v2:**
  - Election-term panel (municipality-election as unit, ~39K obs)
  - By-election-cohort first stage revealing "shelf life" (2011 strong → 2019 null)
  - BH-adjusted q-values for all main results tables
  - Levels + extensive margins (appendix)
  - MDE calculations
  - 2011-only pre-LRSAL analysis (appendix, referee response)
  - Narrative reframing: "explaining the European null" not "adding another null"
  - Main text streamlined: robustness exhibits moved to appendix

## Summary
- **Key lesson:** The bundled treatment (quota + council size at 5,000) is an honest limitation that must be acknowledged everywhere, not just in one section. Consistent estimand language ("threshold bundle" not "quota effect") is essential.
- **Process lesson:** Advisor review loops productive through round 3, then diminishing returns. Seven rounds was excessive. The structural changes (election-term design, reframing) were more important than textual fixes.
- **Data lesson:** CONPREL's 2-digit vs 3-digit classification (share_32 aggregate) is a trap — always exclude from analysis. Most municipalities report ~50% of education spending at the undisaggregated 2-digit level.
- **Revision lesson:** When three referees say "show 2011-only," just show it. The 2011-only result (p=0.051) is the most important robustness check because it eliminates (a) the 2007 proxy concern, (b) the clustering concern, and (c) confirms the 2011 cohort drives the finding.
