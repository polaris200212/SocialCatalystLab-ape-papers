## 02b_construct_variables.R — Construct analysis variables from merged BTVote panel
## apep_0481: Gender, Electoral Pathway, and Party Discipline in the German Bundestag

source("00_packages.R")

data_dir <- "../data"
panel <- readRDS(file.path(data_dir, "panel_raw.rds"))

cat("=== Exploring variable coding ===\n\n")

## Check gender coding
## BTVote V2 has 'gender' in MP characteristics
## Need to determine: is 0=female/1=male or 0=male/1=female?
cat("Gender distribution:\n")
print(table(panel$gender, useNA = "always"))

## Check by looking at names — are there obviously male/female names?
cat("\nSample names by gender value:\n")
cat("Gender = 0:\n")
print(head(unique(panel[gender == 0, .(lastname, firstname)]), 10))
cat("\nGender = 1:\n")
print(head(unique(panel[gender == 1, .(lastname, firstname)]), 10))

## Check mandate coding
cat("\nMandate variable:\n")
print(table(panel$mandate, useNA = "always"))
cat("\nMandate detailed:\n")
print(table(panel$mandate_detailed, useNA = "always"))

## Check dualcand variable
cat("\nDual candidate:\n")
print(table(panel$dualcand, useNA = "always"))

## Check vote behavior
cat("\nVote behavior (vote_beh):\n")
print(table(panel$vote_beh, useNA = "always"))

## Check pre-computed deviation
cat("\nPre-computed vote_deviate:\n")
print(table(panel$vote_deviate, useNA = "always"))

## Check party/ppg variable
cat("\nParliamentary party group (ppg):\n")
print(head(sort(table(panel$ppg), decreasing = TRUE), 10))

## Check electoral periods
cat("\nElectoral periods (elecper):\n")
print(table(panel$elecper, useNA = "always"))

## Check free_vote variable
cat("\nFree vote indicator:\n")
print(table(panel$free_vote, useNA = "always"))

## Check vote_finalpassage
cat("\nFinal passage vote:\n")
print(table(panel$vote_finalpassage, useNA = "always"))

## Check policy area
cat("\nPolicy area (policy1):\n")
print(table(panel$policy1, useNA = "always"))

## Electoral safety
cat("\nElectoral safety (district):\n")
print(summary(panel$elecsafe_district))
cat("\nElectoral safety (list):\n")
print(summary(panel$elecsafe_list))
cat("\nElectoral safety (overall):\n")
print(summary(panel$elecsafe_overall))

## Closeness in district
cat("\nDistrict vote closeness:\n")
print(summary(panel$closeness_district))

## List position
cat("\nList position:\n")
print(summary(panel$listpos))

## Now construct analysis variables
cat("\n=== Constructing analysis variables ===\n\n")

## 1. Female indicator
## Based on name inspection and the known Bundestag gender ratio (~20-30% female),
## gender=0 should be the minority group if it represents female
## If 290K is gender=0 and 972K is gender=1, and female is ~23% historically,
## then gender=0 = female
n_0 <- sum(panel$gender == 0, na.rm = TRUE)
n_1 <- sum(panel$gender == 1, na.rm = TRUE)
pct_0 <- n_0 / (n_0 + n_1) * 100
cat(sprintf("Gender=0: %s (%.1f%%), Gender=1: %s (%.1f%%)\n",
            format(n_0, big.mark = ","), pct_0,
            format(n_1, big.mark = ","), 100 - pct_0))
cat("Historical female share of Bundestag: ~7-35% across periods\n")

## The smaller group should be female
if (pct_0 < 40) {
  panel[, female := as.integer(gender == 0)]
  cat("Mapping: gender=0 → female=1 (minority group)\n")
} else {
  panel[, female := as.integer(gender == 1)]
  cat("Mapping: gender=1 → female=1 (minority group)\n")
}

## Verify by period — female share should increase over time
cat("\nFemale share by period (should increase over time):\n")
period_gender <- panel[!is.na(female), .(
  pct_female = mean(female) * 100,
  n = .N
), by = elecper]
setorder(period_gender, elecper)
print(period_gender)

## 2. District mandate indicator
## mandate variable: need to check coding
## In BTVote: mandate = 1 means direct (district), mandate = 2 means list
## Or it could be 0/1
cat("\nMandate coding exploration:\n")
cat("mandate values: ", paste(sort(unique(panel$mandate[!is.na(panel$mandate)])), collapse = ", "), "\n")

## Check relationship between mandate and list variables
cat("\nCross-tab mandate × list:\n")
print(table(panel$mandate, panel$list, useNA = "always"))

## If mandate has values like 1 and 2:
## 1 = direct/district, 2 = list (standard BTVote coding)
if (all(unique(na.omit(panel$mandate)) %in% c(1, 2))) {
  panel[, district := as.integer(mandate == 1)]
  cat("Mapping: mandate=1 → district=1, mandate=2 → district=0 (list)\n")
} else if (all(unique(na.omit(panel$mandate)) %in% c(0, 1))) {
  ## If 0/1, check which is district vs list
  ## District members should be roughly equal to list members in German MMP
  n_m0 <- sum(panel$mandate == 0, na.rm = TRUE)
  n_m1 <- sum(panel$mandate == 1, na.rm = TRUE)
  cat(sprintf("mandate=0: %s, mandate=1: %s\n",
              format(n_m0, big.mark = ","), format(n_m1, big.mark = ",")))
  ## mandate=1 is typically "direct" in BTVote
  panel[, district := as.integer(mandate == 1)]
  cat("Mapping: mandate=1 → district=1, mandate=0 → district=0 (list)\n")
} else {
  cat("WARNING: Unexpected mandate values. Checking mandate_detailed...\n")
  print(table(panel$mandate_detailed, useNA = "always"))
}

## Verify: district share should be roughly 50% (half the seats are district)
cat(sprintf("\nDistrict share: %.1f%%\n",
            mean(panel$district, na.rm = TRUE) * 100))

## 3. Party-line deviation
## BTVote includes vote_deviate which is pre-computed
## vote_deviate = 1 if MP voted differently from majority of their parliamentary group
cat("\nUsing pre-computed vote_deviate as rebellion indicator:\n")
cat(sprintf("Rebellion rate: %.2f%%\n",
            mean(panel$vote_deviate == 1, na.rm = TRUE) * 100))

## Also construct our own for robustness
## vote_beh coding (from BTVote): 1=Yes, 2=No, 3=Abstain, 4=Present not voting, 0=Absent
## Compute party majority position and flag deviations
cat("\nComputing party majority position per vote...\n")

## Only use substantive votes (Yes/No/Abstain, exclude absent)
panel[, substantive_vote := vote_beh %in% c(1, 2, 3)]

## Compute party majority position for each vote
## Use PPG (parliamentary party group) as the party unit
party_majority <- panel[substantive_vote == TRUE, .(
  n_yes = sum(vote_beh == 1),
  n_no = sum(vote_beh == 2),
  n_abstain = sum(vote_beh == 3),
  n_total = .N
), by = .(ppg, vote_id)]

## Party line = plurality position
party_majority[, party_position := fifelse(
  n_yes >= n_no & n_yes >= n_abstain, 1L,
  fifelse(n_no >= n_yes & n_no >= n_abstain, 2L, 3L)
)]

## Party cohesion = share voting with majority
party_majority[, cohesion := pmax(n_yes, n_no, n_abstain) / n_total]

## Merge back
panel <- merge(panel, party_majority[, .(ppg, vote_id, party_position, cohesion)],
               by = c("ppg", "vote_id"), all.x = TRUE)

## Compute our own deviation indicator
panel[substantive_vote == TRUE, deviate_own := as.integer(vote_beh != party_position)]
panel[substantive_vote == FALSE, deviate_own := NA_integer_]

cat(sprintf("Our computed rebellion rate: %.2f%%\n",
            mean(panel$deviate_own == 1, na.rm = TRUE) * 100))
cat(sprintf("BTVote pre-computed rebellion rate: %.2f%%\n",
            mean(panel$vote_deviate == 1, na.rm = TRUE) * 100))

## 4. Strong party-line indicator (≥90% cohesion)
panel[, strong_partyline := as.integer(cohesion >= 0.90)]

## 5. Electoral safety
## Already numeric in the data

## 6. Seniority (number of prior periods)
panel[, seniority := as.integer(as.factor(elecper)) - 1]  # Rough proxy

## 7. Policy domain classification
## BTVote policy codes — map to categories
## Policy1: 1-19 using CAP coding (Comparative Agendas Project)
## "Feminine" issues: health (3), education (6), social welfare (13), civil rights/liberties (2)
## "Masculine" issues: defense (16), foreign trade (18), science/tech (17)
panel[, feminine_policy := as.integer(policy1 %in% c(2, 3, 6, 13))]
panel[, masculine_policy := as.integer(policy1 %in% c(15, 16, 17, 18))]

## 8. Whip removal (free vote)
## free_vote is already in the data
cat(sprintf("\nFree vote share: %.2f%% of all votes\n",
            mean(panel$free_vote == 1, na.rm = TRUE) * 100))

## 9. Government vs opposition
## Need to construct from cabinet parties
## cab_parties contains comma-separated party codes
## If MP's ppg is in cab_parties, they're in government
panel[, in_government := as.integer(grepl(ppg, cab_parties, fixed = TRUE))]

## Filter to analysis sample
cat("\n=== Constructing analysis sample ===\n\n")

## Drop observations with missing key variables
analysis <- panel[
  !is.na(female) &
  !is.na(district) &
  substantive_vote == TRUE &
  !is.na(deviate_own)
]
cat(sprintf("Analysis sample: %s observations\n",
            format(nrow(analysis), big.mark = ",")))

## Focus on post-1983 (when RCVs became frequent after Green entry)
## WP 10 started in 1983
analysis_post83 <- analysis[elecper >= 10]
cat(sprintf("Post-1983 sample: %s observations\n",
            format(nrow(analysis_post83), big.mark = ",")))

## Summary statistics
cat("\n=== Summary Statistics ===\n\n")
cat("By Gender:\n")
print(analysis_post83[, .(
  N = .N,
  N_MPs = uniqueN(id_de_parliament),
  rebellion_rate = mean(deviate_own) * 100,
  free_vote_share = mean(free_vote == 1) * 100
), by = .(Gender = fifelse(female == 1, "Female", "Male"))])

cat("\nBy Mandate Type:\n")
print(analysis_post83[, .(
  N = .N,
  N_MPs = uniqueN(id_de_parliament),
  rebellion_rate = mean(deviate_own) * 100,
  pct_female = mean(female) * 100
), by = .(Mandate = fifelse(district == 1, "District", "List"))])

cat("\nBy Gender × Mandate Type:\n")
print(analysis_post83[, .(
  N = .N,
  N_MPs = uniqueN(id_de_parliament),
  rebellion_rate = mean(deviate_own) * 100
), by = .(Gender = fifelse(female == 1, "Female", "Male"),
          Mandate = fifelse(district == 1, "District", "List"))])

cat("\nBy Party (top 6):\n")
top_parties <- names(head(sort(table(analysis_post83$ppg), decreasing = TRUE), 6))
print(analysis_post83[ppg %in% top_parties, .(
  N = .N,
  N_MPs = uniqueN(id_de_parliament),
  rebellion_rate = mean(deviate_own) * 100,
  pct_female = mean(female) * 100,
  pct_district = mean(district) * 100
), by = ppg])

## Save analysis datasets
saveRDS(analysis, file.path(data_dir, "analysis_full.rds"))
saveRDS(analysis_post83, file.path(data_dir, "analysis_post83.rds"))
cat(sprintf("\nSaved analysis datasets.\n"))
cat(sprintf("  Full: %s rows\n", format(nrow(analysis), big.mark = ",")))
cat(sprintf("  Post-1983: %s rows\n", format(nrow(analysis_post83), big.mark = ",")))
