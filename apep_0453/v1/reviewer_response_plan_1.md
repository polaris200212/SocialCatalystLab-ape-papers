# Reviewer Response Plan

## Consensus Issues (all 3 reviewers)

### 1. Reframe: Banking as Proxy, Not Causal Channel
All three reviewers flag that the banking coefficient vanishes with controls (Table 3 Col 2, Table 5 Col 6). The paper needs to lead with the formality/convergence finding, not banking causality.

**Action:** Revise abstract, title consideration, introduction framing. Lead with "formality paradox" / convergence. Banking density is presented as a proxy measure from the start.

### 2. Strengthen RI (100 → 500+ permutations)
GPT and Gemini both want more permutations.

**Action:** Increase to 500 permutations in 04_robustness.R.

### 3. Triple-Diff Inconsistency
GPT flags that the triple interaction in Table 4 Col 3 doesn't support "entirely driven by agricultural districts."

**Action:** Review and revise heterogeneity language. Temper claim from "entirely driven" to "concentrated in."

## GPT-Specific Issues

### 4. Missing Bank Data Imputed as Zero
**Action:** Add robustness check dropping 5 districts with missing bank data.

### 5. Wild Cluster Bootstrap
**Action:** Add WCB p-values as robustness.

### 6. District Boundary Harmonization
**Action:** Add note about SHRUG harmonization in data section.

## Prose Improvements (from prose_review)

### 7. Remove Roadmap Paragraph
**Action:** Delete "The remainder of the paper proceeds as follows..." paragraph.

### 8. Punch Up Urbanization Decomposition
**Action:** Rewrite opening of Section 5.5.

## Exhibit Improvements (from exhibit_review)

### 9. Clean Table Labels
**Action:** Already addressed with fixest dictionary.

## Workstream Execution Order

1. Reframe abstract/intro/conclusion (claim calibration)
2. Increase RI permutations + add WCB
3. Add robustness for missing bank data
4. Fix heterogeneity language
5. Prose improvements
6. Add SHRUG harmonization note
7. Recompile and verify
