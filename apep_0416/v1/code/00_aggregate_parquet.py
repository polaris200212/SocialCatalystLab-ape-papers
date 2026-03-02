"""
00_aggregate_parquet.py — Pre-aggregate T-MSIS Parquet for R
Uses pyarrow (available on this system) with chunked reading to stay within memory.
"""

import pyarrow.parquet as pq
import pyarrow as pa
import csv
import os
from collections import defaultdict

SHARED_DATA = os.path.join("..", "..", "..", "..", "data", "medicaid_provider_spending")
DATA = os.path.join("..", "data")
os.makedirs(DATA, exist_ok=True)

parquet_path = os.path.join(SHARED_DATA, "tmsis.parquet")

def classify_hcpcs(code):
    if not code or len(code) == 0:
        return "CPT"
    first = code[0]
    if first == "H":
        return "BH"
    elif first in ("T", "S"):
        return "HCBS"
    return "CPT"

# Read in batches to avoid OOM
print("Reading Parquet in batches...")
pf = pq.ParquetFile(parquet_path)
total_rows = pf.metadata.num_rows
print(f"Total rows: {total_rows:,}")

# Aggregate: (npi, service_cat, month) -> {paid, claims, benes}
# Use dict-based aggregation for memory efficiency
agg = defaultdict(lambda: [0.0, 0, 0])  # paid, claims, benes

batch_size = 1_000_000
processed = 0

for batch in pf.iter_batches(batch_size=batch_size,
                              columns=["BILLING_PROVIDER_NPI_NUM", "HCPCS_CODE",
                                       "CLAIM_FROM_MONTH", "TOTAL_PAID",
                                       "TOTAL_CLAIMS", "TOTAL_UNIQUE_BENEFICIARIES"]):
    npis = batch.column("BILLING_PROVIDER_NPI_NUM").to_pylist()
    codes = batch.column("HCPCS_CODE").to_pylist()
    months = batch.column("CLAIM_FROM_MONTH").to_pylist()
    paid = batch.column("TOTAL_PAID").to_pylist()
    claims = batch.column("TOTAL_CLAIMS").to_pylist()
    benes = batch.column("TOTAL_UNIQUE_BENEFICIARIES").to_pylist()

    for i in range(len(npis)):
        cat = classify_hcpcs(codes[i])
        month_str = str(months[i])[:7]  # YYYY-MM
        key = (npis[i], cat, month_str)
        row = agg[key]
        row[0] += (paid[i] or 0)
        row[1] += (claims[i] or 0)
        row[2] += (benes[i] or 0)

    processed += len(npis)
    if processed % 10_000_000 == 0:
        print(f"  Processed {processed:,} / {total_rows:,} rows ({100*processed/total_rows:.1f}%), {len(agg):,} groups")

print(f"\nTotal groups: {len(agg):,}")

# Write CSV
out_path = os.path.join(DATA, "tmsis_agg_by_npi_cat_month.csv")
print(f"Writing to {out_path}...")

with open(out_path, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["npi", "service_cat", "month", "total_paid", "total_claims", "total_benes"])
    for (npi, cat, month), (paid, claims, benes) in agg.items():
        writer.writerow([npi, cat, month, f"{paid:.2f}", claims, benes])

file_size = os.path.getsize(out_path) / 1e6
print(f"Saved: {out_path} ({file_size:.1f} MB)")

# Summary by category
cat_totals = defaultdict(lambda: [0.0, 0, 0, set()])
for (npi, cat, month), (paid, claims, benes) in agg.items():
    ct = cat_totals[cat]
    ct[0] += paid
    ct[1] += claims
    ct[2] += benes
    ct[3].add(npi)

print("\nService Category Summary:")
print(f"{'Category':>10} {'Total Paid ($B)':>15} {'Total Claims (M)':>17} {'Unique NPIs':>12}")
for cat in sorted(cat_totals):
    ct = cat_totals[cat]
    print(f"{cat:>10} {ct[0]/1e9:>15.1f} {ct[1]/1e6:>17.1f} {len(ct[3]):>12,}")

print("\nDone!")
