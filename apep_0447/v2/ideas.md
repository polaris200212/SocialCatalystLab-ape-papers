# Research Ideas

## Idea 1: Lockdowns and the Collapse of In-Person Medicaid Care (Triple-Diff)

**Policy:** State COVID-19 stay-at-home orders and workplace closure policies, March–June 2020. States varied dramatically in timing (CA March 19 vs. SC April 7), stringency (full lockdown vs. advisory), and duration (some lifted April, others maintained through June+). Seven states never issued statewide orders (AR, IA, NE, ND, SD, UT, WY).

**Outcome:** Monthly HCBS provider billing from T-MSIS (T-codes: personal care, attendant care, habilitation) vs. behavioral health billing (H-codes: community support, psychiatric rehabilitation). The key insight: HCBS services require physical presence in the beneficiary's home — they cannot be delivered via telehealth. Behavioral health services received emergency telehealth waivers and could pivot online. This within-state contrast in lockdown susceptibility creates a natural comparison group.

**Identification:** Triple-difference (DDD) design. (1) Compare HCBS (in-person) vs. behavioral health (telehealth-eligible) services; (2) before vs. after lockdown onset; (3) high vs. low lockdown stringency states (Oxford COVID-19 Government Response Tracker, state-level stringency index). The identifying assumption: absent lockdowns, the ratio of HCBS to behavioral health billing would have evolved similarly across high and low stringency states. Lockdown stringency is measured continuously, avoiding arbitrary dichotomization.

**Why it's novel:** No existing paper has studied how COVID lockdowns differentially disrupted Medicaid's in-person care workforce. The HCBS vs. BH comparison is a new idea — it uses T-MSIS's comparative advantage (the T/H code split that Medicare data lacks). Existing COVID-Medicaid papers focus on enrollment/coverage (demand side) or the 2023 unwinding, not the 2020 supply-side shock.

**Feasibility check:**
- Variation: 50 states, continuous stringency variation, 26 pre-treatment months (Jan 2018–Feb 2020), 58 post months
- Data access: T-MSIS Parquet (local, 2.74 GB), OxCGRT US state-level CSV (GitHub, confirmed accessible), CDC stay-at-home order dataset (Socrata API, confirmed accessible), NPPES for state assignment
- Novelty: No APEP paper on COVID lockdowns × HCBS. Not overstudied in the literature (COVID-Medicaid papers focus on enrollment, not provider billing)
- Sample size: 50 states × 84 months × 2 service types = 8,400 state-service-month cells

---

## Idea 2: Did Lockdowns Permanently Shrink the HCBS Workforce? (Event Study)

**Policy:** Same stay-at-home orders as Idea 1, but focused on long-run provider exit rather than billing volume.

**Outcome:** Count of unique billing NPIs in HCBS (T-codes) by state × month. Track provider entry and exit using first/last observed billing month. Measure whether lockdown-induced exit was temporary (providers returned within 6 months) or permanent (never billed again through Dec 2024).

**Identification:** Staggered event-study DiD around each state's lockdown onset date. Treatment timing is the date of the state's first stay-at-home order. States without statewide orders serve as never-treated. Use Callaway-Sant'Anna (2021) for heterogeneity-robust estimation. Pre-trend test uses 24 months of data.

**Why it's novel:** Provider lifecycle dynamics during COVID are unstudied in the Medicaid HCBS context. The question of permanent vs. temporary workforce disruption has direct policy implications for HCBS workforce planning.

**Feasibility check:**
- Variation: ~43 treated states with staggered adoption in March–April 2020, 7 never-treated states
- Data: T-MSIS + NPPES (confirmed available)
- Novelty: Not in APEP list, limited existing literature on HCBS provider exit during COVID
- Sample: 50 states × 84 months; 617K unique billing NPIs

---

## Idea 3: Essential Worker Exemptions and HCBS Billing Continuity

**Policy:** During lockdowns, some states explicitly classified home care workers as "essential workers" exempt from stay-at-home orders, while others did not include them or were ambiguous. This created within-lockdown variation in whether HCBS providers could continue operating.

**Outcome:** HCBS billing volume (T-codes) during lockdown months (March–June 2020) relative to pre-lockdown baseline.

**Identification:** DiD comparing HCBS billing in states that exempted home care workers vs. states that did not, conditional on having a lockdown. The comparison narrows to states WITH lockdowns, exploiting only the essential worker classification margin.

**Why it's novel:** No paper has studied whether essential worker designations actually affected service delivery in Medicaid HCBS. This is a novel within-lockdown margin of variation.

**Feasibility check:**
- Variation: Need to verify essential worker classifications across states — may require manual coding from executive orders
- Data: T-MSIS + NPPES (confirmed), essential worker lists (need manual compilation)
- Risk: Manual coding of essential worker exemptions is labor-intensive and subjective. Classification boundaries may be fuzzy.
- Sample: ~35-40 states with lockdowns, varying exemption clarity

---

## Idea 4: COVID Severity, Emergency Telehealth Waivers, and the Behavioral Health Provider Surge

**Policy:** States issued emergency Medicaid telehealth waivers at different times during March–April 2020, varying in scope (which services, which modalities, payment parity). Combined with differential COVID severity across states (deaths per capita), this created a two-dimensional shock to behavioral health provider incentives.

**Outcome:** Count of behavioral health providers (H-code billers) and total H-code billing volume in T-MSIS by state × month. Track new provider entry into Medicaid behavioral health.

**Identification:** DiD exploiting staggered telehealth waiver adoption across states + continuous COVID severity variation. Triple-diff comparing behavioral health (telehealth-eligible) vs. HCBS (not telehealth-eligible).

**Why it's novel:** apep_0424 studied telehealth PAYMENT PARITY laws (a later, separate policy), not the emergency COVID waivers. This focuses on the acute crisis response, not the post-hoc parity legislation.

**Feasibility check:**
- Variation: 50 states, telehealth waiver dates well-documented by CMS
- Data: T-MSIS (confirmed), CMS emergency waiver tracker, NPPES
- Risk: Telehealth waivers were nearly universal by April 2020 — limited sustained variation
- Novelty: Distinct from apep_0424 (parity laws vs. emergency waivers)
