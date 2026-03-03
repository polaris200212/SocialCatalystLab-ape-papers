# Research Idea Ranking

**Generated:** 2026-03-03T17:43:28.372654
**Models:** GPT-5.2, Gemini 3.1 Pro, Grok 4.1 Fast
**Reasoning:** high

## Comparison Table

| Idea | GPT-5.2 | Gemini 3.1 Pro | Grok 4.1 Fast |
|------|------|------|------|
| Who Captures a Tax Cut? Property Price C... | PURSUE (82) | PURSUE (88) | PURSUE (88) |
| Does Social Housing Enforcement Reshape ... | CONSIDER (68) | SKIP (55) | SKIP (58) |
| Do Priority Schools Help or Stigmatize? ... | CONSIDER (60) | CONSIDER (68) | CONSIDER (72) |
| Taxe Foncière Hikes and Housing Market D... | PURSUE (45) | SKIP (35) | SKIP (35) |

---

## GPT-5.2

**Tokens:** 6245

### Rankings

**#1: Who Captures a Tax Cut? Property Price Capitalization and Fiscal Substitution from France's €22 Billion Residence Tax Abolition**
- **Score: 82/100**
- **Strengths:** First-order fiscal reform at national scale with “universe” transactions and rich institutional features (staggering, compensation, and a clean within-tax placebo via secondary residences). The ability to decompose *gross capitalization* (TH relief) vs *offsetting capitalization* (TF hikes) is exactly the kind of mechanism chain top journals like (policy → local fiscal response → incidence in asset prices).
- **Concerns:** Pre-reform TH rates are not randomly assigned; they proxy for local amenities, spending preferences, housing-demand trends, and political economy—so “continuous intensity” DiD risks confounding unless you add very strong diagnostics/design augmentations. Anticipation is likely (announcement/legislation pre-2018), and capitalization may occur before the first mechanical tax relief.
- **Novelty Assessment:** **High** (especially in English-language peer-reviewed economics). Tax capitalization is heavily studied in the US, but this *specific* French reform + fiscal substitution decomposition + primary/secondary-residence placebo is not close to “100 existing papers.”
- **Top-Journal Potential:** **High/Medium.** The scale and institutional richness can support a definitive incidence statement and a compelling substitution mechanism; framed as “who benefits from large tax cuts when local governments can re-optimize,” this is top-field-journal and potentially top-5 viable.
- **Identification Concerns:** The key threat is **non-parallel trends correlated with baseline TH rates** (and with tourism/second-home intensity). I would want (i) border-pair or neighboring-commune specifications, (ii) explicit anticipation/event-timing tests around announcement dates, and (iii) a tight placebo battery using secondary-residence-heavy markets and other non-affected outcomes/segments.
- **Recommendation:** **PURSUE (conditional on: convincing pre-trends/anticipation handling; a design add-on beyond “intensity DiD” such as border discontinuities or rich local controls interacted with time; a clear separation of “tax cut incidence” vs “local fiscal response” in the causal chain).**

---

**#2: Does Social Housing Enforcement Reshape Cities? Evidence from France's 2013 SRU Penalty Tripling**
- **Score: 68/100**
- **Strengths:** Big policy stakes (housing supply, segregation/sorting, spatial equilibrium) with outcomes that matter and can be traced through a mechanism chain (penalties → construction/allocations → prices → composition). The 2013 change is a plausible “shock” that can be connected to global debates on mandates/inclusionary zoning.
- **Concerns:** The proposed DiD contrast (20–25% vs >25%) is vulnerable: communes near thresholds differ systematically and may already be on different trajectories (politics, land scarcity, urban growth), making parallel trends questionable. Treatment is also fuzzy (pay fines vs build; prefect intervention is selective), so you must be explicit about ITT vs TOT and the enforcement selection process.
- **Novelty Assessment:** **Medium.** SRU is discussed and studied (often descriptively), and inclusionary/zoning mandates have a large literature; the *2013 penalty tripling + DVF capitalization/sorting* angle is less saturated, but not wholly untouched conceptually.
- **Top-Journal Potential:** **Medium.** If you can credibly show enforcement meaningfully changed construction and segregation (not just small price movements), it becomes a belief-changing paper; without a strong design upgrade it risks reading as “competent DiD on a politically chosen policy margin.”
- **Identification Concerns:** Biggest risks are **endogenous initial social-housing shares** and **selective enforcement (“carence”)** correlated with unobservables. A more credible route would be a **triple-diff** (above vs below population threshold × below vs above 25% × pre/post) and/or designs exploiting **mechanical penalty schedule changes** and rule-based eligibility.
- **Recommendation:** **CONSIDER (upgrade identification: triple-diff using eligibility thresholds; pre-trend discipline; clear first-stage on construction/enforcement).**

---

**#3: Do Priority Schools Help or Stigmatize? Property Price Effects of France's 2015 Education Zone Reform**
- **Score: 60/100**
- **Strengths:** The “resources vs stigma” sign test (enter vs exit REP/REP+) is a nice competing-mechanisms setup, and micro-distance gradients are intuitive for the housing market. Policymakers care about unintended consequences of labeling schools/neighborhoods.
- **Concerns:** School priority status is intensely targeted using socio-economic metrics; even with a national redraw, entry/exit is likely correlated with local trends (gentrification/decline), which is exactly what moves prices. Data-wise, with DVF starting in 2014 you have a short clean pre-period for a 2015 reform, making parallel trends hard to validate and leaving you exposed to “recent policy, short window” skepticism.
- **Novelty Assessment:** **Medium/Low.** Many papers study school quality/catchment boundaries and house prices; the REP/REP+ redraw is newer and France-specific, but the core question (school labeling/resources → prices) is well-trodden.
- **Top-Journal Potential:** **Low/Medium.** Could land in a good field journal if the design becomes quasi-experimental (e.g., rule-based discontinuities), but as a standard DiD around targeted schools it will look familiar and identification-challenged to top-5 editors.
- **Identification Concerns:** Primary threats are **selection into treatment** (designation based on changing deprivation) and **insufficient pre-period**. A more credible design would leverage **assignment-rule discontinuities** (if an index/threshold exists) or **boundary-based comparisons** (very near treated/untreated school catchment edges) rather than simple treated-vs-control neighborhoods.
- **Recommendation:** **CONSIDER (only if you can anchor treatment in a transparent assignment rule with discontinuities, or build a boundary/discontinuity design; otherwise it’s likely to be viewed as confounded).**

---

**#4: Taxe Foncière Hikes and Housing Market Dynamics After France's Local Tax Reform**
- **Score: 45/100**
- **Strengths:** Clear outcome mapping (property tax changes should capitalize into prices/volumes) and feasible data. Could be a useful descriptive complement.
- **Concerns:** As posed, it’s both **subsumed by Idea 1** (fiscal substitution) and weakly identified: big discrete TF hikes are typically endogenous (fiscal stress, spending shocks, local politics), so “event study around hikes” is a classic selection-on-trends pitfall. Novelty is low relative to the large existing property-tax capitalization literature.
- **Novelty Assessment:** **Low.** This is a standard question with many precedents; the France setting is a modest twist, not a new object.
- **Top-Journal Potential:** **Low.** Reads as “competent but not exciting” unless it is tightly embedded in a larger incidence/substitution framework (which is Idea 1).
- **Identification Concerns:** **Endogenous timing and magnitude of tax hikes** (reverse causality with prices/volumes, omitted fiscal shocks). Hard to rescue without an instrument or institutional discontinuity.
- **Recommendation:** **SKIP (as standalone). Fold into Idea 1’s mechanism section if pursued.**

---

### Summary

This is a strong batch in terms of policy salience and data access, but only one idea (Idea 1) is both genuinely novel and plausibly top-journal with credible identification *if* you add design features to neutralize baseline-rate confounding and anticipation. I would start with Idea 1 immediately, and keep Idea 3 as the secondary pipeline project contingent on a threshold-based triple-diff/RD-style identification upgrade.

---

## Gemini 3.1 Pro

**Tokens:** 7529

Here is my evaluation of the proposed research ideas, ranked from most to least promising, applying the strict criteria of top-tier economics publishing and policy relevance.

### Rankings

**#1: Who Captures a Tax Cut? Property Price Capitalization and Fiscal Substitution from France's €22 Billion Residence Tax Abolition**
- **Score**: 88/100
- **Strengths**: This proposal leverages a massive, first-order policy shock (€22B) using universe-level administrative data, perfectly aligning with the editorial preference for scale as scientific content. The built-in placebo (secondary residences) and the mechanism chain (tax cut → local fiscal substitution → net capitalization) elevate this from a simple ATE paper to a comprehensive study of fiscal federalism.
- **Concerns**: The continuous treatment (pre-reform TH rates) might be correlated with unobserved local economic trajectories, meaning communes with high TH rates might have been on different property price trends regardless of the reform. 
- **Novelty Assessment**: High. While property tax capitalization is a mature literature (Oates, Lutz), studying a total abolition of this magnitude, combined with the unstudied local fiscal substitution mechanism, is highly novel. The lack of English-language, peer-reviewed literature on this specific, massive reform is a glaring gap waiting to be filled.
- **Top-Journal Potential**: High. A top-5 journal would find this exciting because it addresses a first-order welfare question with a compelling causal chain and a bulletproof placebo design. It moves beyond "did prices go up?" to "who actually captures the incidence of a national tax cut when local governments can strategically respond?"
- **Identification Concerns**: The primary threat is that pre-reform TH rates (the continuous treatment) are endogenous to local economic shocks; however, the secondary residence placebo provides a highly credible defense against this exact cosmopolitan confounding.
- **Recommendation**: PURSUE

**#2: Do Priority Schools Help or Stigmatize? Property Price Effects of France's 2015 Education Zone Reform**
- **Score**: 68/100
- **Strengths**: The dual treatment arms (entering vs. exiting REP status) provide a highly elegant way to decompose the competing mechanisms of resource gains versus neighborhood stigma. The sharp 2015 implementation allows for a clean temporal break.
- **Concerns**: School quality capitalization is a heavily saturated literature, and spatial DiDs around school boundaries often suffer from severe sorting dynamics and SUTVA violations (spillovers to nearby control neighborhoods).
- **Novelty Assessment**: Medium. The specific 2015 reform hasn't been studied with DVF data, but the broader question of school zoning and property prices has hundreds of existing papers (e.g., Black 1999, Figlio & Lucas 2004). 
- **Top-Journal Potential**: Medium. While technically competent and featuring a clever mechanism test (entering vs. exiting), it risks falling into the modal rejection category of "competent but not exciting." To hit a top-5, it would need to fundamentally challenge how we view place-based policies, perhaps by proving that stigma entirely crowds out resource benefits.
- **Identification Concerns**: Endogenous boundary drawing is a major threat; the ministry did not randomly assign REP status, they assigned it based on deteriorating local demographics, which likely have their own pre-trends in property prices.
- **Recommendation**: CONSIDER (conditional on: proving strict parallel trends in the pre-period and successfully geocoding the exact school catchment boundaries, not just radii).

**#3: Does Social Housing Enforcement Reshape Cities? Evidence from France's 2013 SRU Penalty Tripling**
- **Score**: 55/100
- **Strengths**: The policy question is highly relevant globally (inclusionary zoning), and exploiting the heterogeneity in compliance (paying fines vs. building) offers an interesting look at municipal strategic behavior.
- **Concerns**: The proposed DiD design is fundamentally flawed because communes hovering at 20-25% social housing are politically, demographically, and economically distinct from those already above 25%. This is a classic setup for an identification failure due to divergent pre-trends.
- **Novelty Assessment**: Medium-Low. The SRU law is well-known and heavily studied descriptively in France. While a causal approach to the 2013 penalty tripling is somewhat new, the general literature on social housing mandates is quite crowded.
- **Top-Journal Potential**: Low. This reads as a standard policy evaluation that would likely yield noisy or endogenous results. It lacks the surprising mechanism or "first-order stakes" required to break into top general-interest journals, placing it firmly in the "competent but not exciting" (or potentially flawed) category.
- **Identification Concerns**: Severe selection bias in the control group. Communes that historically built >25% social housing are on entirely different urban trajectories than those forced to build by the mandate. *Note: The 3,500 population threshold mentioned in the prompt would make a much better RDD design than the proposed DiD.*
- **Recommendation**: SKIP (unless completely redesigned around the 3,500 population threshold RDD).

**#4: Taxe Foncière Hikes and Housing Market Dynamics After France's Local Tax Reform**
- **Score**: 35/100
- **Strengths**: Uses high-quality, universe-level administrative data (DVF).
- **Concerns**: Tax rate hikes are highly endogenous to local financial distress, infrastructure investments, or demographic shifts, making a standalone event-study highly susceptible to omitted variable bias. Furthermore, this is entirely redundant to the mechanism analysis in Idea 1.
- **Novelty Assessment**: Low. Property tax capitalization is one of the oldest topics in urban economics.
- **Top-Journal Potential**: Low. A standalone paper estimating an ATE on an endogenous local tax hike without a broader structural or policy narrative will not survive peer review at a top journal. It lacks an exogenous shock.
- **Identification Concerns**: Fatal endogeneity. Communes that hike taxes by 52% (like Paris) are doing so because of severe underlying fiscal or macroeconomic shocks, meaning the "control" communes with stable rates are not valid counterfactuals.
- **Recommendation**: SKIP (Merge the data work into Idea 1 as a mechanism test).

### Summary

Overall, this batch contains one absolute standout, one solid but conventional idea, and two weaker proposals. **Idea 1** is exceptionally promising and should be pursued immediately; it combines a massive, unstudied policy shock with universe-level data and a highly credible identification strategy (the secondary residence placebo is a brilliant touch). **Idea 2** is a competent secondary project if the geocoding proves feasible, but **Idea 3** suffers from severe control-group endogeneity, and **Idea 4** should simply be folded into Idea 1's mechanism analysis rather than pursued as a standalone paper.

---

## Grok 4.1 Fast

**Tokens:** 5590

### Rankings

**#1: Who Captures a Tax Cut? Property Price Capitalization and Fiscal Substitution from France's €22 Billion Residence Tax Abolition**
- Score: 88/100
- Strengths: Exceptional identification with continuous-treatment DiD, built-in placebos (secondary residences), DDD on timing, and fiscal substitution decomposition, all on universe-scale transaction data with 4-year pre-period; directly addresses who captures massive tax cuts via capitalization chain (TH abolition → TF substitution → net price effects), with clear welfare implications.
- Concerns: Staggered rollout could invite recent DiD concerns if not fully addressed via event studies; post-2023 data for full phase-out may be thin depending on 2025 availability.
- Novelty Assessment: Highly novel—only one non-peer-reviewed French policy report exists, no English-language causal work linking to core tax capitalization literature (Oates, etc.), and fiscal substitution entirely unstudied.
- Top-Journal Potential: High. Challenges conventional wisdom on tax incidence (local governments claw back via substitution?), delivers mechanism chain (windfall → rate hikes → capitalization), on first-order stakes (€22B reform) with universe data enabling precise bounds—fits winner patterns like surprising tradeoffs and policy deliverable.
- Identification Concerns: Parallel trends credible with 4-year pre-period and event studies, but staggered timing requires careful aggregation checks (e.g., Callaway-Sant'Anna); département clustering sufficient but could test finer (commune fixed effects).
- Recommendation: PURSUE (conditional on: full event-study pre-trends pass; integrate TF hikes as core mechanism rather than side analysis)

**#2: Do Priority Schools Help or Stigmatize? Property Price Effects of France's 2015 Education Zone Reform**
- Score: 72/100
- Strengths: Clean sharp reform with enter/exit arms enabling mechanism decomposition (resources vs. stigma via opposite predictions and distance gradients); tests globally relevant tradeoff in place-based education policy using property prices as revealed preference.
- Concerns: Geocoding school-to-parcel matching may introduce noise/attrition; relatively small treated units (~1,100 schools) risks power issues for radius-specific estimates.
- Novelty Assessment: Moderately novel—original ZEP studied for labor outcomes (Benabou et al.), but 2015 redraw and property price angle entirely unstudied.
- Top-Journal Potential: Medium. Exciting mechanism chain (designation → resources/stigma → prices) with counterintuitive potential (stigma dominates?), but niche to French education zones unless framed as boundary test for worldwide policies; lacks massive scale or belief-changing stakes.
- Identification Concerns: National sharp date supports DiD, but unobserved neighborhood confounders (e.g., correlated school quality changes) could bias; needs strong pre-trends by enter/exit/unchanged groups.
- Recommendation: CONSIDER (conditional on: confirming geocoded REP lists on data.gouv.fr; power calcs show adequate treated parcels)

**#3: Does Social Housing Enforcement Reshape Cities? Evidence from France's 2013 SRU Penalty Tripling**
- Score: 58/100
- Strengths: Multiple outcomes (construction, prices, demographics) allow tracing chain (penalties → building → sorting); compliance heterogeneity adds bite for uptake vs. fines.
- Concerns: Pre-reform housing shares likely endogenous to local politics/preferences, threatening parallel trends; population threshold enables RDD but DiD on 20-25% band may have few units (~200?), diluting power.
- Novelty Assessment: Somewhat novel—descriptive work exists (Gobillon/Vanhoni), but no causal exploitation of 2013 penalty shock with prices/demographics.
- Top-Journal Potential: Low. Competent policy evaluation but lacks surprise (expected NIMBY/sorting?) or first-order stakes; reads as standard DiD ATE on familiar inclusionary zoning without strong chain or welfare pivot.
- Identification Concerns: Binding threshold endogenous (political sorting into 20-25%), risking selection bias; penalty "intensification" not as sharp as full rollout, with fines as weak compliance instrument.
- Recommendation: SKIP

**#4: Taxe Foncière Hikes and Housing Market Dynamics After France's Local Tax Reform**
- Score: 35/100
- Strengths: Leverages same rich DVF/REI data as Idea 1 for event-study DiD on rate hikes.
- Concerns: Not standalone—purely subsumed in Idea 1's fiscal substitution; lacks unique variation or novelty beyond post-TH noise.
- Novelty Assessment: Low—overlaps directly with Idea 1 and existing capitalization lit; post-reform variation not quasi-experimental on its own.
- Top-Journal Potential: Low. Narrow ATE on tax hikes without mechanism or stakes; would read as "competent but unexciting" appendix material.
- Identification Concerns: "Discrete large hikes" voter-endogenous, no clear exogeneity; stable-rate controls may correlate with hike-prone communes.
- Recommendation: SKIP

### Summary
This is a strong batch anchored by Idea 1, which stands out for its scale, identification battery, and top-journal arc (tradeoff chain on €22B reform)—genuinely field-changing potential. Pursue Idea 1 immediately as the clear leader, consider Idea 2 only after data checks, and skip the rest to avoid overlap/dilution. Overall quality high for policy institute but calibrate excitement to empirical patterns: mechanism depth and stakes separate winners.

