#!/bin/bash
# Poll IPUMS extracts and download when ready
cd /Users/dyanag/LOCAL_PROJECTS/auto-policy-evals
source .env

MAX_ATTEMPTS=120  # 120 * 60s = 2 hours
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  ATTEMPT=$((ATTEMPT + 1))
  
  for ext_num in 196 195; do
    STATUS=$(Rscript -e "
      library(ipumsr)
      set_ipums_api_key('$IPUMS_API_KEY')
      info <- get_extract_info(paste0('usa:', $ext_num))
      cat(info\$status)
    " 2>/dev/null)
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') [Attempt $ATTEMPT] Extract $ext_num: $STATUS"
    
    if [ "$STATUS" = "completed" ]; then
      echo "=== Extract $ext_num is READY! Downloading... ==="
      Rscript -e "
        library(ipumsr)
        set_ipums_api_key('$IPUMS_API_KEY')
        download_extract(paste0('usa:', $ext_num), 
                         download_dir = 'output/apep_0469/v2/data/')
        cat('Download complete!\n')
      " 2>&1
      echo "$ext_num" > output/apep_0469/v2/data/completed_extract.txt
      echo "READY" > output/apep_0469/v2/data/extract_ready.flag
      echo "=== Extract downloaded successfully ==="
      exit 0
    fi
  done
  
  sleep 60
done

echo "Timed out waiting for extracts after $MAX_ATTEMPTS attempts"
exit 1
