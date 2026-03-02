# Research Ideas: apep_0483 v2 Revision

This is a revision of apep_0483 v1 (tournament rating: 1.75). The revision plan was developed collaboratively based on referee feedback identifying fatal flaws in v1.

## Idea 1: Ground-Up Reconstruction of Teacher Pay Competitiveness Paper (SELECTED)

**Policy:** STPCD austerity-era pay restraint (2010-2023) — nationally set teacher pay interacting with heterogeneous local labor markets
**Outcome:** Progress 8 (value-added measure) from DfE, both LA-level panel and school-level cross-section
**Identification:** Panel FE (LA + year), event study with baseline competitiveness interactions, Bartik IV using 2010 industry composition, academy triple-difference
**Why it's novel:** First LA-level panel of teacher pay competitiveness; first use of academy/maintained split as falsification test for STPCD mechanism
**Feasibility check:** Confirmed — KS4 data available from EES, ASHE from NOMIS, GIAS from DfE, SWC vacancies from EES, BRES from NOMIS. All data successfully fetched and panels constructed.

## Changes from v1

- Unit: 141 LAs (cross-section) → 157 LAs (panel with 5 years)
- Outcome: Raw Attainment 8 → Progress 8 (value-added)
- FE: Region FE → LA + Year FE
- Identification: Cross-sectional AIPW → Panel FE + Event Study + Bartik IV + Academy DDD
- School-level: None → 4,237 schools for academy DDD
- Inference: In-sample RF → Cluster-robust SEs + Randomization Inference
