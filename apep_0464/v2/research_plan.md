# Revision Plan: apep_0464 v2

## Context

Paper apep_0464 v1 ("Connected Backlash: Social Networks, Carbon Tax Incidence, and the Political Economy of Climate Policy in France") received MAJOR REVISION from all 3 referees (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash). The paper combines commune-level French election data with Facebook SCI to show that social network exposure to fuel-vulnerable departments raises RN vote share by 0.48 pp/SD.

**All 3 referees agree on 3 must-fix issues:**
1. **Pre-trends weakness** — Only 1 pre-treatment period (2012 vs 2014 reference), and the 2012 coefficient is large (-1.45 pp)
2. **RI discord** — Randomization inference p=0.135 vs clustered regression p<0.05
3. **SAR rho=0.97 interpretation** — No SEM comparison, likely conflates contagion with correlated errors

**The user also explicitly requests Shleifer-style prose.**

---

## What Changes

### WS1: Expand Pre-Treatment Panel (MUST-FIX, highest impact)

**Problem:** Only 1 pre-treatment observation (2012). Referees cannot assess parallel trends.

**Fix:** Add 4 earlier elections from the same consolidated Parquet data source:
- 2002 Presidential (FN at 16.9% nationally)
- 2004 European
- 2007 Presidential (FN at 10.4%)
- 2009 European

This gives **5 pre-treatment periods** (2002, 2004, 2007, 2009, 2012) instead of 1. The event study with 2014 as reference will show whether network exposure coefficients are near zero across 2002-2012, which would strongly support parallel trends.

**Files modified:** `02_clean_data.R` (expand election filter), `03_main_analysis.R` (event study with 10 elections), `05_figures.R` (updated event study plot), `paper.tex` (rewrite event study discussion)

### WS2: SEM and Spatial Durbin Comparison (MUST-FIX)

**Problem:** All 3 referees demanded SEM comparison. SAR ρ=0.97 could reflect spatially correlated errors rather than network contagion.

**Fix:** Install `spatialreg` package and estimate three spatial models:
- **SAR** (existing): y = ρWy + Xβ + ε
- **SEM** (new): y = Xβ + u, u = λWu + ε
- **SDM** (new): y = ρWy + Xβ + WXθ + ε

Report log-likelihoods, AIC/BIC, and parameter estimates in a comparison table. If SEM fits similarly to SAR, acknowledge that ρ likely captures correlated shocks. If SDM shows θ≈0, SAR is adequate. Present honestly regardless of outcome.

**Files modified:** `07_structural.R` (add SEM/SDM estimation), `06_tables.R` (new comparison table), `paper.tex` (new subsection in structural results)

### WS3: Improved Inference (MUST-FIX)

**Problem:** RI p=0.135 contradicts clustered SE significance. Wild cluster bootstrap wasn't implemented.

**Fix:**
1. Install `fwildclusterboot` and run wild cluster bootstrap (Rademacher weights, 9999 reps)
2. Implement **block-permutation RI**: permute fuel vulnerability within regions (13 blocks), preserving spatial autocorrelation structure — 10,000 permutations
3. Report WCB p-values, standard RI, and block RI in a single inference comparison table

**Files modified:** `04_robustness.R` (add WCB and block RI), `06_tables.R` (inference comparison), `paper.tex` (expanded inference discussion)

### WS4: Continuous Treatment Specification (HIGH-VALUE)

**Problem:** Binary Post throws away tax-rate variation and invites confounding by "post-2017 politics."

**Fix:** Replace binary Post with continuous carbon tax rate:
- Rate_t ∈ {0, 0, 0, 0, 0, 7, 30.5, 44.6, 44.6, 44.6} for the 10 elections
- Specification: RN_ct = α_c + γ_t + β_1(Own_d × Rate_t) + β_2(Net_d × Rate_t) + ε_ct
- This exploits 4 distinct rate levels (0, 7, 30.5, 44.6) rather than binary pre/post
- Report alongside binary Post as complementary specification

**Files modified:** `03_main_analysis.R` (add continuous spec), `06_tables.R`, `paper.tex`

### WS5: Additional Robustness (HIGH-VALUE)

**Problem:** Limited controls and no placebo party outcomes.

**Fix:**
1. **Placebo party outcomes**: Estimate main spec with Green/EELV vote share and center-right (LR/UMP) vote share as outcomes. Network effects should be absent or weak for these parties.
2. **Additional covariates × time**: Add unemployment rate, share with higher education, share foreign-born (all at department level from INSEE) interacted with Post/Rate. Show network coefficient stability.
3. **Urban/rural heterogeneity**: Split sample by urbanization quartile and test whether network effects are stronger in rural areas.

**Files modified:** `02_clean_data.R` (extract additional party outcomes + covariates), `04_robustness.R` (new checks), `06_tables.R`, `paper.tex`

### WS6: Shleifer Prose Rewrite

**Problem:** Introduction is dense with jargon, passive voice, and lacks narrative momentum. User explicitly requests Shleifer-style writing.

**Fix:** Complete prose overhaul:
1. **Introduction**: Open with the GJ puzzle (why did protests spread beyond fuel-dependent areas?), build suspense, delay technical vocabulary, use concrete examples
2. **Results**: Tell stories, not narrate tables. "Network exposure, not direct costs, drives RN support" rather than "Column 3 shows coefficient..."
3. **Conclusion**: End with a sentence that sticks — reframe the policy implication as a fundamental insight about political communication
4. **Throughout**: Active voice 80%+, varied sentence rhythm, earn every sentence

**Files modified:** `paper.tex` (substantial rewrite of introduction, results narrative, conclusion)

---

## What Doesn't Change

- Core identification strategy (shift-share with SCI × fuel vulnerability)
- Primary data sources (SCI, election Parquet, commuting CO2)
- Main specification structure (commune FE + election FE)
- Distance restriction test (>200 km)
- Leave-one-out exercise
- Turnout placebo
- Department-level results (population-weighted)

---

## Execution Order

1. **Setup**: Create workspace `output/apep_0464/v2/`, copy parent code, install packages (`spatialreg`, `fwildclusterboot`, `spdep`)
2. **Data expansion** (WS1): Modify `02_clean_data.R` to include 2002-2009 elections. Re-run `01_fetch_data.R` → `02_clean_data.R`
3. **Re-run core analysis** (WS1 + WS4): Update `03_main_analysis.R` with extended event study and continuous treatment. Re-run.
4. **Robustness expansion** (WS3 + WS5): Update `04_robustness.R` with WCB, block RI, placebo parties, additional covariates. Re-run.
5. **Structural expansion** (WS2): Update `07_structural.R` with SEM/SDM. Re-run.
6. **Regenerate exhibits** (all): Re-run `05_figures.R` and `06_tables.R` for all updated exhibits
7. **LaTeX revision** (WS6): Rewrite paper.tex — prose, new results, new tables/figures, updated discussion
8. **Compile + Visual QA**: pdflatex cycle, check page 1, exhibits, references
9. **Review workflow**: Advisor review → theory review → exhibit review → prose review → referee reviews → Stage C revision
10. **Publish**: `revise_and_publish.py --parent apep_0464 --push`

---

## Key Files to Modify

| File | Changes |
|------|---------|
| `code/00_packages.R` | Add `spatialreg`, `spdep`, `fwildclusterboot` |
| `code/01_fetch_data.R` | No changes (Parquet already has all elections) |
| `code/02_clean_data.R` | Expand election filter to include 2002-2009; extract Green/center-right vote shares; add INSEE covariates |
| `code/03_main_analysis.R` | Extended event study (10 elections), continuous treatment spec |
| `code/04_robustness.R` | Wild cluster bootstrap, block-permutation RI, placebo parties, additional covariates, urban/rural heterogeneity |
| `code/05_figures.R` | Updated event study figure (10 elections), SAR/SEM/SDM comparison |
| `code/06_tables.R` | Updated main results table, new inference comparison, SAR/SEM/SDM table, expanded robustness |
| `code/07_structural.R` | SEM and SDM estimation alongside SAR |
| `paper.tex` | Substantial rewrite: intro, data section (10 elections), results, structural, robustness, discussion, conclusion |
| `references.bib` | Add LeSage & Pace 2009, Anselin 1988 SEM, Cameron et al. WCB |

---

## Verification

1. All R scripts run without error (`Rscript 00_packages.R` through `07_structural.R`)
2. Extended event study shows near-zero network coefficients in 2002-2009 (pre-trends satisfied)
3. SEM/SDM results are reported alongside SAR — log-likelihood comparison is honest
4. WCB p-value and block RI p-value narrow the inference gap vs standard RI
5. Placebo party outcomes (Green, center-right) show no/weak network effects
6. Paper compiles cleanly (no `??` references, page 1 = front matter only, 25+ main text pages)
7. Advisor review passes (3/4 PASS)
8. Abstract ≤ 150 words
