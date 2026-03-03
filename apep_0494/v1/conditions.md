# Conditional Requirements

**Generated:** 2026-03-03T17:44:43.465449
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

---

## Who Captures a Tax Cut? Property Price Capitalization and Fiscal Substitution from France's €22 Billion Residence Tax Abolition

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: convincing pre-trends/anticipation handling

**Status:** [x] RESOLVED

**Response:**

The reform was announced during Macron's 2017 presidential campaign (spring 2017) and legislated in the Finance Law for 2018 (December 2017). This creates a potential anticipation window in 2017. The strategy:

1. **Core pre-trend test:** Event study for 2014–2016 (3 years well before any announcement). These coefficients should be flat zero.
2. **Anticipation analysis:** 2017 is explicitly modeled as a potential anticipation year. If prices already move in 2017 in high-TH communes, we discuss this as rational anticipation and adjust event-study timing accordingly.
3. **HonestDiD bounds:** Apply Rambachan and Roth (2023) sensitivity to bound effects under violations of parallel trends up to linear extrapolation of any pre-trends.
4. **Announcement date event study:** Use monthly DVF transaction dates to test for a price break around the June 2017 election vs. December 2017 legislation.

**Evidence:** DVF provides exact transaction dates (2014–2025). REI provides annual tax rates (2014–2024). The 3-year clean pre-period (2014–2016) provides adequate basis for parallel trends testing.

---

### Condition 2: a design add-on beyond "intensity DiD" such as border discontinuities or rich local controls interacted with time

**Status:** [x] RESOLVED

**Response:**

Four design add-ons beyond simple intensity DiD:

1. **DDD (Triple difference):** Exploit the income-based staggering. Low-income households (80%) got full exemption by 2020; high-income (20%) only by 2023. Communes differ in income composition → differential treatment timing. DDD = commune TH rate × income composition × time.
2. **Secondary residence placebo:** TH on résidences secondaires was NOT abolished — it persists and was even increased in tourist areas. This is a built-in within-commune placebo: if we see price effects only for primary-residence-type transactions (apartments in cities) and not secondary-residence-type (vacation homes in tourist communes), this rules out commune-level confounds.
3. **Département border discontinuity:** Neighboring communes across département boundaries may have different TH rates due to intercommunal tax regimes. Comparing communes just across département borders provides geographic RDD-like variation.
4. **Rich local controls × time:** Interact year dummies with pre-reform commune characteristics (population, income, urbanization, housing stock composition) to absorb differential trends correlated with TH rates.

**Evidence:** All data sources confirmed available. Département border pairs can be constructed from commune adjacency data (available in IGN admin boundaries).

---

### Condition 3: a clear separation of "tax cut incidence" vs "local fiscal response" in the causal chain

**Status:** [x] RESOLVED

**Response:**

The paper's central contribution IS this decomposition. The causal chain has two stages:

**Stage 1 — Gross capitalization:** TH abolished → households save €X/year → property prices rise by PV(savings). Estimate using communes that did NOT raise TF (clean treatment group) vs. those with stable, low TH rates (control).

**Stage 2 — Fiscal substitution:** Lost TH revenue → communes raise TF rates → property owners face offsetting tax increase → prices partially revert. Estimate TF rate changes as a function of pre-reform TH dependence (fiscal gap).

**Net capitalization = Stage 1 - Stage 2.** Formalized as a sequential mediation:
- Direct effect: TH abolition → prices (holding TF constant)
- Indirect effect: TH abolition → TF rate increase → prices

This decomposition is the paper's "new object" — converting a simple policy evaluation into a measurement of fiscal pass-through and local government behavior.

**Evidence:** REI data contains both TH and TF voted rates at commune level annually, enabling direct observation of fiscal substitution timing and magnitude.

---

### Condition 1 (duplicate): full event-study pre-trends pass

**Status:** [x] RESOLVED

**Response:** Same as Condition 1 above. Will present event-study coefficients for 2014–2017 (4 pre-reform years relative to 2018 first treatment). HonestDiD sensitivity bounds applied.

---

### Condition 2 (duplicate): integrate TF hikes as core mechanism rather than side analysis

**Status:** [x] RESOLVED

**Response:** This IS the paper's contribution. The fiscal substitution channel is the central mechanism — not a robustness appendix. The paper title explicitly includes "Fiscal Substitution." The mechanism chain (TH cut → commune response → TF increase → net capitalization) structures the entire results section.

---

## Do Priority Schools Help or Stigmatize? (Idea 2 — NOT PURSUING)

All conditions for Idea 2 are marked NOT APPLICABLE since we are pursuing Idea 1.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
