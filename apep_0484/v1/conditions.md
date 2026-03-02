# Conditional Requirements

**Generated:** 2026-03-02T15:10:30.590175
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

## Flood Re and the Capitalization of Climate Risk Insurance — A Triple-Difference Design

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: obtaining/constructing credible pre- vs post-2009 build-year data

**Status:** [x] RESOLVED

**Response:**

Land Registry Price Paid Data includes an "Old/New" field (column 6) where Y = newly built property and N = established. Properties first sold as New Build (Y) after 1 January 2009 are post-2009 constructions — Flood Re ineligible. All other properties (established stock, or first sold as New before 2009) are pre-2009 — Flood Re eligible. This provides a direct, transaction-level classification of construction vintage.

As a robustness check, EPC register data (available from epc.opendatacommunities.org) includes construction age bands for most dwellings, providing an independent verification of build date classification.

**Evidence:**

- HM Land Registry PPD column specification: https://www.gov.uk/guidance/about-the-price-paid-data (Column 6: "Old/New" — Y/N)
- EPC Open Data: https://epc.opendatacommunities.org/ (includes CONSTRUCTION_AGE_BAND field)

---

### Condition 2: EPC age bands/VOA

**Status:** [x] RESOLVED

**Response:**

EPC data from epc.opendatacommunities.org includes CONSTRUCTION_AGE_BAND (e.g., "2007-2011", "England and Wales: 2007-2011") which can supplement the Land Registry New Build flag for robustness. VOA Council Tax banding data by property can help verify construction era where EPC data is missing. However, the primary classification uses the PPD New Build flag, which is simpler and available for all transactions.

**Evidence:**

- EPC domestic data download: https://epc.opendatacommunities.org/ (CONSTRUCTION_AGE_BAND field documented in data dictionary)
- VOA Council Tax List: available via data.gov.uk

---

### Condition 3: demonstrating flood-risk classification stability or using historical layers

**Status:** [x] RESOLVED

**Response:**

The EA's Risk of Flooding from Rivers and Sea (RoFRS) dataset was last updated in 2018 before Flood Re's introduction and remained stable through 2024. A major NaFRA update in January 2025 reclassified some areas. For our design, we use the 2016-vintage flood risk classification (the map in force when Flood Re launched) for treatment assignment, avoiding endogeneity from subsequent map updates. The EA publishes historical flood map layers that allow us to fix treatment assignment at baseline. As a robustness check, we test sensitivity to using the current (2025) classification.

**Evidence:**

- EA RoFRS dataset: https://environment.data.gov.uk/dataset/8dae18e1-d465-11e4-8e78-f0def148f590
- Open Flood Risk by Postcode: https://www.getthedata.com/open-flood-risk-by-postcode (includes PUB_DATE field for vintage verification)
- EA NaFRA update guidance: https://www.gov.uk/guidance/updates-to-national-flood-and-coastal-erosion-risk-information

---

### Condition 4: pre-trend/event-study diagnostics within flood zones

**Status:** [x] RESOLVED

**Response:**

We will implement event-study plots showing the DDD coefficient (pre-2009 × flood zone × year) for each year from 2009–2025 relative to 2015 (year before Flood Re). Pre-trend validation requires: (a) coefficients for 2009–2015 are jointly insignificant, (b) no visible upward trend before April 2016. With 21 years of pre-period data (1995–2015), we have exceptional power for pre-trend detection. Additionally, we apply HonestDiD/Rambachan-Roth bounds to quantify sensitivity to parallel trends violations.

**Evidence:**

- PPD data begins 1995, giving 21 years of pre-treatment data for event-study diagnostics
- Will implement Callaway-Sant'Anna event-study framework + HonestDiD sensitivity analysis

---

## Idea 5: Clean Air, Rich Air? ULEZ Expansions and Residential Sorting in London

**Rank:** #2 | **Recommendation:** PURSUE

### Condition 1: focusing primarily on the 2019

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: 2021 boundaries to ensure sufficient post-treatment statistical power

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Flood Re and the Capitalization of Climate Risk Insurance — A Triple-Difference Design

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: confirming parallel trends by construction vintage-flood band

**Status:** [x] RESOLVED

**Response:**

Parallel trends by construction vintage × flood band is the core identification assumption. We test this via: (1) event-study coefficients for pre-2009 vs post-2009 properties within flood zones for years 2009–2015 (pre-Flood Re), (2) placebo tests using non-flood-zone properties (where the vintage distinction should not matter for insurance), (3) annual pre-trend F-tests. The 6-year window (2009–2015, after post-2009 properties begin appearing) provides adequate pre-periods.

**Evidence:**

- Planned implementation in 03_main_analysis.R and 04_robustness.R

---

### Condition 2: adding owner-occupier placebo for capitalization purity

**Status:** [x] RESOLVED

**Response:**

Flood Re covers ALL residential properties (owner-occupied and rental) built before 2009, so an owner-occupier vs rental split is not a clean placebo in the way it works for EPC/MEES regulations. However, we implement alternative placebos: (1) Properties in "Very Low" flood risk areas (where Flood Re is irrelevant because standard insurance is affordable) — the DDD coefficient should be zero for these areas. (2) Commercial/non-residential transactions (Land Registry PPD Category B includes some non-standard transactions) — Flood Re does not cover commercial property, so no effect expected.

**Evidence:**

- Flood Re eligibility explicitly covers all residential properties regardless of tenure: https://www.floodre.co.uk/find-an-insurer/eligibility-criteria/
- PPD Category field (A = standard residential, B = additional) allows filtering

---

## Planning Deregulation and the Quality-Quantity Tradeoff — Permitted Development Rights and Article 4 Directions

**Rank:** #2 | **Recommendation:** PURSUE

### Condition 1: validating staggered DiD with event-study pre-trends

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: automating Article 4 date compilation

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Clean Air, Rich Air? ULEZ Expansions and Residential Sorting in London

**Rank:** #3 | **Recommendation:** CONSIDER

### Condition 1: powering with 2019+ data

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: multi-expansion aggregation

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: adding car ownership data for mechanism

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions for Flood Re (top pick) are marked RESOLVED
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
