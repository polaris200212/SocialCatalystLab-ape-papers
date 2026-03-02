# Research Ideas

## Idea 1: The First Retirement Age — Civil War Pensions and Elderly Labor Supply at the Age-62 Threshold

**Policy:** The Service and Age Pension Act of 1907 created a sharp statutory threshold at age 62 for automatic Union veteran pension eligibility. Before this, veterans needed to prove war-related disability. After, any veteran who had served 90+ days and reached 62 was automatically eligible for $12/month (~30% of a laborer's annual income). Additional discontinuities at 70 ($15/month) and 75 ($20/month).

**Outcome:** IPUMS 1910 full-count census. Variables: LABFORCE (labor force participation), OCC1950 (occupation), OWNERSHP (property ownership), RELATE (living arrangements — independent vs. with children vs. institution), VETCIVWR (Civil War veteran identifier — Union Army/Navy vs. Confederate).

**Identification:** Sharp RDD at age 62. Running variable = age. Treatment = automatic pension eligibility. The 1910 census was enumerated 3 years after the 1907 Act, providing a clean cross-section. Confederate veterans provide a natural **placebo test** — they face the same aging process but did NOT receive federal pensions at 62 (only state pensions with different rules). Multiple thresholds (62, 70, 75) enable multi-cutoff robustness.

**Why it's novel:** Despite being the largest social program in American history before the New Deal (40% of the federal budget by 1900) and the direct prototype for Social Security, NO published paper applies an RDD to the age-62 threshold. The existing literature (Costa 1998, Eli 2015, Salisbury 2017) uses OLS, matching, and IV — never the sharp statutory cutoff. This is the paper that should have been written 20 years ago.

**Why economists never wrote it:** (1) Civil War pensions are "economic history," not mainstream labor — falls between fields. (2) The age-RDD concern from the modern literature (Mastrobuoni 2009 warns about age manipulation) doesn't apply here because age 62 had NO other policy significance in 1910. (3) The relevant data variable (VETCIVWR) is only in the 1910 census and was historically coded with errors until IPUMS corrected it.

**Feasibility check:** Confirmed. IPUMS 1910 full-count has ~150,000+ Union veterans. The VETCIVWR variable identifies Union vs. Confederate veterans. Age is the running variable with a sharp cutoff at 62. Pension amounts by age bracket verified via National Archives sources. Confederate placebo available. Multiple outcome variables measurable. Sample size sufficient for RDD even with narrow bandwidth. 16GB RAM feasible using targeted IPUMS extract (selected variables only).

---

## Idea 2: Workers' Compensation and the Moral Hazard of Safety — Occupational Sorting After State Workers' Comp Laws (1911-1948)

**Policy:** All 48 states adopted workers' compensation laws between 1911 (Wisconsin) and 1948 (Mississippi), in staggered fashion. Before WC, workers bore the full cost of workplace injuries. After, employers were strictly liable.

**Outcome:** IPUMS 1900-1940 censuses. OCC1950 (occupation), IND1950 (industry), LABFORCE, CLASSWKR (class of worker).

**Identification:** Staggered DiD across states and census years. Callaway-Sant'Anna estimator for heterogeneous treatment effects.

**Why it's novel:** The WC literature focuses almost entirely on insurance and injury outcomes. The occupational SORTING question — did WC pull workers INTO dangerous industries (moral hazard: risk is now insured) or OUT (employers face costs, invest in safety) — has never been tested with historical microdata.

**Feasibility check:** 48 treated states (clean DiD threshold). 5 census cross-sections. Occupation data available in all censuses. Large sample sizes. Method is DiD, not RDD — would require changing the randomly assigned method.

---

## Idea 3: The Age of Innocence — State Age-of-Consent Reform and Female Human Capital Formation (1880s-1920s)

**Policy:** Between 1880 and 1920, states raised the legal age of consent from 10-12 to 16-18. This was driven by social purity movements and the "age of consent campaign." Staggered adoption across 30+ states.

**Outcome:** IPUMS 1880-1930. SCHOOL (school attendance), AGE_MARRIED (available 1930), CHBORN (children ever born, 1900-1940), MARST (marital status).

**Identification:** RDD at the state-specific age-of-consent threshold. Running variable = age of young women. Compare outcomes for women just above vs. below the consent age across states.

**Why it's novel:** Almost completely unstudied. The age-of-consent literature is entirely in legal history and gender studies, never economics. Could study whether higher consent ages delayed marriage and increased female schooling.

**Feasibility check:** 30+ states changed laws, but exact dates require historical legal research. The RDD is at the age threshold, which varies by state. Outcome data available in IPUMS. Sample sizes large.

---

## Idea 4: The Pension Before Pensions — State Old-Age Pension Laws and Elderly Independence (1923-1935)

**Policy:** 28 states adopted old-age pension programs between 1923 (Montana, Nevada, Pennsylvania) and 1935 (before Social Security). These were means-tested, typically $1/day for persons 65-70+ without other support.

**Outcome:** IPUMS 1920-1940. LABFORCE, RELATE (living with children vs. independent household), OWNERSHP, INCWAGE (1940 only).

**Identification:** DiD exploiting staggered state adoption. The 1920 census provides pre-treatment baseline; 1930 and 1940 show post-adoption outcomes. Never-adopting states serve as control.

**Why it's novel:** Everyone studies Social Security (1935+). Nobody studies the STATE programs that preceded it — the very experiments that convinced Congress to pass Social Security. This is the laboratory of democracy, unstudied.

**Feasibility check:** 28 treated states, well-documented adoption dates. DiD method (not RDD). Outcome variables available. But method assignment was RDD.

---

## Idea 5: City Limits — Population Thresholds and the Rise of Municipal Public Health (1900-1920)

**Policy:** Many states mandated that cities above certain population thresholds (commonly 2,500, 5,000, or 10,000) establish health departments, building codes, or sanitation infrastructure. These were Progressive Era municipal reforms.

**Outcome:** IPUMS 1900-1920 census data at the city level. Migration (people moving to/from cities), school attendance, mortality (from vital statistics, not IPUMS), property ownership.

**Identification:** RDD at the population threshold. Running variable = city population. Treatment = mandatory public health infrastructure. Compare residents of cities just above vs. below the threshold.

**Why it's novel:** The public health revolution of 1900-1920 is well-studied at the aggregate level (Cutler & Miller 2005) but the POPULATION THRESHOLD mechanism — which specific cities were forced to invest — has never been exploited as an RDD.

**Feasibility check:** Need to identify specific state laws with population thresholds. IPUMS has city of residence. Population thresholds create a sharp cutoff. But need to verify which states had such laws and their exact thresholds — this requires historical legal research that may be difficult.

---

## Ranking Assessment

**Idea 1 (Civil War Pensions)** is clearly dominant:
- Clean, sharp statutory threshold (age 62)
- Built-in placebo (Confederate veterans)
- Large sample (150K+ Union veterans in full-count 1910)
- Multiple cutoffs (62, 70, 75) for robustness
- Direct predecessor to Social Security — obvious policy relevance
- Zero existing RDD papers on this threshold
- RDD method matches the random assignment
- Feasible with IPUMS API and 16GB RAM

Ideas 2 and 4 are strong but require DiD (not RDD). Idea 3 is RDD-compatible but requires more historical legal research. Idea 5 is creative but data verification is challenging.
