# Research Ideas

## Idea 1: The Price of Subsidy Limits — Multi-Cutoff Evidence from Help to Buy's Regional Caps

**Policy:** Help to Buy Equity Loan scheme (2013–2023). The UK government provided 20% equity loans (40% in London) for new-build properties below a price cap. In April 2021, the uniform £600K national cap was replaced by 9 region-specific caps ranging from £186,100 (North East) to £600,000 (London). The scheme also became first-time-buyer-only. Applications closed October 2022; completions ended March 2023.

**Outcome:** HM Land Registry Price Paid Data (PPD) — universe of residential transactions in England and Wales since 1995, with new-build flag, transaction price, postcode, and property type. ~132,000 new-build transactions per year. ONS Postcode Directory (ONSPD) maps postcodes to regions.

**Identification:** Three-pronged design:
1. **Multi-cutoff bunching analysis** (Kleven 2016): 9 simultaneous price cap thresholds. Measure excess mass below each regional cap and the "missing mass" above. The 2021 reform creates a difference-in-bunching (bunching at £600K pre-2021 vs bunching at region-specific caps post-2021).
2. **Temporal difference-in-discontinuities**: Before April 2021, all regions faced £600K cap. After, caps diverged. Compare bunching patterns at each regional cap before/after the reform.
3. **Spatial RDD at regional borders**: New-build properties near regional boundaries face different caps. Properties priced £186–228K near the North East / Yorkshire border are eligible in Yorkshire but ineligible in the North East. Similar designs at East of England / London (£407–600K) and South East / London (£438–600K) borders.

**Why it's novel:** Carozzi, Hilber & Yu (2024, JUE) study the 2013–2021 scheme using England/Wales and London/non-London boundaries. They document bunching below the uniform £600K cap. **No paper exploits the 9 regional caps introduced in April 2021.** The multi-cutoff design provides internal replication across 9 thresholds simultaneously. The spatial RDD at regional borders is entirely new.

**Feasibility check:**
- ✅ Data confirmed accessible: PPD CSVs downloadable from `https://price-paid-data.publicdata.landregistry.gov.uk/pp-YYYY.csv`
- ✅ New-build flag confirmed in column 6 of PPD
- ✅ 132K new builds in 2022 alone; ~260K over the 2021–2023 scheme period
- ✅ postcodes.io confirmed working for postcode-to-region assignment
- ✅ 9 distinct regional caps verified: NE £186,100; NW £224,400; Y&H £228,100; EM £261,900; WM £255,600; SW £349,000; EoE £407,400; SE £437,600; London £600,000
- ✅ Built-in placebos: second-hand properties (not eligible), London (cap unchanged)
- ✅ Key literature: Best & Kleven (2018, REStud) on SDLT notches; Carozzi et al. (2024, JUE) on HtB

---

## Idea 2: Flood Risk, Insurance Subsidies, and Property Values — A Spatial Regression Discontinuity at England's Flood Zone Boundaries

**Policy:** Environment Agency flood zone designations classify all land in England into Zone 1 (low risk, <0.1% annual chance), Zone 2 (medium, 0.1–1%), and Zone 3 (high, >1%). Zone 3 properties face mandatory flood risk assessments for planning, higher insurance premiums, and disclosure requirements. In April 2016, Flood Re introduced subsidized flood insurance for properties built before January 2009 in high-risk zones, capping premiums by Council Tax band (£192–£1,613/year).

**Outcome:** HM Land Registry PPD (geocoded via NSPL postcode coordinates) × EA Flood Zone shapefiles (freely downloadable GeoPackage, ~1 GB). Distance from each property to the nearest Zone 2/3 boundary is the running variable.

**Identification:** Spatial RDD at the Zone 2/3 boundary:
- Running variable: distance to Zone 2/3 boundary (negative = inside Zone 3, positive = Zone 2)
- Treatment: Zone 3 classification → higher insurance costs, planning restrictions, disclosure
- Temporal variation: Flood Re (April 2016) reduced insurance costs for pre-2009 Zone 3 properties → difference-in-discontinuities (before/after Flood Re)
- Eligibility variation: pre-2009 vs post-2009 construction → triple interaction (spatial × temporal × construction-date eligibility)
- Multiple boundaries: Zone 1/2 boundary provides additional cutoff

**Why it's novel:** Beltran, Maddison & Elliott (2018, Ecological Economics; 2019, JEEM) study UK flood capitalization using hedonic and repeat-sales methods. **No paper uses a spatial RDD at EA flood zone boundaries.** US studies (Bin & Polasky 2004; Bin & Landry 2013) use hedonic methods at FEMA zones. The Flood Re policy shock adds a mechanism decomposition: is the price discount driven by insurance costs (attenuated by Flood Re for pre-2009 properties) or pure risk perception (unaffected by Flood Re)?

**Feasibility check:**
- ✅ EA flood zone shapefiles freely downloadable (GeoPackage format)
- ✅ NSPL provides postcode-to-coordinate mapping for geocoding PPD
- ✅ SpatialRDD R package available for implementation (Lehner, CRAN)
- ⚠️ Postcode centroid precision (~15 households/postcode) introduces measurement error at boundary
- ⚠️ GIS computation intensive: distance from millions of properties to complex polygon boundaries
- ✅ Built-in placebos: Zone 1/2 boundary (smaller insurance differential), owner-occupied vs rented, pre/post-2009 construction
- ✅ Key literature: Keele & Titiunik (2015) spatial RDD methods; Beltran et al. (2018, 2019)

---

## Idea 3: Stamp Duty Holidays and Housing Market Dynamics — Temporal RDD at the 2021 Cliff Edge

**Policy:** The COVID-era SDLT holiday raised the nil-rate band from £125K to £500K (July 8, 2020), then stepped down to £250K (July 1, 2021), then returned to £125K (October 1, 2021). These created two sharp temporal discontinuities where the effective tax rate jumped overnight.

**Outcome:** HM Land Registry PPD — transaction dates allow precise assignment relative to deadline. Universe of ~850K annual transactions.

**Identification:** Temporal RDD at the July 1 and October 1, 2021 deadlines:
- Running variable: days relative to deadline
- Treatment: pre-deadline = reduced SDLT; post-deadline = standard SDLT
- The stepped phase-down (£500K → £250K → £125K) creates multiple notches at different price points
- Combine with bunching analysis at the £250K threshold during the interim period

**Why it's novel:** Best & Kleven (2018, REStud) study the 2008–09 SDLT holiday. Besley, Meads & Surico (2014, JPubE) also study 2008–09. **The 2020–21 COVID holiday with its unique two-step phase-down has received less rigorous bunching analysis.** The phased structure creates a "dosage" design where the tax change varies by price band.

**Feasibility check:**
- ✅ Data confirmed: PPD has exact transaction dates
- ✅ ~850K transactions/year, massive sample around each deadline
- ⚠️ Existing literature on SDLT notches is extensive (less novelty)
- ⚠️ COVID confounds: the holiday coincided with pandemic-era housing market dynamics
- ✅ Multiple discontinuities (July and October 2021) provide internal replication
- ✅ Key literature: Best & Kleven (2018), Besley et al. (2014)
