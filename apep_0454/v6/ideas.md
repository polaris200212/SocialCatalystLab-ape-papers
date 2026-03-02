# Research Ideas

## Idea 1: The Long Shadow of Provider Loss — Pre-Pandemic Medicaid Workforce Depletion and Deaths of Despair During COVID-19

**Policy:** COVID-19 pandemic as an exogenous demand shock for behavioral health services; state-level COVID policy stringency (OxCGRT) as continuous treatment intensity.

**Outcome:** (Primary) CDC provisional drug overdose deaths and suicide mortality by state-month, 2018–2024. (Secondary) T-MSIS behavioral health claims, beneficiaries served, and provider billing volume by state-month.

**Identification:** Continuous-treatment DiD with pre-determined exposure. Counties/states with higher pre-COVID (2018–2019) Medicaid behavioral health provider exit rates are differentially exposed when the pandemic creates a surge in mental health and substance use disorder demand. The key interaction: Post-March-2020 × Pre-COVID-Exit-Rate. Parallel pre-trends in cause-specific mortality (overdose, suicide) across exit-rate quartiles validate the design. Shift-share instrument: national specialty-specific exit trends × local specialty composition gives exogenous variation in predicted exits.

**Why it's novel:**
- First paper using T-MSIS billing cessation to measure pre-pandemic provider supply vulnerability
- Reframes COVID health effects from acute respiratory mortality to behavioral health/deaths of despair — where HCBS/behavioral health providers (T-MSIS's comparative advantage) are directly relevant
- Tests whether pre-existing "supply deserts" amplified COVID's indirect health toll
- Short-run (2020–2021: acute disruption) vs. long-run (2022–2024: persistent gaps or recovery)

**Feasibility check:**
- T-MSIS 2018–2024 available (need to download 2.74 GB Parquet); NPPES provides state/county geography (99.5% match)
- CDC provisional drug overdose death counts available via data.cdc.gov Socrata API (state × month, kn79-hsxy)
- OxCGRT US sub-national data on GitHub (policy stringency by state × date)
- Pre-COVID exit measurement: billing cessation (no claims for 6+ months) + NPPES enumeration date as career-length proxy + deactivation date
- Pre-trend validation possible: 24 months pre-COVID (Jan 2018 – Feb 2020)
- Concern: county-level CDC data suppressed when deaths < 10; use state-level aggregation for deaths, county-level for T-MSIS outcomes

**DiD feasibility:** Not a standard staggered DiD — this is a continuous-treatment event study design. "Treatment" = pre-COVID exit intensity (continuous); "Event" = pandemic onset (March 2020). All states observed, variation is in exposure intensity. Pre-trend validation across exit-rate quartiles is the key assumption test.

---

## Idea 2: Mandate and Mend? Healthcare Worker Vaccine Mandates and Medicaid Provider Exits

**Policy:** State-level healthcare worker COVID-19 vaccine mandates. 15 states enacted mandates before the federal CMS mandate (Nov 2021). Timing varies: New York (Aug 2021), California (Aug 2021), Washington (Oct 2021), others through late 2021. Federal CMS mandate effective Jan 2022 for remaining states.

**Outcome:** T-MSIS provider exits (billing cessation), billing volume changes, service gaps (beneficiaries per provider), and provider entry rates by state-month.

**Identification:** Staggered DiD (Callaway-Sant'Anna). Treated states = those with pre-federal state mandates. Never-treated (until federal mandate) as comparison. Event study with 6+ months pre-mandate and 24+ months post for long-run effects. Placebo: higher-wage physician providers (more likely vaccinated) should show smaller exits than lower-wage HCBS workers.

**Why it's novel:**
- First study of vaccine mandates on Medicaid-specific workforce using claims data
- HCBS/behavioral health workers disproportionately affected (lower vaccination rates than physicians)
- Can distinguish short-run panic exits from long-run supply adjustment
- Wang & Stoecker (2024 JAMA Network Open) studied vaccination uptake, not workforce exits

**Feasibility check:**
- 15 treated states (below 20 threshold — borderline). Could extend to federal mandate (Jan 2022) affecting remaining states for second event.
- State mandate dates available from Ballotpedia and Wang & Stoecker (2024)
- T-MSIS covers the full mandate period (2021–2024)
- NPPES taxonomy codes distinguish behavioral health providers from physicians
- Pre-period: 12+ months (Jan–Jul 2021 before first mandates)
- Concern: confounded with other fall 2021 events (Delta wave, booster rollout, return-to-work pressures)

**DiD feasibility:** 15 treated states is below the 20-state threshold but close. Strong placebo (high-wage vs. low-wage providers) mitigates concerns. Could also use federal mandate as a second natural experiment.

---

## Idea 3: Did the Rescue Plan Rescue? ARPA HCBS Spending and Provider Supply Recovery Post-COVID

**Policy:** American Rescue Plan Act Section 9817 (March 2021) — 10 percentage point FMAP increase for HCBS spending. States submitted spending plans to CMS on different timelines (April 2021 through 2023). Plans included rate increases, workforce bonuses, service expansions, and technology investments.

**Outcome:** T-MSIS HCBS provider counts (active billing NPIs), billing volume, new provider entries, and beneficiaries served by state-month.

**Identification:** Staggered DiD exploiting state-level variation in ARPA HCBS spending plan approval and implementation dates. Some states deployed funds quickly (2021); others took 12–18 months. Interaction with pre-ARPA provider exit rates tests whether funding was more effective in depleted markets.

**Why it's novel:**
- First evaluation of ARPA HCBS effectiveness using actual claims data (prior work is descriptive: KFF surveys, MACPAC briefs)
- Tests whether federal funding reversed the COVID-era HCBS supply crisis documented in apep_0447
- Interaction with pre-existing provider gaps answers: does money flow to where it's needed, or to where capacity already exists?
- Short-run (immediate post-ARPA) vs. long-run (after enhanced FMAP expires March 2024)

**Feasibility check:**
- ARPA HCBS spending plan dates trackable via CMS.gov and MACPAC
- All 50 states + DC participated (universal adoption, variation in timing)
- T-MSIS covers full ARPA period (April 2021 – Dec 2024)
- Pre-period: Jan 2018 – March 2021 (38 months)
- Concern: states that spent quickly may be systematically different (more organized, more HCBS-dependent); need to address selection

**DiD feasibility:** ≥20 treated states (all 50+DC eventually treated, staggered timing), ≥5 pre-periods (38 months). Passes gate cleanly.

---

## Idea 4: Essential but Expendable — Pre-COVID Solo Practitioner Exits and the Geography of Behavioral Health Access During the Pandemic

**Policy:** COVID-19 pandemic as a common shock; state-level variation in behavioral health parity enforcement, telehealth flexibility, and emergency Medicaid expansions as policy moderators.

**Outcome:** (Primary) T-MSIS behavioral health beneficiaries per provider (access intensity), new behavioral health provider entries, and service diversity (unique HCPCS codes billed per county). (Secondary) SAMHSA National Survey on Drug Use and Health (NSDUH) state-level mental health treatment gap indicators.

**Identification:** Cross-sectional event study. Define "treatment" as counties where solo behavioral health practitioners (NPPES: Entity Type 1, sole proprietor, behavioral health taxonomy) exited T-MSIS billing in 2019. These exits are pre-determined (pre-COVID) and arguably exogenous to the pandemic. Study the evolution of behavioral health access in affected vs. unaffected counties through 2024.

**Why it's novel:**
- Focuses on the "extensive margin" — entire service points disappearing when a solo practitioner retires
- Rural areas where a single provider is the only Medicaid behavioral health option
- Uses T-MSIS to map the "behavioral health desert" geography
- Long-run focus: do new providers eventually fill the gap, or are losses permanent?

**Feasibility check:**
- T-MSIS + NPPES can identify solo behavioral health practitioners and their billing cessation
- Census ZCTA-to-county crosswalk provides county assignment
- NPPES sole_prop flag and Entity Type Code available
- Behavioral health taxonomy codes (e.g., 101Y, 103T, 106H series) available
- Concern: many factors affect behavioral health access besides provider retirements; cross-sectional design is descriptive rather than causal

**DiD feasibility:** Not a standard DiD. Event study with pre-determined county-level treatment. Stronger on measurement novelty than identification.

---

## Idea 5: When the Safety Net Frayed — COVID-19 Continuous Enrollment and the Strain on Medicaid Provider Markets

**Policy:** COVID-19 Public Health Emergency (PHE) continuous enrollment requirement (March 2020 – April 2023). Medicaid enrollment surged by ~23 million. States could not disenroll beneficiaries regardless of eligibility changes. Provider supply did not proportionally expand.

**Outcome:** T-MSIS beneficiaries per active provider (provider strain), average claims per provider, provider entry/exit rates, and service mix changes by state-month.

**Identification:** Continuous enrollment is a federal mandate (no cross-state variation in the mandate itself). But pre-existing state-level variation in Medicaid expansion status (expansion vs. non-expansion states under ACA) creates differential exposure: expansion states had larger enrollment surges. DiD comparing expansion vs. non-expansion states' provider-level strain during PHE.

**Why it's novel:**
- First provider-side analysis of the continuous enrollment mandate (existing literature focuses on beneficiary-side: coverage, health outcomes)
- Tests whether the supply side can absorb a massive, sustained demand shock
- Natural complement to the unwinding papers (apep_0307, apep_0416) — this studies the build-up, not the wind-down
- Long-run: did the strain cause permanent provider exits or was it absorbed?

**Feasibility check:**
- T-MSIS 2018–2024 covers full PHE period
- Medicaid expansion status (14 non-expansion states as of March 2020) provides cross-state variation
- KFF tracks expansion dates and enrollment changes
- Pre-period: Jan 2018 – Feb 2020 (26 months)
- Concern: Medicaid expansion states differ in many ways from non-expansion states; parallel trends may be violated

**DiD feasibility:** 14 non-expansion states as "control," 36+ expansion states as "treated" (higher enrollment surge). ≥5 pre-periods. Passes gate on counts, but parallel trends assumption is the key test.
