# Research Ideas

## Idea 1: Compensating Danger: Workers' Compensation Laws and Industrial Safety in the Progressive Era — Evidence from Historical Newspaper Reports and Census Microdata

**Policy:** State workers' compensation laws, adopted in staggered fashion across 42 US states between 1911 and 1948 (with the bulk adopting 1911–1920). These laws replaced the common-law negligence system with a no-fault insurance system, shifting the financial burden of workplace injuries from workers to employers.

**Outcome:**
- **Primary (Novel):** State-year panel of workplace accident newspaper coverage intensity from the Library of Congress Chronicling America digital newspaper archive (135,000+ historical newspaper pages mentioning industrial accidents, 1900–1920). This text-as-data measure captures the public information environment around workplace safety.
- **Secondary (Novel for this policy):** Individual-level occupational sorting from IPUMS 1910 and 1920 census microdata (1% samples). Measure whether workers' comp shifted workers between dangerous and safe occupations, using OCC1950 occupation codes and OCCSCORE occupational income scores.

**Identification:** Doubly Robust (AIPW) estimation within a Callaway & Sant'Anna (2021) staggered treatment framework. Workers' comp adoption was not random — more industrial, urban, and politically progressive states adopted earlier (Fishback & Kantor 1998). The DR estimator combines:
1. Propensity score model for adoption timing based on pre-treatment state characteristics (manufacturing share, urbanization, population, foreign-born share)
2. Outcome regression for accident coverage/occupational composition conditional on covariates
3. The AIPW estimator is consistent if either model is correctly specified

**Why it's novel:**
- First paper to use digitized historical newspaper text as a quantitative outcome measure for Progressive Era labor policy evaluation
- First individual-level analysis of workers' comp effects on occupational sorting (prior work uses aggregate industry data)
- Combines two novel data sources (Chronicling America + IPUMS microdata) in a single paper
- DR methodology addresses the fundamental selection problem that DiD alone cannot solve with decennial census data

**Feasibility check:**
- ✅ Chronicling America API tested: 135,329 newspaper pages for "industrial accident" (1910–1920) across 18+ states with state-level filtering
- ✅ IPUMS API extract submitted (extract #149): 1910 and 1920 census 1% samples with occupation, industry, and demographic variables
- ✅ Workers' comp adoption dates well-documented in Fishback & Kantor (1998, 2000)
- ✅ DR implementation via R `did` package with `est_method = "dr"` (AIPW estimator)
- ✅ 42 states with staggered adoption over 10 years provides excellent treatment variation

**Counter-intuitive potential:** Fishback found that workers' comp INCREASED fatal accident rates in coal mining (moral hazard). Newspaper evidence could either confirm this finding more broadly or reveal that the aggregate result masks heterogeneous effects across industries.


## Idea 2: The Ink Before the Law: Did Media Coverage of the Triangle Fire Accelerate Workers' Compensation Adoption?

**Policy:** Same staggered workers' comp adoption (1911–1920), but studied from the policy diffusion angle. The Triangle Shirtwaist Factory fire (March 25, 1911, NYC, 146 deaths) was the most widely covered industrial disaster of the era.

**Outcome:** Time to workers' comp adoption (hazard model) as a function of newspaper coverage intensity of the Triangle Fire.

**Identification:** DR with state characteristics (industrialization, political composition, union density). The Triangle Fire was exogenous (unexpected, localized to NYC), but its newspaper coverage varied across states based on newspaper network connections, geographic proximity, and immigrant community ties.

**Why it's novel:** Tests the information → policy channel using novel newspaper data. If media coverage accelerated adoption, this has implications for how public attention shapes regulatory reform.

**Feasibility check:**
- ✅ Chronicling America searchable for "Triangle fire" + "shirtwaist" by state-year
- ✅ Workers' comp adoption dates available from Fishback & Kantor
- ⚠️ Only 42 states with adoption events → limited statistical power for survival analysis
- ⚠️ Endogeneity concern: states with more safety concern may both cover the fire more AND adopt sooner


## Idea 3: From Schoolhouse to Factory: State Child Labor Laws and Human Capital Accumulation, 1880–1920

**Policy:** State child labor laws restricting employment of children under 14–16, adopted in staggered fashion from the 1880s through the 1910s. Laws varied in minimum age, maximum hours, and enforcement provisions.

**Outcome:** School attendance rates and literacy from IPUMS census microdata (children aged 10–15 in 1880, 1900, 1910, 1920 censuses). Occupational sorting of young adults (16–25) into skilled vs. unskilled occupations.

**Identification:** DR comparing children in states with child labor laws vs. states without, controlling for individual demographics and state characteristics. The unconfoundedness assumption is that, conditional on observables (state industrialization, urbanization, family structure), exposure to child labor laws is as-good-as-random.

**Why it's novel:** While child labor laws are well-studied (Moehling 1999, Lleras-Muney 2005), no one has applied modern DR methods with individual-level census microdata across multiple census waves. Previous studies used aggregate data or focused on specific outcomes.

**Feasibility check:**
- ✅ IPUMS data available for 1880–1920 census years
- ✅ Child labor law adoption dates documented in historical literature
- ⚠️ Very well-studied topic — novelty comes primarily from methodology and data, not policy
- ⚠️ Enforcement varied dramatically; laws on the books may not reflect actual conditions


## Idea 4: Mothers' Pensions and Children's Economic Mobility: Evidence from IPUMS Linked Census Data, 1920–1940

**Policy:** State mothers' pension laws (precursors to AFDC), adopted 1911–1935 across 46 states. These provided cash assistance to widowed mothers with children, representing America's first large-scale welfare program.

**Outcome:** Children's 1940 census outcomes (wage income, occupational status, educational attainment) for cohorts exposed to mothers' pensions during childhood, identified via IPUMS 1920–1940 data.

**Identification:** DR comparing adults in 1940 who grew up in states that adopted mothers' pensions early (during their childhood) vs. late/never. Covariates include birth state characteristics, individual demographics, and family structure.

**Why it's novel:** Aizer et al. (2016) studied mothers' pensions using administrative records from a single state (Ohio). A national-level analysis using IPUMS census data would provide broader external validity and allow heterogeneity analysis across states.

**Feasibility check:**
- ✅ IPUMS 1940 census has income data (first year available)
- ✅ Mothers' pension adoption dates documented in the literature
- ⚠️ Requires IPUMS 1940 extract (not yet submitted)
- ⚠️ Cannot directly observe which families received pensions — must use state-level treatment exposure
- ⚠️ 1920→1940 is a 20-year gap; intent-to-treat effects may be attenuated
