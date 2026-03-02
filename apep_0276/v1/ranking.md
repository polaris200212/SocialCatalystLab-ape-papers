# Research Idea Ranking

**Generated:** 2026-02-13T12:46:26.752689
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 10467

---

### Rankings

**#1: The Second Emancipation? Felon Voting Rights Restoration and Community-Level Black Political Participation**
- **Score:** 63/100
- **Strengths:** High policy relevance (active reform area) with many treated states and long pre-period coverage in CPS. The “community spillover/civic chill” mechanism is a genuinely interesting twist relative to the direct-effect literature.
- **Concerns:** As written, CPS cannot identify *non-felons*, so the main estimand (spillovers on never-disenfranchised Black residents) is not cleanly observed; results would mechanically mix direct effects on newly eligible voters with any spillovers. Treatment timing and reversals (FL, IA) plus concurrent voting-policy changes create serious confounding risk.
- **Novelty Assessment:** **Moderate.** Felon disenfranchisement/restoration is well-studied; the *spillover-on-non-felons* angle is less studied, but adjacent work exists (often suggestive/cross-sectional).
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (CPS Voting Supplement back to 1976 gives many pre elections before the late-1990s/2000s reforms).
  - **Selection into treatment:** **Marginal** (often political/endogenous; some quasi-exogenous channels like ballot initiatives or court/administrative actions, but still correlated with broader political shifts that also move turnout).
  - **Comparison group:** **Marginal** (never-treated states plausibly differ systematically in criminal justice and voting regimes; needs careful covariate/event-study balance checks).
  - **Treatment clusters:** **Strong** (≈26+ states with expansions; enough clusters for inference).
  - **Concurrent policies:** **Marginal → Weak** (many contemporaneous election-law changes—ID laws, early voting rules, registration reforms, and in FL the post–Amendment 4 fines/fees regime—can move turnout in the same elections).
  - **Outcome-Policy Alignment:** **Weak (potential dealbreaker as written).** CPS does not measure felony history, so “Black non-felons” is not observed; the measured turnout among Black citizens will combine (i) direct effects on restored voters and (ii) any spillovers.  
    *Mitigation that could upgrade this:* redefine the estimand to “effect on overall Black citizen turnout/registration,” **or** design a DDD that isolates spillovers using low-felony-risk subgroups (e.g., Black women 50+, high-education) as the outcome population and treat prime-age men as the “more directly affected” group.
  - **Data-Outcome Timing:** **Marginal** (outcome is November of even years; reforms happen on varied dates and may miss registration deadlines—must code “first exposed election” rather than calendar year).
  - **Outcome Dilution:** **Marginal** (directly affected population share is often <10% of Black adult citizens in many states, though larger in some; true *spillovers* may be smaller still, so power is a concern with biennial outcomes).
- **Recommendation:** **CONSIDER (conditional on: redefining the estimand or obtaining/designing data/strategy that separates spillovers from direct effects; coding treatment as “first eligible election”; explicit handling of reversals and concurrent voting-law changes).**

---

**#2: The Tongue of Empire — Official English Laws and Immigrant Economic Assimilation**
- **Score:** 48/100
- **Strengths:** Potentially important question (symbolic/exclusionary language policy) with a large microdata source and a natural triple-difference structure (foreign-born vs US-born within state).
- **Concerns:** The core feasibility/ID problem is that most adoptions occur **before** the annual ACS era, so the “staggered adoption” design using ACS 2005–2023 effectively has only a handful of post-2005 adoptions—too few treated clusters and limited ability to test pre-trends. Adoption is plausibly driven by anti-immigrant sentiment and immigration shocks that also differentially affect immigrant outcomes, so DDD may not save identification.
- **Novelty Assessment:** **Moderate.** There is literature on language policy and immigrant outcomes and some work on historical English-only laws; a comprehensive modern staggered-adoption design is less common, but the policy is not untouched.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak.** With ACS annual data starting 2005, most treated states have no observable pre-period; decennial censuses provide only a few pre points and are not adequate for credible pre-trend testing.
  - **Selection into treatment:** **Weak.** Official English adoption is closely tied to immigration salience and political backlash—factors likely correlated with immigrant wages/employment trends; US-born within-state controls don’t remove immigrant-specific shocks.
  - **Comparison group:** **Marginal.** Never-treated states differ (coastal vs interior, immigrant composition, industrial mix); could be partially addressed with region×year and state trends, but that doesn’t fix endogenous adoption.
  - **Treatment clusters:** **Weak (in the usable ACS window).** Post-2005 adoptions are ~5–6 states (e.g., AZ 2006, ID/KS 2007, OK 2010, WV 2016), making inference and event studies fragile.
  - **Concurrent policies:** **Marginal → Weak.** Late-2000s/2010s overlap with immigration enforcement expansions (e.g., E-Verify mandates, 287(g), local enforcement), which directly affect immigrant labor outcomes.
  - **Outcome-Policy Alignment:** **Marginal.** Earnings/employment could respond via discrimination, signaling, or sorting, but many Official English laws are symbolic/limited in workplace coverage, so the mapping from statute to labor market outcomes is indirect.
  - **Data-Outcome Timing:** **Marginal.** ACS earnings refer to the *prior 12 months* while interview timing spans the year; effective dates vary, generating partial exposure/attenuation unless carefully aligned.
  - **Outcome Dilution:** **Strong.** If you estimate within-immigrant outcomes (rather than state means), the “affected share” is not tiny; dilution is not the main issue here.
- **Recommendation:** **SKIP (unless redesigned around a dataset with long annual pre-periods for wages/employment—e.g., CPS ASEC for outcomes without language—and/or a different identification strategy).**

---

**#3: The Colonial Wage Gap — Official English Laws and Within-Immigrant Inequality**
- **Score:** 44/100
- **Strengths:** Interesting distributional/inequality framing that could be more informative than average effects; ACS can measure both wages and self-reported English proficiency at the individual level.
- **Concerns:** Same “most treatment happens pre-ACS” problem as Idea 1 (few usable treated clusters). Additionally, English proficiency is likely endogenous to the law; defining groups by post-treatment proficiency creates composition/selection problems that can mechanically change wage gaps even absent true distributional effects.
- **Novelty Assessment:** **Moderate-to-high (question), but derivative (design).** The specific within-immigrant inequality angle is less studied; however, it inherits all the core design problems of Idea 1.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (for the same reason as Idea 1).
  - **Selection into treatment:** **Weak** (same political endogeneity; immigrant-specific shocks likely).
  - **Comparison group:** **Marginal** (similar concerns as Idea 1).
  - **Treatment clusters:** **Weak** (few post-2005 adoptions).
  - **Concurrent policies:** **Marginal → Weak** (overlaps with immigration enforcement and service-access changes affecting low-English groups).
  - **Outcome-Policy Alignment:** **Marginal.** A wage gap by proficiency is conceptually tied to mechanisms (returns to English, discrimination), but only if proficiency groups are stable and meaningfully connected to the policy’s operative margins.
  - **Data-Outcome Timing:** **Weak.** ENG is measured at interview; wage is prior-12-months—if the law affects proficiency or reporting, “gap” comparisons can mix pre/post exposure within the wage window.
  - **Outcome Dilution:** **Marginal.** Low-English-proficiency immigrants are often a minority of immigrants; detectable effects on the gap may be modest and sensitive to how groups are defined.
- **Recommendation:** **SKIP (unless you can fix the proficiency endogeneity/composition issue—e.g., use predetermined proxies like age-at-arrival cohorts, baseline language by origin group, or panel/linked data—and solve the treated-cluster problem).**

---

**#4: Linguistic Exile — Official English Laws and Immigrant Geographic Sorting**
- **Score:** 38/100
- **Strengths:** Sorting is a first-order mechanism that could explain (or bias) labor-market estimates; ACS migration questions allow direct measurement of recent moves.
- **Concerns:** The migration outcome is only available in the annual ACS era, but most Official English laws were adopted decades earlier—so you largely cannot observe pre-trends or pre-treatment migration for treated states. Restricting to late adopters leaves too few treated clusters, and migration is highly sensitive to concurrent economic shocks and immigration enforcement policies.
- **Novelty Assessment:** **High as posed**, but largely because the design is hard to execute credibly with available data.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak.** For most treated states, treatment predates the ACS migration measure; no credible pre-period exists.
  - **Selection into treatment:** **Weak.** Adoption coincides with immigration salience; those same forces plausibly drive migration flows.
  - **Comparison group:** **Marginal.** Never-treated states differ structurally; migration flows are especially heterogeneous across regions.
  - **Treatment clusters:** **Weak.** Only a small number of adoptions occur after 2005.
  - **Concurrent policies:** **Weak.** Immigration enforcement and labor-demand shocks directly move immigrant migration at the same time.
  - **Outcome-Policy Alignment:** **Strong (conceptually).** If the policy changes perceived hostility or access to services, migration is a direct margin of response.
  - **Data-Outcome Timing:** **Marginal.** ACS migration is “residence 1 year ago,” so exposure timing can be aligned in principle, but only if treatment dates are handled precisely; partial exposure is common.
  - **Outcome Dilution:** **Strong.** You can focus on immigrants (the affected group) and on recent movers; dilution is not the key issue.
- **Recommendation:** **SKIP (unless you find an alternative long-run migration dataset by nativity—e.g., administrative/IRS-style flows with nativity, which is unlikely—or a different source/setting).**

---

### Summary

Only **Idea 2** looks plausibly viable on identification/data grounds *after* a redesign to address the key outcome mismatch (spillovers on “non-felons” are not observed in CPS). The three Official English proposals are conceptually interesting but run into a common, severe DiD problem: **most policy adoptions occur before the annual ACS window**, leaving **too few treated clusters with observable pre-periods**, plus serious endogenous adoption concerns. If you pursue anything first, pursue **Idea 2 with a tightened estimand and election-timing treatment coding**.