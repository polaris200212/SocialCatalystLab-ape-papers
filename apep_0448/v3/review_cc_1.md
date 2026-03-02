# Internal Review (Claude Code) — Round 1

**Reviewer:** Claude Code (internal self-review)
**Paper:** Back to Work? Early Termination of Pandemic Unemployment Benefits and Medicaid Home Care Provider Supply
**Timestamp:** 2026-03-02T20:05:00

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

The identification strategy exploits staggered early termination of federal pandemic UI benefits across 26 states in June-July 2021. The paper uses Callaway-Sant'Anna (2021) with never-treated states as the comparison group, which is the appropriate estimator for this setting.

**Strengths:**
- Clean treatment timing with 22 states in July 2021 and 4 in August 2021
- Never-treated comparison group avoids contamination from already-treated units
- Multiple robustness checks: TWFE, within-region, randomization inference

**Concerns:**
- The primary threat is ARPA Section 9817 HCBS spending enhancement, which provided 10% FMAP increase to all states simultaneously. The paper discusses this but cannot directly test it. The behavioral health placebo and triple-difference help, but a reader may remain concerned.
- Selection into treatment is non-random (Republican, Southern states). The within-region analysis partially addresses this.

### 2. Inference and Statistical Validity

- CS-DiD ATT of 0.0609 (SE=0.0286) is significant at the 5% level
- Randomization inference with 1,000 permutations yields p=0.045, confirming significance
- TWFE estimates are larger but imprecise, consistent with heterogeneity bias documented by de Chaisemartin and D'Haultfoeuille
- The entity type decomposition shows Type 2 (organizational) drives the result (ATT=0.0650, p=0.017), while Type 1 (individual) is noise (ATT=0.1364, p=0.32)
- Sample sizes are clearly reported and consistent across specifications

### 3. Robustness

- Behavioral health placebo yields a precise null (0.0078, SE=0.0506) — strong evidence for mechanism
- Triple-difference point estimate is large (-0.0966) but p=0.14, consistent with limited power in the DDD design
- Regional robustness (South-only, Midwest-only) and large-state exclusion all corroborate
- Event study shows clean pre-trends and gradual post-treatment onset

### 4. Entity Type Decomposition (New in v3)

This is the key new contribution. The finding that ~90% of HCBS billing NPIs are organizational (Type 2) fundamentally reframes the mechanism: the UI supplement affected agency staffing and billing capacity, not individual practitioner labor supply decisions. This is honest and important — it changes the narrative from "workers returning to work" to "agencies scaling up."

The Type 1 panel has only 50 states (one state has zero individual HCBS NPIs) and ~9 NPIs per state-month, making inference impossible for this stratum. This is appropriately documented.

### 5. Claim Calibration

The abstract and conclusion appropriately frame findings around "billing entities" rather than "workers." The 6.3% provider increase and 14.9% beneficiary increase are stated with appropriate precision. Policy implications in Section 7.5 are proportional to evidence.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **High value:** The entity type decomposition could be strengthened by showing that the post-treatment divergence in Type 2 NPIs tracks the pooled effect almost exactly (suggesting Type 2 is the entire story, not just the majority).

2. **Medium value:** The ARPA concern could be partially addressed by noting that ARPA HCBS spending plans were submitted on different timelines across states. If data on submission dates existed, this would enable a falsification test. Acknowledging this in the limitations section would be transparent.

3. **Optional:** The intensive margin (claims per provider) results currently appear only in the robustness table. A brief discussion of what the extensive vs intensive margin split implies for the mechanism would be useful.

---

## DECISION: MINOR REVISION
