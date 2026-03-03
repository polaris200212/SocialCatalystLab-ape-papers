# Research Idea Ranking

**Generated:** 2026-03-03T20:14:59.989982
**Models:** GPT-5.2, Gemini 3.1 Pro, Grok 4.1 Fast
**Reasoning:** high

## Comparison Table

| Idea | GPT-5.2 | Gemini 3.1 Pro | Grok 4.1 Fast |
|------|------|------|------|
| Who Captures a Tax Cut? Property Price C... | PURSUE (79) | PURSUE (88) | PURSUE (82) |
| Maternity Ward Closures and Birth Outcom... | CONSIDER (68) | CONSIDER (58) | CONSIDER (68) |
| Low-Emission Zones (ZFE) and Property Va... | CONSIDER (66) | SKIP (52) | SKIP (58) |
| Sunday Trading Liberalization and Local ... | CONSIDER (57) | SKIP (48) | CONSIDER (62) |
| Municipal Mergers (Communes Nouvelles) a... | SKIP (49) | SKIP (38) | SKIP (52) |

---

## GPT-5.2

**Tokens:** 6680

### Rankings

**#1: Who Captures a Tax Cut? Property Price Capitalization from France's €20B Taxe d'Habitation Abolition**
- **Score: 79/100**
- **Strengths:** First-order policy shock (largest modern OECD residential property-tax abolition) plus *universe* transactions (DVF) gives unusually high power and scope for mechanism work (timing, supply elasticity, volumes). The design can “pre-build the skeptic” via secondary-residence placebo and heterogeneous exposure (rate variation × income-phase-in).
- **Concerns:** Capitalization is a heavily-studied object, so you must clearly separate what’s new (scale, institutional setting, phase-in, welfare incidence) from “yet another capitalization DiD.” Key risk is confounding local trends correlated with pre-TH rates/income composition (and contemporaneous shocks like Covid, local amenities investment, other housing/tax reforms).
- **Novelty Assessment:** **Medium-high**. Property-tax capitalization has a large literature, but *this specific reform* (size + phased abolition + France + universe DVF) is plausibly underpublished in journals and could genuinely add.
- **Top-Journal Potential: Medium-High.** Not automatically top-5 because capitalization is “classic,” but the combination of unprecedented fiscal magnitude + clean placebo architecture + welfare/incidence decomposition could be AEJ:EP/JPE-quality if executed tightly and framed around incidence and local public finance.
- **Identification Concerns:** Continuous/staggered DiD hinges on parallel trends in high- vs low-TH communes and early- vs late-phase-in places; income composition is not random and may proxy for divergent housing-demand trends. Need very explicit event studies by exposure bins, strong placebo battery (secondary residences; non-affected property types/areas), and careful handling of staggered timing and anticipation.
- **Recommendation:** **PURSUE (conditional on: constructing property-level predicted TH exposure credibly; demonstrating strong pre-trends/placebos across multiple exposure definitions; a clear welfare/incidence/who-benefits decomposition beyond an average price effect)**

---

**#2: Maternity Ward Closures and Birth Outcomes in France**
- **Score: 68/100**
- **Strengths:** Extremely high policy stakes (access to obstetric care, neonatal outcomes) and a large national closure wave—this is the kind of “life-and-death” margin top journals like when identification is credible. France’s regulatory-volume rationale could potentially be leveraged into a sharper design than “closures happened.”
- **Concerns:** Feasibility is the gating item: open commune-level vital stats likely won’t contain prematurity/birthweight with needed granularity, pushing you toward restricted SNDS access and linkage complexity. Closure endogeneity is also serious (closures may follow deteriorating quality, staffing shortages, or local demographic decline).
- **Novelty Assessment:** **Medium**. US evidence exists; France-specific causal evidence appears thinner, but “hospital/ward closure impacts” is a known genre—novelty must come from scale, institutional rules, and sharper design (e.g., regulatory threshold).
- **Top-Journal Potential: Medium (could become High if design sharpens).** With individual-level outcomes and a quasi-experimental lever (e.g., discontinuity/IV from volume thresholds, regulator rules, or mandated compliance dates), it could be very publishable; without that, it risks reading as a standard staggered DiD with endogenous treatment.
- **Identification Concerns:** “Nearest ward closes” is vulnerable to differential pre-trends (areas losing wards may be shrinking/aging/poorer) and compositional changes (who gives birth locally vs elsewhere). A strong version likely needs: explicit distance-to-care first stage, migration/selection checks, and ideally an instrument tied to regulatory thresholds rather than discretionary closure decisions.
- **Recommendation:** **CONSIDER (conditional on: confirming outcome availability at high resolution; obtaining credible closure timing; upgrading identification—ideally threshold-based RD/IV or regulator-driven quasi-random timing rather than pure DiD)**

---

**#3: Low-Emission Zones (ZFE) and Property Values at City Boundaries**
- **Score: 66/100**
- **Strengths:** Boundary-based designs can be persuasive, and France’s multi-city staggered rollouts allow difference-in-discontinuities rather than a single-city case study. DVF makes the outcome measurable at high spatial resolution; the policy is salient and current.
- **Concerns:** ZFE boundaries are not “as-good-as-random”: they often track ring roads, density, transit, school quality, and other discontinuous amenities—exactly what breaks spatial RDD. Air-quality measurement is also tricky (monitor sparsity), so the mechanism chain (policy → pollution/amenities → prices) may be hard to nail.
- **Novelty Assessment:** **Medium-low to Medium**. LEZ/ULEZ effects have an active literature; France/Crit’Air adds institutional variation but not a brand-new question.
- **Top-Journal Potential: Medium-Low.** Likely a strong field-journal piece if identification holds and you show mechanisms (pollution, noise, traffic, accessibility) rather than only a price discontinuity. Top-5 odds rise only if you convincingly isolate competing channels (environmental improvement vs access/commuting cost) and show a surprising welfare-incidence pattern.
- **Identification Concerns:** Sorting/anticipation (buyers and sellers reposition around boundaries), boundary co-movements with other policies (bike lanes, transit expansions), and spatial spillovers (traffic diversion just outside) can all contaminate. You’ll need dense balance tests, “donut” RDD, alternative boundaries placebo, and careful bandwidth sensitivity.
- **Recommendation:** **CONSIDER (conditional on: obtaining precise, legally stable boundary shapefiles by date; showing strong covariate smoothness/placebos; adding credible mechanism measures—potentially satellite/traffic proxies if monitors are sparse)**

---

**#4: Sunday Trading Liberalization and Local Retail Markets**
- **Score: 57/100**
- **Strengths:** Sharp within-city policy discontinuities (ZTI boundaries) are attractive, and retail-market responses are of real interest to urban policymakers. If you can link to employment/wages, you could speak to labor-market incidence rather than just firm counts.
- **Concerns:** Small number of treated zones (and highly selected: tourism-heavy, already-trending neighborhoods) makes inference and external validity difficult; spillovers/displacement to nearby areas are likely first-order. Without restricted employment data, the remaining outcomes (creation/closure) may look narrow and “competent but not exciting.”
- **Novelty Assessment:** **Medium-low**. Sunday trading has been studied in multiple countries; France’s ZTI boundary structure is somewhat distinctive, but not obviously a literature-reset.
- **Top-Journal Potential: Low-Medium.** Could land in a good field journal with strong data and careful spillover modeling; top-journal potential is limited unless you uncover a belief-changing mechanism (e.g., strong displacement, rent capture by landlords, or surprising worker welfare effects).
- **Identification Concerns:** Treated neighborhoods differ sharply from controls; parallel trends at a fine spatial level are hard, and policy assignment is plausibly endogenous to anticipated growth/tourism. Difference-in-discontinuities helps but does not eliminate boundary-amenity confounding.
- **Recommendation:** **CONSIDER (conditional on: securing DADS or equivalent employment data; explicitly designing around spillovers/displacement and endogenous zone selection; having enough ZTIs/cities for credible inference)**

---

**#5: Municipal Mergers (Communes Nouvelles) and Local Public Goods**
- **Score: 49/100**
- **Strengths:** Large number of mergers and strong administrative data availability make this feasible, and “scale of local government” is a durable policy question. Property values as a summary measure of perceived public goods/governance is a potentially useful angle.
- **Concerns:** Voluntary adoption is a fundamental identification problem—matching/event studies are unlikely to convince top outlets because merger decisions correlate with unobserved fiscal stress, leadership quality, demographics, and pre-existing trajectories. Even with good execution, the likely product is “reasonable DiD on an endogenous reform,” which editors often view as incremental.
- **Novelty Assessment:** **Medium-low**. Municipal consolidation has a substantial international literature; France is a new setting, but the core question is well-trodden.
- **Top-Journal Potential: Low.** Without a strong quasi-random lever (e.g., a sharp eligibility/incentive discontinuity, binding referendum thresholds, or something akin to an instrument), it’s hard to see top-journal excitement.
- **Identification Concerns:** Selection into merging plus simultaneous administrative changes (budgets, services, boundaries) make it difficult to isolate causal effects; composition changes and reclassification can mechanically move outcomes. Pre-trends will likely differ and may not be salvageable.
- **Recommendation:** **SKIP (unless you can credibly instrument/identify quasi-random merger adoption—otherwise the endogeneity risk dominates)**

---

### Summary

This batch has one clearly front-runner (**taxe d’habitation abolition**) with strong feasibility, scale, and an unusually rich set of built-in validation tests—worth moving to execution immediately. **Maternity closures** and **ZFE boundaries** are promising but hinge on (i) data access/measurement and (ii) sharpening identification to survive skepticism. The **municipal mergers** idea is the weakest as stated due to fundamental selection problems; **Sunday trading** is viable mainly if you can obtain richer labor outcomes and credibly handle spillovers and endogenous zone designation.

---

## Gemini 3.1 Pro

**Tokens:** 7636

Here is my evaluation of the research proposals, ranked from most to least promising, applying the strict criteria of top-tier economics publishing and policy relevance.

### Rankings

**#1: Who Captures a Tax Cut? Property Price Capitalization from France's €20B Taxe d'Habitation Abolition**
- **Score**: 88/100
- **Strengths**: This proposal leverages massive scale ("universe" data) to evaluate a first-order, €23.4B policy shock with a highly credible, multi-layered identification strategy. The built-in placebo of secondary residences is an elegant, top-tier design feature that pre-empts the most obvious skeptical counterarguments.
- **Concerns**: The phase-in timing is tied to commune-level income, meaning early-treated communes are systematically poorer than late-treated ones, which could correlate with divergent underlying property price trends. 
- **Novelty Assessment**: Extremely high. A €20B+ tax abolition with zero existing causal journal publications is a rare find. It moves beyond standard capitalization papers by exploiting the staggered, income-based rollout and supply elasticity mechanisms.
- **Top-Journal Potential**: High. This perfectly fits the "scale as scientific content" and "first-order stakes" heuristics from the editorial appendix. By decomposing the capitalization mechanism (immediate vs. delayed, buyer vs. seller capture) rather than just estimating an ATE, it offers a compelling causal chain for a top-5 or AEJ: Policy.
- **Identification Concerns**: The primary threat is that low-income communes (treated early) and high-income communes (treated late) have different baseline property price trajectories due to macroeconomic trends (e.g., post-COVID urban flight). The secondary residence placebo is crucial to solving this.
- **Recommendation**: PURSUE (conditional on: successfully validating parallel trends between early/late treated communes using the 2014-2017 pre-period, and heavily leaning on the secondary residence placebo).

**#2: Maternity Ward Closures and Birth Outcomes in France**
- **Score**: 58/100
- **Strengths**: The regulatory, volume-based threshold for closures provides a clearer quasi-experimental setup than market-driven closures in the US. It addresses a highly salient local policy issue with clear welfare implications (infant health).
- **Concerns**: The data feasibility is highly suspect without restricted SNDS access, as open état civil data lacks the clinical granularity (prematurity, exact birth weight) needed for top-tier health economics. 
- **Novelty Assessment**: Low to Medium. The impact of maternity ward closures on birth outcomes is a well-trodden literature (e.g., US, rural closures). While the French regulatory context is different, the fundamental economic question is not new.
- **Top-Journal Potential**: Low. This falls squarely into the "technically competent but not exciting" category. It estimates a standard ATE on a familiar policy without a surprising mechanism or belief-changing literature pivot. 
- **Identification Concerns**: Volume-based closures are not truly exogenous; wards drop below 300 births because the local population is shrinking or economically declining. This creates a severe risk of omitted variable bias where deteriorating local economic conditions drive both the closure and worse health outcomes.
- **Recommendation**: CONSIDER (conditional on: securing restricted SNDS health data and finding an instrumental variable or sharp RDD around the 300-birth threshold to isolate exogenous closures).

**#3: Low-Emission Zones (ZFE) and Property Values at City Boundaries**
- **Score**: 52/100
- **Strengths**: The multi-city staggered rollout combined with spatial boundaries offers a theoretically clean difference-in-discontinuities design. It targets a highly controversial, modern urban policy.
- **Concerns**: Air pollution does not stop at a street boundary, making a sharp spatial RDD physically implausible for the environmental mechanism. Furthermore, ATMO monitoring stations are far too sparse to measure block-by-block boundary discontinuities.
- **Novelty Assessment**: Medium. The literature on LEZs (Germany, London ULEZ) is already quite crowded. Looking at property values in France is an incremental addition rather than a paradigm shift.
- **Top-Journal Potential**: Low. Top journals will immediately flag the physical spillovers of air quality. Without a novel mechanism, this reads as a standard spatial DiD in a saturated literature.
- **Identification Concerns**: Endogenous boundary drawing (cities draw ZFE lines around specific neighborhoods for political/economic reasons) and spatial spillovers (pollution blows across the boundary; traffic reroutes just outside the boundary, violating SUTVA).
- **Recommendation**: SKIP

**#4: Sunday Trading Liberalization and Local Retail Markets**
- **Score**: 48/100
- **Strengths**: The creation of sharp, within-city ZTI boundaries provides a visually compelling spatial discontinuity for a classic economic question about labor and retail regulation.
- **Concerns**: The proposal suffers from a severe "measurement mismatch" (as noted in the appendix): firm creation/closure is the wrong outcome variable. Sunday trading primarily affects the intensive margin (sales, employment hours of existing firms), not the extensive margin of firm creation.
- **Novelty Assessment**: Medium. Sunday trading is a classic topic. The ZTI spatial boundary is a neat institutional quirk, but the underlying economic question is well-explored.
- **Top-Journal Potential**: Low. Without restricted employment data (DADS) or sales data (VAT records), the paper is underpowered by construction. Top journals routinely reject papers that measure the wrong margin of a policy.
- **Identification Concerns**: ZTI boundaries were explicitly drawn around already-booming, high-tourist areas (e.g., Champs-Élysées, Haussmann). Comparing these global retail hubs to streets just outside the zone is a comparison of fundamentally unobservable different markets.
- **Recommendation**: SKIP

**#5: Municipal Mergers (Communes Nouvelles) and Local Public Goods**
- **Score**: 38/100
- **Strengths**: The scale of the reform is massive (reducing French communes by nearly 2,000), and the data is entirely open-access and easily linked.
- **Concerns**: The voluntary nature of the mergers introduces a fatal selection bias that standard matching techniques cannot solve. 
- **Novelty Assessment**: Medium. Municipal mergers are studied extensively in public choice economics (Denmark, Japan). The French wave is large but theoretically similar.
- **Top-Journal Potential**: Low. This proposal contains a fatal flaw: "Admitted identification failure with no salvage design." Top journals do not publish event-study DiDs on purely voluntary, incentivized policy adoptions unless there is a strictly exogenous instrument for adoption.
- **Identification Concerns**: Communes that choose to merge are fundamentally different from those that do not. They often merge because they are facing severe fiscal distress, or conversely, because they have highly competent, aligned mayors. Matching on pre-merger observables cannot control for this endogenous political selection.
- **Recommendation**: SKIP

### Summary

This batch contains one absolute standout and several mediocre proposals that fall into common applied microeconomics traps. **Idea 1 (Taxe d'Habitation)** is a rare, top-tier opportunity: it combines a massive, unstudied €23.4B policy shock with universe-level data and a highly credible identification strategy (including a brilliant built-in placebo). I strongly recommend allocating institute resources to Idea 1 immediately. The remaining ideas suffer from either fatal endogeneity (Idea 4, Idea 5), physical spillover violations (Idea 3), or being "competent but unexciting" additions to crowded literatures (Idea 2).

---

## Grok 4.1 Fast

**Tokens:** 5798

### Rankings

**#1: Who Captures a Tax Cut? Property Price Capitalization from France's €20B Taxe d'Habitation Abolition**
- Score: 82/100
- Strengths: Extremely novel as the first causal academic study of the largest OECD residential property tax abolition, using universe transaction data and multiple staggered DiD variations with built-in placebos; strong mechanism decomposition (immediate/delayed capitalization, supply elasticity) and welfare analysis on tax incidence.
- Concerns: Property tax capitalization is a crowded theoretical area, so the paper must aggressively position against simulations/existing empirics to avoid "another cap study"; short post-period for top 20% phase-in (2021-2023) risks underpowered nulls on full rollout.
- Novelty Assessment: Highly novel—only one non-peer-reviewed policy report exists; no journal papers on this exact massive reform, despite general capitalization literature.
- Top-Journal Potential: High. Challenges conventional wisdom on full property tax capitalization with a counter-intuitive capture question (sellers/buyers/gov?) on first-order stakes (€23B scale, universe data enables definitive bounds); fits winning arc of policy shock → causal chain (phase-in → prices → mechanisms) → welfare deliverable.
- Identification Concerns: Staggered timing risks heterogeneous trends, but modern CS estimator, HonestDiD, and secondary residence placebo strongly mitigate; commune-level variation in rates and income shares provides exogenous bite with 4+ pre-years.
- Recommendation: PURSUE (conditional on: robust event-study visuals pre-empting trend concerns; full mechanism tables with transaction volumes)

**#2: Maternity Ward Closures and Birth Outcomes in France**
- Score: 68/100
- Strengths: First-order life-and-death stakes on birth outcomes from regulatory closures, cleaner centralized quasi-experiment than US market-driven studies; event-study DiD leverages large closure wave for reliable power.
- Concerns: Data feasibility uncertain (SNDS likely needed for birth weights/prematurity, not open état civil); limited French evidence means it risks being a "replication with local flavor" without strong mechanisms or general equilibrium (e.g., travel substitution).
- Novelty Assessment: Moderately novel—US papers exist, but France's scale and regulatory driver are understudied with no major causal French papers.
- Top-Journal Potential: Medium. High stakes appeal, but needs mechanism chain (distance → outcomes → long-run health) to elevate beyond competent ATE; recent/short post-periods per appendix hurt unless framed as "short-run overpowered null."
- Identification Concerns: Nearest-ward assignment may suffer spillovers (women bypass to next ward) or selection (risky pregnancies avoid closing wards); needs pre-trends by rurality and travel-time balances.
- Recommendation: CONSIDER (conditional on: confirming open data granularity; adding travel-time mechanisms)

**#3: Sunday Trading Liberalization and Local Retail Markets**
- Score: 62/100
- Strengths: Exceptionally clean spatial DiD from sharp ZTI boundaries within cities, providing precise difference-in-discontinuities; novel French setup vs. prior studies elsewhere.
- Concerns: Outcomes too narrow (firm entry/exit without employment risks "competent but unsurprising null"); restricted DADS access limits scope, diluting measurement per appendix.
- Novelty Assessment: Moderately novel—similar studies in Germany/Netherlands, but ZTI spatial discontinuity is a fresh natural experiment.
- Top-Journal Potential: Low. Standard retail ATE without counter-intuitive tradeoff, mechanism chain, or welfare pivot; reads as "narrow firm counts" modal loss, not field-changing.
- Identification Concerns: Boundary firms may sort or spill over; voluntary ZTI designation risks endogeneity unless pre-trends/balances are pristine.
- Recommendation: CONSIDER

**#4: Low-Emission Zones (ZFE) and Property Values at City Boundaries**
- Score: 58/100
- Strengths: Multi-city staggered adoption strengthens spatial RDD; timely env policy with air quality mechanisms.
- Concerns: Crowded literature (Germany/London) makes it incremental; sparse air monitors undermine fine-grained spatial analysis and mechanisms.
- Novelty Assessment: Low to moderate—growing evidence from other LEZs, with limited but emerging French work.
- Top-Journal Potential: Low. Familiar property ATE on env policy lacks surprise or stakes; no clear causal chain beyond capitalization, risking "technically sound but dull."
- Identification Concerns: Boundary fuzziness (enforcement?) and multi-city heterogeneity threaten RDD density/balance; staggered timing needs modern DiD to avoid TWFE pitfalls.
- Recommendation: SKIP

**#5: Municipal Mergers (Communes Nouvelles) and Local Public Goods**
- Score: 52/100
- Strengths: Large merger wave with confirmed data; property values as revealed-preference outcome for governance quality.
- Concerns: Voluntary selection is a fatal endogeneity threat—merging communes likely higher-quality baselines; matching won't fully resolve per appendix patterns.
- Novelty Assessment: Moderately novel—international studies exist, but France's scale unexplored.
- Top-Journal Potential: Low. Governance scale nulls without bite verification or tradeoff (e.g., efficiency vs. identity loss) read as niche administrative margin, not first-order.
- Identification Concerns: Incentives create selection bias (better communes merge); no clear exogenous shifter, pre-trends likely fail without strong matching diagnostics.
- Recommendation: SKIP

### Summary
This is a strong batch with one genuine top-journal contender (Idea 1) due to its scale, novelty, and incidence question, while others are competent mid-tier policy evals hampered by data gaps, crowded topics, or ID threats. Pursue Idea 1 immediately for its universe-data firepower and welfare punch; conditionally consider Idea 2 if data confirms, as stakes could elevate it. The rest lack excitement or credibility for a policy institute prioritizing field changers.

