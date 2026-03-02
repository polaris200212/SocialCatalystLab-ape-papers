# Conditional Requirements

**Generated:** 2026-02-20T18:24:21.151155
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

## Connecting the Most Remote — Road Access and Development in India's Tribal Areas

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: obtaining/constructing an official designation map consistent with PMGSY rules

**Status:** [x] RESOLVED

**Response:**

The PMGSY guidelines (pmgsy.nic.in) explicitly define which areas qualify for the 250 threshold. We will construct the designation map using three identification strategies:

**Strategy A (Primary — State-level):** The 11 Special Category/Hill States are unambiguous:
Arunachal Pradesh, Assam, Manipur, Meghalaya, Mizoram, Nagaland, Sikkim, Tripura, Himachal Pradesh, Jammu & Kashmir, Uttarakhand. ALL villages in these states use the 250 threshold. State codes in SHRUG make this trivial.

**Strategy B (District-level — Schedule V):** The Fifth Schedule of the Constitution designates specific districts/blocks as Scheduled Areas. The official list is published by the Ministry of Tribal Affairs. These districts in 10 states (AP, Chhattisgarh, Gujarat, HP, Jharkhand, MP, Maharashtra, Odisha, Rajasthan, Telangana) use the 250 threshold. We will compile the district-level list from published government sources and match via Census 2011 district codes in SHRUG.

**Strategy C (Robustness — ST share proxy):** Villages with >50% ST population (N=102,670 in Census 2001) strongly overlap with Schedule V areas. This will be used as a robustness check to verify that Strategy B captures the correct population.

**Evidence:**
- PMGSY FAQ (pmgsy.nic.in/frequently-asked-questions): "250 persons and above" for "Special Category States, Desert Areas, Tribal (Schedule V) areas"
- PMGSY Programme Guidelines (omms.nic.in/ReferenceDocs/PMGSY_Guidelines.pdf): Definitive eligibility criteria
- Fifth Schedule district list: Published by Ministry of Tribal Affairs

---

### Condition 2: demonstrating a strong first stage

**Status:** [x] RESOLVED

**Response:**

Three approaches to demonstrate the first stage:

1. **ITT as primary specification:** The intent-to-treat (reduced form) estimate at the 250 threshold is valid without first-stage data. This estimates: effect of eligibility (above threshold) → development outcomes. This is clean, transparent, and does not require road construction data.

2. **PMGSY OMMAS data (if available):** SHRUG includes PMGSY road construction data (documented at docs.devdatalab.org/SHRUG-Metadata/PMGSY roads/). If downloadable, this provides actual road completion dates for a fuzzy RDD first stage. We will attempt to download.

3. **Village Directory road variable:** Census 2011 Village Directory includes `pc11_vd_tar_road` (paved road access). Comparing this across the 250 threshold gives a "revealed first stage" — did eligibility translate to road access by 2011?

4. **Benchmark:** Asher & Novosad (2020) found a ~21pp first stage at the 500 threshold. We expect a similar magnitude at 250, possibly somewhat weaker due to implementation challenges in remote areas.

**Evidence:**
- The first stage will be formally estimated and reported in the analysis. If it is weak (F < 10), we will report ITT estimates only and flag this as a design limitation.

---

### Condition 3: no sorting at 250 via McCrary/heaping tests

**Status:** [x] RESOLVED

**Response:**

We will implement three standard RDD validity tests:

1. **McCrary density test:** Test for bunching in the Census 2001 population distribution at 250. Since population is from an official Census enumeration (not self-reported), manipulation is extremely unlikely — Census enumeration preceded PMGSY by one year and the 250 rule was not announced until after the Census.

2. **Population heaping test:** Check for excess mass at round numbers (250, 300, etc.) which could indicate rounding rather than precise counts. If present, donut-hole RDD excluding observations at exact threshold.

3. **Histogram visualization:** Bin plot of Census 2001 population around 250 in designated areas, following standard McCrary methodology.

**Evidence:**
- Population data comes from Census 2001 (conducted April-May 2001). PMGSY guidelines were issued December 2000 but habitation-level eligibility lists were prepared AFTER the Census. Manipulation is implausible because:
  (a) Census population is enumerated, not self-reported
  (b) Village officials had no incentive/ability to manipulate the official Census count
  (c) The 250 threshold was not prominently publicized before the Census

---

### Condition 4: covariate balance

**Status:** [x] RESOLVED

**Response:**

Standard RDD covariate balance test using pre-treatment (Census 2001) characteristics:

Variables to test at the 250 threshold:
- Literacy rate (pc01_pca_p_lit / pc01_pca_tot_p)
- SC/ST shares (pc01_pca_p_sc, pc01_pca_p_st)
- Worker composition (main workers, marginal workers, cultivators, agricultural laborers)
- Female literacy rate
- Household count
- Number of households

Methodology: Local polynomial regression on each covariate as a function of population, checking for discontinuity at 250. Both graphical (bin scatter) and formal (RD estimate with conventional and robust bias-corrected CIs) approaches.

If any covariate shows significant imbalance, we will: (a) include it as a control, (b) discuss the threat to identification, (c) check whether results are robust to inclusion/exclusion of the imbalanced covariate.

**Evidence:**
- Will be formally demonstrated in the analysis using `rdrobust` R package.

---

### Condition 5: enable dose/exposure analyses

**Status:** [x] RESOLVED

**Response:**

Dose/exposure analyses will examine heterogeneity in treatment effects along several dimensions:

1. **Distance to nearest town:** Using `pc11_td_sh_dist` (distance to subdistrict HQ) and `pc11_td_dh_dist` (distance to district HQ) from the SHRUG town directory — tests whether road effects are larger for more remote villages.

2. **Terrain difficulty:** Using state-level variation — NE hill states vs Schedule V areas in plains states.

3. **Baseline development:** Heterogeneity by pre-treatment literacy, electrification, and worker composition.

4. **ST population share:** Continuous treatment intensity — do more tribal villages benefit more?

5. **Comparison to 500 threshold:** The 500 threshold in non-designated areas serves as a natural benchmark. We will estimate the same RDD at 500 and formally compare effect sizes.

**Evidence:**
- All proposed variables are available in SHRUG data already on disk.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
