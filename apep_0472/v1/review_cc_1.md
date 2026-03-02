# Internal Review — Round 1

**Verdict: MINOR REVISION**

## Strengths

1. **Honest reporting of null results.** The paper transparently reports that the heterogeneity-robust CS-DiD estimator yields a null aggregate effect (+0.20, p>0.50) rather than overselling the borderline TWFE result (-0.78, p=0.087). This is scientifically commendable.

2. **Category-level decomposition reveals interesting heterogeneity.** The finding that violence, public order, vehicle crime, and other theft decline while ASB increases is the paper's most valuable contribution. The reporting mechanism explanation is plausible and well-argued.

3. **Comprehensive robustness.** Multiple estimators (TWFE, CS-DiD, Sun-Abraham), alternative FE specifications, wild cluster bootstrap, borough-wide subsample, and LA-level aggregation. The uniformity of nulls is convincing.

4. **Good institutional knowledge.** The Housing Act 2004 background, enforcement discussion, and coverage heterogeneity sections demonstrate genuine understanding of the policy.

5. **Novel topic.** First large-scale DiD evaluation of selective licensing and crime — fills a clear gap.

## Weaknesses

1. **Placebo test failures.** Two of three placebo categories show significant effects. This is acknowledged but could be discussed more prominently as a threat to identification.

2. **Borough-wide positive coefficient.** The +1.78 result for borough-wide schemes is striking and somewhat puzzling. The endogeneity explanation is reasonable but could be strengthened.

3. **Population approximation.** Dividing LA population equally across LSOAs is crude. Could mention this introduces classical measurement error biasing coefficients toward zero.

4. **Limited pre-treatment window.** Crime data start July 2013, and Newham's scheme starts January 2013 — essentially no pre-period for the first cohort. This limits the CS-DiD precision for the earliest treated unit.

5. **No victimisation survey data.** The reporting mechanism is the central interpretive claim but is fundamentally untestable with the available data.

## Minor Issues

- The title "Waterbed Effect" is somewhat misleading given the null finding — the waterbed operates across categories, not space. Consider whether the title accurately frames the contribution.
- Some tables are slightly too wide (tabularray width warning).
- Table numbering: the placebo table (Table 4) and robustness table (Table 5) come in a different order than the section numbering might suggest.

## Recommendation

The paper is ready for external review. The honest null finding with interesting heterogeneity is the right framing. Minor revisions to address the placebo test discussion and table formatting would improve the paper.
