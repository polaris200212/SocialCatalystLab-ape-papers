#!/usr/bin/env python3
"""
frequency_benchmark.py — Raw frequency-based DiD transition matrix.

Computes the same 12×12 occupation-level DiD transition matrix using
empirical frequencies (no model). This serves as a benchmark to validate
that the transformer recovers a real statistical object rather than
creating patterns through inductive bias.

For each group × period cell:
  1. Count occupation-to-occupation transitions
  2. Normalize rows to get empirical transition probabilities
  3. Double-difference to get DiD matrix

Also computes county-cluster bootstrap SEs for the frequency estimator.

Usage:
    python -m projects.did_transformer.analysis.frequency_benchmark
    python -m projects.did_transformer.analysis.frequency_benchmark --bootstrap 200
"""

import argparse
import json
import sys
import time
from collections import defaultdict
from pathlib import Path

import numpy as np
import pyarrow.parquet as pq

project_root = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(project_root))

from projects.did_transformer.data.dataset_v2 import load_vocab_v2
from projects.did_transformer.analysis.generate_figures import (
    OCC_ORDER, OCC_DISPLAY, build_occ_aggregation,
)

# Occupation mapping at the broad level (OCC1950 ranges)
# Mirrors extract_sequences_v3.py exactly
OCC_BROAD_RANGES = {
    range(0, 100): "Prof",
    range(100, 200): "Farmer",
    range(200, 300): "Manager",
    range(300, 400): "Clerical",
    range(400, 500): "Sales",
    range(500, 600): "Craftsman",
    range(600, 700): "Operative",
    range(700, 800): "Service",
    range(800, 900): "FarmLab",
    range(900, 980): "Laborer",
}


def token_to_occ(token_id, idx_to_occ):
    """Map token_id (1-indexed) to broad occupation category."""
    return idx_to_occ.get(token_id - 1, None)  # token_id is 1-indexed, matrix is 0-indexed


def compute_transition_matrix(input_ids_list, idx_to_occ, occ_order, src_pos, dst_pos):
    """Compute empirical transition matrix from input_ids sequences.

    Args:
        input_ids_list: List of [tok_1920, tok_1930, tok_1940] sequences
        idx_to_occ: token matrix index -> occupation mapping
        occ_order: list of occupation names in order
        src_pos: source position index (0=1920, 1=1930)
        dst_pos: destination position index (1=1930, 2=1940)

    Returns:
        n_occ × n_occ transition matrix (rows=source, cols=destination)
    """
    n_occ = len(occ_order)
    occ_to_idx = {o: i for i, o in enumerate(occ_order)}
    counts = np.zeros((n_occ, n_occ))

    for seq in input_ids_list:
        src_tok = seq[src_pos]
        dst_tok = seq[dst_pos]
        src_occ = token_to_occ(src_tok, idx_to_occ)
        dst_occ = token_to_occ(dst_tok, idx_to_occ)
        if src_occ is not None and dst_occ is not None:
            si = occ_to_idx.get(src_occ)
            di = occ_to_idx.get(dst_occ)
            if si is not None and di is not None:
                counts[si, di] += 1

    # Normalize rows
    row_sums = counts.sum(axis=1, keepdims=True)
    row_sums[row_sums == 0] = 1  # avoid division by zero
    return counts / row_sums, counts


def compute_did_matrix(tva_ids, ctrl_ids, idx_to_occ, occ_order):
    """Compute full DiD transition matrix from raw frequencies.

    Pre:  1920→1930 (positions 0→1)
    Post: 1930→1940 (positions 1→2)
    """
    T_tva_pre, _ = compute_transition_matrix(tva_ids, idx_to_occ, occ_order, 0, 1)
    T_tva_post, _ = compute_transition_matrix(tva_ids, idx_to_occ, occ_order, 1, 2)
    T_ctrl_pre, _ = compute_transition_matrix(ctrl_ids, idx_to_occ, occ_order, 0, 1)
    T_ctrl_post, _ = compute_transition_matrix(ctrl_ids, idx_to_occ, occ_order, 1, 2)

    did = (T_tva_post - T_tva_pre) - (T_ctrl_post - T_ctrl_pre)
    return did, T_tva_pre, T_tva_post, T_ctrl_pre, T_ctrl_post


def county_cluster_bootstrap(tva_ids, ctrl_ids, tva_counties, ctrl_counties,
                              idx_to_occ, occ_order, n_boot=200, seed=42):
    """Bootstrap DiD matrix by resampling counties with replacement.

    Args:
        tva_ids: list of input_id sequences for TVA individuals
        ctrl_ids: list of input_id sequences for control individuals
        tva_counties: list of (state, county) tuples for TVA individuals
        ctrl_counties: list of (state, county) tuples for control individuals
    """
    rng = np.random.default_rng(seed)
    n_occ = len(occ_order)

    # Build county -> individual index mapping
    tva_county_to_idx = defaultdict(list)
    for i, c in enumerate(tva_counties):
        tva_county_to_idx[c].append(i)

    ctrl_county_to_idx = defaultdict(list)
    for i, c in enumerate(ctrl_counties):
        ctrl_county_to_idx[c].append(i)

    tva_county_list = list(tva_county_to_idx.keys())
    ctrl_county_list = list(ctrl_county_to_idx.keys())

    boot_dids = np.zeros((n_boot, n_occ, n_occ))

    for b in range(n_boot):
        # Sample county indices with replacement
        tva_sampled_idx = rng.choice(len(tva_county_list), size=len(tva_county_list), replace=True)
        ctrl_sampled_idx = rng.choice(len(ctrl_county_list), size=len(ctrl_county_list), replace=True)

        # Collect individuals
        tva_boot_ids = []
        for ci in tva_sampled_idx:
            c = tva_county_list[ci]
            for idx in tva_county_to_idx[c]:
                tva_boot_ids.append(tva_ids[idx])

        ctrl_boot_ids = []
        for ci in ctrl_sampled_idx:
            c = ctrl_county_list[ci]
            for idx in ctrl_county_to_idx[c]:
                ctrl_boot_ids.append(ctrl_ids[idx])

        did_b, _, _, _, _ = compute_did_matrix(tva_boot_ids, ctrl_boot_ids, idx_to_occ, occ_order)
        boot_dids[b] = did_b

        if (b + 1) % 50 == 0:
            print(f"  Bootstrap iteration {b+1}/{n_boot}")

    return boot_dids


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=str,
                        default="projects/did_transformer/data/sequences_v3_tva.parquet")
    parser.add_argument("--vocab", type=str,
                        default="projects/did_transformer/data/vocab_v2.json")
    parser.add_argument("--output-dir", type=str,
                        default="projects/did_transformer/outputs/frequency_benchmark")
    parser.add_argument("--bootstrap", type=int, default=200,
                        help="Number of bootstrap iterations for SEs")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    t0 = time.time()
    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Load vocab and build mappings
    vocab = load_vocab_v2(args.vocab)
    idx_to_occ = build_occ_aggregation(vocab)
    present_occs = [o for o in OCC_ORDER if o in set(idx_to_occ.values())]
    display_labels = [OCC_DISPLAY.get(o, o) for o in present_occs]

    print(f"Occupations ({len(present_occs)}): {present_occs}")

    # Load data
    print(f"Loading data from {args.data}...")
    table = pq.read_table(args.data)
    input_ids = table.column("input_ids").to_pylist()
    tva_treatment = table.column("tva_treatment").to_pylist()

    # County IDs for bootstrap
    county_ids = table.column("county_ids").to_pylist()
    state_ids_col = table.column("state_ids").to_pylist()

    n_total = len(input_ids)
    print(f"  {n_total:,} individuals")

    # Split by TVA treatment
    tva_ids = []
    ctrl_ids = []
    tva_counties = []
    ctrl_counties = []

    for i in range(n_total):
        # Use 1920 county (position 0) as fixed assignment
        county_key = (state_ids_col[i][0], county_ids[i][0])
        if tva_treatment[i] == 1:
            tva_ids.append(input_ids[i])
            tva_counties.append(county_key)
        else:
            ctrl_ids.append(input_ids[i])
            ctrl_counties.append(county_key)

    print(f"  TVA: {len(tva_ids):,}, Control: {len(ctrl_ids):,}")

    # Compute point estimate
    print("\nComputing frequency-based DiD matrix...")
    did, T_tva_pre, T_tva_post, T_ctrl_pre, T_ctrl_post = compute_did_matrix(
        tva_ids, ctrl_ids, idx_to_occ, present_occs
    )

    print(f"\nFrequency DiD matrix (percentage points):")
    print(f"{'':>12s}", end="")
    for label in display_labels:
        print(f"  {label[:6]:>6s}", end="")
    print()
    for i, src in enumerate(display_labels):
        print(f"{src:>12s}", end="")
        for j in range(len(display_labels)):
            val = did[i, j] * 100
            print(f"  {val:6.1f}", end="")
        print()

    # Pre-trends check
    pre_diff = T_tva_pre - T_ctrl_pre
    pre_mae = np.abs(pre_diff).mean()
    print(f"\nPre-trends MAE: {pre_mae:.4f}")
    print(f"Max pre-trend cell: {np.abs(pre_diff).max():.4f}")

    # Compare with transformer results if available
    transformer_path = Path("projects/did_transformer/outputs/four_adapter/four_adapter_results.json")
    correlation = None
    if transformer_path.exists():
        print("\nComparing with transformer-based DiD...")
        with open(transformer_path) as f:
            tf_results = json.load(f)

        # Aggregate transformer results to occupation level
        from projects.did_transformer.analysis.generate_figures import aggregate_to_occ
        tf_did_raw = np.array(tf_results["model_did"])
        tf_did = aggregate_to_occ(tf_did_raw, idx_to_occ, present_occs)

        # Compute DiD from aggregated matrices
        tf_tva_pre = aggregate_to_occ(np.array(tf_results["T_tva_pre"]), idx_to_occ, present_occs)
        tf_tva_post = aggregate_to_occ(np.array(tf_results["T_tva_post"]), idx_to_occ, present_occs)
        tf_ctrl_pre = aggregate_to_occ(np.array(tf_results["T_ctrl_pre"]), idx_to_occ, present_occs)
        tf_ctrl_post = aggregate_to_occ(np.array(tf_results["T_ctrl_post"]), idx_to_occ, present_occs)
        tf_did_recomputed = (tf_tva_post - tf_tva_pre) - (tf_ctrl_post - tf_ctrl_pre)

        # Correlation
        freq_flat = did.flatten()
        tf_flat = tf_did_recomputed.flatten()
        correlation = float(np.corrcoef(freq_flat, tf_flat)[0, 1])
        mae_diff = float(np.abs(did - tf_did_recomputed).mean())

        print(f"  Correlation (frequency vs transformer): {correlation:.4f}")
        print(f"  MAE between methods: {mae_diff:.4f}")

        # Cell-by-cell comparison for biggest differences
        diff = did - tf_did_recomputed
        flat_idx = np.argsort(np.abs(diff).flatten())[::-1]
        print(f"\n  Top 5 cells where methods diverge:")
        for rank, fi in enumerate(flat_idx[:5]):
            i, j = divmod(fi, len(present_occs))
            print(f"    {display_labels[i]:>12s} → {display_labels[j]:<12s}: "
                  f"freq={did[i,j]*100:+.2f}pp, transformer={tf_did_recomputed[i,j]*100:+.2f}pp, "
                  f"diff={diff[i,j]*100:+.2f}pp")

    # Bootstrap
    if args.bootstrap > 0:
        print(f"\nRunning county-cluster bootstrap ({args.bootstrap} iterations)...")
        boot_dids = county_cluster_bootstrap(
            tva_ids, ctrl_ids, tva_counties, ctrl_counties,
            idx_to_occ, present_occs, n_boot=args.bootstrap, seed=args.seed,
        )

        boot_ses = boot_dids.std(axis=0)
        boot_mean = boot_dids.mean(axis=0)

        # P-values (two-sided, fraction of bootstrap samples with opposite sign or zero)
        p_values = np.zeros_like(did)
        for i in range(did.shape[0]):
            for j in range(did.shape[1]):
                if abs(did[i, j]) < 1e-10:
                    p_values[i, j] = 1.0
                else:
                    # Two-sided: fraction of bootstrap where sign differs
                    p_values[i, j] = float(np.mean(
                        np.abs(boot_dids[:, i, j]) >= np.abs(did[i, j])
                    ))

        # 95% CIs
        ci_lo = np.percentile(boot_dids, 2.5, axis=0)
        ci_hi = np.percentile(boot_dids, 97.5, axis=0)

        print(f"\nFrequency DiD with bootstrap SEs (pp):")
        print(f"{'':>12s}", end="")
        for label in display_labels:
            print(f"  {label[:6]:>6s}", end="")
        print()
        for i, src in enumerate(display_labels):
            print(f"{src:>12s}", end="")
            for j in range(len(display_labels)):
                val = did[i, j] * 100
                se = boot_ses[i, j] * 100
                star = "*" if p_values[i, j] < 0.05 else ""
                print(f" {val:5.1f}{star:<1s}", end="")
            print()
            # SE row
            print(f"{'':>12s}", end="")
            for j in range(len(display_labels)):
                se = boot_ses[i, j] * 100
                print(f" ({se:4.1f})", end="")
            print()

        # BH-FDR correction
        n_cells = did.size
        flat_p = p_values.flatten()
        sorted_idx = np.argsort(flat_p)
        bh_threshold = np.zeros(n_cells)
        fdr_level = 0.10
        for rank, idx in enumerate(sorted_idx, 1):
            bh_threshold[idx] = fdr_level * rank / n_cells
        significant_bh = (flat_p <= bh_threshold).reshape(did.shape)

        n_sig_raw = int((p_values < 0.05).sum())
        n_sig_bh = int(significant_bh.sum())
        print(f"\n  Significant at 5%: {n_sig_raw}/{n_cells} cells")
        print(f"  Significant after BH-FDR (10%): {n_sig_bh}/{n_cells} cells")
    else:
        boot_ses = None
        p_values = None
        ci_lo = None
        ci_hi = None
        significant_bh = None

    # Save results
    results = {
        "did_matrix": did.tolist(),
        "T_tva_pre": T_tva_pre.tolist(),
        "T_tva_post": T_tva_post.tolist(),
        "T_ctrl_pre": T_ctrl_pre.tolist(),
        "T_ctrl_post": T_ctrl_post.tolist(),
        "occ_labels": present_occs,
        "display_labels": display_labels,
        "pre_trends_mae": float(pre_mae),
        "n_tva": len(tva_ids),
        "n_ctrl": len(ctrl_ids),
        "n_tva_counties": len(set(tva_counties)),
        "n_ctrl_counties": len(set(ctrl_counties)),
    }

    if correlation is not None:
        results["transformer_correlation"] = correlation

    if boot_ses is not None:
        results["bootstrap_ses"] = boot_ses.tolist()
        results["bootstrap_p_values"] = p_values.tolist()
        results["bootstrap_ci_lo"] = ci_lo.tolist()
        results["bootstrap_ci_hi"] = ci_hi.tolist()
        results["significant_bh_10pct"] = significant_bh.tolist()
        results["n_bootstrap"] = args.bootstrap
        results["n_significant_5pct"] = n_sig_raw
        results["n_significant_bh_10pct"] = n_sig_bh

    with open(out_dir / "frequency_results.json", "w") as f:
        json.dump(results, f, indent=2)

    elapsed = time.time() - t0
    print(f"\nResults saved to {out_dir / 'frequency_results.json'} ({elapsed:.0f}s)")


if __name__ == "__main__":
    main()
