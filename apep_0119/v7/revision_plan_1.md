# Revision Plan: apep_0119 v7

## Parent: apep_0119 (v6)
## Summary: Table Formatting Fix + Total Electricity Pre-Trend Engagement

### Changes

1. **Table 3 overflow fix**: Column 5 ("Log Price") was cut off at right margin. Fixed by applying `\small` font, rounding CIs to 3 decimal places, and using `*{5}{c}` column spec. Added note flagging Column (4) pre-trends failure.

2. **Total electricity pre-trend discussion (Main Results)**: Added three new paragraphs in Section 6.2 directly confronting the near-linear decline in total electricity event study. Explains decomposition (industrial component drives pre-trend), argues residential event study is the identification-relevant test, and honestly acknowledges the limitation.

3. **Introduction update**: Revised the preview paragraph about additional analyses to flag the total electricity concern upfront.

4. **Discussion expansion**: Replaced single-paragraph treatment of industrial result with three paragraphs addressing total electricity pre-trend, the decomposition argument, what evidence supports/undermines the residential result, and concrete suggestions for future work (manufacturing employment controls).

5. **Conclusion update**: Expanded the caution paragraph to explicitly mention total electricity pre-trend failure as a fundamental warning about EERS vs non-EERS state differences.
