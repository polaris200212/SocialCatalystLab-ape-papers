# Conditional Requirements

**Generated:** 2026-02-24T14:00:18.454535
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

## Back to Work? Early Termination of Pandemic Unemployment Benefits and Medicaid HCBS Provider Supply (Idea 1)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: defining outcomes by date-of-service month

**Status:** [x] RESOLVED

**Response:**
T-MSIS uses `CLAIM_FROM_MONTH` which is the **date-of-service month**, not the payment/adjudication month. This is confirmed in the dataset documentation and the field name itself ("claim from" = service date). Our outcomes (provider counts, billing volume, beneficiaries) are aggregated by date-of-service month, which correctly aligns with when services were actually delivered.

**Evidence:**
T-MSIS schema documentation: `CLAIM_FROM_MONTH` = "Month of service (not submission date)". Confirmed in SCOPING_NOTES.md Section 1.

---

### Condition 2: using first full month of exposure

**Status:** [x] RESOLVED

**Response:**
UI termination dates range from June 12 to July 31, 2021. For states terminating mid-month (most of them), the first full month of exposure is the FOLLOWING month. Implementation:
- June 12 termination → first full exposure month = July 2021
- June 19 termination → first full exposure month = July 2021
- June 26 termination → first full exposure month = July 2021
- June 27 termination → first full exposure month = July 2021
- June 30 termination → first full exposure month = July 2021
- July 3 termination → first full exposure month = August 2021
- July 10 termination → first full exposure month = August 2021
- July 31 termination → first full exposure month = August 2021

For CS-DiD, we will define the treatment cohort by the first full month of exposure (July or August 2021). We will also present results using the termination month itself as a sensitivity check.

**Evidence:**
Ballotpedia state-by-state termination dates confirmed. Design specification in initial_plan.md.

---

### Condition 3: presenting strong event-study pre-trends

**Status:** [x] RESOLVED

**Response:**
We will present Callaway-Sant'Anna group-time ATTs with a full event-study plot showing 12+ pre-treatment months. Parallel trends will be tested formally using the CS pre-trend test. With 41 months of pre-treatment data (Jan 2018 – May 2021), we have exceptional power to detect pre-trend violations. We will also present Bacon decomposition to check for negative weights in TWFE.

**Evidence:**
Pre-period: 41 months. Post-period: 42 months. CS-DiD event study will be the primary specification. Pre-trend p-values will be reported.

---

### Condition 4: addressing confounding via controls for COVID waves/reopening

**Status:** [x] RESOLVED

**Response:**
Early UI termination was concentrated in Republican-governed states. Key confounders: (1) COVID severity/waves, (2) reopening timing, (3) other benefit changes, (4) ARPA HCBS spending. Our strategy:

1. **State × month fixed effects** in the triple-diff specification absorb ALL state-level time-varying confounders including COVID waves, reopening policies, and economic conditions.
2. **Callaway-Sant'Anna** uses never-treated states as the comparison group, controlling for group-specific trends.
3. **Robustness checks:** (a) Add time-varying COVID controls (deaths per capita, vaccination rates, unemployment), (b) restrict to within-region comparisons (South only), (c) include state-level reopening stringency as a control, (d) placebo test using behavioral health (H-codes) — if the effect is UI-driven (labor supply), it should be concentrated in low-wage HCBS (T-codes) and absent in behavioral health (where workers earn more).
4. **Placebo test with H-codes:** Behavioral health providers earn more ($18-25/hr vs $12-15/hr for HCBS aides), making them less affected by UI supplements. A null effect on H-code providers would support the labor supply mechanism.

**Evidence:**
Design specification includes all of the above. Behavioral health placebo is a key falsification test.

---

### Condition 5: reweighting/matching to improve comparability

**Status:** [x] RESOLVED

**Response:**
Early-terminating states are disproportionately Southern, Republican-governed, and lower-income. We address comparability through:

1. **Entropy balancing:** Re-weight never-treated states to match treated states on pre-COVID HCBS provider counts, Medicaid enrollment, state unemployment, population, and political composition.
2. **Covariate balance table:** Show pre-treatment means for treated vs. control states (raw and re-weighted).
3. **Within-region analysis:** Restrict to South/Midwest where both treated and control states exist.
4. **Callaway-Sant'Anna with covariates:** Include time-invariant state characteristics (pre-COVID HCBS per capita, unemployment, Medicaid expansion status) in the CS-DiD estimation.

**Evidence:**
Balance table and entropy-balanced results will be presented alongside baseline estimates.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
