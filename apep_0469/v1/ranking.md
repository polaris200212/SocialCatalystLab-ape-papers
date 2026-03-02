# Research Idea Ranking

**Generated:** 2026-02-27T02:18:16.237447
**Models:** GPT-5.2, Gemini 3.1 Pro, Grok 4.1 Fast
**Reasoning:** high

## Comparison Table

| Idea | GPT-5.2 | Gemini 3.1 Pro | Grok 4.1 Fast |
|------|------|------|------|
| Missing Men, Rising Women — WWII Selecti... | PURSUE (78) | — | PURSUE (82) |
| The Selective Survivor — Mortality Selec... | PURSUE (72) | — | PURSUE (75) |
| The Marriage Market After Armageddon — S... | CONSIDER (60) | — | CONSIDER (68) |
| The Great Reshuffling — WWII, Internal M... | CONSIDER (55) | — | CONSIDER (60) |
| Born Under Rosie — Maternal Wartime Empl... | SKIP (35) | — | SKIP (52) |
| Idea 1: Missing Men, Rising Women — WWII... | — | PURSUE (75) | — |
| Idea 4: The Great Reshuffling — WWII, In... | — | CONSIDER (62) | — |
| Idea 5: The Selective Survivor — Mortali... | — | SKIP (45) | — |
| Idea 3: The Marriage Market After Armage... | — | SKIP (35) | — |
| Idea 2: Born Under Rosie — Maternal Wart... | — | SKIP (15) | — |

---

## GPT-5.2

**Tokens:** 6522

### Rankings

**#1: Missing Men, Rising Women — WWII Selective Mortality and the Individual Origins of Gender Convergence**
- **Score: 78/100**
- **Strengths:** The linked-person panel (1930–40–50) is a genuinely new measurement object for this classic question, and it enables a compelling “within-person change vs composition” architecture. Centering selective male mortality as a mechanism (not a nuisance) is a potentially field-shifting reframing if executed carefully.
- **Concerns:** The proposed IV (1940 agriculture share → mobilization) is likely to violate exclusion because agriculture predicts many concurrent wartime changes (female labor demand, migration, local wages, war production siting) and long-run structural change. County-level treatment also invites differential-trend concerns (especially with only one clean pre-period for many outcomes).
- **Novelty Assessment:** **Medium-High.** WWII and women’s work is heavily studied, but **not** with this scale of linked individual histories plus explicit mortality-selection mechanics; that combination is meaningfully new.
- **Top-Journal Potential:** **Medium-High.** A top-5/AEJ:EP could bite if the paper is framed as resolving a major empirical “gender convergence” fact by separating true within-person advancement from compositional attrition, and if it delivers a crisp causal chain (mobilization → female labor/occupation shifts + male attrition → measured convergence + marriage/household structure).
- **Identification Concerns:** Main threats are (i) **exclusion** for the agriculture-share instrument; (ii) **non-parallel trends** at the county level; (iii) treatment bundling (mobilization vs war production vs migration). The design will need strong pre-trend/placebo work (1930–40), alternative instruments/first stages, and careful separation of mobilization from local demand shocks.
- **Recommendation:** **PURSUE (conditional on: a defensible instrument/first stage not mechanically tied to local labor-demand trends; explicit pre-trend diagnostics using 1930–40; and a design that separates mobilization from war-production intensity/migration shocks).**

---

**#2: The Selective Survivor — Mortality Selection, the Missing Fifth, and What Aggregate Gender Gaps Actually Measure**
- **Score: 72/100**
- **Strengths:** This is the cleanest use of the linked data’s comparative advantage: it directly attacks a first-order measurement problem (cross-sectional convergence vs within-person change) that could reinterpret a large literature. If the decomposition is sharp and surprising, it can be publishable even without a flashy policy “ATE.”
- **Concerns:** Linkage is not random (name changes for women, migration, enumerator error), so “unlinked = dead/attrited” is wrong without a careful selection model; you risk swapping “mortality bias” for “linkage bias.” Also, top journals may view it as a methods note unless it demonstrably overturns canonical magnitudes and narratives.
- **Novelty Assessment:** **High.** Selection/attrition is discussed in this literature, but a formal, large-scale linked-data decomposition that quantifies how much of “gender convergence” is composition vs within-person change is plausibly new.
- **Top-Journal Potential:** **Medium.** Strong potential in a top field journal (AEJ:EP) and some chance at top-5 if the headline is genuinely literature-revising (e.g., “most convergence is compositional” or “standard estimates are biased in sign/magnitude”) and the paper becomes the reference for how to do WWII-era linked inference.
- **Identification Concerns:** Not “identification” in the causal sense; the core credibility issue is **mapping link failure to mortality/attrition**. You’ll need validation (e.g., CenSoc enlistment + death proxies, SSA/Numident-style benchmarks if available, or bounding exercises that explicitly incorporate link-probability heterogeneity).
- **Recommendation:** **PURSUE (conditional on: an explicit linkage-selection framework—IPW/bounds/validation—and a clear claim that materially changes interpretation of existing WWII gender-convergence evidence).**

---

**#3: The Marriage Market After Armageddon — Sex Ratio Shocks and Assortative Matching**
- **Score: 60/100**
- **Strengths:** The marriage-market question is inherently interesting, and linked micro data lets you study transitions and matching (not just aggregate marriage rates), which is a real upgrade. The mechanism can complement Idea 1 (mobilization → sex ratios → marriage/household responses → female labor supply).
- **Concerns:** This topic is **well-trodden** in many settings; the U.S. WWII sex-ratio shock is smaller than canonical cases, so effect sizes may be modest and hard to separate from migration and local economic shocks. County is also a noisy “marriage market,” and migration endogeneity can mechanically change sex ratios and matching.
- **Novelty Assessment:** **Medium-Low.** Sex ratios and marriage/matching have a huge literature; the “novel” piece is mainly the linked-person implementation for the U.S. WWII case.
- **Top-Journal Potential:** **Low-Medium.** More likely a solid field-journal paper than top-5 unless you uncover a genuinely counterintuitive equilibrium response (e.g., changes in assortative matching that worsen women’s bargaining power despite higher employment) and tightly nail the mechanism with strong first-stage evidence.
- **Identification Concerns:** The IV based on industrial composition inherits the same exclusion problems as in Idea 1, plus **migration-driven endogeneity** in sex ratios. A credible strategy likely requires focusing on non-movers, using predicted mobilization by cohort/age structure, and carefully separating “missing men” from “men moved.”
- **Recommendation:** **CONSIDER (best as a mechanism chapter bundled with Idea 1, rather than a standalone flagship).**

---

**#4: The Great Reshuffling — WWII, Internal Migration, and the Geographic Origins of Gender Convergence**
- **Score: 55/100**
- **Strengths:** WWII migration is a first-order economic event, and linked data is valuable for distinguishing who moved, where, and how outcomes changed for the same individuals. Race × gender heterogeneity could be genuinely informative.
- **Concerns:** Migration is a classic selection problem; “defense industry placement is quasi-random” is a hard sell because plant siting is tied to pre-war infrastructure, political economy, and growth potential—exactly what predicts post-war trajectories. A triple-diff can still be fragile if destination trends differ mechanically.
- **Novelty Assessment:** **Medium.** WWII-induced migration has been studied, and defense-contract/plant-shock designs exist; the linked-person angle is helpful but not obviously paradigm-shifting on its own.
- **Top-Journal Potential:** **Low-Medium.** Could place well in a field journal if the design is unusually credible and the paper delivers a clear mechanism chain (defense shocks → migration → occupation upgrading/household structure), but it’s harder to make watertight than the selection/decomposition angle in Ideas 1/5.
- **Identification Concerns:** Key threats are (i) **endogenous mover selection**; (ii) **non-random destination growth paths**; (iii) treatment conflation (war production, housing constraints, unions, segregation regimes). Without a very strong instrument and placebo tests, this will read as “good descriptive panel work” rather than clean causal inference.
- **Recommendation:** **CONSIDER (conditional on: a highly defensible exogenous shock measure—e.g., plausibly predetermined contract allocation components—and a design that addresses mover selection head-on).**

---

**#5: Born Under Rosie — Maternal Wartime Employment and the Intergenerational Transmission of Gender Norms**
- **Score: 35/100**
- **Strengths:** Intergenerational transmission of gender norms is an important question, and WWII is a plausible shock with strong salience. In principle, mother-child links are a real asset.
- **Concerns:** With MLP stopping at 1950, you cannot observe the children’s adult labor supply/marriage/fertility outcomes—the outcomes that would actually identify “norm transmission” rather than short-run household circumstances. The proposed within-family timing (siblings pre/during war) also risks severe confounding from cohort effects and post-war family re-optimization.
- **Novelty Assessment:** **Medium.** The broad idea is well studied; what would be novel is credible long-run linked outcomes, which this data constraint prevents.
- **Top-Journal Potential:** **Low.** Without adult outcomes (or a compelling early-life proxy tightly linked to later gender norms), it will be hard to clear the “so what” bar at top journals.
- **Identification Concerns:** Even with an instrument for maternal work, you face (i) **outcome mismatch** (childhood measures ≠ adult norms); (ii) **cohort/time confounding** within families; (iii) measurement error in “wartime employment” if proxied by 1950 status.
- **Recommendation:** **SKIP (unless you can link to later-life outcomes via another source beyond 1950, or redefine the question around clearly policy-relevant short-run child outcomes with strong interpretation).**

---

### Summary

This is a strong batch because it leverages a genuinely new data capability (mass-scale linked census panels) on a historically important shock. The most promising path is to lead with **Idea 1** but architect it around the **selection/decomposition core of Idea 5**, using the causal estimates as a complement rather than over-claiming a fragile IV. Ideas 3–4 are better positioned as mechanism/extension chapters once the flagship contribution is nailed; Idea 2 is not viable without post-1950 adult outcomes.

---

## Gemini 3.1 Pro

**Tokens:** 10081

Here is my evaluation of the research proposals. As requested, I have applied a highly critical lens, prioritizing credible identification, genuine novelty, and top-journal viability based on observed editorial patterns. 

### Rankings

**#1: Idea 1: Missing Men, Rising Women — WWII Selective Mortality and the Individual Origins of Gender Convergence**
- **Score**: 75/100
- **Strengths**: The scale of the data (175M linked records) is treated as scientific content. Tracking the *same* women through the 1940s structural break allows you to construct a new object (within-person trajectories) and potentially resolve compositional confounding in a classic literature.
- **Concerns**: The proposed IV is fatally flawed, and the mortality mechanism is overstated (US WWII deaths were ~400k, or <0.3% of the population, which is insufficient to be the "central mechanism" for aggregate convergence). 
- **Novelty Assessment**: The topic is heavily saturated (Acemoglu, Goldin, Olivetti, etc.), but the individual-level panel approach is genuinely novel. If it overturns stylized facts derived from repeated cross-sections, it is highly valuable.
- **Top-Journal Potential**: High. Top-5 journals consistently reward papers that use massive new administrative panels to reconcile or overturn classic stylized facts (the "puzzle-resolver" archetype). The "causal chain" of individual occupational upgrading is compelling.
- **Identification Concerns**: Using 1940 agricultural share as an IV violates the exclusion restriction. Agricultural and manufacturing counties were on fundamentally different secular trajectories for female labor force participation due to mid-century structural transformation. 
- **Recommendation**: PURSUE (conditional on: abandoning the agricultural IV; finding a credible source of exogenous variation for mobilization, such as local draft board idiosyncrasies, or relying on a tightly controlled event-study).

**#2: Idea 4: The Great Reshuffling — WWII, Internal Migration, and the Geographic Origins of Gender Convergence**
- **Score**: 62/100
- **Strengths**: Leverages the panel structure to solve the classic selection problem in migration literature by observing pre-move characteristics of both movers and stayers.
- **Concerns**: Defense industry placement is not quasi-random; it heavily targeted existing rail, ports, and agglomeration economies. 
- **Novelty Assessment**: WWII migration is well-studied (Boustan, Collins & Wanamaker), but individual panel tracking of the Great Reshuffling is a solid empirical advance over aggregate data.
- **Top-Journal Potential**: Medium. It reads as "technically competent but not exciting." Without a counter-intuitive equilibrium effect or a sharp policy counterfactual, this is a solid field journal paper (e.g., *AEJ: Applied*) rather than a top-5 contender.
- **Identification Concerns**: Endogenous placement of defense contracts and endogenous selection into migration. A triple-difference design does not solve the fact that people who choose to move to defense hubs are on fundamentally different unobservable trajectories.
- **Recommendation**: CONSIDER (conditional on: developing a credible instrument for defense contract allocation, such as physical geography constraints or a shift-share design).

**#3: Idea 5: The Selective Survivor — Mortality Selection, the Missing Fifth, and What Aggregate Gender Gaps Actually Measure**
- **Score**: 45/100
- **Strengths**: Explicitly targets a measurement problem (compositional bias) to reconcile literatures, which is a winning narrative strategy in top journals.
- **Concerns**: The proposal fundamentally conflates census linkage failure with historical mortality. The "Missing Fifth" is an artifact of OCR errors, name changes, and mobility (linkage rates are typically 30-50%), not the ~400k US WWII deaths.
- **Novelty Assessment**: Methodologically novel, but empirically built on a false premise.
- **Top-Journal Potential**: Low. Reviewers will immediately spot the conflation of linkage attrition with mortality. 
- **Identification Concerns**: Linkage rates are highly non-random (correlated with SES, race, and mobility). Using linkage failure as a proxy for mortality or selection is empirically invalid and will result in swift rejection.
- **Recommendation**: SKIP (or pivot entirely to a methodological paper on census linkage bias, dropping the WWII mortality framing).

**#4: Idea 3: The Marriage Market After Armageddon — Sex Ratio Shocks and Assortative Matching**
- **Score**: 35/100
- **Strengths**: Applies a known, successful framework (sex ratio shocks) to new individual-level panel data.
- **Concerns**: The magnitude of the shock is simply too small. The "Armageddon" framing is historically inaccurate for the US mainland; ~400k deaths spread across 3,000 counties will not generate sufficient variation to identify assortative matching changes.
- **Novelty Assessment**: Low. It is a direct port of Abramitzky et al. (WWI France) and Brainerd (WWII Russia) to a setting where the treatment is weak.
- **Top-Journal Potential**: Low. The results would likely be precisely estimated nulls or tiny effects. As the appendix notes, nulls only win when they are decisive and rule out policy-relevant magnitudes, not when the treatment was just weak to begin with.
- **Identification Concerns**: Suffers from the same invalid agricultural IV as Idea 1. Furthermore, 1950 county sex ratios are heavily endogenous to post-war migration.
- **Recommendation**: SKIP.

**#5: Idea 2: Born Under Rosie — Maternal Wartime Employment and the Intergenerational Transmission of Gender Norms**
- **Score**: 15/100
- **Strengths**: Asks an interesting intergenerational question about the transmission of gender norms.
- **Concerns**: Fatal data feasibility flaw. The MLP ends in 1950, meaning the children of WWII workers are only 5 to 15 years old in the endline data. You cannot observe their adult labor market outcomes.
- **Novelty Assessment**: The question is well-studied (Fernández et al.), but the panel approach would be novel *if* the data existed.
- **Top-Journal Potential**: Zero. The study cannot be executed with the proposed data.
- **Identification Concerns**: Cross-county mobilization is a weak and likely confounded instrument for individual maternal employment.
- **Recommendation**: SKIP.

### Summary

This batch relies heavily on the newly available IPUMS MLP 1930-1950, which provides excellent scale and panel structure. However, the proposals consistently suffer from weak identification strategies (invalid IVs) and a misunderstanding of the historical magnitude of US WWII mortality. I recommend pursuing **Idea 1** as the flagship project, provided the authors abandon the flawed agricultural IV and focus purely on the descriptive power of the massive panel to overturn cross-sectional stylized facts about gender convergence.

---

## Grok 4.1 Fast

**Tokens:** 5661

### Rankings

**#1: Missing Men, Rising Women — WWII Selective Mortality and the Individual Origins of Gender Convergence**
- Score: 82/100
- Strengths: Leverages unprecedented individual-level panel data (IPUMS MLP) to track millions of the same people across censuses, enabling precise within-person DiD that decomposes gender convergence into female advancement vs. male removal—a clear causal chain with methodological innovation. Strong exogenous variation from county mobilization intensity, instrumented cleanly by pre-war industrial composition, with ample pre-trends from 1930-1940.
- Concerns: Historical setting limits immediate policy pull, though welfare implications for understanding gender gap origins are clear; selective mortality bounds (Lee 2009) add complexity but may dilute headline sharpness if bounds are wide.
- Novelty Assessment: Highly novel—prior work (Acemoglu et al. 2004; Goldin 1991) relies on aggregates or small cross-sections; first use of multi-wave individual panels (1930-1950) reframes the entire literature.
- Top-Journal Potential: High—this constructs a new object (panel-linked WWII shock) to resolve a puzzle (overstated female progress in aggregates), packages a counter-intuitive mechanism chain (mobilization → male removal → convergence), and delivers field-changing decomposition with tight CIs from massive scale, fitting top-5 patterns like "dark side" effects and literature pivots.
- Identification Concerns: Mobilization instrument strong but could pick up some pre-war industrial sorting; within-person panel mitigates but requires robust parallel trends tests across 1930-1940, with enough treated counties for clustering.
- Recommendation: PURSUE (conditional on: confirming tight Lee bounds and pre-trends visuals in 1930-1940; integrating Idea 5 decomposition as core chapter)

**#2: The Selective Survivor — Mortality Selection, the Missing Fifth, and What Aggregate Gender Gaps Actually Measure**
- Score: 75/100
- Strengths: Pure methodological innovation decomposing aggregate gender gaps into within-person changes vs. composition bias using the panel link rates themselves—directly critiques all prior cross-sectional WWII/gender studies. Clean, scalable identification from the data structure, with Lee bounds quantifying bias precisely.
- Concerns: Standalone, it risks being seen as a "technical note" without broader outcomes; limited to measurement without full causal story on policy shock.
- Novelty Assessment: Extremely novel—no prior formal decomposition of WWII selective mortality bias in gender gaps; methodological advance applicable beyond WWII.
- Top-Journal Potential: High—fits "puzzle-resolver" pattern by exposing measurement error in canonical literature, with generalizable method (link rates → selection bounds) that could adjudicate debates in other compositional settings; pairs perfectly with Idea 1 for causal chain.
- Identification Concerns: Minimal—decomposition is mechanical from panels, but assumes link rates proxy selection perfectly (testable via CenSoc validation); no exogenous shock needed beyond panel existence.
- Recommendation: PURSUE (conditional on: bundling as lead chapter in Idea 1 project; sensitivity to link quality)

**#3: The Marriage Market After Armageddon — Sex Ratio Shocks and Assortative Matching**
- Score: 68/100
- Strengths: Clean extension of foreign sex-ratio literature (Abramitzky et al. 2011) to US with individual panels tracking same-person marriage transitions; exogenous IV from mobilization predicts sex ratios well.
- Concerns: Smaller US mortality shock (~400K) yields modest effect sizes vs. WWI France/Russia, risking imprecise CIs; overlaps heavily with Idea 1 as mechanism.
- Novelty Assessment: Moderately novel—sex ratios post-WWII studied in aggregates, but first individual-level US panels for transitions.
- Top-Journal Potential: Medium—compelling mechanism (sex ratios → matching) with heterogeneity potential, but "competent replication" vibe without strong counter-intuitive hook or first-order stakes; top field (AEJ:App) more likely than top-5 unless chained to convergence puzzle.
- Identification Concerns: Sex ratio changes may correlate with local economic shocks beyond mortality; needs strong pre-trends (1940 singles) and McCrary-style density tests at county cuts.
- Recommendation: CONSIDER (as mechanism chapter for Idea 1)

**#4: The Great Reshuffling — WWII, Internal Migration, and the Geographic Origins of Gender Convergence**
- Score: 60/100
- Strengths: Individual panels enable precise mover-stayer comparisons; triple-diff exploits quasi-random defense placements for exogenous pull.
- Concerns: Migration highly endogenous (self-selection into moves), weakening instrument validity even conditional on controls; risks "spatial confounding" pitfalls from Editorial Appendix.
- Novelty Assessment: Somewhat novel—migration studied in aggregates (Collins/Wanamaker 2014), but first panels; still incremental vs. core gender shock papers.
- Top-Journal Potential: Medium-low—good design but unsurprising ATE on mobility without clear causal chain or welfare pivot; niche unless reframed as boundary test for gender mechanisms.
- Identification Concerns: Defense placement not fully exogenous (ports/rail pre-war advantages may sort talent); failed balance or pre-trends in mover characteristics would kill credibility, per spatial RDD flaws.
- Recommendation: CONSIDER (only as heterogeneity appendix to Idea 1; skip standalone)

**#5: Born Under Rosie — Maternal Wartime Employment and the Intergenerational Transmission of Gender Norms**
- Score: 52/100
- Strengths: Clever within-family IV tests transmission hypothesis, building on Fernández et al. (2004) with actual mother-child links.
- Concerns: Fatal feasibility flaw—MLP ends 1950, so children too young for adult outcomes (e.g., own LFPR), limiting to weak early-life measures; intergenerational story collapses.
- Novelty Assessment: Moderately novel in intent, but data limits echo existing cross-sections; not first on working mothers' transmission.
- Top-Journal Potential: Low—underpowered early outcomes lack stakes or chain; "suggestive" by construction without adult links, matching underpowered cluster pitfalls.
- Identification Concerns: Within-family variation good, but instrument weak if few pre- vs. war-born per mother; child outcomes noisy without forward links.
- Recommendation: SKIP

### Summary
This is a strong batch leveraging a new data object (IPUMS MLP panels) to revitalize WWII/gender literature, with genuine top-journal potential in the decomposition and convergence reframing of Ideas 1 and 5. Pursue Idea 1 as the anchor project (integrating 5 and possibly 3/4), as it best hits novelty, identification, and editorial patterns for causal chains/puzzle resolution; skip Idea 2 outright due to data constraints. Overall quality high for a policy institute, though historical focus tempers policy relevance scores.

