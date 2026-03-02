# Research Ideas

## Idea 1: State Minimum Wage Increases and the HCBS Provider Supply Crisis

**Policy:** State minimum wage increases, 2018–2024. Approximately 32 states + DC raised their minimum wage above the federal floor ($7.25) during this period, with staggered effective dates and magnitudes ranging from $8.75 to $17.13. Nineteen states remained at $7.25 throughout (clean never-treated control group).

**Outcome:** T-MSIS Medicaid Provider Spending data (local Parquet, 227M rows). Outcomes: (1) count of unique billing NPIs filing T-code (HCBS personal care) claims per state-month, (2) total unique beneficiaries served per state-month, (3) claims per beneficiary (intensity), (4) provider entry rate (new NPIs appearing) and exit rate (NPIs disappearing). State assignment via NPPES bulk extract.

**Identification:** Staggered DiD using Callaway-Sant'Anna (2021) estimator. Treatment: state minimum wage increase above previous level. Clean variation: 32+ treated states with different timing, 19 never-treated. Triple-difference design as primary robustness: compare HCBS providers (T/H/S codes, near-MW wages) vs. non-HCBS Medicaid providers (CPT codes, physician wages far above MW) within the same state.

**Why it's novel:** The minimum wage literature is vast but has never examined its effect on the Medicaid HCBS provider network using provider-level claims data. HCBS direct care workers earn a median of $16.12/hr (BLS OES 2023), placing them squarely in the range where MW increases bind. The mechanism is the "outside option" effect: when MW rises, retail and food service jobs become relatively more attractive compared to emotionally demanding HCBS work. Counter-intuitive prediction: MW increases intended to help low-wage workers may reduce home-based care access for elderly and disabled Medicaid beneficiaries.

**Feasibility check:**
- Variation: 32+ treated states, staggered 2018-2024 ✓
- Pre-periods: ≥5 years for most treated states ✓
- Data access: T-MSIS Parquet confirmed (31K-37K T-code billing NPIs per year). NPPES bulk download confirmed available. State MW data from DOL/NCSL. ✓
- Novelty: No APEP paper on MW × HCBS. Google Scholar shows no existing paper linking minimum wage to HCBS provider supply using claims data. ✓
- Sample size: ~54 states × 84 months = ~4,500 state-month observations ✓

**External data needed:** (1) State minimum wage panel (DOL/NCSL, easily compiled), (2) NPPES bulk extract (downloading, ~800MB), (3) BLS QCEW for local healthcare employment controls, (4) Census ACS for state population denominators.

---

## Idea 2: Electronic Visit Verification Mandates and HCBS Provider Participation

**Policy:** The 21st Century Cures Act mandated Electronic Visit Verification (EVV) for Medicaid personal care services by January 1, 2020, and home health services by January 1, 2023. States implemented at different times — some early (Texas by 2018), some received good-faith effort exemptions and implemented later.

**Outcome:** T-MSIS provider counts and beneficiary volumes for personal care T-codes. Measure whether EVV mandates reduced the number of small/solo providers (compliance burden) or increased provider participation (payment reliability).

**Identification:** Staggered DiD around state-specific EVV compliance dates (available from CMS compliance tracker).

**Why it's novel:** EVV is a massive administrative mandate affecting all HCBS providers, but its supply-side effects have not been studied using claims data. Could reveal whether digital compliance mandates disproportionately push out small providers.

**Feasibility check:**
- Variation: Staggered compliance across states ✓
- Pre-periods: 2018 start gives pre-periods for states implementing after 2020 ✓
- Data access: T-MSIS confirmed. CMS publishes EVV compliance status by state. ✓
- Novelty: No existing APEP paper. Limited academic literature on EVV supply effects. ✓
- CONCERN: Federal deadline creates a bunching problem — many states hit the same deadline. Need to verify truly staggered implementation. May have <20 uniquely-timed cohorts. ⚠️

---

## Idea 3: Cross-Payer Substitution — Do Medicaid Providers Shift to Medicare When Rates Diverge?

**Policy:** Use variation in state Medicaid-to-Medicare payment ratios as a natural experiment. States where Medicaid rates fell further below Medicare rates should see providers shifting billing toward Medicare. Leverage ARPA HCBS rate increases (2021-2023) as positive shocks to the Medicaid-to-Medicare ratio.

**Outcome:** Link T-MSIS to Medicare Physician/Supplier PUF by NPI × HCPCS. For dual-biller providers, measure the Medicaid share of total billing over time.

**Identification:** DiD comparing providers in states with ARPA rate increases vs. states that implemented later. Triple-diff: dual-billers vs. Medicaid-only vs. Medicare-only within the same state.

**Why it's novel:** First study to directly observe cross-payer billing substitution at the provider level using linked Medicaid-Medicare claims data. Quantifies the "competitive payer" model in a Medicaid context.

**Feasibility check:**
- Variation: ARPA rate increases varied by state and timing ⚠️ (but ALL states got FMAP increase — variation is in implementation)
- Data access: T-MSIS confirmed. Medicare PUF available via data.cms.gov Socrata API ✓
- Novelty: Very high — no provider-level cross-payer substitution study exists ✓
- CONCERN: All states received ARPA FMAP increase. Variation is in *how* states used funds, which is endogenous. Treatment definition is fuzzy. ⚠️

---

## Idea 4: Medicaid Postpartum Coverage Extensions and Maternal Health Provider Supply

**Policy:** 47 states adopted 12-month postpartum Medicaid coverage extensions, staggered from April 2022 through early 2024. Previously, coverage ended 60 days after delivery.

**Outcome:** T-MSIS provider counts for maternal health-related HCPCS codes (prenatal visits, postpartum care). Measure whether extended coverage increased the number of providers billing Medicaid for postpartum services.

**Identification:** CS-DiD with staggered adoption across 47 states. Strong design: clear dates, near-universal adoption, 3 never-treated states as controls.

**Why it's novel:** apep_0149 studied demand-side effects (enrollment, coverage). This would study the supply-side response: did more providers enter Medicaid maternity care when coverage was extended?

**Feasibility check:**
- Variation: 47 treated states, staggered 2022-2024 ✓
- Pre-periods: 2018-2021 gives 4 years pre-treatment ✓
- Data access: T-MSIS confirmed. Adoption dates documented by KFF. ✓
- CONCERN: Identifying maternal health providers in T-MSIS requires linking to HCPCS codes that specifically indicate maternity care. T-MSIS is dominated by HCBS codes; maternity-specific codes may be a small slice. Only 3 never-treated states may limit inference. ⚠️
- CONCERN: Too close to existing apep_0149 paper — judges may see it as duplicative ⚠️
