#!/usr/bin/env python3
"""
Wrapper: Run four-adapter DiD fine-tuning.

This script fine-tunes the pre-trained transformer with 4 LoRA adapters on the 2×2 DiD design:
  - Treatment × Pre-period
  - Treatment × Post-period
  - Control × Pre-period
  - Control × Post-period

It wraps the production code in projects/did_transformer/train/finetune_four_adapter.py.

Usage:
  python3 code/01_run_four_adapter_did.py --help
  python3 code/01_run_four_adapter_did.py --model-path data/pretrained_model.pt --mask-post

Output:
  - DiD weights: data/did_weights.pt
  - DiD analysis: data/did_results.json (SVD, rank, effects)
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

# Import the production fine-tuning script
from train.finetune_four_adapter import main

if __name__ == "__main__":
    # Parse args and run
    sys.argv[0] = "finetune_four_adapter.py"
    main()
