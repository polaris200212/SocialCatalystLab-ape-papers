# Reviewer Response Plan v1

## Grouped Concerns & Actions

### (A) METHODOLOGY
1. **Estimand consistency** (GPT): Clarify that TWFE uses continuous log(MW) while CS-DiD uses discrete adoption — different estimands, presented transparently. Add explicit discussion.
2. **Bene-months measurement** (GPT): Clarify throughout that "beneficiaries served" = bene-months, not unique individuals. Already noted in Table 1 but add to results text.
3. **Power analysis** (GPT, Grok, Gemini): Add formal MDE discussion to limitations.
4. **Confounding policies** (GPT, Gemini): Acknowledge more explicitly. Reimbursement data not available at state-year level; managed care control not feasible with current data. Strengthen existing ARPA robustness discussion.
5. **Bootstrap details** (GPT): Add CS-DiD bootstrap parameters (999 reps, clustered, multiplier bootstrap) to methods.

### (B) LITERATURE
Add missing references:
- Roth et al. (2023) — DiD synthesis
- Neumark & Wascher (2008) — canonical MW overview
- Clemens & Gottlieb (2014) — physician response to admin prices
- Derenoncourt & Montialoux (2021) — MW and racial inequality
- Grabowski (2011) — nursing home payment
- Decker (2012) — Medicaid provider participation

### (C) EXHIBITS
1. Move Figure 6 (RI) to appendix
2. Figure 4: add different line styles (would require R re-run — defer)
3. Table 5 label: already fixed (HCBS × log_mw → hcbs × log_mw in \footnotesize)
4. CS-DiD table merge: deferred (requires R code restructuring)

### (D) PROSE
1. Rewrite opening with waitlist hook
2. Kill roadmap paragraph
3. Improve results narration (less "Column X shows...")
4. Soften "validating parallel trends" to "consistent with"

### (E) OUT OF SCOPE
1. County-level border design (no county identifiers in data)
2. Unique beneficiary counts (T-MSIS aggregation doesn't distinguish)
3. State-year HCBS reimbursement rates (not publicly available)
4. Managed care penetration controls (not in current dataset)
