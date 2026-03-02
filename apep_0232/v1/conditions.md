# Conditional Requirements

**Generated:** 2026-02-12T09:27:46.007270
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

## The Geography of Monetary Transmission — Household Liquidity and Regional Impulse Responses

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: obtaining a defensible state-level liquidity/HtM measure beyond poverty

**Status:** [x] RESOLVED

**Response:**
We construct THREE distinct HtM proxies at the state-year level, each capturing different dimensions of household liquidity constraints:

1. **Poverty rate** (primary): FRED series `PPAACA[FIPS]A156NCEN` — estimated percent of people of all ages in poverty, annual, 1989–2024. This is the broadest measure of income inadequacy and is strongly correlated with HtM status (Kaplan-Violante 2014 show ~70% of poor HtM are also income-poor).

2. **SNAP recipiency rate**: FRED series `BR[FIPS]CAA647NCEN` — SNAP benefits recipients divided by state population. SNAP participation requires liquid assets below $2,750 (FY2024), making it a DIRECT measure of liquidity constraints, not just income poverty.

3. **Zero-financial-income share**: From Census ACS 1-year estimates (Table B19054 — aggregate interest/dividend/rental income), compute the share of households reporting zero financial asset income. Households with no financial asset income are a proxy for those without liquid savings (a core HtM indicator).

All three measures vary substantially across states (e.g., poverty rate: 7.2% in NH to 19.6% in MS). We use all three as alternative HtM proxies and show results are robust across measures.

**Evidence:** FRED API tested and confirmed for poverty rate and SNAP recipiency. ACS data available via Census API.

---

### Condition 2: pre-specifying a battery of "horse race" controls—industry composition

**Status:** [x] RESOLVED

**Response:**
We pre-specify the following industry composition controls, measured at the state level from BLS QCEW or BEA SAINC data:

1. **Manufacturing share** of total employment (interest-rate-sensitive sector)
2. **Construction share** of total employment (housing-linked, rate-sensitive)
3. **Government employment share** (countercyclical, not rate-sensitive)
4. **Finance/insurance/real estate share** (directly affected by rates)

These are measured in a pre-period (average over 5 years before each horizon) and interacted with the monetary shock alongside the HtM measure. The horse race tests whether HtM share has explanatory power ABOVE AND BEYOND industry composition.

**Evidence:** BLS QCEW data available via FRED (e.g., `TXMFG` for Texas manufacturing). BEA SAINC data has employment by industry.

---

### Condition 3: tradable share

**Status:** [x] RESOLVED

**Response:**
Following Mian and Sufi (2014) and the Regional Keynesian Cross, we control for the **non-tradable employment share** (retail, food services, healthcare, education) as a fraction of total employment. The Regional Keynesian Cross identifies this as a key amplification channel — our test asks whether HtM share provides ADDITIONAL explanatory power beyond the tradable/non-tradable distinction.

Specification: ΔY_{s,t+h} = α_s + α_t + γ₁(MP_t × HtM_s) + γ₂(MP_t × NonTradable_s) + δX_{s,t} + ε

If γ₁ remains significant after controlling for γ₂, this establishes that the HtM channel operates independently of the trade multiplier channel.

**Evidence:** Non-tradable share constructable from BLS QCEW or BEA employment by industry data.

---

### Condition 4: housing leverage

**Status:** [x] RESOLVED

**Response:**
We control for state-level **mortgage debt-to-income ratio** and **homeownership rate** (both from Census ACS or FRED). The mortgage channel of monetary transmission (Berger et al. 2021, Wong 2019) predicts that states with higher housing leverage respond more to rate changes through the housing wealth effect. Our test asks whether HtM share provides amplification BEYOND the housing channel.

Additional control: **ARM share** of new mortgage originations (from HMDA or FHFA data). Although ARM share is low in the US (~10-25%), cross-state variation exists and should be controlled.

**Evidence:** FRED has state homeownership rates (e.g., `CAHOWN`). Mortgage debt data available from NY Fed Consumer Credit Panel or FHFA.

---

### Condition 5: bank exposure—to isolate the liquidity channel

**Status:** [x] RESOLVED

**Response:**
We control for the state-level **bank lending channel exposure** using:
1. **Small bank deposit share**: Share of deposits held by small banks (assets < $10B), from FDIC Summary of Deposits. Small banks are more affected by monetary policy through the bank lending channel (Kashyap and Stein 2000).
2. **Credit-to-GDP ratio**: State-level bank credit outstanding / state GDP.

These controls isolate the HtM/liquidity channel from the bank lending channel. If HtM amplification survives controlling for bank exposure, it confirms that the mechanism operates through household balance sheets (the HANK channel), not bank balance sheets (the traditional lending channel).

**Evidence:** FDIC Summary of Deposits is publicly available. State credit data from FDIC or Call Reports.

---

### Condition 6: using inference robust to cross-sectional dependence/common shocks

**Status:** [x] RESOLVED

**Response:**
Since monetary shocks are national (common to all states), standard clustered SEs at the state level may understate uncertainty. We implement:

1. **Driscoll-Kraay standard errors** (Driscoll and Kraay 1998): Robust to both cross-sectional dependence and heteroscedasticity. This is the standard in panel macro with common shocks.

2. **Newey-West HAC** at the time dimension with sufficient lags (4-8 quarters for annual, 12-24 months for monthly data).

3. **Wild cluster bootstrap** at the state level (Cameron, Gelbach, Miller 2008) as a robustness check.

4. **Permutation inference**: Randomly reassign HtM rankings across states and re-estimate. The distribution of placebo γ estimates provides a nonparametric test of statistical significance.

**Evidence:** R packages `sandwich` (Driscoll-Kraay), `fwildclusterboot` or `clubSandwich` implement these. Local projection inference with Driscoll-Kraay is standard in Jordà (2005) applications.

---

## Fiscal Transfers and the HANK Multiplier — Cross-State Evidence from Federal Transfer Shocks

**Rank:** #2 | **Recommendation:** CONSIDER (will be included as secondary analysis)

### Condition 1: constructing shifts from clearly exogenous federal policy changes or rule changes rather than raw national spending growth

**Status:** [x] RESOLVED

**Response:**
We use TWO types of shift variation:
1. **Legislated policy changes**: ARRA 2009 (stimulus transfers), ACA Medicaid expansion (2014+), CARES Act (2020), ARPA (2021). These are discrete federal policy shocks identifiable by legislation date.
2. **Automatic stabilizer formulas**: National UI claims × state UI generosity parameters, national SNAP eligibility × state SNAP enrollment rates. The "shift" is the national unemployment/poverty rate (driven by aggregate conditions), and the "share" is the state's predetermined program parameters.

We EXCLUDE raw national spending growth and use only legislated changes or formula-driven variation.

**Evidence:** Legislative dates are well-documented. BEA SAINC35 has category-level detail.

---

### Condition 2: implementing Borusyak–Hull / Goldsmith-Pinkham–Sorkin–Swift-style shift-share validity checks

**Status:** [x] RESOLVED

**Response:**
We implement:
1. **GPSS (2020) decomposition**: Estimate Rotemberg weights to identify which shifts drive the estimate and test for balance on pre-determined covariates.
2. **Borusyak-Hull-Jaravel (2022)**: Test for shift-level exogeneity by examining whether national shifts are uncorrelated with state-level pre-trends.
3. **Overidentification test**: With 44 transfer categories providing 44 potential instruments, we test overidentifying restrictions (Sargan-Hansen J-test).

**Evidence:** R package `ShiftShareSE` (Adão, Kolesár, Morales 2019) implements shift-share inference.

---

### Condition 3: separating mechanically endogenous components like UI unless the shift is explicitly legislated

**Status:** [x] RESOLVED

**Response:**
UI spending is mechanically endogenous (rises when state unemployment rises). We handle this by:
1. **Excluding UI from the baseline Bartik instrument** — use only non-cyclical transfers (Social Security, Medicare, veterans' benefits, EITC).
2. **Including UI in a separate specification** where the "shift" is only legislated UI policy changes (e.g., ARRA extended benefits, CARES $600 supplement, state maximum benefit changes), NOT automatic claims variation.
3. **Reporting both specifications** with and without UI to show robustness.

**Evidence:** BEA SAINC35 separates UI (line 2400) from other transfers, enabling clean decomposition.

---

### Condition 4: timing-clean

**Status:** [x] RESOLVED

**Response:**
All "share" measures are lagged by at least 5 years to ensure pre-determination. Specifically:
- For analysis year t, shares are measured as the average over [t-7, t-5]
- This ensures shares are not contaminated by the economic conditions that generate the "shift"
- For legislated policy changes (ARRA, ACA, CARES), shares are measured BEFORE the legislative session

Pre-trend tests: We estimate the specification with leads (h = -3, -2, -1 years before the shock) and verify zero differential effects before the fiscal event.

**Evidence:** Standard practice in Bartik literature (Goldsmith-Pinkham et al. 2020).

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
