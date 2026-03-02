# Research Ideas

## Idea 1: Medicaid Unwinding and HCBS Provider Network Destruction

**Policy:** The end of the COVID-19 continuous enrollment provision triggered staggered Medicaid disenrollment across all 50 states beginning April 2023. States initiated terminations between April and July 2023, with some (CA, NY) delaying to mid-2024. Over 25 million people were disenrolled; 69% of disenrollments were procedural (paperwork failures), not eligibility-based. State-level variation in timing, aggressiveness (disenrollment rates ranged 12-57%), and administrative approach (ex parte renewal rates ranged 11-90%) provides rich treatment variation.

**Outcome:** T-MSIS Medicaid Provider Spending dataset (227M rows, 617K providers, $1.09T, Jan 2018 - Dec 2024). Linked to NPPES for state/specialty/entity type assignment. Outcomes: (1) provider exit rate (NPI stops billing), (2) billing volume per active provider, (3) active HCBS providers per capita, (4) HCBS market concentration (HHI by firm × county), (5) new provider entry rate.

**Identification:** Staggered difference-in-differences exploiting state-level variation in unwinding start dates. Callaway-Sant'Anna (2021) heterogeneity-robust estimator with group-time ATTs. Sun-Abraham as robustness. Event study specification with 12+ months pre and 12-21 months post. Treatment intensity design using state disenrollment rates as continuous treatment. Permutation inference for p-values.

**Why it's novel:** (1) First causal paper using T-MSIS provider spending data — a dataset released 6 days ago. (2) First paper to examine supply-side provider effects of unwinding — all existing work focuses on demand-side coverage loss. (3) Documents an irreversible mechanism: provider exit destroys care infrastructure that cannot be rebuilt when patients re-enroll. (4) HCBS providers (52% of Medicaid spending) have no Medicare equivalent — they are 100% Medicaid-dependent.

**Feasibility check:**
- Variation: 50+ states with staggered timing (April-July 2023) ✓
- Pre-periods: 63 months (Jan 2018 - Mar 2023) ✓
- Treated clusters: 50+ states ✓
- Data access: T-MSIS (public, downloaded), NPPES (public, downloadable), CMS unwinding reports (public) ✓
- Not overstudied: No existing T-MSIS causal papers; no supply-side unwinding papers ✓
- Sample size: 617K providers × 84 months ✓

**DiD feasibility screen:**
- Pre-treatment periods: 63 months (≥5 years) ✓
- Treated clusters: 50 states (≥20) ✓
- Selection into treatment: Unwinding timing determined by state administrative capacity, not provider outcomes ✓
- Comparison group: Later-unwinding states serve as controls for early unwinders ✓
- Outcome-policy alignment: Provider billing directly measures effect ✓

---

## Idea 2: Medicaid Postpartum Extension and OB Provider Billing

**Policy:** 47 states extended Medicaid postpartum coverage from 60 days to 12 months, with staggered adoption 2022-2024 (only AR and WI have not acted).

**Outcome:** T-MSIS billing for OB-related HCPCS codes (prenatal visits, delivery codes, postpartum E&M visits). Provider-level changes in OB billing volume and patient counts.

**Identification:** Staggered DiD across ~40 state adoption dates.

**Why it's novel:** Provider-side measurement of a demand-side coverage expansion. Does extending coverage actually translate to more provider billing?

**Feasibility check:**
- Variation: ~40 states with staggered timing ✓
- Pre-periods: 4+ years for early adopters ✓
- Treated clusters: ~40 states ✓
- Data access: All public ✓
- **Concern:** Treatment window (2022-2024) is near end of data — limited post-treatment periods for late adopters. Also near-universal adoption limits variation. APEP already has apep_0149 on this topic using survey data. Lower novelty.

---

## Idea 3: CCBHC Expansion and Behavioral Health Provider Supply

**Policy:** Certified Community Behavioral Health Clinics (CCBHCs) provide enhanced reimbursement and expanded services. Federal demonstration expanded from 8 states (2017) to ~40+ states (2024), with staggered state adoption.

**Outcome:** T-MSIS H-code (behavioral health) billing: H2015, H2016, H0031, H0032, H0036. Number of behavioral health providers (NPPES taxonomy), billing volume, beneficiary counts.

**Identification:** Staggered DiD on CCBHC adoption dates.

**Why it's novel:** First provider-level analysis of whether enhanced behavioral health reimbursement increases provider supply. Uses Medicaid-specific H-codes that have no equivalent in any other dataset.

**Feasibility check:**
- Variation: ~30+ states with staggered timing ✓ (needs verification)
- Pre-periods: 2018 baseline ✓
- Data access: All public ✓
- **Concern:** CCBHC adoption dates need careful verification — demonstration vs. state plan amendment vs. certification creates complex treatment definition. Exact timing harder to pin down than unwinding.

---

## Idea 4: Medicaid Unwinding and Cross-Payer Provider Substitution

**Policy:** Same unwinding policy as Idea 1.

**Outcome:** T-MSIS + Medicare Physician/Supplier PUF linked by NPI. Dual-billing providers observable in both systems. When Medicaid patients lose coverage, do providers shift billing toward Medicare?

**Identification:** Same staggered DiD as Idea 1, but with the NPI-linked cross-payer panel as outcome.

**Why it's novel:** First evidence on provider-level cross-payer substitution following an enrollment shock. Addresses a longstanding health economics question about cost-shifting.

**Feasibility check:**
- Same strong variation as Idea 1 ✓
- Data access: Both PUFs public ✓
- **Concern:** Medicare PUF is annual (not monthly), creating temporal mismatch with monthly T-MSIS. Would need to aggregate T-MSIS to annual for cross-payer comparison. Also, overlap population (providers billing both payers) may be small for HCBS codes since those have no Medicare equivalent.

---

## Recommendation

**Idea 1 dominates.** It has the cleanest identification, the most novel contribution (first T-MSIS causal paper, first supply-side unwinding paper), the strongest policy relevance (OBBBA work requirements coming), and all data is publicly accessible. Ideas 2-4 are viable follow-up papers in the agenda but have meaningful feasibility concerns.
