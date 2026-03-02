# Reviewer Response Plan

**Date:** 2026-02-20
**Reviews addressed:** GPT-5.2 (MAJOR), Grok-4.1-Fast (MAJOR), Gemini-3-Flash (MINOR), Exhibit Review, Prose Review

---

## Workstream 1: Identification & Methodology (Priority: HIGH)

**Concerns raised by:** All three referees

### 1a. Strengthen causal/descriptive distinction
- GPT: "Long-run claims rely on comparisons after universal treatment that are not causally identified"
- Grok: "True effect blurred by convergence"
- **Action:** Explicitly separate causal CS estimates (short-run, ~2 years) from descriptive long-run trajectory comparisons. Add a subsection clarifying estimands.

### 1b. Acknowledge proxy treatment assignment limitation more clearly
- GPT: "Potentially fatal for credibility... use official MGNREGA notification"
- **Action:** Add paragraph in Limitations acknowledging this is a proxy and discussing implications. Note this as a priority for future work. (Cannot obtain official lists within this revision.)

### 1c. Add 95% CIs to main results
- GPT: "Mostly missing in main presentation"
- Grok: "Suggest adding 95% CIs to Table 1 footnotes for main results"
- **Action:** Add 95% CI notes to text for CS ATT (0.091 ± 1.96×0.0147 = [0.062, 0.120]) and key specifications.

### 1d. Discuss paths forward for identification
- GPT suggests RDD at phase cutoffs, SDID, GSC
- Grok suggests synthetic controls, triple-diff
- **Action:** Add a "Future Directions" paragraph in Discussion acknowledging these as promising paths.

---

## Workstream 2: Literature (Priority: MEDIUM)

**Concerns raised by:** All three referees

### 2a. Add missing references
- Gemini: Kraay & McKenzie (2014) poverty traps, Ghatak (2015)
- Grok: Berg et al. (2022) long-run MGNREGA, Dhar et al. (2023) MGNREGA assets, Aiken et al. (2024) MGNREGA violence
- GPT: Arkhangelsky et al. (2021) SDID, Xu (2017) GSC, Conley (1999) spatial SEs
- **Action:** Add all to references.bib, cite in relevant sections.

---

## Workstream 3: Exhibits (Priority: MEDIUM)

**Concerns raised by:** Exhibit review

### 3a. Move Bacon decomposition (Fig 5) and RI (Fig 6) to appendix
- Exhibit review: "Move to appendix — diagnostics that confirm why old method failed"
- **Action:** Move both figures after \appendix, renumber.

### 3b. Clean Table 3 variable names
- Exhibit review: "event_time labels are very 'raw code'"
- **Action:** Cannot change the .tex table file without re-running R. Add a note in the table caption explaining the notation.

---

## Workstream 4: Prose (Priority: MEDIUM)

**Concerns raised by:** Prose review

### 4a. Rewrite opening paragraph
- Prose review: "Classic academic throat-clearing... start with the sky"
- **Action:** Rewrite first paragraph with satellite hook.

### 4b. Remove roadmap paragraph
- Prose review: "Delete it"
- **Action:** Remove "The remainder of the paper is organized as follows..."

### 4c. Humanize backwardness description
- Prose review: "Make us see the backwardness"
- **Action:** Add vivid description to Section 3.3.

### 4d. Active voice in results
- Prose review: "Column X shows Y" → economic discovery narration
- **Action:** Rewrite key results paragraphs.

### 4e. Kill citations from opening paragraphs
- Prose review: "Put the names in the lit review"
- **Action:** Remove or defer citations from first two paragraphs of Introduction.

---

## Workstream 5: Minor Issues

### 5a. Spatial spillovers acknowledgment
- GPT: "MGNREGA could affect migration, wages across district borders"
- **Action:** Add paragraph to Limitations.

### 5b. Multiple hypothesis testing acknowledgment
- GPT: "Consider pre-specifying a main estimating equation"
- **Action:** Clarify in methodology that CS ATT is the pre-specified primary estimate.

---

## Execution Order

1. Add references to references.bib
2. Prose revisions to paper.tex (opening, voice, roadmap, backwardness)
3. Move figures to appendix
4. Add CIs, strengthen identification discussion
5. Add literature citations
6. Recompile and QA
