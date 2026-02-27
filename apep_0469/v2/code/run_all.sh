#!/bin/bash
## ============================================================================
## run_all.sh — Master Pipeline Runner for apep_0469 v2
## Runs all R scripts in sequence after data is available
## ============================================================================

set -e  # Exit on any error
cd "$(dirname "$0")/.."  # Go to v2 root

echo "=== APEP 0469 v2: Full Pipeline ==="
echo "Working directory: $(pwd)"
echo "Start time: $(date)"
echo ""

# Check if data is available
if [ ! -f "data/ipums_fullcount.rds" ] && [ ! -f "data/extract_ready.flag" ]; then
  echo "ERROR: No IPUMS full-count data found."
  echo "Run 01_fetch_data.R first, or wait for extract to complete."
  exit 1
fi

# Run each script in order
for script in 00_packages 01_fetch_data 02_clean_data 03_main_analysis 04_robustness 05_figures 06_tables; do
  echo ""
  echo "================================================================"
  echo "Running ${script}.R at $(date '+%H:%M:%S')"
  echo "================================================================"
  Rscript "code/${script}.R" 2>&1
  echo "${script}.R completed at $(date '+%H:%M:%S')"
done

echo ""
echo "=== All scripts complete ==="
echo "End time: $(date)"
echo ""

# Verify outputs
echo "=== Output verification ==="
echo "Figures:"
ls -la figures/*.pdf 2>/dev/null | wc -l | xargs -I{} echo "  {} PDF figures generated"
echo "Tables:"
ls -la tables/*.tex 2>/dev/null | wc -l | xargs -I{} echo "  {} LaTeX tables generated"
echo "Data files:"
ls -la data/*.rds 2>/dev/null | wc -l | xargs -I{} echo "  {} RDS data files"
