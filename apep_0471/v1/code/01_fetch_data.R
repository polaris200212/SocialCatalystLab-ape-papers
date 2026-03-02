## 01_fetch_data.R — Data acquisition for apep_0471
## UC Rollout and Firm Formation
## Sources: DWP rollout schedule, Companies House bulk, NOMIS APS, ONS

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

cat("=== Step 1: UC Full Service Rollout Dates ===\n")
# Manually coded from DWP Transition Rollout Schedule PDF
# Source: https://assets.publishing.service.gov.uk/media/5ab507c8e5274a1aa2d414d1/universal-credit-transition-rollout-schedule.pdf
# Each row: LA name -> rollout month (YYYY-MM)

uc_rollout <- tribble(
  ~la_name, ~rollout_month,
  # November 2015
  "London Borough of Croydon", "2015-11",
  "London Borough of Southwark", "2015-11",
  # December 2015
  "London Borough of Sutton", "2015-12",
  # January 2016
  "London Borough of Hounslow", "2016-01",
  # March 2016
  "East Lothian Council", "2016-03",
  # April 2016
  "Great Yarmouth Borough Council", "2016-04",
  "London Borough of Croydon", "2016-04",
  "London Borough of Southwark", "2016-04",
  # May 2016
  "Bath and North East Somerset Council", "2016-05",
  "Newcastle City Council", "2016-05",
  "Rugby Borough Council", "2016-05",
  "Sedgemoor District Council", "2016-05",
  "Waveney District Council", "2016-05",
  # June 2016
  "Harrogate Borough Council", "2016-06",
  "Highland Council", "2016-06",
  "London Borough of Hammersmith & Fulham", "2016-06",
  "Richmondshire District Council", "2016-06",
  "Ryedale District Council", "2016-06",
  # July 2016
  "Halton Borough Council", "2016-07",
  "Lancaster City Council", "2016-07",
  "Mendip District Council", "2016-07",
  # October 2016
  "Craven District Council", "2016-10",
  "Hambleton District Council", "2016-10",
  "London Borough of Lambeth", "2016-10",
  "London Borough of Southwark", "2016-10",
  "Taunton Deane Borough Council", "2016-10",
  "West Somerset Council", "2016-10",
  # November 2016
  "Allerdale Borough Council", "2016-11",
  "Copeland Borough Council", "2016-11",
  "Daventry District Council", "2016-11",
  "East Dunbartonshire Council", "2016-11",
  "Harborough District Council", "2016-11",
  "Inverclyde Council", "2016-11",
  "London Borough of Hammersmith & Fulham", "2016-11",
  "London Borough of Southwark", "2016-11",
  "Melton Borough Council", "2016-11",
  "Swindon Borough Council", "2016-11",
  # December 2016
  "Hartlepool Borough Council", "2016-12",
  "Hastings Borough Council", "2016-12",
  "London Borough of Hammersmith & Fulham", "2016-12",
  "Stratford District Council", "2016-12",
  "Swindon Borough Council", "2016-12",
  # February 2017
  "Corby Borough Council", "2017-02",
  "London Borough of Tower Hamlets", "2017-02",
  "Newcastle City Council", "2017-02",
  "Southampton City Council", "2017-02",
  "Warrington Borough Council", "2017-02",
  # March 2017
  "Hinckley & Bosworth Borough Council", "2017-03",
  "London Borough of Tower Hamlets", "2017-03",
  "City of London", "2017-03",
  "Midlothian Council", "2017-03",
  "Newcastle City Council", "2017-03",
  # April 2017
  "Flintshire County Council", "2017-04",
  "Oldham Metropolitan Council", "2017-04",
  "South Somerset District Council", "2017-04",
  # May 2017
  "Bedford Borough Council", "2017-05",
  "Dover District Council", "2017-05",
  "Burnley Borough Council", "2017-05",
  "Erewash Borough Council", "2017-05",
  "Wiltshire Council", "2017-05",
  # June 2017
  "Calderdale Metropolitan Borough Council", "2017-06",
  "Clackmannanshire Council", "2017-06",
  "North Somerset Council", "2017-06",
  "Stirling Council", "2017-06",
  "Wiltshire Council", "2017-06",
  # July 2017
  "Barnsley Metropolitan Borough Council", "2017-07",
  "Cheshire East", "2017-07",
  "Cheshire West and Chester Council", "2017-07",
  "City of York Council", "2017-07",
  "Dudley Metropolitan Borough Council", "2017-07",
  "Eastleigh Borough Council", "2017-07",
  "Harlow Council", "2017-07",
  "Highland Council", "2017-07",
  "North Somerset Council", "2017-07",
  "Rother District Council", "2017-07",
  "Solihull Metropolitan Borough Council", "2017-07",
  "Southend-on-Sea Borough Council", "2017-07",
  "Thanet District Council", "2017-07",
  "Torfaen County Borough Council", "2017-07",
  "Trafford Council", "2017-07",
  "Wiltshire Council", "2017-07",
  # October 2017
  "Babergh District Council", "2017-10",
  "Braintree District Council", "2017-10",
  "Brighton & Hove City Council", "2017-10",
  "Doncaster Metropolitan Borough Council", "2017-10",
  "Durham County Council", "2017-10",
  "East Ayrshire Council", "2017-10",
  "East Dorset District Council", "2017-10",
  "Eastbourne Borough Council", "2017-10",
  "Gateshead Council", "2017-10",
  "Manchester City Council", "2017-10",
  "Neath Port Talbot County Borough Council", "2017-10",
  "North Dorset District Council", "2017-10",
  "North Lincolnshire Council", "2017-10",
  "Nuneaton & Bedworth Borough Council", "2017-10",
  "Oxford City Council", "2017-10",
  "Plymouth City Council", "2017-10",
  "Poole Borough Council", "2017-10",
  "Purbeck District Council", "2017-10",
  "Redditch Borough Council", "2017-10",
  "Rutland County Council", "2017-10",
  "Sefton Borough Council", "2017-10",
  "South Kesteven District Council", "2017-10",
  "South Lanarkshire Council", "2017-10",
  "South Oxfordshire District Council", "2017-10",
  "St Edmundsbury Borough Council", "2017-10",
  "Stroud District Council", "2017-10",
  "Thurrock Council", "2017-10",
  "Uttlesford District Council", "2017-10",
  "Vale of White Horse District Council", "2017-10",
  "Waveney District Council", "2017-10",
  "Wealden District Council", "2017-10",
  "West Devon Borough Council", "2017-10",
  "Wrexham County Borough Council", "2017-10",
  # March 2018
  "City of Lincoln Council", "2018-03",
  "Falkirk Council", "2018-03",
  "London Borough of Barking & Dagenham", "2018-03",
  "London Borough of Ealing", "2018-03",
  "London Borough of Enfield", "2018-03",
  "Tameside Metropolitan Borough Council", "2018-03",
  # April 2018
  "Denbighshire County Council", "2018-04",
  "Ipswich Borough Council", "2018-04",
  "North Lanarkshire Council", "2018-04",
  "Slough Borough Council", "2018-04",
  "Wigan Council", "2018-04",
  # May 2018
  "Basingstoke and Deane Borough Council", "2018-05",
  "Bracknell Forest Council", "2018-05",
  "Cornwall Council", "2018-05",
  "Dumfries & Galloway Council", "2018-05",
  "East Northamptonshire Council", "2018-05",
  "Gravesham Borough Council", "2018-05",
  "Knowsley Metropolitan Borough Council", "2018-05",
  "London Borough of Barnet", "2018-05",
  "London Borough of Enfield", "2018-05",
  "London Borough of Waltham Forest", "2018-05",
  "Medway Council", "2018-05",
  "Mid Suffolk District Council", "2018-05",
  "Newark and Sherwood District Council", "2018-05",
  "North Tyneside Council", "2018-05",
  "Rochdale Borough Council", "2018-05",
  "Royal Borough of Windsor and Maidenhead", "2018-05",
  "Scarborough Borough Council", "2018-05",
  "Selby District Council", "2018-05",
  "Shepway District Council", "2018-05",
  "Shropshire Council", "2018-05",
  "South Norfolk Council", "2018-05",
  "South Tyneside Council", "2018-05",
  "West Lothian Council", "2018-05",
  "Wokingham Borough Council", "2018-05",
  # June 2018
  "Aberdeenshire Council", "2018-06",
  "Amber Valley Borough Council", "2018-06",
  "Ashford Borough Council", "2018-06",
  "Blaby District Council", "2018-06",
  "Bradford Metropolitan District Council", "2018-06",
  "Breckland Council", "2018-06",
  "Bridgend County Borough Council", "2018-06",
  "Bristol City Council", "2018-06",
  "City of Westminster", "2018-06",
  "Conwy County Council", "2018-06",
  "Cornwall Council", "2018-06",
  "Crawley Borough Council", "2018-06",
  "Darlington Borough Council", "2018-06",
  "Durham County Council", "2018-06",
  "East Lindsey District Council", "2018-06",
  "Herefordshire Council", "2018-06",
  "Horsham District Council", "2018-06",
  "Isle of Wight Council", "2018-06",
  "Leicester City Council", "2018-06",
  "London Borough of Havering", "2018-06",
  "London Borough of Islington", "2018-06",
  "London Borough of Redbridge", "2018-06",
  "London Borough of Richmond upon Thames", "2018-06",
  "Merthyr Tydfil County Borough Council", "2018-06",
  "Mid Sussex District Council", "2018-06",
  "Monmouthshire County Council", "2018-06",
  "New Forest District Council", "2018-06",
  "Oadby & Wigston Borough Council", "2018-06",
  "Perth and Kinross Council", "2018-06",
  "Royal Borough of Kingston upon Thames", "2018-06",
  "Scottish Borders Council", "2018-06",
  "Stoke-on-Trent City Council", "2018-06",
  "The Moray Council", "2018-06",
  # July 2018
  "Adur District Council", "2018-07",
  "Arun District Council", "2018-07",
  "Blaenau Gwent County Borough Council", "2018-07",
  "Bury Council", "2018-07",
  "Canterbury City Council", "2018-07",
  "Carlisle City Council", "2018-07",
  "Castle Point Borough Council", "2018-07",
  "Charnwood Borough Council", "2018-07",
  "Cheshire East", "2018-07",
  "Chichester District Council", "2018-07",
  "Chorley Borough Council", "2018-07",
  "Colchester Borough Council", "2018-07",
  "Coventry City Council", "2018-07",
  "Dartford Borough Council", "2018-07",
  "Derby City Council", "2018-07",
  "East Devon District Council", "2018-07",
  "East Riding of Yorkshire Council", "2018-07",
  "Eden District Council", "2018-07",
  "London Borough of Bromley", "2018-07",
  "London Borough of Harrow", "2018-07",
  "London Borough of Lewisham", "2018-07",
  "London Borough of Newham", "2018-07",
  "Manchester City Council", "2018-07",
  "Mid Devon District Council", "2018-07",
  "North Devon District Council", "2018-07",
  "North East Derbyshire District Council", "2018-07",
  "Preston City Council", "2018-07",
  "Rochford District Council", "2018-07",
  "Rotherham Metropolitan Borough Council", "2018-07",
  "South Holland District Council", "2018-07",
  "South Ribble Borough Council", "2018-07",
  "St Helens Metropolitan Borough Council", "2018-07",
  "Stockton Borough Council", "2018-07",
  "Sunderland City Council", "2018-07",
  "Tendring District Council", "2018-07",
  "Test Valley Borough Council", "2018-07",
  "Torridge District Council", "2018-07",
  "Walsall Metropolitan Borough Council", "2018-07",
  "Winchester City Council", "2018-07",
  "Worthing Borough Council", "2018-07",
  # September 2018
  "Argyll and Bute Council", "2018-09",
  "Aylesbury Vale District Council", "2018-09",
  "Boston Borough Council", "2018-09",
  "Breckland Council", "2018-09",
  "Bristol City Council", "2018-09",
  "Bromsgrove District Council", "2018-09",
  "Caerphilly County Borough Council", "2018-09",
  "Cambridge City Council", "2018-09",
  "Chiltern District Council", "2018-09",
  "Derbyshire Dales District Council", "2018-09",
  "East Cambridgeshire District Council", "2018-09",
  "East Lindsey District Council", "2018-09",
  "East Renfrewshire Council", "2018-09",
  "Eilean Siar Council", "2018-09",
  "Exeter City Council", "2018-09",
  "Fenland District Council", "2018-09",
  "Glasgow City Council", "2018-09",
  "Havant Borough Council", "2018-09",
  "High Peak Borough Council", "2018-09",
  "Knowsley Metropolitan Borough Council", "2018-09",
  "Lewes District Council", "2018-09",
  "Liverpool City Council", "2018-09",
  "London Borough of Wandsworth", "2018-09",
  "Malvern Hills District Council", "2018-09",
  "Mansfield District Council", "2018-09",
  "New Forest District Council", "2018-09",
  "North Warwickshire Borough Council", "2018-09",
  "Orkney Islands Council", "2018-09",
  "Pembrokeshire County Council", "2018-09",
  "Portsmouth City Council", "2018-09",
  "Renfrewshire Council", "2018-09",
  "Salford City Council", "2018-09",
  "Shetland Islands Council", "2018-09",
  "South Bucks District Council", "2018-09",
  "South Gloucestershire Council", "2018-09",
  "South Hams District Council", "2018-09",
  "South Lakeland District Council", "2018-09",
  "Staffordshire Moorlands District Council", "2018-09",
  "Teignbridge District Council", "2018-09",
  "Torbay Council", "2018-09",
  "West Devon Borough Council", "2018-09",
  "West Lindsey District Council", "2018-09",
  "Wycombe District Council", "2018-09",
  # October 2018
  "Aberdeen City Council", "2018-10",
  "Broadland District Council", "2018-10",
  "Bristol City Council", "2018-10",
  "Cambridge City Council", "2018-10",
  "East Hampshire District Council", "2018-10",
  "East Herts District Council", "2018-10",
  "Epsom and Ewell Borough Council", "2018-10",
  "Glasgow City Council", "2018-10",
  "Guildford Borough Council", "2018-10",
  "Gwynedd Council", "2018-10",
  "Hart District Council", "2018-10",
  "Huntingdonshire District Council", "2018-10",
  "Isle of Wight Council", "2018-10",
  "Kettering Borough Council", "2018-10",
  "Leeds City Council", "2018-10",
  "London Borough of Bexley", "2018-10",
  "London Borough of Hackney", "2018-10",
  "London Borough of Haringey", "2018-10",
  "London Borough of Hillingdon", "2018-10",
  "Luton Borough Council", "2018-10",
  "Middlesbrough Council", "2018-10",
  "Mole Valley District Council", "2018-10",
  "North Hertfordshire District Council", "2018-10",
  "North Norfolk District Council", "2018-10",
  "Norwich City Council", "2018-10",
  "Nottingham City Council", "2018-10",
  "Powys County Council", "2018-10",
  "Reigate and Banstead Council", "2018-10",
  "Royal Borough of Greenwich", "2018-10",
  "Rushcliffe Borough Council", "2018-10",
  "Rushmoor Borough Council", "2018-10",
  "Stevenage Borough Council", "2018-10",
  "South Bucks District Council", "2018-10",
  "South Cambridgeshire District Council", "2018-10",
  "South Gloucestershire District Council", "2018-10",
  "Suffolk Coastal District Council", "2018-10",
  "Tandridge District Council", "2018-10",
  "Vale of Glamorgan Council", "2018-10",
  "Walsall Metropolitan Borough Council", "2018-10",
  "Warwick District Council", "2018-10",
  "Waverley Borough Council", "2018-10",
  "Woking Borough Council", "2018-10",
  "Worcester City Council", "2018-10",
  # November 2018
  "Ashfield District Council", "2018-11",
  "Bolsover District Council", "2018-11",
  "Bolton Council", "2018-11",
  "Borough Council of King's Lynn & West Norfolk", "2018-11",
  "Borough Council of Wellingborough", "2018-11",
  "Broxtowe Borough Council", "2018-11",
  "Cannock Chase District Council", "2018-11",
  "Central Bedfordshire Council", "2018-11",
  "City of Edinburgh Council", "2018-11",
  "East Staffordshire Borough Council", "2018-11",
  "Elmbridge Borough Council", "2018-11",
  "Epson & Ewell Borough Council", "2018-11",
  "Fareham Borough Council", "2018-11",
  "Gedling Borough Council", "2018-11",
  "Gosport Borough Council", "2018-11",
  "Havant Borough Council", "2018-11",
  "Liverpool City Council", "2018-11",
  "London Borough of Brent", "2018-11",
  "Maidstone Borough Council", "2018-11",
  "North Kesteven District Council", "2018-11",
  "Northampton Borough Council", "2018-11",
  "Northumberland County Council", "2018-11",
  "Pendle Borough Council", "2018-11",
  "Redcar and Cleveland Council", "2018-11",
  "Rhondda Cynon Taf County Borough Council", "2018-11",
  "Ribble Valley Borough Council", "2018-11",
  "Rossendale Borough Council", "2018-11",
  "Runnymede Borough Council", "2018-11",
  "Sandwell Council", "2018-11",
  "Sheffield City Council", "2018-11",
  "Spelthorne Borough Council", "2018-11",
  "Stafford Borough Council", "2018-11",
  "Stockport Metropolitan Borough Council", "2018-11",
  "South Derbyshire District Council", "2018-11",
  "South Northamptonshire Council", "2018-11",
  "South Staffordshire Council", "2018-11",
  "Surrey Heath Borough Council", "2018-11",
  "Telford & Wrekin Council", "2018-11",
  "Tonbridge and Malling Borough Council", "2018-11",
  "Tunbridge Wells Borough Council", "2018-11",
  "Wakefield Council", "2018-11",
  "West Dunbartonshire Council", "2018-11",
  "Wychavon District Council", "2018-11",
  "Wyre Forest District Council", "2018-11",
  # December 2018
  "Barrow In Furness Borough Council", "2018-12",
  "Blackpool Council", "2018-12",
  "Carmarthenshire County Council", "2018-12",
  "Ceredigion County Council", "2018-12",
  "Chelmsford City Council", "2018-12",
  "Dacorum Borough Council", "2018-12",
  "Epping Forest District Council", "2018-12",
  "Forest Heath District Council", "2018-12",
  "Fylde Borough Council", "2018-12",
  "Glasgow City Council", "2018-12",
  "Gwynedd Council", "2018-12",
  "Hertsmere Borough Council", "2018-12",
  "Hull City Council", "2018-12",
  "Isle of Anglesey County Council", "2018-12",
  "Liverpool City Council", "2018-12",
  "London Borough of Brent", "2018-12",
  "London Borough of Camden", "2018-12",
  "Maldon District Council", "2018-12",
  "Milton Keynes Council", "2018-12",
  "Newcastle-under-Lyme Borough Council", "2018-12",
  "North Norfolk District Council", "2018-12",
  "Northumberland County Council", "2018-12",
  "Royal Borough of Kensington and Chelsea", "2018-12",
  "Sheffield City Council", "2018-12",
  "Wyre Borough Council", "2018-12"
)

# Keep only earliest treatment date per LA (some LAs appear multiple times as rollout expanded)
uc_rollout <- uc_rollout %>%
  mutate(rollout_date = ym(rollout_month)) %>%
  group_by(la_name) %>%
  summarise(
    first_treat_date = min(rollout_date),
    first_treat_month = format(min(rollout_date), "%Y-%m"),
    .groups = "drop"
  )

cat(sprintf("UC rollout dates coded for %d unique LAs\n", nrow(uc_rollout)))
cat(sprintf("Treatment range: %s to %s\n",
            min(uc_rollout$first_treat_date), max(uc_rollout$first_treat_date)))

# Save treatment dates
write_csv(uc_rollout, file.path(data_dir, "uc_rollout_dates.csv"))

cat("\n=== Step 2: Companies House Bulk Data ===\n")
# Download annual files to avoid the massive pp-complete.csv
# We need 2013-2019 to cover pre and post treatment
# Companies House snapshot only has LIVE companies - for historical formation,
# we use IncorporationDate from the current snapshot

ch_url <- "https://download.companieshouse.gov.uk/BasicCompanyDataAsOneFile-2026-02-01.zip"
ch_zip <- file.path(data_dir, "companies_house.zip")
ch_csv <- file.path(data_dir, "companies_house.csv")

if (!file.exists(ch_csv)) {
  cat("Downloading Companies House bulk data (~468MB)...\n")
  download.file(ch_url, ch_zip, mode = "wb", quiet = FALSE)
  cat("Unzipping...\n")
  unzip(ch_zip, exdir = data_dir)
  # Find the extracted CSV (may be in nested subdirectories)
  csvs <- list.files(data_dir, pattern = "BasicCompanyData.*\\.csv$",
                     full.names = TRUE, recursive = TRUE)
  if (length(csvs) > 0) {
    file.rename(csvs[1], ch_csv)
    # Clean up any extracted subdirectories
    unlink(file.path(data_dir, "home"), recursive = TRUE)
  }
  unlink(ch_zip) # Clean up zip
  cat("Companies House data extracted.\n")
} else {
  cat("Companies House CSV already exists.\n")
}

# Read with arrow for memory efficiency
cat("Reading Companies House data with arrow...\n")
ch_raw <- read_csv_arrow(ch_csv, as_data_frame = TRUE)
# Trim whitespace from column names (CH CSV has leading spaces)
names(ch_raw) <- str_trim(names(ch_raw))
cat(sprintf("Columns: %s\n", paste(head(names(ch_raw), 10), collapse = ", ")))
# Select only needed columns
ch_raw <- ch_raw %>%
  select(CompanyNumber, CompanyName, RegAddress.PostCode,
         CompanyCategory, IncorporationDate, DissolutionDate,
         SICCode.SicText_1)

cat(sprintf("Companies House: %s rows loaded\n", comma(nrow(ch_raw))))

# Parse incorporation date and filter to study window
ch <- ch_raw %>%
  mutate(
    inc_date = dmy(IncorporationDate),
    inc_ym = floor_date(inc_date, "month"),
    postcode = str_trim(`RegAddress.PostCode`),
    # Extract outward code for initial geographic matching
    postcode_out = str_extract(postcode, "^[A-Z]{1,2}[0-9][A-Z0-9]?"),
    sic_full = str_extract(`SICCode.SicText_1`, "^[0-9]+"),
    # Extract SIC division (first 2 digits) for section mapping
    sic_code = as.numeric(substr(sic_full, 1, 2)),
    sic_section = case_when(
      sic_code >= 1 & sic_code <= 3 ~ "A",   # Agriculture
      sic_code >= 5 & sic_code <= 9 ~ "B",   # Mining
      sic_code >= 10 & sic_code <= 33 ~ "C", # Manufacturing
      sic_code >= 41 & sic_code <= 43 ~ "F", # Construction
      sic_code >= 45 & sic_code <= 47 ~ "G", # Wholesale/Retail
      sic_code >= 49 & sic_code <= 53 ~ "H", # Transport
      sic_code >= 55 & sic_code <= 56 ~ "I", # Accommodation/Food
      sic_code >= 58 & sic_code <= 63 ~ "J", # Information/Communication
      sic_code >= 64 & sic_code <= 66 ~ "K", # Financial
      sic_code == 68 ~ "L",                   # Real estate
      sic_code >= 69 & sic_code <= 75 ~ "M", # Professional/Scientific
      sic_code >= 77 & sic_code <= 82 ~ "N", # Administrative
      sic_code == 84 ~ "O",                   # Public admin (placebo)
      sic_code == 85 ~ "P",                   # Education
      sic_code >= 86 & sic_code <= 88 ~ "Q", # Health/Social
      TRUE ~ "Other"
    )
  ) %>%
  filter(
    !is.na(inc_date),
    inc_date >= ymd("2013-01-01"),
    inc_date <= ymd("2019-12-31"),
    !is.na(postcode),
    str_detect(postcode, "^[A-Z]{1,2}[0-9]")  # Valid UK postcode pattern
  )

cat(sprintf("Companies formed 2013-2019 with valid postcodes: %s\n", comma(nrow(ch))))

# Save filtered dataset
write_parquet(ch, file.path(data_dir, "ch_formations_2013_2019.parquet"))
rm(ch_raw); gc()

cat("\n=== Step 3: ONS NSPL Postcode Lookup ===\n")
# NSPL postcode-to-LA mapping pre-downloaded via ArcGIS Feature Service
# (see Python download script or manual download from geoportal.statistics.gov.uk)
nspl_csv <- file.path(data_dir, "nspl_lookup.csv")

if (!file.exists(nspl_csv)) {
  stop("NSPL lookup file not found at ", nspl_csv,
       "\nRun the Python NSPL download script first, or download from ",
       "https://geoportal.statistics.gov.uk (NSPL latest)")
}

pc_lookup <- read_csv(nspl_csv, show_col_types = FALSE)
cat(sprintf("Loaded %s postcode-LA mappings (%d unique LAs)\n",
            comma(nrow(pc_lookup)), n_distinct(pc_lookup$la_code)))

cat("\n=== Step 4: NOMIS APS Self-Employment Data ===\n")
nomis_key <- Sys.getenv("NOMIS_API_KEY")
auth_param <- if (nchar(nomis_key) > 0) paste0("&uid=", nomis_key) else ""

# Fetch self-employment rate (var 73), employment rate (var 45),
# unemployment rate (var 83), and employee rate (var 71)
# by Local Authority, annual 2004-2024
nomis_url <- paste0(
  "https://www.nomisweb.co.uk/api/v01/dataset/NM_17_5.data.csv?",
  "geography=TYPE464",
  "&date=2004-12,2005-12,2006-12,2007-12,2008-12,2009-12,2010-12,",
  "2011-12,2012-12,2013-12,2014-12,2015-12,2016-12,2017-12,2018-12,",
  "2019-12,2020-12,2021-12,2022-12,2023-12,2024-12",
  "&variable=73,45,83,71",
  "&measures=20599,21001,21002",
  "&select=date_name,geography_name,geography_code,variable_name,measures_name,obs_value",
  auth_param
)

nomis_file <- file.path(data_dir, "nomis_aps_la.csv")
if (!file.exists(nomis_file)) {
  cat("Fetching NOMIS APS data...\n")
  download.file(nomis_url, nomis_file, quiet = FALSE)
}

nomis_raw <- read_csv(nomis_file, show_col_types = FALSE)
cat(sprintf("NOMIS: %s rows loaded\n", comma(nrow(nomis_raw))))

# Save raw
write_csv(nomis_raw, file.path(data_dir, "nomis_aps_raw.csv"))

cat("\n=== Step 5: ONS Mid-Year Population Estimates ===\n")
# Fetch total population by LA for rate denominators
# Use NOMIS dataset NM_31_1 (Mid-Year Population Estimates)
pop_url <- paste0(
  "https://www.nomisweb.co.uk/api/v01/dataset/NM_31_1.data.csv?",
  "geography=TYPE464",
  "&date=2013,2014,2015,2016,2017,2018,2019",
  "&sex=7",     # Total (persons)
  "&age=0",     # All ages
  "&measures=20100",
  "&select=date_name,geography_name,geography_code,obs_value",
  auth_param
)

pop_file <- file.path(data_dir, "population_la.csv")
if (!file.exists(pop_file)) {
  cat("Fetching ONS population estimates via NOMIS...\n")
  download.file(pop_url, pop_file, quiet = FALSE)
}

pop <- read_csv(pop_file, show_col_types = FALSE)
cat(sprintf("Population data: %s rows\n", comma(nrow(pop))))

cat("\n=== All data fetched successfully ===\n")
cat("Files saved to:", data_dir, "\n")
cat("Next: Run 02_clean_data.R to build analysis panel\n")
