"""Download NSPL postcode-to-LA mapping from ONS ArcGIS Feature Service.
Uses concurrent requests for speed. Output: ../data/nspl_lookup.csv
"""
import json, csv, urllib.request, time, sys, os
from concurrent.futures import ThreadPoolExecutor, as_completed

BASE_URL = ("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/"
            "NSPL_LATEST_UK/FeatureServer/0/query")
OUTPUT = os.path.join(os.path.dirname(__file__), "..", "data", "nspl_lookup.csv")
BATCH_SIZE = 2000
TOTAL = 2720556  # from returnCountOnly query
WORKERS = 10

def fetch_batch(offset):
    """Fetch one batch of NSPL records."""
    params = (f"?where=1=1&outFields=PCDS,LAD25CD&f=json"
              f"&resultRecordCount={BATCH_SIZE}&resultOffset={offset}")
    url = BASE_URL + params
    for attempt in range(5):
        try:
            req = urllib.request.Request(url)
            with urllib.request.urlopen(req, timeout=60) as resp:
                data = json.loads(resp.read())
            records = []
            for f in data.get("features", []):
                attrs = f.get("attributes", {})
                records.append((attrs.get("PCDS", ""), attrs.get("LAD25CD", "")))
            return records
        except Exception as e:
            if attempt == 4:
                print(f"  FAILED at offset {offset}: {e}", flush=True)
                return []
            time.sleep(1 * (attempt + 1))
    return []

def main():
    offsets = list(range(0, TOTAL, BATCH_SIZE))
    print(f"Downloading {TOTAL:,} NSPL records in {len(offsets)} batches "
          f"({WORKERS} workers)...", flush=True)

    all_records = []
    done = 0

    with ThreadPoolExecutor(max_workers=WORKERS) as executor:
        futures = {executor.submit(fetch_batch, off): off for off in offsets}
        for future in as_completed(futures):
            records = future.result()
            all_records.extend(records)
            done += 1
            if done % 100 == 0:
                print(f"  {done}/{len(offsets)} batches "
                      f"({len(all_records):,} records)", flush=True)

    print(f"Total records: {len(all_records):,}", flush=True)

    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    with open(OUTPUT, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["postcode", "la_code"])
        writer.writerows(all_records)

    print(f"Saved to {OUTPUT}", flush=True)

if __name__ == "__main__":
    main()
