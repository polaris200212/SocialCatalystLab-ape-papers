###############################################################################
# 06_tables.R — Publication-quality LaTeX tables
# Paper: Divine Forgiveness Beliefs (apep_0218)
###############################################################################

source("00_packages.R")
library(sandwich)
library(lmtest)

data_dir <- "../data"
tab_dir  <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

###############################################################################
# Load all cleaned datasets
###############################################################################
cat("Loading datasets...\n")
gss    <- readRDS(file.path(data_dir, "gss_clean.rds"))
ea     <- readRDS(file.path(data_dir, "ea_clean.rds"))
sccs   <- readRDS(file.path(data_dir, "sccs_clean.rds"))
sccs_hg <- readRDS(file.path(data_dir, "sccs_highgods.rds"))
pulotu <- readRDS(file.path(data_dir, "pulotu_clean.rds"))
pul_q  <- readRDS(file.path(data_dir, "pulotu_questions.rds"))
seshat <- readRDS(file.path(data_dir, "seshat_clean.rds"))
fred   <- readRDS(file.path(data_dir, "fred_annual.rds"))

###############################################################################
# Table 1: Summary Statistics (tab_summary_stats.tex)
###############################################################################
cat("\n=== Table 1: Summary Statistics ===\n")

# --- Panel A: GSS individual-level ---
gss_vars_list <- list(
  "Heaven belief (1=yes)"       = gss$heaven,
  "Hell belief (1=yes)"         = gss$hell,
  "Afterlife belief (1=yes)"    = gss$afterlif,
  "Coping through God (1--4)"   = gss$cope4,
  "Forgiveness of God (1--4)"   = gss$forgive3,
  "God as judge (1--4)"         = gss$judge,
  "Age"                         = gss$age_num,
  "Female (1=yes)"              = gss$female,
  "Education (years)"           = gss$educ_num,
  "Real income (\\$)"           = gss$realinc_num,
  "Attendance (0--8)"           = gss$attend_num
)

panel_a <- do.call(rbind, lapply(names(gss_vars_list), function(nm) {
  x <- gss_vars_list[[nm]]
  x <- x[!is.na(x)]
  data.frame(
    Variable = nm,
    N        = length(x),
    Mean     = mean(x),
    SD       = sd(x),
    Min      = min(x),
    Max      = max(x),
    stringsAsFactors = FALSE
  )
}))

# --- Panel B: Cross-cultural datasets ---

# EA: societies by high gods category
ea_valid <- ea %>% filter(!is.na(high_gods_label))
ea_n_total <- nrow(ea_valid)
ea_by_cat <- ea_valid %>%
  count(high_gods_label) %>%
  mutate(pct = n / sum(n) * 100)

# SCCS: societies by high gods category
sccs_hg_tab <- sccs_hg %>%
  mutate(
    hg_cat = case_when(
      grepl("absent", Description, ignore.case = TRUE) ~ "Absent",
      grepl("otiose", Description, ignore.case = TRUE) ~ "Otiose",
      grepl("not.*moral|not offering", Description, ignore.case = TRUE) ~ "Active, not moralizing",
      grepl("supportive.*moral", Description, ignore.case = TRUE) ~ "Active, moralizing",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(hg_cat)) %>%
  count(hg_cat) %>%
  mutate(pct = n / sum(n) * 100)

# Pulotu: cultures with supernatural punishment data
pul_sp <- pulotu %>% filter(!is.na(`7`))
pul_sp_yes <- sum(pul_sp[["7"]] == 1, na.rm = TRUE)
pul_sp_no  <- sum(pul_sp[["7"]] == 0, na.rm = TRUE)

# Seshat: polity-periods
seshat_n <- nrow(seshat)
seshat_nga <- length(unique(seshat$NGA))
seshat_msp_mean <- mean(seshat$MSP_sum, na.rm = TRUE)

# Fill any missing categories with 0 before building panel B
for (cat_name in c("Absent", "Otiose", "Active, not moralizing", "Active, moralizing")) {
  if (!(cat_name %in% ea_by_cat$high_gods_label)) {
    ea_by_cat <- bind_rows(ea_by_cat, data.frame(high_gods_label = cat_name, n = 0L, pct = 0))
  }
  if (!(cat_name %in% sccs_hg_tab$hg_cat)) {
    sccs_hg_tab <- bind_rows(sccs_hg_tab, data.frame(hg_cat = cat_name, n = 0L, pct = 0))
  }
}

# Rebuild panel_b_rows with safe lookups
safe_ea <- function(cat) {
  val <- ea_by_cat$n[ea_by_cat$high_gods_label == cat]
  if (length(val) == 0) 0L else val
}
safe_sccs <- function(cat) {
  val <- sccs_hg_tab$n[sccs_hg_tab$hg_cat == cat]
  if (length(val) == 0) 0L else val
}

# Compute percentages for EA and SCCS categories
safe_ea_pct <- function(cat) {
  val <- ea_by_cat$pct[ea_by_cat$high_gods_label == cat]
  if (length(val) == 0) 0 else val
}
safe_sccs_pct <- function(cat) {
  val <- sccs_hg_tab$pct[sccs_hg_tab$hg_cat == cat]
  if (length(val) == 0) 0 else val
}

pul_total <- pul_sp_yes + pul_sp_no
pul_sp_yes_pct <- if (pul_total > 0) 100 * pul_sp_yes / pul_total else 0
pul_sp_no_pct  <- if (pul_total > 0) 100 * pul_sp_no / pul_total else 0

panel_b_rows <- data.frame(
  Variable = c(
    "EA: Absent high god",
    "EA: Otiose high god",
    "EA: Active, not moralizing",
    "EA: Active, moralizing",
    "",
    "SCCS: Absent high god",
    "SCCS: Otiose high god",
    "SCCS: Active, not moralizing",
    "SCCS: Active, moralizing",
    "",
    "Pulotu: Supernatural punishment present",
    "Pulotu: Supernatural punishment absent",
    "",
    "Seshat: Polity-periods (mean MSP)",
    "Seshat: Unique NGAs"
  ),
  N = c(
    safe_ea("Absent"), safe_ea("Otiose"),
    safe_ea("Active, not moralizing"), safe_ea("Active, moralizing"),
    NA,
    safe_sccs("Absent"), safe_sccs("Otiose"),
    safe_sccs("Active, not moralizing"), safe_sccs("Active, moralizing"),
    NA,
    pul_sp_yes, pul_sp_no,
    NA,
    seshat_n, seshat_nga
  ),
  Pct = c(
    safe_ea_pct("Absent"), safe_ea_pct("Otiose"),
    safe_ea_pct("Active, not moralizing"), safe_ea_pct("Active, moralizing"),
    NA,
    safe_sccs_pct("Absent"), safe_sccs_pct("Otiose"),
    safe_sccs_pct("Active, not moralizing"), safe_sccs_pct("Active, moralizing"),
    NA,
    pul_sp_yes_pct, pul_sp_no_pct,
    NA,
    seshat_msp_mean, NA
  ),
  stringsAsFactors = FALSE
)

# Compose the full LaTeX table
tab1_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics}",
  "\\label{tab:summary_stats}",
  "\\begin{tabular}{lrrrrrr}",
  "\\toprule",
  "& $N$ & Mean & SD & Min & Max \\\\",
  "\\midrule",
  "\\multicolumn{6}{l}{\\textit{Panel A: GSS Individual-Level Variables}} \\\\",
  "\\addlinespace"
)

for (i in seq_len(nrow(panel_a))) {
  row <- panel_a[i, ]
  # Format income differently (no decimals, with comma)
  if (grepl("income", row$Variable, ignore.case = TRUE)) {
    tab1_lines <- c(tab1_lines, sprintf(
      "\\quad %s & %s & %s & %s & %s & %s \\\\",
      row$Variable,
      formatC(row$N, format = "d", big.mark = ","),
      formatC(row$Mean, format = "f", digits = 0, big.mark = ","),
      formatC(row$SD, format = "f", digits = 0, big.mark = ","),
      formatC(row$Min, format = "f", digits = 0, big.mark = ","),
      formatC(row$Max, format = "f", digits = 0, big.mark = ",")
    ))
  } else {
    tab1_lines <- c(tab1_lines, sprintf(
      "\\quad %s & %s & %s & %s & %s & %s \\\\",
      row$Variable,
      formatC(row$N, format = "d", big.mark = ","),
      formatC(row$Mean, format = "f", digits = 2),
      formatC(row$SD, format = "f", digits = 2),
      formatC(row$Min, format = "f", digits = 0),
      formatC(row$Max, format = "f", digits = 0)
    ))
  }
}

tab1_lines <- c(tab1_lines,
  "\\addlinespace",
  "\\midrule",
  "\\multicolumn{6}{l}{\\textit{Panel B: Cross-Cultural Datasets}} \\\\",
  "\\addlinespace",
  "& \\multicolumn{1}{c}{$N$} & \\multicolumn{1}{c}{\\%} & & & \\\\",
  "\\addlinespace"
)

for (i in seq_len(nrow(panel_b_rows))) {
  row <- panel_b_rows[i, ]
  if (row$Variable == "") {
    tab1_lines <- c(tab1_lines, "\\addlinespace")
  } else {
    n_str <- if (is.na(row$N)) "" else formatC(row$N, format = "d", big.mark = ",")
    pct_str <- if (is.na(row$Pct)) "---" else sprintf("%.1f", row$Pct)
    tab1_lines <- c(tab1_lines, sprintf(
      "\\quad %s & %s & %s & & & \\\\",
      row$Variable, n_str, pct_str
    ))
  }
}

tab1_lines <- c(tab1_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]\\footnotesize",
  "\\item \\textit{Notes:} Panel A reports individual-level summary statistics from the General Social Survey (GSS, 1972--2024). Belief variables are binary (1 = yes definitely/probably). Cope4 measures reliance on God for coping (1 = not at all, 4 = a great deal). Forgive3 measures belief in divine forgiveness (1 = strongly agree, 4 = strongly disagree). God as judge is rated 1--4 (1 = extremely well describes God). Real income includes all non-zero positive values from the GSS \\texttt{realinc} variable (constant-dollar family income); the minimum of \\$182 reflects respondents at the bottom of the income distribution. Panel B reports society/polity counts and within-dataset percentages from cross-cultural databases.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab1_lines, file.path(tab_dir, "tab_summary_stats.tex"))
cat("Saved tab_summary_stats.tex\n")


###############################################################################
# Table 2: Belief Rates by Religious Tradition (tab_gss_beliefs_religion.tex)
###############################################################################
cat("\n=== Table 2: Beliefs by Religion ===\n")

# Filter to years where these variables were asked
gss_belief <- gss %>%
  filter(!is.na(relig_cat)) %>%
  select(relig_cat, heaven, hell, afterlif, judge)

# Compute cross-tabulation
relig_order <- c("Protestant", "Catholic", "Jewish", "Other", "None")

belief_by_relig <- gss_belief %>%
  filter(relig_cat %in% relig_order) %>%
  mutate(relig_cat = factor(relig_cat, levels = relig_order)) %>%
  group_by(relig_cat) %>%
  summarize(
    N_total     = n(),
    N_heaven    = sum(!is.na(heaven)),
    pct_heaven  = mean(heaven, na.rm = TRUE) * 100,
    N_hell      = sum(!is.na(hell)),
    pct_hell    = mean(hell, na.rm = TRUE) * 100,
    N_afterlife = sum(!is.na(afterlif)),
    pct_afterlife = mean(afterlif, na.rm = TRUE) * 100,
    N_judge     = sum(!is.na(judge)),
    mean_judge  = mean(judge, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  # Module-specific N: max of respondents across belief items (not total GSS N)
  mutate(N_module = pmax(N_heaven, N_hell, N_afterlife, N_judge))

# Chi-square tests
chisq_heaven <- tryCatch({
  tbl <- table(gss_belief$relig_cat, gss_belief$heaven)
  chisq.test(tbl)$p.value
}, error = function(e) NA)

chisq_hell <- tryCatch({
  tbl <- table(gss_belief$relig_cat, gss_belief$hell)
  chisq.test(tbl)$p.value
}, error = function(e) NA)

chisq_afterlife <- tryCatch({
  tbl <- table(gss_belief$relig_cat, gss_belief$afterlif)
  chisq.test(tbl)$p.value
}, error = function(e) NA)

# For judge, use ANOVA (continuous 1-4)
anova_judge <- tryCatch({
  fit <- aov(judge ~ relig_cat, data = gss_belief)
  summary(fit)[[1]][["Pr(>F)"]][1]
}, error = function(e) NA)

format_p <- function(p) {
  if (is.na(p)) return("---")
  if (p < 0.001) return("$<$0.001")
  sprintf("%.3f", p)
}

tab2_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Afterlife Beliefs and God Image by Religious Tradition (GSS)}",
  "\\label{tab:beliefs_religion}",
  "\\begin{tabular}{lrcccc}",
  "\\toprule",
  "& & Heaven & Hell & Afterlife & God as \\\\",
  "Religious Tradition & $N$ & (\\% yes) & (\\% yes) & (\\% yes) & Judge (mean) \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(belief_by_relig))) {
  r <- belief_by_relig[i, ]
  tab2_lines <- c(tab2_lines, sprintf(
    "%s & %s & %s & %s & %s & %s \\\\",
    as.character(r$relig_cat),
    formatC(r$N_module, format = "d", big.mark = ","),
    if (r$N_heaven > 0) sprintf("%.1f (%s)", r$pct_heaven, formatC(r$N_heaven, format = "d", big.mark = ",")) else "---",
    if (r$N_hell > 0) sprintf("%.1f (%s)", r$pct_hell, formatC(r$N_hell, format = "d", big.mark = ",")) else "---",
    if (r$N_afterlife > 0) sprintf("%.1f (%s)", r$pct_afterlife, formatC(r$N_afterlife, format = "d", big.mark = ",")) else "---",
    if (r$N_judge > 0) sprintf("%.2f (%s)", r$mean_judge, formatC(r$N_judge, format = "d", big.mark = ",")) else "---"
  ))
}

tab2_lines <- c(tab2_lines,
  "\\midrule",
  sprintf("$\\chi^2$ / $F$-test $p$-value & & %s & %s & %s & %s \\\\",
          format_p(chisq_heaven), format_p(chisq_hell),
          format_p(chisq_afterlife), format_p(anova_judge)),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]\\footnotesize",
  "\\item \\textit{Notes:} $N$ reports the maximum number of module respondents across belief items for each tradition. Percentages report the share affirming each belief (yes definitely or yes probably) with the item-specific non-missing $N$ in parentheses. God as judge is the mean response on a 1--4 scale (1 = extremely well describes God, 4 = not at all). $\\chi^2$ tests assess independence of belief and religious tradition; $F$-test for God as judge (ANOVA). Data: GSS cumulative file 1972--2024; belief modules administered in selected years only.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab2_lines, file.path(tab_dir, "tab_gss_beliefs_religion.tex"))
cat("Saved tab_gss_beliefs_religion.tex\n")


###############################################################################
# Table 3: GSS OLS Regressions (tab_gss_regressions.tex)
###############################################################################
cat("\n=== Table 3: GSS Regressions ===\n")

# Prepare regression sample
gss_reg <- gss %>%
  mutate(
    log_income = ifelse(realinc_num > 0, log(realinc_num), NA_real_),
    relig_cat  = factor(relig_cat, levels = c("Protestant", "Catholic", "Jewish", "Other", "None"))
  ) %>%
  filter(
    !is.na(age_num) & !is.na(female) & !is.na(college) &
    !is.na(log_income) & !is.na(attend_num) & !is.na(relig_cat)
  )

# Run regressions
formula_base <- "~ age_num + female + college + log_income + attend_num + relig_cat"

models <- list()

# (1) Heaven
if (sum(!is.na(gss_reg$heaven)) > 100) {
  models[["Heaven"]] <- lm(as.formula(paste("heaven", formula_base)), data = gss_reg)
}

# (2) Hell
if (sum(!is.na(gss_reg$hell)) > 100) {
  models[["Hell"]] <- lm(as.formula(paste("hell", formula_base)), data = gss_reg)
}

# (3) Afterlife
if (sum(!is.na(gss_reg$afterlif)) > 100) {
  models[["Afterlife"]] <- lm(as.formula(paste("afterlif", formula_base)), data = gss_reg)
}

# (4) Forgiveness (forgive3)
if (sum(!is.na(gss_reg$forgive3)) > 100) {
  models[["Forgive"]] <- lm(as.formula(paste("forgive3", formula_base)), data = gss_reg)
}

# (5) Coping (cope4)
if (sum(!is.na(gss_reg$cope4)) > 100) {
  models[["Cope"]] <- lm(as.formula(paste("cope4", formula_base)), data = gss_reg)
}

# Covariate mapping for clean labels
cm <- c(
  "age_num"         = "Age",
  "female"          = "Female",
  "college"         = "College degree",
  "log_income"      = "Log(real income)",
  "attend_num"      = "Religious attendance",
  "relig_catCatholic" = "Catholic",
  "relig_catJewish" = "Jewish",
  "relig_catOther"  = "Other religion",
  "relig_catNone"   = "No religion",
  "(Intercept)"     = "Constant"
)

# Use modelsummary
gof_map <- list(
  list("raw" = "nobs",      "clean" = "$N$",     "fmt" = function(x) formatC(x, format = "d", big.mark = ",")),
  list("raw" = "r.squared", "clean" = "$R^2$",   "fmt" = function(x) sprintf("%.3f", x)),
  list("raw" = "adj.r.squared", "clean" = "Adj. $R^2$", "fmt" = function(x) sprintf("%.3f", x))
)

if (length(models) > 0) {
  # Use stargazer for reliable LaTeX output with booktabs
  reg_file <- file.path(tab_dir, "tab_gss_regressions.tex")

  # Rename models for column headers
  model_list <- unname(models)

  # Compute heteroskedasticity-robust standard errors (HC1)
  robust_ses <- lapply(model_list, function(m) sqrt(diag(vcovHC(m, type = "HC1"))))

  stargazer(
    model_list,
    type = "latex",
    out = reg_file,
    se = robust_ses,
    title = "OLS Regressions: Determinants of Divine Belief and Forgiveness (GSS)",
    label = "tab:gss_regressions",
    dep.var.labels = names(models),
    covariate.labels = c(
      "Age", "Female", "College degree", "Log(real income)",
      "Religious attendance",
      "Catholic", "Jewish", "Other religion", "No religion"
    ),
    omit.stat = c("f", "ser"),
    digits = 3,
    digits.extra = 0,
    column.sep.width = "3pt",
    float.env = "table",
    table.placement = "htbp",
    style = "aer",
    notes = c(
      "Heteroskedasticity-robust standard errors in parentheses.",
      "Reference category: Protestant.",
      "Heaven, Hell, and Afterlife are binary (1 = yes definitely/probably); positive coeff. = more belief.",
      "Forgive: 1 = strongly agree God forgives, 4 = strongly disagree; positive coeff. = less forgiveness.",
      "Cope: 1 = a great deal punished by God, 4 = not applicable; positive coeff. = less punishment."
    ),
    notes.align = "l",
    notes.append = FALSE
  )
  cat("Saved tab_gss_regressions.tex\n")
} else {
  cat("WARNING: No regression models had sufficient observations.\n")
}


###############################################################################
# Table 4: EA034 High Gods by World Region (tab_ea_region.tex)
###############################################################################
cat("\n=== Table 4: EA High Gods by Region ===\n")

# Aggregate fine-grained regions into broader world regions
ea_region <- ea %>%
  filter(!is.na(high_gods_label)) %>%
  mutate(
    world_region = case_when(
      grepl("Africa|Macaronesia", region, ignore.case = TRUE) ~ "Africa",
      grepl("Europe|Caucasus", region, ignore.case = TRUE)    ~ "Europe",
      grepl("Asia|China|Mongolia|Indo-China|Malesia|Siberia|Far East|Indian|Arabian",
            region, ignore.case = TRUE) ~ "Asia",
      grepl("Australia|Pacific|New Zealand|Papuasia", region, ignore.case = TRUE) ~ "Oceania",
      grepl("U\\.S\\.A|Canada|Subarctic America", region, ignore.case = TRUE) ~ "North America",
      grepl("Mexico|Central America|Caribbean", region, ignore.case = TRUE) ~ "Central America/Caribbean",
      grepl("South America|Brazil", region, ignore.case = TRUE) ~ "South America",
      TRUE ~ "Other"
    )
  )

# Cross-tabulation
ea_cross <- ea_region %>%
  count(world_region, high_gods_label) %>%
  group_by(world_region) %>%
  mutate(
    total = sum(n),
    pct   = n / total * 100
  ) %>%
  ungroup()

# Get all categories and regions
hg_cats <- c("Absent", "Otiose", "Active, not moralizing", "Active, moralizing")
regions_order <- c("Africa", "Asia", "Europe", "North America",
                   "Central America/Caribbean", "South America", "Oceania", "Other")
regions_present <- intersect(regions_order, unique(ea_cross$world_region))

# Build table
tab4_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{High Gods (EA034) Distribution by World Region}",
  "\\label{tab:ea_region}",
  "\\begin{tabular}{lrrrrrr}",
  "\\toprule",
  "& \\multicolumn{4}{c}{High Gods Category} & & \\\\",
  "\\cmidrule(lr){2-5}",
  "Region & Absent & Otiose & \\shortstack{Active, not\\\\moralizing} & \\shortstack{Active,\\\\moralizing} & Total & \\\\",
  "\\midrule"
)

for (reg in regions_present) {
  reg_data <- ea_cross %>% filter(world_region == reg)
  total_reg <- sum(reg_data$n)
  vals <- sapply(hg_cats, function(cat) {
    row <- reg_data %>% filter(high_gods_label == cat)
    if (nrow(row) == 0) return("0 (0.0)")
    sprintf("%d (%.1f)", row$n, row$pct)
  })
  tab4_lines <- c(tab4_lines, sprintf(
    "%s & %s & %s & %s & %s & %d & \\\\",
    reg, vals[1], vals[2], vals[3], vals[4], total_reg
  ))
}

# Total row
total_by_cat <- ea_region %>%
  count(high_gods_label) %>%
  mutate(pct = n / sum(n) * 100)
grand_total <- sum(total_by_cat$n)

total_vals <- sapply(hg_cats, function(cat) {
  row <- total_by_cat %>% filter(high_gods_label == cat)
  if (nrow(row) == 0) return("0 (0.0)")
  sprintf("%d (%.1f)", row$n, row$pct)
})

tab4_lines <- c(tab4_lines,
  "\\midrule",
  sprintf("Total & %s & %s & %s & %s & %d & \\\\",
          total_vals[1], total_vals[2], total_vals[3], total_vals[4], grand_total),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]\\footnotesize",
  "\\item \\textit{Notes:} Cell entries show count (row percentage). EA034 codes: Absent = no high god reported; Otiose = present but not concerned with humans; Active, not moralizing = active in human affairs but not enforcing morality; Active, moralizing = active and specifically supportive of human morality. Societies with missing EA034 excluded. Data: D-PLACE Ethnographic Atlas.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab4_lines, file.path(tab_dir, "tab_ea_region.tex"))
cat("Saved tab_ea_region.tex\n")


###############################################################################
# Table 5: Datasets Overview (tab_datasets_overview.tex)
###############################################################################
cat("\n=== Table 5: Datasets Overview ===\n")

datasets_info <- data.frame(
  Dataset = c(
    "General Social Survey (GSS)",
    "Ethnographic Atlas (EA)",
    "Std. Cross-Cultural Sample (SCCS)",
    "Pulotu",
    "Seshat Databank",
    "FRED Economic Data"
  ),
  Coverage = c(
    "United States, 1972--2024",
    "1,291 societies worldwide",
    "186 societies worldwide",
    "137 Austronesian cultures",
    "33 NGAs, 9600 BCE--1987 CE",
    "United States, 1972--2025"
  ),
  N = c(
    formatC(nrow(gss), format = "d", big.mark = ","),
    formatC(nrow(ea), format = "d", big.mark = ","),
    formatC(nrow(sccs), format = "d", big.mark = ","),
    formatC(nrow(pulotu), format = "d", big.mark = ","),
    formatC(nrow(seshat), format = "d", big.mark = ","),
    formatC(nrow(fred), format = "d", big.mark = ",")
  ),
  Key_Variables = c(
    "Heaven, hell, afterlife, God image, forgiveness, coping",
    "High gods (EA034), subsistence, stratification",
    "High gods, political complexity, subsistence",
    "Supernatural punishment, gods, afterlife beliefs",
    "Moralizing supernatural punishment (MSP), afterlife",
    "GDP growth, Gini, unemployment, income"
  ),
  Access = c(
    "Free download (NORC)",
    "Free (D-PLACE GitHub)",
    "Free (D-PLACE GitHub)",
    "Free (Pulotu GitHub)",
    "Free (Seshat GitHub)",
    "Free (FRED API)"
  ),
  stringsAsFactors = FALSE
)

tab5_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Overview of Datasets Used}",
  "\\label{tab:datasets_overview}",
  "\\small",
  "\\begin{tabular}{p{3.8cm}p{3.0cm}rp{4.2cm}p{2.5cm}}",
  "\\toprule",
  "Dataset & Coverage & $N$ & Key Variables & Access \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(datasets_info))) {
  r <- datasets_info[i, ]
  tab5_lines <- c(tab5_lines, sprintf(
    "%s & %s & %s & %s & %s \\\\",
    r$Dataset, r$Coverage, r$N, r$Key_Variables, r$Access
  ))
  if (i < nrow(datasets_info)) {
    tab5_lines <- c(tab5_lines, "\\addlinespace")
  }
}

tab5_lines <- c(tab5_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]\\footnotesize",
  "\\item \\textit{Notes:} $N$ reports total observations in the cleaned dataset (individuals for GSS, societies for EA/SCCS/Pulotu, polity-periods for Seshat, years for FRED). All datasets are freely accessible for academic research.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab5_lines, file.path(tab_dir, "tab_datasets_overview.tex"))
cat("Saved tab_datasets_overview.tex\n")


###############################################################################
# Table 6: Restricted Datasets (Appendix) (tab_restricted_datasets.tex)
###############################################################################
cat("\n=== Table 6: Restricted Datasets (Appendix) ===\n")

restricted <- data.frame(
  Dataset = c(
    "EVS/WVS Joint Longitudinal",
    "World Values Survey Wave 6",
    "World Values Survey Wave 7",
    "ISSP Religion IV (2018)",
    "Pew Religious Landscape Study",
    "Baylor Religion Survey",
    "Database of Religious History (DRH)"
  ),
  Coverage = c(
    "100+ countries, 1981--2022",
    "60 countries, 2010--2014",
    "57 countries, 2017--2022",
    "36 countries, 2018",
    "United States, 2007 \\& 2014",
    "United States, 2005--2017",
    "Historical religions worldwide"
  ),
  Key_Variables = c(
    "God importance, heaven/hell, church attendance",
    "Afterlife belief, God importance, religious values",
    "Afterlife belief, God importance, religious values",
    "Belief in God, afterlife, heaven/hell, religious coping",
    "Detailed belief batteries, God image, forgiveness",
    "God image (loving/judging), forgiveness, theodicy",
    "Moralizing gods, afterlife, supernatural punishment"
  ),
  Access_Requirement = c(
    "Registration \\& agreement",
    "Registration \\& agreement",
    "Registration \\& agreement",
    "Registration \\& membership",
    "Registration (Pew)",
    "Registration (ARDA)",
    "Free but complex API"
  ),
  URL = c(
    "\\url{https://www.worldvaluessurvey.org/}",
    "\\url{https://www.worldvaluessurvey.org/}",
    "\\url{https://www.worldvaluessurvey.org/}",
    "\\url{https://issp.org/}",
    "\\url{https://www.pewresearch.org/}",
    "\\url{https://www.baylor.edu/baylorreligionsurvey/}",
    "\\url{https://religiondatabase.org/}"
  ),
  stringsAsFactors = FALSE
)

tab6_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Restricted-Access Datasets Relevant to Divine Forgiveness Research}",
  "\\label{tab:restricted_datasets}",
  "\\small",
  "\\begin{tabular}{p{3.2cm}p{2.5cm}p{3.5cm}p{2.3cm}p{3.0cm}}",
  "\\toprule",
  "Dataset & Coverage & Key Variables & Access & URL \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(restricted))) {
  r <- restricted[i, ]
  tab6_lines <- c(tab6_lines, sprintf(
    "%s & %s & %s & %s & %s \\\\",
    r$Dataset, r$Coverage, r$Key_Variables, r$Access_Requirement, r$URL
  ))
  if (i < nrow(restricted)) {
    tab6_lines <- c(tab6_lines, "\\addlinespace")
  }
}

tab6_lines <- c(tab6_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]\\footnotesize",
  "\\item \\textit{Notes:} These datasets contain rich measures of divine beliefs, forgiveness, and supernatural punishment but could not be freely downloaded for this study. Each requires registration, institutional affiliation, or data use agreements. Future work incorporating these sources would substantially strengthen cross-national and historical analyses.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab6_lines, file.path(tab_dir, "tab_restricted_datasets.tex"))
cat("Saved tab_restricted_datasets.tex\n")


###############################################################################
# Table 7: SCCS Bivariate Correlations with High Gods (Appendix)
###############################################################################
cat("\n=== Table 7: SCCS Correlations (Appendix) ===\n")

# Load raw SCCS data to get categorical variables
sccs_data_raw <- read.csv(file.path(data_dir, "dplace_sccs", "data.csv"),
                          stringsAsFactors = FALSE)
sccs_vars_meta <- read.csv(file.path(data_dir, "dplace_sccs", "variables.csv"),
                           stringsAsFactors = FALSE)
sccs_codes_raw <- read.csv(file.path(data_dir, "dplace_sccs", "codes.csv"),
                           stringsAsFactors = FALSE)

# Merge high gods into numeric form
sccs_hg_num <- sccs_hg %>%
  select(Soc_ID, Code_ID) %>%
  mutate(
    high_gods_num = case_when(
      Code_ID == "SCCS238-1" ~ 0,
      Code_ID == "SCCS238-2" ~ 1,
      Code_ID == "SCCS238-3" ~ 2,
      Code_ID == "SCCS238-4" ~ 3,
      TRUE ~ NA_real_
    )
  ) %>%
  filter(!is.na(high_gods_num))

# Define key SCCS covariates with labels and ordinal recoding
# We need to handle both numeric and categorical variables
covariate_specs <- list(
  list(var_id = "SCCS814", label = "Agricultural dependence (\\%)",
       recode = NULL),  # already numeric 0-1
  list(var_id = "SCCS237", label = "Jurisdictional hierarchy (EA033)",
       recode = c("Acephalous" = 0, "One level" = 1, "Two levels" = 2,
                  "Three levels" = 3, "Four levels" = 4)),
  list(var_id = "SCCS158", label = "Social stratification (scale)",
       recode = c("Egalitarian" = 0,
                  "2 social classes, no castes/slavery" = 1,
                  "Elite, based on wealth" = 1,
                  "Hereditary slavery" = 2,
                  "Complex stratification" = 3,
                  "Dual: based on wealth and hereditary aristocracy" = 2,
                  "Two hereditary social classes, no castes or slavery" = 1)),
  list(var_id = "SCCS156", label = "Population density (scale)",
       recode = NULL),  # numeric
  list(var_id = "SCCS234", label = "Settlement patterns (EA030)",
       recode = c("Nomadic" = 0, "Seminomadic" = 1, "Semisedentary" = 2,
                  "Sedentary: impermanent" = 3, "Sedentary" = 4,
                  "Compact and relatively permanent settlements" = 5,
                  "Complex settlements" = 6)),
  list(var_id = "SCCS270", label = "Class differentiation (EA066)",
       recode = NULL),  # will try numeric
  list(var_id = "SCCS1751", label = "Social stratification (alt.)",
       recode = NULL)
)

# Compute correlations for each covariate
sccs_cor_results <- lapply(covariate_specs, function(spec) {
  var_data <- sccs_data_raw[sccs_data_raw$Var_ID == spec$var_id,
                            c("Soc_ID", "Value")]
  if (nrow(var_data) == 0) {
    return(data.frame(Variable = spec$label, r = NA, p = NA, N = 0,
                      stringsAsFactors = FALSE))
  }

  # Attempt numeric conversion first
  var_data$num_val <- suppressWarnings(as.numeric(var_data$Value))

  # If mostly NA after numeric conversion and recode map provided, use recode
  if (sum(!is.na(var_data$num_val)) < nrow(var_data) * 0.3 && !is.null(spec$recode)) {
    var_data$num_val <- spec$recode[var_data$Value]
  }

  # If still mostly NA, try ordinal ranking of unique values
  if (sum(!is.na(var_data$num_val)) < nrow(var_data) * 0.3) {
    unique_vals <- sort(unique(var_data$Value[var_data$Value != ""]))
    if (length(unique_vals) > 1 && length(unique_vals) <= 10) {
      rank_map <- setNames(seq_along(unique_vals) - 1, unique_vals)
      var_data$num_val <- rank_map[var_data$Value]
    }
  }

  # Merge with high gods
  merged <- merge(var_data, sccs_hg_num, by = "Soc_ID")
  merged <- merged[!is.na(merged$num_val) & !is.na(merged$high_gods_num), ]

  if (nrow(merged) < 10) {
    return(data.frame(Variable = spec$label, r = NA, p = NA, N = nrow(merged),
                      stringsAsFactors = FALSE))
  }

  ct <- cor.test(merged$high_gods_num, merged$num_val)
  data.frame(
    Variable = spec$label,
    r = round(ct$estimate, 3),
    p = round(ct$p.value, 4),
    N = nrow(merged),
    stringsAsFactors = FALSE
  )
})

sccs_cor_df <- do.call(rbind, sccs_cor_results)
sccs_cor_df <- sccs_cor_df[!is.na(sccs_cor_df$r), ]

cat("SCCS correlations computed:\n")
print(sccs_cor_df)

# Build LaTeX table
format_p_sccs <- function(p) {
  if (is.na(p)) return("---")
  if (p < 0.001) return("$<$0.001")
  if (p < 0.01) return(sprintf("%.3f", p))
  if (p < 0.05) return(sprintf("%.3f", p))
  sprintf("%.3f", p)
}

stars_fn <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.001) return("***")
  if (p < 0.01) return("**")
  if (p < 0.05) return("*")
  ""
}

tab7_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{SCCS Bivariate Correlations: Societal Covariates and High Gods (SCCS238)}",
  "\\label{tab:sccs_correlations}",
  "\\begin{tabular}{lrrr}",
  "\\toprule",
  "Variable & $r$ & $p$-value & $N$ \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(sccs_cor_df))) {
  row <- sccs_cor_df[i, ]
  r_str <- sprintf("%.3f%s", row$r, stars_fn(row$p))
  p_str <- format_p_sccs(row$p)
  n_str <- formatC(row$N, format = "d")
  tab7_lines <- c(tab7_lines, sprintf(
    "%s & %s & %s & %s \\\\",
    row$Variable, r_str, p_str, n_str
  ))
}

tab7_lines <- c(tab7_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]\\footnotesize",
  "\\item \\textit{Notes:} Pearson correlations between the ordinal high gods variable (SCCS238: 0 = absent, 1 = otiose, 2 = active non-moralizing, 3 = active moralizing) and societal covariates from the Standard Cross-Cultural Sample ($N = 186$ societies). Categorical covariates are coded as ordinal scales. *** $p<0.001$, ** $p<0.01$, * $p<0.05$.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab7_lines, file.path(tab_dir, "tab_sccs_correlations.tex"))
cat("Saved tab_sccs_correlations.tex\n")


###############################################################################
# Summary
###############################################################################
cat("\n=== All tables generated ===\n")
for (f in list.files(tab_dir, pattern = "\\.tex$")) {
  sz <- file.size(file.path(tab_dir, f))
  cat(sprintf("  %s: %.1f KB\n", f, sz / 1e3))
}
