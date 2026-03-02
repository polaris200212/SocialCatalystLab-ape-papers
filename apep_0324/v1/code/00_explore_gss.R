library(gssr)
data(gss_all)

cat("=== GSS Cumulative Data ===\n")
cat("Observations:", nrow(gss_all), "\n")
cat("Years:", range(gss_all$year, na.rm=TRUE), "\n\n")

# Key attitude variables with sample sizes and year ranges
attitude_groups <- list(
  "Trust/Social Capital" = c("trust", "helpful", "fair"),
  "Meritocracy/Mobility" = c("getahead", "ophrdwrk", "opclss"),
  "Gender Roles" = c("fefam", "fepresch", "fechld", "fework"),
  "Crime/Justice" = c("natcrime", "courts", "cappun", "fear", "gunlaw"),
  "Government Spending" = c("natfare", "natheal", "nateduc", "natenvir", "natarms", "natcity", "natdrug", "natrace"),
  "Redistribution" = c("eqwlth", "helppoor", "helpnot", "taxrich"),
  "Drug Policy" = c("grass"),
  "Sexuality/Family" = c("homosex", "abany", "abnomore", "premarsx", "divlaw"),
  "Immigration" = c("letin1", "immameco", "immmass"),
  "Confidence in Institutions" = c("confinan", "conbus", "conlegis", "conjudge", "conarmy", "conmedic", "conpress", "contv", "coneduc", "consci"),
  "Race" = c("racdif1", "racdif2", "racdif3", "racdif4", "affrmact"),
  "Economic Outlook" = c("satfin", "finalter", "goodlife")
)

for (group_name in names(attitude_groups)) {
  cat(sprintf("\n--- %s ---\n", group_name))
  for (v in attitude_groups[[group_name]]) {
    if (v %in% names(gss_all)) {
      valid <- !is.na(gss_all[[v]])
      n_valid <- sum(valid)
      years_with <- sort(unique(gss_all$year[valid]))
      yr_range <- paste(range(years_with), collapse = "-")
      n_years <- length(years_with)
      cat(sprintf("  %-12s: %6d obs, %2d survey years (%s)\n", v, n_valid, n_years, yr_range))
    } else {
      cat(sprintf("  %-12s: NOT IN DATASET\n", v))
    }
  }
}

# Key outcome variables
cat("\n\n--- Economic Outcome Variables ---\n")
outcome_vars <- c("wrkstat", "rincome", "realinc", "prestg80", "hrs1", "hrs2",
                   "income", "realrinc", "sei10", "educ", "degree", "coninc")
for (v in outcome_vars) {
  if (v %in% names(gss_all)) {
    n_valid <- sum(!is.na(gss_all[[v]]))
    cat(sprintf("  %-12s: %6d obs\n", v, n_valid))
  } else {
    cat(sprintf("  %-12s: NOT IN DATASET\n", v))
  }
}

# Demographic controls
cat("\n--- Demographic Controls ---\n")
demo_vars <- c("age", "sex", "race", "educ", "marital", "childs", "born", "parborn",
               "maeduc", "paeduc", "region", "srcbelt", "size", "polviews", "partyid")
for (v in demo_vars) {
  if (v %in% names(gss_all)) {
    n_valid <- sum(!is.na(gss_all[[v]]))
    cat(sprintf("  %-12s: %6d obs\n", v, n_valid))
  }
}

# Check geographic detail
cat("\n--- Geographic Detail ---\n")
cat("Regions:\n")
print(table(gss_all$region, useNA = "ifany"))

# Check if there's any sub-region geography
geo_vars <- c("region", "srcbelt", "size", "xnorcsiz", "dwelling", "vstrat")
for (v in geo_vars) {
  if (v %in% names(gss_all)) {
    cat(sprintf("\n%s: %d unique values\n", v, length(unique(na.omit(gss_all[[v]])))))
  }
}

# Check trust variable in detail
cat("\n\n--- Trust Variable Detail ---\n")
cat("Distribution:\n")
print(table(gss_all$trust, useNA = "ifany"))
cat("\nBy decade:\n")
gss_all$decade <- floor(gss_all$year / 10) * 10
trust_tab <- table(gss_all$decade, gss_all$trust)
print(round(prop.table(trust_tab, 1) * 100, 1))
