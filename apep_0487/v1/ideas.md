# Research Ideas

## Idea 1: "Voting Their Wallet? Medicaid Revenue Dependence and Provider Political Behavior"

**Policy:** Staggered Medicaid expansion under the ACA. Seven states expanded Medicaid during the T-MSIS window (2018–2024): Virginia (Jan 2019), Maine (Jan 2019), Idaho (Jan 2020), Nebraska (Oct 2020), Missouri (Oct 2021), Oklahoma (Jul 2021), South Dakota (Jul 2023). Ten states never expanded (TX, FL, GA, WI partial, etc.) serve as never-treated controls.

**Outcome:** Individual political donations by Medicaid providers, measured via FEC bulk individual contribution files (Schedule A). Outcomes include: (1) extensive margin — probability of donating, (2) intensive margin — total dollars donated per election cycle, (3) direction — share of donations to Democratic (pro-ACA) vs. Republican candidates, (4) health-specific targeting — share to candidates on health committees.

**Data linkage (new object):** T-MSIS (227M rows, provider-level Medicaid billing) → NPPES (provider name, state, ZIP, specialty) → FEC bulk individual contributions (donor name, state, ZIP, occupation, amount, date, recipient). Match on last_name + first_name + state + ZIP5. Validate via occupation field. Cross-payer denominator from Medicare Physician/Supplier PUF (same NPI × HCPCS structure) to compute Medicaid revenue share.

**Identification:** Triple-difference (DDD):
- Dimension 1: State × time (staggered expansion timing)
- Dimension 2: Provider-level Medicaid dependence (high vs. low Medicaid revenue share, continuous)
- Dimension 3: Before/after expansion

DDD isolates the causal effect by comparing: providers with high Medicaid dependence in expanding states (treated) vs. low-dependence providers in the same state (within-state control) vs. high-dependence providers in non-expanding states (across-state control).

**Built-in placebos:**
- Low-Medicaid-dependence providers in expanding states (shouldn't respond to expansion)
- HCBS/behavioral health providers in non-expanding states (same occupation, different treatment)
- Donations to non-health-related committees (gun rights, environmental, etc. — shouldn't shift)
- Pre-treatment trends in donation behavior

**Why it's novel:**
1. First individual-level linkage of Medicaid billing data to political donations (Medicare × FEC exists via Kim 2024 and Jena et al. 2018, but Medicaid × FEC does not)
2. First causal evidence on policy → provider political behavior (existing literature goes the other direction: provider politics → clinical behavior)
3. Builds a new object: the Medicaid provider political engagement panel (617K providers × 4 election cycles)
4. Speaks to regulatory capture, constituency creation, and political persistence of entitlement programs

**The puzzle:** Healthcare providers receive $1.09 trillion annually from Medicaid. Bonica et al. (2014) show physicians lean Republican despite benefiting from government insurance programs. Do providers vote their wallet — or their ideology?

**Scale:** 617K unique Medicaid billing NPIs. ~300K individual providers (Entity Type 1). Expected 30–90K matched provider-donors per election cycle. Massive statistical power.

**Feasibility check:** T-MSIS Parquet on disk (confirmed). FEC API tested and working (3.3M physician donations in 2020 cycle alone). NPPES bulk download available. Medicare PUF on data.cms.gov. All confirmed accessible.

---

## Idea 2: "Does Money Talk? HCBS Rate Shocks and the Political Voice of Care Workers"

**Policy:** Staggered ARPA-funded HCBS rate increases (2021–2023). North Carolina (+40%, March 2022), Colorado (+6–10%, Jan 2022), Virginia (+12%, July 2021), New Mexico (+8.5%, April 2022), plus ~44 other states with varying timing and magnitude.

**Outcome:** FEC donations by HCBS providers (those billing T-codes in T-MSIS).

**Identification:** DiD — staggered rate increases × before/after. Treatment timing measured directly from T-MSIS as structural breaks in average paid-per-claim for T1019.

**Why it's novel:** Focuses specifically on the HCBS workforce (T-MSIS comparative advantage). Tests whether wage increases for low-paid care workers translate into political engagement.

**Feasibility check:** Policy confirmed, data accessible. CONCERN: Nearly universal treatment (48/50 states raised rates) limits clean never-treated control group. Rate increase timing is messy. Home health aides donate at much lower rates than physicians (~72K FEC records for "HOME HEALTH" occupation in 2020 vs. 3.3M for physicians).

**Risk:** Underpowered for extensive margin (home care workers donate infrequently). Short post-period for many states. Better as a supplementary analysis within Idea 1 than as a standalone paper.

---

## Idea 3: "The Political Price of Unwinding: Provider Donations After Medicaid Disenrollment"

**Policy:** Medicaid continuous enrollment ended April 1, 2023. States unwound on different timelines: Arkansas/Idaho (April 2023) through California/New York (mid-2024). 25+ million disenrolled.

**Outcome:** Provider donations in the 2024 FEC election cycle.

**Identification:** DiD — staggered unwinding timing × before/after.

**Why it's novel:** Tests whether losing patients (revenue shock) politicizes providers. Direct test of "voice vs. exit" in healthcare markets.

**Feasibility check:** Policy well-documented. CONCERN: Only one post-treatment election cycle (2024). Judges penalize short post-periods. The T-MSIS window ends Dec 2024, limiting post-treatment observation.

**Risk:** Short post-period makes nulls uninterpretable. Better as a subsection within Idea 1 (exploiting unwinding as an additional shock) than standalone.

---

## Idea 4: "The Captured Constituency: Open Payments, Medicaid Prescribing, and Political Engagement"

**Policy:** CMS Open Payments (Sunshine Act) — pharma/device industry payments to individual providers (linked by NPI).

**Outcome:** Triple linkage: Open Payments → T-MSIS prescribing → FEC donations. Do pharma-paid providers prescribe more brand-name drugs in Medicaid AND donate to pharma-friendly candidates?

**Identification:** Provider fixed effects + timing of first industry payment. Pre/post receipt of industry money.

**Why it's novel:** Only paper linking all three datasets at the individual provider level.

**Feasibility check:** All data confirmed accessible (Open Payments on data.cms.gov, T-MSIS local, FEC bulk). CONCERN: Severe selection bias — pharma targets high-prescribing providers. Without random assignment, causal claims are limited. Cross-sectional design won't convince skeptics.

**Risk:** No clean quasi-experiment. Selection dominates. Descriptive but not causal.

---

## Idea 5: "Regulatory Capture at the Bedside: Medicaid Expansion, Provider Revenue, and State Legislative Donations"

**Policy:** Same as Idea 1 (staggered Medicaid expansion) but focuses on state legislative campaigns rather than federal.

**Outcome:** State-level campaign finance records via FollowTheMoney/NIMSP database.

**Identification:** Same DDD as Idea 1 but with state-level donation data.

**Why it's novel:** State legislators directly control Medicaid policy, so the "regulatory capture" channel is more direct than federal donations.

**Feasibility check:** CONCERN: State campaign finance data is fragmented — different filing rules, different databases, different fields across 50 states. The National Institute on Money in Politics (NIMSP/FollowTheMoney) aggregates some data, but coverage is incomplete and format inconsistent. Individual-level matching to NPPES would be far more difficult than with the standardized FEC data.

**Risk:** Data quality too heterogeneous for credible analysis. Would require heroic data cleaning with no guarantee of success. Federal FEC data (Idea 1) is much cleaner.

---

## Ranking

**Idea 1 >> Ideas 2, 3, 5 > Idea 4**

Idea 1 is the clear winner:
- Cleanest identification (staggered Medicaid expansion with 7+ treated states)
- Largest scale (600K+ providers, millions of FEC records)
- Best-defined control groups (DDD with multiple built-in placebos)
- Genuine puzzle (do providers vote their wallet?)
- Novel object (first Medicaid × FEC linkage)
- Multiple mechanism tests
- Speaks to first-order political economy questions

Ideas 2 and 3 work as supplementary analyses within Idea 1 (additional policy shocks). Idea 4 lacks a clean causal design. Idea 5 has data quality problems.
