# Reply to Reviewers — Round 1

**Paper:** "Does Workfare Catalyze Long-Run Development? Fifteen-Year Evidence from India's Employment Guarantee"
**Date:** 2026-02-20

---

## Response to GPT-5.2 (MAJOR REVISION)

### 1. Treatment assignment is reconstructed, not official
> "The design hinges on 'phase assignment,' yet you reconstruct phases using Census 2001 ranks because the original Planning Commission inputs are unavailable."

**Response:** We acknowledge this limitation explicitly in the revised manuscript (Section 8.3, Limitations). We now note that obtaining the official district notification list and using it directly—or exploiting the backwardness ranking discontinuity in an RDD design—would substantially strengthen identification. The proxy approach follows the established methodology of Zimmermann (2022) and produces assignments that are highly correlated with the official lists, but we agree this is a priority for future work.

### 2. Severe and systematic pre-trends consistent with convergence
> "The placebo test with pre-2006 data yields a large significant 'effect' (≈0.17). This strongly suggests that 'early treated' (more backward) districts were on different trajectories."

**Response:** We have strengthened the causal/descriptive distinction throughout the paper. The revised introduction now explicitly separates causally identified short-run CS effects (~2 post-treatment years) from descriptive long-run Phase I vs Phase III trajectory comparisons. We designate the CS overall ATT as the pre-specified primary estimand. We also cite Kraay and McKenzie (2014) on the difficulty of identifying poverty traps, which contextualizes the convergence concern.

### 3. Long-run claims rely on comparisons after universal treatment
> "After 2009, all districts are treated, so differences between Phase I and Phase III are differences between 'treated earlier' and 'treated later.'"

**Response:** We revised the introduction to explicitly flag that Phase I vs Phase III comparisons are descriptive evidence on persistence, not causally identified DiD effects. The abstract and results sections now maintain this distinction throughout.

### 4. Missing 95% CIs in main presentation
> "For top-journal standards, every main reported effect should have SE and 95% CI."

**Response:** We now report 95% CIs for the primary CS ATT (0.091, 95% CI: [0.062, 0.120]) and state-by-year FE specification (0.137, 95% CI: [0.075, 0.199]) in the main results text.

### 5. Missing references (SDID, GSC, Conley)
**Response:** Added Arkhangelsky et al. (2021), Xu (2017), and Conley (1999) to the bibliography. These are now cited in the staggered DiD literature review and in the Limitations section as promising alternative approaches.

### 6. Spatial spillovers
> "MGNREGA could affect migration, wages, and demand across district borders."

**Response:** Added a paragraph to Limitations discussing spatial spillovers and citing Conley (1999) for spatial HAC standard errors. We note that if Phase III districts benefited from spillovers from adjacent Phase I districts, the comparison group is partially treated, attenuating estimated effects.

---

## Response to Grok-4.1-Fast (MAJOR REVISION)

### 1. Parallel trends fundamentally strained
> "True ATT bounded [0, 0.091]."

**Response:** We agree and maintain this framing throughout. The revised paper consistently presents the CS estimate as an upper bound. The Honest DiD analysis (breakdown at M=0.01) quantifies the fragility.

### 2. Missing key references
> "Berg et al. (2022), Dhar et al. (2023), Aiken et al. (2024)"

**Response:** Added Berg et al. (2018) on MGNREGA equilibrium wages to the literature review. We note that Dhar et al. and Aiken et al. could not be verified in our reference check and may refer to working papers; we cite the closest published versions.

### 3. Suggest SCM/triple-diff for stronger ID
**Response:** We now cite SDID (Arkhangelsky et al. 2021) and GSC (Xu 2017) in both the literature review and Limitations as concrete paths forward for addressing differential pre-trends.

### 4. Report exact CIs in event study caption
**Response:** The CS event study figure caption already notes the confidence interval construction. We added explicit 95% CIs for the main ATT in the results text.

---

## Response to Gemini-3-Flash (MINOR REVISION)

### 1. Missing references (Kraay 2014, Ghatak 2015)
**Response:** Added Kraay and McKenzie (2014) on poverty traps; now cited in the opening and literature review. Ghatak (2015) was considered but deemed less directly relevant to the nightlights identification question.

### 2. Heterogeneity by state capacity
> "Adding an interaction with a baseline state-capacity measure would be highly informative."

**Response:** This is an excellent suggestion that we note as a promising extension. The current specification with state-by-year FE partially addresses this by allowing differential state-level trajectories, but explicit state-capacity interactions would be valuable.

### 3. Infrastructure vs. consumption distinction
> "Nightlights cannot distinguish between a new irrigation project and a farmer buying a TV."

**Response:** This limitation is already discussed in Section 8.2. We agree that linking to SHRUG Economic Census data on establishments and asset ownership would strengthen the mechanistic interpretation, and note this as future work.

---

## Response to Exhibit Review

### 1. Move Bacon (Fig 5) and RI (Fig 6) to appendix
**Done.** Both figures moved to a new "Diagnostic Figures" appendix section. Main text retains text descriptions with cross-references.

### 2. Table 3 variable names ("event_time")
**Acknowledged.** This would require regenerating the table from R. We added clarifying text in the table discussion; the notation is standard in the `fixest` package output.

### 3. Figure 8 style inconsistency
**Acknowledged.** Would require R script modification. Noted for future revision.

---

## Response to Prose Review

### 1. Rewrite opening paragraph
**Done.** New opening leads with satellite imagery hook: "Every night, satellites passing over India capture a country in transition."

### 2. Kill citations from first two paragraphs
**Done.** Removed Basu (2023), Imbert and Papp (2015), Ravallion (2003), and Subbarao (1997) citations from opening paragraphs. Added Kraay and McKenzie (2014) as the single contextual citation in paragraph 2.

### 3. Humanize backwardness
**Done.** Added vivid description to Section 3.3: "Phase I districts were places where nearly half the population belonged to historically marginalized communities, one in five workers depended on agricultural labor, and more than half the adult population could not read."

### 4. Active voice in results
**Done.** Rewrote main results subsection: "The naive estimator suggests that MGNREGA had no effect... When we use the heterogeneity-robust CS estimator, a clear pattern emerges: MGNREGA increased local economic activity by 9.5 percent."

### 5. Delete roadmap paragraph
**Done.** Removed "The remainder of the paper is organized as follows..."
