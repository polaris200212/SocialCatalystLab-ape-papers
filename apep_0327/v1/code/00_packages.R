## ============================================================================
## 00_packages.R — Load libraries, set themes, define helper functions
## APEP-0326: State Minimum Wage Increases and the HCBS Provider Supply Crisis
## ============================================================================

## ---- Core packages ----
library(arrow)
library(data.table)
library(tidyverse)
library(fixest)
library(did)       # Callaway-Sant'Anna (2021)
library(ggplot2)
library(latex2exp)

## ---- Install if missing ----
for (pkg in c("arrow", "data.table", "tidyverse", "fixest", "did", "latex2exp")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org/", quiet = TRUE)
    library(pkg, character.only = TRUE)
  }
}

## ---- APEP standard theme ----
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin = margin(10, 15, 10, 10)
    )
}

## ---- Color palette (colorblind-safe) ----
apep_colors <- c(
  "#0072B2",  # Blue (treated)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group)
  "#56B4E9",  # Light blue
  "#E69F00"   # Amber
)

## ---- Paths ----
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")
DATA <- "../data"
FIGURES <- "../figures"
TABLES <- "../tables"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)
dir.create(FIGURES, showWarnings = FALSE, recursive = TRUE)
dir.create(TABLES, showWarnings = FALSE, recursive = TRUE)

## ---- State FIPS lookup ----
state_fips <- data.table(
  fips = c("01","02","04","05","06","08","09","10","11","12",
           "13","15","16","17","18","19","20","21","22","23",
           "24","25","26","27","28","29","30","31","32","33",
           "34","35","36","37","38","39","40","41","42","44",
           "45","46","47","48","49","50","51","53","54","55","56"),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
                 "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
                 "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
                 "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
                 "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  state_name = c("Alabama","Alaska","Arizona","Arkansas","California",
                 "Colorado","Connecticut","Delaware","District of Columbia","Florida",
                 "Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas",
                 "Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan",
                 "Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada",
                 "New Hampshire","New Jersey","New Mexico","New York","North Carolina",
                 "North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island",
                 "South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont",
                 "Virginia","Washington","West Virginia","Wisconsin","Wyoming")
)

cat("Packages loaded, theme set, paths defined.\n")
