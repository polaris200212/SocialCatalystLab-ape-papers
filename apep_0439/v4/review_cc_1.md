# Internal Review (Round 1)

**Reviewer:** Claude Code (self-review)
**Timestamp:** 2026-02-22T21:28:00

---

## FORMAT CHECK

- **Length:** 34 pages (exceeds 25-page minimum)
- **References:** Bibliography covers cultural economics (Alesina & Giuliano, Bisin & Verdier), Swiss context (Eugster, Basten & Betz), and econometric methods (Young, Conley & Taber)
- **Prose:** All major sections in paragraph form
- **Section depth:** Each section has 3+ paragraphs
- **Figures:** 7 figures with visible data, proper axes
- **Tables:** 8 tables with real regression output

## STATISTICAL METHODOLOGY

- Standard errors reported for all coefficients (municipality-clustered)
- 95% confidence intervals discussed for key parameters
- N=8,727 reported
- Permutation inference at both municipality and canton levels
- BH-adjusted q-values for multiple testing across referenda
- Fractional logit as alternative specification

## IDENTIFICATION STRATEGY

- 2x2 factorial design exploiting historically predetermined cultural boundaries
- Language boundary fixed in 5th century, confessional status in 16th century
- Not a formal spatial RDD but transparently described as complementary
- Covariate balance table added (Table 1)
- Limitations section acknowledges external validity constraints

## WRITING QUALITY

- Strong Shleifer-style opening hook
- Clear narrative arc from puzzle to result
- Results narrated before tables referenced
- Transitions pull reader forward between sections

## OVERALL ASSESSMENT

The paper is methodologically sound and well-written. The 4/4 advisor PASS confirms no fatal errors remain. The main contribution (modularity of cultural dimensions) is clearly stated and robustly supported. The falsification test (reversing main effects on non-gender issues while interaction stays zero) is particularly compelling.

**Key strengths:**
1. Clean natural experiment with historically predetermined variation
2. Precise null result with tight confidence intervals
3. Domain-specificity finding adds novelty beyond the null interaction
4. Comprehensive robustness (permutation, fractional logit, BH adjustment, alternative clustering)

**Minor issues:**
1. Tables 1 and 2 could potentially be consolidated (exhibit review suggestion)
2. Table 3 uses coding-style variable names (vote_date instead of "Referendum FE")
3. Permutation and ridgeline figures could move to appendix to streamline

DECISION: MINOR REVISION
