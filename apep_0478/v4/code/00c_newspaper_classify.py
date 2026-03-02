#!/usr/bin/env python3
"""
00c_newspaper_classify.py — Going Up Alone v4 (apep_0478)
Classify matched newspaper articles using Gemini 3 Flash.

Categories:
  AUTOMATION: Articles about automatic elevators, push-button technology,
              self-service elevators, or the replacement of operators
  LABOR: Union activity, strikes, wages, working conditions
  CONSTRUCTION: New building construction mentioning elevator installation
  ACCIDENT: Elevator accidents, injuries, deaths
  HUMAN_INTEREST: Personal stories about elevator operators
  OTHER: Mentions elevator but not primarily about the topics above

Uses batch classification (10 articles per API call) to minimize cost.
"""

import os
import sys
import json
import time
import logging
from pathlib import Path
from datetime import datetime

import pyarrow.parquet as pq
import pandas as pd

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

# ─────────────────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────────────────

DATA_DIR = Path(__file__).resolve().parent.parent / "data"
INPUT_FILE = DATA_DIR / "newspaper_matches_raw.parquet"
OUTPUT_FILE = DATA_DIR / "newspaper_classified.parquet"

# Load Google API key from .env
env_path = Path(__file__).resolve().parent.parent.parent.parent.parent / ".env"
GOOGLE_API_KEY = None
if env_path.exists():
    for line in env_path.read_text().splitlines():
        if line.startswith("GOOGLE_API_KEY="):
            GOOGLE_API_KEY = line.split("=", 1)[1].strip()
            break

if not GOOGLE_API_KEY:
    log.error("GOOGLE_API_KEY not found in .env")
    sys.exit(1)

BATCH_SIZE = 10  # Articles per API call
MODEL = "gemini-2.0-flash"  # Gemini 3 Flash

CATEGORIES = ["AUTOMATION", "LABOR", "CONSTRUCTION", "ACCIDENT", "HUMAN_INTEREST", "OTHER"]

SYSTEM_PROMPT = """You are classifying historical U.S. newspaper articles (1900-1963) that mention elevators.
Your task: for each article, assign ONE primary category.

Categories:
- AUTOMATION: About automatic/self-service/push-button elevators, replacement of human operators by technology, modernization of elevator systems
- LABOR: Union activity, strikes, wages, working conditions of elevator operators/building workers
- CONSTRUCTION: New building construction or renovation that mentions elevator installation
- ACCIDENT: Elevator accidents, injuries, falls, mechanical failures, deaths
- HUMAN_INTEREST: Personal stories about elevator operators, profiles, obituaries, human moments
- OTHER: Mentions elevator in passing, classified ads, or not primarily about any above topic

Also note if the article is actually about GRAIN elevators despite passing filters.
If it's about grain elevators, classify as GRAIN_ELEVATOR.

Return a JSON array with one object per article:
[{"id": 0, "category": "AUTOMATION", "confidence": "high"}, ...]

confidence: "high" (clearly fits category), "medium" (reasonable fit), "low" (ambiguous)
"""


def build_batch_prompt(articles: list[dict]) -> str:
    """Build prompt for a batch of articles."""
    parts = [f"Classify these {len(articles)} newspaper articles:\n"]
    for i, art in enumerate(articles):
        headline = art.get("headline", "").strip()
        text = art.get("article", "").strip()[:1500]  # Truncate for token budget
        date = art.get("date", "unknown")
        newspaper = art.get("newspaper_name", "unknown")
        parts.append(f"--- Article {i} ({date}, {newspaper}) ---")
        if headline:
            parts.append(f"HEADLINE: {headline}")
        parts.append(f"TEXT: {text}")
        parts.append("")
    return "\n".join(parts)


def call_gemini(prompt: str, max_retries: int = 3) -> list[dict]:
    """Call Gemini 3 Flash API and parse response."""
    import urllib.request
    import urllib.error

    url = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent?key={GOOGLE_API_KEY}"

    body = json.dumps({
        "contents": [
            {"role": "user", "parts": [{"text": SYSTEM_PROMPT + "\n\n" + prompt}]}
        ],
        "generationConfig": {
            "temperature": 0.1,
            "maxOutputTokens": 2000,
            "responseMimeType": "application/json"
        }
    }).encode("utf-8")

    for attempt in range(max_retries):
        try:
            req = urllib.request.Request(
                url, data=body,
                headers={"Content-Type": "application/json"},
                method="POST"
            )
            with urllib.request.urlopen(req, timeout=60) as resp:
                result = json.loads(resp.read().decode())

            text = result["candidates"][0]["content"]["parts"][0]["text"]
            # Parse JSON from response
            classifications = json.loads(text)
            return classifications

        except (urllib.error.HTTPError, json.JSONDecodeError, KeyError) as e:
            if attempt < max_retries - 1:
                wait = 2 ** (attempt + 1)
                log.warning(f"  API error (attempt {attempt+1}): {e}. Retrying in {wait}s...")
                time.sleep(wait)
            else:
                log.error(f"  Failed after {max_retries} attempts: {e}")
                return []
        except Exception as e:
            log.error(f"  Unexpected error: {e}")
            return []


def main():
    if not INPUT_FILE.exists():
        log.error(f"Input file not found: {INPUT_FILE}")
        log.error("Run 00b_newspaper_fetch.py first.")
        sys.exit(1)

    # Load matched articles
    df = pq.read_table(INPUT_FILE).to_pandas()
    log.info(f"Loaded {len(df):,} matched articles")

    # Check for existing progress
    if OUTPUT_FILE.exists():
        existing = pq.read_table(OUTPUT_FILE).to_pandas()
        classified_ids = set(existing["article_id"])
        df = df[~df["article_id"].isin(classified_ids)].copy()
        log.info(f"  {len(existing):,} already classified, {len(df):,} remaining")
        all_results = existing.to_dict("records")
    else:
        all_results = []

    if len(df) == 0:
        log.info("All articles already classified.")
        return

    # Process in batches
    articles = df.to_dict("records")
    n_batches = (len(articles) + BATCH_SIZE - 1) // BATCH_SIZE

    for batch_idx in range(n_batches):
        start = batch_idx * BATCH_SIZE
        end = min(start + BATCH_SIZE, len(articles))
        batch = articles[start:end]

        if batch_idx % 50 == 0:
            log.info(f"  Batch {batch_idx+1}/{n_batches} "
                     f"({start:,}-{end:,} of {len(articles):,})")

        prompt = build_batch_prompt(batch)
        classifications = call_gemini(prompt)

        # Match classifications back to articles
        for i, art in enumerate(batch):
            result = art.copy()
            if i < len(classifications):
                cls = classifications[i]
                result["category"] = cls.get("category", "OTHER")
                result["confidence"] = cls.get("confidence", "low")
                # Override: if Gemini says GRAIN_ELEVATOR, mark it
                if result["category"] == "GRAIN_ELEVATOR":
                    continue  # Skip grain elevator articles
            else:
                result["category"] = "UNCLASSIFIED"
                result["confidence"] = "none"

            all_results.append(result)

        # Save checkpoint every 100 batches
        if (batch_idx + 1) % 100 == 0:
            _save_results(all_results)
            log.info(f"    Checkpoint saved: {len(all_results):,} articles")

        # Rate limiting
        time.sleep(0.1)

    # Final save
    _save_results(all_results)

    # Summary statistics
    results_df = pd.DataFrame(all_results)
    log.info(f"\n{'='*50}")
    log.info(f"NEWSPAPER CLASSIFICATION COMPLETE")
    log.info(f"{'='*50}")
    log.info(f"Total classified: {len(results_df):,}")
    log.info(f"\nCategory distribution:")
    for cat in CATEGORIES + ["UNCLASSIFIED"]:
        n = len(results_df[results_df["category"] == cat])
        if n > 0:
            log.info(f"  {cat}: {n:,} ({n/len(results_df)*100:.1f}%)")

    # Year × category summary
    if "year" in results_df.columns:
        cross = results_df.groupby(["year", "category"]).size().unstack(fill_value=0)
        cross.to_csv(DATA_DIR / "newspaper_year_category.csv")
        log.info(f"\nSaved year × category cross-tab to newspaper_year_category.csv")


def _save_results(results: list[dict]):
    """Save results to parquet."""
    df = pd.DataFrame(results)
    # Ensure consistent columns
    for col in ["article_id", "newspaper_name", "date", "page", "headline",
                "article", "year", "pre_label", "category", "confidence"]:
        if col not in df.columns:
            df[col] = ""
    df.to_parquet(OUTPUT_FILE, index=False)


if __name__ == "__main__":
    main()
