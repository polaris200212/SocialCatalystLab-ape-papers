# Revision Plan (Stage C)

## Summary of Reviewer Feedback

Three external referees (GPT-5.2: MAJOR, Grok-4.1: MAJOR, Gemini-3: MINOR). Common themes:

### Must-Address Issues

1. **Long-horizon significance**: GR h=48+ is not significant under permutation/wild-bootstrap inference. Claims of "persistent scarring" overstate what the data supports. All 3 reviewers flagged this.

2. **SMM model fit and welfare claims**: J-test rejects (p=0.0001). Steady-state UR=0.078 vs target=0.055. COVID recovery 10 vs 18 months. The 71:1 welfare ratio is "false precision" given model rejection. All 3 reviewers.

3. **Causal claim scope**: "Demand recessions scar, supply recessions don't" is too broad for n=2 episodes with different exposure measures. Should be reframed as episode-specific rather than general. GPT + Grok.

4. **Policy confounding**: PPP/UI/CARES massive for COVID but not addressed beyond "endogenous." All 3 reviewers.

5. **Permanent demand shock assumption**: Modeling GR as permanent productivity drop overstates welfare loss. Gemini + GPT.

### High-Value (Address if Feasible)

6. Show full LP grid (3-month horizons) for transparency
7. Romano-Wolf stepdown for multiple testing
8. Add pre-determined covariates for GR specification
9. Individual-level evidence for duration mechanism

## Planned Changes

### 1. Recalibrate Claims (Text revisions in paper.tex)
- **Abstract**: Remove "never fully recovers"; replace with "persistent relative deficits" language
- **Introduction**: Qualify title claim as episode-specific; add "comparative case study" framing
- **Results (Sec 6)**: Distinguish h≤36 (statistically significant) from h=48-84 (point estimates negative but imprecise); center on long-run average statistic with CI
- **Conclusion**: Replace "demand recessions scar" with "the housing-driven Great Recession produced persistent cross-state employment deficits; the COVID supply shock did not"

### 2. Address Welfare/Model Fit Honestly (Text + minor code)
- Add paragraph acknowledging J-test rejection and positioning welfare as "illustrative, not precise"
- Add sensitivity: report welfare ratio under half-life=120 months (10 years) demand shock instead of permanent
- Report welfare confidence intervals from bootstrap
- Add sentence: "Worker-income welfare excludes firm profits and vacancy costs"

### 3. Policy Confounding Discussion (Text)
- Expand Section 7.5 to explicitly discuss PPP match-preservation channel
- Reframe as "episode-specific treatment package (shock + policy response)"
- Note that PPP endogeneity to supply-type is the point: policy *response* differs because shock *type* differs

### 4. Half-Life Uncertainty (Text)
- Add bootstrap CI for half-life estimates
- State that 60-month half-life has wide uncertainty band

### 5. Permanent Shock Sensitivity (Already have sensitivity table)
- The sensitivity table already shows results under different parameters
- Add explicit row for "mean-reverting demand shock (half-life 120 months)" if feasible in code
- Otherwise, add text acknowledging the permanent assumption is strong and discuss direction of bias

## Execution Order

1. Text revisions in paper.tex (claims, framing, welfare discussion)
2. Recompile PDF
3. Verify page count ≥25
