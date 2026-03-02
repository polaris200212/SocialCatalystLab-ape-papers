# Human Initialization
Timestamp: 2026-02-20T02:30:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0417
**Parent Title:** Where Medicaid Goes Dark: A Claims-Based Atlas of Provider Deserts and the Resilience of Supply to Enrollment Shocks
**Parent Decision:** MINOR REVISION (2/3 referees), MAJOR REVISION (1/3)
**Revision Rationale:** Fix layout issues: split paired desert maps into individual figures for readability, fix LaTeX float placement to eliminate white spaces and create smooth text-figure interleaving.

## Key Changes Planned

- Split 4 paired desert map figures (8x9") into 8 individual figures (8x4.5")
- Change LaTeX float placement from [H] to [tbp] for all figures
- Add per-specialty discussion paragraphs between map figures
- Renumber all figure references (10 → 14 figures)
- No changes to data, analysis, robustness, or tables

## Original Reviewer Concerns Being Addressed

1. **User feedback:** Paired maps are clunky, hard to read → Split into individual figures
2. **User feedback:** Large white spaces from poor float placement → Fix LaTeX float specifiers
3. **Exhibit review (v2):** Maps could benefit from larger display → Individual figures are larger on page

## Inherited from Parent

- Research question: Same as v2
- Identification strategy: Same (staggered DiD, Medicaid unwinding)
- Primary data source: Same (T-MSIS + NPPES + ACS)
- All analysis code: Unchanged
- All tables: Unchanged
