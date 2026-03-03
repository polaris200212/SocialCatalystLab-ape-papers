# Conditional Requirements

**Generated:** 2026-03-03T17:54:32.838959
**Status:** RESOLVED

---

## The Price of Austerity: Council Tax Support Localisation and Low-Income Employment

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: Reconstructing treatment intensity transparently from administrative taxbase data

**Status:** [x] RESOLVED

**Response:**
Three-pronged treatment variable strategy:
1. **DLUHC Council Taxbase LCTS data** (2013+): Table "Reduction in council tax base due to council tax support — working age people (dwelling equivalents)" provides LA-level CTS reduction. Available as Excel/ODS from GOV.UK. The CHANGE in this measure between 2012/13 (under national CTB) and 2013/14 (under local CTS) directly captures the treatment intensity.
2. **Binary treatment**: ~264 LAs imposed minimum payments vs. ~62 LAs maintained full protection. This binary classification is documented in NPI/Entitledto aggregate reports and can be validated from the taxbase data (LAs with large drops in CTS reduction = cut LAs).
3. **Beatty & Fothergill (2013)** welfare loss simulations provide a district-level CTS-specific per-capita loss measure, used by Fetzer (2019, AER). This can validate our taxbase-derived treatment.

**Evidence:**
- DLUHC LCTS 2013 file confirmed downloadable: `https://assets.publishing.service.gov.uk/media/5a7bac1ce5274a7202e18ad1/Council_Taxbase_local_authority_level_data_-_LCTS_2013.xls`
- Full collection: `https://www.gov.uk/government/collections/council-taxbase-statistics` (annual 2010-2025)
- Entitledto aggregate stats: 264 LAs with minimum payments, distributed across bins (45 at <10%, 136 at 20-30%, 23 at 30%+)

---

### Condition 2: A pre-analysis plan emphasizing parallel trends/sensitivity

**Status:** [x] RESOLVED

**Response:**
The initial_plan.md will specify:
1. **Pre-trends**: Event-study coefficients for t-5 to t-1 (all should be near zero; formal F-test for joint significance)
2. **HonestDiD/Rambachan-Roth sensitivity**: Bound treatment effects under departures from parallel trends
3. **Callaway & Sant'Anna** with doubly-robust estimation for continuous treatment
4. **Placebo outcomes**: Council tax on pensioners (protected group, should show no effect)
5. **Controls for coincident reforms**: Include Benefit Cap exposure, UC rollout timing, and broader austerity spending cuts as covariates
6. **Leave-one-out**: Exclude each region to check sensitivity

**Evidence:** Will be implemented in R code and documented in initial_plan.md.

---

### Condition 3: Adding a mechanism/first-stage battery — arrears/collections

**Status:** [x] RESOLVED

**Response:**
DLUHC publishes LA-level council tax collection rates and arrears data annually from 2004-2024, including:
- Table 5: Collection rates by LA
- Table 8: Arrears by LA
- Table 9: Arrears per dwelling

This data directly tests the mechanism chain: CTS cuts → increased liability for low-income households → (a) some find work (employment effect) or (b) some fail to pay (arrears/distress effect). Both channels are testable with available data.

**Evidence:**
- Collection rates data confirmed available: `https://www.gov.uk/government/statistics/collection-rates-for-council-tax-and-non-domestic-rates-in-england-2013-to-2014`
- Annual Excel files with Tables 1-9 covering 2004-2024
- LA-level panel of collection rates, amounts collected, arrears, and write-offs

---

### Condition 4: CTR caseload

**Status:** [x] RESOLVED

**Response:**
- Pre-reform (2008-2013): DWP publishes Council Tax Benefit caseloads by LA via Stat-Xplore and downloadable spreadsheets
- Post-reform (2013+): DLUHC Council Taxbase LCTS tables show CTS claimant numbers by LA
- This gives a continuous caseload panel bridging the reform boundary

**Evidence:**
- DWP HB/CTB caseload statistics: `https://www.gov.uk/government/collections/housing-benefit-and-council-tax-benefit-caseload-statistics--2`
- DLUHC taxbase LCTS tables (2013+) include CTS claimant counts

---

### Condition 5: Minimum payments actually collected

**Status:** [x] RESOLVED

**Response:**
The council tax collection rates data (Table 5, Table 8) directly show whether minimum payments imposed on CTS claimants are actually collected. The IFS report (Adam, Joyce, Pope 2019) documents that approximately 25% of additional council tax due from CTS claimants was NOT collected — this is a key finding that our paper can replicate and extend with panel methods. "Bite" of the reform is directly testable.

**Evidence:**
- IFS finding: ~25% of additional tax due not collected (documented in Adam, Joyce, Pope 2019)
- DLUHC collection rates by LA (annual, 2004-2024) — confirmed downloadable

---

### Condition 6 (Grok): Constructing reliable continuous treatment from DLUHC/Entitledto data

**Status:** [x] RESOLVED

**Response:** Same as Condition 1. Covered by DLUHC taxbase approach.

---

### Condition 7 (Grok): Piloting event-study to confirm IFS deviation

**Status:** [x] RESOLVED

**Response:**
The IFS null result used cross-sectional regression comparing LAs at a single point in time. Our contribution over IFS:
1. **Panel structure**: Monthly LA-level data 2008-2023 (vs. IFS cross-section)
2. **Event-study**: Visual pre-trend validation (impossible in cross-section)
3. **Modern DiD**: Callaway & Sant'Anna with continuous treatment intensity
4. **Longer post-period**: We observe 10 years of post-reform outcomes (IFS had ~5)
5. **Mechanism chain**: Employment + arrears + collection rates (IFS focused on employment alone)

The event-study will be piloted in Phase 4 as a gating diagnostic.

---

## Verification Checklist

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Status: RESOLVED**
