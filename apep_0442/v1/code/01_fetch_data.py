#!/usr/bin/env python3
"""
01_fetch_data.py — Request and download 1910 census data from IPUMS USA API.

Uses ipumspy to submit an extract for the 1910 1% sample with variables
needed for the Civil War pension RDD analysis.

Usage:
    export IPUMS_API_KEY=your_key_here
    python3 code/01_fetch_data.py
"""

import os
import sys
import time
from pathlib import Path

try:
    from ipumspy import IpumsApiClient, UsaExtract
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

# ---- Define extract ----
# 1910 1% sample: us1910a
# Variables chosen for the Civil War pension RDD analysis
SAMPLES = ["us1910a"]

VARIABLES = [
    "YEAR",       # Census year
    "SERIAL",     # Household serial number
    "PERNUM",     # Person number within household
    "STATEFIP",   # State FIPS code
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
]

def main():
    client = IpumsApiClient(API_KEY)

    print("=" * 60)
    print("IPUMS USA Extract Request")
    print("=" * 60)
    print(f"Samples: {SAMPLES}")
    print(f"Variables: {len(VARIABLES)}")
    print()

    # Submit extract
    extract = UsaExtract(SAMPLES, VARIABLES)
    extract_id = client.submit_extract(extract)
    print(f"Extract submitted. ID: {extract_id}")

    # Poll for completion
    poll_interval = 30  # seconds
    max_wait = 3600     # 1 hour
    elapsed = 0

    while elapsed < max_wait:
        status = client.extract_status(extract_id)
        print(f"[{time.strftime('%H:%M:%S')}] Status: {status}")

        if status == "completed":
            print("\nExtract ready! Downloading...")
            client.download_extract(extract_id, str(DATA_DIR))
            print(f"Downloaded to {DATA_DIR}/")

            # List downloaded files
            for f in sorted(DATA_DIR.iterdir()):
                size_mb = f.stat().st_size / 1e6
                print(f"  {f.name}: {size_mb:.1f} MB")

            print("\nDone! Run 01b_load_data.R to process.")
            return

        elif status == "failed":
            print(f"\nERROR: Extract {extract_id} failed!")
            sys.exit(1)

        time.sleep(poll_interval)
        elapsed += poll_interval

    print(f"\nERROR: Timed out after {max_wait}s waiting for extract.")
    sys.exit(1)


if __name__ == "__main__":
    main()
