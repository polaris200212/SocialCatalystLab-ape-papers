# Reviewer Response Plan — Round 1
## APEP-0460 v1

All three referees: MAJOR REVISION. Key issues are: (1) German placebo undermines identification, (2) SCI endogeneity, (3) pre-trend outlier, (4) table rendering. Prose review: A grade.

## Workstream 1: Identification Strengthening (Critical)

### 1a. General International Openness Control
Add `log(total_foreign_SCI) × Post` as control — if UK effect survives after controlling for total international connectedness, this partly addresses the German placebo concern.

### 1b. Residualized UK Exposure
Residualize UK SCI on German SCI. If residualized UK exposure is still significant, this isolates UK-specific variation.

### 1c. Additional Country Placebos
Run Italy and Spain SCI × Post — null results strengthen the UK-specific story.

### 1d. Joint Pre-Trend F-Test
Add formal joint F-test for all pre-period event study coefficients.

## Workstream 2: Mechanism Evidence (Important)

### 2a. Property Type Heterogeneity
Split DVF by houses vs apartments. UK expats buy houses in rural areas; investors buy apartments in cities.

### 2b. Geographic Heterogeneity
Split by coastal/Channel-facing vs interior départements.

## Workstream 3: Exhibit Improvements (Important)

### 3a. Fix Table 5 rendering (already done — resizebox)
### 3b. Consolidate Table 3 into Table 2 (add Swiss column)
### 3c. Promote SCI map to main text
### 3d. Fix Table 2 variable naming (German SCI snake_case)
### 3e. Fix map color note

## Workstream 4: Prose Polish (Nice-to-Have)

### 4a. Cut roadmap paragraph
### 4b. Active voice fixes
### 4c. Reframe German placebo as "European integration channel"
### 4d. Polish conclusion sentence
### 4e. SCI timing discussion strengthening (already done)

## What We Will NOT Do (Out of Scope for This Round)

- Full shift-share Bartik redesign with UK regional GVA shocks (would require rebuilding the entire analysis pipeline — save for revision)
- Obtain pre-2016 SCI vintage (not publicly available)
- Rambachan-Roth bounds (complex implementation)
- Additional outcome variables beyond DVF (INSEE API issues persist)

## Execution Order

1. Run additional R analysis (1a, 1b, 1c, 1d, 2a, 2b) → save new results
2. Regenerate tables and figures
3. Update paper.tex with new results + prose fixes
4. Recompile and verify
