# Initial Research Plan: Where the Money Moves

## Research Question

Do gender quotas in municipal elections cause within-category budget reallocation — shifting spending composition within education (e.g., from secondary schools toward early childhood, school meals, and complementary services) — even when aggregate spending totals show no effect?

## Motivation and Puzzle

A robust finding across 20 years of research: gender quotas increase female political representation but do NOT change aggregate municipal spending composition in European settings (Bagues & Campa 2021 Spain; Ferreira & Gyourko 2014 US; Geys & Sørensen 2019 Norway; Casarico et al. 2022 Italy; apep_0433 France). Yet in India, female leaders do shift spending toward women's priorities (Chattopadhyay & Duflo 2004).

**The resolution hypothesis:** Female politicians in rich democracies don't increase total education or social spending (which is largely determined by intergovernmental transfers and mandates). Instead, they exercise discretion at the margin — shifting resources *within* categories toward early childhood and family services. This reallocation is invisible to aggregate analysis because total category spending stays flat.

## Policy Setting

**Spain's 2007 Equality Law (Ley Orgánica 3/2007):**
- Mandates 40-60% gender balance on candidate lists for municipal elections
- Applies to municipalities above 5,000 inhabitants (Article 44 bis LOREG)
- Extended to municipalities above 3,000 inhabitants from 2011
- Enforcement: non-compliant lists rejected by Junta Electoral (hard veto)
- First applied: May 2007 municipal elections (5,000 threshold)
- First applied at 3,000: May 2011 municipal elections

**Municipal governance:** Elected councils (concejalías) govern ~8,100 municipalities. Council size varies by population (LOREG Art. 179). Councils elect the mayor from among members. Municipalities have fiscal authority over education infrastructure (primary schools), social services, cultural facilities, sports, and local security.

## Identification Strategy

### Multi-Cutoff Population-Threshold RDD

**Running variable:** Official Padrón Municipal population (INE, annual). Determined by census methodology; municipalities cannot manipulate.

**Cutoff 1:** 5,000 inhabitants
- Treatment: quota applies to 2007, 2011, 2015, 2019, 2023 elections
- Budget data: 2010-2023 (post-classification-reform program codes)

**Cutoff 2:** 3,000 inhabitants
- Treatment: quota applies to 2011, 2015, 2019, 2023 elections
- Budget data: 2010-2023

**Estimand:** Sharp RD on within-education budget shares; Fuzzy RD instrumenting female councillor share with threshold indicator.

**Primary specification (for each cutoff separately):**

Y_i = α + τ · D_i + f(X_i - c) + D_i · f(X_i - c) + ε_i

where:
- Y_i = within-education spending share (e.g., program 321 share of total education)
- D_i = 1{population ≥ cutoff}
- X_i = population (running variable)
- f() = local polynomial (triangular kernel, MSE-optimal bandwidth via rdrobust)

**Fuzzy RD (second stage):**

Y_i = α + β · FemaleShare_i + controls + ε_i

where FemaleShare_i is instrumented by D_i.

## Primary Outcomes

### Within-Education Composition (shares of total education spending)
1. **Program 321 share:** Infant/primary education centers (construction, equipment)
2. **Program 323 share:** Infant/primary/special education operations
3. **Program 326 share:** Complementary education services (school meals, transport, extracurricular)
4. **Education HHI:** Herfindahl-Hirschman Index of concentration within education

### Within-Social-Services Composition
5. **Program 231 share:** Primary social assistance (share of total social)
6. **Program 232/233 share:** Elderly care vs. family/childcare services

### Levels (EUR per capita)
7. Total education spending per capita (aggregate null replication)
8. Program 321, 323, 326 per capita individually

## Placebo Outcomes (no expected effect)
- **Program 132 share:** Security/police (within basic services)
- **Program 150/155 share:** Roads/infrastructure (within basic services)
- **Within-security composition:** No reallocation expected

## Robustness Battery
1. McCrary (2008) density test at both cutoffs
2. Covariate balance: pre-treatment population growth, budget per capita, income, unemployment, pre-quota female share
3. Donut RDD: exclude ±100, ±200, ±500 around cutoff
4. Bandwidth sensitivity: 0.5×, 1×, 1.5×, 2× MSE-optimal bandwidth
5. Local polynomial order: linear, quadratic, cubic
6. Pre-treatment placebo: RD estimates on within-education shares in 2003-2006 (pre-quota)
7. Multi-cutoff replication: estimate at 5,000 and 3,000 separately; also pooled
8. Placebo cutoffs: RD at 4,000 and 6,000 (no policy change)
9. Wild cluster bootstrap (by province) for inference
10. LRSAL heterogeneity: pre/post 2013 austerity reform interaction

## Data Sources

| Source | Content | Years | Access |
|--------|---------|-------|--------|
| CONPREL (Ministerio de Hacienda) | Municipal executed budgets, program classification | 2010-2023 | .accdb download, no registration |
| Ministerio del Interior | Municipal election candidates with `sexo` field | 2003-2023 | ZIP download via infoelectoral |
| INE Padrón Municipal | Official population by municipality | 1996-2025 | JSON API, no key |
| INE demographics | Municipal-level demographics, births | 2000-2023 | JSON API |

## Power Assessment

- ~8,100 municipalities in CONPREL per year
- ~2,000 within ±2,000 of 5,000 cutoff (MSE-optimal bandwidth TBD)
- ~3,000 within ±2,000 of 3,000 cutoff
- 14 years × 8,100 = ~113,000 municipality-year observations
- Panel structure: collapse to municipality level (average post-treatment spending) or exploit panel
- First stage: ~4pp increase in female councillor share (Bagues & Campa)
- MDE for composition shares: TBD after data inspection

## Expected Effects and Mechanisms

**If female politicians reallocate within education:**
- Program 321/323 share ↑ (infant/primary centers, operations)
- Program 326 share ↑ (school meals, transport — family services)
- Secondary education programs ↓ (compensating adjustment)
- Education HHI may ↓ (more diversified spending)
- Total education spending unchanged (aggregate null preserved)

**Mechanisms:**
1. **Preference channel:** Female councillors have different spending priorities (Funk & Gathmann 2015)
2. **Agenda-setting:** Female councillors on education/social committees shift committee decisions
3. **Information channel:** Female councillors bring attention to family-relevant service gaps
4. **Voter-response channel:** Parties anticipate female councillors' preferences and adjust platforms

**If null on within-category too:**
- Strengthens the "institutional constraints" explanation (apep_0433)
- Rules out "wrong aggregation level" as the explanation for European nulls
- Still a contribution: precisely bounded null with MDE/equivalence framing

## Code Structure

```
output/apep_0482/v1/code/
├── 00_packages.R          — Load libraries, set themes
├── 01_fetch_data.R         — Download CONPREL, elections, Padrón
├── 02_clean_data.R         — Parse .accdb, compute shares, merge
├── 03_main_analysis.R      — First stage, McCrary, balance, main RD
├── 04_robustness.R         — Donut, bandwidth, placebos, LRSAL
├── 05_figures.R            — RD plots, event studies, placebos
└── 06_tables.R             — Summary stats, main results, robustness
```

## Timeline

1. Data acquisition and cleaning (01_fetch_data.R, 02_clean_data.R)
2. First-stage verification and RDD diagnostics (03_main_analysis.R)
3. Main results and robustness (03_main_analysis.R, 04_robustness.R)
4. Figures and tables (05_figures.R, 06_tables.R)
5. Paper writing (paper.tex)
6. Review and revision cycle
7. Publication
