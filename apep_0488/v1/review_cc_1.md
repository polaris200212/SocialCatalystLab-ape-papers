# Internal Review (Round 1)

**Reviewer:** Claude Code (self-review)
**Timestamp:** 2026-03-03

## PART 1: CRITICAL REVIEW

### Identification and Empirical Design
The paper employs Callaway-Sant'Anna staggered DiD with 30 treated states (2014+) and 15 never-treated states over 2013-2023. The identification strategy is standard and well-executed. Key concern: the 2012-2013 early adopters are excluded due to the panel start date, which is documented but reduces the treated sample. The 45-state sample and exclusion rationale are clearly stated.

Pre-trends are flat across all specifications, supporting parallel trends. The never-treated control group (15 states) is reasonable but could be vulnerable to spillover if prescribers shift across state lines.

### Inference and Statistical Validity
Standard errors are clustered at the state level (45 clusters). The main CS-DiD estimate is imprecise (-0.070 pp, SE 0.102), failing to reject zero. This is honestly reported. The TWFE benchmark confirms the same pattern (-0.063, SE 0.086). Wild cluster bootstrap is not used but would not change the conclusion given 45 clusters.

### Key Concern: Welfare Calibration
The welfare formula is now internally consistent (aggregate quantities, no π factors, correct λ-based decomposition). The calibration parameters are drawn from the literature with appropriate caveats. The central finding (β* ≈ 0.37 at λ=0.70) is striking and policy-relevant.

However, λ=0.70 is calibrated from a single source (Buchmueller 2018). Given that λ is the most powerful lever in the welfare calculation, more sensitivity to this parameter would strengthen the paper. The sensitivity table already includes λ variation, which partially addresses this.

### Robustness
- Sun-Abraham estimator confirms the main finding
- Placebo outcomes (total prescribers, total claims) show null effects as expected
- Leave-one-out analysis shows stability
- All-cohorts specification (including 2012-2013) yields similar estimates

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Strengthen the targeting discussion**: The finding that welfare depends critically on λ (targeting quality) is the paper's most policy-actionable result. Consider expanding the discussion of what real-world PDMP reforms would change λ (e.g., risk-stratified algorithms, provider-specific thresholds).

2. **Heterogeneity analysis**: The paper could explore whether the prescribing effect varies by state characteristics (initial prescribing level, opioid crisis severity, PDMP design features).

3. **Power discussion**: Given the imprecise main estimate, a formal power analysis would help readers understand what effect sizes could be detected with this sample.

## DECISION: MINOR REVISION
