# Research Ideas — apep_0488

## Idea 1: The Welfare Cost of Prescription Drug Monitoring Programs: A Sufficient Statistics Approach

**Policy:** Must-access PDMP mandates requiring prescribers to query a state database before writing opioid prescriptions. Staggered adoption: Kentucky (2012), Tennessee/New York/West Virginia (2013), Ohio (2015), ~36 states by 2019. Treatment dates from RAND OPTIC dataset.

**Outcome:** (1) Opioid prescribing volume and intensity (Medicare Part D provider-level data, 2013–2023); (2) Overdose mortality (CDC WONDER, state×year); (3) Heroin/illicit opioid mortality (CDC WONDER, separately coded).

**Identification:** Staggered DiD (Callaway–Sant'Anna) exploiting state-level variation in must-access PDMP adoption timing. ~36 treated states across 7+ years of staggered adoption. Rich pre-treatment panel (2013 onward for Part D).

**Theoretical contribution:** Derive the sufficient statistics formula for optimal prescribing regulation under a model with: (a) quasi-hyperbolic patients who underweight future addiction costs (Gruber–Koszegi internality), (b) physician agents who prescribe on behalf of patients (agency wedge), and (c) externalities (overdose deaths, healthcare costs, diversion). The welfare formula is:

dW/dτ = (γ̄ + ē + φ̄) · (−dQ̄/dτ) − v̄_L · (−dQ_L/dτ) − C'(τ)

where γ̄ = average internality, ē = externality, φ̄ = physician agency, v̄_L = value of lost pain management. Each statistic is estimable from the DiD.

**Why it's novel:** The entire opioid policy literature is reduced-form (Buchmueller–Carey 2018, Mallatt 2020, Alpert–Powell–Pacula 2018). Nobody has done welfare analysis of any opioid prescribing regulation. Nobody has applied the sufficient statistics approach (Chetty 2009, Allcott–Lockwood–Taubinsky 2019) to addiction policy. The closest paper — Mulligan (2024 JPE) — does consumer theory for opioid markets but does not quantify welfare or deadweight loss. This paper fills the entire gap between theory and empirics in opioid policy.

**Key empirical insight:** Alpert–Dykstra–Jacobson (2024 AEJ:EP) find hassle costs explain ~70% of the prescribing decline from PDMPs. This means PDMPs are blunt instruments that reduce prescribing across the board — imposing real costs on legitimate pain patients. Whether PDMPs improve welfare depends on whether the internality + externality gains outweigh the pain management losses. The answer is genuinely unknown.

**Three welfare scenarios (theoretical benchmarks):**
1. Rational addiction (Becker–Murphy): γ̄ = 0, PDMP justified only by externalities → welfare ambiguous
2. Moderate present bias (Gruber–Koszegi, β ≈ 0.7): γ̄ > 0, PDMP likely welfare-improving
3. Cue-triggered addiction (Bernheim–Rangel): γ̄ large, PDMP strongly welfare-improving

**Template papers:** Allcott–Lockwood–Taubinsky (2019 QJE), Deshpande–Lockwood (2022 Econometrica), Finkelstein–Hendren (2020 QJE)

**Feasibility check:** Confirmed: RAND OPTIC has clean must-access PDMP dates (GitHub, Stata/Excel). Medicare Part D "by Provider" CSVs available 2013–2023 with built-in opioid columns (Opioid_Tot_Clms, Opioid_Prscrbr_Rate, etc.), NPI identifiers, state/ZIP. CDC WONDER has overdose mortality by state. No API keys needed for any source.

---

## Idea 2: Physician Agency in Opioid Prescribing — Hassle Costs, Patient Sorting, and the Shadow Price of Regulation

**Policy:** Same as Idea 1 (must-access PDMPs), but the empirical focus shifts to physician-level heterogeneity and patient sorting.

**Outcome:** Medicare Part D provider-level panel: prescribing intensity, patient composition (age, race, dual-eligible status, risk scores), opioid share of practice, long-acting vs. short-acting opioid mix.

**Identification:** Staggered DiD at the physician level, exploiting cross-physician variation in pre-PDMP prescribing intensity as a continuous treatment dose. High-prescribing physicians face larger hassle costs from must-access mandates.

**Theoretical contribution:** A model of physician prescribing under regulatory hassle costs (Alpert–Dykstra–Jacobson mechanism), where the physician's prescribing decision is a function of patient severity, expected hassle cost, and perceived liability risk. The PDMP increases hassle costs differentially for different prescription types, inducing patient-level sorting (some patients lose access, some are redirected to non-opioid alternatives).

**Why it's novel:** Schnell–Currie (2018) documented physician heterogeneity. Alpert–Dykstra–Jacobson (2024) identified hassle costs as the mechanism. Nobody has modeled how hassle costs create differential access by patient type, or estimated the shadow price of PDMP hassle costs from physician behavioral responses.

**Feasibility check:** Confirmed: Medicare Part D "by Provider" files have beneficiary demographics (age bins, race, dual-eligible counts, risk scores) alongside opioid prescribing. ~480K opioid prescribers per year, 10-year panel.

---

## Idea 3: Illicit Substitution and the Welfare Paradox of Supply-Side Drug Policy

**Policy:** Same as Ideas 1–2 (must-access PDMPs), but the core question is whether PDMPs increase illicit drug deaths by pushing users from prescription opioids to heroin/fentanyl.

**Outcome:** (1) Prescription opioid mortality (CDC WONDER ICD-10 T40.2); (2) Heroin mortality (T40.1); (3) Synthetic opioid/fentanyl mortality (T40.4); (4) Total opioid mortality — all at state×year level.

**Identification:** Staggered DiD. The substitution channel is tested by comparing PDMP effects on Rx opioid deaths (expected decrease) vs. heroin/fentanyl deaths (expected increase if substitution dominates).

**Theoretical contribution:** Extend Mulligan's (2024 JPE) nonconvex budget set framework to welfare analysis. When PDMPs raise the effective price of prescription opioids, addicted users face a discrete choice: quit, switch to illicit sources (lower per-dose cost but higher mortality risk), or seek treatment. The welfare effect depends on the substitution elasticity between legal and illegal opioids — a new sufficient statistic not in Allcott et al.

**Why it's novel:** Mallatt (2020) and Alpert–Powell–Pacula (2018) documented heroin substitution empirically. Mulligan (2024 JPE) modeled the mechanism theoretically. Nobody has combined the two to ask: does the mortality from substitution to illicit drugs outweigh the mortality reduction from reduced prescribing? Is the net mortality effect of PDMPs positive or negative?

**Feasibility check:** CDC WONDER has cause-specific mortality by ICD-10 codes at state level. RAND OPTIC has PDMP dates. Pre-existing empirical evidence (Mallatt, Alpert et al.) confirms the substitution channel exists.

---

## Idea 4: The Long-Acting Opioid Paradox — PDMPs, Formulary Switching, and the Durability-Safety Tradeoff

**Policy:** Must-access PDMPs (same policy variation), but focused on the composition of opioid prescribing: long-acting (LA) vs. short-acting formulations.

**Outcome:** Medicare Part D "by Provider" data separately reports: Opioid_LA_Tot_Clms, Opioid_LA_Tot_Drug_Cst, Opioid_LA_Tot_Suply, Opioid_LA_Tot_Benes, Opioid_LA_Prscrbr_Rate — alongside total opioid measures. This allows decomposing the PDMP effect into changes in long-acting vs. short-acting prescribing.

**Identification:** Staggered DiD on the LA-to-total opioid ratio at the prescriber level.

**Why it's novel:** Long-acting opioids (e.g., OxyContin, fentanyl patches, extended-release morphine) are the highest-risk formulations for addiction and diversion, but also the most appropriate for chronic pain patients. If PDMPs reduce both LA and short-acting equally, they're not well-targeted. If they selectively reduce LA, they may hurt chronic pain patients disproportionately. This composition question hasn't been studied.

**Feasibility check:** Confirmed: Medicare Part D "by Provider" files have separate LA opioid columns built in. No additional data needed.

---

## Ranking

**Strong preference for Idea 1.** It is by far the most ambitious — a genuine theoretical + empirical contribution that fills a clear gap at the intersection of addiction economics, sufficient statistics, and pharmaceutical regulation. The welfare formula is the contribution. The DiD estimates populate it. The three theoretical benchmarks (rational, present-biased, cue-triggered) give policy-relevant bounds. This is an Econometrica paper.

Ideas 2–4 are valuable complements that could serve as mechanism sections within Idea 1 (especially Idea 2's physician agency and Idea 3's substitution channel), rather than standalone papers.
