# Reviewer Response Plan — apep_0448 v1

## Decisions
- GPT-5.2: Major Revision
- Grok-4.1-Fast: Minor Revision
- Gemini-3-Flash: Minor Revision

## Priority Changes

### 1. Add 95% CIs to Main Tables (All reviewers)
Add [lower, upper] confidence intervals to Tables 2 and 3.

### 2. RI on CS-DiD ATT (GPT critical)
Run RI using the CS-DiD estimator rather than TWFE. Also add wild cluster bootstrap p-values.

### 3. Heterogeneity by Entity Type (GPT, Grok)
Decompose NPI results into individual vs. organizational NPIs using NPPES entity type.

### 4. Exclude Maryland Robustness (Gemini)
Add a row to the robustness table excluding Maryland.

### 5. Prose Improvements (Prose review)
- Remove "remainder of the paper" paragraph
- Active voice in methodology
- Punch up placebo narrative

### 6. Exhibit Improvements (Exhibit review)
- Move Figure 1 to appendix, lead with Figure 2
- Remove redundant appendix figures 8 and 9

### 7. Missing References
Add de Chaisemartin & D'Haultfoeuille (2020), Roth (2022), and other key citations.

### 8. ARPA Confounding Acknowledgment (GPT)
Address ARPA Section 9817 HCBS spending plans as a limitation, note that the behavioral health placebo helps address this.

## Changes NOT Made (with justification)
- Full demand-side decomposition: Beyond scope given data limitations (no beneficiary demographics)
- Size-weighted ATT: Would require individual-level weights not available in aggregated data
- PUA share controls: State-level PUA data not readily available from API
