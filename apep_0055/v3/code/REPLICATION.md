# Replication Instructions

## Requirements
- R >= 4.2
- R packages: tidyverse, data.table, haven, rdrobust, rddensity, rdlocrand, sandwich, lmtest, fixest, ggplot2, latex2exp, scales, jsonlite

## Data
- CDC Natality Public Use Files 2016-2023 (downloaded from NBER)
- ACS 1-Year PUMS (fetched via Census Microdata API)

## Execution Order
Run all scripts from the `code/` directory:

```bash
cd code/
Rscript 00_packages.R
Rscript 01_fetch_data.R      # Downloads ~6 GB of natality data from NBER
Rscript 02_clean_data.R      # Creates analysis sample (~12M births)
Rscript 03_main_analysis.R   # Main RDD + permutation inference
Rscript 03b_first_stage.R    # ACS PUMS first-stage evidence
Rscript 04_validity_tests.R  # McCrary, balance, placebo, bandwidth
Rscript 05_figures.R         # All figures including first-stage
Rscript 06_robustness.R      # Robustness + MDE + heterogeneity
Rscript 06b_expansion_heterogeneity.R  # Subgroup heterogeneity
Rscript 07_tables.R          # All LaTeX tables
Rscript 08_placebo_figure.R  # Placebo cutoff figure
Rscript 09_bandwidth_figure.R # Bandwidth sensitivity figure
```

## Notes
- Script 01 downloads ~800 MB per year (8 years = ~6 GB total)
- Script 02 takes ~10-15 minutes to process all years
- Scripts must be run in order (later scripts depend on earlier outputs)
- Census API key (CENSUS_API_KEY env var) recommended for 03b
