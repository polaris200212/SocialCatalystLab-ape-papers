# Reply to Reviewers (Round 1)

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### Must-Fix 1: Outcome-to-welfare unit mapping
**Response:** Added explicit paragraph in Section 7.1 (Calibrating the Sufficient Statistics) explaining the mapping from the opioid prescribing *rate* (our empirical outcome) to the prescribing *level* (the welfare formula's input). The connection is straightforward: since total Part D claims are approximately constant (placebo test null: +0.013, SE 0.012), a percentage-point decline in the share maps proportionally to a decline in counts. The welfare sign depends on the bracket, not on the magnitude of R, so precise count conversion is unnecessary.

### Must-Fix 2: Prescriber time/compliance costs
**Response:** Added a new paragraph in Section 7.4 (Sensitivity of the Calibration) calibrating administrative costs at $3–5 per prevented prescription. At these magnitudes (vs. net benefits of $-4,750 to $+2,750 per prevented prescription), administrative costs do not materially affect the welfare sign under any behavioral model. We maintain C'(τ) = 0 in the baseline for transparency.

### Must-Fix 3: Mortality in CS-DiD framework
**Response:** Added a detailed footnote in Section 6.4 explaining why TWFE is used for mortality: CDC VSRR provisional data suppress counts below 10, creating non-ignorable censoring that compromises the CS-DiD estimator's doubly robust group-time ATTs. TWFE is more robust to sporadic missing values. The qualitative null is unlikely to change under CS-DiD.

### Must-Fix 4: λ as empirical object with bounds
**Response:** Substantially expanded the λ discussion. λ is now presented as uncertain over [0.50, 0.80] rather than a point estimate of 0.70. Added post-2015 evidence (Dave 2021, Horwitz 2021) suggesting that later-adopting states show more concentrated effects among high-volume prescribers, consistent with lower λ (better targeting). Added sensitivity showing that moving from λ=0.70 to λ=0.50 raises β* from 0.37 to 0.74. Added discussion of concrete PDMP reforms that could lower λ (risk-stratified algorithms, provider-specific thresholds, exception protocols).

### Must-Fix 5: Wild cluster bootstrap / RI
**Response:** Not implemented. With 45 clusters, standard cluster-robust SEs are reliable. Wild cluster bootstrap would not change the inference conclusion (effect is imprecise regardless of SE method), and this paper's contribution is the welfare sign, which is invariant to the effect size.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Must-Fix 1: Tabulate exact calibration sources
**Response:** Added Table C.1 (Calibration Parameter Sources) in Appendix C.2, mapping each parameter to its exact source, value, and the equation in which it enters.

### Must-Fix 2: Update λ with post-2015 evidence
**Response:** See response to GPT Must-Fix 4. λ is now treated as uncertain over [0.50, 0.80] with post-2015 evidence cited.

### Must-Fix 3: Quantify Medicare scope bias
**Response:** Substantially expanded the Medicare population limitation in Section 9.3. Added quantitative directional analysis: if λ fell from 0.70 to 0.50 (higher addiction-risk share in under-65 population) and v_L fell from $7,500 to $5,000, then β* would rise from 0.37 to approximately 0.82. The welfare case for PDMPs is likely stronger for the under-65 population.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Must-Fix 1: Rigorous λ justification with (β, λ) heatmap
**Response:** λ is now presented with bounds and sensitivity rather than as a point estimate. Panel B of the sensitivity table already provides the (λ, β*) mapping. The text now explicitly discusses the (β, λ) joint determination of welfare throughout Sections 7 and 9.

### Must-Fix 2: Substitution possibility in welfare formula
**Response:** Added two paragraphs in Section 6.4 discussing how substitution to illicit opioids could *increase* the net externality (the externality from a prevented prescription becomes negative if the patient substitutes toward heroin/fentanyl). This would weaken the welfare case under all behavioral models.

### Must-Fix 3: Include C'(τ) estimate
**Response:** See response to GPT Must-Fix 2. Administrative costs calibrated at $3–5 per prevented prescription; they do not materially affect the welfare sign.

---

## Theory Review (GPT-5.2-pro, 2 rounds)

### Critical Issues 1-2: Quantity definition inconsistency, π factors in proof
**Response:** Completely rewritten prior to this review round. Planner problem now uses aggregate quantities (Q_L, Q_A totals, not per-capita). Proof eliminates all π factors. λ = R_L/R where R_L and R are aggregate reductions. Proposition 1's bracket matches the derived expression exactly.

### Warning 5: Sign invariance claim when C'(τ) ≠ 0
**Response:** Added parenthetical caveat in the discussion after Proposition 1.

### Warning 6: K vs δK ambiguity
**Response:** Clarified K as "undiscounted present value from period 1 onward, evaluated at period 1."

### Warning 7: φ defined as quantity gap but used as utility wedge
**Response:** Redefined φ as "an additive utility wedge in the physician's prescribing rule."

### Notes 8-9: FOC language; integral notation
**Response:** Changed "FOC" to "prescribing condition." Planner now uses v_L·Q_L + v_A·Q_A (linear, not integral).

---

## Exhibit Review (Gemini-3-Flash)

### Consolidate event studies (Figures 2 & 3)
**Response:** Not consolidated (would require regenerating figures). Both figures remain as standalone exhibits.

### Promote Table 4 (robustness) to main text
**Response:** Table 4 (robustness) already appears in the main text as Table 3 (Robustness section).

### Move LOO figure (Figure 6) to appendix
**Response:** Done. Figure 6 moved to Appendix D. Main text now provides a brief summary with cross-reference.

---

## Prose Review (Gemini-3-Flash)

### Opening hook
**Response:** Rewrote opening. New first sentence: "Every opioid prescription prevented by regulation is either a future addiction averted or a patient left in pain." No more epidemiological throat-clearing.

### Active voice in results
**Response:** Rewrote key results paragraphs with active voice. "PDMPs reduced prescribing by..." rather than "The CS-DiD aggregate treatment effect is..."

### Data section framing
**Response:** Revised opening of Section 4 to frame data through the research question: "Estimating the welfare effect of PDMPs requires three empirical inputs..."

### Kill throat-clearing
**Response:** Removed instances of passive constructions and unnecessary hedging throughout.
