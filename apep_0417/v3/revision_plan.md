# Revision Plan: apep_0417 v2 → v3

## Context

**Paper:** apep_0417 — "Where Medicaid Goes Dark"
**Parent:** `papers/apep_0417/v2/`
**Problem:** Two user-identified layout issues:
1. Paired maps (2 maps crammed into one figure) make for a clunky read
2. LaTeX `[H]` float placement + oversized figures (8x9") create large white spaces instead of smooth text-figure interleaving

## Root Causes

1. **Paired maps:** Figures 4-7 each contain two vertically-stacked maps using patchwork's `/` operator, saved at 8x9" (taller than a text page). This forces each figure to span nearly two pages, leaving awkward gaps.

2. **Float placement:** Every figure uses `\begin{figure}[H]` (force exact position), which prevents LaTeX from optimizing placement. Combined with 9"-tall figures, this creates a cascade of white space.

## Changes

### 1. R Code: `code/05_figures.R`

Split paired maps into individual figures, each with its own legend:

| Current | After Split |
|---------|-------------|
| Fig 4: PC + Dental (8x9") | Fig 4: Primary Care (8x4.5"), Fig 5: Dental (8x4.5") |
| Fig 5: Psych + BH (8x9") | Fig 6: Psychiatry (8x4.5"), Fig 7: Behavioral Health (8x4.5") |
| Fig 6: OB-GYN + Surgery (8x9") | Fig 8: OB-GYN (8x4.5"), Fig 9: Surgery (8x4.5") |
| Fig 7: MD vs All comparison (8x9") | Fig 10: No-NP/PA Primary Care (8x4.5"), Fig 11: All Clinicians Primary Care (8x4.5") |

Each individual map:
- Gets `show_legend = TRUE` (standalone)
- Saved at 8x4.5" (fits comfortably within one page with caption)
- No more patchwork stacking

Remaining figures renumber:
- Fig 12: Urban/Rural (was Fig 8)
- Fig 13: Event Study (was Fig 9)
- Fig 14: RI Distribution (was Fig 10)

### 2. LaTeX: `paper.tex`

**Float placement:** Change ALL `\begin{figure}[H]` to `\begin{figure}[tbp]`
- `[tbp]` = try top, then bottom, then page-of-floats
- Allows LaTeX to optimize figure placement around text
- Add `\FloatBarrier` before section boundaries to prevent figures drifting too far

**Figure width:** Reduce from `\textwidth` to `0.9\textwidth` for maps (visual breathing room)

**Text restructuring:** Each desert map gets its own discussion paragraph after the figure block, so LaTeX has text to interleave. Currently 3 paired figures are back-to-back with minimal text — expand into per-specialty paragraphs.

**Update all figure references:** `\ref{fig:desert_pc_dental}` becomes `\ref{fig:desert_pc}` and `\ref{fig:desert_dental}`, etc. Update all captions, labels, and cross-references throughout.

### 3. Scope Limitation

Only `05_figures.R` and `paper.tex` change. Analysis scripts (01-04, 06) are untouched. No re-running of data fetch, cleaning, analysis, robustness, or tables.

## Execution Steps

1. Create workspace: `output/apep_0417/v3/`
2. Copy all artifacts from `papers/apep_0417/v2/`
3. Edit `code/05_figures.R`: split paired maps into individual saves
4. Run `Rscript 05_figures.R` only (regenerate figures)
5. Edit `paper.tex`: update float placement, figure includes, labels, references, discussion text
6. Recompile PDF (pdflatex x 3 + bibtex)
7. Visual QA: verify no white space gaps, smooth interleaving
8. Run advisor review, exhibit review, prose review, external review
9. Create revision artifacts and publish with `--parent apep_0417`

## Verification

- Each desert map occupies roughly half a page (4.5" tall) with caption
- Text flows between figures with no large white gaps
- All 14 figures render correctly with proper legends
- All cross-references resolve (no `??`)
- Page count stays at 25+ pages

## Critical Files

| File | Changes |
|------|---------|
| `code/05_figures.R` | Split 4 paired figures into 8 individual figures |
| `paper.tex` | Float placement `[H]` to `[tbp]`, update 14 figure blocks, add per-map discussion text |
