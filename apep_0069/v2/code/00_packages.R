# =============================================================================
# 00_packages.R - Package Loading and Configuration
# Swiss Cantonal Energy Laws and Federal Referendum Voting
# v2: Fixed global seed, added fwildclusterboot
# =============================================================================

# Core tidyverse
library(tidyverse)
library(lubridate)

# Swiss data packages
library(swissdd)    # Referendum voting data
library(BFS)        # Federal statistics and maps
library(sf)         # Spatial data handling

# RDD analysis
library(rdrobust)   # Robust RDD estimation
library(rddensity)  # McCrary density test

# Econometrics
library(fixest)     # Fixed effects estimation
library(modelsummary)  # Tables

# Wild cluster bootstrap
has_fwildclusterboot <- requireNamespace("fwildclusterboot", quietly = TRUE)
if (has_fwildclusterboot) library(fwildclusterboot)

# Visualization
library(ggplot2)
library(patchwork)  # Combining plots
library(scales)
library(viridis)

# Set APEP theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "gray40", size = base_size),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90"),
      axis.title = element_text(size = base_size),
      legend.position = "bottom",
      plot.caption = element_text(hjust = 0, color = "gray50", size = base_size - 3)
    )
}

theme_set(theme_apep())

# =============================================================================
# RELATIVE PATH SETUP
# =============================================================================
get_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) {
      return(dirname(sys.frame(i)$ofile))
    }
  }
  if (!is.null(getOption("rstudio.proj.path"))) {
    proj_path <- getOption("rstudio.proj.path")
    if (dir.exists(file.path(proj_path, "code"))) {
      return(file.path(proj_path, "code"))
    }
  }
  return(getwd())
}

script_dir <- get_script_dir()
if (basename(script_dir) == "code") {
  base_dir <- dirname(script_dir)
} else {
  base_dir <- script_dir
}

data_dir <- file.path(base_dir, "data")
fig_dir <- file.path(base_dir, "figures")
tab_dir <- file.path(base_dir, "tables")

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

message(paste("Base directory:", base_dir))

# =============================================================================
# TREATMENT PROVENANCE
# =============================================================================
# Treatment defined by comprehensive cantonal energy laws (MuKEn) in force
# before the May 21, 2017 Energy Strategy 2050 referendum.
#
# Sources (LexFind.ch):
#   GR: Energiegesetz des Kantons Graubünden, SR 820.200
#       Adopted 2010, in force January 1, 2011
#       https://www.lexfind.ch/fe/de/tol/24592/de
#   BE: Kantonales Energiegesetz, SR 741.1
#       Adopted 2011, in force January 1, 2012
#       https://www.lexfind.ch/fe/de/tol/24803/de
#   AG: Energiegesetz des Kantons Aargau, SR 773.200
#       Adopted 2012, in force January 1, 2013
#       https://www.lexfind.ch/fe/de/tol/25116/de
#   BL: Energiegesetz, SR 490
#       Adopted 2015 (NOT 2016), in force July 1, 2016
#       https://www.lexfind.ch/fe/de/tol/26418/de
#   BS: Energiegesetz, SR 772.100
#       Adopted 2016, in force January 1, 2017
#       https://www.lexfind.ch/fe/de/tol/26835/de
# =============================================================================

# =============================================================================
# SPATIAL UTILITY: CORRECT POLICY BORDER COMPUTATION
# =============================================================================
# Computes ONLY internal canton-to-canton boundaries between treated and
# control cantons. Excludes national borders with France, Italy, Germany.

get_policy_border <- function(canton_sf, treated_ids, canton_id_col = "canton_id") {
  canton_sf <- canton_sf %>%
    filter(!st_is_empty(st_geometry(.))) %>%
    st_make_valid()

  treated_sf <- canton_sf %>% filter(!!sym(canton_id_col) %in% treated_ids)
  control_sf <- canton_sf %>% filter(!(!!sym(canton_id_col) %in% treated_ids))

  if (nrow(treated_sf) == 0 || nrow(control_sf) == 0) {
    warning("No treated or control cantons found")
    return(st_sfc(st_multilinestring(), crs = st_crs(canton_sf)))
  }

  touches_mat <- st_touches(treated_sf, control_sf, sparse = TRUE)

  borders <- list()
  border_pairs <- list()
  for (i in seq_len(nrow(treated_sf))) {
    touching_controls <- touches_mat[[i]]
    for (j in touching_controls) {
      shared <- tryCatch({
        st_intersection(
          st_geometry(treated_sf[i,]),
          st_geometry(control_sf[j,])
        )
      }, error = function(e) NULL)

      if (is.null(shared)) next

      if (!any(st_is_empty(shared))) {
        geom_type <- as.character(st_geometry_type(shared))
        if (geom_type %in% c("POLYGON", "MULTIPOLYGON")) {
          shared <- st_cast(st_boundary(shared), "MULTILINESTRING")
        }
        borders <- c(borders, list(shared))
        # Store pair info for per-segment analysis
        t_id <- pull(treated_sf[i,], !!sym(canton_id_col))
        c_id <- pull(control_sf[j,], !!sym(canton_id_col))
        border_pairs <- c(border_pairs, list(list(
          treated_id = t_id, control_id = c_id, geom = shared
        )))
      }
    }
  }

  if (length(borders) == 0) {
    warning("No shared borders found between treated and control cantons")
    return(st_sfc(st_multilinestring(), crs = st_crs(canton_sf)))
  }

  border_geoms <- do.call(c, lapply(borders, st_geometry))
  border_union <- st_union(border_geoms)

  # Store pair info as attribute for per-segment analysis
  attr(border_union, "border_pairs") <- border_pairs

  return(st_set_crs(border_union, st_crs(canton_sf)))
}

# Get per-segment border geometries (for same-language filtering)
get_border_segments <- function(canton_sf, treated_ids, canton_id_col = "canton_id") {
  canton_sf <- canton_sf %>%
    filter(!st_is_empty(st_geometry(.))) %>%
    st_make_valid()

  treated_sf <- canton_sf %>% filter(!!sym(canton_id_col) %in% treated_ids)
  control_sf <- canton_sf %>% filter(!(!!sym(canton_id_col) %in% treated_ids))

  touches_mat <- st_touches(treated_sf, control_sf, sparse = TRUE)

  segments <- list()
  for (i in seq_len(nrow(treated_sf))) {
    touching_controls <- touches_mat[[i]]
    for (j in touching_controls) {
      shared <- tryCatch({
        st_intersection(
          st_geometry(treated_sf[i,]),
          st_geometry(control_sf[j,])
        )
      }, error = function(e) NULL)

      if (is.null(shared) || any(st_is_empty(shared))) next

      geom_type <- as.character(st_geometry_type(shared))
      if (geom_type %in% c("POLYGON", "MULTIPOLYGON")) {
        shared <- st_cast(st_boundary(shared), "MULTILINESTRING")
      }

      t_id <- pull(treated_sf[i,], !!sym(canton_id_col))
      c_id <- pull(control_sf[j,], !!sym(canton_id_col))

      segments[[length(segments) + 1]] <- list(
        treated_id = t_id,
        control_id = c_id,
        geom = shared
      )
    }
  }

  return(segments)
}

message("Packages loaded. Ready for analysis.")
