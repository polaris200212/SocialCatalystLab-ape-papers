# Research Idea Ranking

**Generated:** 2026-03-03T17:53:48.310030
**Models:** GPT-5.2, Gemini 3.1 Pro, Grok 4.1 Fast
**Reasoning:** high

## Comparison Table

| Idea | GPT-5.2 | Gemini 3.1 Pro | Grok 4.1 Fast |
|------|------|------|------|
| The Price of Austerity: Council Tax Supp... | PURSUE (77) | — | PURSUE (78) |
| Conditioned to Work? Universal Credit's ... | CONSIDER (66) | — | CONSIDER (68) |
| The Training Tax: Britain's Apprenticesh... | CONSIDER (63) | — | SKIP (55) |
| Zones of Employment? Staggered Designati... | CONSIDER (58) | — | SKIP (48) |
| The Benefit Cap and the Geography of Wor... | SKIP (54) | — | CONSIDER (62) |

---

## GPT-5.2

**Tokens:** 7364

### Rankings

**#1: The Price of Austerity: Council Tax Support Localisation and Low-Income Employment**
- Score: **77/100**
- Strengths: Large-N, policy-induced cross-area variation with a clean national-to-local break and a long common-policy pre-period; outcomes (claimant counts, arrears/collections) are tightly linked to the reform’s incentives and hardship channels. The design naturally supports an event-study + mechanism chain (CTS cuts → arrears/collections → claimant dynamics/employment).
- Concerns: LA scheme choice is not random (politics, fiscal stress, local labor market trends), so “quasi-random” needs to be earned with strong pre-trend diagnostics and covariate/stacked designs; claimant count is an imperfect employment measure and may move for administrative reasons.
- Novelty Assessment: **High**. Surprisingly thin peer-reviewed causal literature on CTS localisation specifically; IFS/report evidence exists but doesn’t exhaust modern panel/event-study designs.
- Top-Journal Potential: **Medium–High** if you (i) document clear first-stage bite (liability increases for a defined group), (ii) trace mechanisms (arrears/collection, hardship) alongside labor supply, and (iii) quantify welfare-relevant tradeoffs (employment gains vs. financial distress). Otherwise it risks reading as “competent DiD on a UK reform.”
- Identification Concerns: Main threats are **policy endogeneity** (cuts correlated with unobserved local shocks) and **coincident 2013 reforms** (Benefit Cap, UC pilots, local austerity). Needs robustness to differential trends (HonestDiD-style sensitivity; rich pre-trends; controls for broader spending cuts; placebo outcomes/groups).
- Recommendation: **PURSUE (conditional on: reconstructing treatment intensity transparently from administrative taxbase data; a pre-analysis plan emphasizing parallel trends/sensitivity; adding a mechanism/first-stage battery—arrears/collections, CTR caseload, minimum payments actually collected)**

---

**#2: Conditioned to Work? Universal Credit's In-Work Regime and Labour Supply at the Intensive Margin**
- Score: **66/100**
- Strengths: The question is genuinely important and under-answered: conditioning *employed* claimants is a distinctive institutional feature with big implications for optimal policy and “work-first” vs. “progression” models. Staggered rollout offers a plausible design starting point.
- Concerns: Outcomes proposed (ASHE/APS at LA level) are likely too coarse/noisy to detect an intensive-margin effect targeted at a subset of workers; “Full Service UC” bundled multiple changes beyond in-work conditionality, making the mechanism attribution hard without sharper data.
- Novelty Assessment: **Medium–High**. UC is heavily studied, but *isolating in-work conditionality’s intensive-margin effects* is less saturated; still, you’re operating in a crowded UC space.
- Top-Journal Potential: **Medium** unless you can convincingly isolate the in-work conditionality channel and show a surprising mechanism (e.g., hours progression vs. job churn vs. sanctions/mental health). With only annual area-level earnings/hours, it risks being “diluted-by-construction.”
- Identification Concerns: **Bundling/compound treatment** (Full Service ≠ in-work conditionality only), and **rollout endogeneity** (administrative readiness may correlate with local capacity/conditions). Needs compelling falsification tests and, ideally, claimant-level admin outcomes.
- Recommendation: **CONSIDER (conditional on: obtaining claimant-level administrative data on earnings/hours/sanctions or HMRC RTI-linked measures; mapping treatment at Jobcentre catchment—not LA—cleanly; explicitly separating “UC exposure” from “in-work conditionality exposure”)**

---

**#3: The Training Tax: Britain's Apprenticeship Levy and the Restructuring of Youth Employment**
- Score: **63/100**
- Strengths: Clear, first-order policy with a sharp national start date and rich administrative outcomes (apprenticeship starts by level/age/sector). Geographic exposure based on pre-levy firm-size structure is intuitive and can generate strong heterogeneous predictions.
- Concerns: The proposed Bartik/shift-share design is vulnerable to standard exposure endogeneity critiques, and the levy coincided with other apprenticeship system changes (standards, funding rules), complicating attribution. Also, LA exposure based on firm size may not map cleanly to where apprentices are trained/registered.
- Novelty Assessment: **Medium**. There is meaningful UK policy/gray literature and some academic work; less saturation than US training tax literatures, but not a blank slate.
- Top-Journal Potential: **Medium–Low** unless you can (i) convincingly validate the identifying variation (Goldsmith-Pinkham/Sorkin/Swift-style diagnostics; alternative exposure definitions), and (ii) deliver a mechanism story beyond starts (composition, firm behavior, displacement from youth to adult, impacts on wages/employment trajectories).
- Identification Concerns: **Bartik validity** (exposure correlated with differential trends) and **contemporaneous reforms**. Needs strong pre-trend evidence, placebo reforms, and robustness to alternative instruments/exposure shares.
- Recommendation: **CONSIDER (conditional on: a serious Bartik validity/diagnostics section; exploiting additional discontinuities—e.g., near-threshold firms if any microdata access emerges; and explicitly netting out contemporaneous apprenticeship standards/funding reforms)**

---

**#4: Zones of Employment? Staggered Designation and Local Labour Market Effects of England's Enterprise Zones**
- Score: **58/100**
- Strengths: Spatially precise policy boundaries allow designs that can be more compelling than generic area DiD, and displacement questions (inside vs. nearby) are policy-relevant. LSOA/workplace employment data can support granular mapping.
- Concerns: Enterprise/empowerment zone-type policies are a well-trodden literature and reviewers will be skeptical of “yet another zone evaluation” unless identification is unusually sharp. EZ selection is highly endogenous (targeted areas), and 48 zones is not that many for credible inference without a boundary-based strategy.
- Novelty Assessment: **Low–Medium**. UK EZs specifically are less studied than US zones, but the broader question/design space is crowded.
- Top-Journal Potential: **Low–Medium** unless you pivot to a design that clearly beats selection (e.g., difference-in-discontinuities at boundaries with tight bandwidths, or compelling within-zone vs. near-zone comparisons) and deliver a strong displacement/general equilibrium contribution.
- Identification Concerns: **Selection into treatment** and **spillovers** (which also break SUTVA but can be studied if designed explicitly). Matching alone will look weak; you need quasi-experimental boundary logic.
- Recommendation: **CONSIDER (conditional on: centering the paper on boundary-based identification and displacement; pre-registering bandwidth/functional-form choices; showing strong balance/pre-trends in narrow border neighborhoods)**

---

**#5: The Benefit Cap and the Geography of Work Incentives**
- Score: **54/100**
- Strengths: Very high policy salience; the cap has clear welfare stakes and the 2016 reduction creates a second shock that could, in principle, strengthen inference. The mobility-versus-employment decomposition is a good framing.
- Concerns: The 2013 introduction collides with other major 2013 reforms (including CTS localisation), and an exposure-based LA design risks severe measurement mismatch because the cap affects a small, selected subset while outcomes proposed are largely aggregate. Data access via Stat-Xplore/API and constructing credible “cap bite” intensity are nontrivial.
- Novelty Assessment: **Medium**. There is substantial government/descriptive evaluation and some academic attention to caps/housing; novelty hinges on whether you can deliver a clean causal decomposition with modern methods.
- Top-Journal Potential: **Low–Medium** unless you can get closer to the treated population (capped households) and cleanly separate channels (work entry vs. moves vs. rent renegotiation). With aggregate LA outcomes, it is likely to be viewed as under-identified/diluted.
- Identification Concerns: **Confounding policy timing (2013)**, **treatment measurement**, and **outcome mismatch**. The 2016 reform helps, but only if you design around it as the primary event with strong pre-trends and a clear first stage in capped caseload intensity.
- Recommendation: **SKIP (unless you can: focus primarily on the 2016 cut; obtain household-level capped outcomes; and credibly net out contemporaneous local reforms/austerity trends)**

---

### Summary

This is a strong batch in terms of policy relevance and availability of administrative outcomes, but several ideas risk “diluted-by-construction” outcomes or exposure-based identification that won’t satisfy top-journal skepticism without sharper designs. **Idea 1 (CTS localisation)** is the clear first project to pursue because it combines relative novelty, many treated units, a long common pre-period, and a natural mechanism chain; **Idea 2** becomes very attractive only if you can secure claimant-level admin data to truly isolate in-work conditionality.

---

## Gemini 3.1 Pro

**Tokens:** 5667

- **Rank**: 1
- **Score**: 85/100
- **Strengths**: Exploits a sharp, quasi-random policy shock with clear geographic variation and a long pre-period, addressing a first-order policy question about the employment effects of welfare conditionality. The continuous-treatment DiD design is robust and the data is readily available.
- **Concerns**: The construction of the treatment variable (minimum payment %) may require significant manual effort if relying on blog posts/PDFs. The existence of a prior IFS report finding null effects means the paper must clearly demonstrate why modern DiD methods yield different and more reliable conclusions.
- **Novelty Assessment**: High. While the policy has been studied descriptively, there is no peer-reviewed academic literature using modern causal inference methods to evaluate its employment effects.
- **Top-Journal Potential**: High. The question of whether financial penalties on non-working benefit claimants increase employment or merely create financial distress is a central debate in welfare economics. A well-executed study with a clear causal chain and robust identification could be highly influential.
- **Identification Concerns**: The main threat is the potential for unobserved time-varying confounders correlated with the intensity of the CTS cut. However, the long pre-period and the ability to test for parallel trends mitigate this risk.
- **Recommendation**: PURSUE

- **Rank**: 2
- **Score**: 75/100
- **Strengths**: Addresses a highly contentious and understudied aspect of Universal Credit (in-work conditionality) using a staggered rollout design. The policy variation is driven by administrative capacity, providing plausible exogeneity.
- **Concerns**: The reliance on annual ASHE data limits the precision of the event-study analysis. The sample size of the APS data at the LA level needs to be verified to ensure sufficient power.
- **Novelty Assessment**: High. No published study isolates the in-work conditionality mechanism using the staggered rollout.
- **Top-Journal Potential**: Medium. The topic is highly relevant, but the data limitations (annual frequency) might hinder the ability to provide a definitive and precise causal estimate, which is often required for top-tier journals.
- **Identification Concerns**: The main threat is the potential for unobserved time-varying confounders correlated with the rollout timing. However, the administrative nature of the rollout mitigates this risk.
- **Recommendation**: CONSIDER (conditional on verifying APS sample size and exploring alternative data sources for higher frequency analysis)

- **Rank**: 3
- **Score**: 65/100
- **Strengths**: Evaluates a significant policy change (Apprenticeship Levy) with clear implications for youth employment and skills strategy. The shift-share geographic approach is novel in this context.
- **Concerns**: The shift-share design is susceptible to mechanically endogenous exposure measures. The simultaneous apprenticeship standards reform complicates identification, making it difficult to isolate the effect of the levy alone.
- **Novelty Assessment**: Medium. While the specific geographic approach is new, the policy has been studied using firm-level matching.
- **Top-Journal Potential**: Low. The identification challenges (simultaneous reforms, potential endogeneity of exposure) and the potential for a "competent but not exciting" finding limit its appeal for top-tier journals.
- **Identification Concerns**: The simultaneous apprenticeship standards reform is a major threat to identification. The shift-share design also requires careful justification of the exogeneity of the exposure measure.
- **Recommendation**: SKIP

- **Rank**: 4
- **Score**: 60/100
- **Strengths**: Uses modern staggered DiD and LSOA-level microdata to evaluate Enterprise Zones, including a novel displacement analysis.
- **Concerns**: The small number of treated clusters (48 zones) is borderline for reliable inference. Selection into EZ designation is endogenous, as deprived areas are targeted.
- **Novelty Assessment**: Medium. The policy has been evaluated before, but the use of modern methods and LSOA-level data is an improvement.
- **Top-Journal Potential**: Low. The identification challenges (endogenous selection, small number of clusters) and the potential for a "competent but not exciting" finding limit its appeal for top-tier journals.
- **Identification Concerns**: Endogenous selection into EZ designation is a major threat. The small number of clusters also raises concerns about the reliability of the inference.
- **Recommendation**: SKIP

- **Rank**: 5
- **Score**: 55/100
- **Strengths**: Evaluates a significant policy (Benefit Cap) with clear implications for work incentives and residential mobility. The exposure-based DiD design is a reasonable approach.
- **Concerns**: The coincidence of the Benefit Cap introduction with the CTS reform (Idea 1) makes it very difficult to isolate the effect of the cap. The limited pre-treatment period also hinders the ability to test for parallel trends.
- **Novelty Assessment**: Medium. The policy has been studied descriptively, but not with modern causal inference methods exploiting geographic variation.
- **Top-Journal Potential**: Low. The identification challenges (coinciding reforms, limited pre-period) make it unlikely to meet the standards of top-tier journals.
- **Identification Concerns**: The coincidence of the Benefit Cap and CTS reforms is a fatal flaw for identification. The limited pre-period also prevents robust testing of parallel trends.
- **Recommendation**: SKIP

### Summary

This batch of research ideas presents a mix of promising and challenging proposals. Idea 1 stands out as the most promising, offering a sharp policy shock, robust identification, and high policy relevance. Idea 2 is also worth considering, provided the data limitations can be addressed. The remaining ideas suffer from significant identification challenges or lack the novelty and potential for a top-tier publication. I recommend pursuing Idea 1 first, as it has the highest potential for a significant contribution to the literature and policy debate.

---

## Grok 4.1 Fast

**Tokens:** 6149

### Rankings

**#1: The Price of Austerity: Council Tax Support Localisation and Low-Income Employment**
- **Score**: 78/100
- **Strengths**: Exceptionally novel with clean quasi-experimental variation from devolution creating sharp differences in effective tax penalties on non-employment across similar LAs; strong potential for a causal chain (financial penalties → employment response vs. distress arrears) addressing core welfare reform debates with global relevance.
- **Concerns**: Treatment variable construction from scattered PDFs/blogs adds upfront effort, though fallbacks exist; must credibly explain deviation from IFS null via modern DiD/event-study advantages.
- **Novelty Assessment**: Highly novel—essentially no peer-reviewed causal literature; only one weak IFS report using cross-section without panel/DiD.
- **Top-Journal Potential**: High. Challenges conventional wisdom on work penalties (employment boost or just distress?) with first-order policy stakes, mechanism chain (employment → collections vs. arrears), and "universe" LA-month data enabling precise bounds; fits winners like policy bite tests with verified first stage.
- **Identification Concerns**: Parallel trends highly testable with 5+ identical pre-years; minor risk of LA heterogeneity in unobservables, but binary split (62 protected vs. 264 cut) and continuous intensity provide multiple diagnostics.
- **Recommendation**: PURSUE (conditional on: constructing reliable continuous treatment from DLUHC/Entitledto data; piloting event-study to confirm IFS deviation)

**#2: Conditioned to Work? Universal Credit's In-Work Regime and Labour Supply at the Intensive Margin**
- **Score**: 68/100
- **Strengths**: Isolates novel in-work conditionality mechanism via clean staggered rollout across 300 Jobcentres; targets intensive margin (hours progression) in contentious UC feature with policy relevance for employed claimants.
- **Concerns**: Annual ASHE/APS data limits event-study precision and power for short-run dynamics; UC literature saturation (even if not exact mechanism) dilutes excitement.
- **Novelty Assessment**: Moderately novel—no published causal study on in-work rollout specifically, though UC has several adjacent papers (e.g., mental health, entrepreneurship).
- **Top-Journal Potential**: Medium. Interesting substitution (conditionality on employed → hours?), but risks "competent ATE" without strong mechanism chain or belief pivot; top-5 would need counterintuitive findings and overpowered null bounds given data frequency limits.
- **Identification Concerns**: Rollout plausibly exogenous (IT/capacity-driven), good pre-period, ample clusters; but LA aggregation from Jobcentres may dilute treatment if spillovers, and annual outcomes weaken pre-trend tests.
- **Recommendation**: CONSIDER (if monthly claimant transitions can proxy hours for event-study)

**#3: The Benefit Cap and the Geography of Work Incentives**
- **Score**: 62/100
- **Strengths**: Geographic exposure variation enables decomposition of employment vs. mobility effects (strong mechanism chain); second 2016 shock aids verification, with high policy relevance for cap design.
- **Concerns**: Severe confounding with 2013 CTS reform (Idea 1) in same rollout window; limited pre-period weakens trends tests.
- **Novelty Assessment**: Moderately novel—DWP descriptives exist, but no rigorous geographic DiD exploiting cap bite variation.
- **Top-Journal Potential**: Medium. Mobility-employment tradeoff has welfare stakes, but coincides with other shocks and lacks "first-order" punch without clean separation; more AEJ Policy than top-5.
- **Identification Concerns**: Coinciding CTS localisation confounds 2013 shock (both hit low-income LAs simultaneously); exposure endogenous to rents/household structure, requiring strong controls/placebos.
- **Recommendation**: CONSIDER (conditional on: fully disentangling CTS via leads/lags or subgroup analysis)

**#4: The Training Tax: Britain's Apprenticeship Levy and the Restructuring of Youth Employment**
- **Score**: 55/100
- **Strengths**: Continuous exposure via pre-levy large-firm share allows composition analysis (levels, age, firm size); good data and long pre-period.
- **Concerns**: Shift-share exposure mechanically endogenous (correlates with youth employment baselines); simultaneous standards reform muddies attribution.
- **Novelty Assessment**: Somewhat novel—no top-journal causal work, but CVER paper covers firm-level effects; geographic shift-share approach new but familiar design.
- **Top-Journal Potential**: Low. Composition shifts interesting but niche skills policy without clear counterintuitive mechanism or field pivot; appendix flags shift-share as dilution risk, reading as "competent but unsurprising."
- **Identification Concerns**: Bartik-style exposure endogenous by construction (high large-firm LAs have more apprentices baseline); reform overlap violates clean shock.
- **Recommendation**: SKIP

**#5: Zones of Employment? Staggered Designation and Local Labour Market Effects of England's Enterprise Zones**
- **Score**: 48/100
- **Strengths**: Staggered rounds and LSOA boundaries enable displacement tests (new angle); microdata feasible.
- **Concerns**: Only 48 zones (few clusters even at LSOA); endogenous selection (deprived areas targeted) hard to match away.
- **Novelty Assessment**: Low—multiple prior UK evaluations (What Works, Chaudhary & Potter); EZs globally overstudied.
- **Top-Journal Potential**: Low. Well-trodden place-based policy with null/displacement risks; lacks stakes or surprise, fits "narrow administrative margin" losses despite modern DiD.
- **Identification Concerns**: Endogenous designation (non-random); few treated units limit inference/power; short pre-period for Round 1.
- **Recommendation**: SKIP

### Summary
This is a solid batch with 1-2 genuinely promising ideas leveraging recent UK welfare shocks, but most suffer from identification confounds, data limits, or saturation in related literatures—typical of policy DiD proposals. Prioritize Idea 1 for its novelty, clean ID, and top-journal arc; Idea 2 as strong backup if hours data proves viable. Skip 4/5 as incremental on crowded topics.

