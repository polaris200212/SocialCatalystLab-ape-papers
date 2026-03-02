#!/bin/bash
# Fast parallel QCEW data download
DATA_DIR="$(cd "$(dirname "$0")/../data" && pwd)"
mkdir -p "$DATA_DIR/qcew_cache"

echo "=== Parallel QCEW Download ==="

if [ -f "$DATA_DIR/qcew_raw.csv" ]; then
    echo "qcew_raw.csv already exists, skipping download."
    exit 0
fi

INDUSTRIES="10 51 5112 5415 52 23 44-45"
COUNT=0

download_one() {
    local yr=$1 qtr=$2 ind=$3 data_dir=$4
    local outfile="${data_dir}/qcew_cache/qcew_${yr}_q${qtr}_${ind}.csv"
    if [ ! -f "$outfile" ] || [ ! -s "$outfile" ]; then
        curl -s "https://data.bls.gov/cew/data/api/${yr}/${qtr}/industry/${ind}.csv" \
             --connect-timeout 30 --max-time 120 -o "$outfile" 2>/dev/null
    fi
}

export -f download_one

# Generate download commands and run in parallel
for yr in $(seq 2015 2024); do
  for qtr in 1 2 3 4; do
    for ind in $INDUSTRIES; do
      echo "$yr $qtr $ind $DATA_DIR"
      COUNT=$((COUNT + 1))
    done
  done
done | xargs -P 8 -L 1 bash -c 'download_one $0 $1 $2 $3'

echo "Download complete."
NFILES=$(ls "$DATA_DIR/qcew_cache/"*.csv 2>/dev/null | wc -l)
echo "Files: $NFILES / $COUNT"
echo "=== Done ==="
