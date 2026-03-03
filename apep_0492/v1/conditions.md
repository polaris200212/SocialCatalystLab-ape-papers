# Conditional Requirements

**Generated:** 2026-03-03T14:18:12.624576
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

All conditions for the selected idea (Idea 1: Help to Buy Regional Price Caps) are addressed below.

---

## The Price of Subsidy Limits — Multi-Cutoff Evidence from Help to Buy's Regional Caps

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: a convincing interpretation strategy without individual HTB take-up

**Status:** [x] RESOLVED

**Response:**
The design does not require individual-level HTB take-up data. We study the UNIVERSE of new-build transactions and measure distortions in the price distribution at each regional cap. The bunching estimand is the excess mass of transactions below the cap, which reveals aggregate behavioral responses of both developers (pricing decisions) and buyers (demand shifts). This is the standard approach in the bunching literature (Kleven 2016, Best & Kleven 2018). The key validation: second-hand properties (never HTB-eligible) should show NO bunching at the same price thresholds. If bunching appears only for new builds and only at HTB caps, the interpretation is unambiguously tied to the subsidy.

**Evidence:** Best & Kleven (2018, REStud) study SDLT notches without individual tax return data — they use the universe of Land Registry transactions. Carozzi et al. (2024, JUE) study HTB without individual loan-level data. Our placebo (second-hand properties) provides the identification.

---

### Condition 2: a pre-analysis plan for border bandwidths/placebos

**Status:** [x] RESOLVED

**Response:**
**Bandwidths:** For the spatial RDD at regional borders, we will use data-driven bandwidth selection (Calonico, Cattaneo & Titiunik 2014 rdrobust) as the primary specification, with fixed bandwidths of 5km, 10km, 20km, and 50km as robustness checks.

**Placebos:**
1. Second-hand properties at the same regional borders (no bunching expected)
2. Pre-2021 period at same borders (uniform £600K cap → no spatial discontinuity)
3. London borders (cap unchanged at £600K on both sides for NE comparison)
4. Donut specifications excluding properties within 1km of border
5. Regional borders where caps are similar (NW/Y&H: £224K vs £228K) as a "weak treatment" test

**Evidence:** Pre-registered in this conditions file and initial_plan.md before data analysis begins.

---

### Condition 3: at least one mechanism margin beyond price

**Status:** [x] RESOLVED

**Response:**
Three mechanism margins beyond headline prices:
1. **Property type mix:** PPD column 5 records property type (D=Detached, S=Semi, T=Terraced, F=Flat). If developers respond to lower caps by building smaller/cheaper unit types, the type distribution should shift toward flats/terraced near the cap. We test whether the share of detached homes declines just below the cap.
2. **Transaction volume:** The quantity of new-build transactions in the price range affected by the cap change. Regions where the cap dropped sharply (e.g., NE from £600K to £186K) should see fewer transactions in the £186K–£600K range post-2021.
3. **Temporal bunching:** Monthly transaction patterns reveal whether completions cluster before the scheme's March 2023 deadline (anticipation effects).

**Evidence:** PPD provides property type (column 5) and transaction dates (column 3) for all transactions.

---

### Condition 4: property type mix/quality proxies

**Status:** [x] RESOLVED (merged with Condition 3)

**Response:** Property type (D/S/T/F) from PPD column 5 serves as a quality proxy. Detached houses are highest quality/price; flats are lowest. The shift in the type distribution at the cap boundary measures developer quality adjustment. Additionally, freehold vs leasehold (column 7) proxies tenure quality.

---

### Condition 5: time-on-market if obtainable

**Status:** [x] NOT APPLICABLE

**Response:** Time-on-market is not available in Land Registry PPD (it records completion dates only, not listing dates). Rightmove/Zoopla listing data is proprietary. We acknowledge this limitation and note it as a data improvement opportunity for future work. Instead, we use temporal transaction patterns (monthly volumes) as a proxy for market dynamics.

---

### Condition 6: or developer-level clustering

**Status:** [x] RESOLVED

**Response:** Developer-level clustering can be approximated by identifying groups of new-build transactions at the same postcode/street within a 6-month window. Multiple new builds at the same address/street strongly suggest the same development. We cluster standard errors at the postcode level (which captures development-level correlation) and test robustness with street-level clustering. For the bunching analysis specifically, we follow Kleven (2016) inference based on bootstrapped bunching estimates.

---

### Condition 7: robust border bandwidth selection (from Grok)

**Status:** [x] RESOLVED (merged with Condition 2)

**Response:** See Condition 2. We use rdrobust data-driven bandwidth selection plus fixed bandwidth sensitivity analysis.

---

### Condition 8: mechanism tests like developer pricing responses (from Grok)

**Status:** [x] RESOLVED (merged with Conditions 3-4)

**Response:** Developer pricing responses are the core bunching analysis: the excess mass below the cap and missing mass above reveal how developers adjust prices to fit within subsidy limits. Property type mix shifts (Condition 3) show quality/size adjustment. We also test whether bunching is stronger for large developments (multiple units at same postcode) than for individual builds — consistent with developer strategic pricing.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
