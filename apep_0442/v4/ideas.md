# Research Ideas — Revision of apep_0442 v2

This is a **revision**, not a new paper. The research question is inherited from the parent paper (apep_0442 v2).

## Idea 1: Switch to Costa Union Army Dataset (SELECTED)

**Policy:** 1907 Service and Age Pension Act — age-62 threshold for Union veterans
**Outcome:** Labor force participation from Costa UA census records (1900 + 1910)
**Identification:** Panel RDD at age 62 using within-person LFP change (ΔY = LFP₁₉₁₀ - LFP₁₉₀₀)
**Why it's novel:** First study to observe the actual first stage (pension take-up) + panel data absorbing individual fixed effects
**Feasibility check:** Confirmed — 39,342 veterans, 20,651 in panel, MDE = 14pp at optimal BW

### Key advantages over v2 (IPUMS-based):
- 10x sample size (21,302 vs ~3,800)
- Panel data (1900 + 1910 linked)
- Observed pension records (actual 1907 Act receipt, amounts, dates)
- Health data from surgeons' certificates
- Density test passes (p = 0.756 vs rejected in v2)
