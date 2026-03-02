#!/bin/bash
# Poll IPUMS extract status and download when ready
cd /Users/dyanag/LOCAL_PROJECTS/auto-policy-evals
source .env

for ext_num in 196 195; do
  STATUS=$(Rscript -e "
    library(ipumsr)
    set_ipums_api_key('$IPUMS_API_KEY')
    info <- get_extract_info(paste0('usa:', $ext_num))
    cat(info\$status)
  " 2>/dev/null)
  
  echo "$(date '+%H:%M:%S') Extract $ext_num: $STATUS"
  
  if [ "$STATUS" = "completed" ]; then
    echo "Extract $ext_num is ready! Downloading..."
    Rscript -e "
      library(ipumsr)
      set_ipums_api_key('$IPUMS_API_KEY')
      download_extract(paste0('usa:', $ext_num), 
                       download_dir = 'output/apep_0469/v2/data/')
      cat('Download complete\n')
    " 2>&1
    echo "READY" > output/apep_0469/v2/data/extract_ready.flag
    exit 0
  fi
done

echo "Neither extract ready yet."
exit 1
