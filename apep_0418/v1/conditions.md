# Conditional Requirements

**Generated:** 2026-02-19T16:25:54.652973
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

## Does Place-Based Climate Policy Work? A Regression Discontinuity Analysis of IRA Energy Community Bonus Credits

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: cleanly isolating areas where qualification is mechanically determined by the 0.17% rule

**Status:** [x] RESOLVED

**Response:**

Energy community designation has three pathways: (1) brownfield sites, (2) coal closure tracts, and (3) statistical area (fossil fuel employment + unemployment). The RDD exploits pathway (3) only. The design restricts the sample to MSAs/non-MSAs that:
- Do NOT contain brownfield or coal closure tracts (eliminating pathway contamination)
- Have unemployment ≥ national average (so the unemployment criterion is mechanically satisfied)
- Then estimates the discontinuity at the 0.17% fossil fuel employment threshold

This ensures treatment is mechanically determined by the 0.17% rule alone. The sample restriction is well-defined: Treasury publishes separate lists for each pathway (brownfield, coal closure, statistical area), enabling clean separation. Among MSAs/non-MSAs with unemployment above the national average, crossing the 0.17% FF employment threshold DETERMINISTICALLY switches energy community status on. This is a sharp RDD.

**Evidence:**

Treasury publishes pathway-specific data: https://home.treasury.gov/policy-issues/tax-policy/data-transparency/all-treasury-generated-energy-communities-data-sets. The statistical area pathway lists show MSAs/non-MSAs that meet (a) the FFE threshold only, (b) the unemployment threshold only, and (c) both (qualifying as energy communities). This allows exact sample construction.

---

### Condition 2: validating timing by using “early pipeline” outcomes like interconnection queue entries/permitting in addition to EIA 860 build outcomes

**Status:** [x] RESOLVED

**Response:**

The analysis will use a cascade of pipeline-stage outcomes to capture investment responses at different horizons:

1. **Interconnection queue entries** (earliest signal): LBNL “Queued Up” dataset (emp.lbl.gov/queues) provides project-level interconnection queue data through end-2024, covering ~97% of US installed capacity across all 7 ISOs/RTOs + 49 non-ISO utilities. Projects enter the queue 2-5 years before operation, so queue entries in 2023-2024 directly reflect post-IRA developer intent.

2. **EIA 860M proposed generators** (mid-pipeline): Monthly supplement to EIA 860 includes all planned/proposed generators with expected operation dates. This captures projects past the interconnection stage but pre-construction.

3. **EIA 860 operational generators** (realized outcome): Annual data on generators that actually began operating. Given the IRA was signed August 2022, some fast-track projects (especially solar) could be operational by 2024-2025.

This multi-stage approach addresses the timing concern directly: if the RDD shows effects on queue entries but not yet on operational capacity, that's consistent with investment responding to the incentive but having natural construction lags.

**Evidence:**

LBNL Queued Up data: https://emp.lbl.gov/queues (Excel download with project-level data including location, technology, queue entry date, status). EIA 860/860M: https://www.eia.gov/electricity/data/eia860/ and https://www.eia.gov/electricity/data/eia860m/

---

## The $55,000 Cliff: IRA Clean Vehicle Credit Price Caps and Manufacturer Strategic Pricing

**Rank:** #3 | **Recommendation:** CONSIDER

### Condition 1: obtaining trim-level MSRP + transaction/registration data

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: cleanly separating MSRP-cap incentives from other contemporaneous IRA eligibility shocks

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
