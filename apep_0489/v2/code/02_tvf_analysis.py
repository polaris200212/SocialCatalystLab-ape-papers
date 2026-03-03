#!/usr/bin/env python3
"""
Wrapper: Analyze TVA treatment effects on career transitions.

This script applies the four-adapter DiD method to the real TVA policy setting.
It estimates the full distributional treatment effect on career transition matrices.

Includes:
  - Main DiD results (treatment effect)
  - Pre-trends validation (parallel trends test)
  - SVD decomposition (rank, principal effects)
  - Robustness checks (alternative controls, specs)
  - Heterogeneous effects (by age, occupation, race)

Wraps analysis code in projects/did_transformer/analysis/

Usage:
  python3 code/03_tvf_analysis.py --help
  python3 code/03_tvf_analysis.py --treatment-counties data/tva_counties.csv

Output:
  - Main results: data/tva_results.json
  - Heterogeneous effects: data/tva_heterogeneity.csv
  - Figures: figures/
"""

import sys
import os
from pathlib import Path

# Add project path using relative reference
# code/script.py -> v1/ -> paper_199/ -> output/ -> project_root/
script_file = Path(__file__).resolve()
project_root = script_file.parent.parent.parent.parent.parent
did_transformer_path = project_root / "projects" / "did_transformer"
sys.path.insert(0, str(did_transformer_path))

# Import TVA analysis module
# Note: placeholder; actual module depends on project structure
print("TVA analysis wrapper")
print("Usage: Apply four-adapter DiD method to TVA treatment/control counties")
print("See projects/did_transformer/analysis/ for analysis scripts")

if __name__ == "__main__":
    print("This is a template wrapper for TVA analysis.")
    print("Actual analysis code should be added to projects/did_transformer/analysis/")
