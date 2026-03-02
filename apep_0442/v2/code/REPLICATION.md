# Replication Instructions

## The First Retirement Age v2: Civil War Pensions and Elderly Labor Supply

### Requirements

**R packages:**
- data.table, rdrobust, rddensity, fixest, ggplot2, modelsummary
- ipumsr, kableExtra, patchwork, scales

**Python packages:**
- ipumspy (for IPUMS API data fetch)

**API keys:**
- IPUMS_API_KEY (for data download)

### Data

Data is downloaded from IPUMS USA via API:
1. 1910 census 1.4% oversampled (us1910l) — ~1.3M records

**Important:** The full-count 1910 census (us1910m) does NOT include the VETCIVWR
variable needed to identify Civil War veterans. The 1.4% oversampled sample (us1910l)
is the largest available IPUMS sample with veteran identification.

### Script Execution Order

```bash
# 1. Download data (requires IPUMS API key; takes 5-30 minutes)
python3 code/01_fetch_data.py

# 2. Clean 1910 data and construct variables
Rscript code/02_clean_data.R

# 3. Main RDD analysis (can run in parallel: 03, 03b, 04, 04b-04e)
Rscript code/03_main_analysis.R
Rscript code/03b_diff_in_disc.R
Rscript code/04_robustness.R
Rscript code/04b_rand_inference.R
Rscript code/04c_subgroups.R
Rscript code/04d_border_states.R
Rscript code/04e_spillovers.R

# 4. Generate figures and tables (requires all analysis output)
Rscript code/05_figures.R
Rscript code/06_tables.R
```

### Output

- `figures/` — PDF/PNG figure files
- `tables/` — LaTeX table files
- `data/` — RDS intermediate data files
- `paper.tex` + `references.bib` → compile with pdflatex + bibtex
