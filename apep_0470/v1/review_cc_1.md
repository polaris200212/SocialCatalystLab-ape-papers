# Internal Review Round 1

**Paper:** The Unequal Legacies of the Tennessee Valley Authority
**Reviewer:** Claude Code (Internal)

## Verdict: CONDITIONAL ACCEPT (Major Revision Required)

## Strengths

1. **Compelling research question.** The intersection of place-based policy and racial inequality is genuinely important and understudied. The paper asks "who benefits?" rather than "does it work?"---a much more interesting question.

2. **Clean identification.** Pre-trends are clean across all three primary outcomes (p > 0.33). The randomization inference (p < 0.001) and wild cluster bootstrap (p = 0.006) provide strong inferential evidence despite few state clusters.

3. **Distance gradient is elegant.** Using continuous distance to dam infrastructure avoids the spatial RDD problem and directly tests the agglomeration vs. electrification channel. The non-parametric bins are informative.

4. **Striking race result.** The TVA × Post × Black coefficient of -1.51 on SEI is a powerful finding. Black residents didn't just gain less---they experienced *worse* outcomes in TVA counties. This is the paper's central contribution.

5. **Beautiful maps.** Figures 1, 2, 6, and 9 are informative and well-designed.

## Weaknesses

1. **Data limitations acknowledged but severe.** Using 1% samples without MLP crosswalks means no individual-level panel. The paper was conceived for individual-level analysis and adapted to county-level. This limits the claims that can be made about mechanisms.

2. **Manufacturing coefficient (0.013) is marginal.** The standard error (0.0073) means the t-statistic is ~1.8, which is borderline. The RI and bootstrap confirm significance, but the reader may be skeptical of the county-level estimate.

3. **Near-zero SEI effect is puzzling.** The paper explains this (manufacturing jobs replacing agriculture aren't much higher status), but the disconnect between the significant manufacturing shift and the near-zero SEI change could be explored more.

4. **Migration section is speculative.** Without individual linking, claims about Black out-migration are necessarily indirect. This section should be more cautious.

5. **Appendix tables have placeholders.** The age cohort table and Holm correction table have placeholder content. These should either be populated with real estimates or removed.

## Required Changes

1. Populate or remove placeholder appendix tables
2. Add caveat about 1% sample power limitations
3. Strengthen the mechanisms discussion to lean harder on what county-level data CAN tell us
