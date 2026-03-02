#!/usr/bin/env python3
"""
01_fetch_data.py — Request and download 1910 census data from IPUMS USA API.

Submits ONE extract:
  1. us1910l (1.4% oversampled 1910) — includes VETCIVWR for veteran identification

NOTE: The full-count 1910 census (us1910m) does NOT include the VETCIVWR variable
needed to identify Civil War veterans. The 1.4% oversampled sample (us1910l) is the
largest available sample with VETCIVWR. Cross-census linkage via HISTID is not
possible because HISTID is only available in full-count samples, while VETCIVWR
is only available in the 1% and 1.4% samples.

Usage:
    export IPUMS_API_KEY=your_key_here
    python3 code/01_fetch_data.py
"""

import os
import sys
import time
from pathlib import Path

try:
    from ipumspy import IpumsApiClient, MicrodataExtract
except ImportError:
    print("ERROR: ipumspy not installed. Run: pip3 install ipumspy")
    sys.exit(1)

API_KEY = os.environ.get("IPUMS_API_KEY")
if not API_KEY:
    print("ERROR: IPUMS_API_KEY environment variable not set.")
    print("Set it in .env or export it before running.")
    sys.exit(1)

DATA_DIR = Path("data")
DATA_DIR.mkdir(exist_ok=True)

# ---- Variables for the 1910 extract ----
VARIABLES = [
    "YEAR",       # Census year
    "SERIAL",     # Household serial number
    "PERNUM",     # Person number within household
    "STATEFIP",   # State FIPS code
    "COUNTYICP",  # County code (ICPSR coding; COUNTYFIP not available in this sample)
    "URBAN",      # Urban/rural status
    "AGE",        # Age
    "SEX",        # Sex
    "RACE",       # Race
    "MARST",      # Marital status
    "NATIVITY",   # Nativity (native/foreign-born)
    "BPL",        # Birthplace
    "LIT",        # Literacy
    "SCHOOL",     # School attendance
    "OCC1950",    # Occupation (1950 classification)
    "LABFORCE",   # Labor force participation
    "OWNERSHP",   # Home ownership
    "RELATE",     # Relationship to household head
    "FAMSIZE",    # Family size
    "VETCIVWR",   # Civil War veteran status (Union/Confederate)
    "GQ",         # Group quarters status
]


def main():
    client = IpumsApiClient(API_KEY)

    print("=" * 70)
    print("IPUMS USA 1910 Census Extract Request")
    print("=" * 70)
    print("Sample: us1910l (1.4% oversampled 1910 census)")
    print(f"Variables: {len(VARIABLES)}")
    print()
    print("NOTE: Full-count (us1910m) lacks VETCIVWR. Using largest sample")
    print("      with Civil War veteran identification available.")
    print()

    # Submit extract
    print("--- Submitting extract ---")
    try:
        extract = MicrodataExtract(
            "usa",
            ["us1910l"],
            VARIABLES,
            description="1910 1.4% oversampled census with VETCIVWR for Civil War pension RDD",
        )
        submitted = client.submit_extract(extract)
        extract_id = submitted.extract_id if hasattr(submitted, 'extract_id') else submitted
        print(f"  Extract ID: {extract_id}")
    except Exception as e:
        print(f"  ERROR submitting extract: {e}")
        sys.exit(1)

    # Wait for completion
    print(f"\n  Waiting for extract (typically 5-30 minutes for 1.4% sample)...")
    try:
        client.wait_for_extract(submitted, collection="usa", timeout=7200)
    except Exception as e:
        print(f"\n  ERROR waiting for extract: {e}")
        sys.exit(1)

    status = client.extract_status(submitted, collection="usa")
    if status == "completed":
        print(f"\n  Extract ready! Downloading...")
        extract_dir = DATA_DIR / "1910_census"
        extract_dir.mkdir(exist_ok=True)
        client.download_extract(submitted, collection="usa", download_dir=str(extract_dir))

        for f in sorted(extract_dir.iterdir()):
            size_mb = f.stat().st_size / 1e6
            print(f"    {f.name}: {size_mb:.1f} MB")

        print("\nDone! Run 02_clean_data.R to process the data.")
    else:
        print(f"\n  ERROR: Extract has status: {status}")
        sys.exit(1)


if __name__ == "__main__":
    main()
