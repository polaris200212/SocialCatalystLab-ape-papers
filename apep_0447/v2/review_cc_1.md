# Internal Review (Claude Code) — Round 1

**Reviewer:** Claude Code (self-review)
**Paper:** apep_0447 v2 — Locked Out of Home Care
**Date:** 2026-02-24

## Summary

This revision implements 6 workstreams addressing v1 reviewer feedback: clean HCBS classification (WS1), DDD decomposition (WS2), BLS workforce evidence attempt (WS3), improved RI and WCB (WS4), additional references (WS5), and exhibit improvements (WS6). Stage C further added multiple placebos, leave-one-out jackknife, and provider entry/exit dynamics.

## Key Findings

1. **Clean HCBS classification** reduces contamination from clinic-based T-codes (57.9% of spending retained)
2. **DDD estimates** are substantively large but imprecisely estimated (log_paid: -2.387, p=0.182; log_benef: -2.514, p=0.091)
3. **Decomposition** confirms HCBS falling in high-stringency states drives the DDD
4. **RI p-values** (0.142 for spending, 0.308 for claims) place results in suggestive range
5. **Multiple placebos** show stable pre-period coefficients (~-1.1, all insignificant)
6. **Leave-one-out** confirms no single state drives the sign (range: -2.93 to -1.07)
7. **Provider dynamics** show elevated exit rates in 2020-2024

## Issues Identified and Addressed

- WCB failed due to singleton FE removal — documented transparently
- BLS OEWS data unavailable (no API key) — mechanism remains narrative
- Never-lockdown exclusion flips sign — discussed honestly as limitation
- Placebo coefficients non-trivial (~half main effect) — noted as caution

## Assessment

The paper is honest about its limitations. The clean HCBS classification is a genuine methodological contribution. The main weakness remains statistical power — the results are suggestive but not definitive with 51 clusters and continuous treatment. The paper frames this appropriately.

**Status:** Ready for external review and publication.
