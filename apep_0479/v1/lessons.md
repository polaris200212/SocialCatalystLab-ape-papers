## Discovery
- **Policy chosen:** Durbin Amendment (2011 interchange fee cap) — sharp regulatory threshold ($10B), well-documented timing, gap in literature (labor market effects unstudied)
- **Ideas rejected:** ATM surcharge deregulation (insufficient state variation — only 2-3 states with bans), mobile banking/4G rollout (weak exclusion restriction — 4G affects many sectors), bank mergers (endogenous timing)
- **Data source:** FDIC SOD API (branch-level, 1.4M records 2005-2019) + FDIC Financials API (bank-level assets) + BLS QCEW (county-industry employment) + Census Population Estimates
- **Key risk:** Financial crisis confounds — counties with more large-bank presence may have different post-crisis recovery trajectories. Mitigated with DDD design (banking vs non-banking within county) and crisis-county exclusion robustness

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT, Grok, Codex pass; Gemini fail on N discrepancy)
- **Top criticism:** NAICS 522110 measures all commercial banking employment, not teller-specific — title "Decline of the Bank Teller" overpromised relative to data. Retitled to "Local Banking Employment."
- **Surprise feedback:** All three referees flagged the same aggregation issue; positive placebo coefficients for retail/healthcare more concerning than expected; deposit reallocation result (treated banks GAINED deposits) drew significant interest as a novel finding.
- **What changed:** Retitled paper; removed HonestDiD claim; cleaned all table labels; fixed N discrepancy explanation; expanded limitations on industry-vs-occupation aggregation; strengthened pre-trend and bias direction discussion.

## Summary
- Paper documents a genuine null: Durbin Amendment caused branch closures but NOT employment decline
- Central contribution: infrastructure rationalization ≠ proportional job losses
- Key limitation: cannot distinguish "no workers lost" from "tellers replaced by different workers"
- Pre-trends in branches are a genuine concern but do not affect the employment null interpretation
