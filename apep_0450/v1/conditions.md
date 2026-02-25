# Conditional Requirements

**Generated:** 2026-02-24T18:08:37.576903
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

## Did India's GST Create a Common Market? Evidence from State-Level Price Convergence

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: strong differential-pretrend/event-study evidence

**Status:** [x] RESOLVED

**Response:**

The design will include a full event-study specification with monthly leads and lags around July 2017. With 54 monthly pre-treatment periods (Jan 2013-Jun 2017) and 102 post-treatment months, we have ample statistical power to test for differential pre-trends by treatment intensity. The specification is:

CPI_{s,g,t} = α_sg + δ_gt + Σ_k β_k × 1(t=k) × Intensity_s + ε_{s,g,t}

Where k indexes months relative to July 2017 (k=-54 to k=+102). Under valid identification, β_k ≈ 0 for k < 0 (flat pre-trends) and β_k ≠ 0 for k ≥ 0 (convergence after GST). The event-study plot will be the core identification evidence.

Robustness: (a) exclude Nov 2016-Jun 2017 transition months (demonetization window); (b) restrict sample to pre-COVID (Jul 2017-Feb 2020) for clean post-period; (c) randomization inference permuting state intensity assignments to construct exact p-values.

**Evidence:**

54 pre-treatment months is well above the recommended minimum (5+ periods). Monthly CPI data confirmed available from MoSPI API for all states.

---

### Condition 2: alternative intensity measures

**Status:** [x] RESOLVED

**Response:**

Three alternative intensity measures will be constructed:

1. **Primary:** Pre-GST total indirect tax revenue / GSDP (from RBI "State Finances: A Study of Budgets" 2016-17 report). Captures overall state tax burden replaced by GST.

2. **Alternative 1:** Pre-GST state VAT revenue / GSDP (narrower, excludes central taxes). Tests whether VAT-specific displacement drives convergence.

3. **Alternative 2:** Pre-GST cross-state price dispersion (σ of state CPI around national mean, averaged 2013-2016). States with more divergent pre-GST prices had more "room" for convergence — this directly measures the scope for GST-induced adjustment.

4. **Alternative 3:** Binary treatment: high-tax states (above median pre-GST tax/GSDP) vs low-tax states. Simplifies the design for robustness.

Results must be robust across all intensity measures. If the primary measure drives results but alternatives do not, this suggests confounding through development channels rather than GST mechanism.

**Evidence:**

RBI State Finances data confirmed available: https://rbidocs.rbi.org.in/rdocs/Publications/PDFs/0SF201718_FULL.pdf contains state-wise indirect tax revenue tables. CPI data for all states confirmed via MoSPI API tests.

---

### Condition 3: pre-GST VAT/CST reliance by commodity if possible

**Status:** [x] RESOLVED

**Response:**

The analysis will exploit commodity-group heterogeneity in two ways:

1. **National-level commodity tax changes:** Different CPI commodity groups experienced different GST vs. pre-GST tax rate changes. Key examples:
   - Food items: Pre-GST VAT ~4-5% → GST 0% (exempt) = LARGE decrease
   - Clothing (below Rs.1000): Pre-GST VAT ~5% → GST 5% = NO change
   - Fuel & Light: Partially outside GST (petroleum excluded) = MINIMAL change
   - Miscellaneous (services/transport): New tax regime (services were under separate service tax) = COMPLEX change
   - Pan/Tobacco: Pre-GST ~30-40% (excise + VAT) → GST 28% + cess = MINIMAL change

2. **Triple-diff design:** CPI_{s,g,t} = α_sg + δ_gt + γ_st + β × (Post_t × State_Intensity_s × Commodity_ΔTax_g) + ε_{s,g,t}. Commodity groups with larger tax rate changes (|Δ Tax|) should show larger price adjustments in high-intensity states. Fuel & Light (largely outside GST) serves as a natural PLACEBO — if GST drove convergence, fuel prices should NOT converge differentially.

3. **Commodity-level placebo:** Items excluded from GST (petroleum, alcohol, electricity) should show no intensity-dependent convergence post-July 2017. This provides a powerful falsification test.

**Evidence:**

MoSPI CPI API confirmed to return data by 8 commodity groups × 36 states × 156 months. GST rate structure well-documented at CBIC website (cbic-gst.gov.in/gst-goods-services-rates.html). Fuel & Light group confirmed as natural placebo (petroleum excluded from GST).

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Status: RESOLVED — PROCEED TO PHASE 4**
