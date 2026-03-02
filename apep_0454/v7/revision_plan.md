# Revision Plan: apep_0454 v8 — Honest Reframe

## Context

Paper 454's latest published version (v6 directory, metadata v7) has strong data (T-MSIS, 617K providers, 84 months), good prose, and thorough robustness analysis. But the framing overclaims. Three of four formal sensitivity checks point to trend continuation, not a discrete COVID effect:

- **HonestDiD breakdown Mbar = 0**: Result doesn't survive even zero pre-trend violations
- **augsynth ATT = -0.003 (p = 0.42)**: Alternative estimator finds nothing
- **State-specific trends: -0.30 (p = 0.29)**: Result disappears with state trends

Only **conditional RI (p = 0.038)** supports the finding.

The non-HCBS "falsification" yields a LARGER coefficient (-1.376) than HCBS (-0.879), meaning the exit rate doesn't capture an HCBS-specific mechanism — it indexes broad Medicaid ecosystem fragility.

Despite the v3 revision already softening language, the paper still frames itself as demonstrating causal hysteresis. This revision makes the framing match what the evidence actually supports.

## Scope: Text-Only

**NO new R code. NO new analysis. NO new robustness checks.** The analysis is done. This revision edits `paper.tex` only — reframing claims, softening causal language, and repositioning the contribution.

## What Changes

### 1. Title
**Current:** "The Depleted Safety Net: Hysteresis in Medicaid's Home Care Workforce"
**New:** "The Depleted Safety Net: Provider Attrition and Medicaid's Pandemic-Era Disruption"

Drop "Hysteresis" from the title. The paper has suggestive evidence consistent with hysteresis, not proof of it. Hysteresis remains discussed in the body as one interpretation. The new subtitle is descriptive and accurate.

### 2. Abstract (~10 word changes)
The abstract is already fairly honest. Surgical edits:
- "I show that states where..." → "I find that states where..."
- "The results are consistent with hysteresis in safety-net labor markets" — KEEP (already hedged)
- Ensure no sentence implies causation is established

### 3. Introduction — Paragraph-level edits

**Para 1 (hook):** "finds evidence that they may not" — keep, already hedged.

**Para 3 (results):** "I show that pre-pandemic provider exits predicted..." → "I document that pre-pandemic provider exits predicted..." (one word change)

**Para 4 (identification):** Already very honest about HonestDiD/augsynth. Keep as-is.

**Para 5 (economic stakes):**
- "I find evidence of an analogous phenomenon in safety-net labor markets" → "The pattern is consistent with an analogous phenomenon in safety-net labor markets"
- "No detectable differential recovery is visible in the data" → keep (already hedged)
- "Depletion, once it reaches a critical threshold, appears to be self-reinforcing" → keep ("appears")

**Para 6 (non-HCBS — BIGGEST REFRAME):**
Current: "The finding that pre-COVID exit intensity predicts disruption across all Medicaid provider types — not just HCBS — deserves emphasis... This strengthens the external validity of the finding"

New framing: "The exit rate predicts disruption across all Medicaid provider types — not just HCBS. The non-HCBS coefficient (-1.376) is larger than the HCBS coefficient (-0.879), and a formal test cannot reject equality. This means the exit rate indexes broad state-level Medicaid ecosystem fragility, not an HCBS-specific mechanism. The contribution of this paper is not that HCBS is differentially affected — it is not — but that HCBS disruption has the most consequential welfare implications, because these beneficiaries have the fewest substitutes."

This is HONEST: the exit rate captures generic state-level Medicaid decline. The paper's value is in documenting this and showing where it matters most.

**Para 7 (contribution):** "This paper contributes to three literatures" — keep structure, but adjust language within to match predictive framing. Replace "I show that the supply side matters independently" → "I document that the supply side matters independently".

### 4. Section 6 Results — Throughout
- "Pre-COVID Exits Predicted Pandemic Disruption" (subsection title) — keep, already predictive
- Scan all "I show" → "I find" or "I document"
- Scan all "The finding" → "The pattern" or "The association" where causal tone is implied
- "consistent with a multiplier" — keep (already hedged)

### 5. Section 6.7 Robustness — Framing paragraph
Add a summary paragraph at the end of the robustness section that honestly synthesizes:
"The robustness analysis reveals a tension. The conditional RI (p = 0.038) supports the finding after controlling for regional structure. But three formal sensitivity checks — HonestDiD (breakdown Mbar = 0), augmented synthetic control (ATT ≈ 0), and state-specific trends (p = 0.29) — suggest the result may partly reflect trend continuation rather than a discrete pandemic effect. I interpret the totality of evidence as establishing a strong predictive association between pre-pandemic provider attrition and pandemic-era disruption, with suggestive but not definitive evidence of causal amplification."

### 6. Section 7 Discussion

**7.1 Hysteresis:**
- "The most striking finding is not the pandemic disruption itself but its persistence" → "The most striking pattern..."
- "This is the signature of hysteresis" → "This pattern is consistent with hysteresis"
- The four-mechanism discussion (entry barriers, shifted reservation wages, ARPA uncertainty, self-reinforcing exit) should be framed as "plausible mechanisms" not established facts: "Four features of HCBS markets make them susceptible to hysteresis, if the causal interpretation is correct"
- "The implication for economic theory is that standard models of self-correcting labor markets may not apply" → "If the causal interpretation holds, standard models..."

**7.2 From Providers to People:**
- "The beneficiary coefficient exceeds the provider coefficient, implying a multiplier" → "suggesting a multiplier"
- Keep Oregon Experiment comparison

**7.3 ARPA:**
- Already hedged ("imprecise", "underpowered"). Keep.

### 7. Section 7.4 Limitations
The third limitation paragraph already discusses identification honestly. Add one sentence at the end:
"The strongest interpretation of this paper is predictive rather than causal: pre-pandemic provider attrition is a powerful index of pandemic-era Medicaid disruption, and the mechanisms through which this association operates remain an important question for future work."

### 8. Section 8 Conclusion
- "This paper documents a setting where that prediction appears to fail" — keep ("appears to fail")
- "I find that pre-pandemic erosion... strongly predicts" — keep (already predictive)
- "The evidence is consistent with hysteresis" — keep (already hedged)
- Final paragraph: keep as-is (already beautiful and appropriately framed)

### 9. Global search-and-replace
- All remaining "I show" → "I find" or "I document"
- "demonstrates" → "suggests" or "is consistent with" (context-dependent)
- "The finding" → "The pattern" where it implies causation

## What Does NOT Change

- All R code (00-06)
- All figures and tables
- All robustness analysis and reported numbers
- The bibliography
- The conceptual framework section (Section 3) — this is a model of predictions, which is fine regardless of whether causality is established
- The data section
- The empirical strategy section

## Execution Steps

1. Create workspace `output/apep_0454/v7/`
2. Copy parent artifacts from `papers/apep_0454/v6/`
3. Edit `paper.tex` (all changes above)
4. Re-run ALL R scripts (00-06) to regenerate figures/tables (required by workflow, outputs unchanged)
5. Recompile PDF (pdflatex × 3 + bibtex)
6. Visual QA (page 1, page count, no ??)
7. Run full review pipeline (advisor → exhibit → prose → lit audit → referee)
8. Stage C revisions if needed
9. Publish with `--parent apep_0454`

## Verification

- [ ] Title no longer says "Hysteresis"
- [ ] Abstract uses "find" not "show"
- [ ] No remaining "I show" in the paper
- [ ] Non-HCBS paragraph reframed honestly (indexes ecosystem fragility, not HCBS-specific)
- [ ] Discussion frames hysteresis as "consistent with" not "demonstrates"
- [ ] Robustness section has honest synthesis paragraph
- [ ] Limitations includes "strongest interpretation is predictive"
- [ ] Conclusion preserves Shleifer-quality prose
- [ ] Paper is 25+ pages
- [ ] All exhibits regenerated
