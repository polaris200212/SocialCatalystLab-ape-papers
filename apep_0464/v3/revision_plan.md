# Revision Plan: apep_0464 v3 (Revising v2)

## Context

Paper apep_0464 v2 ("Connected Backlash: Social Networks and the Political Economy of Carbon Taxation in France") was published and calibrated in tournament. Performance: **μ=25.4, cons=19.8, rank #9 APEP, 24W/16L/0T**. All 3 v2 referees gave MAJOR REVISION (GPT, Gemini) or MINOR (Grok).

The paper's central finding — that network exposure to fuel-vulnerable départements predicts RN vote gains post-carbon-tax — is undermined by one critical inference failure: **WCB p=0.377** for the key network coefficient. This is cited in **15+ tournament losses**. Resolving it is the single highest-impact change possible.

Tournament losses also consistently cite: post-treatment SCI, insufficient controls for differential trends, and overclaimed structural results.

---

## Workstreams

### WS1: Resolve Inference Crisis (MUST-FIX, P0)

**Problem:** WCB p=0.377 vs clustered SE p<0.001 for the network coefficient. Cited in 15+ tournament losses.

**Fix — three-pronged approach:**

1. **AKM (2019) shift-share robust SEs** using `ShiftShareSE::reg_ss()` (confirmed available on R 4.5.2). This is the inference method designed for exactly this setting — shift-share regressions where shared exposure induces correlation. Run at dept × election level (N=960, the PRIMARY specification).

2. **Two-way clustering** (dept + election) via `fixest::feols(..., cluster = ~dept_code + id_election)`.

3. **Conley spatial HAC** SEs via `fixest` `conley()` with 300km bandwidth and dept centroids.

**Outcome:** Expanded inference comparison table with 7+ methods. WCB reported transparently but no longer the pivotal test — AKM is the primary inference for shift-share designs.

**Dept-level as primary:** Redesignate N=960 dept×election specification as the paper's primary analysis, with commune-level (N=361K) as ancillary.

**Files:** `00_packages.R` (add ShiftShareSE), `04_robustness.R` (new inference section), `06_tables.R`, `paper.tex` (rewrite Section 5.3 on inference; move dept table up)

### WS2: SCI Vintage Validation via Migration Proxy (HIGH-VALUE, P1)

**Problem:** SCI is 2024 vintage (post-treatment). All 3 referees flagged this. Current response is verbal arguments only.

**Fix:** Construct a pre-treatment network proxy from INSEE 2013 inter-département residential migration flows. Show:
- High pairwise correlation (Spearman) between SCI weights and migration-based weights
- Re-estimation with migration-based network exposure yields qualitatively similar results
- Scatter plot of SCI vs migration weights

**Data source:** INSEE "Migrations résidentielles 2013" (commune-of-residence × commune-of-prior-residence). Pre-dates GJ by 5 years.

**Files:** `01_fetch_data.R` (new data fetch), `02_clean_data.R` (build 96×96 migration matrix), `04_robustness.R` (re-estimate with migration weights), `05_figures.R` (scatter), `paper.tex` (new Appendix subsection + strengthened main-text discussion)

### WS3: Time-Varying Controls Battery (HIGH-VALUE, P1)

**Problem:** Only income×Post currently controlled. GPT-5.2 demanded unemployment, education, immigration, sector composition all interacted with Post. Also demanded dept-specific linear trends.

**Fix:** Fetch from INSEE and add progressively:
- Unemployment rate × Post (from INSEE BDM/chomage localisé)
- Education share (% bac+) × Post (from recensement)
- Immigration share × Post (from recensement)
- Industry share × Post (from recensement)
- Département-specific linear trends (`dept_code[year_num]` in fixest)
- Kitchen-sink specification (all + trends)

Show network coefficient stability across specifications.

**Files:** `01_fetch_data.R` (new INSEE downloads), `02_clean_data.R` (merge controls), `04_robustness.R` (new specs), `06_tables.R` (sensitivity table), `paper.tex` (new robustness table + text)

### WS4: Distance-Bin Decomposition (HIGH-VALUE, P2)

**Problem:** Single 200km cutoff is too crude. GPT-5.2 demanded bins.

**Fix:** Estimate network effects using SCI ties within 5 distance bins: 0–50km, 50–100km, 100–200km, 200–400km, 400+km. Show where the identifying signal originates.

**Files:** `04_robustness.R` (new loop over distance bins), `05_figures.R` (bar chart), `paper.tex` (replace single-cutoff discussion)

### WS5: Formal Estimand Under Interference + Placebo Timing (HIGH-VALUE, P2)

**Problem:** (a) SUTVA violated by construction; no formal estimand. (b) No placebo timing tests.

**Fix:**
- New subsection 3.5 formalizing the exposure mapping: define exposure sufficiency assumption, state what β₂ identifies (average marginal effect of network exposure, not ATE), list required assumptions
- Placebo timing tests: assign fake treatment dates (2007, 2009) and show no break in network coefficients
- Separate event studies by election type (presidential-only, European-only)

**Files:** `04_robustness.R` (placebo timing + election-type event studies), `paper.tex` (new subsection + expanded robustness)

### WS6: Structural Reframing (EDITORIAL, P3)

**Problem:** Counterfactuals overclaimed. SAR/SEM equivalence means structural results are descriptive, not causal.

**Fix:**
- Rename section to "Spatial Dependence Analysis"
- Present reduced-form (1.19 pp) as lower bound, SAR counterfactual (~11 pp) as upper bound
- Downgrade counterfactual claims to "illustrative" / "under SAR parameterization"
- Remove "22x multiplier" from abstract; replace with reduced-form finding

**Files:** `paper.tex` only

---

## What Doesn't Change

- Core identification strategy (shift-share with SCI × fuel vulnerability)
- Primary data sources (SCI, election Parquet, commuting CO₂)
- 10-election panel (2002–2024)
- SAR/SEM/SDM model comparison (already in v2)
- Placebo party outcomes (Green, center-right)
- Leave-one-out exercise
- Block RI implementation
- Shleifer-style prose (already rewritten in v2)

---

## Execution Order

1. **Setup:** Create `output/apep_0464/v3/`, copy parent code, write initialization.md
2. **Data fetches (WS2 + WS3):** Fetch INSEE migration flows, unemployment, education, immigration data
3. **Build controls panel (WS3):** Merge time-varying covariates into panel
4. **Build migration proxy (WS2):** Construct 96×96 migration weight matrix, compute migration-based network exposure
5. **Inference resolution (WS1):** Install ShiftShareSE, implement AKM/two-way/Conley at dept level
6. **Distance bins (WS4):** Implement 5-bin decomposition
7. **Placebo timing + election-type tests (WS5):** Fake treatment dates, separate event studies
8. **Re-run all scripts:** 00→07, regenerate figures and tables
9. **Paper revision:** Rewrite inference section, add estimand subsection, add new tables/figures, reframe structural, update abstract
10. **Compile + Visual QA**
11. **Review workflow:** Advisor → Exhibit → Prose → External → Stage C
12. **Publish:** `revise_and_publish.py --parent apep_0464 --push`

---

## Key Files to Modify

| File | Changes |
|------|---------|
| `code/00_packages.R` | Add `ShiftShareSE`, `insee` |
| `code/01_fetch_data.R` | Add INSEE migration, unemployment, education, immigration downloads |
| `code/02_clean_data.R` | Build migration matrix, merge time-varying controls, construct distance bins |
| `code/03_main_analysis.R` | Minor: add dept-level as primary spec designation |
| `code/04_robustness.R` | Major: AKM inference, two-way clustering, Conley, migration-proxy re-estimation, controls battery, distance bins, placebo timing, election-type event studies |
| `code/05_figures.R` | New: distance-bin bar chart, SCI-migration scatter |
| `code/06_tables.R` | New: expanded inference table, controls sensitivity table, distance-bin table |
| `paper.tex` | Major: rewrite inference section, add estimand subsection, reframe structural, update abstract, add new tables/figures, new appendix material |
| `references.bib` | Add Adão et al. 2019, Aronow & Samii 2017, Conley 1999 |

---

## Verification

1. All R scripts run without error (00_packages.R through 07_structural.R)
2. **AKM p-value for network coefficient** — if < 0.05, the inference crisis is resolved
3. Migration-SCI correlation > 0.5 (validates pre-treatment proxy)
4. Network coefficient survives full controls battery + dept-specific trends
5. Distance-bin decomposition shows signal in 200+ km bins (supports social > geographic)
6. Placebo timing tests (2007, 2009 fake treatment) show null effects
7. Paper compiles cleanly, page 1 = front matter only, 25+ pages
8. Abstract ≤ 150 words
9. Advisor review: 3/4 PASS
10. No unresolved `??` references

## Risk

If AKM also yields insignificant p-value for network coefficient, the paper's central claim is genuinely fragile. Fallback: reframe around own-exposure channel (which passes all inference methods) and present network effects as suggestive. The AKM approach is specifically designed for this shift-share structure, so there is reason for cautious optimism.
