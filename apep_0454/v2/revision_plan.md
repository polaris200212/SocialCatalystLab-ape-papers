# Revision Plan: apep_0454 v2

## Context

Paper 454 ("The Depleted Safety Net") documents that pre-COVID provider exits predicted HCBS supply disruption during COVID. The user (econ professor) raised two issues:

1. **"So what?"** — The paper shows providers left but never answers what happened to PEOPLE who needed those providers. T-MSIS already has beneficiary counts, claims, and spending data — and the code already estimates beneficiary/claims event studies (`es_bene`, `es_claims`) that were never reported in the paper.

2. **Bad control problem** — COVID deaths are partly a mediator (depleted networks → worse pandemic outcomes → more deaths), so controlling for them biases the estimate toward zero. The user correctly identified this as a potential bad control.

**Parent:** apep_0454 v1 (published, conservative rating 17.0)
**Integrity:** Not yet scanned/replicated (just published)
**Referee decisions:** GPT MAJOR, Grok MINOR, Gemini MINOR

---

## Workstream 1: Beneficiary-Side Outcomes (the "so what")

**Goal:** Show that provider exits translated into real harm for beneficiaries.

### R Code Changes

**`02_clean_data.R`** — Add per-beneficiary ratios:
```r
panel[, claims_per_bene := total_claims / pmax(total_beneficiaries, 1)]
panel[, spending_per_bene := total_paid / pmax(total_beneficiaries, 1)]
panel[, ln_claims_per_bene := log(pmax(claims_per_bene, 1))]
panel[, ln_spending_per_bene := log(pmax(spending_per_bene, 1))]
```

**`03_main_analysis.R`** — Add static DiD for all beneficiary outcomes:
- `did_bene`: ln_beneficiaries ~ post_covid_num:exit_rate + unemp_rate | state + month_date
- `did_claims_per_bene`: ln_claims_per_bene ~ same
- `did_spending_per_bene`: ln_spending_per_bene ~ same
- Already has: `es_bene` (event study), `es_claims`
- Add: `es_claims_per_bene`, `es_spending_per_bene` event studies

**`05_figures.R`** — New multi-panel event study figure (2×2):
- Panel A: ln_providers (existing Figure 2)
- Panel B: ln_beneficiaries
- Panel C: ln_claims_per_bene
- Panel D: ln_spending_per_bene

**`06_tables.R`** — Expand main results table to include beneficiary outcomes.

### Paper Changes

- **Section 6.3 (NEW):** "Consequences for Beneficiaries: Access and Service Intensity"
- **Abstract:** Add beneficiary-side result with specific numbers
- **Introduction:** Strengthen the "so what" — provider exits meant real people lost care
- **Discussion 7.2 (NEW):** Interpret beneficiary findings

### Limitation Note
T-MSIS `TOTAL_UNIQUE_BENEFICIARIES` aggregated at NPI×HCPCS level double-counts beneficiaries seeing multiple providers. Frame as "beneficiary-provider encounters" and note that within-state over-time variation is still valid because double-counting rates are approximately stable until the shock.

---

## Workstream 2: Bad Control / DAG Discussion

**Goal:** Address COVID deaths as mediator, not just confounder.

### Key Insight from Reading the Code
The main DiD spec (`did_covid`, line 67-72) already uses NO COVID deaths control — just `unemp_rate` + state/month FE. The "bad control" issue is about what the paper presents and discusses, not about the primary specification.

### R Code Changes

**`03_main_analysis.R`** — Add explicit mediation comparison:
```r
# Spec 1 (MAIN): No COVID controls — total effect of θ_s
did_no_covid <- feols(ln_providers ~ post_covid_num:exit_rate + unemp_rate | state + month_date, ...)

# Spec 2: + COVID deaths per capita — direct effect conditional on pandemic severity
did_with_covid <- feols(ln_providers ~ post_covid_num:exit_rate + unemp_rate + covid_deaths_pc | state + month_date, ...)

# Spec 3: + COVID deaths + stringency — full mediation controls
did_full_controls <- feols(ln_providers ~ post_covid_num:exit_rate + unemp_rate + covid_deaths_pc + stringency | state + month_date, ...)
```

Need to move `covid_deaths_pc` construction from Part 3 (line 171) to `02_clean_data.R` so it's available in the HCBS panel.

**`06_tables.R`** — Main results table shows all three specifications side by side. If coefficient is MORE negative without COVID controls → evidence of mediation.

### Paper Changes

- **Section 5 (Empirical Strategy):** Add explicit DAG discussion + "Identification Challenge: COVID Severity as Mediator" subsection
- Draw DAG in LaTeX (tikz) showing dual-role of COVID severity
- Explain: omitting COVID controls = total effect; including = direct effect net of mediation
- **Table 2:** Show (1) No COVID controls [MAIN], (2) + COVID deaths, (3) + full controls

---

## Workstream 3: Vulnerability Interaction

**Goal:** Test whether depleted states were MORE vulnerable to COVID severity.

### R Code Changes

**`03_main_analysis.R`** — New specification:
```r
vulnerability <- feols(
  ln_providers ~ post_covid_num:exit_rate +
    post_covid_num:covid_deaths_pc +
    post_covid_num:I(exit_rate * covid_deaths_pc) + unemp_rate |
    state + month_date,
  data = hcbs_panel, cluster = ~state
)
```

Negative coefficient on the triple interaction = depleted states amplified COVID's damage.

Run same for beneficiary outcomes.

### Paper Changes

- **Section 6.4 (NEW):** "Safety Net Vulnerability: Exit Rate × COVID Severity"
- **New table:** Vulnerability interaction results
- **Discussion:** If significant, this is the mechanism story — fragility wasn't just about provider counts, it amplified the pandemic's impact

---

## Workstream 4: Address Reviewer Feedback

### Must-Fix (from all 3 reviewers)

1. **Non-HCBS falsification reframing** (GPT priority): coefficient -1.376 > HCBS -0.879
   - Add pooled HCBS/non-HCBS test: interact exit_rate × HCBS × post_covid to test if HCBS is differentially affected
   - Reframe: θ_s captures broad Medicaid market fragility; HCBS is the most policy-relevant case (most vulnerable population, fewest substitutes)

2. **Pre-trend F-stats** (Grok): Report joint F-test on pre-period event study coefficients in table notes

3. **RI permutations**: Increase from 500 → 2,000 (include for beneficiary outcomes too)

4. **Shift-share diagnostics** (Gemini): Discuss which specialties drive instrument power (Goldsmith-Pinkham et al. share analysis)

### Optional/Lower Priority

- Provider type heterogeneity (individual vs agency) — Gemini suggestion
- ARPA spending variation by state — Gemini suggestion (defer to future work)

---

## Results Section Restructuring

| Section | Content | Status |
|---------|---------|--------|
| 6.1 | Pre-COVID exit patterns (descriptive) | Keep |
| 6.2 | Provider supply disruption (main DiD + mediation comparison) | **Revised** |
| 6.3 | Beneficiary access and service intensity | **NEW** |
| 6.4 | Vulnerability interaction (exit_rate × COVID severity) | **NEW** |
| 6.5 | ARPA recovery (DDD, exploratory) | Keep, add pre-trend F-stat |
| 6.6 | Robustness | **Expanded** |

---

## File-by-File Changes

| File | Change | Scope |
|------|--------|-------|
| `02_clean_data.R` | Add per-bene ratios, move covid_deaths_pc here | Small |
| `03_main_analysis.R` | Add mediation specs, vulnerability interaction, beneficiary DiDs | Major |
| `04_robustness.R` | 2000 RI perms, pooled HCBS/non-HCBS test, beneficiary RI | Medium |
| `05_figures.R` | Multi-panel event study (4 outcomes) | Medium |
| `06_tables.R` | Expanded Table 2 (mediation), new Table 3 (beneficiary), new Table 4 (vulnerability) | Major |
| `paper.tex` | New sections 6.3-6.4, DAG in Section 5, revised abstract/intro/discussion | Major |
| `references.bib` | Add Angrist & Pischke (bad controls), Pearl, Cinelli & Hazlett | Small |

---

## Execution Order

1. Create workspace (output/apep_0454/v2/)
2. Copy parent code/data, modify `02_clean_data.R`
3. Restructure `03_main_analysis.R` (all new specs)
4. Expand `04_robustness.R`
5. Update `05_figures.R` and `06_tables.R`
6. Re-run ALL R scripts (00 through 06)
7. Revise `paper.tex` with new results
8. Compile PDF, visual QA
9. Full review pipeline (advisor → exhibit → prose → referee → revision)
10. Publish with `--parent apep_0454`

---

## Verification

- All R scripts run without error
- New Table 2 shows coefficient comparison across control specifications
- Multi-panel event study figure shows parallel trends for all 4 outcomes
- Beneficiary results have specific magnitudes cited in abstract/intro
- DAG is clearly drawn and discussed
- Paper is 25+ pages
- RI permutations increased to 2,000
