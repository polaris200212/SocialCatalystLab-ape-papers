# Research Plan: "The First Retirement Age" v2

## Parent: apep_0442_v1

## Summary of Changes

### Data Upgrades
1. **Full-count 1910 census** (`us1910m`): ~92M records → ~150K Union veterans, ~50K Confederate
2. **Full-count 1900 census** (`us1900m`): Pre-treatment era (before 1907 Act)
3. **Full-count 1920 census** (`us1920m`): Persistence / long-run effects
4. **Cross-census linkage** via HISTID (IPUMS MLP): Panel of linked individuals

### New Analyses
- B1: Primary RDD with full power (MDE ~1-2pp vs ~5-7pp)
- B2: Difference-in-discontinuities (Union − Confederate)
- B3: 1900 pre-treatment falsification (MLP linkage)
- B4: 1920 persistence (MLP linkage)
- B5: Randomization inference (Cattaneo et al. 2015)
- B6: Subgroup analysis (race, urban/rural, literacy, region, occupation, nativity)
- B7: Geographic RDD (Border States: KY, MO, MD, WV, DE)
- B8: Household spillovers (wives, children, co-residents)
- B9: Multi-cutoff dose-response (ages 70, 75) with real power
- B10: Lee bounds for literacy imbalance

### Paper Rewrite
- Remove "proof of concept" language → definitive study
- New §7: Cross-Census Evidence (MLP linkage results)
- New subsection: Difference-in-Discontinuities
- Expanded subgroup heterogeneity
- Household spillovers analysis
- AER-style table formatting throughout

## Script Pipeline

```
00_packages.R          → Load libraries, set paths
01_fetch_data.py       → Submit/download 3 IPUMS extracts (1910, 1900, 1920)
02_clean_data.R        → Process full-count 1910, construct variables
02b_link_veterans.R    → MLP linkage across censuses via HISTID
03_main_analysis.R     → Main RDD at age 62 (full-count)
03b_diff_in_disc.R     → Difference-in-discontinuities (Union − Confederate)
04_robustness.R        → Bandwidth, polynomial, kernel, donut, placebo, multi-cutoff
04b_rand_inference.R   → Randomization inference (Cattaneo et al. 2015)
04c_subgroups.R        → Subgroup RDD analysis
04d_border_states.R    → Geographic RDD (border states)
04e_spillovers.R       → Household spillover effects
05_figures.R           → All figures
06_tables.R            → All tables (AER style)
07_mlp_falsification.R → 1900 pre-treatment falsification
08_mlp_persistence.R   → 1920 long-run persistence
```
