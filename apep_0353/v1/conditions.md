# Conditional Requirements

**Generated:** 2026-02-18T09:29:32.397096
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

---

## Tight Labor Markets and the Crisis in Home Care — Within-State Evidence from Medicaid Provider Billing

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: extending/strengthening pre-trend diagnostics—ideally add earlier years or very strong placebo tests

**Status:** [x] RESOLVED

**Response:**

The pre-period (2018Q1-2019Q4) provides 8 quarterly observations before the COVID shock — this exceeds the 5-period minimum threshold. While only 2 calendar years, the quarterly frequency provides sufficient statistical power for pre-trend tests. Additionally, I will implement:

1. **Event study plots** with quarterly leads/lags showing no differential pre-trends between high- and low-tightness counties
2. **Placebo outcomes**: (a) Non-HCBS Medicaid spending (CPT/medical codes) — should not respond to low-wage labor competition; (b) High-wage medical provider supply (physicians, specialists) — should be inelastic to local retail/food service competition
3. **Randomization inference** for the Bartik IV to assess whether observed effects exceed chance
4. **Falsification test**: Regress pre-period (2018-2019) HCBS supply levels on 2020-2022 labor market tightness changes — should find no effect if pre-trends are parallel

**Evidence:** T-MSIS confirmed to have 84 months (2018-01 through 2024-12). BLS QCEW confirmed accessible for all years.

---

### Condition 2: validating county location using beneficiary county or service location where possible rather than NPPES mailing ZIP

**Status:** [x] RESOLVED

**Response:**

T-MSIS does not contain beneficiary county — NPI is the sole geographic link. However, the NPPES extract uses **practice location** (not mailing address): the fields are `practice_state` and `practice_zip`, which correspond to where care is actually delivered. This is standard in health economics research using NPI-linked data. Additional validation:

1. **Use servicing NPI** as primary geography where available (65% of rows have distinct servicing NPIs who are typically at the point of care), with billing NPI as fallback
2. **Restrict sensitivity analysis to individual providers** (entity_type=1) who practice at their registered location, excluding large organizations whose billing NPI may be a corporate headquarters
3. **Cross-validate** state-level aggregates from our county panel against the known state distribution from the overview paper (apep_0294)
4. **Report ZIP-to-county crosswalk match rate** and assess whether unmatched providers differ systematically

**Evidence:** NPPES extract confirmed to have `state` (practice_state), `zip` (practice_zip), and `entity_type` fields. 96.4% of NPIs have non-missing zip5.

---

### Condition 3: showing Bartik robustness to alternative industry sets

**Status:** [x] RESOLVED

**Response:**

The paper will report the following Bartik robustness checks:

1. **Baseline**: 2-digit NAICS private sector (own_code=5), ~15 industries — standard in the literature
2. **Excluding healthcare** (NAICS 62): Remove the endogenous industry — HCBS providers are within healthcare, so healthcare industry growth could violate exclusion
3. **Excluding top industry**: Leave-one-out Bartik (remove largest employment-share industry per county)
4. **3-digit NAICS**: Finer industry decomposition (~60+ industries) to reduce exposure to any single share
5. **Goldsmith-Pinkham et al. (2020) diagnostics**: Report Rotemberg weights showing which industry shares drive identification and test their exogeneity
6. **Borusyak et al. (2022) approach**: Report the share-weighted average effect and cluster-robust inference at the industry level

**Evidence:** BLS QCEW confirmed to return 2,000+ industry codes per county including detailed NAICS breakdown. All robustness variants constructible from same data pull.

---

### Condition 4: controlling for Medicaid enrollment/demand shocks

**Status:** [x] RESOLVED

**Response:**

The paper will control for demand-side confounders:

1. **State×quarter FEs** already absorb ALL state-level enrollment changes (unwinding, expansion, ARPA effects) — this is the core design advantage
2. **County-level controls**: ACS 5-year poverty rate, uninsurance rate, population, and elderly share — these capture structural demand differences
3. **Direct demand control**: Include total Medicaid spending (all HCPCS codes, not just HCBS) as a county-quarter control variable — this captures local Medicaid utilization intensity
4. **Beneficiary counts from T-MSIS**: The data includes TOTAL_UNIQUE_BENEFICIARIES, which I can aggregate to county-quarter as a direct enrollment proxy and use as both an outcome denominator (claims per beneficiary) and a control
5. **Robustness**: Show results with and without demand controls to demonstrate insensitivity

**Evidence:** T-MSIS has TOTAL_UNIQUE_BENEFICIARIES field. Census ACS county data confirmed accessible. State×quarter FEs mechanically absorb state-level enrollment/policy shocks.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git
