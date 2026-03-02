# Research Idea Ranking

**Generated:** 2026-03-02T09:04:45.235313
**Models:** GPT-5.2, Gemini 3.1 Pro, Grok 4.1 Fast
**Reasoning:** high

## Comparison Table

| Idea | GPT-5.2 | Gemini 3.1 Pro | Grok 4.1 Fast |
|------|------|------|------|
| Mandates and Mavericks — Gender, Elector... | PURSUE (74) | PURSUE (86) | PURSUE (78) |
| Do Quotas Breed Loyalty? Gender, Party D... | PURSUE (66) | SKIP (42) | SKIP (54) |
| Quota Shock and Party Loyalty — How Nati... | CONSIDER (61) | SKIP (54) | CONSIDER (62) |
| When the Whip Comes Off — Gender Gaps in... | CONSIDER (51) | CONSIDER (62) | CONSIDER (67) |

---

## GPT-5.2

**Tokens:** 7099

### Rankings

**#1: Mandates and Mavericks — Gender, Electoral Pathway, and Party Discipline in the German Bundestag**
- **Score:** 74/100
- **Strengths:** Strong setting where “dependence on the party” is institutionally sharp (list vs district), with unusually rich roll-call microdata over many decades. The dual-candidate close-race design can plausibly deliver a clean causal effect of mandate type and lets you speak to mechanism (preferences vs constraints), not just an ATE.
- **Concerns:** Party quota adoption is plausibly endogenous to broader party modernization and could coincide with unobserved shifts in internal discipline norms; the DDD could pick up these correlated changes. Roll-call votes (namentliche Abstimmungen) are a selected subset of all votes, and “rebellion” measured against faction-majority may move with agenda control rather than individual discipline.
- **Novelty Assessment:** **Moderately novel.** Bundestag discipline and mandate type are studied, and gender–discipline has some work, but the *causal decomposition* using MMP structure + quotas + (especially) close-race assignment is not a crowded lane.
- **Top-Journal Potential:** **Medium–High.** Best shot at a top field journal (AEJ:EP) and an outside chance at a top-5 if framed as a general result about party control technologies and descriptive representation (MMP as a “party-dependence lever”) with a tight mechanism chain.
- **Identification Concerns:** The cleanest piece is the **close-race RDD for dual candidates**, but it may be underpowered and subject to selection into “dual candidacy” and strategic list placement. For the DDD, you’ll need convincing evidence that quota timing doesn’t coincide with party-specific discipline reforms and that pre-trends by mandate type × gender are flat.
- **Recommendation:** **PURSUE (conditional on: a strong close-race first-stage showing mandate-type assignment actually shifts dependence; extensive pre-trend/placebo checks; a clear discussion of roll-call selection and robustness to alternative “party line” definitions).**

---

**#2: Do Quotas Breed Loyalty? Gender, Party Discipline, and the Laranja Problem in Brazil's Chamber of Deputies**
- **Score:** 66/100
- **Strengths:** First-order policy setting (a major democracy with binding quota enforcement) and outcomes tightly linked to party governance (deviation from leader orientação). If you can separate “quota-induced” entrants from others, this becomes a sharp test of whether quotas change *types* of politicians or party control over them.
- **Concerns:** The **laranja** phenomenon and weak enforcement make the “first stage” (reform → different elected women) uncertain; you risk estimating a reform that changed *candidate paperwork* more than legislative composition/behavior. DiD using compliance gaps is vulnerable to correlated party trends (ideology, regional bases, anti-corruption waves, coalition shifts) and to mechanical “exposure” endogeneity if pre-period female shares proxy for unobserved party characteristics.
- **Novelty Assessment:** **Moderately novel.** Brazil quotas and Brazil roll-call/discipline are each studied, but the specific merge of quota enforcement → elected women → party-line discipline is much less saturated.
- **Top-Journal Potential:** **Medium.** Likely strong in comparative political economy / top field outlets if you can convincingly show a real first-stage and a mechanism (party gatekeeping, candidate quality, electoral incentives). Harder for top-5 without a particularly surprising mechanism or a broader framework that travels beyond Brazil.
- **Identification Concerns:** Main threat is **non-exogenous treatment intensity** (parties with larger “gaps” differ systematically and may have different discipline trends absent the reform). You’ll need (i) strong event-study diagnostics, (ii) placebo reforms, and (iii) an explicit first-stage showing the reform shifted elected-women composition in treated parties, not just candidate shares.
- **Recommendation:** **CONSIDER (upgrade to PURSUE if you can document a strong first-stage on *elected* female composition/characteristics and show no differential pre-trends in discipline by quota-gap).**

---

**#3: Quota Shock and Party Loyalty — How National Gender Quotas Reshape MEP Discipline in the European Parliament**
- **Score:** 61/100
- **Strengths:** Cross-country staggered quota timing is attractive in principle, and EP roll-call data are large-scale with standardized voting, enabling rich heterogeneity (by EP group, policy area, national party family). Policy relevance is real given ongoing quota debates and EU governance concerns.
- **Concerns:** Quota adoption is highly **politically endogenous** (reflecting social norms, party-system changes, constitutional reforms) and may correlate with unobserved trends in delegation behavior that also affect loyalty. Data constraints are nontrivial: VoteWatch starts 2004, many quota adoptions are earlier, and merging gender/biographics across terms/countries is error-prone; also, the number of treated countries is small for credible inference with clustered errors.
- **Novelty Assessment:** **Some novelty, but not pristine.** Gender quotas are heavily studied; EP party-group cohesion is heavily studied; the specific “quota → EP loyalty” link is less common, but it is a foreseeable join of two large literatures.
- **Top-Journal Potential:** **Low–Medium.** Without a compelling exogenous adoption story (or an instrument/threshold design within countries), this risks reading as a competent CS-DiD application with lingering endogeneity—typically not enough for top journals unless the result is striking and robust to many alternative stories.
- **Identification Concerns:** The core issue is **policy endogeneity and few treated clusters**; standard staggered DiD won’t fix selection into adoption. Pre-trends will be hard to validate for early adopters given data start dates, and treatment “dosage” (quota compliance → elected women) varies.
- **Recommendation:** **CONSIDER (conditional on: restricting to adoption episodes with credible quasi-exogenous triggers; demonstrating strong first-stage in elected female shares; and presenting a battery of placebo tests/negative controls).**

---

**#4: When the Whip Comes Off — Gender Gaps in German Bundestag "Conscience Votes"**
- **Score:** 51/100
- **Strengths:** Intuitively appealing mechanism: comparing whipped vs free votes gets directly at “suppressed preferences” vs party discipline. Data are clean and immediately usable, and within-legislator comparisons are feasible.
- **Concerns:** “Free vote” designation is **highly selected** (moral/salient issues, cross-cutting cleavages, leadership strategy), so the change in discipline is not plausibly exogenous—this is closer to comparing different *types of issues* than removing a whip at random. The number of free votes is small, making power and generalizability major problems; likely results will be fragile and easy to over-interpret.
- **Novelty Assessment:** **Low–Moderate.** Free votes in legislatures and gender differences in voting are both known objects; the specific German gender angle is less common but not a big conceptual leap, and the small-N nature limits contribution.
- **Top-Journal Potential:** **Low.** More likely a neat descriptive/mechanism note or a section within a broader paper (e.g., as supportive evidence for Idea 1) than a standalone top-journal piece.
- **Identification Concerns:** The fatal risk is **selection into treatment** (why/when parties allow conscience votes) plus limited ability to test parallel trends given sparse events and topic heterogeneity.
- **Recommendation:** **SKIP (as a standalone). Consider folding it in as auxiliary evidence/mechanism validation for Idea 1 rather than building an entire paper around it.**

---

### Summary

This is a coherent batch around gender, quotas, and party discipline, but only **Idea 1** has a realistic path to *clean identification plus a mechanism contribution* that could travel beyond its setting. I would fund and staff **Idea 1 first**, and treat **Idea 4** as a contingent second bet only if you can demonstrate a strong first-stage on *elected* women and defeat the “laranja/party-trends” alternative story. Ideas 2 and 3 are better as complements or pilot projects than as flagship institute papers.

---

## Gemini 3.1 Pro

**Tokens:** 8282

Here is my evaluation of the research proposals, ranked from most to least promising, calibrated against the empirical editorial patterns of top economics journals.

### Rankings

**#1: Mandates and Mavericks — Gender, Electoral Pathway, and Party Discipline in the German Bundestag**
- **Score**: 86/100
- **Strengths**: This proposal brilliantly exploits a unique institutional feature (the MMP system) to cleanly decompose a persistent behavioral gap into intrinsic preferences versus institutional constraints. The supplementary RDD on dual candidates provides a highly credible, micro-level causal engine that top journals love.
- **Concerns**: The DDD relies on staggered party quotas, which might be endogenous to internal party factional shifts that simultaneously alter party discipline. 
- **Novelty Assessment**: High. While gender and party discipline are frequently studied, causally separating the *mechanism* (preferences vs. electoral vulnerability) using an MMP system is a novel, puzzle-resolving contribution to political economy.
- **Top-Journal Potential**: High. Top-5 journals actively reward papers that use clever institutional variation to resolve a fundamental mechanism debate, moving beyond a simple ATE of "do women vote differently." It perfectly fits the winning architecture of "hook → puzzle → design that isolates a channel."
- **Identification Concerns**: For the DDD, parallel trends in party discipline across parties adopting quotas at different times could be violated by broader political realignments. The RDD is much cleaner but relies entirely on having sufficient density of close races involving dual candidates.
- **Recommendation**: PURSUE (conditional on: demonstrating sufficient sample size and density for the dual-candidate RDD, as this will be the paper's most credible causal claim).

**#2: When the Whip Comes Off — Gender Gaps in German Bundestag "Conscience Votes"**
- **Score**: 62/100
- **Strengths**: This is a conceptually elegant way to measure the "shadow" of party discipline by observing behavior when the constraint is explicitly removed. It addresses a first-order question about how much substantive representation is suppressed by institutional norms.
- **Concerns**: Severe statistical power limitations due to the small number of free votes (~50-100 over 70 years). Finding perfectly comparable "whipped" votes on the exact same topics to serve as the counterfactual is practically impossible.
- **Novelty Assessment**: Medium-High. Using free votes to study gender gaps is a fresh angle, and framing it as revealing latent preferences is theoretically compelling.
- **Top-Journal Potential**: Medium. While the narrative framing is excellent, top journals will likely reject it due to the inability to construct a clean, well-powered counterfactual. It risks falling into the "failed identifying assumptions that the paper cannot fix" category.
- **Identification Concerns**: The designation of a "free vote" is highly endogenous; party leaders only release the whip when it is politically optimal or when the party is already hopelessly divided. Comparing a free vote to a whipped vote on a "similar" topic suffers from severe selection bias.
- **Recommendation**: CONSIDER (conditional on: finding a highly rigorous way to match free votes to whipped votes—perhaps using text analysis of bills—and proving sufficient statistical power via MDE calculations).

**#3: Quota Shock and Party Loyalty — How National Gender Quotas Reshape MEP Discipline in the European Parliament**
- **Score**: 54/100
- **Strengths**: Leverages clean, staggered cross-national variation in quota adoption. The European Parliament provides a large, standardized testing ground for national-level shocks.
- **Concerns**: The EP is a secondary legislature where party discipline dynamics differ vastly from national parliaments, making it hard to generalize. Furthermore, quotas affect candidate lists, not necessarily the composition of elected MEPs, leading to a weak first stage.
- **Novelty Assessment**: Medium. Applying a standard staggered DiD to gender quotas is a familiar design, even if the EP setting hasn't been extensively mined for this specific question.
- **Top-Journal Potential**: Low. This reads exactly like the "competent but not exciting" modal loss described in the editorial appendix: a standard DiD on a familiar margin without a novel mechanism decomposition or belief-changing pivot.
- **Identification Concerns**: Because quotas only mandate candidate list composition and compliance varies, the actual "shock" to the elected delegation's gender makeup may be weak or endogenous to party popularity (e.g., if a party wins more seats, they reach further down the list).
- **Recommendation**: SKIP

**#4: Do Quotas Breed Loyalty? Gender, Party Discipline, and the Laranja Problem in Brazil's Chamber of Deputies**
- **Score**: 42/100
- **Strengths**: Addresses a highly relevant policy issue in developing democracies (quota evasion) and utilizes a rich, publicly available dataset of party orientations and roll-call votes.
- **Concerns**: The "laranja" (dummy candidate) phenomenon fatally undermines the treatment; the reform did not cleanly increase genuine female representation. The baseline female representation is also too low to detect meaningful within-party behavioral shifts.
- **Novelty Assessment**: Low-Medium. Merging roll-call data with gender in Brazil is useful but represents an incremental empirical extension rather than a conceptual breakthrough.
- **Top-Journal Potential**: Low. Top journals will view the "laranja" problem not as an interesting boundary test, but as a fatal "measurement mismatch/outcome dilution" flaw where the policy failed to actually treat the population of interest.
- **Identification Concerns**: The treatment (quota compliance gap) is heavily confounded by party corruption and institutional capacity. Parties that had to scramble to find 30% female candidates and resorted to dummy candidates are fundamentally different from those that complied naturally, violating parallel trends.
- **Recommendation**: SKIP

### Summary

This batch contains one standout proposal (Idea 1) that perfectly aligns with what top economics journals are currently publishing: it uses a clean institutional quirk to decompose a mechanism rather than just estimating an ATE. Idea 3 is conceptually beautiful but likely suffers from fatal empirical limitations regarding power and endogeneity. Ideas 2 and 4 should be discarded, as they represent standard, unexciting DiD designs plagued by weak first stages and measurement mismatches.

---

## Grok 4.1 Fast

**Tokens:** 5794

### Rankings

**#1: Mandates and Mavericks — Gender, Electoral Pathway, and Party Discipline in the German Bundestag**
- **Score**: 78/100
- **Strengths**: Exceptional causal identification via triple-difference and supplementary RDD cleanly decomposes the gender-discipline gap into preferences vs. institutional incentives, leveraging staggered party quotas as exogenous variation in a high-quality roll-call dataset. High novelty as the first causal evidence in this setting, with strong top-journal potential from a compelling mechanism chain that challenges conventional wisdom on gender representation.
- **Concerns**: Relies on sufficient post-quota variation in list vs. district gender shares across parties; free votes may need careful handling to avoid diluting the main analysis.
- **Novelty Assessment**: High—closest papers (Ohmura 2021, Sieberer & Ohmura 2021) are purely observational; this provides the first causal decomposition exploiting MMP and quotas.
- **Top-Journal Potential**: High. Fits editorial patterns for "mechanism decomposition" (preferences vs. incentives) and "puzzle-resolver" (reconciles gender gap literature with mandate-type effects), with a clear causal chain (quota → list entry → discipline constraint) in a boundary-test setting (MMP systems); could change how the field views institutional effects on representation.
- **Identification Concerns**: Parallel trends in gender gaps by mandate type need strong pre-testing; party-term FEs handle time-varying confounders, but electoral safety could confound if correlated with gender post-quota.
- **Recommendation**: PURSUE (conditional on: robust event-study evidence for parallel trends; power checks for heterogeneity by policy area)

**#2: When the Whip Comes Off — Gender Gaps in German Bundestag "Conscience Votes"**
- **Score**: 67/100
- **Strengths**: Clean within-legislator, within-topic DiD reveals latent gender preferences suppressed by discipline, building directly on existing free-vote coding for a novel "shadow of hierarchy" angle. Strong data feasibility with public sources and conceptual alignment to policy debates on representation.
- **Concerns**: Small number of free votes (~50-100) risks low power for detecting gaps, potentially yielding imprecise nulls without strong bite verification.
- **Novelty Assessment**: Medium-high—Hohendorf et al. (2022) identify free votes but ignore gender; this is a fresh extension to reveal suppressed preferences.
- **Top-Journal Potential**: Medium. Offers a counter-intuitive mechanism (discipline masks gender effects) with decomposition potential, but niche outcomes and power limits may read as "competent but not exciting" without scaling to broader whipped-vote contrasts.
- **Identification Concerns**: Topic-specific matching assumes whipped/free votes are comparable absent discipline; selection into free-vote topics could bias if gendered.
- **Recommendation**: CONSIDER (conditional on: power simulations showing MDE coverage; expansion to related low-discipline votes)

**#3: Quota Shock and Party Loyalty — How National Gender Quotas Reshape MEP Discipline in the European Parliament**
- **Score**: 62/100
- **Strengths**: Exploits clean staggered adoption across countries for CS-DiD on an understudied EP setting, with adequate sample size and relevance to European integration debates.
- **Concerns**: Merging gender data is labor-intensive and error-prone; quota compliance varies, weakening first-stage and risking mechanical pre-trends from national politics.
- **Novelty Assessment**: High—EP gender-discipline link is "almost completely unstudied," with no prior quota-IV papers.
- **Top-Journal Potential**: Medium. Addresses first-order EP policy question but lacks mechanism depth (just ATE on loyalty), risking "nice evaluation" dismissal without counter-intuitive chain or literature pivot.
- **Identification Concerns**: Cross-country DiD vulnerable to EU-wide shocks (e.g., treaty changes); quotas affect nominations not seats, so compliance heterogeneity confounds treatment.
- **Recommendation**: CONSIDER

**#4: Do Quotas Breed Loyalty? Gender, Party Discipline, and the Laranja Problem in Brazil's Chamber of Deputies**
- **Score**: 54/100
- **Strengths**: Interesting boundary test merging gender quotas with fragmented-party discipline, using open API data for party orientations.
- **Concerns**: Low female representation (8-18%) cripples power; "laranja" dummies and compliance-gap construction muddy who counts as quota-induced, yielding fuzzy DiD.
- **Novelty Assessment**: Medium—separate literatures exist, but no roll-call merger; still, Brazil gender-quota effects are somewhat studied observationally.
- **Top-Journal Potential**: Low. Standard DiD without strong mechanism or surprise in a familiar quota setting; fragmented parties add flavor but not enough for "belief-changing" pivot.
- **Identification Concerns**: Compliance gap is endogenous to pre-reform shares; post-reform selection (laranjas) biases treatment composition, with few clusters in small parties.
- **Recommendation**: SKIP

### Summary
This is a solid batch with two promising ideas anchored in German data, offering causal mechanism insights into gender and discipline that could inform quota design—far better than typical proposals. Pursue Idea 1 first for its top-journal excitement and rigor; Idea 2 (conscience votes) as a quick complementary project if power holds. Ideas 3-4 suffer from feasibility and identification flaws that limit impact.

