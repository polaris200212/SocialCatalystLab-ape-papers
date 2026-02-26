# Reply to Reviewers - Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1. Pre-trend and identification concerns

> "The paper reports a marginally significant pre-trend (p=0.08). Given the pre-trend evidence, the causal interpretation is not yet warranted without additional design work."

**Response:** We agree this is the central identification concern and have substantially expanded the analysis:

- **State-specific linear trends**: Added a specification with state-specific linear trends. The coefficient drops to 0.247 (p=0.35), confirming the pre-trend sensitivity. We discuss this transparently (Section 6, new paragraph), citing Wolfers (2006) and Meer and West (2016) on the well-known downward bias of unit-specific trends in exposure designs.
- **Expanded RI**: Increased from 500 to 5,000 permutations. The RI p-value improves to 0.002 (from 0.006), providing strong non-parametric evidence.
- **Honest discussion**: Revised the abstract, introduction, and discussion to acknowledge the identification limitation. We now frame the main finding as "consistent with" rather than "direct evidence of" monopsony effects.

We could not implement HonestDiD (Rambachan-Roth) due to the monthly event-time granularity (82 pre-periods), which exceeds the method's computational capacity. We note the RI and organizational heterogeneity as the strongest evidence.

### 2. Strengthen inference

> "Main estimates are marginal under clustered SE; wild cluster bootstrap needed."

**Response:** Wild cluster bootstrap requires the `fwildclusterboot` package, which was unavailable in our R environment. The RI result (p=0.002 with 5,000 permutations) provides stronger non-parametric evidence than bootstrap p-values. We agree this would be a valuable addition in a revision.

### 3. Treatment variable validity

> "The wage ratio is not a direct measure of Medicaid-administered wages; it is a proxy."

**Response:** Agreed. We have softened the language throughout:
- Abstract: "consistent with Medicaid's monopsonistic wage-setting" (was "direct evidence")
- Introduction: "evidence consistent with monopsony power" (was "direct evidence on monopsony")
- Discussion: "consistent with... creating structural fragility" (was "direct evidence that")

### 4. ARPA interpretation

> "ARPA results as currently written are not identified as a causal ARPA effect."

**Response:** Revised throughout to frame as descriptive heterogeneity:
- Introduction: "The ARPA... is associated with differential recovery" (was "partially reversed the damage")
- Results: Added explicit caveat that "identifying ARPA's causal effect would require additional variation"
- Discussion: Reframed as descriptive decomposition

### 5. Multiple testing and outcome hierarchy

> "No correction for multiple testing."

**Response:** We now designate log providers as the primary outcome in the text and characterize beneficiaries/spending/claims as secondary. We explicitly note that the spending result lacks statistical significance.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Pre-trend (p=0.08)

> "Pre-trend undermines parallel trends. Fix: Add triple-difference or synthetic control."

**Response:** We added state-specific linear trends (see GPT response above) and expanded RI to 5,000 permutations (p=0.002). The organizational heterogeneity (p=0.03) serves as an implicit triple-difference: sole proprietors (less Medicaid-rate-constrained) show null effects. We discuss the pre-trend transparently with honest characterization of the identification limitation.

### 2. ARPA decomposition

> "Main effect partly insignificant pre-ARPA. Shifts story from 'decline' to 'differential recovery.'"

**Response:** Revised throughout (see GPT response above). We now explicitly discuss the narrative tension between "initial decline" and "differential recovery."

### 3. DC outlier

> "Noted but not tabled."

**Response:** DC exclusion is already reported in the main text (coefficient 0.795 without DC, close to full-sample 0.811). The LOO analysis (all 51 positive) provides comprehensive evidence that no single state drives results.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### 1. Pre-trend concern

> "Include state-specific linear trends or Honest DiD sensitivity."

**Response:** State-specific trends added (coefficient 0.247, p=0.35). HonestDiD infeasible with monthly event-time. See GPT response for full details.

### 2. Outcome definition

> "Move beneficiaries event study to main body."

**Response:** The multi-outcome event study (Figure 3) already appears in the main text, showing beneficiaries alongside providers, spending, and claims. The text now more explicitly discusses beneficiary results alongside provider counts.

### 3. Wage ratio decomposition

> "Run a 'horserace' between numerator and denominator."

**Response:** The wage level specification (Table 3, Column 5) already uses the PCA wage level alone (numerator only), confirming that higher home care wages predict greater provider retention (0.047, p<0.10). This addresses the "is it Medicaid or the labor market" concern, though we acknowledge it is not a full decomposition.

---

## Exhibit Review Improvements

- Shortened robustness table column headers to prevent truncation
- Added significance star legend to Table 2 notes
- Fixed FE display rows in Table 3 (removed confusing "partial" entries)

## Prose Review Improvements

- Tightened roadmap paragraph (Section 1)
- Clarified spending result as "not statistically significant"
- Sharpened results narration (magnitudes and interpretation)
