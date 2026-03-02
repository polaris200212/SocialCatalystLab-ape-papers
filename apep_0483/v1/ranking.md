# Research Idea Ranking

**Generated:** 2026-03-02T13:31:25.325131
**Models:** GPT-5.2, Gemini 3.1 Pro, Grok 4.1 Fast
**Reasoning:** high

## Comparison Table

| Idea | GPT-5.2 | Gemini 3.1 Pro | Grok 4.1 Fast |
|------|------|------|------|
| Teaching the STEM Gap: Training Bursary ... | PURSUE (73) | — | — |
| The Competitiveness Cliff: Teacher Pay, ... | CONSIDER (68) | — | — |
| The Decade of Decline: How the Austerity... | CONSIDER (65) | — | — |
| Teach First Meets Doubly Robust: The Cau... | CONSIDER (55) | — | — |
| Deregulation Without Deviation: Academy ... | SKIP (44) | — | — |
| Idea 1: The Decade of Decline: How the A... | — | PURSUE (78) | PURSUE (76) |
| Idea 5: The Competitiveness Cliff: Teach... | — | CONSIDER (68) | CONSIDER (64) |
| Idea 2: Teaching the STEM Gap: Training ... | — | SKIP (52) | CONSIDER (68) |
| Idea 3: Deregulation Without Deviation: ... | — | SKIP (40) | SKIP (48) |
| Idea 4: Teach First Meets Doubly Robust:... | — | SKIP (30) | PURSUE (54) |

---

## GPT-5.2

**Tokens:** 7225

### Rankings

**#1: Teaching the STEM Gap: Training Bursary Shocks, Recruitment Quality, and Subject-Level Student Outcomes**
- **Score: 73/100**
- **Strengths:** Large, policy-driven subject×year variation with clear first-stage outcomes (ITT applications/recruitment) and a potentially compelling mechanism chain (bursary → teacher supply/quality → subject-specific achievement). If credibly linked to student outcomes, this is both high-stakes (STEM shortages) and exportable beyond the UK.
- **Concerns:** Bursary schedules are not purely exogenous—DfE adjusts them in response to anticipated shortages, which may correlate with contemporaneous subject trends (curriculum/exam changes, grading reforms, shifting pupil composition). Mapping bursary cohorts into actual classroom exposure and then into subject GCSE outcomes risks substantial treatment mismeasurement.
- **Novelty Assessment:** **Medium-High.** Bursaries are studied for recruitment/supply; much less is credibly known about downstream student achievement effects by subject.
- **Top-Journal Potential: Medium-High.** Could be AEJ:EP/top-field if you deliver a tight causal chain and show meaningful learning impacts (not just recruitment). Top-5 is possible but would likely require unusually clean identification and a strong welfare/policy counterfactual (e.g., cost per SD increase in STEM achievement).
- **Identification Concerns:** The main threat is **policy endogeneity and coincident subject shocks** (e.g., national STEM curriculum/exam reforms) that move outcomes independently of bursaries. A more credible design would look like an **event-study/DiD across subjects** with rich subject-specific time controls, explicit handling of exam reform periods, and strong first-stage + exposure validation.
- **Recommendation:** **PURSUE (conditional on: (i) design upgrade to subject×year DiD/event-study with exam-reform controls/placebos; (ii) validated exposure mapping from bursary cohort → teacher supply in schools/subjects; (iii) pre-trend and “other-subject placebo” battery).**

---

**#2: The Competitiveness Cliff: Teacher Pay, Local Labor Markets, and the Widening Achievement Gap in England**
- **Score: 68/100**
- **Strengths:** Inequality-focused outcome (FSM gap) is intrinsically more “editorially valuable” than average attainment, and the UK’s nationally set pay with locally varying outside options is a strong motivating institutional feature. Data feasibility is excellent and the mechanism (vacancies/turnover) is measurable.
- **Concerns:** The competitiveness shock (local private wage growth) is highly entangled with local economic change that also affects pupils (income, housing churn/gentrification, school composition, local public spending). The DR-AIPW framing does not, by itself, resolve time-varying omitted variables; you risk a “local boom/bust explains everything” critique.
- **Novelty Assessment:** **Medium.** Teacher labor-market competitiveness is studied broadly; the *UK austerity-era competitiveness → achievement gap* angle is less saturated and could be a meaningful contribution if identified well.
- **Top-Journal Potential: Medium.** The inequality framing helps, and a convincing mechanism chain (competitiveness → vacancies → differential sorting/quality → FSM gap) could be publishable in top field journals. Top-5 would require a design that convincingly rules out local economic confounds.
- **Identification Concerns:** The key threat is **endogenous local wage growth** correlated with unobserved shocks to the FSM gap (migration, school intakes, local policy changes). You likely need a **panel design with LA fixed effects + event-study**, and ideally a **shift-share/Bartik-style instrument** for outside-option growth (predicted wage growth from baseline industry mix) to isolate plausibly exogenous labor-demand shocks.
- **Recommendation:** **CONSIDER (upgrade needed: FE/event-study + stronger exogenous variation; explicit composition checks for FSM cohorts and migration).**

---

**#3: The Decade of Decline: How the Austerity Pay Squeeze on Teachers Shaped Student Achievement in England**
- **Score: 65/100**
- **Strengths:** Big, first-order policy episode (real pay erosion) with long panel coverage and measurable intermediates (vacancies/leaving). The “national pay-setting × local outside options” angle is the right economic mechanism and can support a full chain, not just an ATE.
- **Concerns:** As written, identification leans too heavily on cross-sectional intensity and DR adjustment; local private wage growth is not plausibly exogenous to student achievement trends. Also, GCSE reforms and accountability changes during the 2010s create outcome comparability issues that must be handled explicitly.
- **Novelty Assessment:** **Medium.** There is a large teacher quality/pay literature; the specific austerity-pay-cap competitiveness channel in England is less directly “done,” but reviewers will see it as close to existing competitiveness/outside-option designs unless the identification is unusually clean.
- **Top-Journal Potential: Medium-Low.** Likely a solid policy paper if executed well; top-5 odds are limited unless you convincingly isolate exogenous outside-option shocks and deliver a mechanism decomposition that changes beliefs about teacher pay rigidity and labor-market competition.
- **Identification Concerns:** Main issues are **time-varying confounding** (local growth affects kids directly) and **measurement/standardization of GCSE outcomes** across reform years. A credible approach would look more like **continuous-treatment DiD with FE + IV (predicted wage growth)** than DR-AIPW alone.
- **Recommendation:** **CONSIDER (conditional on: (i) FE/event-study design; (ii) exogenous wage-growth proxy/IV; (iii) explicit handling of GCSE/accountability regime breaks).**

---

**#4: Teach First Meets Doubly Robust: The Causal Effect of High-Performing Graduates on Disadvantaged Schools**
- **Score: 55/100**
- **Strengths:** Clear, policy-salient program; long time horizon and geographic rollout potentially allow stronger quasi-experimental designs than simple matching. If you can measure persistence (post-participant), that’s a valuable mechanism/persistence contribution.
- **Concerns:** This is already a studied program, and “DR-AIPW instead of matching” is not a novelty hook. Data access is the binding constraint (school-level placement lists), and selection into receiving Teach First (among eligible schools) is likely strongly non-random.
- **Novelty Assessment:** **Low-Medium.** Teach First effects have been examined; incremental unless you unlock new data or a sharper design (e.g., rollout-based event study with credible comparison groups).
- **Top-Journal Potential: Low-Medium.** Could be publishable if you obtain near-universe placement data and exploit rollout/eligibility rules credibly. Without that, it will read as “competent but not exciting,” and vulnerable on identification.
- **Identification Concerns:** **Selection on unobservables** (school leadership, capacity to host trainees, MAT networks) and **non-random placement** are the core threats. A stronger design would exploit **staggered regional entry + eligibility-based comparisons**, not just covariate adjustment.
- **Recommendation:** **CONSIDER (conditional on: obtaining credible school-level placement data; and pivoting to a rollout/eligibility design rather than pure DR selection-on-observables).**

---

**#5: Deregulation Without Deviation: Academy Pay Freedom and the Paradox of Unused Autonomy**
- **Score: 44/100**
- **Strengths:** The “unused autonomy/adoption puzzle” is genuinely interesting and can be framed in a way editors like (why institutions don’t use available margins). If you could build a new dataset on pay-setting behavior, that *object creation* could be the main contribution.
- **Concerns:** The key treatment—whether a school deviates from STPCD—is not currently observable in public microdata, and proxies (average pay anomalies) are noisy and confounded by staff composition. Even with data, deviators are a selected 13% and likely differ on unobservables (MAT strategy, governance quality), making causal effects very hard.
- **Novelty Assessment:** **High on the puzzle, low on feasibility.** The adoption/non-adoption angle is less studied than academy conversion per se, but only if you can measure it cleanly.
- **Top-Journal Potential: Low (as currently scoped).** With a credible new measurement dataset, the descriptive “adoption failure” paper could become interesting; the causal “effect of deviation” is likely too selection-ridden for top outlets without a sharp instrument.
- **Identification Concerns:** **Severe measurement and selection problems**: you don’t observe treatment, and the adopters are non-random with small effective sample size.
- **Recommendation:** **SKIP (unless you can: (i) obtain/construct true school-level pay-policy indicators at scale; and (ii) reframe toward the adoption/constraints question rather than causal impacts).**

---

### Summary

This is a strong batch in terms of policy relevance and data awareness, but several ideas currently over-rely on “doubly robust” language to substitute for truly exogenous variation. The best near-term bet is **Idea 2** if you can credibly handle policy endogeneity and exam-reform confounds while validating exposure; next are **Ideas 5 and 1**, but both need a design pivot toward **panel FE/event-study and plausibly exogenous outside-option shocks (e.g., Bartik-predicted wage growth)** to be top-journal competitive.

---

## Gemini 3.1 Pro

**Tokens:** 8585

Here is my evaluation of the research proposals. 

As a general note before diving into the rankings: the author of these proposals seems to view Doubly Robust AIPW (DR-AIPW) as a magic bullet for causal inference. It is not. DR-AIPW only solves selection on *observables*. In applied microeconomics, the primary threats to identification are almost always *unobservables* (e.g., school leadership quality, local economic shocks). Proposing DR-AIPW for highly endogenous treatments (like a school choosing to deviate from a pay scale) is a red flag. 

That said, there is one genuinely excellent source of variation in this batch.

### Rankings

**#1: Idea 1: The Decade of Decline: How the Austerity Pay Squeeze on Teachers Shaped Student Achievement in England**
- **Score**: 78/100
- **Strengths**: This addresses a first-order macroeconomic policy (austerity) through a clever micro-level mechanism (local labor market competitiveness). It proposes a complete, testable causal chain (pay → vacancies → replacement quality → student outcomes) which top journals love.
- **Concerns**: The proposal relies on cross-sectional DR-AIPW, which is the wrong tool for a spatial shock over time. Local economic booms (e.g., London tech corridors) drive both private wages and gentrification, which independently affects GCSE scores.
- **Novelty Assessment**: High. While the teacher pay penalty is well-documented descriptively, using the 2010-2019 austerity cap interacting with local private-sector wage variance as a natural experiment for student outcomes is a fresh, highly compelling angle.
- **Top-Journal Potential**: High. This has the "first-order stakes" and "mechanism trace" that win top-5 placements. It moves beyond a simple ATE to show *how* macro-austerity hollows out state capacity at the micro-level. 
- **Identification Concerns**: Unobserved local economic trends. To be viable, the identification strategy must be upgraded from DR-AIPW to a panel Difference-in-Differences or a Shift-Share (Bartik) design that controls for local authority fixed effects and local economic trends.
- **Recommendation**: PURSUE (conditional on: abandoning DR-AIPW in favor of a panel fixed-effects or shift-share design; proving parallel pre-trends in the 2000s).

**#2: Idea 5: The Competitiveness Cliff: Teacher Pay, Local Labor Markets, and the Widening Achievement Gap in England**
- **Score**: 68/100
- **Strengths**: Applies a crucial equity lens to the excellent variation identified in Idea 1. Policymakers care deeply about the FSM achievement gap.
- **Concerns**: It is essentially the exact same paper as Idea 1, just with a different left-hand-side variable. 
- **Novelty Assessment**: Medium-High. The intersection of local labor market shocks and educational inequality is understudied in the UK context.
- **Top-Journal Potential**: Medium. While inequality is a major topic, journals usually prefer the "main effect + mechanism" (Idea 1) over a pure heterogeneity story, unless the gap widening is the *only* place the effect shows up.
- **Identification Concerns**: Identical to Idea 1. You cannot use selection-on-observables to wave away local economic shocks that simultaneously drive private wages and demographic shifts in the FSM population.
- **Recommendation**: CONSIDER (as a major heterogeneity section *within* Idea 1, rather than a standalone paper).

**#3: Idea 2: Teaching the STEM Gap: Training Bursary Shocks, Recruitment Quality, and Subject-Level Student Outcomes**
- **Score**: 52/100
- **Strengths**: Clever use of subject-level variation and publicly available bursary schedules. 
- **Concerns**: Massive measurement dilution. A bursary shock in 2015 might bring 3 new physics teachers into a local authority in 2016, but they will be a tiny fraction of the total physics teaching workforce by the time 2019 GCSEs are taken. 
- **Novelty Assessment**: Medium. Bursary effects on recruitment are well-studied; tracing this to student outcomes is novel but likely because it is empirically intractable.
- **Top-Journal Potential**: Low. This falls directly into the "measurement mismatch/dilution" fatal flaw noted in the Editorial Appendix. The treatment (a few new trainees) is too diluted at the school-subject level to detectably move the needle on aggregate GCSE scores. You will get a precisely estimated null that reviewers will dismiss as underpowered by construction.
- **Identification Concerns**: Subject-level grading standards and uptake trends change over time (e.g., the push for EBacc). A DR approach cannot account for unobserved subject-specific trends.
- **Recommendation**: SKIP.

**#4: Idea 3: Deregulation Without Deviation: Academy Pay Freedom and the Paradox of Unused Autonomy**
- **Score**: 40/100
- **Strengths**: The descriptive puzzle—that 87% of academies don't use their primary deregulatory freedom—is genuinely fascinating and highlights a major coordination failure.
- **Concerns**: The proposal lacks the data to actually identify the treated units, and the proposed causal design is hopelessly confounded.
- **Novelty Assessment**: High for the descriptive puzzle; low for the causal evaluation.
- **Top-Journal Potential**: Low for the causal paper. A purely descriptive paper on the "adoption puzzle" (why institutions refuse autonomy) might have a shot at a field journal, but the causal claims would be rejected outright.
- **Identification Concerns**: Fatal. Schools that choose to deviate from national pay scales are fundamentally different in unobservable ways (e.g., aggressive MAT leadership, financial distress) than those that don't. DR-AIPW cannot fix this endogeneity.
- **Recommendation**: SKIP (unless pivoted to a purely descriptive/qualitative paper on institutional inertia).

**#5: Idea 4: Teach First Meets Doubly Robust: The Causal Effect of High-Performing Graduates on Disadvantaged Schools**
- **Score**: 30/100
- **Strengths**: Teach First is a well-known program, and the 20-year panel offers a chance to look at long-run effects.
- **Concerns**: This is the definition of "technically competent but not exciting." Updating an old Propensity Score Matching paper with a slightly newer selection-on-observables estimator (DR-AIPW) is not a contribution. Furthermore, the school-level data isn't even public.
- **Novelty Assessment**: Low. Teach First has been evaluated to death.
- **Top-Journal Potential**: Low. This perfectly matches the modal loss in the appendix: a standard estimator on a familiar policy without a new mechanism or belief-changing pivot. 
- **Identification Concerns**: Fatal. Teach First actively selects schools based on leadership capacity, and schools must proactively apply. Controlling for FSM% and prior attainment does not capture the unobserved drive of a headteacher trying to turn a school around.
- **Recommendation**: SKIP.

### Summary

This batch contains one highly promising natural experiment (the austerity pay squeeze interacting with local labor markets) and several weak ideas that rely too heavily on selection-on-observables estimators (DR-AIPW) to evaluate endogenous choices. I strongly recommend pursuing **Idea 1**, incorporating the equity focus of **Idea 5** as a core mechanism. However, the researcher must abandon the cross-sectional DR-AIPW approach in favor of a rigorous panel fixed-effects or shift-share design to properly isolate the causal effect of the local competitiveness shocks. Ideas 2, 3, and 4 suffer from fatal data dilution, missing variables, or lack of novelty, and should be discarded.

---

## Grok 4.1 Fast

**Tokens:** 6855

### Rankings

**#1: Idea 1: The Decade of Decline: How the Austerity Pay Squeeze on Teachers Shaped Student Achievement in England**
- **Score**: 76/100
- **Strengths**: Leverages a unique UK institutional shock (national pay cap amid varying local markets) with a full observable mechanism chain (pay competitiveness → vacancies/retention → student outcomes) using universe-level admin data across 14+ years. Doubly robust estimation provides credible handling of confounding, and all data is publicly verified as accessible at scale.
- **Concerns**: LA-level aggregation (~150-370 units) risks ecological fallacy and underpowered inference if heterogeneity is high; lacks explicit pre-trends test since it's not a DiD design.
- **Novelty Assessment**: High—while teacher pay competitiveness exists in health (Britton & Propper) and PRP reforms (Burgess et al.), no papers exploit the full austerity decade for student outcomes or apply DR-AIPW to this channel at LA scale.
- **Top-Journal Potential**: Medium-High. A top-5 journal could find the austerity "hidden cost" framing exciting as a first-order challenge to fiscal consolidation narratives, with a clear causal chain and policy counterfactual (e.g., "8% real pay cut cost X points in attainment"); aligns with winners showing mechanism traces and universe-scale bounds on tradeoffs.
- **Identification Concerns**: DR-AIPW relies on correct specification of either propensity or outcome models, vulnerable to unobservables like LA-specific shocks (e.g., housing costs omitted); limited treated units and no parallel trends test weaken exogeneity claims relative to DiD.
- **Recommendation**: PURSUE (conditional on: adding school-level falsification tests; Rosenbaum sensitivity expanded to quantify bias bounds)

**#2: Idea 2: Teaching the STEM Gap: Training Bursary Shocks, Recruitment Quality, and Subject-Level Student Outcomes**
- **Score**: 68/100
- **Strengths**: Exploits sharp, subject-specific bursary variation (national policy changes of £3-5k) to trace recruitment to STEM-specific outcomes, with large school-level data (~5k schools × cohorts) enabling precise estimates. Policy relevance is strong for addressing chronic STEM teacher shortages.
- **Concerns**: 3-4 year lag introduces noise from trainee attrition or school matching; cross-subject spillovers within schools (e.g., better physics teachers freeing resources) confound subject isolation.
- **Novelty Assessment**: Medium-high—prior work (Allen et al.) stops at recruitment volumes; extending to student outcomes via DR is new, though bursary effects on quantity are well-trodden.
- **Top-Journal Potential**: Medium. Top field journals (AEJ:EP) might bite on STEM gap stakes with a recruitment-to-attainment chain, but lacks puzzle/counterintuitive bite or welfare pivot (e.g., "bursaries boost quantity but dilute quality?"); risks "competent ATE" rejection without belief-changing null or tradeoff.
- **Identification Concerns**: Bursary changes may respond endogenously to prior shortages/outcomes; school fixed effects needed but omitted, and lag dilutes first stage (recruitment numbers observable but not guaranteed to classroom quality).
- **Recommendation**: CONSIDER (conditional on: verifying first-stage recruitment-to-classroom link; school FE robustness)

**#3: Idea 5: The Competitiveness Cliff: Teacher Pay, Local Labor Markets, and the Widening Achievement Gap in England**
- **Score**: 64/100
- **Strengths**: Builds directly on Idea 1's strong variation/data but adds high-policy equity angle (FSM gap), with same DR-AIPW credibility and FSM breakdowns readily available in DfE data.
- **Concerns**: Narrower than Idea 1 (just gap outcome, no vacancies chain), making it derivative; LA-level gap changes could reflect pupil composition shifts unrelated to teachers.
- **Novelty Assessment**: Medium—relies on same austerity shock as Idea 1, with inequality lens adding marginal novelty but no unique mechanism or data.
- **Top-Journal Potential**: Medium. Inequality framing elevates policy stakes, but top-5 unlikely without standalone puzzle (e.g., "pay hurts poor areas less?"); reads as narrower extension of competitiveness literature, missing scale-diagnostic flair.
- **Identification Concerns**: Same DR pitfalls as Idea 1, plus baseline gap conditioning may not capture dynamic selection (e.g., high-gap LAs attract worse replacements); outcome misalignment if gaps driven by non-teacher factors.
- **Recommendation**: CONSIDER

**#4: Idea 4: Teach First Meets Doubly Robust: The Causal Effect of High-Performing Graduates on Disadvantaged Schools**
- **Score**: 54/100
- **Strengths**: Long 20-year panel allows long-run effects (post-placement persistence), building on prior work with modern DR and sensitivity tools; targets equity via disadvantaged schools.
- **Concerns**: Data access for school-level placements is uncertain (FOI/restricted NPD likely needed); selection into Teach First areas/schools undermines exogeneity.
- **Novelty Assessment**: Low-medium—directly extends Allen & Allnutt (2017) PSM with DR and recent data; no new shock or setting.
- **Top-Journal Potential**: Low. Familiar program evaluation without counterintuitive mechanism or first-order pivot; appendix patterns flag "technically competent" extensions of existing papers as modal losses.
- **Identification Concerns**: Eligibility confounds treatment (deprived schools in regions); no pre-placement trends test, and participant exit after 2 years muddies sustained effects.
- **Recommendation**: SKIP (data access too uncertain; pursue only with confirmed NPD partnership)

**#5: Idea 3: Deregulation Without Deviation: Academy Pay Freedom and the Paradox of Unused Autonomy**
- **Score**: 48/100
- **Strengths**: Puzzle of unused autonomy (87% stick to national scales) offers descriptive contribution on coordination failures; school-level outcomes linkable via URN.
- **Concerns**: Core treatment (pay deviation) unobservable publicly, forcing noisy proxies (e.g., SWC pay anomalies); severe selection into deviation/academies.
- **Novelty Assessment**: Medium—the paradox is fresh, but academy effects broadly studied; data gap kills execution.
- **Top-Journal Potential**: Low-Medium. Puzzle could hook if executed (e.g., "autonomy unused due to risk?"), but data flaws trigger "measurement mismatch" rejections; lacks causal chain or stakes.
- **Identification Concerns**: Self-selection into deviation (better schools experiment); proxy treatment dilutes power, with no pre-conversion DiD possible without clean indicator.
- **Recommendation**: SKIP

### Summary
This batch is solid but mostly "competent not exciting"—Ideas 1 and 2 stand out for novel shocks, mechanisms, and data scale addressing first-order questions (austerity costs, STEM gaps), while 3-5 falter on data access and derivativeness. Pursue Idea 1 first for its top-journal arc potential; Idea 2 as strong follow-up if STEM recruitment first-stage holds. Overall quality skews mid-tier (average ~62), typical for policy admin data without boundary-pushing identification.

