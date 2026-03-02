# Revision Plan — APEP-0457

## Reviewer Consensus (3/3 Major Revision)

All reviewers praised the transparency and data quality but identified the same core issues:
1. Pre-trends violate parallel trends; CS pre-test rejects (p=0.004)
2. Near-threshold DiD is null; placebo cutoffs all significant → no threshold-specific effect
3. Treatment measured post-policy (2017 inventory)
4. RDD magnitude implausible vs DiD (-0.71 vs -0.03)
5. No spillover test

## Actionable Revisions (Feasible in Current Session)

### A. Strengthen Identification
1. **HonestDiD / Rambachan-Roth sensitivity**: Show how sensitive the DiD is to pre-trend violations → bounded treatment effects
2. **Municipality-specific linear trends**: Add linear trend controls to see if results survive detrending
3. **IHS transform**: Replace log to handle zeros (removes selection on log(0))

### B. Reframe Paper
4. **Reposition as descriptive contribution**: Lead with the identification challenge as the central contribution; frame the TWFE as "upper bound" and CS as "lower bound"
5. **Canton × year FE event study**: Show whether pre-trends improve with canton FE

### C. Additional Tests
6. **Spatial spillover test**: Create neighbor exposure variable; test if control municipalities adjacent to treated ones show effects
7. **RDD in changes** (difference-in-discontinuities): Use change in employment (pre to post) as RDD outcome instead of post-period levels

### D. Not Feasible in Current Session
- Pre-2012 second home shares (data doesn't exist in comparable format)
- Municipality-level NOGA construction employment (only at canton level)
- Full synthetic control (computationally expensive, would require restructuring the paper)
