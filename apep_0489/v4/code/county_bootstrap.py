#!/usr/bin/env python3
"""
county_bootstrap.py — County-cluster bootstrap for transformer DiD inference.

For each bootstrap iteration:
  1. Sample counties with replacement, stratified by TVA/control
  2. Filter dataset to individuals in sampled counties
  3. Run full four-adapter pipeline (pretrain is shared; only adapters retrained)
  4. Extract 12×12 occupation-level DiD matrix
  5. Save iteration results

Total time estimate: 100 iterations × ~7 min = ~12 hours on MPS.

Usage:
    python -m projects.did_transformer.analysis.county_bootstrap
    python -m projects.did_transformer.analysis.county_bootstrap --iterations 100 --start 0
    python -m projects.did_transformer.analysis.county_bootstrap --iterations 50 --start 50  # resume
"""

import argparse
import json
import sys
import time
from collections import defaultdict
from copy import deepcopy
from pathlib import Path

import numpy as np
import torch
from torch.utils.data import DataLoader, Subset

project_root = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(project_root))

from projects.did_transformer.data.dataset_v2 import LifeStateDataset, load_vocab_v2
from projects.did_transformer.model.career_model import CensusCareerModel
from projects.did_transformer.model.lora import apply_lora, extract_lora_state
from projects.did_transformer.train.collator import CareerCollator
from projects.did_transformer.train.finetune_four_adapter import (
    finetune_adapter, extract_transitions, _move_batch, mask_labels_temporal,
)
from projects.did_transformer.analysis.generate_figures import (
    OCC_ORDER, OCC_DISPLAY, build_occ_aggregation, aggregate_to_occ,
)


def build_county_index(dataset):
    """Build county -> list of individual indices mapping.

    Returns separate mappings for TVA and control individuals.
    Uses 1920 county (position 0) as fixed assignment.
    """
    tva_county_to_idx = defaultdict(list)
    ctrl_county_to_idx = defaultdict(list)

    for i in range(len(dataset)):
        state = dataset.state_ids[i][0]  # 1920 state
        county = dataset.county_ids[i][0]  # 1920 county
        county_key = (state, county)

        if dataset.tva_treatment[i] == 1:
            tva_county_to_idx[county_key].append(i)
        else:
            ctrl_county_to_idx[county_key].append(i)

    return tva_county_to_idx, ctrl_county_to_idx


def resample_counties(county_to_idx, rng):
    """Resample counties with replacement, return pooled individual indices."""
    counties = list(county_to_idx.keys())
    sampled = rng.choice(len(counties), size=len(counties), replace=True)
    indices = []
    for ci in sampled:
        indices.extend(county_to_idx[counties[ci]])
    return indices


def run_bootstrap_iteration(
    base_state, config, dataset, tva_idx, ctrl_idx,
    n_occ, idx_to_occ, present_occs, device,
    adapter_steps=1000, batch_size=256, lr=1e-4,
    lora_r=8, lora_alpha=16.0,
):
    """Run one full four-adapter pipeline on resampled data.

    Returns occupation-level DiD matrix.
    """
    pre_positions = [0]
    post_positions = [1]

    adapters = {}
    models = {}

    for region_name, region_idx in [("TVA", tva_idx), ("Ctrl", ctrl_idx)]:
        for period_name, positions in [("pre", pre_positions), ("post", post_positions)]:
            label = f"{region_name}_{period_name}"
            lora_state, finetuned_model = finetune_adapter(
                base_state, config, dataset, region_idx, positions,
                device, label, max_steps=adapter_steps,
                batch_size=batch_size, lr=lr,
                lora_r=lora_r, lora_alpha=lora_alpha,
            )
            adapters[label] = lora_state
            models[label] = finetuned_model

    # Extract transition matrices
    T_tva_pre = extract_transitions(
        models["TVA_pre"], dataset, tva_idx, n_occ, device, pre_positions
    )
    T_tva_post = extract_transitions(
        models["TVA_post"], dataset, tva_idx, n_occ, device, post_positions
    )
    T_ctrl_pre = extract_transitions(
        models["Ctrl_pre"], dataset, ctrl_idx, n_occ, device, pre_positions
    )
    T_ctrl_post = extract_transitions(
        models["Ctrl_post"], dataset, ctrl_idx, n_occ, device, post_positions
    )

    # Token-level DiD
    model_did = (T_tva_post - T_tva_pre) - (T_ctrl_post - T_ctrl_pre)

    # Aggregate to occupation level
    occ_did = aggregate_to_occ(model_did, idx_to_occ, present_occs)

    # Clean up models to free memory
    for m in models.values():
        del m
    torch.mps.empty_cache() if device == "mps" else None

    return occ_did


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=str,
                        default="projects/did_transformer/data/sequences_v3_tva.parquet")
    parser.add_argument("--vocab", type=str,
                        default="projects/did_transformer/data/vocab_v2.json")
    parser.add_argument("--checkpoint", type=str,
                        default="projects/did_transformer/outputs/clean_pretrain/pretrain_v2_best.pt")
    parser.add_argument("--output-dir", type=str,
                        default="projects/did_transformer/outputs/bootstrap")
    parser.add_argument("--iterations", type=int, default=100)
    parser.add_argument("--start", type=int, default=0,
                        help="Starting iteration (for resuming)")
    parser.add_argument("--adapter-steps", type=int, default=1000,
                        help="Training steps per adapter (reduced from 1500 for speed)")
    parser.add_argument("--batch-size", type=int, default=256)
    parser.add_argument("--lr", type=float, default=1e-4)
    parser.add_argument("--lora-r", type=int, default=8)
    parser.add_argument("--lora-alpha", type=float, default=16.0)
    parser.add_argument("--device", type=str, default=None)
    parser.add_argument("--seed", type=int, default=42)
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

    # Load vocab and build mappings
    vocab = load_vocab_v2(args.vocab)
    idx_to_occ = build_occ_aggregation(vocab)
    present_occs = [o for o in OCC_ORDER if o in set(idx_to_occ.values())]
    n_occ_agg = len(present_occs)
    n_occ = len(vocab["tokens"]) + len(vocab["special_tokens"])

    print(f"Occupations ({n_occ_agg}): {present_occs}")

    # Load data
    print(f"Loading data from {args.data}...")
    dataset = LifeStateDataset(args.data)
    print(f"  {len(dataset):,} sequences")

    # Build county index
    print("Building county index...")
    tva_county_to_idx, ctrl_county_to_idx = build_county_index(dataset)
    n_tva_counties = len(tva_county_to_idx)
    n_ctrl_counties = len(ctrl_county_to_idx)
    n_tva = sum(len(v) for v in tva_county_to_idx.values())
    n_ctrl = sum(len(v) for v in ctrl_county_to_idx.values())
    print(f"  TVA: {n_tva:,} individuals in {n_tva_counties} counties")
    print(f"  Control: {n_ctrl:,} individuals in {n_ctrl_counties} counties")

    # Load checkpoint
    print(f"Loading checkpoint from {args.checkpoint}...")
    ckpt = torch.load(args.checkpoint, map_location="cpu", weights_only=False)
    config = ckpt["config"]
    base_state = ckpt["model_state"]

    # Run bootstrap
    rng = np.random.default_rng(args.seed)
    all_dids = []

    # Load any previously computed iterations
    for prev_i in range(args.start):
        prev_path = out_dir / f"iteration_{prev_i:03d}.json"
        if prev_path.exists():
            with open(prev_path) as f:
                prev = json.load(f)
            all_dids.append(np.array(prev["occ_did"]))

    total_start = time.time()

    for i in range(args.start, args.iterations):
        iter_start = time.time()
        print(f"\n{'='*60}")
        print(f"Bootstrap iteration {i+1}/{args.iterations}")
        print(f"{'='*60}")

        # Advance RNG to correct position for this iteration
        iter_rng = np.random.default_rng(args.seed + i)

        # Resample counties
        tva_idx = resample_counties(tva_county_to_idx, iter_rng)
        ctrl_idx = resample_counties(ctrl_county_to_idx, iter_rng)
        print(f"  Resampled: TVA {len(tva_idx):,}, Control {len(ctrl_idx):,}")

        # Run full pipeline
        occ_did = run_bootstrap_iteration(
            base_state, config, dataset, tva_idx, ctrl_idx,
            n_occ, idx_to_occ, present_occs, device,
            adapter_steps=args.adapter_steps,
            batch_size=args.batch_size, lr=args.lr,
            lora_r=args.lora_r, lora_alpha=args.lora_alpha,
        )

        all_dids.append(occ_did)

        # Save iteration
        iter_result = {
            "iteration": i,
            "occ_did": occ_did.tolist(),
            "n_tva": len(tva_idx),
            "n_ctrl": len(ctrl_idx),
            "time_seconds": time.time() - iter_start,
        }
        with open(out_dir / f"iteration_{i:03d}.json", "w") as f:
            json.dump(iter_result, f, indent=2)

        elapsed = time.time() - iter_start
        total_elapsed = time.time() - total_start
        iters_done = i - args.start + 1
        avg_per_iter = total_elapsed / iters_done
        remaining = avg_per_iter * (args.iterations - i - 1)

        print(f"  Iteration {i+1} done in {elapsed:.0f}s")
        print(f"  Avg: {avg_per_iter:.0f}s/iter, ETA: {remaining/3600:.1f}h")

        # Save running summary after each iteration
        if len(all_dids) >= 2:
            dids_array = np.array(all_dids)
            boot_ses = dids_array.std(axis=0)
            boot_mean = dids_array.mean(axis=0)
            summary = {
                "n_completed": len(all_dids),
                "mean_did": boot_mean.tolist(),
                "bootstrap_ses": boot_ses.tolist(),
                "occ_labels": present_occs,
                "avg_seconds_per_iter": avg_per_iter,
            }
            with open(out_dir / "running_summary.json", "w") as f:
                json.dump(summary, f, indent=2)

    # Final summary
    print(f"\n{'='*60}")
    print(f"Bootstrap complete: {len(all_dids)} iterations")
    print(f"{'='*60}")

    dids_array = np.array(all_dids)
    boot_ses = dids_array.std(axis=0)
    boot_mean = dids_array.mean(axis=0)

    # Load point estimate for p-values
    point_path = Path("projects/did_transformer/outputs/four_adapter/four_adapter_results.json")
    if point_path.exists():
        with open(point_path) as f:
            point_results = json.load(f)
        point_did_raw = np.array(point_results["model_did"])
        point_did = aggregate_to_occ(point_did_raw, idx_to_occ, present_occs)
    else:
        point_did = boot_mean

    # P-values: fraction of bootstrap samples with |effect| >= |point estimate|
    p_values = np.zeros_like(point_did)
    for i in range(point_did.shape[0]):
        for j in range(point_did.shape[1]):
            if abs(point_did[i, j]) < 1e-10:
                p_values[i, j] = 1.0
            else:
                p_values[i, j] = float(np.mean(
                    np.abs(dids_array[:, i, j] - boot_mean[i, j]) >= abs(point_did[i, j] - boot_mean[i, j])
                ))

    # 95% CIs
    ci_lo = np.percentile(dids_array, 2.5, axis=0)
    ci_hi = np.percentile(dids_array, 97.5, axis=0)

    # BH-FDR correction
    n_cells = p_values.size
    flat_p = p_values.flatten()
    sorted_idx = np.argsort(flat_p)
    bh_threshold = np.zeros(n_cells)
    fdr_level = 0.10
    for rank, idx in enumerate(sorted_idx, 1):
        bh_threshold[idx] = fdr_level * rank / n_cells
    significant_bh = (flat_p <= bh_threshold).reshape(point_did.shape)

    n_sig_raw = int((p_values < 0.05).sum())
    n_sig_bh = int(significant_bh.sum())

    display_labels = [OCC_DISPLAY.get(o, o) for o in present_occs]

    print(f"\nTransformer DiD with bootstrap SEs (pp):")
    print(f"{'':>12s}", end="")
    for label in display_labels:
        print(f"  {label[:6]:>6s}", end="")
    print()
    for i, src in enumerate(display_labels):
        print(f"{src:>12s}", end="")
        for j in range(len(display_labels)):
            val = point_did[i, j] * 100
            star = "*" if p_values[i, j] < 0.05 else ""
            print(f" {val:5.1f}{star:<1s}", end="")
        print()
        print(f"{'':>12s}", end="")
        for j in range(len(display_labels)):
            se = boot_ses[i, j] * 100
            print(f" ({se:4.1f})", end="")
        print()

    print(f"\n  Significant at 5%: {n_sig_raw}/{n_cells} cells")
    print(f"  Significant after BH-FDR (10%): {n_sig_bh}/{n_cells} cells")

    # Save final results
    final = {
        "point_estimate": point_did.tolist(),
        "bootstrap_mean": boot_mean.tolist(),
        "bootstrap_ses": boot_ses.tolist(),
        "bootstrap_p_values": p_values.tolist(),
        "bootstrap_ci_lo": ci_lo.tolist(),
        "bootstrap_ci_hi": ci_hi.tolist(),
        "significant_bh_10pct": significant_bh.tolist(),
        "n_bootstrap": len(all_dids),
        "n_significant_5pct": n_sig_raw,
        "n_significant_bh_10pct": n_sig_bh,
        "occ_labels": present_occs,
        "display_labels": display_labels,
        "adapter_steps": args.adapter_steps,
        "total_time_hours": (time.time() - total_start) / 3600,
    }

    with open(out_dir / "bootstrap_results.json", "w") as f:
        json.dump(final, f, indent=2)

    print(f"\nFinal results saved to {out_dir / 'bootstrap_results.json'}")
    print(f"Total time: {(time.time() - total_start)/3600:.1f} hours")


if __name__ == "__main__":
    main()
