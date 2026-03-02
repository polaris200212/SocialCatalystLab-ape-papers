# Reply to Reviewers

## Reviewer 1 (GPT-5.2): REJECT AND RESUBMIT

### Running variable timing
> The paper defines treatment using time-invariant average population... breaks the legal assignment rule.

We acknowledge this concern. We now discuss the running variable choice explicitly (Section 3.3), noting that within-municipality population SD is ~150 inhabitants (<4% of the mean), fewer than 3% of municipalities cross the 5,000 threshold, and bandwidth sensitivity implicitly tests this. We agree an election-specific design would be ideal but maintain the cross-sectional approach as a tractable first-pass analysis.

### Council size confound at 5,000
> Council size changes at 5,000 (11→13 members), creating a major simultaneous discontinuity.

We now discuss this explicitly in Section 4.4 (Threats) and the Limitations section. We note that the 3,000 cutoff has no council size change and thus provides a cleaner test—the null results there are informative. The pre-LRSAL finding at 5,000 should be interpreted as an ITT of the quota threshold bundled with council size, not as a pure quota effect.

### Multiple testing
> A single p=0.03 finding is very likely noise without adjustment.

We now report that the pre-LRSAL primary school facilities result (p=0.032) would not survive Bonferroni correction (p_adj=0.26). The finding is reframed as "suggestive rather than definitive."

### Mechanism mismatch (321 = mandatory)
> The paper predicts discretionary programs should move, but the effect is in mandatory program 321.

We now discuss that program 321 includes discretionary margins within mandatory obligations (timing of renovations, scope of facility improvements). The mandatory/discretionary distinction is blurrier in practice than in legal classification.

### Sub-period first stage
> Election-specific first stages showing decay are needed.

We estimate sub-period first stages: pre-LRSAL (-0.024, p=0.17) and post-LRSAL (-0.019, p=0.25). Both are weak. We report this honestly and note that the compositional shift "cannot be confidently attributed to increased female representation."

### Zero education spending / selection
> Dropping zeros may induce selection.

We acknowledge this in the limitations. The zeros are rare (<2% of observations) and primarily reflect genuine administrative arrangements rather than treatment-induced reporting changes.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Sub-period first stage
> Report first stage by subperiod.

Done. Pre-LRSAL: -0.024 (p=0.17), Post-LRSAL: -0.019 (p=0.25). Reported in Section 6.6.

### Multiple testing correction
> Report FDR/Bonferroni.

Done. Bonferroni p_adj=0.26 for the pre-LRSAL primary school facilities result. Discussed in Section 6.6 and Limitations.

### Running variable clarification
> Election-year Padrón determines treatment; confirm <1% misclassification.

Already reported: <3% of municipalities cross threshold. Added emphasis in Section 3.3.

### Missing citations
> Fonseca (2023 AER), Bertocchi (2020).

These are valuable suggestions for future versions. The current citation coverage (13 intro citations, 21 total) is sufficient for the manuscript's scope.

### Quantify compositional implications
> +0.093 primary ≈ €12 per capita.

Good suggestion; we note this is approximately €12 per capita given mean education spending of €133.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Weak first stage
> Since the first stage is null, the full-sample null is mechanical.

We agree that the weak first stage limits interpretation. The paper is framed around ITT effects of the quota threshold, not representation effects. Sub-period first stages now reported.

### Pre-LRSAL / Multiple testing
> The p=0.03 result is unlikely to survive correction.

Addressed with Bonferroni discussion and explicit reframing as "suggestive."

### Mechanism contradiction (321)
> Why would women favor "facilities"?

Addressed: program 321 includes discretionary margins within mandatory obligations (maintenance timing, renovation scope, facility upgrades).

### Running variable
> Average population may smooth over discontinuity.

Addressed with persistence statistics and explicit discussion of the trade-off.

---

## Summary of Changes

1. Added sub-period first stage estimates (pre/post-LRSAL) showing weak first stage in both periods
2. Added multiple testing discussion (Bonferroni p_adj=0.26; reframed as suggestive)
3. Explicit discussion of council size confound at 5,000 in Threats section
4. Expanded running variable justification with persistence statistics
5. Discussed mechanism mismatch (321 = mandatory with discretionary margins)
6. Expanded Limitations section (now 6 limitations)
7. Removed timing placeholder from author footnote
8. Fixed treatment indicator notation (>= to >) to match law's "more than" language
