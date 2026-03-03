#!/usr/bin/env python3
"""
Wrapper: Pre-train the national career transformer.

This script pre-trains a transformer on all linked census sequences (national, region-blind).
It wraps the production code in projects/did_transformer/train/pretrain_v2.py.

Usage:
  python3 code/00_pretrain_model.py --help
  python3 code/00_pretrain_model.py --num-epochs 20 --batch-size 256

Output:
  - Model checkpoint: data/pretrained_model.pt
  - Validation loss: data/pretrain_metrics.json
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

# Import the production pre-training script
from train.pretrain_v2 import main

if __name__ == "__main__":
    # Parse args and run
    sys.argv[0] = "pretrain_v2.py"  # For help message
    main()
