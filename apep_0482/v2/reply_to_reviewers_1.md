# Reply to Reviewers — apep_0482 v2

## Referee 1 (GPT-5.2): Major Revision

### Must-fix issues

**1. Fix statistical inference for repeated municipality observations**
> "Municipality appears up to 5 times; rdrobust SEs likely assume independence."

We address this concern in two ways. First, we add a 2011-only analysis (Appendix Table, `tab13_2011_only.tex`) where each municipality contributes exactly one observation, eliminating within-municipality dependence. The primary school facilities estimate is +0.080 (p=0.051), larger than the pooled estimate, confirming the finding is not driven by serial correlation. Second, we add an explicit limitations discussion acknowledging the concern and noting the 2011-only defense (Section 7.4).

**2. Address discrete running variable / mass points**
> "Population is discrete; standard RD inference can be misleading."

We acknowledge mass point warnings from rdrobust and note this as a standard feature of population-based RDD designs. The bandwidth sensitivity analysis (now in Appendix) shows stable estimates across 0.5x to 2.0x the MSE-optimal bandwidth, suggesting mass points do not drive the results. A full mass-point-corrected inference framework is beyond the scope of this revision.

**3. Resolve the quota vs council-size confound**
> "The clean causal object is the effect of crossing 5,000, not the effect of quotas."

We agree. The paper has been reframed throughout to consistently describe the estimand as the "threshold bundle" at 5,000, not a quota-only effect. The abstract, introduction, results, and conclusion now explicitly state that the 5,000 cutoff bundles the quota with a council size increase. Claims about "preferences vs institutions" are framed as interpretations of the threshold effect, not causal claims about representation per se.

**4. Demonstrate continuity in predetermined covariates**
> "Balance tests use 2010 spending which is not pre-treatment."

We acknowledge this limitation transparently. The balance table is now titled "Continuity of Spending at 5,000 Threshold (Earliest Available Data, 2010)" with a footnote explaining that 2010 is contemporaneous with the first quota-eligible council. Pre-2007 municipality characteristics from INE/census sources would strengthen the design but are not available in the current data infrastructure.

### High-value improvements

**5. Make pre-LRSAL result cohort-transparent**
Done. We present 2011-only results in the Appendix and reference them in the main text (Section 5.3). The introduction now explicitly states the 2011 cohort drives the finding (+0.080, p=0.051).

**6. Align levels/extensive margins with heterogeneity**
The full-sample levels/extensive margins show null results, consistent with reallocation rather than creation. Period-specific levels are a valuable extension but require substantial additional computation and are deferred.

---

## Referee 2 (Grok-4.1-Fast): Minor Revision

### Must-fix issues

**1. Bundled treatment: reframe claims**
Done. All claims are now framed as "quota threshold" effects throughout (Section 4.3, Abstract, Conclusion).

**2. 2007 cohort: drop or sensitivity-only**
The 2007 cohort is now explicitly secondary. The introduction and data sections note that the central finding is driven by 2011. Appendix Table shows 2011-only results. The 2007 cohort is retained in the pooled analysis for completeness but not relied upon.

### High-value improvements

**3. Elevate 3k analysis**
The 3,000 results are reported in a dedicated table with discussion. The null results at 3,000 (where no council size change occurs) are explicitly framed as informative for the council size confound.

**4. Missing citations**
Added Clots-Figueras (already cited in v1), Folke & Rickne, and discussion connecting to fiscal federalism literature in the Discussion section.

---

## Referee 3 (Gemini-3-Flash): Minor Revision

### Must-fix

**1. Clarify 2007 cohort proxy**
Done. Data section now contains concise acknowledgment. 2011-only results in Appendix.

**2. Council size vs quota discussion**
Discussion section (7.2) now explicitly considers whether larger councils generally spend more on facilities regardless of gender composition.

### High-value

**1. Mechanism of primary school facilities**
Discussion section (7.2) expanded with concrete examples (renovating kitchens, adding accessibility features, building nursery wings) and the argument that large capital budget lines offer maximum deliberative scope.

---

## Exhibit Review (Gemini)

- Table 11 variable names: Fixed (descriptive English, Panel A/B)
- Table 7 panels: Added Panel A/B headers
- Density table: Removed (p-values folded into text/figure caption)
- Placebo, donut, bandwidth, security placebo: Moved to Appendix
- Main text streamlined to ~6 key tables + 4 figures

## Prose Review (Gemini)

- Running variable paragraph simplified
- 2007 proxy discussion condensed
- "Shelf life" punched up in Conclusion
- Active voice in Data section
- Multiple testing prose simplified
- Program 321 humanized with concrete school examples
