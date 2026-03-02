# Conditional Requirements

**Generated:** 2026-02-23T13:10:04.218530
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Does Sanitation Drive Development? Satellite Evidence from India's Swachh Bharat Mission

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: validating ODF timing with independent sanitation/use measures such as NFHS/other surveys

**Status:** [x] RESOLVED

**Response:**

We will validate ODF declaration dates against independent sanitation measures in two ways:
1. **NFHS-4 (2015-16) vs NFHS-5 (2019-21) cross-validation:** Compare state-level changes in "improved sanitation facility" and "open defecation" rates (NFHS district factsheets are publicly available) against ODF declaration timing. States that declared ODF earlier should show larger improvements in NFHS sanitation indicators.
2. **NSS 76th Round (2018) sanitation data:** The 76th round specifically covers drinking water, sanitation, and hygiene. State-level tabulations are published and can validate whether ODF-declared states actually showed reduced open defecation.
3. **Robustness check in paper:** We will include a "first-stage" analysis showing that ODF declarations correlate with actual sanitation improvements, using NFHS district factsheets as external validation. If ODF dates are pure politics with no behavioral change, we'd expect no first-stage — and would report that honestly.

**Evidence:**

NFHS-4 and NFHS-5 district factsheets available at https://rchiips.org/nfhs/. NSS 76th round sanitation data published by MoSPI. Both are freely accessible and will be incorporated as validation exercises in the paper.

---

### Condition 2: using monthly VIIRS or an exposure-weighted treatment definition

**Status:** [x] RESOLVED

**Response:**

We will use an **exposure-weighted treatment definition** rather than a binary treatment dummy. Specifically:
1. **Fractional exposure in the ODF year:** If a state declares ODF in month M of year Y, the treatment variable for year Y equals (12-M+1)/12 (fraction of the year exposed). This avoids the bias from treating mid-year declarations as full-year treatment.
2. **Primary specification:** Full binary treatment for years after ODF declaration year; fractional for the declaration year itself.
3. **Robustness:** We will also report results coding the ODF year as either fully treated or fully untreated, showing stability across definitions.
4. **Monthly VIIRS:** Raw monthly VIIRS composites are available from NOAA but require significant processing (cloud masking, stray light correction) and are not pre-aggregated to SHRUG villages. We judge the exposure-weighted annual approach sufficient and more transparent, but will note monthly analysis as a potential extension.

**Evidence:**

This approach follows Goodman-Bacon (2021) and Callaway & Sant'Anna (2021) guidance on handling partial exposure in staggered DiD. The SHRUG provides annual composites; exposure weighting is the standard solution in the literature when monthly data is unavailable at the desired geographic level.

---

### Condition 3: reporting rural-only/nightlights variants

**Status:** [x] RESOLVED

**Response:**

SHRUG's village-level data includes a rural/urban classification. We will report:
1. **Primary specification:** District-level aggregated nightlights (all villages + towns within district).
2. **Rural-only specification:** Aggregate nightlights using only rural villages (excluding Census towns and statutory towns). SBM-Gramin specifically targets rural areas, so rural-only nightlights provide cleaner treatment-relevant variation.
3. **Population-weighted nightlights:** Weight village nightlights by Census 2011 population to capture per-capita economic activity rather than spatial extent.
4. **Alternative nightlights measures:** Report results using (a) total luminosity, (b) mean luminosity, (c) max luminosity, and (d) lit area (number of cells with non-zero light) as outcomes.

The rural-only specification will be prominently reported alongside the full-district specification.

**Evidence:**

SHRUG crosswalk (`shrid_pc11dist_key.csv`) maps villages to districts. Census PCA provides rural/urban classification for each SHRID. The VIIRS data includes both `viirs_annual_sum` (total) and `viirs_annual_mean` (mean) at village level, enabling flexible aggregation.

---

### Condition 4: excluding major urban pixels to reduce dilution

**Status:** [x] RESOLVED

**Response:**

We will address urban dilution through multiple strategies:
1. **Rural-only aggregation:** Primary robustness specification aggregates nightlights from rural villages only (see Condition 3). This mechanically excludes major urban centers.
2. **Exclude top-coded/saturated pixels:** For DMSP, pixels at maximum intensity (63) are top-coded and reflect large cities. We will exclude SHRIDs where max_light = 63 in any pre-treatment year.
3. **Population-based trimming:** Exclude SHRIDs in the top decile of Census 2011 population (large towns/cities) as a robustness check.
4. **Heterogeneity by urbanization:** Split sample into (a) predominantly rural districts (>70% rural population), (b) mixed districts, and (c) predominantly urban districts. Report treatment effects separately. We expect stronger effects in rural districts where SBM-G was targeted.

**Evidence:**

Census 2011 PCA provides total population by SHRID. DMSP provides `dmsp_max_light` for saturation identification. Urban/rural classification available in SHRUG crosswalk. These mechanical filters are standard in the nightlights literature (Henderson et al. 2012, Asher & Novosad 2020).

---

## Piped Water and Rural Development: Early Evidence from India's Jal Jeevan Mission

**Rank:** #2 | **Recommendation:** CONSIDER

*Not pursuing this idea — proceeding with Idea 1 (SBM). All conditions marked NOT APPLICABLE.*

### Condition 1–5: All NOT APPLICABLE (not pursuing this idea)

**Status:** [x] NOT APPLICABLE

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Status: RESOLVED**
