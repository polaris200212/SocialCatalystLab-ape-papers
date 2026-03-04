#!/usr/bin/env python3
"""
finetune_four_adapter.py — Four-adapter LoRA DiD on real TVA data.

Implements the core methodological contribution: train 4 LoRA adapters
on the 2×2 (Treatment/Control × Pre/Post) cells with temporal loss masking.

Temporal structure:
  - 1920→1930 transition = pre-TVA (loss at position 0)
  - 1930→1940 transition = post-TVA (loss at position 1)

Usage:
    python -m projects.did_transformer.train.finetune_four_adapter
    python -m projects.did_transformer.train.finetune_four_adapter --steps 2000
"""

import argparse
import json
import math
import sys
import time
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


def _move_batch(batch, device):
    result = {}
    for k, v in batch.items():
        if isinstance(v, torch.Tensor):
            result[k] = v.to(device)
        elif isinstance(v, dict):
            result[k] = _move_batch(v, device)
        else:
            result[k] = v
    return result


def mask_labels_temporal(labels, keep_positions, pad_id=0):
    """Zero out labels at positions NOT in keep_positions."""
    masked = labels.clone()
    T = masked.shape[1]
    kill = torch.ones(T, dtype=torch.bool, device=labels.device)
    for pos in keep_positions:
        if pos < T:
            kill[pos] = False
    masked[:, kill] = pad_id
    return masked


def filter_by_treatment(dataset, treatment_value):
    """Return indices of individuals with given TVA treatment value."""
    return dataset.get_treatment_indices(treatment_value)


def finetune_adapter(
    base_state, config, dataset, region_indices, keep_positions,
    device, label, max_steps=1500, batch_size=256, lr=1e-4,
    lora_r=8, lora_alpha=16.0,
):
    """Fine-tune a LoRA adapter on a specific region × period cell."""
    model = CensusCareerModel(config).to(device)
    model.load_state_dict(base_state)
    apply_lora(model, r=lora_r, alpha=lora_alpha)

    # Split train/val
    n_val = max(1000, len(region_indices) // 20)
    g = torch.Generator().manual_seed(42)
    perm = torch.randperm(len(region_indices), generator=g).tolist()
    train_idx = [region_indices[p] for p in perm[:-n_val]]
    val_idx = [region_indices[p] for p in perm[-n_val:]]

    train_set = Subset(dataset, train_idx)
    val_set = Subset(dataset, val_idx)

    collator = CareerCollator(pad_id=0)
    train_loader = DataLoader(train_set, batch_size=batch_size, shuffle=True,
                              collate_fn=collator, num_workers=0, drop_last=True)
    val_loader = DataLoader(val_set, batch_size=batch_size, shuffle=False,
                            collate_fn=collator, num_workers=0)

    lora_params = [p for p in model.parameters() if p.requires_grad]
    optimizer = torch.optim.Adam(lora_params, lr=lr, betas=(0.9, 0.98))

    model.train()
    step = 0
    running_loss = 0.0
    best_val_loss = float("inf")
    t0 = time.time()

    while step < max_steps:
        for batch in train_loader:
            if step >= max_steps:
                break

            batch = _move_batch(batch, device)
            # Temporal loss masking
            masked_labels = mask_labels_temporal(batch["labels"], keep_positions)

            output = model(
                input_ids=batch["input_ids"],
                covariates=batch["covariates"],
                labels=masked_labels,
            )
            loss = output["loss"]

            optimizer.zero_grad()
            loss.backward()
            torch.nn.utils.clip_grad_norm_(lora_params, 1.0)
            optimizer.step()

            running_loss += loss.item()
            step += 1

            if step % 300 == 0:
                avg = running_loss / 300
                elapsed = time.time() - t0
                print(f"    [{label:>12s}] step {step:5d} | loss {avg:.4f} | {elapsed:.0f}s")
                running_loss = 0.0

                # Validate
                model.eval()
                val_loss = 0
                n_val_batches = 0
                with torch.no_grad():
                    for vb in val_loader:
                        vb = _move_batch(vb, device)
                        vl = mask_labels_temporal(vb["labels"], keep_positions)
                        vo = model(input_ids=vb["input_ids"],
                                   covariates=vb["covariates"], labels=vl)
                        val_loss += vo["loss"].item()
                        n_val_batches += 1
                val_loss /= max(n_val_batches, 1)
                improved = " *" if val_loss < best_val_loss else ""
                if val_loss < best_val_loss:
                    best_val_loss = val_loss
                print(f"    [{label:>12s}] val {val_loss:.4f}{improved}")
                model.train()

    elapsed = time.time() - t0
    print(f"    [{label:>12s}] done: {step} steps in {elapsed:.0f}s, best val {best_val_loss:.4f}")

    lora_state = extract_lora_state(model)
    return lora_state, model


@torch.no_grad()
def extract_transitions(model, dataset, indices, n_occ, device, positions):
    """Extract transition matrix from model via statistical extraction."""
    model.eval()
    subset = Subset(dataset, indices)
    collator = CareerCollator(pad_id=0)
    loader = DataLoader(subset, batch_size=512, shuffle=False,
                        collate_fn=collator, num_workers=0)

    # n_occ is the number of non-pad tokens
    # Model output log_probs has shape (B, T, vocab_size) where vocab_size includes pad
    # Token indices: 0=pad, 1..n_occ = real tokens
    # We extract probabilities for real tokens only (indices 1..end)

    first_batch = True
    prob_sums = None
    counts = None

    for batch in loader:
        batch = _move_batch(batch, device)
        output = model(batch["input_ids"], batch["covariates"])
        probs = torch.exp(output["log_probs"]).cpu().numpy()

        # Determine actual vocab size from model output
        V = probs.shape[-1]
        actual_n_occ = V - 1  # exclude pad at index 0

        if first_batch:
            prob_sums = np.zeros((actual_n_occ, actual_n_occ))
            counts = np.zeros(actual_n_occ)
            first_batch = False

        occ_probs = probs[:, :, 1:]  # Skip pad (index 0)
        input_occs = batch["input_ids"].cpu().numpy() - 1  # Convert to 0-indexed

        B, T = batch["input_ids"].shape
        for t in range(T):
            if t not in positions:
                continue
            for b in range(B):
                src = int(input_occs[b, t])
                if 0 <= src < actual_n_occ:
                    row = occ_probs[b, t]
                    row_sum = row.sum()
                    if row_sum > 0:
                        row = row / row_sum
                    prob_sums[src] += row
                    counts[src] += 1

    if prob_sums is None:
        return np.zeros((n_occ, n_occ))

    trans = np.zeros_like(prob_sums)
    for i in range(len(counts)):
        if counts[i] > 0:
            trans[i] = prob_sums[i] / counts[i]

    return trans


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=str,
                        default="projects/did_transformer/data/sequences_v3_tva.parquet")
    parser.add_argument("--vocab", type=str,
                        default="projects/did_transformer/data/vocab_v2.json")
    parser.add_argument("--checkpoint", type=str,
                        default="projects/did_transformer/outputs/pretrain_v2_best.pt")
    parser.add_argument("--steps", type=int, default=1500)
    parser.add_argument("--batch-size", type=int, default=256)
    parser.add_argument("--lr", type=float, default=1e-4)
    parser.add_argument("--lora-r", type=int, default=8)
    parser.add_argument("--lora-alpha", type=float, default=16.0)
    parser.add_argument("--device", type=str, default=None)
    parser.add_argument("--output-dir", type=str,
                        default="projects/did_transformer/outputs/four_adapter")
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

    # Load data
    print(f"Loading data from {args.data}...")
    dataset = LifeStateDataset(args.data)
    print(f"  {len(dataset):,} sequences")

    # Split by TVA treatment
    print("Filtering by TVA treatment...")
    tva_idx = filter_by_treatment(dataset, 1)
    ctrl_idx = filter_by_treatment(dataset, 0)
    print(f"  TVA: {len(tva_idx):,}, Control: {len(ctrl_idx):,}")

    # Load vocab
    vocab = load_vocab_v2(args.vocab)
    n_occ = len(vocab["tokens"]) + len(vocab["special_tokens"])

    # Load pre-trained checkpoint
    print(f"Loading checkpoint from {args.checkpoint}...")
    ckpt = torch.load(args.checkpoint, map_location="cpu", weights_only=False)
    config = ckpt["config"]
    base_state = ckpt["model_state"]

    # Temporal structure: position 0 = 1920→1930 (pre), position 1 = 1930→1940 (post)
    pre_positions = [0]
    post_positions = [1]

    print(f"\nFine-tuning 4 adapters with temporal masking...")
    print(f"  Pre positions:  {pre_positions}")
    print(f"  Post positions: {post_positions}")

    adapters = {}
    models = {}

    for region_name, region_idx in [("TVA", tva_idx), ("Ctrl", ctrl_idx)]:
        for period_name, positions in [("pre", pre_positions), ("post", post_positions)]:
            label = f"{region_name}_{period_name}"
            print(f"\n{'='*60}")
            print(f"Adapter: {label} ({len(region_idx):,} individuals, positions {positions})")
            print(f"{'='*60}")

            lora_state, finetuned_model = finetune_adapter(
                base_state, config, dataset, region_idx, positions,
                device, label, max_steps=args.steps,
                batch_size=args.batch_size, lr=args.lr,
                lora_r=args.lora_r, lora_alpha=args.lora_alpha,
            )
            adapters[label] = lora_state
            models[label] = finetuned_model

            # Save adapter
            torch.save({
                "lora_state": lora_state,
                "label": label,
                "n_samples": len(region_idx),
                "positions": positions,
            }, out_dir / f"adapter_{label}.pt")

    # Extract transition matrices
    print(f"\n{'='*60}")
    print("Extracting transition matrices...")
    print(f"{'='*60}")

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

    # Compute DiD
    model_did = (T_tva_post - T_tva_pre) - (T_ctrl_post - T_ctrl_pre)

    # Pre-trends check
    pre_diff = np.abs(T_tva_pre - T_ctrl_pre).mean()
    print(f"\nPre-trends MAE (TVA pre vs Ctrl pre): {pre_diff:.4f}")

    # Weight-space DiD + SVD
    print(f"\nWeight-space DiD SVD:")
    for name in sorted(adapters["TVA_pre"].keys()):
        eff = {}
        for label in ["TVA_pre", "TVA_post", "Ctrl_pre", "Ctrl_post"]:
            A = adapters[label][name]["lora_A"]
            B = adapters[label][name]["lora_B"]
            eff[label] = B @ A
        delta = (eff["TVA_post"] - eff["TVA_pre"]) - (eff["Ctrl_post"] - eff["Ctrl_pre"])
        l2 = delta.norm().item()
        if min(delta.shape) >= 2 and l2 > 1e-6:
            U, S, Vh = torch.linalg.svd(delta, full_matrices=False)
            energy_1 = float(S[0]**2 / (S**2).sum() * 100)
            short = name.split("decoder.layers.layers.")[-1] if "decoder" in name else name
            top3 = S[:3].tolist()
            print(f"  {short:<40s} L2={l2:.4f} σ=[{', '.join(f'{s:.4f}' for s in top3)}] top-1: {energy_1:.0f}%")

    # Save all results
    results = {
        "model_did": model_did.tolist(),
        "T_tva_pre": T_tva_pre.tolist(),
        "T_tva_post": T_tva_post.tolist(),
        "T_ctrl_pre": T_ctrl_pre.tolist(),
        "T_ctrl_post": T_ctrl_post.tolist(),
        "pre_trends_mae": float(pre_diff),
        "n_tva": len(tva_idx),
        "n_ctrl": len(ctrl_idx),
    }

    with open(out_dir / "four_adapter_results.json", "w") as f:
        json.dump(results, f, indent=2)

    # Save adapters bundle
    torch.save({
        "adapters": adapters,
        "results": results,
    }, out_dir / "all_adapters.pt")

    print(f"\nResults saved to {out_dir}")
    print(f"  TVA: {len(tva_idx):,}, Control: {len(ctrl_idx):,}")
    print(f"  Pre-trends MAE: {pre_diff:.4f}")


if __name__ == "__main__":
    main()
