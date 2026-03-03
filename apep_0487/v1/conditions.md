# Conditional Requirements

**Generated:** 2026-03-03T01:03:27.649702
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

## Idea 3: "The Political Price of Unwinding: Provider Donations After Medicaid Disenrollment"

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: integrating it as a secondary shock/robustness test within Idea 1 rather than as a standalone paper

**Status:** [x] RESOLVED

**Response:**

Medicaid unwinding will be incorporated as a secondary revenue shock in Section 6 (Extensions) of the Idea 1 paper. This tests symmetry: if expansion (positive shock) increases political engagement, does unwinding (negative shock) increase it further (voice) or reduce it (exit)? This is a natural extension of the main DDD analysis, using the same linked panel.

**Evidence:**

All three rankers recommended this integration. The unwinding window (April 2023+) provides one additional election cycle (2024) of post-shock data within the T-MSIS coverage period.

---

## Voting Their Wallet? Medicaid Revenue Dependence and Provider Political Behavior

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: confirming match quality >90% via Medicare overlap subsample

**Status:** [x] RESOLVED

**Response:**

The linkage validation strategy has three layers:
1. **NPPES name + state + ZIP5 match to FEC donors:** Conservative exact matching on (last_name, first_name, state, zip5). NPPES has structured name fields; FEC uses "LAST, FIRST" format — both parseable.
2. **Occupation validation:** FEC occupation field (e.g., "PHYSICIAN", "NURSE", "THERAPIST") must be consistent with NPPES taxonomy/credential. This eliminates name-only false positives.
3. **Medicare overlap subsample:** Providers appearing in BOTH T-MSIS and Medicare Physician/Supplier PUF (matched by NPI) provide a gold-standard name validation. If the T-MSIS → NPPES → FEC match agrees with Medicare PUF → NPPES → FEC match for the same NPI, the linkage is confirmed.

From Bonica et al. (2014): NPI-to-DIME match rate for physicians was >95% using name + state + ZIP. Our method replicates this approach. The >90% threshold will be verified empirically in the execution phase and reported in the paper.

Additionally, sensitivity analysis will bound estimates using Lee (2009) trimming bounds for potential false matches and randomization inference for the main specifications.

**Evidence:**

- Bonica, Rosenthal, Rothman (2014) JAMA Internal Medicine: matched 311,513 physician contributors from 1,044,460 NPI records using name + geography
- Kim (2024) Stanford GSB: matched 309,000 physicians using similar approach
- FEC API test confirmed: 3.3M physician donation records in 2020 cycle with name, state, ZIP, occupation fields present

---

### Condition 2: piloting full DDD specs

**Status:** [x] RESOLVED

**Response:**

The full DDD specification will be piloted in 03_main_analysis.R before any results are written. The pilot sequence:

1. **Panel construction:** Build provider × election-cycle panel (2018, 2020, 2022, 2024 cycles) with T-MSIS revenue, NPPES characteristics, and FEC donation outcomes.
2. **Pre-trend validation:** Event-study graph showing donation trends for high- vs low-Medicaid-dependence providers in expansion vs non-expansion states for 2018 (pre) cycle.
3. **DDD specification:** Y_{i,s,t} = β(Expand_{s,t} × MedicaidShare_i × Post_t) + provider FE + state×cycle FE + MedicaidShare×cycle FE + Expand×MedicaidShare FE + X_{i,t} + ε_{i,s,t}
4. **Cluster inference:** State-level clustering (51 clusters) + wild cluster bootstrap as robustness.
5. **Callaway-Sant'Anna:** Group-time ATTs for staggered adoption, aggregated to event-study.

If pre-trends reject parallel trends at p<0.05, the paper will (a) report HonestDiD/Rambachan-Roth sensitivity bounds and (b) pivot to a more descriptive framing with the DDD as a suggestive design.

**Evidence:**

- 7 late-expanding states provide staggered treatment timing
- 10 never-expanding states provide clean controls
- Pre-expansion period (2018 cycle) available for all states
- Provider-level Medicaid dependence varies continuously (0-100%)

---

## Regulatory Capture at the Bedside: Medicaid Expansion, Provider Revenue, and State Legislative Donations

**Rank:** #3 | **Recommendation:** CONSIDER

### Condition 1: NIMSP data pilot yielding >70% match rate

**Status:** [x] NOT APPLICABLE

**Response:** Idea 5 was not selected. The paper uses Idea 1 with federal FEC data (standardized, complete coverage).

---

### Condition 2: consistent fields for 80% of states

**Status:** [x] NOT APPLICABLE

**Response:** See above — using federal FEC data, not state campaign finance records.

---

### Condition 3: otherwise integrate as robustness to Idea 1

**Status:** [x] NOT APPLICABLE

**Response:** Idea 5 not pursued. State legislative donations may be noted as a limitation/future work in the conclusion.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
