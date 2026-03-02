# Research Ideas

## Idea 1: The Tongue of Empire — Official English Laws and Immigrant Economic Assimilation

**Policy:** State Official English laws — 30 states have designated English as their official language through statutes, constitutional amendments, or ballot measures. The modern wave spans 1981 (Virginia) to 2016 (West Virginia), with peak adoption in 1986–1998. These laws are a direct modern manifestation of British colonial linguistic imperialism: English dominance in the US is a consequence of colonization, and Official English laws codify that dominance into state policy.

**Adoption timeline (modern wave):**
- 1981: Virginia
- 1984: Indiana, Kentucky, Tennessee
- 1986: California (Prop 63), Georgia (resolution)
- 1987: Arkansas, Mississippi, North Carolina, North Dakota, South Carolina
- 1988: Arizona (Prop 106, struck down 1998), Colorado, Florida
- 1990: Alabama
- 1995: Montana, New Hampshire, South Dakota
- 1996: Georgia (statute), Wyoming
- 1998: Alaska, Missouri
- 2000: Utah
- 2002: Iowa
- 2006: Arizona (Prop 103, replacement)
- 2007: Idaho, Kansas
- 2010: Oklahoma
- 2016: West Virginia

**Outcome:** Immigrant earnings, employment rates, and English proficiency — measured via ACS/Census PUMS (WAGP, ESR, ENG variables). Annual data from ACS 2005–2023; decennial census 1980, 1990, 2000 for earlier periods. ~3 million observations per ACS year.

**Identification:** Staggered DiD using Callaway-Sant'Anna estimator. Triple-difference design: (foreign-born vs. US-born) × (adopting vs. non-adopting states) × (before vs. after adoption). US-born workers in the same state serve as a within-state control, netting out state-level shocks.

**Why it's novel:** Despite 30 states adopting these laws over 35 years, **no published study** uses the staggered adoption of modern Official English laws as a natural experiment to estimate effects on immigrant labor market outcomes with modern DiD methods. Bleakley & Chin (2004, 2010) study English proficiency effects using critical-period instruments, and one NBER working paper examines 1910–1930 era English-only laws, but the modern wave (1981–2016) is unstudied.

**Feasibility check:**
- ✅ Variation: 30 treated states, staggered over 35 years
- ✅ Data: ACS PUMS via Census API (state × year × nativity × English proficiency × earnings)
- ✅ Novelty: No modern DiD study exists
- ✅ Sample size: ~3 million ACS observations/year; immigrant subsample ~400K/year
- ✅ DiD criteria: ≥20 treated states, multiple pre-treatment periods available
- ✅ Colonial connection: Direct codification of colonial linguistic dominance

**Mechanisms to test:**
1. *Signaling/hostility channel*: Official English laws signal anti-immigrant sentiment, reducing immigrant labor force participation or pushing immigrants into ethnic enclave employment
2. *Investment channel*: Laws increase returns to English proficiency, inducing greater investment in language skills (positive effect on long-run assimilation)
3. *Discrimination channel*: Laws provide legal cover for workplace language discrimination, widening the wage gap for low-English-proficiency workers
4. *Sorting channel*: Laws induce selective migration of immigrants away from adopting states

---

## Idea 2: The Second Emancipation? Felon Voting Rights Restoration and Community-Level Black Political Participation

**Policy:** State reforms to felon voting rights restoration. Since 1997, 26+ states have expanded voting rights for people with felony convictions — through automatic restoration upon release, removal of waiting periods, executive orders, or constitutional amendments. This is a direct colonial/slavery legacy: post-Civil War felon disenfranchisement laws were designed as tools of racial suppression after the 15th Amendment, targeting newly freed Black citizens through racially selective criminal codes.

**Key reforms (partial list):**
- 2000: Delaware (restoration after 5 years)
- 2001: Connecticut (restoration on probation)
- 2005: Iowa (automatic restoration, reversed 2011)
- 2006: Rhode Island (ballot referendum)
- 2007: Florida (automatic for non-violent, reversed 2011), Maryland (automatic)
- 2009: Washington (automatic after sentence)
- 2013: Virginia (executive order for non-violent)
- 2018: Florida (Amendment 4, 1.4M eligible)
- 2019: Nevada (AB 431), Kentucky (executive order)
- 2020: Iowa (executive order), California (ACA-6, parolees)
- 2021: Connecticut, New York, Washington (expanded to parolees)
- 2023: Michigan (automatic registration on release)

**Outcome:** Voter registration and turnout rates among Black non-felons — measured via CPS Voting and Registration Supplement (biennial, November of even years, 1976–2024). Variables: VOTED, VOREG, VOWHYNOT. State × race breakdown available.

**Identification:** Staggered DiD. Key innovation: we study the **community spillover** effect — does restoring felon voting rights increase political participation among Black residents who were NEVER disenfranchised? The hypothesis: mass disenfranchisement creates a "civic chill" that depresses participation in entire communities. Restoration reverses this.

**Why it's novel:** Existing literature (Meredith & Morse 2015, Shineman 2019) studies effects on ex-felons themselves. Burch (2014) provides suggestive evidence of community-level effects but uses cross-sectional variation. No study uses the modern staggered adoption of restoration laws with DiD to estimate spillover effects on non-felon Black voter participation.

**Feasibility check:**
- ✅ Variation: 26+ states, staggered 2000–2024
- ✅ Data: CPS Voting Supplement via IPUMS CPS (state × race × voting, biennial since 1976)
- ✅ Novelty: Community spillover angle is unstudied with modern DiD
- ✅ Sample size: CPS is ~60K households/month, adequate at state-year level
- ✅ DiD criteria: ≥20 treated states, 10+ pre-treatment periods
- ⚠️ Complication: Some states reversed reforms (Florida 2011, Iowa 2011), creating "treatment-reversal" dynamics
- ⚠️ Complication: Coding treatment timing is complex (executive orders vs. legislation vs. constitutional amendments)

---

## Idea 3: Linguistic Exile — Official English Laws and Immigrant Geographic Sorting

**Policy:** Same Official English laws as Idea 1 (30 states, 1981–2016).

**Outcome:** Immigrant net migration and residential concentration. Do immigrants "vote with their feet" in response to Official English laws? ACS provides state-to-state migration data (MIGSP variable: state of residence 1 year ago). Also: change in foreign-born population share, immigrant concentration in ethnic enclaves.

**Identification:** Staggered DiD. Compare immigrant in-migration and out-migration rates in states before and after Official English adoption, relative to non-adopting states. Use US-born migration as a within-state placebo.

**Why it's novel:** The "Tiebout sorting" response to symbolic legislation is theoretically interesting and empirically unstudied for language policy. If immigrants relocate in response to Official English laws, this has implications for: (a) the labor market effects estimated in Idea 1 (composition bias), and (b) the political economy of language policy (sorting undermines the policy's stated purpose).

**Feasibility check:**
- ✅ Variation: Same 30 states
- ✅ Data: ACS migration variables (MIGSP), Census population data
- ✅ Novelty: No study of immigrant sorting response to Official English
- ✅ Sample size: Large ACS samples
- ✅ DiD criteria: Same as Idea 1
- ⚠️ Challenge: Migration data only available in ACS (2005+), limiting pre-treatment data for early adopters

---

## Idea 4: The Colonial Wage Gap — Official English Laws and Within-Immigrant Inequality

**Policy:** Same Official English laws as Idea 1.

**Outcome:** Wage gap between high-English-proficiency and low-English-proficiency immigrants within adopting states. ACS provides both English proficiency (ENG: "very well", "well", "not well", "not at all") and earnings (WAGP).

**Identification:** Staggered DiD with heterogeneous treatment effects by English proficiency. The hypothesis: Official English laws may benefit immigrants who already speak English well (signaling value of English proficiency increases) while harming those who don't (discrimination, reduced access to services in other languages). This would WIDEN within-immigrant inequality — a "colonial stratification" effect where the colonial language creates hierarchy within the colonized population.

**Why it's novel:** The inequality angle within the immigrant population is theoretically compelling and connects to a deep colonial studies literature on language stratification. No empirical study examines this.

**Feasibility check:**
- ✅ All feasibility criteria from Idea 1
- ✅ ACS has both English proficiency AND earnings at the individual level
- ✅ Novel theoretical contribution linking colonial theory to modern policy evaluation
- ⚠️ Challenge: English proficiency is endogenous (may respond to law), requiring careful timing
