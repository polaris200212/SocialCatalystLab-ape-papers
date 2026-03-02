# Conditional Requirements

**Generated:** 2026-02-18T11:20:05.944708
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

## The Elasticity of Medicaid's Safety Net — Market Responses to Provider Fraud Exclusions

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: extending pre-period or restricting to later exclusions

**Status:** [x] RESOLVED

**Response:**

T-MSIS covers January 2018 through December 2024 (84 months). We restrict the analysis sample to exclusions occurring on or after July 2020, ensuring each treated market has ≥30 months of pre-period billing data. This provides ample pre-treatment observation for event study diagnostics. Exclusions from 2018-2019 are excluded from the main analysis but used in a supplementary analysis with shorter pre-periods as a robustness check.

With exclusions July 2020 – December 2024 (54 months), and an average of ~550 NPI-bearing exclusions per year, we expect ~2,500 events in the main sample. This is well-powered for county-level analysis.

**Evidence:**

- T-MSIS coverage: Jan 2018 – Dec 2024 (verified from local Parquet)
- OIG LEIE 2020-2024 exclusions with NPIs: 2018=432, 2019=424, 2020=479, 2021=357, 2022=611, 2023=631, 2024=877 (validated via direct CSV download)
- Restricting to July 2020+ gives ~2,500 events with ≥30 months pre-period

---

### Condition 2: defining outcomes net-of-excluded-provider

**Status:** [x] RESOLVED

**Response:**

All market-level outcomes will be computed EXCLUDING the excluded provider's own billing. Specifically:

1. **HCBS spending in ZIP c at month t** = Σ(paid) for all NPI ≠ excluded NPI billing to ZIP c in month t
2. **Provider count in ZIP c at month t** = count of distinct NPIs ≠ excluded NPI billing to ZIP c in month t
3. **Beneficiary count in ZIP c at month t** = distinct beneficiaries served by NPIs ≠ excluded NPI in ZIP c in month t

This avoids the mechanical drop when the excluded provider stops billing. The research question becomes: "Does the rest of the market expand to absorb the displaced patients?"

A separate analysis will track the excluded provider's pre-exclusion billing trajectory to measure the direct "hole" created by the exclusion — the absorption rate = (change in rest-of-market) / (excluded provider's pre-exclusion baseline).

**Evidence:**

Implementation is straightforward in T-MSIS: filter by servicing_npi ≠ excluded_npi before aggregation.

---

### Condition 3: focusing on high-share providers / tighter markets

**Status:** [x] RESOLVED

**Response:**

For each excluded provider, we compute their pre-exclusion market share:
- **Market share** = (excluded provider's HCBS spending in 12 months before exclusion) / (total HCBS spending in same ZIP × service category × 12 months)

The main analysis restricts to exclusions where the provider had ≥5% market share in their service category within their ZIP code. A secondary specification uses the 10% threshold.

Heterogeneity analysis by:
- Market concentration quartiles (HHI of ZIP-level HCBS spending)
- Rural vs urban markets (USDA rural-urban continuum codes)
- Provider type (individual vs organizational)
- Service category (personal care vs behavioral health)

**Evidence:**

OIG LEIE specialty distribution shows 1,792 "personal care providers" and 703 "home health agencies" — organizational providers who likely have meaningful market share. The 10-20% of exclusions that are organizations will drive the strongest results.

---

### Condition 4: explicit tests for anticipatory effects

**Status:** [x] RESOLVED

**Response:**

Three explicit tests for anticipation:

1. **Event study with 18+ monthly leads:** Plot rest-of-market outcomes from t-18 to t+18 around the exclusion. Under no anticipation, the event study coefficients should be flat (zero) for t < 0.

2. **Excluded provider's own billing trajectory:** Plot the excluded provider's monthly billing from t-18 to t=0. If the provider reduced activity during an investigation phase, this would show a decline before the formal exclusion date. We report this transparently and define "effective exclusion" as the month when the provider's billing drops below 50% of their baseline (rather than the formal LEIE date) as a robustness check.

3. **Placebo test on unrelated service categories:** For excluded HCBS providers, examine whether non-HCBS Medicaid spending in the same ZIP shows any response — it should not, absent general enforcement-related disruption.

**Evidence:**

The event study framework (Callaway-Sant'Anna 2021) with long pre-periods naturally tests for pre-trends. The 18-month lead window is feasible given 30+ months of pre-period data for our main sample.

---

### Condition 5: enforcement-wave confounding

**Status:** [x] RESOLVED

**Response:**

Three mitigation strategies:

1. **State × month fixed effects:** Our main specification includes state × month FE, which absorbs any state-level enforcement campaigns that coincide with outcome trends. If OIG targets a state heavily in a particular month, state × month FE absorbs this.

2. **Enforcement intensity controls:** Include county-month controls for the number of other OIG exclusions in the same county × same calendar quarter. This absorbs the "local crackdown" channel.

3. **Robustness to enforcement-wave exclusion:** Restrict to exclusions that are temporally isolated (≥6 months since the last exclusion in the same county). If results are similar for isolated vs. clustered exclusions, enforcement-wave confounding is unlikely to drive the findings.

4. **Exclusion type heterogeneity:** LEIE tracks exclusion types (mandatory under 1128a vs permissive under 1128b). Mandatory exclusions (e.g., felony conviction) are less likely to co-occur with local enforcement waves than permissive exclusions (e.g., billing issues found during audits). Compare estimates across exclusion types.

**Evidence:**

LEIE `EXCLTYPE` column classifies exclusions as 1128a1, 1128a2, 1128b1-b16. Mandatory exclusions (1128a) are driven by individual criminal justice outcomes, not OIG enforcement campaigns, providing cleaner identification.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
