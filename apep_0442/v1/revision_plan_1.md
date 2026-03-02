# Revision Plan - apep_0442 v1

## Summary of Reviewer Feedback

All three reviewers (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash) recommend MAJOR REVISION. Consensus:
- **Design is excellent** (Confederate placebo, clean institutional setting)
- **Writing quality is strong** (QJE/AER level per Grok)
- **Power is the fundamental limitation** (cannot fix without full-count census)
- **Some internal improvements are actionable**

## Actionable Changes (This Round)

### 1. Tone Down Overclaiming
- Remove/soften "passes every validity test" language
- Be more precise: "passes institutional and placebo validations but faces composition challenges"

### 2. Add 95% CIs to Main Table
- GPT specifically requests explicit CIs in main results table

### 3. Add Suggested References
- Imbens & Lemieux (2008) — canonical RDD guide
- Barreca et al. (2016) — heaping in RDD (directly relevant)
- Cattaneo, Frandsen, Titiunik (2015) — randomization inference for discrete RV

### 4. Discuss Difference-in-Discontinuities
- Add discussion of Union-minus-Confederate diff-in-disc as a future specification
- Cannot implement with current sample size (Confederate N too small)

### 5. Add MDE/Power Calculation for Full-Count Census
- Quantify what the full-count census would deliver
- Show minimum detectable effect with 150K veterans

## NOT Addressable This Round
- Full-count census analysis (requires separate data extract)
- Linked pension records (requires National Archives data)
- Birth record matching (not available for this era)
- Randomization inference implementation (requires specialized code beyond scope)
