# Research Ideas

## Idea 1: Do Red Flag Laws Reduce Violent Crime? Modern Staggered DiD Evidence from 22 States

**Policy:** Extreme Risk Protection Orders (ERPOs / "Red Flag" laws) — court orders temporarily restricting firearm access for individuals deemed dangerous. 22 states + DC adopted between 1999 and 2024: CT (1999), IN (2005), CA (2016), WA (2016), OR (2018), FL (2018), VT (2018), RI (2018), MA (2018), MD (2018), DE (2018), IL (2019), DC (2019), CO (2019), NJ (2019), NY (2019), HI (2020), NV (2020), NM (2020), VA (2020), MN (2024), MI (2024).

**Outcome:** FBI UCR Offenses Known data (Kaplan concatenated files, Harvard Dataverse, 1960–2023). Primary: state-level murder and aggravated assault rates. Secondary: robbery, total violent crime. Firearm-specific homicide from Supplementary Homicide Reports (SHR).

**Identification:** Callaway & Sant'Anna (2021) staggered DiD exploiting cross-state variation in adoption timing. Event study with group-time ATTs. 28 never-treated states serve as clean controls. Anti-ERPO states (OK, TN, WV, WY, MT, TX) provide additional placebo.

**Why it's novel:** RAND rates existing evidence on ERPOs and violent crime as "inconclusive" — all prior work uses TWFE (biased under heterogeneity), single-state studies, or synthetic control. Heflin (2023, JMP) is closest but uses standard TWFE. No published paper applies modern heterogeneity-robust DiD to 22 treated states. The suicide literature is better developed; the violent crime channel is the clear gap.

**Feasibility check:** Confirmed: 22 treated states (exceeds 20 minimum), UCR data freely downloadable, template R script available. Pre-treatment data extends to 1960 for CT. ERPO adoption dates verified via National ERPO Resource Center (Johns Hopkins).

**Mechanism decomposition:**
1. First stage: ERPO petition filings (state court records)
2. Firearm vs. non-firearm homicide (SHR weapon type)
3. Intimate partner violence vs. stranger violence (SHR circumstances)
4. Heterogeneity by petitioner type (law enforcement only vs. family + LE)

**Built-in placebos:**
- Property crime (ERPOs remove firearms, should not affect burglary/larceny)
- Anti-ERPO states as explicit control group
- Pre-2018 period for 2018 wave states (long pre-trend)

---

## Idea 2: Does Relaxing Mandatory Minimums Increase Crime? Justice Reinvestment Reforms and Public Safety

**Policy:** State-level mandatory minimum sentencing reforms under the Justice Reinvestment Initiative (JRI) and independent state legislation. 24+ states reduced or eliminated drug mandatory minimums since 2001: MI (2003), NY (2004/2009), SC (2010), KY (2011), OH (2011), GA (2012), OK (2012), MA (2012), CT (2015), and others through 2020.

**Outcome:** FBI UCR state-level crime rates: drug arrests (most direct), property crime (burglary, larceny, MVT), violent crime (murder, robbery, assault). Panel from 2000–2019 avoids NIBRS transition and COVID disruption.

**Identification:** CS-DiD exploiting staggered reform adoption. Never-reformed states as controls. Dose-response variant exploiting reform intensity (full repeal vs. safety valve vs. threshold increase).

**Why it's novel:** No published study uses modern staggered DiD methods to study the crime effects of mandatory minimum reforms. Agan, Doleac & Harvey (2025, NBER WP 34364) study prosecutorial reforms but not legislative changes. Dobkin & Nicosia (2009, AER) study drug supply disruptions, not sentencing changes. The National Research Council (2014) concluded mandatory minimums have "few, if any, deterrent effects" but cited no credible state-level DiD evidence.

**Feasibility check:** 24+ states confirmed by Sentencing Project and Vera Institute. Reform dates available from FAMM, JRI database, and state legislative records. UCR data covers 2000–2019.

**Risk:** JRI reforms were multi-component packages (parole, probation, sentencing all changed together). Isolating the mandatory minimum component requires careful coding and potentially DDD (reform × drug offense × state).

---

## Idea 3: Felony Theft Thresholds and Property Crime — Evidence from Dollar-Amount Reclassification

**Policy:** State-level increases to the felony theft threshold (the dollar amount above which theft becomes a felony). 40+ states raised thresholds since 2000: TX raised from $750 to $2,500 (2015), CO from $500 to $2,000 (2019), CA effectively raised to $950 via Prop 47 (2014), etc. Thresholds range from $200 (NJ) to $2,500 (TX, WI).

**Outcome:** FBI UCR larceny-theft counts and rates. Property crime index. UCR captures total larceny reports regardless of classification. Secondary: clearance rates (do police investigate less when theft is a misdemeanor?).

**Identification:** CS-DiD exploiting staggered threshold increases. States that never raised thresholds serve as controls.

**Why it's novel:** The Prop 47 literature (Lofstrom et al. 2016; Bartos & Kubrin 2018) is California-specific. No multi-state staggered DiD exists. The question has "first-order policy stakes" — threshold increases are politically contentious (California partially reversed via Prop 36 in 2024).

**Feasibility check:** Threshold data available from Pew Research Center's compilation. 40+ states with variation. UCR larceny data is the most reliably reported crime type.

**Risk:** Thresholds affect charging, not reporting to police. UCR counts "offenses known" (reports), which may not change even if classification shifts. The outcome measurement may be too upstream of the mechanism. Need to decompose into reporting vs. actual behavior.

---

## Idea 4: Domestic Violence Firearm Restrictions and Intimate Partner Homicide

**Policy:** State laws prohibiting firearm possession by individuals subject to domestic violence restraining orders or convicted of DV misdemeanors. These go beyond the federal Lautenberg Amendment (1996) by expanding covered relationships, requiring firearm surrender (not just prohibiting purchase), or extending to dating partners.

**Outcome:** FBI Supplementary Homicide Reports (SHR): intimate partner homicides by weapon type (firearm vs. non-firearm). Secondary: total DV-related homicides, aggravated assault.

**Identification:** CS-DiD exploiting staggered adoption of state-level firearm surrender requirements for DV offenders. ~30 states with variation in timing and stringency.

**Why it's novel:** Zeoli & Webster (2010) and Zeoli et al. (2018, Annals of Internal Medicine) studied this using TWFE with limited state variation. A modern CS-DiD with 30+ states, firearm-specific decomposition, and HonestDiD sensitivity would be a substantial methodological upgrade.

**Feasibility check:** SHR data available through Kaplan concatenated files. Victim-offender relationship codes allow isolation of intimate partner incidents. Weapon type codes distinguish firearm from non-firearm.

**Built-in placebo:** Non-intimate-partner homicide (DV firearm laws should not affect stranger homicide). Non-firearm IPH (mechanism-specific: laws target firearms, not other weapons).

---

## Idea 5: The Deterrent Effect of Fentanyl-Specific Criminal Penalties on Drug Crime and Overdose

**Policy:** State-level fentanyl-specific sentencing enhancements: felonization of possession, trafficking threshold laws, and drug-induced homicide provisions. 39+ states enacted some provision, with major adoption wave 2021–2024.

**Outcome:** FBI UCR drug arrest rates (total — cannot isolate fentanyl-specific arrests due to NIBRS coding). CDC WONDER synthetic opioid (T40.4) mortality as primary outcome for mechanism.

**Identification:** CS-DiD with staggered adoption. LawAtlas Drug Induced Homicide Laws dataset (2018–2024) provides coded panel.

**Why it's novel:** No causal study exists. Irvine et al. (2023) provide only a Markov simulation; Colorado ITS has no comparison group.

**Feasibility check:** WEAK for FBI data specifically. NIBRS code H ("Other Narcotics") lumps fentanyl with hydrocodone, codeine, methadone. Cannot isolate fentanyl arrests. Very recent adoption (mostly 2021–2024) → short post-periods.

**Risk:** Fatal data limitation — FBI crime data cannot distinguish fentanyl-specific outcomes. Endogeneity: states adopted laws precisely because fentanyl was surging. This idea would need CDC WONDER as primary outcome, making FBI data secondary at best.
