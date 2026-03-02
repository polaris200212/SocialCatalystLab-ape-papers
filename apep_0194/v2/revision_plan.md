# Revision Plan: apep_0194 → v2

## Context

**Paper:** "Digital Exodus or Digital Magnet? How State Data Privacy Laws Reshape the Technology Sector"
**Current rating:** μ=19.1, rank #50/151 (top 25% APEP, but 0-15 vs journals)
**Integrity:** CLEAN scan, no replication yet
**Reviews:** 1 MAJOR (GPT), 2 MINOR (Grok, Gemini); Advisor: 3/4 PASS (Gemini FAIL on 3 fatal errors)

The paper has a strong research design and compelling framing but is held back by: (1) internal consistency errors that failed advisor review, (2) underdeveloped mechanism evidence, (3) insufficient transparency about California dependence and statistical power, and (4) minor code quality issues. This revision addresses all reviewer concerns to push the rating toward the AEJ-competitive range (22-24).

---

## Workstream 1: Critical Code Fixes

### 1a. Montana treatment reclassification
- **File:** `code/01_fetch_data.R` (line 32, 53-57)
- **Issue:** Montana effective Oct 1, 2024. Code treats it as 2024Q4 since `day() == 1`. Gemini advisor flagged as FATAL: with data ending 2024Q4, Montana has at most 1 quarter of post-treatment data and firms had zero compliance lead time before Q4 outcomes were measured.
- **Fix:** After the treatment coding block, add a filter reclassifying Montana as not-yet-treated (set treat_yearqtr to NA). This reduces effectively-treated states from 8 to 7.
- **Cascade:** All point estimates, tables, figures will change slightly. Must re-run entire pipeline.

### 1b. Remove dead FIPS mapping code
- **File:** `code/01_fetch_data.R` (lines 63-69)
- **Issue:** `match(state.abb, state.abb)` produces 1..50 (not FIPS codes), immediately overwritten by correct mapping on lines 72+.
- **Fix:** Remove the incorrect block, keep only the correct hard-coded FIPS tibble.

### 1c. Document QCEW agglvl_code filtering
- **File:** `code/01_fetch_data.R` (line ~205)
- **Fix:** Add comment block explaining what codes 50, 54-58 represent (all state-level aggregations). Add assertion that area_fips matches state-level pattern (XX000).

### 1d. Log zero-variance state dropping
- **File:** `code/03_main_analysis.R` (lines 104-109)
- **Fix:** Print which states are dropped per industry and whether they are treated/control, so replication can verify no selection bias.

### 1e. Fix permutation count mismatch
- **File:** `code/06_tables.R` (line ~259) and `paper.tex` (line 488)
- **Issue:** Code uses 1000 permutations; table footnote says 500.
- **Fix:** Harmonize all references to 1,000 permutations.

---

## Workstream 2: New Analyses

### 2a. Cohort-specific ATT estimates
- **File:** `code/03_main_analysis.R`
- **What:** Extract group-level ATTs from existing CS-DiD `att_gt` objects using `aggte(type="group")`. Report California ATT separately from 2023 wave (VA, CO, CT) and 2024 wave (UT, OR, TX).
- **Why:** #1 request from GPT-5-mini. Addresses California dependence concern directly.
- **Output:** New RDS file + new table + new figure showing cohort-specific ATTs with CIs.

### 2b. Employment per establishment ratio
- **File:** `code/03_main_analysis.R`
- **What:** TWFE regression of log(emp/estabs) on treatment for each industry.
- **Why:** Gemini requested. If emp/estab rises while total employment falls, confirms small-firm exit mechanism.
- **Output:** New results added to wage/establishment table.

### 2c. Minimum detectable effect calculation
- **File:** `code/04_robustness.R`
- **What:** Formal MDE given 7 treated clusters, 44 control, 40 periods, estimated ICC.
- **Why:** GPT-5-mini requested. Contextualizes null Information Sector result.
- **Output:** MDE reported in Limitations section.

### 2d. Law-strength heterogeneity
- **File:** `code/04_robustness.R`
- **What:** Interact treatment with strong/standard law classification (CA, CO, CT, OR = strong; VA, UT, TX = standard). Test if stronger laws produce larger effects.
- **Why:** Referenced in paper text (Section 2.2) but never executed. Grok specifically requested.
- **Output:** New robustness table row.

---

## Workstream 3: Figures & Tables Updates

### Tables
- **Table 2:** Add 95% CIs below SEs for CS-DiD panel; replace "---" with "n.e." with footnote
- **New table:** Cohort heterogeneity (ATT by treatment wave × industry)
- **New table row:** Employment per establishment results
- **Table 5 footnote:** Fix "500" → "1,000" permutations
- All tables: Update N, state counts (8→7 treated)

### Figures
- **New figure:** Cohort-specific ATT plot (point estimates + 95% CI by treatment wave)
- All existing figures: Regenerated from updated data (mandatory — never copy parent figures)

---

## Workstream 4: Paper.tex Revisions

### 4a. Internal consistency fixes (Gemini FATAL errors)
- Harmonize all coefficient references: use 4-decimal log points in tables, exact exp() percentages in text
- Reconcile NAICS 5415 Sun-Abraham (-0.100***) vs CS-DiD (-0.045, ns): add paragraph explaining estimator sensitivity for this subsector
- Fix "5.8%" → use consistent transformation throughout

### 4b. Treated state count: 8 → 7 everywhere
- Abstract, Introduction, Data, Results, Robustness, Conclusion, all table notes
- Remove Montana from the treated-state list; add footnote explaining reclassification rationale
- Reduce "only N states" mentions to 3 max (abstract, data, conclusion)

### 4c. New results sections
- Cohort-specific ATTs subsection (in Results or Mechanisms)
- Employment per establishment (in Mechanisms)
- MDE paragraph (in Limitations)
- Law strength heterogeneity (in Robustness)

### 4d. Elevate caveats to main text
- RI p=0.404 vs clustered p=0.029 discrepancy: discuss in Results, not just table footnote
- California dependence: prominent paragraph in Results
- Power limitations: main-text discussion, not just endnote

### 4e. Add missing references
- Peukert et al. (2023): CCPA firm-level effects
- Roth et al. (2023): DiD pre-trend sensitivity
- Campbell, Goldfarb & Tucker (2015): Privacy regulation and market structure

### 4f. Revision footnote
- Add `\footnote{This paper is a revision of apep\_0194. See \url{https://github.com/SocialCatalystLab/ape-papers/tree/main/apep_0194}}` to title

---

## Workstream 5: Review Pipeline

1. **Compile PDF** (pdflatex × 3 + bibtex)
2. **Stage A: Advisor review** — 4 models, need 3/4 PASS
3. **Stage A.5: Exhibit review** — Gemini vision feedback on figures/tables
4. **Stage A.6: Prose review** — Writing quality feedback
5. **Stage B: External review** — 3 referee reports
6. **Stage C: Revision** — Address all new feedback
7. Iterate if advisor fails

---

## Workstream 6: Publish

```bash
python3 scripts/revise_and_publish.py output/paper_N/ --parent apep_0194 --push
```

---

## Execution Order

```
Setup workspace (copy parent artifacts, create initialization.md)
  ↓
Workstream 1: Code fixes (Montana, FIPS, agglvl, variance logging, perm count)
  ↓
Workstream 2: New analyses (cohort ATTs, emp/estab, MDE, law strength)
  ↓
Re-run ALL R scripts (00 → 06) — regenerates all data, figures, tables
  ↓
Workstream 3: Verify new figures/tables rendered correctly
  ↓
Workstream 4: paper.tex revisions (consistency, new sections, caveats, references)
  ↓
Compile PDF
  ↓
Workstream 5: Full review pipeline (advisor → exhibit → prose → external → revision)
  ↓
Workstream 6: Publish with --parent apep_0194
```

## Verification
- All 7 R scripts run without error
- Montana absent from treated states in all output
- Page count ≥ 25
- All coefficients in text match tables exactly
- Advisor review: 4/4 PASS (fixing the 3 Gemini fatals)
- 3 fresh external reviews completed
