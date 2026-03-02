# Conditional Requirements

**Generated:** 2026-02-27T11:12:24.156679
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

---

## Flood Re and the Price of Climate Risk — How Government Reinsurance Recapitalized Flood-Prone Property (Idea 3)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: obtaining defensible pre/post-2009 construction-year data

**Status:** [x] RESOLVED

**Response:**

Three complementary approaches provide defensible construction-year classification:

1. **EPC Register (primary):** The Domestic EPC Register (epc.opendatacommunities.org) contains CONSTRUCTION_AGE_BAND for ~20M+ certificates. Bands include: "≤2006", "2007-2011", "2012 onwards". The "2007-2011" band straddles the Flood Re eligibility cutoff (1 Jan 2009). **Resolution:** Use a "donut" specification that compares properties in bands "≤2006" (definitely eligible) vs "≥2012" (definitely not eligible), excluding the ambiguous "2007-2011" band. This provides clean classification for the vast majority of properties.

2. **Land Registry new-build flag (supplementary):** The PPD "Old/New" field identifies new-build transactions. Properties first sold as new-build with transaction date ≥2009 are definitively post-2009 builds (NOT Flood Re eligible). Properties never flagged as new-build were built before 1995 (start of PPD data) → definitely Flood Re eligible.

3. **Sensitivity:** Run main specification with the donut approach AND robustness checks where (a) all "2007-2011" properties are classified as eligible (conservative), (b) all "2007-2011" properties are classified as ineligible (aggressive), and (c) Land Registry new-build dates are used for the "2007-2011" EPC band.

**Evidence:**

EPC data documentation confirms CONSTRUCTION_AGE_BAND field: https://epc.opendatacommunities.org/docs/guidance. Bands: "before 1900", "1900-1929", "1930-1949", "1950-1966", "1967-1975", "1976-1982", "1983-1990", "1991-1995", "1996-2002", "2003-2006", "2007-2011", "2012 onwards". Bulk download available as CSV. Land Registry PPD column 6 is "Old/New build" (Y=new build, N=not new build).

---

### Condition 2: EPC "construction age band" or another address-level attribute source

**Status:** [x] RESOLVED

**Response:**

Same as Condition 1. The EPC register provides address-level construction age bands. Linkage to Land Registry: EPC records contain full address (building reference number, address1, address2, postcode). Land Registry PPD contains PAON, SAON, Street, Postcode. Matching on postcode + property reference/address fields provides the link. For unmatched records, fall back to Land Registry new-build flag.

**Evidence:**

EPC download format documented at https://guides.opendatacommunities.org/article/40-energy-performance-certificates-download. Fields include: LMK_KEY, ADDRESS1, ADDRESS2, ADDRESS3, POSTCODE, BUILDING_REFERENCE_NUMBER, CONSTRUCTION_AGE_BAND.

---

### Condition 3: implementing robust GIS assignment + sensitivity to boundary error

**Status:** [x] RESOLVED

**Response:**

1. **Flood zone classification:** Environment Agency "Flood Map for Planning - Flood Zones" available as GeoPackage from data.gov.uk (https://www.data.gov.uk/dataset/104434b0-5263-4c90-9b1e-e43b1d57c750/flood-map-for-planning-flood-zones1). Contains Flood Zone 2 (medium probability, 0.1-1% annual) and Flood Zone 3 (high probability, >1% annual) polygons.

2. **Postcode geocoding:** ONS NSPL (National Statistics Postcode Lookup) provides postcode centroids with Easting/Northing and Lat/Lon. Download from geoportal.statistics.gov.uk.

3. **Spatial join:** R `sf` package — read GeoPackage, project to British National Grid (EPSG:27700), perform point-in-polygon join of postcode centroids to flood zone polygons.

4. **Sensitivity to boundary error:**
   - *Buffer zone:* Exclude properties within 50m of flood zone boundaries (where postcode centroid may misassign)
   - *Alternative flood indicators:* EA flood history data (actual flood events at station level) as independent validation
   - *Postcode-level vs LSOA-level:* Compare results using postcode-level classification vs LSOA-level (proportion of LSOA in flood zone)
   - *Council Tax band interaction:* Flood Re premiums are capped by Council Tax band (A-H), so lower-band properties in flood zones benefit more — test for dosage effects

**Evidence:**

EA Flood Map for Planning confirmed at data.gov.uk. ONS NSPL download confirmed at geoportal.statistics.gov.uk. R sf package supports GeoPackage reading and spatial joins. postcodes.io API confirmed working (returns lat/lon for any UK postcode).

---

### Condition 4: pre-trend/event-study checks

**Status:** [x] RESOLVED

**Response:**

1. **Event study design:** Quarterly event study around April 2016 (Flood Re launch), with leads (Q1 2012–Q1 2016) and lags (Q2 2016–Q4 2024). Plot coefficients for flood zone × quarter interactions. Joint F-test on pre-trend coefficients (Q1 2012–Q1 2016 should be insignificant).

2. **Anticipation effects:** Test for effects around key announcement dates:
   - Water Act 2014 (Royal Assent 14 May 2014) — legislation establishing Flood Re
   - Flood Re final regulations (September 2015)
   - Flood Re launch (4 April 2016)
   If anticipation detected, redefine treatment date to the announcement date.

3. **HonestDiD sensitivity:** Apply Rambachan and Roth (2023) HonestDiD framework to bound treatment effects under limited violations of parallel trends.

4. **Placebo timing:** Run the same DD specification using fake treatment dates (2012, 2013, 2014) — coefficients should be near zero.

**Evidence:**

Standard methodology for single-event DiD designs. HonestDiD R package available on CRAN.

---

### Condition 5: placebo zones/bands

**Status:** [x] RESOLVED

**Response:**

1. **Flood Zone 1 placebo:** Properties in Flood Zone 1 (low probability, <0.1% annual) should NOT be affected by Flood Re (insurance was already affordable). Run the same DD specification using FZ1 as "treatment" — coefficient should be near zero.

2. **Post-2009 build placebo:** Properties built ≥2009 in Flood Zones 2/3 are NOT eligible for Flood Re. Compare their price dynamics around April 2016 to pre-2009 builds in the same flood zone. If Flood Re is driving the effect, post-2009 builds should show no change (within-flood-zone placebo).

3. **Geographic placebo:** Run DD for properties in areas with historically minimal flood insurance issues (inland, well-drained, distant from rivers/coast). These should show no flood-zone premium change around 2016.

4. **Council Tax band gradient:** Flood Re caps premiums at band-specific levels. Lower bands (A–D) face lower caps, so the subsidy is larger for cheaper properties. Test for a monotone Council Tax band gradient in the treatment effect — stronger effects for lower bands provides dose-response evidence.

**Evidence:**

EA Flood Zone 1 data available in same GeoPackage. Council Tax bands available from VOA (Valuation Office Agency) or NSPL lookup. EPC register includes current energy rating which correlates with property age/value.

---

## The Waterbed Effect — Crime Displacement from Selective Licensing (Idea 1)

**Rank:** #2 | **Recommendation:** PURSUE

### Condition 1: digitizing/obtaining exact designation boundaries

**Status:** [x] NOT APPLICABLE

**Response:**

Pursuing Idea 3 (Flood Re) as the primary paper. Selective Licensing conditions documented here for reference but not required for current execution. If Flood Re encounters insurmountable data issues, these conditions will be revisited.

---

### Condition 2: assigning treatment at LSOA-within-designation level

**Status:** [x] NOT APPLICABLE

**Response:** Same as above.

---

### Condition 3: dropping pre-2010 treated adopters

**Status:** [x] NOT APPLICABLE

**Response:** Same as above.

---

### Condition 4: pre-trend diagnostics + sensitivity to endogenous designation

**Status:** [x] NOT APPLICABLE

**Response:** Same as above.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
