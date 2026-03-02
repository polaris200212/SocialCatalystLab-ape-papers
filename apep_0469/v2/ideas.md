# Research Ideas

## Idea 1: Missing Men, Rising Women — WWII Selective Mortality and the Individual Origins of Gender Convergence

**Policy:** WWII military mobilization (1941-1945) created the largest exogenous labor market shock in American history. Cross-county variation in mobilization intensity provides quasi-random variation in both male labor supply reduction and female labor demand.

**Outcome:** Individual-level occupational upgrading (SEI/OCCSCORE), labor force participation, marital status, household headship, geographic mobility — all measured for the SAME individuals across 1930, 1940, and 1950 using IPUMS MLP linked census data.

**Identification:** DiD + IV hybrid. Within-person difference-in-differences using the individual panel structure (same woman observed in 1940 and 1950) with county-level mobilization intensity as continuous treatment. Instrumented by pre-war (1940) county industrial composition — specifically agricultural employment share (agricultural counties sent more men, had fewer essential-worker deferments). Lee (2009) bounds for selective male mortality. CenSoc WWII Army Enlistment data (9M records linked to 1940 Census) provides county-level mobilization rates.

**Why it's novel:** First paper to use individual-level linked panel data across multiple census waves to study WWII's impact on gender. Acemoglu, Autor, and Lyle (2004) used state-level cross-sections (48 states). Goldin (1991) used a small retrospective survey (Palmer Survey, urban women only). Goldin and Olivetti (2013) used repeated cross-sections. Nobody has tracked millions of individual women from childhood (1930) through the war (1940→1950) using actual panel data. The MLP's 175 million linked individuals and HISTID make this possible for the first time. Second innovation: we make male selective mortality the central MECHANISM rather than a confound, decomposing convergence into female advancement vs male removal.

**Feasibility check:** Confirmed. IPUMS MLP Version 2.0 (2025) provides 1930-1940-1950 linked censuses. CenSoc WWII Enlistment data freely downloadable from Harvard Dataverse (9M records, county FIPS). Jaworski (2017) replication data on OpenICPSR provides county-level war production. IPUMS_API_KEY configured. 96GB RAM handles the dataset.


## Idea 2: Born Under Rosie — Maternal Wartime Employment and the Intergenerational Transmission of Gender Norms

**Policy:** Same WWII mobilization shock, but focused on the CHILDREN of women who entered the labor force during the war. Did daughters of wartime workers develop different labor force attachment than daughters of non-workers?

**Outcome:** Children observed in 1950 Census (ages 5-15), tracked forward via MLP. Measure: mother's labor force status in 1950 conditional on child presence, father's veteran status, household structure.

**Identification:** Exploit within-family variation: same mother, children born before vs during the war. Cross-county mobilization as instrument for mother's wartime work.

**Why it's novel:** Tests intergenerational transmission of gender norms through a natural experiment. Fernández, Fogli, and Olivetti (2004) showed sons of working mothers marry working women, but used cross-sectional data. MLP panel allows actual mother-child links across censuses.

**Feasibility check:** Confirmed in principle. Challenge: children in 1950 are too young to observe adult outcomes. Would need 1960+ census data, which MLP does not cover (stops at 1950). This limits the intergenerational story to early-life outcomes only. WEAKER than Idea 1.


## Idea 3: The Marriage Market After Armageddon — Sex Ratio Shocks and Assortative Matching

**Policy:** WWII created massive county-level sex ratio imbalances through differential male mobilization and mortality. ~400,000 American men killed, millions more displaced.

**Outcome:** Individual marriage transitions (1940 single → 1950 married, or reverse), spouse quality (occupation score of partner), age gap, interracial marriage, out-of-wedlock births.

**Identification:** County sex ratio changes (1940→1950) instrumented by pre-war industrial composition predicting mobilization. Individual panel tracks same people's marriage market outcomes.

**Why it's novel:** Extends Abramitzky et al. (2011) on WWI France and Brainerd (2017) on WWII Russia to the US with individual-level linked data. Can observe the SAME woman's marital status change, not just aggregate rates.

**Feasibility check:** Confirmed. MLP links individuals across 1940 and 1950. Can construct individual marriage transitions. County-level sex ratios from Census. CenSoc provides mobilization rates. Challenge: WWII US mortality (~400K) was much smaller relative to population than WWI France or WWII Russia, so sex ratio effects may be modest. Could combine with Idea 1 as a mechanism chapter.


## Idea 4: The Great Reshuffling — WWII, Internal Migration, and the Geographic Origins of Gender Convergence

**Policy:** WWII triggered massive internal migration — the Great Migration for Black Americans, rural-to-urban for defense industry workers, women moving to shipyard/aircraft cities (Portland, Los Angeles, Detroit).

**Outcome:** Geographic mobility (county of residence in 1940 vs 1950), occupational change conditional on mobility, race-specific migration patterns, destination choice.

**Identification:** Defense industry placement (quasi-random — driven by access to ports, rail, raw materials) creates exogenous pull for labor. Compare movers vs stayers using MLP individual links. Triple-diff: movers × women × high-defense destinations.

**Why it's novel:** First individual-level study of WWII migration using linked census panel. Previous work (Collins and Wanamaker, 2014 on Great Migration; Boustan 2010) used repeated cross-sections or aggregate data. MLP tracks the same individuals before and after moving.

**Feasibility check:** Confirmed. MLP provides STATEFIP and COUNTY in both 1940 and 1950, allowing individual mobility measurement. CenSoc enlistment data includes county of residence. Challenge: migration is endogenous (who chooses to move?). Instrument validity requires defense industry placement to be quasi-random conditional on controls. Could be a chapter within Idea 1.


## Idea 5: The Selective Survivor — Mortality Selection, the Missing Fifth, and What Aggregate Gender Gaps Actually Measure

**Policy:** Same WWII mobilization shock. Focus on the MEASUREMENT PROBLEM: comparing 1940 and 1950 aggregate statistics conflates genuine within-person changes with compositional shifts from selective male mortality.

**Outcome:** Decomposition of the 1940-1950 gender gap change into: (A) within-person female advancement, (B) within-person male changes for survivors, (C) composition effects from male attrition. Individual-level link rates as direct measure of selection.

**Identification:** Use the panel structure itself to decompose. Linked individuals provide within-person changes. Difference between linked (survivors) and full cross-sectional samples reveals the composition bias. Lee bounds quantify the bias range.

**Why it's novel:** First formal decomposition of how selective mortality biases measured gender convergence. Methodological contribution: demonstrates that aggregate cross-sectional comparisons (the basis of ALL previous studies) systematically overstate female-driven convergence and understate the role of male removal.

**Feasibility check:** Confirmed. MLP link rates by county, cohort, and 1940 characteristics directly measure selection. Comparing linked vs unlinked subsamples reveals selection patterns. This is primarily a measurement/decomposition exercise with strong methodological appeal. Could be the central contribution of Idea 1.
