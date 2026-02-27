# Conditional Requirements

**Generated:** 2026-02-27T20:11:31.434435
**Status:** RESOLVED

---

## MERGED IDEA: Multi-Cutoff EPC RDD (Idea 1) + MEES Supply/Investment (Idea 5)

The two top-ranked ideas share data and running variable. They are merged into a single paper that:
1. Establishes EPC label capitalization across all band boundaries (multi-cutoff information RDD)
2. Shows the E/F boundary has an additional MEES regulatory effect (post-2018)
3. Decomposes the MEES adjustment into supply (landlord exit), investment (upgrading), and price channels
4. Tests energy crisis amplification of label effects

---

### Condition 1: A defensible rental-status definition

**Status:** [x] RESOLVED

**Response:** The EPC register includes a `TENURE` field (Owner-occupied, Rental (social), Rental (private), Unknown). This is recorded at the time of EPC assessment. For identifying MEES-affected properties, we use `TENURE = "Rental (private)"` from EPCs lodged proximate to the transaction date. As a robustness check, we also use: (a) Companies House data to identify corporate landlords (buy-to-let companies with SIC codes 68100/68209) by matching registered address to property postcode; (b) Land Registry "additional price paid" flag (Category B), which captures non-standard transactions more common in investment purchases. The owner-occupied placebo group uses `TENURE = "Owner-occupied"` from the same EPC register.

**Evidence:** EPC register documentation confirms TENURE field is available in all domestic certificates. Verified via bulk download metadata at epc.opendatacommunities.org.

---

### Condition 2: A pre-specified supply measure not mechanically driven by EPC re-lodgements

**Status:** [x] RESOLVED

**Response:** Supply is measured via three independent channels:
1. **Land Registry transaction volume** for rental-tenure properties in the F/G EPC range — this captures the extensive margin (are F/G properties being sold?) without using EPC re-lodgement data at all.
2. **Companies House dissolution rates** for SIC 68100/68209 firms (buy-to-let companies) by postcode — captures landlord market exit.
3. **EPC purpose-of-lodgement** field: EPCs lodged for "rental" vs "sale" vs "assessment" provides independent evidence of rental supply shifts, where the purpose of lodgement is mechanically distinct from the score upgrade itself.

The key outcome is NOT "how many properties get re-assessed" (which would be mechanical), but "what happens to transaction volumes and firm counts at the E/F threshold?"

**Evidence:** Land Registry PPD is entirely independent of EPC register. Companies House dissolution data is independent. Pre-specified in initial_plan.md.

---

### Condition 3: RDD manipulation/bunching handled explicitly as part of the mechanism

**Status:** [x] RESOLVED

**Response:** This is the core methodological innovation. At the E/F boundary (score 39), we expect post-MEES bunching because landlords upgrade properties to comply. We treat this explicitly:
1. **McCrary density test** at all cutoffs, separately for pre-MEES and post-MEES periods. At C/D and D/E (information-only boundaries), we expect NO systematic bunching.
2. **At E/F post-MEES:** If bunching exists, we deploy Kleven-style bunching estimators to quantify the compliance upgrading margin. The bunching excess IS the treatment effect on investment.
3. **Donut RDD** as sensitivity: exclude properties within ±1 point of each threshold to verify that price discontinuities are not driven solely by the manipulated mass.
4. **Pre-MEES E/F:** The same boundary before April 2018 serves as the pure information placebo (no regulatory incentive to bunch).

**Evidence:** Design pre-specified in initial_plan.md. McCrary implemented via R package `rddensity`.

---

### Condition 4: McCrary density tests at informational thresholds

**Status:** [x] RESOLVED

**Response:** McCrary tests run at all five EPC band boundaries (39, 55, 69, 81, 92) in both pre- and post-MEES periods. At informational-only boundaries (55, 69, 81, 92), we test whether there is assessor bunching. If detected at some thresholds, we use donut RDD (excluding ±1 of threshold) and report sensitivity. If severe at a particular boundary, we drop it from the multi-cutoff comparison and note the limitation.

**Evidence:** Pre-specified in initial_plan.md; implemented via `rddensity::rddensity()` in R.

---

### Condition 5: Pre-specify crisis interaction

**Status:** [x] RESOLVED

**Response:** Energy crisis periods pre-specified as:
- **Pre-crisis:** Jan 2018 – Sep 2021 (gas wholesale < £50/MWh)
- **Crisis:** Oct 2021 – Jun 2023 (gas wholesale > £100/MWh, peaking at £300+)
- **Post-crisis:** Jul 2023 – Dec 2025 (prices normalized)

We estimate RDD discontinuities separately for each period at each cutoff. The crisis amplification test is: Does the label effect (price discontinuity at band boundaries) increase during the crisis period relative to pre-crisis? Pre-specified as interaction term `band_boundary × crisis_period` in the pooled specification.

**Evidence:** UK wholesale gas prices (NBP) publicly available from OFGEM/ICE. Breakpoints at Oct 2021 and Jun 2023 are clear structural breaks in the price series.

---

### Condition 6: Romano-Wolf multiple-testing correction

**Status:** [x] RESOLVED

**Response:** With 5 cutoffs × 3 time periods × 2 tenure types = 30 RDD estimates, multiple testing is a first-order concern. We pre-specify outcome families:
- **Family 1 (Information):** Price discontinuities at C/D, D/E, B/C, A/B boundaries (4 estimates per period)
- **Family 2 (Regulation):** Price discontinuity at E/F boundary (1 estimate per period × tenure)
- **Family 3 (Supply):** Transaction volume, firm dissolution, tenure composition at E/F

Romano-Wolf step-down correction applied within each family. Bonferroni applied across families for conservative inference.

**Evidence:** R package `wildrwolf` for Romano-Wolf; pre-specified in initial_plan.md.

---

## Verification Checklist

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Status: RESOLVED**
