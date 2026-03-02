# Internal Review — Claude Code (Round 1)

**Reviewer:** Claude Code (internal)
**Paper:** Going Up Alone: The Lifecycle and Unequal Displacement of the Elevator Operator
**Round:** 1

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

The paper explicitly frames itself as descriptive economic history, not causal. This is appropriate given the data limitations (decennial census, single post-treatment observation for the SCM). The displacement regressions (Equation 1) are presented as conditional associations with appropriate caveats. The SCM is relegated to the appendix with honest discussion of its limitations. No overclaiming detected.

**Strengths:**
- Honest about the descriptive nature of findings
- SCM appropriately demoted to appendix
- Individual-level linked panel provides rich microdata

**Concerns:**
- The comparison group (janitors, porters, guards) is reasonable but the paper could briefly discuss why other building service workers are the right counterfactual rather than all urban workers

### 2. Inference and Statistical Validity

- Standard errors clustered by state (49 clusters) — appropriate
- IPW correction for linkage selection bias — well-executed
- Sample sizes reported and consistent across tables (483,773 for displacement, 38,562 for operator-only analyses)
- The triple-diff (120 obs, R² = 0.995) is acknowledged as warranting cautious interpretation

**One concern:** The OCCSCORE outcome assigns 0 to NLF workers. This is documented in the table note, but the interpretation could note that this mechanically increases the measured penalty since NLF workers receive the lowest possible score.

### 3. Robustness and Alternative Explanations

- IPW correction is a meaningful robustness check
- Excluding janitors doesn't change results
- Event study, triple-diff, and SCM all corroborate the individual-level findings
- The paper honestly discusses the farm transition share (11%) and acknowledges potential linkage noise

### 4. Contribution and Literature Positioning

The paper positions itself well within automation/labor economics literature. Key citations (Acemoglu & Restrepo, Autor, Brynjolfsson, David, Derenoncourt) are present. The historical comparison to telephone operators provides useful context. The "first complete lifecycle of a fully automated occupation" claim appears well-supported.

### 5. Results Interpretation and Claim Calibration

Claims are well-calibrated to evidence. The positive "Same Occ." coefficient is explained transparently (comparison group baseline). The NYC paradox is framed as a descriptive pattern rather than a causal finding. The racial channeling finding is the paper's strongest contribution and is appropriately emphasized.

### 6. Actionable Revision Requests

**Must-fix:**
1. None — paper is internally consistent and well-documented

**High-value improvements:**
1. Add dependent variable means to displacement regression table for interpretive context
2. Consider adding balance/summary statistics table comparing linked vs. unlinked operators

**Optional polish:**
1. The transition from national lifecycle (Section 4) to individual transitions (Section 5) could be tightened with a bridging paragraph

### 7. Overall Assessment

**Key strengths:**
- Compelling narrative framing with vivid historical detail
- Rich individual-level data (38,562 linked operators)
- Honest about limitations; no overclaiming
- Racial channeling finding is genuinely novel and policy-relevant

**Critical weaknesses:**
- None that are fatal. The paper knows what it is and executes well.

**Publishability:** Strong paper suitable for AEJ: Economic Policy or similar. The historical lens and racial dimension elevate it beyond a standard descriptive exercise.

DECISION: MINOR REVISION
