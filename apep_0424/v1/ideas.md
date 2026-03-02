# Research Ideas

## Idea 1: Does Telehealth Payment Parity Expand Medicaid Behavioral Health Access? Evidence from Staggered State Adoption

**Policy:** State telehealth payment parity laws requiring that Medicaid reimburse telehealth services at the same rate as in-person services. These laws were adopted in a staggered pattern: approximately 16 states had permanent parity by 2019, growing to 33 states by 2024. Key adopters include Georgia (Jan 2020), Colorado (2021), Delaware (2021), Iowa (2021), Illinois (2021), Kentucky (2021), Arizona (2022), Nebraska (2022), Connecticut (2024), and Maryland (2025). This provides clean state x time variation across the full T-MSIS window (2018-2024).

**Outcome:** T-MSIS behavioral health claims data (H-prefix HCPCS codes: H0036 psychiatric services, H2015/H2016 community support, H0031 mental health assessment, etc.). Primary outcomes: (1) number of unique billing NPIs providing behavioral health services per state-month, (2) total unique beneficiaries receiving behavioral health services, (3) total claims volume and spending on behavioral health codes. Secondary outcomes: geographic reach of behavioral health providers (share of counties with at least one billing NPI), provider entry rate (new NPIs appearing in behavioral health billing).

**Data sources:** T-MSIS Parquet (local, 227M rows), NPPES extract (local, provider geography/specialty), CCHPCA state policy database (for treatment timing), Census ACS (county demographics via API), FRED (state unemployment via API).

**Identification:** Staggered DiD using Callaway-Sant'Anna estimator. Treatment: state adoption of permanent Medicaid telehealth payment parity law. Unit: state x month. Exploit variation in adoption timing (2019-2024) with never-treated states as comparison group. Pre-treatment periods: 5+ years for early adopters (data starts Jan 2018). Treated clusters: 20+ states adopted during observation window. Key threats: COVID-19 emergency telehealth waivers (all states, March 2020) -- address by focusing on PERMANENT law adoption (distinct from emergency orders) and using triple-diff comparing behavioral health (telehealth-eligible) vs. personal care/HCBS services (not telehealth-eligible) within the same state-time.

**Why it's novel:** (1) First study using Medicaid claims data (T-MSIS) to examine telehealth parity effects on provider supply -- existing literature uses private insurance claims or facility surveys. (2) Supply-side focus: does parity bring new providers into Medicaid behavioral health? (3) Mental health crisis is the top health policy priority; understanding whether payment policy can expand access is directly relevant. (4) Existing research finds Medicaid-accepting facilities had LOWER odds of offering telehealth, suggesting a parity gap -- we test whether closing it works.

**Feasibility check:** Confirmed: (1) T-MSIS contains H-prefix codes with substantial volume -- H2015/H2016 are among the top 50 HCPCS codes by claims. (2) NPPES provides state assignment for providers. (3) Staggered adoption with 20+ treated states and 5+ pre-treatment years. (4) Treatment timing constructable from CCHPCA database + legislative records. (5) Not in APEP list -- no existing paper on telehealth parity.

---

## Idea 2: The Organizational Shift: How Medicaid Managed Care Mandates Reshape Provider Market Structure

**Policy:** State mandates requiring Medicaid beneficiaries to enroll in managed care organizations (MCOs). Most major expansions predate our data window.

**Feasibility check:** CONCERN: Most major MCO mandates were adopted before 2018. Treated clusters may fall below 20. SKIP.

---

## Idea 3: Does Fraud Enforcement Deter Entry? The Effect of OIG Provider Exclusions on Medicaid Behavioral Health Supply

**Policy:** OIG LEIE exclusions. Partially covered by apep_0355.

**Feasibility check:** CONCERN: Overlap with existing paper apep_0355. Endogeneity of exclusions hard to address. SKIP.
