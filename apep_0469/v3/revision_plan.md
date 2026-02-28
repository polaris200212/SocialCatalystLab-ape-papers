# Revision Plan: apep_0469 v3 — MLP 3-Wave Panel via Azure

## Context

Paper apep_0469 v2 ("Missing Men, Rising Women") uses CLP crosswalks for a 2-period panel (1940→1950, 14M linked men, 5.6M couples). Three reviewers (GPT: MAJOR, Grok: MAJOR, Gemini: MINOR) converge on five top demands:

1. **Pre-trend test** — no 1930-1940 placebo
2. **Comparable decomposition** — must use married women aggregate, not all women
3. **Mobilization validation** — correlate CenSoc measure with alternative proxies
4. **Selection quantification** — linkage rate vs mobilization, IPW
5. **State-level controls** — region FE too coarse; state FE infeasible since treatment IS state-level

The user built Azure blob storage infrastructure with a complete MLP panel construction pipeline (`scripts/build_mlp_panel/`, 8 scripts, 1,218 lines). Pre-built derived datasets are ready in Azure.

## What Already Exists in Azure

**Pre-built decade pairs (ready to read):**
- `derived/mlp_panel/linked_1930_1940.parquet` — **68.1M rows** (all variables harmonized)
- `derived/mlp_panel/linked_1940_1950_part*.parquet` — **71.8M rows** (split due to Azure block limits)

**Pre-built 3-census panel:**
- `derived/mlp_panel/linked_1920_1930_1940.parquet` — 34.7M rows (not what we need, but same pattern)
- `derived/mlp_panel/linked_1930_1940_1950.parquet` — **DOES NOT EXIST YET** → must build

**Supporting files:**
- `derived/mlp_panel/link_diagnostics.parquet` — 15,686 rows of link rates by cell
- `selection_weights.parquet` — NOT YET BUILT

**Key column schemas:**
- `linked_1930_1940`: histid_1930, histid_1940, statefip/age/sex/race/marst/occ1950/classwkr/sei/occscore + age_diff, mover — **NO EMPSTAT/LABFORCE/EDUC for 1930**
- `linked_1940_1950`: histid_1940, histid_1950, statefip/age/sex/race/marst/occ1950/empstat/classwkr/occscore/educ/incwage + age_diff, mover — **Has EMPSTAT for both years**

**R library:** `scripts/lib/azure_data.R` — `apep_azure_connect()`, `apep_azure_read()`, `apep_azure_query()`, `apep_azure_write()`
**Working example:** `papers/apep_0476/v1/code/01_fetch_data.R` — pattern to follow for Azure reads
**Build template:** `scripts/build_mlp_panel/03_build_multi.R` — pattern to adapt for building 1930-1940-1950

## LFP Construction

| Year | Variable | Method |
|------|----------|--------|
| 1930 | `CLASSWKR` | `in_lf = (CLASSWKR > 0)` — "gainful employment" (standard in econ history) |
| 1940 | `EMPSTAT` | `in_lf = (EMPSTAT %in% {1,2})` — employed or unemployed |
| 1950 | `EMPSTAT` | `in_lf = (EMPSTAT %in% {1,2})` |

---

## Workstreams

### WS1: Workspace + Build 3-Census Panel

**Step 1:** Create `output/apep_0469/v3/`, copy parent artifacts from `papers/apep_0469/v2/`

**Step 2:** Build `linked_1930_1940_1950.parquet` — adapt `scripts/build_mlp_panel/03_build_multi.R` for years 1930/1940/1950. One-time Azure write, reusable by future papers. Key: use `get_common_vars(1930, 1940)` intersected with `get_common_vars(1940, 1950)` for variable list. Expected: ~40M+ rows (the 43.5M MLP links minus age-filter dropouts and many-to-many removals).

### WS2: Data Pipeline (01_fetch_data.R + 02_clean_data.R)

**01_fetch_data.R — Rewrite** (follow apep_0476 pattern)
- Source `scripts/lib/azure_data.R`
- Read pre-built `linked_1940_1950_part*.parquet` (71.8M → filter to working-age men/women)
- Read pre-built `linked_1930_1940_1950.parquet` (the 3-wave panel built in WS1)
- Query full-count aggregates for married-women decomposition (SQL on raw census files, no linkage)
- Read `link_diagnostics.parquet` for selection analysis
- Keep CenSoc enlistment download from Harvard Dataverse (unchanged)
- Save local RDS files for downstream scripts

**02_clean_data.R — Major rewrite**
- `construct_vars_1930()`: LFP from CLASSWKR > 0, OCCSCORE, SEI (no EDUC/EMPSTAT)
- `construct_vars_1940()`: LFP from EMPSTAT ∈ {1,2}, EDUC, OCCSCORE, SEI, INCWAGE
- `construct_vars_1950()`: LFP from EMPSTAT ∈ {1,2}, EDUC, OCCSCORE, INCWAGE (no SEI)
- Build couples panels: track wife via husband SERIAL+RELATE across all 3 censuses with age verification
- Compute married-women aggregate: full-count SQL (MARST ∈ {1,2}, SEX=2, age 18-55) by state×year
- Build IPW weights: cell-based (state × race × sex × age_group), matching linked to full-count
- Output: `linked_panel_40_50.rds`, `couples_panel_40_50.rds`, `linked_panel_30_40_50.rds`, `couples_panel_30_40_50.rds`, `married_women_aggregate.rds`, `selection_diagnostics.rds`

### WS3: Analysis (03_main_analysis.R + 04_robustness.R)

**03_main_analysis.R — Expand with:**
1. **Pre-trend test**: ΔLF(1930→1940) ~ Mob_s + X_1930 + region_FE → should be ≈0 (men and wives)
2. **State-level baseline controls**: Add 1940 state covariates (female LFP, urbanization, industry, education, race) — explain why state FE absorb the state-level treatment
3. **Married-women decomposition**: Aggregate_married vs within-couple (replace all-women comparison)
4. **State-level regression**: HC2/HC3 with population weights (promoted from robustness)
5. **95% CIs** for all headline estimates

**04_robustness.R — Add new checks:**
- R15: Mobilization validation (CenSoc vs 1950 veteran share / defense industry proxy)
- R16: Linkage rate vs mobilization (state-level → should be null)
- R17: IPW-weighted main specifications
- R18: Finer age-bin placebo (46-50, 51-55, 56-60, 60+)
- R19: War mortality proxy (husband "disappearance rate" by state)
- R20: Pre-trend event study (stacked periods, Mob_s × Period interaction)
- Remove R11 (ABE-EI — no longer relevant with MLP)
- Keep all other R1-R14

### WS4: Figures + Tables (05_figures.R + 06_tables.R)

**New figures:** Pre-trend event study (most important), mobilization validation scatter, linkage rate scatter, finer age-bin placebo, IPW sensitivity forest
**New tables:** Pre-trend results, mobilization validation, selection diagnostics, married-women decomposition, state-level controls sensitivity
**Modified:** All existing figures/tables regenerated with MLP data, 95% CIs added

### WS5: Paper (paper.tex)

**Abstract + Introduction — Rewrite from scratch** (no v1/v2 mentions per MEMORY.md)
- 3-wave panel as natural innovation; pre-trend test as identification evidence
- Married-women decomposition as primary result
- Mobilization gradient secondary, with 95% CIs and honest hedging

**Data section:** MLP replaces CLP, CLASSWKR proxy documented, married-women aggregate described
**Framework:** Pre-trend equation, state-level controls specification, explain state FE infeasibility
**Results:** Lead with pre-trends, married-women decomposition, 95% CIs throughout
**Mechanisms:** Reframe husband-wife test as descriptive
**Conclusion:** Present best analysis as natural choice

### WS6: Review + Publish

1. Compile PDF → Advisor review (3/4 PASS) → Exhibit + prose review (parallel) → External referee review (tri-model) → Stage C revision → Publish with `--parent apep_0469`

---

## Key Files

| File | Action | Reference Pattern |
|------|--------|-------------------|
| `scripts/build_mlp_panel/03_build_multi.R` | Adapt for 1930-1940-1950 | Template for WS1 |
| `papers/apep_0476/v1/code/01_fetch_data.R` | Follow Azure access pattern | Template for WS2 |
| `scripts/lib/azure_data.R` | Source (no change) | |
| `scripts/build_mlp_panel/00_config.R` | Reference for variable lists | |
| `output/apep_0469/v3/code/01_fetch_data.R` | Rewrite | |
| `output/apep_0469/v3/code/02_clean_data.R` | Major rewrite | |
| `output/apep_0469/v3/code/03_main_analysis.R` | Substantial expansion | |
| `output/apep_0469/v3/code/04_robustness.R` | Substantial expansion | |
| `output/apep_0469/v3/code/05_figures.R` | Expand | |
| `output/apep_0469/v3/code/06_tables.R` | Expand | |
| `output/apep_0469/v3/paper.tex` | Full rewrite of key sections | |

## Verification

1. `linked_1930_1940_1950.parquet` builds successfully in Azure with ~40M+ rows
2. All R scripts run end-to-end (00 through 06)
3. Pre-trend coefficients near zero with proper CIs
4. Married-women decomposition computable and interpretable
5. Paper compiles to 40+ pages with no `??` references
6. Advisor review: 3/4 PASS
7. Publication successful via `publish_paper.py --parent apep_0469 --push`
