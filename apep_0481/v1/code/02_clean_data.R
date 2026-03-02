## 02_clean_data.R — Clean and merge BTVote V2 datasets
## apep_0481: Gender, Electoral Pathway, and Party Discipline in the German Bundestag

source("00_packages.R")

data_dir <- "../data"

cat("=== Loading BTVote V2 datasets ===\n\n")

## 1. Voting behavior (individual vote records) — V2 (1949-2021)
cat("Loading voting behavior (V2)...\n")
voting <- haven::read_dta(file.path(data_dir, "voting", "voting_behavior_V2_19492021.dta"))
voting <- as.data.table(voting)
cat(sprintf("  Rows: %s | Cols: %d\n", format(nrow(voting), big.mark = ","), ncol(voting)))
cat(sprintf("  Columns: %s\n", paste(names(voting), collapse = ", ")))

## 2. MP characteristics — V2 (tab-delimited)
cat("\nLoading MP characteristics (V2)...\n")
mps <- fread(file.path(data_dir, "mps", "mp_characteristics_V2_19492021.tab"),
             sep = "\t", header = TRUE, encoding = "Latin-1")
cat(sprintf("  Rows: %s | Cols: %d\n", format(nrow(mps), big.mark = ","), ncol(mps)))
cat(sprintf("  Columns: %s\n", paste(names(mps), collapse = ", ")))

## 3. Vote characteristics — V2 (tab-delimited)
cat("\nLoading vote characteristics (V2)...\n")
votes <- fread(file.path(data_dir, "votes", "vote_characteristics_V2_19492021.tab"),
               sep = "\t", header = TRUE, encoding = "Latin-1")
cat(sprintf("  Rows: %s | Cols: %d\n", format(nrow(votes), big.mark = ","), ncol(votes)))
cat(sprintf("  Columns: %s\n", paste(names(votes), collapse = ", ")))

## Explore key variables
cat("\n=== Key Variable Summary ===\n\n")

## Gender distribution
if ("female" %in% names(mps)) {
  cat("Gender (MP characteristics):\n")
  print(table(mps$female, useNA = "always"))
} else {
  cat("Gender variable names in MP data: ")
  cat(paste(grep("fem|sex|gend|geschl", names(mps), value = TRUE, ignore.case = TRUE), collapse = ", "), "\n")
}

## Mandate type
mandate_vars <- grep("mand|list|direct|direkt|wahlkreis|type", names(mps),
                     value = TRUE, ignore.case = TRUE)
cat("\nMandate-related variables: ", paste(mandate_vars, collapse = ", "), "\n")
for (v in mandate_vars) {
  cat(sprintf("\n  %s:\n", v))
  print(table(mps[[v]], useNA = "always"))
}

## Vote variables
cat("\nVote choice variable in voting data: ")
vote_vars <- grep("vote|stimme|ja|nein", names(voting), value = TRUE, ignore.case = TRUE)
cat(paste(vote_vars, collapse = ", "), "\n")
for (v in vote_vars[1:min(3, length(vote_vars))]) {
  cat(sprintf("\n  %s:\n", v))
  print(table(voting[[v]], useNA = "always"))
}

## Party variable
party_vars <- grep("party|partei|frak", names(mps), value = TRUE, ignore.case = TRUE)
cat("\nParty variables: ", paste(party_vars, collapse = ", "), "\n")

## Legislative period
period_vars <- grep("period|wp|wahlperiode|leg", names(mps), value = TRUE, ignore.case = TRUE)
cat("Period variables: ", paste(period_vars, collapse = ", "), "\n")

## Merge key
cat("\n=== Finding merge keys ===\n")
cat("Voting columns: ", paste(names(voting), collapse = ", "), "\n")
cat("MP columns: ", paste(names(mps), collapse = ", "), "\n")
cat("Vote columns: ", paste(names(votes), collapse = ", "), "\n")

## Identify common merge keys
common_voting_mp <- intersect(names(voting), names(mps))
common_voting_vote <- intersect(names(voting), names(votes))
cat("\nCommon keys (voting-MP): ", paste(common_voting_mp, collapse = ", "), "\n")
cat("Common keys (voting-votes): ", paste(common_voting_vote, collapse = ", "), "\n")

## Save exploration results for inspection
cat("\n=== Saving column lists ===\n")
col_info <- list(
  voting_cols = names(voting),
  mp_cols = names(mps),
  vote_cols = names(votes),
  common_voting_mp = common_voting_mp,
  common_voting_vote = common_voting_vote
)
saveRDS(col_info, file.path(data_dir, "column_info.rds"))

## Now do the actual merge
cat("\n=== Merging datasets ===\n")

## Identify the MP-level merge key
## BTVote uses mp_id as the legislator identifier
mp_key <- intersect(names(voting), names(mps))
mp_key <- mp_key[!mp_key %in% c("wp")]  # Keep wp as a dimension, not just merge key
cat("MP merge key(s): ", paste(mp_key, collapse = ", "), "\n")

## Vote-level merge key
vote_key <- intersect(names(voting), names(votes))
cat("Vote merge key(s): ", paste(vote_key, collapse = ", "), "\n")

## Merge voting behavior with MP characteristics
panel <- merge(voting, mps, by = intersect(names(voting), names(mps)),
               all.x = TRUE)
cat(sprintf("After MP merge: %s rows\n", format(nrow(panel), big.mark = ",")))

## Merge with vote characteristics
panel <- merge(panel, votes, by = intersect(names(panel), names(votes)),
               all.x = TRUE)
cat(sprintf("After vote merge: %s rows\n", format(nrow(panel), big.mark = ",")))

## Explore the merged data structure
cat("\n=== Merged Data Structure ===\n")
cat(sprintf("Total observations: %s\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("Total columns: %d\n", ncol(panel)))
cat(sprintf("Unique MPs: %d\n", uniqueN(panel, by = intersect(c("mp_id", "id_mp"),
                                                                names(panel)))))
cat(sprintf("Unique votes: %d\n", uniqueN(panel, by = intersect(c("vote_id", "id_vote"),
                                                                   names(panel)))))
cat(sprintf("Legislative periods: %s\n",
            paste(sort(unique(panel$wp)), collapse = ", ")))

## Save the full column listing for next script
cat("\nFull merged column list:\n")
for (col in names(panel)) {
  cat(sprintf("  %-30s class=%-12s NAs=%d\n",
              col, class(panel[[col]])[1], sum(is.na(panel[[col]]))))
}

## Construct key analysis variables

## Identify the actual variable names by pattern matching
female_var <- grep("^female$|^sex$|^gender$|^geschlecht$", names(panel),
                   value = TRUE, ignore.case = TRUE)
mandate_var <- grep("^mandate$|^mandate_type$|^mandatsart$|^direct$|^list$",
                    names(panel), value = TRUE, ignore.case = TRUE)
vote_var <- grep("^vote$|^vote_decision$|^abstimmung$|^decision$",
                 names(panel), value = TRUE, ignore.case = TRUE)
party_var <- grep("^party$|^party_short$|^partei$|^fraktion$",
                  names(panel), value = TRUE, ignore.case = TRUE)

cat("\n=== Variable mapping ===\n")
cat("Female var: ", paste(female_var, collapse = ", "), "\n")
cat("Mandate var: ", paste(mandate_var, collapse = ", "), "\n")
cat("Vote var: ", paste(vote_var, collapse = ", "), "\n")
cat("Party var: ", paste(party_var, collapse = ", "), "\n")

## Standardize variable names
## We'll use the first match for each
if (length(female_var) > 0) {
  panel[, female := as.integer(get(female_var[1]))]
  cat(sprintf("\nFemale distribution:\n"))
  print(table(panel$female, useNA = "always"))
}

if (length(mandate_var) > 0) {
  panel[, mandate_raw := get(mandate_var[1])]
  cat(sprintf("\nMandate type distribution:\n"))
  print(table(panel$mandate_raw, useNA = "always"))
  ## Create binary: district = 1, list = 0
  ## Need to inspect actual values first
}

if (length(vote_var) > 0) {
  panel[, vote_raw := get(vote_var[1])]
  cat(sprintf("\nVote distribution:\n"))
  print(table(panel$vote_raw, useNA = "always"))
}

if (length(party_var) > 0) {
  panel[, party := get(party_var[1])]
  cat(sprintf("\nParty distribution:\n"))
  print(head(sort(table(panel$party), decreasing = TRUE), 10))
}

## Save merged but not yet fully cleaned data
saveRDS(panel, file.path(data_dir, "panel_raw.rds"))
cat(sprintf("\nSaved raw panel: %s rows to %s\n",
            format(nrow(panel), big.mark = ","),
            file.path(data_dir, "panel_raw.rds")))
