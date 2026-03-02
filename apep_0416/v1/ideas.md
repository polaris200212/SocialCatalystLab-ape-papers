# Research Ideas

## Idea 1: The Behavioral Health Cliff — Medicaid Unwinding and Community Mental Health Provider Supply

**Policy:** Medicaid continuous enrollment ended April 1, 2023. States began disenrollment processes on staggered timelines (April–July 2023), with disenrollment rates ranging from 12% (North Carolina) to 57% (Montana). States also varied dramatically in their approach: some relied heavily on procedural disenrollments (30–90% of terminations were procedural rather than eligibility-based), while others emphasized ex parte renewals to minimize coverage losses.

**Outcome:** Behavioral health provider billing volume, provider exit rates, and per-provider caseload changes in T-MSIS, measured via H-prefix HCPCS codes (behavioral health codes: community support, psychiatric services, substance use treatment). H-codes are distinct from the T-codes (HCBS) studied in apep_0307.

**Identification:** Staggered DiD exploiting state-level variation in unwinding start dates (April–July 2023 cohorts). Treatment intensity measured by state-level disenrollment rate. 51 states, 84 months (Jan 2018–Dec 2024), giving 63+ pre-treatment months and 12–20 post-treatment months. Callaway-Sant'Anna estimator with never/not-yet-treated controls.

**Why it's novel:**
- apep_0307 studied HCBS providers (T-codes) and found null effects — HCBS providers were resilient because they serve long-term enrollees less likely to be disenrolled. Behavioral health providers (H-codes) serve a fundamentally different population: episodic patients with mental health/substance use needs who are disproportionately subject to procedural disenrollments.
- Community mental health centers derive 80–90% of revenue from Medicaid, making them uniquely vulnerable to enrollment drops.
- First provider-level analysis of behavioral health supply responses to the unwinding — existing literature focuses on patient access, not provider supply.
- The T-MSIS data makes this possible for the first time: H-codes are invisible in Medicare data.

**Feasibility check:**
- Variation: 51 states with staggered adoption (April–July 2023), disenrollment rates from 12–57%. ≥20 treated states, ≥5 years pre-treatment. ✓
- Data access: T-MSIS Parquet (local, 2.74 GB), NPPES (state assignment via NPI), KFF unwinding tracker (state disenrollment timelines). All confirmed accessible. ✓
- Novelty: No APEP paper on behavioral health providers × unwinding. Distinct from apep_0307 (HCBS) and apep_0339 (minimum wages). ✓
- Sample size: H-codes constitute ~10% of T-MSIS spending (~$100B cumulative). Tens of thousands of behavioral health NPIs per state. ✓

## Idea 2: Cross-Payer Musical Chairs — Do Medicaid Behavioral Health Providers Shift to Medicare When Beneficiaries Lose Coverage?

**Policy:** Same unwinding variation as Idea 1.

**Outcome:** Within-provider changes in Medicare billing volume (from Medicare Physician/Supplier PUF) for dual-eligible behavioral health providers who also bill Medicaid (from T-MSIS), measured at the NPI level. The key question: when Medicaid enrollment drops, do providers compensate by billing more to Medicare?

**Identification:** NPI-level panel linking T-MSIS and Medicare PUFs. Within-provider DiD comparing Medicaid vs. Medicare billing volumes before and after unwinding, exploiting state-level timing variation.

**Why it's novel:**
- First cross-payer provider-level analysis combining T-MSIS and Medicare PUFs.
- Tests a fundamental health economics question: are providers quantity-constrained or payer-shifting?
- Direct test of crowd-out in reverse — does losing Medicaid patients create Medicare slots?

**Feasibility check:**
- Variation: Same as Idea 1. ✓
- Data access: T-MSIS (local), Medicare PUF (data.cms.gov Socrata). BUT: Medicare PUF data is annual and may only cover through 2022 — would need to verify 2023+ availability. ⚠️ Risk: if 2023 Medicare data isn't available yet, cannot observe post-unwinding Medicare billing.
- Novelty: No APEP cross-payer paper exists. ✓
- Sample size: Need providers billing both payers. Behavioral health providers billing both Medicaid H-codes and Medicare CPT codes may be a small subset. ⚠️

## Idea 3: When the Safety Net Frays — Unwinding Intensity and Behavioral Health Provider Market Concentration

**Policy:** Same unwinding variation, but using continuous treatment intensity (disenrollment rate) rather than binary start dates.

**Outcome:** Behavioral health provider market concentration (HHI) at the state-month level, provider exit rates, new entry rates, and per-provider billing volume.

**Identification:** Continuous DiD with state-level disenrollment intensity as treatment dosage. High-disenrollment states as treatment, low-disenrollment states as controls. Also triple-diff (DDD): behavioral health providers (H-codes) vs. HCBS providers (T-codes) within the same state, exploiting differential vulnerability to enrollment losses.

**Why it's novel:**
- The DDD design is particularly strong: if behavioral health providers are differentially affected while HCBS providers (already shown to be resilient in apep_0307) are not, the within-state comparison controls for state-level confounders.
- Tests the market structure prediction: does revenue loss lead to consolidation or exit?

**Feasibility check:**
- Variation: Continuous intensity measure from KFF data. ✓
- Data access: Same as Idea 1, plus KFF unwinding tracker for disenrollment rates. ✓
- Novelty: DDD with H-code vs. T-code comparison is novel. ✓
- Sample size: Same as Idea 1. ✓

## Recommendation

**Idea 1 is the strongest standalone paper.** It has the cleanest identification, clearest policy relevance, and most direct comparison to the existing literature (building on apep_0307's null result for HCBS by asking "what about the OTHER half of Medicaid-specific spending?"). Elements of Idea 3's DDD approach (H-code vs. T-code comparison) can be incorporated as a robustness check.

Idea 2 is the most ambitious but faces significant data availability risk (Medicare PUF timing) and sample size uncertainty (dual-billing providers). Better suited for a future paper once 2023 Medicare data is confirmed.
