# Revision Plan — apep_0185 v17

## Context
This is a revision of apep_0185 v16 (conservative rating 22.5). Two of three v16 reviewers gave Minor Revision; one gave Major.

## Changes Implemented

### 1. Reframing (Structural)
- **Title:** Changed subtitle to "Minimum Wage Shocks and Social Network Propagation"
- **Abstract:** Rewritten from 230→137 words; opens with shock propagation puzzle
- **Introduction:** Cut from ~3000→~1700 words; framed around "how do MW shocks propagate?"
- Removed title footnote referencing prior version (APEP-0211)
- Removed boilerplate roadmap paragraph

### 2. New Empirical Content
- **Policy Diffusion Test:** New subsection in Mechanisms; state-year panel testing whether network MW exposure predicts future own-state MW increases
- Framed as descriptive (not causal) per referee feedback

### 3. Prose & Discussion
- Broke up wall paragraphs in magnitude discussion and job flow reconciliation
- Removed hedging language ("suggestive of causal effects under maintained assumptions")
- Conclusion opens with shock propagation, not "This paper provides evidence..."
- Added magnitude caution per referee feedback
- Clarified pre-trend F-test (p=0.007) as level vs. trend distinction
- Clarified RI vs. cluster-robust inference divergence
- Harmonized MW descriptions (CA $15 large employers vs statewide)
- Fixed "synthetic" comment in placebo code

## What Did Not Change
- All R analysis code (01-08 scripts)
- All figures and tables (except new policy diffusion table)
- Appendix structure
- Theoretical framework
- Robustness sections
