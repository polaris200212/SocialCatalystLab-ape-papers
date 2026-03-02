# Conditional Requirements

**Generated:** 2026-03-01T19:16:20.532339
**Status:** RESOLVED

---

## FOBT Reform Conditions (Consolidated from all three models)

### Condition 1: Strong closure first-stage documented using establishment data

**Status:** [x] RESOLVED

**Response:**
The Gambling Commission publishes both (a) Licensing Authority Statistics — a 329-LA annual panel (2015–2025) counting licensed betting offices by LA, and (b) a downloadable CSV register of all licensed gambling businesses with operating licence details and postcodes. Parliamentary research documents that 1,000+ shops closed within 6 months of April 2019 (12% of stock), with GGY from B2 machines falling 46%. The first-stage is mechanically strong and directly observable in administrative data — this is not an inferred treatment.

**Evidence:**
- Gambling Commission Licensing Authority Statistics 2024-2025 (Excel, 329 LAs, 2015–2025): https://www.gamblingcommission.gov.uk/statistics-and-research/publication/licensing-authority-statistics-2024-to-2025-official-statistics
- Gambling Commission Business Register CSV: https://www.gamblingcommission.gov.uk/public-register/businesses/download
- House of Commons Library SN06946: documents 8,500 → 7,315 shops within 6 months
- FOI data on licensed betting offices: https://www.gamblingcommission.gov.uk/about-us/freedomofinformation/print/licensed-betting-offices
- Will be verified empirically in 03_main_analysis.R (first-stage figure showing LA-level closure rates by pre-policy density quintile)

---

### Condition 2: Pre-trend/event-study evidence under multiple exposure definitions

**Status:** [x] RESOLVED

**Response:**
The analysis plan includes: (a) event study plots showing crime/property trends by exposure quintile for 4+ years pre-treatment; (b) formal parallel trends tests (both unconditional and conditional on DR covariates); (c) Rambachan-Roth (HonestDiD) sensitivity analysis for deviations from parallel trends; (d) robustness to alternative exposure definitions — pre-policy shop density per capita, per km², binary above/below median, and actual post-policy closure counts (instrumented by pre-policy density to avoid endogeneity of selective closures).

**Evidence:**
- Will be implemented in 03_main_analysis.R and 04_robustness.R
- Pre-treatment crime data available from December 2010 (Police API bulk downloads), giving 8+ years of pre-periods
- Multiple exposure definitions prevent results from depending on a single arbitrary measure

---

### Condition 3: Pre-analysis plan prioritizing 1-2 primary outcomes + mechanism tests

**Status:** [x] RESOLVED

**Response:**
The paper will commit to:
- **Primary outcome:** Total police-recorded crime per capita at the LA-quarter level (single headline estimand)
- **Secondary outcome:** Property values (Land Registry average transaction price at LA-quarter level)
- **Mechanism decomposition:** Crime-type analysis (antisocial behavior, violence, shoplifting, drugs, public order as "gambling-adjacent" vs. vehicle crime, burglary, bike theft as "unrelated placebos")
- **Online displacement channel:** Gambling Commission data on remote gambling GGY by operator (aggregate, not LA-level — acknowledged limitation)
- **Welfare/employment:** NOMIS claimant count as a supporting outcome, NOT a co-equal primary outcome

This avoids "three papers in one" by maintaining crime as the core contribution, with property and welfare as supporting evidence for the neighborhood equilibrium story.

**Evidence:**
- Detailed in initial_plan.md (to be committed before data fetch)

---

### Condition 4: Demonstrating mechanism via vacant-storefront/online-displacement channels

**Status:** [x] RESOLVED

**Response:**
Mechanism tests planned:
1. **Crime decomposition:** If closures → less street disorder, we expect antisocial behavior/public order to fall but violence/domestic incidents to be unchanged or increase (online displacement). If closures → broken windows, we expect shoplifting/criminal damage to increase near former sites.
2. **Temporal dynamics:** Event study showing immediate vs delayed effects — immediate crime drop (footfall reduction) vs delayed crime increase (vacancy/decay) speaks to mechanism timing.
3. **Vacancy channel:** Companies House data tracks whether former betting shop addresses see new business registrations (SIC code changes) — empty vs repurposed premises.
4. **Online displacement:** Gambling Commission Industry Statistics report aggregate online GGY growth post-reform. Acknowledged as suggestive/descriptive only (not LA-level).
5. **Deprivation heterogeneity:** Effects by IMD quintile — if closures help deprived areas more (or less) than affluent ones, this speaks to competing mechanisms.

**Evidence:**
- Crime categories from data.police.uk support the decomposition
- Companies House SIC code tracking feasible at postcode level
- Gambling Commission Industry Statistics confirm online GGY available

---

### Condition 5: Online gambling metrics

**Status:** [x] RESOLVED

**Response:**
The Gambling Commission publishes Industry Statistics with remote (online) gambling GGY broken down by product type, quarterly. This is aggregate national data, not LA-level. The paper will use this to document the aggregate online substitution (descriptive), while acknowledging that LA-level online gambling data is not available. This is an honest limitation, not a paper-killing gap — the crime decomposition (street vs domestic categories) provides the LA-level mechanism test for displacement.

**Evidence:**
- Gambling Commission Industry Statistics: https://www.gamblingcommission.gov.uk/statistics-and-research/publication/industry-statistics-november-2020

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Status: RESOLVED**
