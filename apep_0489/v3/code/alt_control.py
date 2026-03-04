#!/usr/bin/env python3
"""
alt_control.py — Alternative control group robustness check.

Excludes TVA-region states entirely, using only the 9 non-TVA states as controls.
This addresses the concern that non-TVA counties within TVA states may experience
indirect TVA effects through electricity access, spillovers, or fiscal complementarities.

Also tests LoRA rank sensitivity (r={4, 8, 16}).

Usage:
    python -m projects.did_transformer.analysis.alt_control
    python -m projects.did_transformer.analysis.alt_control --lora-r 4
"""

import argparse
import json
import sys
import time
from pathlib import Path

import numpy as np
import torch

project_root = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(project_root))

from projects.did_transformer.data.dataset_v2 import LifeStateDataset, load_vocab_v2
from projects.did_transformer.data.tva_counties import (
    get_tva_state_fips, get_control_state_fips,
)
from projects.did_transformer.train.finetune_four_adapter import (
    finetune_adapter, extract_transitions,
)
from projects.did_transformer.analysis.generate_figures import (
    OCC_ORDER, OCC_DISPLAY, build_occ_aggregation, aggregate_to_occ,
)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=str,
                        default="projects/did_transformer/data/sequences_v3_tva.parquet")
    parser.add_argument("--vocab", type=str,
                        default="projects/did_transformer/data/vocab_v2.json")
    parser.add_argument("--checkpoint", type=str,
                        default="projects/did_transformer/outputs/clean_pretrain/pretrain_v2_best.pt")
    parser.add_argument("--output-dir", type=str,
                        default="projects/did_transformer/outputs/alt_control")
    parser.add_argument("--steps", type=int, default=1500)
    parser.add_argument("--batch-size", type=int, default=256)
    parser.add_argument("--lr", type=float, default=1e-4)
    parser.add_argument("--lora-r", type=int, default=8)
    parser.add_argument("--lora-alpha", type=float, default=16.0)
    parser.add_argument("--device", type=str, default=None)
    args = parser.parse_args()

    if args.device is None:
        if torch.backends.mps.is_available():
            device = "mps"
        elif torch.cuda.is_available():
            device = "cuda"
        else:
            device = "cpu"
    else:
        device = args.device

    print(f"Device: {device}")
    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Load vocab and data
    vocab = load_vocab_v2(args.vocab)
    idx_to_occ = build_occ_aggregation(vocab)
    present_occs = [o for o in OCC_ORDER if o in set(idx_to_occ.values())]
    n_occ = len(vocab["tokens"]) + len(vocab["special_tokens"])

    print(f"Loading data from {args.data}...")
    dataset = LifeStateDataset(args.data)
    print(f"  {len(dataset):,} sequences")

    # Identify TVA and non-TVA-region state individuals
    tva_state_fips = get_tva_state_fips()
    ctrl_state_fips = get_control_state_fips()

    tva_idx = []
    ctrl_nontva_states_idx = []  # Only individuals in 9 non-TVA states

    for i in range(len(dataset)):
        state_1920 = dataset.state_ids[i][0]
        if dataset.tva_treatment[i] == 1:
            tva_idx.append(i)
        elif state_1920 in ctrl_state_fips:
            # Only include if in a non-TVA-region state
            ctrl_nontva_states_idx.append(i)

    print(f"  TVA: {len(tva_idx):,}")
    print(f"  Control (9 non-TVA states only): {len(ctrl_nontva_states_idx):,}")

    # Load checkpoint
    print(f"Loading checkpoint from {args.checkpoint}...")
    ckpt = torch.load(args.checkpoint, map_location="cpu", weights_only=False)
    config = ckpt["config"]
    base_state = ckpt["model_state"]

    pre_positions = [0]
    post_positions = [1]

    # Run four-adapter pipeline with alternative control group
    print(f"\nFine-tuning 4 adapters (alt control, LoRA r={args.lora_r})...")
    models = {}

    for region_name, region_idx in [("TVA", tva_idx), ("Ctrl", ctrl_nontva_states_idx)]:
        for period_name, positions in [("pre", pre_positions), ("post", post_positions)]:
            label = f"{region_name}_{period_name}"
            print(f"\n{'='*60}")
            print(f"Adapter: {label} ({len(region_idx):,} individuals)")
            print(f"{'='*60}")

            lora_state, model = finetune_adapter(
                base_state, config, dataset, region_idx, positions,
                device, label, max_steps=args.steps,
                batch_size=args.batch_size, lr=args.lr,
                lora_r=args.lora_r, lora_alpha=args.lora_alpha,
            )
            models[label] = model

    # Extract transition matrices
    print(f"\nExtracting transitions...")
    T_tva_pre = extract_transitions(models["TVA_pre"], dataset, tva_idx, n_occ, device, pre_positions)
    T_tva_post = extract_transitions(models["TVA_post"], dataset, tva_idx, n_occ, device, post_positions)
    T_ctrl_pre = extract_transitions(models["Ctrl_pre"], dataset, ctrl_nontva_states_idx, n_occ, device, pre_positions)
    T_ctrl_post = extract_transitions(models["Ctrl_post"], dataset, ctrl_nontva_states_idx, n_occ, device, post_positions)

    model_did = (T_tva_post - T_tva_pre) - (T_ctrl_post - T_ctrl_pre)
    pre_diff = np.abs(T_tva_pre - T_ctrl_pre).mean()

    # Aggregate to occupation level
    occ_did = aggregate_to_occ(model_did, idx_to_occ, present_occs)

    # Compare with baseline results
    baseline_path = Path("projects/did_transformer/outputs/four_adapter/four_adapter_results.json")
    if baseline_path.exists():
        with open(baseline_path) as f:
            baseline = json.load(f)
        baseline_did = aggregate_to_occ(np.array(baseline["model_did"]), idx_to_occ, present_occs)
        correlation = float(np.corrcoef(occ_did.flatten(), baseline_did.flatten())[0, 1])
        mae = float(np.abs(occ_did - baseline_did).mean())
        print(f"\nComparison with baseline (all controls):")
        print(f"  Correlation: {correlation:.4f}")
        print(f"  MAE: {mae:.4f}")
    else:
        correlation = None
        mae = None

    display_labels = [OCC_DISPLAY.get(o, o) for o in present_occs]

    print(f"\nAlt control DiD matrix (pp):")
    print(f"{'':>12s}", end="")
    for label in display_labels:
        print(f"  {label[:6]:>6s}", end="")
    print()
    for i, src in enumerate(display_labels):
        print(f"{src:>12s}", end="")
        for j in range(len(display_labels)):
            val = occ_did[i, j] * 100
            print(f"  {val:6.1f}", end="")
        print()

    # Save results
    results = {
        "occ_did": occ_did.tolist(),
        "model_did_token": model_did.tolist(),
        "pre_trends_mae": float(pre_diff),
        "n_tva": len(tva_idx),
        "n_ctrl": len(ctrl_nontva_states_idx),
        "lora_r": args.lora_r,
        "control_type": "non_tva_states_only",
        "occ_labels": present_occs,
        "display_labels": display_labels,
    }
    if correlation is not None:
        results["baseline_correlation"] = correlation
        results["baseline_mae"] = mae

    with open(out_dir / f"alt_control_r{args.lora_r}.json", "w") as f:
        json.dump(results, f, indent=2)

    print(f"\nResults saved to {out_dir / f'alt_control_r{args.lora_r}.json'}")


if __name__ == "__main__":
    main()
