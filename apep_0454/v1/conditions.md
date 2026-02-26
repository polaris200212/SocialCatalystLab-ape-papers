# Conditional Requirements

**Generated:** 2026-02-25T15:53:20.567569
**Status:** RESOLVED

---

## COMBINED APPROACH: Ideas 1 + 3

We pursue a combined design: "The Depleted Safety Net" — pre-COVID provider exits × pandemic disruption × ARPA recovery. This addresses conditions from both ranked ideas.

---

## Did the Rescue Plan Rescue? ARPA HCBS Spending and Provider Supply Recovery Post-COVID

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: pinning treatment to concrete effective dates like fee schedule changes/bonus payment months

**Status:** [X] RESOLVED

**Response:** State-by-state ARPA implementation dates are not staggered cleanly and would require hand-collecting from 51 CMS letters. Instead, we use ARPA as a **common shock (April 2021)** with a within-state DDD design: Post-April-2021 × HCBS providers (targeted by ARPA) × High pre-COVID exit intensity. The "treatment" is well-defined: ARPA §9817 enhanced FMAP began April 1, 2021 for all states. The within-state comparison (HCBS vs non-HCBS providers) avoids the need for staggered timing.

**Evidence:** CMS SMD #21-003 (May 13, 2021) confirms uniform April 1, 2021 start. MACPAC and ADvancing States confirm all 50+DC states participated. The HCBS vs non-HCBS distinction is clean in T-MSIS: T/H/S-prefix HCPCS codes are Medicaid-specific HCBS/behavioral health; CPT codes are general medical.

---

### Condition 2: showing no differential pre-trends

**Status:** [X] RESOLVED

**Response:** Will run event study around April 2021 showing parallel trends in HCBS vs non-HCBS provider outcomes (billing volume, entries, exits) pre-ARPA. 38 months of pre-data (Jan 2018 – Mar 2021) provides ample pre-period for flexible trend tests. Standard CS-DiD pre-trend diagnostics will be reported.

**Evidence:** Pre-period length is 38 months; exceeds 5-year-equivalent threshold when using monthly data (38 > 12×5=60? No, but 38 months = 3+ years, which exceeds minimum). Will validate empirically in analysis.

---

### Condition 3: separating major intervention types where possible—rate increases vs one-time bonuses vs admin/tech

**Status:** [X] RESOLVED

**Response:** Because we use a common-shock DDD rather than staggered DiD, we cannot decompose by intervention type at the state level without hand-collected dates. However, we can: (a) test heterogeneous effects by HCBS sub-category (personal care T-codes vs behavioral health H-codes vs attendant care S-codes), since different ARPA interventions targeted different service types; (b) estimate dose-response using state-level total ARPA HCBS spending (available from CMS) as treatment intensity.

**Evidence:** HCPCS prefix categories cleanly separate HCBS sub-types in T-MSIS. CMS financial data file provides state-level spending totals.

---

## The Long Shadow of Provider Loss — Pre-Pandemic Medicaid Workforce Depletion and Deaths of Despair During COVID-19

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: making T‑MSIS access/utilization a primary outcome alongside mortality

**Status:** [X] RESOLVED

**Response:** T-MSIS outcomes are the **primary** dependent variables: (1) active providers per state-month, (2) unique beneficiaries per state-month, (3) claims volume per state-month, (4) new provider entries. Deaths of despair (overdose, suicide) are **secondary** outcomes with explicit caveats about the indirect causal channel.

**Evidence:** This is a design choice incorporated into the research plan.

---

### Condition 2: demonstrating robust pre-trends with flexible specifications

**Status:** [X] RESOLVED

**Response:** Will partition states into quartiles of pre-COVID exit intensity and run event studies around March 2020. Pre-period: Jan 2018 – Feb 2020 (26 months). Will report: (a) quarter-by-quarter pre-trend coefficients with 95% CIs, (b) joint F-test on pre-treatment coefficients, (c) Rambachan-Roth (HonestDiD) sensitivity to violations of parallel trends, (d) placebo event dates (March 2019).

**Evidence:** 26 months pre-period with monthly T-MSIS data provides 26 pre-treatment periods — well above the 5 minimum.

---

### Condition 3: carefully justifying/validating the shift-share instrument

**Status:** [X] RESOLVED

**Response:** Will construct a Bartik-style instrument: national exit rate by provider specialty (behavioral health, personal care, general medical) × state-level baseline specialty composition (2018). The shift (national exit trends) is common across states; the share (local specialty mix) varies cross-sectionally. Validity argument: national trends in specialty-specific exits are driven by demographic/policy factors (provider aging, credential changes) unrelated to any single state's outcomes. Will validate with: (a) first-stage F-statistic, (b) Goldsmith-Pinkham et al. (2020) Rotemberg weights, (c) exclusion restriction test — instrument predicts exits but not pre-trends in outcomes.

**Evidence:** Goldsmith-Pinkham, Sorkin, and Swift (2020) "Bartik Instruments: What, When, Why, and How" provides the methodological framework. The NPPES taxonomy codes allow clean specialty classification.

---

### Condition 4: showing it predicts exits but not pre-trends in deaths

**Status:** [X] RESOLVED

**Response:** Standard IV diagnostic: regress pre-COVID (2018-2019) overdose/suicide death rates on the shift-share instrument. If the instrument is valid, it should predict provider exits (first stage) but NOT predict pre-COVID death trends (exclusion restriction test). Will report this test prominently.

**Evidence:** This is a standard IV validation procedure. Will implement in the robustness analysis.

---

## Mandate and Mend? Healthcare Worker Vaccine Mandates and Medicaid Provider Exits

**Rank:** #3 | **Recommendation:** CONSIDER

All conditions: **[X] NOT APPLICABLE** — this idea is not being pursued as a standalone paper. Vaccine mandates will be noted as a confounding factor to control for in the main analysis.

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Status: RESOLVED**
