# Internal Review — Claude Code (Round 1)

**Role:** Reviewer 2 (harsh) + Editor (constructive)
**Timestamp:** 2026-02-25T21:30:00

---

## Summary

This paper uses a spatial RDD at the Grand Paris ZFE boundary (A86 motorway) to estimate the effect of low emission zones on property prices. The main finding is a precisely estimated null (-2.4%, p=0.45). The paper is well-written and honest about its limitations.

## Major Concerns

### 1. McCrary Test Failure (Methodology)
The density test rejects at the boundary. The paper argues this reflects the A86's pre-existing urban structure rather than manipulation, which is plausible. However, this fundamentally weakens the RDD identification. The difference-in-discontinuities estimator partially addresses this, but its own confidence intervals are very wide (±10%).

**Verdict:** Acknowledged and discussed honestly. The paper's framing is appropriate.

### 2. Covariate Imbalance (Methodology)
Two of four balance tests fail (lots, apartment share). Again attributable to the A86, but it means the "pure" cross-sectional RDD is contaminated by pre-existing compositional differences. The controlled specification (Table 2, Col 2) addresses this.

**Verdict:** The difference-in-discontinuities approach is the right response, but the paper could be more explicit that the cross-sectional RDD alone is not fully credible.

### 3. Limited Geographic Scope (External Validity)
Only Grand Paris is studied. The A86 is unique — few other ZFE boundaries follow major motorways. Results may not generalize.

**Verdict:** Appropriately acknowledged in limitations.

## Minor Concerns

1. The house subsample coefficient (0.46) is implausibly large and likely reflects local composition effects. The paper acknowledges this but could be more forceful in dismissing it.
2. The 2021 temporal spike coincides with post-COVID recovery, not ZFE effects. Good that this is discussed.
3. The roadmap paragraph at the end of the introduction is unnecessary.

## Exhibits

1. The map (Figure 7) should be in the main text — spatial papers need geography upfront.
2. Table 3's "PASS/FAIL" column is non-standard for a journal paper.

## Verdict

**MINOR REVISION.** The paper is honest, well-executed, and reports a meaningful null. The identification has genuine weaknesses (McCrary failure, covariate imbalance) but the paper addresses them head-on with the difference-in-discontinuities approach. With exhibit improvements and prose tightening, this is publishable.
