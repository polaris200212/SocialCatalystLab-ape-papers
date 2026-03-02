# Human Initialization
Timestamp: 2026-02-22T16:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0439
**Parent Title:** Where Cultural Borders Cross: Gender Equality at the Intersection of Language and Religion in Swiss Direct Democracy
**Parent Decision:** MAJOR REVISION (substantive improvements addressing all reviewer concerns)
**Revision Rationale:** Substantive revision addressing Gemini advisor fatal errors (unit inconsistencies, narrative-table contradictions), GPT referee major revision concerns (few-cluster inference, covariate balance, identification), deep Shleifer-style prose rewrite, exhibit fixes, and new analyses (canton-level permutation, fractional logit, BH adjustment, covariate balance table).

## Key Changes Planned

### WS1: Fix Gemini Advisor Fatal Errors
- Reconcile abstract headline numbers with table specifications
- Qualify "precisely zero" claims given Table 4 heterogeneity (1981: +3.4**, 2020: -4.8***)
- Convert Table 5 to percentage point units for consistency

### WS2: Shleifer-Style Prose Rewrite
- Complete introduction overhaul (narrative-driven, not thesis-driven)
- Tighten conceptual framework
- Results: story-first, tables-second
- Delete throat-clearing phrases
- Strengthen transitions

### WS3: Exhibit Fixes
- Fix Table 1 column header truncation
- Table 5 unit conversion (decimals → pp)
- Figure 2 Panel C Y-axis cropping fix
- Remove redundant exhibits (old Figure 5 forest plot, Appendix Figure 6)
- Promote ridgeline/distribution plot to main text
- Add covariate balance table
- Add dependent variable mean row to Table 2

### WS4: Strengthen Inference
- Canton-level permutation inference (permute at canton, not municipality)
- Fractional logit robustness
- Benjamini-Hochberg multiplicity adjustment for Table 4

### WS5: Iterative Review Workflow
- Full exhibit review → prose review → advisor review cycle
- External referee review with reply_to_reviewers

## Inherited from Parent (v3)

- Research question: Same (intersection of language and religion on gender voting)
- Identification strategy: Same (OLS with interaction, within-canton FE, permutation inference)
- Primary data source: Same (swissdd referendum data, BFS municipality data)
- Core R analysis code: Enhanced (new robustness checks added)
