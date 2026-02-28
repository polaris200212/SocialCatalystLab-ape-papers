#!/bin/bash
## ============================================================================
## run_all.sh — Full pipeline for apep_0469 v3
## Missing Men, Rising Women (MLP Three-Wave Panel)
## ============================================================================
## Prerequisite: Azure panel build must be complete
##   Rscript scripts/build_mlp_panel/04_build_1930_1940_1950.R
## ============================================================================

set -e
cd "$(dirname "$0")/.."

echo "=== apep_0469 v3 Pipeline ==="
echo "Working directory: $(pwd)"
echo "Start time: $(date)"
echo ""

# Step 0: Packages
echo ">>> Step 0: Loading packages..."
Rscript code/00_packages.R

# Step 1: Fetch data from Azure + CenSoc
echo ""
echo ">>> Step 1: Fetching data..."
Rscript code/01_fetch_data.R

# Step 2: Clean and construct variables
echo ""
echo ">>> Step 2: Cleaning data..."
Rscript code/02_clean_data.R

# Step 3: Main analysis
echo ""
echo ">>> Step 3: Main analysis..."
Rscript code/03_main_analysis.R

# Step 4: Robustness checks
echo ""
echo ">>> Step 4: Robustness checks..."
Rscript code/04_robustness.R

# Step 5: Generate figures
echo ""
echo ">>> Step 5: Generating figures..."
Rscript code/05_figures.R

# Step 6: Generate tables
echo ""
echo ">>> Step 6: Generating tables..."
Rscript code/06_tables.R

# Step 7: Compile paper
echo ""
echo ">>> Step 7: Compiling paper..."
pdflatex -interaction=nonstopmode paper.tex
bibtex paper
pdflatex -interaction=nonstopmode paper.tex
pdflatex -interaction=nonstopmode paper.tex

echo ""
echo "=== Pipeline Complete ==="
echo "End time: $(date)"
echo "Paper: $(pwd)/paper.pdf"
