#!/usr/bin/env python3
"""
00d_corpus_normalization.py — apep_0478 v5
Count total articles in each sampled year of the American Stories corpus
to compute elevator-mention rates per 10,000 articles.

Uses cached HuggingFace downloads (no re-download needed).
"""

import json
import tarfile
import time
import sys
from pathlib import Path

import pandas as pd

DATA_DIR = Path(__file__).resolve().parent.parent / "data"

CACHE_BASE = Path.home() / ".cache/huggingface/hub/datasets--dell-research-harvard--AmericanStories/snapshots"

YEARS = [1900, 1905, 1910, 1915, 1920, 1925, 1930, 1935,
         1940, 1945, 1946, 1950, 1955, 1960]

# Elevator matches per year (from newspaper_fetch_stats.json)
ELEVATOR_MATCHES = {
    1900: 8483, 1905: 10971, 1910: 13710, 1915: 10466,
    1920: 9797, 1925: 2439, 1930: 3536, 1935: 2105,
    1940: 2253, 1945: 2160, 1946: 1719, 1950: 1842,
    1955: 1702, 1960: 711
}


def find_cache_dir():
    """Find the snapshot directory in the HuggingFace cache."""
    if not CACHE_BASE.exists():
        print("ERROR: HuggingFace cache not found. Run 00b_newspaper_fetch.py first.")
        sys.exit(1)
    snapshots = list(CACHE_BASE.iterdir())
    if not snapshots:
        print("ERROR: No snapshots found in cache.")
        sys.exit(1)
    return snapshots[0]


def count_articles(tar_path):
    """Count total articles in a year's tar.gz file."""
    n_scans = 0
    n_articles = 0
    with tarfile.open(tar_path, "r:gz") as tf:
        for member in tf:
            if not member.name.endswith(".json"):
                continue
            n_scans += 1
            try:
                f = tf.extractfile(member)
                if f is None:
                    continue
                data = json.loads(f.read())
                articles = data.get("full articles") or data.get("full_articles") or []
                n_articles += len(articles)
            except Exception:
                pass
    return n_scans, n_articles


def main():
    cache_dir = find_cache_dir()
    print(f"Using cache: {cache_dir}")
    print(f"Processing {len(YEARS)} years...\n")

    results = []
    total_start = time.time()

    for year in YEARS:
        tar_path = cache_dir / f"faro_{year}.tar.gz"
        if not tar_path.exists():
            print(f"  WARNING: {tar_path} not found, skipping")
            continue

        start = time.time()
        print(f"  {year}...", end=" ", flush=True)
        n_scans, n_articles = count_articles(tar_path)
        elapsed = time.time() - start

        elev_articles = ELEVATOR_MATCHES.get(year, 0)
        rate_per_10k = (elev_articles / n_articles * 10000) if n_articles > 0 else 0

        results.append({
            "year": year,
            "total_scans": n_scans,
            "total_articles": n_articles,
            "elevator_articles": elev_articles,
            "rate_per_10k": round(rate_per_10k, 2)
        })

        print(f"{n_scans:,} scans, {n_articles:,} articles, "
              f"rate={rate_per_10k:.2f}/10k ({elapsed:.0f}s)")

    total_elapsed = time.time() - total_start
    print(f"\nTotal time: {total_elapsed:.0f}s")

    df = pd.DataFrame(results)
    out_path = DATA_DIR / "corpus_normalization.csv"
    df.to_csv(out_path, index=False)
    print(f"\nSaved to {out_path}")
    print(df.to_string(index=False))


if __name__ == "__main__":
    main()
