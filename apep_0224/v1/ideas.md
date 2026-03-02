# Research Ideas

## Idea 1: School Suicide Prevention Training Mandates and Youth Suicide Rates

**Policy:** State mandates requiring school personnel to receive suicide prevention gatekeeper training (Jason Flatt Act and broader mandatory training laws). Staggered adoption across 25+ states from 2006-2017. Key adopters: NJ (2006), TN (2007), LA (2008), CA (2008), MS (2009), IL (2010), AR (2011), CT (2011), WV (2012), UT (2012), SC (2012-2013), OH (2012), ND (2013), WY (2014), ME (2014), WA (2014), GA (2015), TX (2015), AL (2016), KS (2016), SD (2016-2017). Sources: Lang et al. (2024, Prev Chronic Disease PMC11504333), Jason Foundation records.

**Outcome:** State-year suicide mortality (deaths and age-adjusted death rates) from CDC NCHS Leading Causes of Death dataset via Socrata API (dataset bi63-dtpu), covering 1999-2017 for all 50 states + DC.

**Identification:** Staggered difference-in-differences exploiting variation in adoption timing. Callaway-Sant'Anna (2021) heterogeneity-robust estimator. Event study for parallel trends validation. 17+ states with 3+ post-treatment years. Never-treated and not-yet-treated states as controls.

**Why it's novel:** No existing causal study. The only prior work (Strnad et al. 2024, Psychiatric Services) used just two time points in a cross-sectional design with no DiD. Lang et al. (2024) explicitly called for evaluation research. This would be the first application of modern staggered DiD to this widespread policy.

**Social norms mechanism:** These mandates operate through norm change, not direct intervention. They train teachers, counselors, and staff to (1) recognize warning signs, (2) initiate conversations about mental health, and (3) create institutional environments where help-seeking is normalized. The paper tests whether this "soft" social norms intervention produces "hard" mortality reductions.

**Feasibility check:** Confirmed. Socrata API returns state-year suicide deaths (tested). 25+ treated states exceed 20-state threshold. 7-18 pre-treatment years per cohort. Treatment variation validated against two independent sources (Jason Foundation + Lang et al. PMC data).

---

## Idea 2: Extreme Risk Protection Orders (ERPOs) and the Social Norms of Community Intervention

**Policy:** State ERPO/"red flag" laws allowing courts to temporarily remove firearms from individuals deemed dangerous. 22 states adopted, staggered from 1999-2024. Early adopters: CT (1999), IN (2005), CA (2016), WA (2016), OR (2018). Major post-Parkland wave: FL, VT, MD, RI, NJ, DE, MA, IL (all 2018).

**Outcome:** CDC WONDER firearm suicide and firearm homicide rates by state-year (1999-2023).

**Identification:** Staggered DiD with Callaway-Sant'Anna. 22 treated states, 19 pre-treatment years for the 2018 wave. ~28 never-treated states.

**Why it's novel:** RAND rates evidence as "limited" for suicide and "inconclusive" for homicide. No published peer-reviewed study uses modern staggered DiD with the full 22-state variation. Heflin (2022 JMP) uses C-S but remains unpublished.

**Feasibility check:** Partially confirmed. CDC WONDER requires manual web query (not programmatic via API), which limits replicability. The 2018 clustering (8+ states same year) creates methodological challenges for DiD — treatment effect heterogeneity hard to identify when most treatment turns on simultaneously.

---

## Idea 3: Anti-Bullying Laws with Enumerated Protections and School Climate

**Policy:** State anti-bullying laws that enumerate specific protected categories (race, sex, sexual orientation, disability). 21 states + DC adopted enumerated laws, staggered from 1994-2019. Key adopters include VT (1994), WA (2001), NJ (2002), IA (2008), MD (2008), NY (2009), OR (2009), IL (2010), CT (2011), CA (2012), CO (2012), MA (2014), MN (2014).

**Outcome:** YRBSS state-level bullying victimization prevalence (2009-2023, biennial). Secondary: CDC WONDER youth suicide rates.

**Identification:** Staggered DiD comparing states that adopted enumerated laws vs. states with generic (non-enumerated) anti-bullying laws.

**Why it's novel:** Moderate novelty. Sabia & Bass (2017, J Pop Econ) conducted a DiD of anti-bullying laws generally, finding null effects for typical laws but significant effects for comprehensive policies. However, enumerated protections as the PRIMARY treatment variable (not just a heterogeneity dimension) has not been studied. The LawAtlas dataset (Ramirez et al. 2024) now provides comprehensive coding of 122 policy components.

**Feasibility check:** Partially confirmed. YRBSS bullying question only available from 2009, limiting pre-treatment periods for early adopters. State participation varies across waves. Data access requires downloading combined SADC datasets. Existing DiD literature reduces novelty significantly.

---

## Idea 4: Social Host Liability Laws and Teen Alcohol Norms

**Policy:** State social host liability (SHL) laws holding adults civilly or criminally liable for providing alcohol to minors on their premises. Staggered adoption across states, with variation in civil vs. criminal liability and strength of penalties.

**Outcome:** YRBSS state-level teen alcohol use prevalence (current drinking, binge drinking). Secondary: fatal alcohol-related crashes among teens from FARS.

**Identification:** Staggered DiD exploiting variation in SHL adoption timing.

**Why it's novel:** SHL laws explicitly target social norms — they change adult behavior around hosting teen drinking parties. The mechanism is pure norm change: adults internalize that facilitating underage drinking carries legal consequences, shifting community expectations.

**Feasibility check:** Needs validation. SHL law adoption dates need systematic compilation; many adopted in the 1990s-2000s which pre-dates YRBSS alcohol questions. FARS data is programmatically accessible but teen-specific crash data may have small samples in some states. More research needed on treatment variation.

---

## Idea 5: State Mandated Sexual Harassment Training and Workplace Norms

**Policy:** State mandates requiring employers to provide sexual harassment prevention training. Adoptions: CA (SB 1343, 2019 effective), NY (2019), IL (2020), CT (2019), DE (2019), ME (2020).

**Outcome:** EEOC sexual harassment charge filings by state. Secondary: female labor force participation from CPS/ACS.

**Identification:** Staggered DiD.

**Why it's novel:** Tests whether mandated workplace training changes norms around harassment reporting and occurrence.

**Feasibility check:** WEAK. Only 6 states adopted during a narrow window (2019-2020), well below the 20-state threshold. COVID-19 confounds the treatment period. EEOC data by state may have access limitations. REJECT on treated-state count.
