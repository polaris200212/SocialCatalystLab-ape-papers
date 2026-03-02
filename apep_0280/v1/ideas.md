# Research Ideas

## Idea 1: From Workplace to Living Room — Do Indoor Smoking Bans Cultivate Anti-Smoking Norms Beyond Their Legal Reach?

**Policy:** Comprehensive statewide indoor smoking bans (workplaces + restaurants + bars). 28 states + DC adopted between 2002 (Delaware) and 2016 (California), with staggered timing. Treatment dates verified from CDC MMWR 2011 and 2016 reports. ~22 non-adopting states serve as comparison group.

**Outcome:** BRFSS (Behavioral Risk Factor Surveillance System), 1995–2023. Individual-level annual survey data with state identifiers. Key variables: current smoking status (_SMOKER3/SMOKDAY2), quit attempts (STOPSMK2), cigarettes per day (SMOKDAY2 intensity). Available for all 50 states, every year. BRFSS download code exists in the codebase (papers/apep_0058/v1/code/02_fetch_brfss.R).

**Identification:** DR-DiD using Callaway and Sant'Anna (2021) doubly-robust estimator. Staggered adoption across 28 states provides clean group-time ATTs. Individual-level covariates (age, education, race, sex, income) support the doubly-robust specification. Event study plots test parallel trends. 15+ pre-treatment years for early adopters, 25+ for late adopters. Randomization inference for p-values.

**Why it's novel:** The vast literature on smoking bans focuses on compliance (workplace exposure declines) and health (heart attacks fall). The fundamental NORMS question — does mandated public behavior change private voluntary behavior? — is remarkably understudied. Adda & Cornaglia (2010 AER) study displacement (do people smoke more at home?), but they measure passive exposure, not active norm adoption. My paper measures whether people CHOOSE to quit smoking and adopt stricter personal rules — the difference between forced compliance and internalized norm change. Key theoretical test: if bans merely relocate smoking, the quit-attempt effect should be zero. If bans change norms, quit attempts should increase AND the effect should GROW over time (norm internalization).

**Feasibility check:** Confirmed. 28 treated states (≥20 ✓). BRFSS data accessible via CDC download (HTTP 200 verified). Pre-treatment periods ≥5 years for all states (earliest adoption 2002, BRFSS back to 1984). Comparison group: ~22 never-treated states. Variables confirmed in BRFSS codebook.


## Idea 2: From "Snitching" to Saving — Do Good Samaritan Laws Change Social Norms Around Drug Treatment-Seeking?

**Policy:** State Good Samaritan Laws providing immunity from prosecution for calling 911 during a drug overdose. ~47 states adopted between 2007 (New Mexico) and 2019, with heavy staggered adoption 2012–2017. PDAPS database has verified adoption dates for all states.

**Outcome:** CDC provisional drug overdose death counts (data.cdc.gov/resource/xkb8-kh2a, state × year × drug type, 2015–2024; API access confirmed). Secondary: SAMHSA TEDS treatment admissions by referral source (self-referral vs. criminal justice referral; downloadable from SAMHSA, 1992–2022).

**Identification:** DR-DiD with staggered adoption. Rich covariates: state demographics (ACS), opioid prescribing rates, political orientation, pre-existing treatment infrastructure. Event study for dynamic effects.

**Why it's novel:** Existing papers (Rees et al. 2019, McClellan et al. 2018) test whether GSL laws reduce mortality. My paper tests whether they change NORMS — measured by the referral source decomposition in TEDS. If GSL laws change norms around help-seeking, self-referrals to treatment should increase (destigmatization). If they merely reduce emergency reporting costs, only emergency-room referrals change. Dynamic effects test norm internalization.

**Feasibility check:** CDC overdose data API confirmed working (2015–2024, all states). TEDS data downloadable from SAMHSA (1992–2022). But ~40 states adopted before 2015, limiting CDC data pre-periods for early adopters. TEDS panel covers full adoption window. 47 treated states ≥20 ✓.


## Idea 3: Legislating Parental Responsibility — Do Social Host Liability Laws Change Youth Drinking Norms?

**Policy:** State social host liability laws making adults civilly or criminally liable when minors consume alcohol on their property. 31+ states have criminal penalties, staggered adoption from 1980s to present. APIS (Alcohol Policy Information System) at NIAAA has comprehensive policy data with state × year coding.

**Outcome:** YRBS (Youth Risk Behavior Survey) for teen drinking behavior (binge drinking, drunk driving) — biennial, state-level, 1991–present. FARS (Fatality Analysis Reporting System) for teen traffic fatalities with alcohol involvement — NHTSA API (2010+) or bulk download (1975+). CDC WONDER motor vehicle mortality by age group.

**Identification:** DR-DiD with staggered state adoption. Controls: minimum drinking age, excise taxes, zero-tolerance laws, MIP (minor in possession) laws. Event study, placebo tests on adult populations (who aren't affected by the social host norm channel).

**Why it's novel:** Most alcohol policy research focuses on prices (excise taxes), access (MLDA, hours of sale), and individual sanctions (MIP laws). SHL laws are unique because they create PEER ENFORCEMENT among parents — a social norm mechanism rather than a direct deterrent on youth. The research tests whether legal liability on hosts changes community-level drinking norms (measured by binge drinking rates even for teens NOT at home parties).

**Feasibility check:** Uncertain. APIS policy data exists but web scraping needed. YRBS is biennial (limits temporal resolution). FARS API covers only 2010+. Could use CDC WONDER compressed mortality 1999–2020 for longer panel. 31+ treated states ✓.


## Idea 4: Can You Ban Stigma? State Anti-Conversion Therapy Bans and LGBTQ+ Mental Health

**Policy:** State bans on conversion therapy for minors. ~22 states adopted between 2012 (California) and 2023 (Minnesota), with staggered timing. Well-documented adoption dates via MAP (Movement Advancement Project) and legislative records.

**Outcome:** BRFSS for mental health outcomes (poor mental health days, depression screening), available 1995–2023 with state identifiers. CDC WONDER suicide mortality data by state, age, and year. ACS for same-sex household formation (proxy for reduced stigma).

**Identification:** DR-DiD with staggered adoption. Rich covariates for treatment selection (state political orientation, urbanization, prior LGBTQ+ protections). Event study for dynamic effects. Placebo test: heterosexual mental health outcomes shouldn't change.

**Why it's novel:** Bans directly address a stigmatizing practice, but their broader norm effect — do they signal LGBTQ+ acceptance and reduce ambient stigma? — is unstudied. Most papers examine whether bans reduce conversion therapy itself (small base rate). My paper tests whether the SIGNAL of the ban (legal declaration that LGBTQ+ identity is not a disorder) changes population-level mental health outcomes, even among those never at risk of conversion therapy.

**Feasibility check:** Moderate. 22 treated states ≥20 ✓. BRFSS accessible ✓. Challenge: BRFSS doesn't identify LGBTQ+ respondents in most years (sexual orientation questions added only recently and optionally). Would need to test population-level effects or use demographic proxies. Mental health outcome may be too diffuse.


## Idea 5: The Internalization Puzzle — Do Mandatory Calorie Labels Change Dietary Norms or Just Dining Choices?

**Policy:** Mandatory calorie labeling at chain restaurants. NYC (2008) pioneered; several cities/states followed before federal ACA mandate (implemented 2018). Key staggered variation comes from early adopters vs. federal compliance.

**Outcome:** BRFSS for obesity (BMI), fruit/vegetable consumption, and health behaviors by state × year. CDC's Nutrition, Physical Activity, and Obesity surveillance data (Socrata API). State-level obesity prevalence trends.

**Identification:** DR-DiD exploiting early city/state adopters as treated group vs. late federal-compliance states. Rich individual-level covariates from BRFSS. Event study for dynamic effects.

**Why it's novel:** Tests the Thaler-Sunstein nudge hypothesis: do informational nudges (calorie labels) change NORMS around dietary choices, or just inform a one-time calculation? If norms change, effects should persist and grow; if just information, effects should be immediate and static. Can also test spillover to NON-labeled contexts (grocery shopping, home cooking) — if norms change, dietary improvement should extend beyond restaurants.

**Feasibility check:** Weak. The staggered variation is primarily city-level (NYC, Philadelphia, King County WA), not state-level, making state-level analysis noisy. Federal mandate in 2018 contaminates comparison group. BRFSS obesity measures have known biases (self-reported height/weight). Only ~5 pre-federal treated jurisdictions ✓ but below 20-state threshold ✗.
