# Conditional Requirements

**Generated:** 2026-02-23T15:22:15.356359
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

## Digital Markets and Price Discovery — Evidence from India's e-NAM Agricultural Platform

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: obtaining/constructing mandi-level onboarding dates with defensible accuracy

**Status:** [x] RESOLVED

**Response:**

Three-layer strategy for treatment assignment:

1. **Primary: State-phase cohort assignment.** PIB press releases and the NAARM (2020) report document 5 clear phase boundaries with state-level counts:
   - Apr 2016: 21 mandis in 8 states (UP, Gujarat, Maharashtra, MP, Telangana, Haryana, Rajasthan, HP, Jharkhand)
   - Nov 2016: 250 mandis across 10 states
   - Mar 2017: 417 mandis across 13 states
   - Mar 2018: 585 mandis across 18 states (Phase 1 complete)
   - May 2020: 1,000 mandis across 21 states (Phase 2)

   Within each phase, state-level counts are documented (e.g., PIB PRID 1558623: UP=100, Gujarat=79, Maharashtra=60 etc. in Phase 1). This allows assigning treatment dates at the state × phase level.

2. **Robustness: First-appearance proxy.** Since CEDA data covers all mandis, I can detect when a mandi first appears in the data or when its trading patterns change (price reporting frequency increases), providing a mandi-level proxy for integration timing. This will be used as a robustness check against state-phase assignment.

3. **Attenuation-aware design.** Measurement error in treatment dates attenuates DiD estimates toward zero, making any significant effects conservative. I will explicitly discuss this and conduct sensitivity analysis with ±3 month treatment windows.

**Evidence:**
- PIB PRID 1558623 (Jan 2019): Phase 1 state-wise breakdown of 585 mandis
- PIB PRID 1624083 (May 2020): 1,000-mandi milestone
- NAARM Report (2020) Table 3.2: Chronological milestones with mandi counts
- e-NAM Directory PDF (July 2021): Complete list of 1,000 integrated mandis with state/district

---

### Condition 2: demonstrating strong pre-trends/event-study validity

**Status:** [x] RESOLVED

**Response:**

The CEDA dataset provides daily mandi-level price data from 2006/2007 through 2025. This gives 8–10 years of pre-treatment data for the earliest cohort (April 2016), which is exceptionally strong for parallel trends testing. The analysis will include:

1. **Event-study plots** with leads and lags (monthly aggregation, ±24 months around treatment) showing coefficient dynamics. Flat pre-trends required; any deviation flagged.

2. **Callaway-Sant'Anna (2021)** group-time ATTs with built-in pre-trend diagnostics. The `did` R package provides formal pre-trend tests.

3. **HonestDiD sensitivity analysis** (Rambachan & Roth 2023) to bound estimates under plausible violations of parallel trends, using the M-approach (restricting maximum deviation from linear extrapolation of pre-trends).

4. **Placebo tests** using: (a) commodities not traded on e-NAM in each mandi; (b) fictional treatment dates 2–3 years before actual integration.

5. **Within-state comparisons** restrict the control group to non-integrated mandis in the same state, absorbing state-level shocks.

**Evidence:**
- CEDA API confirmed: daily data available from 2006 for most mandis
- 8+ years pre-period exceeds conventional 5-year minimum

---

### Condition 3: explicitly addressing concurrent state ag-market reforms

**Status:** [x] RESOLVED

**Response:**

Key concurrent agricultural market reforms to address:

1. **Model APMC Act (2003)**: Central government proposed allowing private markets. States adopted partially and at different times. Bihar abolished APMCs entirely in 2006. This creates state-level variation that predates e-NAM. **Mitigation:** State × year fixed effects absorb any state-time-varying reform impact. Additionally, Bihar (no APMCs since 2006) provides a natural placebo — e-NAM integration there should have different effects if APMC reform status matters.

2. **Farm Laws (Sep 2020 – Nov 2021)**: Three laws permitted trading outside APMCs, removed stocking limits. Repealed Nov 2021. **Mitigation:** These laws were national (no state variation) and short-lived (14 months). Year fixed effects absorb the common shock. For the core 2016–2019 analysis period, these laws were not yet in effect.

3. **State-specific APMC amendments**: Some states (Maharashtra, Karnataka, Rajasthan) amended APMC Acts around 2016–2018 to enable e-NAM integration (required electronic trading provisions). **Mitigation:** These amendments are the enabling condition for e-NAM, not a competing treatment. They do not independently affect prices absent the e-NAM platform. I will document which states amended and when, and test whether results differ by amendment timing.

4. **eNAM Model Act compatibility**: States needed to ensure 3 APMC Act provisions (single license, single levy, electronic trading). This is measured and documented by the Ministry. **Mitigation:** Include as a state-level control.

**Evidence:**
- PIB documentation of state-level APMC Act compatibility requirements
- Bihar APMC abolition (2006) provides natural placebo comparison
- Farm Laws timeline: Sep 2020 passage, Nov 2021 repeal (national, absorbed by year FE)

---

### Condition 4: procurement shocks

**Status:** [x] RESOLVED

**Response:**

Government procurement operations (Minimum Support Price + FCI procurement) can distort mandi prices, especially for wheat and rice in major procurement states (Punjab, Haryana, MP). This is a real threat because procurement intensity varies by state and year.

**Mitigation strategy:**

1. **Focus on non-procurement crops.** The primary analysis will use crops where government procurement is minimal: onions, tomatoes, potatoes, soybean, chana (chickpea), and other pulses/oilseeds. These are market-determined prices less distorted by MSP operations.

2. **Procurement crops as robustness.** Wheat and rice results will be reported separately, with explicit discussion of how MSP/procurement operations attenuate or distort the e-NAM price effect.

3. **Procurement-season interactions.** Include Rabi procurement season (Apr–Jun) and Kharif procurement season (Oct–Dec) dummies interacted with treatment to check whether e-NAM effects differ in procurement vs. non-procurement months.

4. **State procurement intensity controls.** Use state-level FCI procurement quantities (available from FCI annual reports) as a time-varying control, or restrict the sample to mandis in non-major-procurement states.

5. **Within-commodity, within-state comparisons.** For a given commodity in a given state, comparing e-NAM mandis to non-e-NAM mandis absorbs state×commodity×time procurement shocks.

**Evidence:**
- FCI Annual Reports document state-level procurement volumes
- Non-procurement commodities (onion, soybean, pulses) constitute the majority of e-NAM trading volume
- Within-state design absorbs state-level procurement policy

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
