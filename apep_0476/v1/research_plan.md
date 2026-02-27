# Initial Research Plan: apep_0476

## Title (Working)

Linking Americans Across the Half-Century: A Descriptive Atlas of the MLP Census Panel, 1900-1950

## Research Question

What do individual-level linked census records reveal about American demographic, occupational, and geographic mobility from 1900 to 1950 — and how does record linkage selectivity shape what we can learn?

## Approach

This is a **descriptive data paper** — no causal identification. The contribution is threefold:

1. **Infrastructure documentation:** Systematic description of the MLP-linked panel construction, covering five consecutive decade pairs (1900→1910 through 1940→1950) and a three-census balanced panel (1920→1930→1940). Full variable harmonization tables, link rate diagnostics, and IPW weight construction.

2. **Descriptive atlas:** Individual-level patterns of change across census decades:
   - Occupational mobility (SEI/OCCSCORE transitions, occupation switching rates)
   - Interstate migration (mover rates by decade, origin-destination patterns)
   - Urbanization (farm-to-nonfarm transitions, urban migration)
   - Demographic transitions (marriage, household formation, fertility via NCHILD)
   - Literacy and education trends (LIT transitions in 1900-1930, EDUC in 1940-1950)
   - Race- and nativity-specific patterns throughout

3. **Selection analysis:** Who gets linked? Systematic comparison of linked vs unlinked populations, IPW correction effectiveness, and implications for research using linked historical data. Comparison with ABE crosswalk link rates for the three overlapping pairs.

## Data Sources

All data hosted on Azure Blob Storage, queried via DuckDB:

| Dataset | Path | Rows |
|---------|------|------|
| MLP crosswalk v2.0 | `raw/ipums_mlp/v2/mlp_crosswalk_v2.parquet` | 175.6M |
| 1900 full-count | `raw/ipums_fullcount/us1900m.parquet` | ~76M |
| 1910 full-count | `raw/ipums_fullcount/us1910m.parquet` | ~92M |
| 1920 full-count | `raw/ipums_fullcount/us1920c.parquet` | ~106M |
| 1930 full-count | `raw/ipums_fullcount/us1930d.parquet` | ~123M |
| 1940 full-count | `raw/ipums_fullcount/us1940b.parquet` | ~132M |
| 1950 full-count | `raw/ipums_fullcount/us1950b.parquet` | ~151M |
| ABE crosswalks | `raw/census_linking_project/crosswalk_*.parquet` | 59.5M |
| Linked panels | `derived/mlp_panel/linked_*.parquet` | Built by pipeline |

## Paper Structure (Target: 30+ pages main text)

### Main Text

1. **Introduction** (3-4 pages) — Motivation: why individual-level linked historical data matters for understanding American economic development. Overview of contribution.

2. **Data and Panel Construction** (5-6 pages) — MLP crosswalk description, census extracts, linking methodology (deduplication, age consistency), variable harmonization across years. Table of variable availability by census year.

3. **Link Rate Analysis** (4-5 pages) — Link rates by decade pair, state, race, sex, age group. Geographic maps of link rates. Comparison with ABE crosswalk rates. Discussion of what drives variation in linkability.

4. **Selection into Linkage** (4-5 pages) — Balance tables comparing linked vs unlinked populations. IPW weight construction and effectiveness. Who is systematically missing from linked samples? Implications for research.

5. **Descriptive Patterns: Occupational Mobility** (4-5 pages) — Within-person SEI/OCCSCORE changes by decade. Occupation transition matrices. Race and nativity differentials. Regional variation.

6. **Descriptive Patterns: Geographic and Demographic Change** (4-5 pages) — Interstate migration rates by decade. Farm-to-nonfarm transitions. Marriage and household formation. Literacy gains.

7. **Guidelines for Researchers** (2-3 pages) — How to access and use the panel. Variable selection guidance. When to use IPW weights. Recommended practices for linked historical analysis.

8. **Conclusion** (1-2 pages)

### Appendix (15+ pages)

- A: Complete variable dictionary with availability matrix
- B: Detailed link rate tables (state × race × sex × age)
- C: Full balance tables for all five decade pairs
- D: IPW weight distributions and trimming diagnostics
- E: Additional occupation transition matrices
- F: State-level migration flow tables

## Analysis Scripts

```
code/
├── 00_packages.R         — Libraries and themes
├── 01_fetch_data.R       — Connect to Azure, query panels
├── 02_clean_data.R       — Construct derived variables
├── 03_main_analysis.R    — Link rates, balance tables, descriptive stats
├── 04_robustness.R       — ABE comparison, IPW validation
├── 05_figures.R          — All figures
└── 06_tables.R           — All tables
```

## Key Figures Planned

1. Link rates by decade pair (bar chart)
2. Link rates by state (choropleth maps, one per decade pair)
3. Link rates by race, sex, age (faceted panel)
4. Balance: linked vs unlinked populations (coefficient plot)
5. IPW correction effectiveness (before/after comparison)
6. SEI distribution changes within individuals (density plots by decade)
7. Occupation transition heatmaps (major occupation groups)
8. Interstate migration rates over time (line chart)
9. Farm-to-nonfarm transition rates by race (grouped bar chart)
10. Three-census panel: 20-year occupational trajectories

## Key Tables Planned

1. Panel summary: rows, columns, link rates per decade pair
2. Variable availability matrix (year × variable)
3. Balance table: linked vs unlinked (all 5 pairs)
4. Link rate comparison: MLP vs ABE (3 overlapping pairs)
5. Occupational mobility: SEI transition quantiles by decade
6. Interstate migration: top origin-destination state pairs
7. Demographic transitions: marriage, household headship, farm status

## Timeline

This paper documents infrastructure already built. The pipeline (`scripts/build_mlp_panel/`) constructs all panels. The paper queries the derived data on Azure and presents descriptive results.
