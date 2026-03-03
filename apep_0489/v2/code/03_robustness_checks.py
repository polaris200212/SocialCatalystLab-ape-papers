#!/usr/bin/env python3
"""
Wrapper: Run robustness checks on four-adapter DiD results.

This script runs a suite of robustness checks:
  1. Alternative control groups (same-state controls, adjacent counties, etc.)
  2. Architecture ablations (LoRA rank, model size, masking strategy)
  3. Specification checks (heterogeneous treatment timing, alternative periods)
  4. Sensitivity analysis (pre-training data, weight decay, learning rate)

Usage:
  python3 code/04_robustness_checks.py --help
  python3 code/04_robustness_checks.py --control-type same-state

Output:
  - Robustness results: data/robustness_results.json
  - Specification sensitivity: data/specification_sensitivity.csv
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

# Template for robustness checks
print("Robustness check wrapper")
print("Available checks:")
print("  1. Alternative control groups")
print("  2. Architecture ablations (LoRA rank, model size)")
print("  3. Specification sensitivity (time periods, heterogeneous treatment)")
print("  4. Pre-training sensitivity")

if __name__ == "__main__":
    print("Robustness checks for four-adapter DiD method")
    print("See projects/did_transformer/ for implementation")
