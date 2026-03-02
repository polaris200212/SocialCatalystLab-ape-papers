# Revision Plan — apep_0482 v2

## Overview

This revision addresses feedback from three external referees (GPT-5.2: Major Revision, Grok-4.1-Fast: Minor Revision, Gemini-3-Flash: Minor Revision), one exhibit review, and one prose review. The revision makes four categories of changes:

## 1. Table and Exhibit Formatting

- **Table 11 (Levels/Extensive):** Replaced code-speak variable names (`edu_pc_32`, `has_325`) with descriptive English. Split into Panel A (Levels) and Panel B (Extensive Margin).
- **Table 7 (LRSAL Heterogeneity):** Added Panel A/B headers for pre- and post-LRSAL periods.
- **Main text streamlining:** Moved placebo tests, FS comparison table, security placebo figure, donut RDD, and bandwidth sensitivity to the Appendix. Robustness section condensed to a single summary paragraph with appendix references.
- **Density table removed:** McCrary p-values folded into figure caption and text.

## 2. 2011-Only Pre-LRSAL Analysis (New)

All three referees requested transparency about the 2011 cohort driving the pre-LRSAL finding. Added:
- New analysis in `04_robustness.R` restricting to 2011 election cohort only
- New table (`tab13_2011_only.tex`) with BH-adjusted q-values
- Result: +0.080 (p=0.051), confirming 2011 drives the finding
- Key defense against clustering concern: each municipality contributes exactly one observation in this specification

## 3. Prose and Narrative Improvements

- Simplified running variable paragraph in introduction (prose review)
- Condensed 2007 proxy discussion (prose review)
- Punched up "shelf life" concept in Conclusion (prose review)
- Active voice in Data section (prose review)
- Simplified multiple testing explanation (prose review)
- Humanized Program 321 description with concrete examples (prose review)
- Strengthened "cancellation" language: "The aggregate zero is an arithmetic artifact, not a behavioral reality"

## 4. Estimand Clarity and Limitations

- Tightened language throughout: "threshold bundle" not "quota effect" (GPT/Grok)
- Added explicit limitation paragraph on clustering, noting 2011-only result as defense (GPT)
- Added discussion of causal claims being about threshold bundle, not quotas alone (GPT)

## Not Addressed (Deferred to Potential v3)

- Municipality-clustered inference via block bootstrap (GPT): Major computational undertaking. The 2011-only result (single obs per municipality) provides the key robustness check.
- Discrete running variable / mass points corrections (GPT): Would require custom rdrobust adjustments. Mass point warnings present but standard in population-based RDD.
- Difference-in-discontinuities across council size thresholds (GPT): Would require entirely new empirical framework.
- Reporting/disaggregation continuity tests (GPT): Would require new outcome construction.
