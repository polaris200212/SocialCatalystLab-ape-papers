# =============================================================================
# 00_packages.R — Load packages, set paths, define helpers
# =============================================================================
# Source this script first. All other scripts depend on it.
# =============================================================================

# --- Packages ---
library(data.table)
library(fixest)
library(ggplot2)
library(sf)
library(duckdb)
library(arrow)
library(kableExtra)

# --- Repo root ---
REPO_ROOT <- system("git rev-parse --show-toplevel", intern = TRUE)
if (length(REPO_ROOT) != 1) stop("Not in a git repository.")

# --- Paths (relative to this script's location) ---
CODE_DIR   <- normalizePath(dirname(sys.frame(1)$ofile), mustWork = FALSE)
if (is.na(CODE_DIR) || CODE_DIR == "") CODE_DIR <- getwd()
PAPER_DIR  <- dirname(CODE_DIR)
DATA_DIR   <- file.path(PAPER_DIR, "data")
FIG_DIR    <- file.path(PAPER_DIR, "figures")
TABLE_DIR  <- file.path(PAPER_DIR, "tables")

dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TABLE_DIR, showWarnings = FALSE, recursive = TRUE)

# --- Source Azure data library ---
source(file.path(REPO_ROOT, "scripts/lib/azure_data.R"))

# --- Azure blob paths ---
MLP_PATH   <- "raw/ipums_mlp/v2/mlp_crosswalk_v2.parquet"
PANEL_PATH <- "derived/mlp_panel/linked_1920_1930_1940.parquet"

# --- ggplot theme ---
theme_set(theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 14),
    strip.text = element_text(face = "bold")
  ))

# Color palette: TVA vs Control
COLORS <- c("TVA" = "#D55E00", "Control" = "#0072B2")

# --- Helpers ---
fmt <- function(x) format(x, big.mark = ",", scientific = FALSE)

log_msg <- function(...) {
  cat(sprintf("[%s] %s\n", format(Sys.time(), "%H:%M:%S"), paste0(...)))
}

# =============================================================================
# TVA County Definitions (STATEFIP + COUNTYICP from IPUMS)
# =============================================================================
# The TVA service area spanned parts of 7 states. These COUNTYICP codes are
# the IPUMS county identifiers (not FIPS) for the historical TVA service area,
# based on the counties that received TVA electricity by 1940.
#
# States: AL (01), GA (13), KY (21), MS (28), NC (37), TN (47), VA (51)
#
# Note: COUNTYICP codes are 4-digit IPUMS codes. They differ from modern FIPS
# county codes. The mapping below is based on IPUMS documentation and the
# historical TVA service area as described in Kline & Moretti (2014).
# =============================================================================

get_tva_counties <- function() {
  # Returns a data.table with statefip + countyicp for TVA service area counties.
  # ~125 counties across 7 states.

  tva <- rbindlist(list(
    # --- Alabama (STATEFIP = 01) ---
    # Northern Alabama counties in TVA service area
    data.table(statefip = 1L, countyicp = c(
      330L,   # Colbert
      770L,   # Lauderdale
      830L,   # Lawrence
      890L,   # Limestone
      970L,   # Madison
      1010L,  # Marshall
      1070L,  # Morgan
      530L,   # DeKalb
      710L,   # Jackson
      170L,   # Blount
      370L,   # Cullman
      510L,   # Cherokee
      590L,   # Etowah
      1310L,  # Talladega (partial)
      1230L,  # St. Clair
      730L,   # Jefferson
      1510L,  # Winston
      1020L,  # Marion
      810L,   # Lamar
      600L,   # Fayette
      1370L,  # Tuscaloosa (partial)
      1490L,  # Walker
      610L,   # Franklin
      190L    # Calhoun
    )),

    # --- Georgia (STATEFIP = 13) ---
    # Northwest Georgia counties
    data.table(statefip = 13L, countyicp = c(
      470L,   # Catoosa
      530L,   # Chattooga
      550L,   # Dade
      870L,   # Fannin
      910L,   # Floyd
      1030L,  # Gilmer
      1090L,  # Gordon
      1690L,  # Murray
      1770L,  # Pickens
      1950L,  # Polk
      2730L,  # Walker
      2770L,  # Whitfield
      2710L   # Towns
    )),

    # --- Kentucky (STATEFIP = 21) ---
    # Western Kentucky counties in TVA service area
    data.table(statefip = 21L, countyicp = c(
      350L,   # Calloway
      530L,   # Christian (partial)
      690L,   # Graves
      850L,   # Hickman
      1050L,  # Livingston
      1070L,  # Lyon
      1110L,  # Marshall
      1130L,  # McCracken
      1430L,  # Trigg
      620L,   # Fulton
      70L,    # Ballard
      380L,   # Carlisle
      400L    # Crittenden
    )),

    # --- Mississippi (STATEFIP = 28) ---
    # Northeast Mississippi counties
    data.table(statefip = 28L, countyicp = c(
      10L,    # Alcorn
      170L,   # Chickasaw
      230L,   # Clay (partial)
      570L,   # Itawamba
      690L,   # Lee
      750L,   # Lowndes (partial)
      810L,   # Monroe
      970L,   # Oktibbeha (partial)
      1090L,  # Pontotoc
      1110L,  # Prentiss
      1410L,  # Tippah
      1430L,  # Tishomingo
      1470L,  # Union
      1530L   # Webster (partial)
    )),

    # --- North Carolina (STATEFIP = 37) ---
    # Western North Carolina counties
    data.table(statefip = 37L, countyicp = c(
      210L,   # Cherokee
      710L,   # Graham
      750L,   # Haywood
      870L,   # Jackson
      930L,   # Macon
      1630L,  # Swain
      430L,   # Clay
      1730L   # Transylvania (partial)
    )),

    # --- Tennessee (STATEFIP = 47) ---
    # Tennessee is the core TVA state; most counties are in the service area
    data.table(statefip = 47L, countyicp = c(
      10L,    # Anderson
      30L,    # Bedford
      50L,    # Benton
      70L,    # Bledsoe
      90L,    # Blount
      110L,   # Bradley
      130L,   # Campbell
      170L,   # Carroll
      190L,   # Cheatham
      210L,   # Chester
      230L,   # Claiborne
      270L,   # Coffee
      290L,   # Crockett
      330L,   # Decatur
      350L,   # DeKalb
      370L,   # Dickson
      390L,   # Dyer
      410L,   # Fayette
      430L,   # Fentress
      450L,   # Franklin
      470L,   # Gibson
      490L,   # Giles
      510L,   # Grainger
      530L,   # Greene
      550L,   # Grundy
      570L,   # Hamblen
      590L,   # Hamilton
      610L,   # Hancock
      630L,   # Hardeman
      650L,   # Hardin
      670L,   # Hawkins
      690L,   # Haywood
      710L,   # Henderson
      730L,   # Henry
      750L,   # Hickman
      770L,   # Houston
      790L,   # Humphreys
      830L,   # Jefferson
      850L,   # Johnson
      870L,   # Knox
      890L,   # Lake
      910L,   # Lauderdale
      930L,   # Lawrence
      950L,   # Lewis
      970L,   # Lincoln
      990L,   # Loudon
      1010L,  # McMinn
      1030L,  # McNairy
      1070L,  # Marion
      1090L,  # Marshall
      1110L,  # Maury
      1130L,  # Meigs
      1150L,  # Monroe
      1170L,  # Montgomery
      1190L,  # Moore
      1210L,  # Morgan
      1230L,  # Obion
      1270L,  # Perry
      1310L,  # Polk
      1350L,  # Rhea
      1370L,  # Roane
      1410L,  # Scott
      1430L,  # Sequatchie
      1450L,  # Sevier
      1470L,  # Shelby
      1510L,  # Stewart
      1530L,  # Sullivan
      1570L,  # Tipton
      1590L,  # Unicoi
      1610L,  # Union
      1650L,  # Warren
      1670L,  # Washington
      1690L,  # Wayne
      1710L,  # Weakley
      1730L,  # White
      1770L,  # Williamson (partial)
      150L,   # Cannon
      810L,   # Jackson (county)
      1050L,  # Macon
      310L,   # Cumberland
      1250L,  # Overton
      1290L,  # Pickett
      1330L,  # Putnam
      1550L,  # Sumner (partial)
      1490L,  # Smith
      250L,   # Cocke
      1390L,  # Robertson (partial)
      1630L,  # Van Buren
      1750L,  # Wilson (partial)
      1510L   # Stewart (duplicate removed below)
    )),

    # --- Virginia (STATEFIP = 51) ---
    # Southwest Virginia counties
    data.table(statefip = 51L, countyicp = c(
      350L,   # Bristol (independent city, mapped to Sullivan County area)
      1050L,  # Lee
      1670L,  # Scott
      1850L,  # Tazewell
      2050L,  # Washington
      2830L,  # Wise
      510L,   # Dickenson
      1270L,  # Norton (independent city)
      830L    # Grayson (partial)
    ))
  ))

  # Remove any duplicate rows

  tva <- unique(tva)
  tva[, tva := 1L]

  return(tva)
}

# List of TVA-region states (for same-state controls)
TVA_STATES <- c(1L, 13L, 21L, 28L, 37L, 47L, 51L)

# Adjacent/neighboring states to TVA states (for bordering controls)
# AR=05, FL=12, IL=17, IN=18, MO=29, OH=39, SC=45, WV=54
TVA_ADJACENT_STATES <- c(5L, 12L, 17L, 18L, 29L, 39L, 45L, 54L)

cat("Packages loaded. Paths set. TVA counties defined.\n")
cat(sprintf("  TVA counties: %d across %d states\n",
            nrow(get_tva_counties()),
            length(unique(get_tva_counties()$statefip))))
