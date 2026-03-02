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

## Review
- **Advisor verdict:** 3 of 4 PASS after 6 rounds (GPT and Gemini were persistent; Grok and Codex stable PASSes)
- **Top criticism:** Running variable timing — GPT flagged average population vs election-year in every round
- **Surprise feedback:** Council size confound at 5,000 (11→13 seats) — real identification issue requiring honest discussion
- **What changed:** Added sub-period first stages (both weak: -0.024 and -0.019), multiple testing discussion (Bonferroni p_adj=0.26), council size confound, reframed pre-LRSAL as suggestive

## Summary
- **Key lesson:** When the first stage is weak and the mechanism doesn't match the finding, honesty is the best strategy. The paper is stronger for acknowledging limitations.
- **Process lesson:** Advisor review loops productive through round 3, then diminishing returns — shift focus to referee feedback
- **Data lesson:** CONPREL's 2-digit vs 3-digit classification (share_32 aggregate) is a trap — always exclude from analysis. Most municipalities report ~50% of education spending at the undisaggregated 2-digit level.
