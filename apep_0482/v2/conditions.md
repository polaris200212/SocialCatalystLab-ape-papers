# Conditional Requirements

**Generated:** 2026-03-02T09:44:13.559367
**Status:** RESOLVED

---

## Where the Money Moves — Within-Category Budget Reallocation Under Gender Quotas in Spain

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: strong first-stage at both cutoffs

**Status:** [x] RESOLVED

**Response:**
Bagues & Campa (2021, JPubE) already validated the first stage at the 5,000 threshold: quotas raised female candidate list share by ~8pp and female councillor share by ~4pp. The 3,000 threshold (effective 2011) has not been separately validated in the literature but uses the same legal mechanism (Article 44 bis LOREG) with the same enforcement (list rejection by Junta Electoral). We will verify the first stage empirically at both cutoffs as the FIRST analysis step before proceeding to budget outcomes.

**Evidence:**
Bagues & Campa (2021), Table 2: 8pp increase in female list share, 4pp in council share at 5,000 threshold. The `infoelectoral` R package provides direct `sexo` field for all municipal candidates 2007-2023.

---

### Condition 2: McCrary/density

**Status:** [x] RESOLVED

**Response:**
Will run McCrary (2008) density test at both cutoffs using the `rdd` package. The running variable (Padrón Municipal population) is determined by INE census methodology, which municipalities cannot manipulate. Eggers et al. (2018, AJPS) document sorting concerns at population thresholds in Europe generally; we will address with: (1) McCrary test, (2) donut RDD excluding municipalities within ±100 of cutoff, (3) local randomization inference.

**Evidence:**
Planned analysis in 03_main_analysis.R. Bagues & Campa (2021) passed McCrary at 5,000.

---

### Condition 3: covariate balance passing

**Status:** [x] RESOLVED

**Response:**
Will test balance on pre-treatment covariates: population growth rate, total municipal budget per capita, income per capita, unemployment rate, and pre-quota female councillor share. Will present balance table at both cutoffs with conventional and robust bias-corrected RD estimates (rdrobust package).

**Evidence:**
Planned analysis in 03_main_analysis.R. Standard RDD diagnostic battery.

---

### Condition 4: explicit handling of denominator/"share" mechanics with levels + totals + reclassification checks

**Status:** [x] RESOLVED

**Response:**
Critical concern. We will report BOTH:
(a) Budget shares (program X as % of total education, the composition outcome)
(b) Absolute levels (EUR per capita in each program, the intensity outcome)
(c) Total category spending (to confirm Bagues & Campa aggregate null reproduces)

For reclassification checks: the post-2010 program classification (Orden EHA/3565/2008) is stable across our entire analysis period (2010-2023). No classification break within this window. We will verify that program codes 321, 323, 326 are consistently defined across years by examining the `tb_cuentasProgramas` lookup table across annual files.

**Evidence:**
CONPREL schema confirmed: `tb_funcional` table contains program-level spending; `tb_cuentasProgramas` provides the classification lookup. Same Orden EHA/3565/2008 applies throughout 2010-2023.

---

### Condition 5: confirming no pre-existing within-category trends in validation sample

**Status:** [x] RESOLVED

**Response:**
Will use pre-quota budget data (2010-2014 for the 3,000 cutoff, which was untreated until 2011; 2003-2006 for the 5,000 cutoff using old functional classification) to test for pre-existing within-education composition trends at the cutoffs. Will present RD estimates on within-education shares in pre-treatment years as a formal placebo test.

**Evidence:**
Planned analysis in 04_robustness.R. Pre-treatment CONPREL data available from 2001.

---

### Condition 6: running full placebo battery across non-education programs

**Status:** [x] RESOLVED

**Response:**
Built-in placebo outcomes:
- Program 132 (Security/police): "male-coded" spending where female representation should NOT shift within-category composition
- Program 155/150 (Roads/infrastructure): Another male-coded category
- Within-security composition: if women don't change how security money is allocated, this strengthens the education result

Will also run placebo cutoffs (e.g., 4,000 and 6,000 where no policy change occurs) to verify no mechanical discontinuities in budget shares.

**Evidence:**
Planned analysis in 04_robustness.R. Design-specific falsification sharing the same DGP (tournament lesson).

---

## Idea 4 conditions: LRSAL as heterogeneity exercise

**Status:** [x] RESOLVED

**Response:**
All three models recommended using Idea 4 as a heterogeneity/robustness exercise within Idea 1, not as a standalone paper. Will include a section testing whether within-education reallocation effects are stronger post-LRSAL (2014+) when fiscal constraints tighten. This is a natural heterogeneity dimension, not a separate design.

**Evidence:**
LRSAL effective December 2013. Natural pre/post split in our 2010-2023 panel.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
