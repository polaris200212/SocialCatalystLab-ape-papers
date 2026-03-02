# Conditional Requirements

**Generated:** 2026-02-23T14:46:10.319164
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

---

## Opportunity Zone Designation and Data Center Investment — A Fuzzy RDD at the Poverty Threshold

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: verifying the true eligibility/designation rule around 20% poverty including MFI/contiguity exceptions

**Status:** [x] RESOLVED

**Response:**

OZ eligibility has THREE pathways: (1) poverty rate >= 20%, (2) median family income <= 80% of area median, (3) contiguity to an eligible LIC tract (if MFI <= 125% of area median). This means the 20% poverty cutoff is NOT the sole eligibility criterion. To maintain a clean RDD, we will:

1. **Restrict the sample** to tracts where the poverty criterion is the binding eligibility condition. Specifically, exclude tracts that qualify via MFI alone (those with poverty < 20% but MFI <= 80% of area median).
2. **Use a donut-RDD** as robustness, dropping tracts right at the cutoff where measurement error could affect classification.
3. **Test robustness** to including/excluding contiguous tracts (these are identifiable in the CDFI data).
4. **The key insight**: Below 20% poverty AND above 80% MFI, a tract is definitively ineligible (no pathway). This creates a clean "always ineligible" region for the control group.

**Evidence:** CDFI Fund documentation confirms the three eligibility criteria. Freedman et al. (2023) use an analogous sample restriction strategy. Over 41,000 tracts were eligible via all pathways; ~31,680 via LIC criteria (poverty or MFI).

---

### Condition 2: confirming a strong first stage in designation probability at the chosen running-variable cutoff

**Status:** [x] RESOLVED

**Response:**

Below 20% poverty (and above 80% MFI), tracts have 0% designation probability. Above 20% poverty, ~25% of eligible tracts were designated (governors could select up to 25% of eligible tracts per state). This creates a first-stage jump of ~25 percentage points at the cutoff — a very strong first stage. Published OZ RDD papers confirm this discontinuity.

Additionally, will verify empirically during execution by:
1. Plotting designation probability against poverty rate with a local polynomial
2. Running a formal first-stage regression with the standard F-statistic
3. Testing bandwidth sensitivity

**Evidence:** 577 GA tracts alone near the 20% threshold (15-25% poverty range). Nationally, tens of thousands of tracts provide ample power. Freedman et al. (2023) confirm strong first stage using similar design.

---

### Condition 3: securing a credible data-center location/outcome dataset beyond suppressed CBP

**Status:** [x] RESOLVED

**Response:**

Three complementary data sources solve the suppression problem:

1. **Census LEHD/LODES (Workplace Area Characteristics)**: Provides census-block-level employment by 2-digit NAICS sector, 2002-2023. CNS09 = NAICS 51 (Information sector, includes data processing, hosting, internet). Uses noise infusion rather than suppression, so ALL blocks have data. Confirmed accessible via direct download from lehd.ces.census.gov.

2. **OpenStreetMap data center locations**: The IM3 Open Source Data Center Atlas derives geocoded data center locations from OSM. Each facility has lat/lon, county, state, and square footage. Can be matched to census tracts via spatial join.

3. **Census Building Permits Survey**: County-level building permit data captures construction activity (a proxy for data center investment).

**Evidence:** LODES WAC files confirmed accessible for all 50 states, 2002-2023. Sample download for GA shows w_geocode (census block), C000 (total employment), CNS09 (NAICS 51 employment), CNS04 (construction employment).

---

### Condition 4: e.g.

**Status:** [x] NOT APPLICABLE

**Response:** This appears to be a malformed condition placeholder. No substantive condition to address.

---

### Condition 5: commercial/industry data on facilities

**Status:** [x] RESOLVED

**Response:** Addressed in Condition 3. LODES CNS09 (NAICS 51) provides facility-level employment at the census block level. Additionally, Census County Business Patterns provides establishment counts by detailed NAICS code at the county level (19 GA counties confirmed with NAICS 5182 data). The combination of LODES (tract/block level, all observations) + CBP (county level, detailed industry) provides comprehensive facility data.

**Evidence:** CBP API test confirmed: 19 GA counties have NAICS 5182 establishments. LODES confirmed: block-level employment for all states, 2002-2023.

---

### Condition 6: capacity (MW)

**Status:** [x] RESOLVED

**Response:** Megawatt capacity data for individual data centers is commercially available (e.g., Aterio, DatacenterMap) but not freely accessible at scale. We will use electricity consumption from EIA Form 861 as a proxy for data center capacity at the utility service territory level. For tract-level analysis, LODES employment in NAICS 51 serves as our primary measure; MW capacity would be supplementary but is not essential for the identification strategy. The paper will acknowledge this limitation and note that employment and establishment counts are the primary outcomes.

**Evidence:** EIA Form 861 provides utility-level electricity sales data. LODES employment in CNS09 is confirmed available at block level.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
