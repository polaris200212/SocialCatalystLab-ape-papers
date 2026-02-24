# Reviewer Response Plan — Round 1

## Summary of Reviews
- **GPT-5.2:** MAJOR REVISION
- **Grok-4.1-Fast:** MINOR REVISION
- **Gemini-3-Flash:** MINOR REVISION

## Grouped Concerns & Planned Actions

### Workstream 1: Inference & Methodology (All 3 reviewers)

**Concern:** Add 95% CIs to main tables; wild cluster bootstrap p-values for 51 clusters.

**Action:**
- Add 95% CIs to Table 2 (main DDD results) in table notes
- Add wild cluster bootstrap p-values using `fwildclusterboot` in R for the main specification
- Report both in Table 2 notes and text

### Workstream 2: Literature (GPT + Grok)

**Concern:** Missing foundational DiD/DDD references and recent HCBS-COVID papers.

**Action:** Add to references.bib and cite in text:
- Goodman-Bacon (2021) — TWFE decomposition
- Callaway & Sant'Anna (2021) — multi-period DiD
- Cameron, Gelbach & Miller (2008) — wild cluster bootstrap
- Autor, Dube & McGrew (2023) — low-wage compression (mechanism)
- Cite and explain why staggered DiD concerns don't apply (continuous, time-invariant treatment)

### Workstream 3: Comparison Group Validity (GPT, primary concern)

**Concern:** BH is directly affected by lockdowns (telehealth expansion, demand changes). Need to show BH trends by stringency to rule out that the DDD is driven by BH rising rather than HCBS falling.

**Action:**
- Add a paragraph in Section 4.2 showing that BH trends are similar across high/low stringency states
- Reference Figure 4 (raw trends) which already shows this
- Add explicit statement: "The DDD result is driven by HCBS declining, not BH rising"
- Mention the CPT professional services alternative control group (already in Table 4) as triangulation

### Workstream 4: Mechanism Evidence (All 3 reviewers)

**Concern:** Workforce scarring inferred from aggregate billing, not directly measured. Need more evidence.

**Action:**
- Expand mechanisms section with reference to Autor, Dube & McGrew (2023) low-wage compression
- Note that individual-level mechanism analysis is beyond scope of aggregate billing data
- Acknowledge as limitation while noting the telehealth comparison controls for demand-side

### Workstream 5: Prose Improvements (from prose review)

**Action:**
- Kill throat-clearing phrases ("Several features merit discussion" → direct statements)
- Sharpen the "slow unwinding" timing in intro
- Fix "The provider count margin shows a negative but imprecise effect" → plain English
- Change "The assumption could be violated if..." → "The logic fails if..."

### Workstream 6: Exhibit Improvements (from exhibit review)

**Action:**
- Add vertical dashed line at x=0 in Figure 1 (event study)
- Update Figure 1 y-axis label to specify "Triple-Difference Coefficient"
- Note: Moving Table 3/Figure 3 to appendix would require restructuring; defer to keep scope manageable

## Execution Order
1. Code changes (wild cluster bootstrap, CIs)
2. References.bib updates
3. Paper.tex revisions (prose, literature, methodology, exhibits)
4. Recompile and verify
