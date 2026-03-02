#!/usr/bin/env python3
"""
00b_newspaper_fetch.py — Going Up Alone v4 (apep_0478)
Search American Stories newspaper corpus for elevator-related articles.

The corpus stores one tar.gz per year, each containing JSON files (one per
newspaper scan). Each JSON has a 'full articles' key with article-level data.

Strategy:
  - Stream through archives without extracting to disk
  - Focus on strategic years (every 5 years + key events)
  - Two-stage filtering: broad regex → grain elevator exclusion
  - OCR-tolerant patterns for historical newspaper text

Being clever about keywords:
  1. "elevator" catches most hits, but grain elevators dominate midwest papers
  2. High-signal phrases (operator, boy, girl, attendant, strike, automatic)
     are unambiguous — always keep
  3. Ambiguous "elevator" mentions get grain-context checking
  4. OCR tolerance: [ec]l[ec]vat[oa]r catches common substitutions
"""

import os
import re
import sys
import json
import tarfile
import logging
from pathlib import Path

import pyarrow as pa
import pyarrow.parquet as pq
from huggingface_hub import hf_hub_download

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

DATA_DIR = Path(__file__).resolve().parent.parent / "data"
DATA_DIR.mkdir(parents=True, exist_ok=True)
OUTPUT_FILE = DATA_DIR / "newspaper_matches_raw.parquet"

# Load HF_TOKEN from .env
env_path = Path(__file__).resolve().parent.parent.parent.parent.parent / ".env"
HF_TOKEN = None
if env_path.exists():
    for line in env_path.read_text().splitlines():
        if line.startswith("HF_TOKEN="):
            HF_TOKEN = line.split("=", 1)[1].strip()
            break
if not HF_TOKEN:
    log.error("HF_TOKEN not found in .env")
    sys.exit(1)

# Strategic years: every 5 years from 1900-1960, plus 1945/1946 (strike years)
YEARS = [1900, 1905, 1910, 1915, 1920, 1925, 1930, 1935,
         1940, 1945, 1946, 1950, 1955, 1960]

# ─────────────────────────────────────────────────────────────────────────────
# Keyword patterns (OCR-tolerant)
# ─────────────────────────────────────────────────────────────────────────────

# Quick first-pass filter: must contain something that looks like "elevator"
# Using broad pattern for speed
QUICK_RE = re.compile(r'[ec]l[ec]vat[oa]r', re.IGNORECASE)

# High-signal: unambiguously about building elevators / people
HIGH_SIGNAL = re.compile(
    r'|'.join([
        r'[ec]l[ec]vat[oa]r\s+(?:op[ec]rat[oa]r|b[oa]y|girl|man\b|m[ec]n\b|'
        r'att[ec]ndant|start[ec]r|strik[ec]|union|shaft|cab|door|lobby|'
        r'hotel|offic[ec]|d[ec]partm[ec]nt\s+stor[ec]|hospital|passeng[ec]r|'
        r'rid[ec]r|button|s[ec]rv[il1]c[ec]|floor)',
        r'(?:op[ec]rat[oa]r|b[oa]y|girl|att[ec]ndant|start[ec]r)'
        r'\s+(?:of\s+)?(?:an?\s+)?[ec]l[ec]vat[oa]r',
        r'(?:s[ec]lf[\s\-]?s[ec]rv[il1]c[ec]|aut[oa]m[an]t[il1]c|push[\s\-]?butt[oa]n|'
        r'[oa]p[ec]rat[oa]rl[ec]ss)\s+[ec]l[ec]vat[oa]r',
        r'[ec]l[ec]vat[oa]r\s+(?:s[ec]lf[\s\-]?s[ec]rv[il1]c[ec]|aut[oa]m[an]t[il1]c)',
        r'(?:otis|westinghouse)\s+[ec]l[ec]vat[oa]r',
        r'[ec]l[ec]vat[oa]r\s+(?:compan[yi]|co\b)',
    ]),
    re.IGNORECASE
)

# Grain/agricultural context — likely NOT about building elevators
GRAIN_RE = re.compile(
    r'(?:grain|wheat|corn|oat|barl[ec]y|bush[ec]l|bin|'
    r'(?:terminal|country|line)\s+[ec]l[ec]vat[oa]r|'
    r'[ec]l[ec]vat[oa]r\s+(?:A|B|C|D)\b|'
    r'[ec]l[ec]vat[oa]r\s+(?:capac[il1]ty|receip|stor[ea]g[ec]))',
    re.IGNORECASE
)

def should_keep(text: str) -> tuple[bool, str]:
    """Return (keep, pre_label) for a text containing 'elevator'."""
    has_high = HIGH_SIGNAL.search(text) is not None
    has_grain = GRAIN_RE.search(text) is not None

    if has_high:
        return True, "KEEP"
    if has_grain and not has_high:
        return False, "GRAIN"
    # Has "elevator" but no clear context — keep as AMBIGUOUS
    return True, "AMBIGUOUS"


def process_year(year: int) -> list[dict]:
    """Download and stream through one year's archive."""
    filename = f"faro_{year}.tar.gz"
    log.info(f"  Downloading {filename}...")

    try:
        path = hf_hub_download(
            "dell-research-harvard/AmericanStories",
            filename,
            repo_type="dataset",
            token=HF_TOKEN
        )
    except Exception as e:
        log.warning(f"  Cannot download {filename}: {e}")
        return []

    matches = []
    n_scans = 0
    n_articles = 0
    n_primary = 0

    log.info(f"  Streaming through {filename}...")

    with tarfile.open(path, "r:gz") as tf:
        for member in tf:
            if not member.name.endswith(".json"):
                continue

            n_scans += 1
            if n_scans % 10000 == 0:
                log.info(f"    {n_scans:,} scans, {n_articles:,} articles, "
                         f"{n_primary} primary matches, {len(matches)} kept")

            try:
                f = tf.extractfile(member)
                if f is None:
                    continue
                data = json.loads(f.read())
            except (json.JSONDecodeError, Exception):
                continue

            # Get articles — key is "full articles" (with space)
            articles = data.get("full articles") or data.get("full_articles") or []

            # Get newspaper metadata
            lccn = data.get("lccn", {})
            newspaper_name = lccn.get("title", "")
            page = data.get("page_number", "")

            # Extract date from filename: YYYY-MM-DD_pN_...
            scan_id = member.name.rsplit("/", 1)[-1].replace(".json", "")
            date = scan_id[:10] if len(scan_id) >= 10 else str(year)

            for art_idx, art in enumerate(articles):
                n_articles += 1
                text = art.get("article", "")
                headline = art.get("headline", "")
                full_text = f"{headline} {text}"

                if not QUICK_RE.search(full_text):
                    continue

                n_primary += 1
                keep, pre_label = should_keep(full_text)

                if not keep:
                    continue

                matches.append({
                    "article_id": f"{scan_id}_{art_idx}",
                    "newspaper_name": newspaper_name,
                    "date": date,
                    "page": str(page),
                    "headline": headline[:500],
                    "article": text[:3000],
                    "year": year,
                    "pre_label": pre_label,
                })

    log.info(f"  {year}: {n_scans:,} scans, {n_articles:,} articles, "
             f"{n_primary} primary, {len(matches)} kept")
    return matches


def main():
    all_matches = []

    for year in YEARS:
        log.info(f"Processing {year}...")
        matches = process_year(year)
        all_matches.extend(matches)
        log.info(f"  Running total: {len(all_matches):,} matches")

    if all_matches:
        table = pa.Table.from_pylist(all_matches)
        pq.write_table(table, OUTPUT_FILE)
        log.info(f"\nSaved {len(all_matches):,} matched articles to {OUTPUT_FILE}")

        # Year summary
        from collections import Counter
        year_counts = Counter(m["year"] for m in all_matches)
        label_counts = Counter(m["pre_label"] for m in all_matches)
        log.info("\nMatches by year:")
        for y in sorted(year_counts):
            log.info(f"  {y}: {year_counts[y]:,}")
        log.info(f"\nBy pre-label: {dict(label_counts)}")
    else:
        log.warning("No matches found!")

    stats = {
        "years_processed": len(YEARS),
        "total_matches": len(all_matches),
        "by_year": {str(m["year"]): 0 for m in all_matches}
    }
    from collections import Counter
    for y, c in Counter(m["year"] for m in all_matches).items():
        stats["by_year"][str(y)] = c
    with open(DATA_DIR / "newspaper_fetch_stats.json", "w") as f:
        json.dump(stats, f, indent=2)


if __name__ == "__main__":
    main()
