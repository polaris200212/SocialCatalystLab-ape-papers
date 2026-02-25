# Conditional Requirements

**Generated:** 2026-02-25T15:50:33.729929
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

## Vacancy Tax Expansion and Housing Markets

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: near-threshold/border comparison strategy

**Status:** [x] RESOLVED

**Response:**

The TLV expansion (Décret 2023-822) designates communes based on specific housing market tension criteria defined in Article 232 of the Code général des impôts. The designation is based on observable indicators: ratio of housing demand to supply, vacancy rates, and price-to-income ratios. Our identification strategy exploits this by:

1. **Within-département matching:** Compare newly designated communes to similar non-designated communes in the same département, matched on pre-treatment observables (population, housing stock, tourism intensity, vacancy rates).
2. **Near-threshold design:** The designation criteria create a scoring system. Communes just above vs. just below the threshold provide the cleanest comparison. We will obtain the underlying tension indicators from INSEE to construct a running variable.
3. **Donut-hole strategy:** Exclude communes that were already designated in the 1999 or 2013 waves (these had TLV for years), focusing exclusively on the 2,263 newly treated vs. never-treated communes.

**Evidence:** Décret 2023-822 published in Journal Officiel, August 25, 2023. The commune list and criteria are publicly available.

---

### Condition 2: demonstrate strong pre-trends

**Status:** [x] RESOLVED

**Response:**

With DVF data available 2020-2024+, we have 3 full pre-treatment years (2020, 2021, 2022) before the January 2024 effective date. The identification strategy includes:

1. **Event-study specification:** Estimate year-by-year coefficients for 2020-2022 (pre) and 2024-2025 (post) relative to 2023 (announcement year). Pre-treatment coefficients should be statistically indistinguishable from zero.
2. **Callaway & Sant'Anna estimator** treats the 2023 expansion as a single-cohort DiD. The pre-treatment period check is standard in the CS framework.
3. **Placebo test:** Apply the same design to the 2013 expansion wave (using 2020-2022 data, pretending treatment in 2022). If parallel trends hold for the placebo, the design gains credibility.

**Evidence:** DVF bulk data confirmed available for 2020-2024 (smoke tested via data.gouv.fr).

---

### Condition 3: pre-register handling of tourism-specific shocks

**Status:** [x] RESOLVED

**Response:**

Tourism communes face specific confounders in 2020-2024: COVID-19 recovery, post-pandemic migration to coastal areas, and remote work relocation effects. We address this through:

1. **Controls for tourism intensity:** Include commune-level tourism indicators (number of hotels/gîtes from Sirene, secondary home share from INSEE) interacted with year fixed effects.
2. **Triple-difference design:** Treatment × Post × Tourism intensity. If the TLV effect is driven by generic tourism shocks, it should appear equally in designated and non-designated tourism communes. The triple-diff isolates the TLV-specific effect.
3. **COVID-robust specification:** Include département × year fixed effects to absorb regional pandemic and recovery shocks. The key identifying variation is within-département: designated vs. non-designated communes in the same département.

**Evidence:** Pre-registered in initial_plan.md before data analysis.

---

### Condition 4: Airbnb/STR policy overlap

**Status:** [x] RESOLVED

**Response:**

Short-term rental regulations are a legitimate confounder. French cities have progressively implemented STR registration and day limits (Paris 120-day cap since 2017, other cities since 2018-2022). We address this by:

1. **Control for STR regulation:** Code which communes have implemented STR registration/caps and when. Include this as a time-varying control.
2. **Mechanism test:** If TLV works through converting vacant units to rental market, we should see effects on transaction volume and composition, not just prices. STR regulation should primarily affect rental supply, not sales prices.
3. **Robustness check:** Exclude communes with active STR regulations from the sample and re-estimate.
4. **Note:** Most STR regulations were implemented before 2023 (pre-treatment), so they don't create differential trends at the treatment date.

**Evidence:** Commune-level STR regulations can be tracked via Légifrance API (PISTE credentials confirmed).

---

### Condition 5: heterogeneity by baseline vacancy/second-home intensity

**Status:** [x] RESOLVED

**Response:**

This is a natural part of our analysis design. We will:

1. **Classify communes by baseline vacancy:** Using INSEE housing census data (last available: 2020), compute baseline vacancy rates and secondary residence shares for each commune.
2. **Split-sample analysis:** Estimate treatment effects separately for high-vacancy vs. low-vacancy communes, and high-secondary-home vs. low-secondary-home communes.
3. **Continuous heterogeneity:** Include baseline vacancy rate × post-treatment interaction in the main specification to estimate the marginal effect per percentage point of baseline vacancy.
4. **Theory prediction:** The TLV should have larger effects in communes with higher baseline vacancy (more "treated" housing units).

**Evidence:** INSEE housing stock data (logements par catégorie) available at the commune level from recensement.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
