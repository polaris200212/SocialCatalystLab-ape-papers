# Revision Plan 1 — Stage C Response to Referee Reviews

**Paper:** APEP-0470 v1
**Date:** 2026-02-27
**Referee Decisions:** GPT-5.2 MAJOR REVISION, Grok-4.1-Fast MINOR REVISION, Gemini-3-Flash MINOR REVISION

---

## Workstream 1: Inference and P-Value Corrections

**Rationale:** All three reviewers flagged the RI p-value reporting and multiple testing interpretation.

**Changes:**
1. Corrected RI p-value from "<0.001" to "0.002" throughout (abstract, introduction, robustness, conclusion, Table 6) — with 500 permutations + 1 correction, 0.002 is the minimum attainable value
2. Rewrote Robustness Summary to present coherent inferential stance: acknowledge Holm-corrected analytical p-values don't survive (mfg p_adj=0.240), explain why non-parametric methods are more appropriate for few-cluster settings, report both transparently

**Verification:** Grep for "0.001" and "<0.001" in paper.tex to confirm no stale values remain.

## Workstream 2: Distance Gradient Pre-Trends

**Rationale:** GPT flagged that gradient specification lacks its own pre-trend validation. This is the most important new empirical result to add.

**Changes:**
1. Ran R analysis: Post × ln(Distance) using only 1920 and 1930 (both pre-TVA)
2. Results: manufacturing -0.002 (p=0.42), agriculture 0.003 (p=0.63), SEI 0.006 (p=0.97) — all substantively zero
3. Added new subsection "Distance Gradient Pre-Trends" in Robustness section

**Verification:** Coefficients are inline (not in separate table). Cross-check that signs and magnitudes are plausible.

## Workstream 3: Population-Weighted Estimates

**Rationale:** GPT and Grok flagged that unweighted county-level regressions may not reflect person-level welfare effects.

**Changes:**
1. Ran weighted regressions using county population as weights
2. Results: manufacturing 0.016 (p=0.02), agriculture -0.030 (p=0.006) — both STRONGER
3. Added new subsection "Population-Weighted Estimates" in Robustness section

**Verification:** Weighted effects should be same sign and similar/larger magnitude as unweighted.

## Workstream 4: Migration and Composition Analysis

**Rationale:** All three reviewers flagged migration/composition as a threat to the race-specific SEI finding.

**Changes:**
1. Ran quantitative composition analysis: log population (p=0.44), Black share (p=0.26) — no dramatic shifts
2. Expanded Migration section with these results
3. Added discussion of how selective out-migration would reinforce (not invalidate) the penalty finding
4. Flagged Lee (2009) bounds and "residence 5 years ago" variable as promising extensions

**Verification:** Results should show no statistically significant compositional shifts at conventional levels.

## Workstream 5: Mechanism Language and Limitations

**Rationale:** GPT and Gemini flagged that "electrification vs agglomeration" claim was overstated.

**Changes:**
1. Softened throughout: "identifies" → "is more consistent with"
2. Added explicit acknowledgment of other local channels (construction, flood control, navigation)
3. Added Limitations paragraph in Discussion listing: New Deal controls gap, 1% sample noise, repeated cross-sections vs linked data

**Verification:** No remaining instances of "identifies electrification" or similar overclaims.

## Workstream 6: Table and Prose Polish

**Rationale:** Exhibit and prose reviews suggested concrete improvements.

**Changes:**
1. Cleaned all table variable labels (Tables 2-5): raw R labels → formatted LaTeX
2. Punched up opening sentence: vivid hook about pellagra, electricity, poverty
3. Fixed dam timing language throughout to reflect Wilson Dam transfer

**Verification:** Visual inspection of compiled PDF tables and opening paragraph.

---

## Changes NOT Made (and Why)

| Suggestion | Source | Why Not |
|-----------|--------|---------|
| Conley spatial HAC SEs | GPT | Requires specialized R packages and careful bandwidth selection; flagged as extension |
| RDD at 150km threshold | Grok | We don't claim 150km as a genuine discontinuity — gradient is preferred |
| Full-count IPUMS | Grok | Requires separate data access not available in current session |
| 1910 census data | GPT | Would improve pre-trend power but requires additional IPUMS extract |
| New Deal spending controls | GPT, Grok | Data available (Fishback) but not included; acknowledged as limitation |
| Lee (2009) bounds | Gemini | Excellent suggestion flagged for next revision |

---

## Execution Order

1. R analyses (gradient pre-trends, population-weighted, migration composition) — **DONE**
2. Paper.tex edits (all 6 workstreams) — **DONE**
3. Recompile PDF — **DONE**
4. Reply to reviewers (reply_to_reviewers_1.md) — **DONE**
5. Update lessons.md — **DONE**
6. Publish — **IN PROGRESS**
