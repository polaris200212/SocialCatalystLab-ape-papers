# Reply to Reviewers

**Paper:** Going Up Alone? Gender, Electoral Pathway, and Party Discipline in the German Bundestag

We thank the three referees for their careful reading and constructive criticism. The reviews collectively identify a small number of issues — one of which (the RI specification mismatch) is flagged by all three referees and will be straightforwardly corrected. Below we respond to each referee in turn, using the standard point-by-point format. Changes to the paper are described in the context of each response.

---

## Response to Referee 1 (GPT-5.2 — Major Revision)

---

### Point 1.1 — The DDD is not a causal design as currently framed

**Referee:** The main regression (Eq. 1) is a conditional cross-sectional comparison within party×period cells. District vs List status is endogenous, and party×period FE do not resolve within-cell selection. The null Female×District interaction therefore cannot be taken as strong evidence that party discipline overrides gendered differences without additional assumptions. The referee recommends either (a) a more credible identification strategy or (b) reframing the DDD as descriptive and moving causal claims exclusively to the RD.

**Response:** We agree that the DDD regression does not constitute a causal design in the potential-outcomes sense. The label "triple-difference" in the text was applied loosely to describe the three-way interaction structure of the regression, not to assert a causal estimand analogous to a pre/post×treated/untreated DiD. We will revise the framing throughout the paper to make this explicit.

Specifically, we will:

1. **Rename and reframe.** The DDD regression will be relabeled a "descriptive decomposition" or "conditional interaction regression" in the text, Sections 3.1 and 5.1, and the abstract. Causal language (e.g., "suppresses," "overrides") will be removed from the discussion of Table 2 results.

2. **State the estimand clearly.** We will add a short paragraph at the start of Section 5.1 explaining that the estimand is a within-party×period conditional correlation: the difference in the Female gap between District and List MPs, controlling for electoral safety and party×period fixed effects. We will state explicitly that this identifies a causal effect only under a conditional ignorability assumption that is unlikely to hold perfectly given within-party selection, and that the RD is the credible causal design.

3. **Reserve causal claims for the RD.** The conclusion and abstract will be revised to separate (a) the descriptive finding from the conditional regression — no robust correlation between gender and deviation from party line, and no gender×mandate interaction — from (b) the causal finding from the RD — district mandates reduce rebellion, and this effect is equal for men and women.

We note that the descriptive decomposition still has scientific value: it establishes that the raw gender gap in rebellion (0.26pp) is entirely absorbed by party×period fixed effects, with no residual interaction by mandate type. This is a useful benchmark regardless of the causal interpretation.

---

### Point 1.2 — The RD design: conditioning and sample selection may break continuity

**Referee:** For district race losers, being observed as an MP requires a high enough list position given party seat allocations. Winners are always MPs. This creates a discontinuity in the probability of appearing in the estimation sample at the cutoff, which is a form of selection-on-being-observed that threatens the continuity assumption. The referee suggests either restricting to dual candidates with safe list positions, implementing a fuzzy RD / RD-with-selection framework, or at minimum showing the discontinuity in "being an MP observed in the data" at the threshold.

**Response:** This is the referee's most consequential concern and we address it directly.

**The empirical magnitude of the selection threat is limited for our sample.** Eighty-three percent of our analytical sample are dual candidates, and we condition throughout on legislators who are actually observed in parliament — both winners and losers appear in the BTVote panel only if they hold a seat. Among close-race dual candidates near our 5.9pp bandwidth, the relevant question is whether the probability of being in parliament is discontinuous at the zero margin.

For losers just below zero, entry into parliament requires that (i) the candidate held a list position, and (ii) the party's second-vote allocation was sufficient to cover that position. For winners just above zero, the district win guarantees a seat. However, we note the following partial mitigants:

- **List safety in German elections.** The Bundestag's compensatory MMP system allocates list seats after subtracting direct mandate winners. A candidate who narrowly loses a district race but holds, say, list position 3 in a state where the party wins 5+ list seats will still enter parliament regardless of the district outcome. The key threat is only candidates who hold marginal list positions where the seat allocation near the threshold creates the discontinuity. In practice, parties tend to place their most competitive district candidates in safe list positions as insurance — this is a well-documented feature of German party strategy (Stratmann and Baur 2002; Bawn 1999). We will document this empirically.

- **We will add the diagnostic the referee requests.** Concretely, we will compute, for our sample of dual candidates within the h=5.9pp bandwidth, the fraction who appear as MPs as a function of the district margin (a "first-stage for selection" plot). If the selection probability is smooth at the cutoff, the continuity assumption is supported. If there is a visible jump, we will acknowledge the limitation and estimate the magnitude of bias.

- **Sensitivity to list-safe restriction.** We will define a "list-safe" indicator for candidates whose list rank, combined with realized party second-vote allocations, would have delivered a seat regardless of their district outcome. We will re-estimate the main RD specification restricting to these candidates and report the results alongside the full-sample RD. If estimates are stable, this allays the selection concern; if they differ substantially, we will note the caveat prominently.

We therefore plan to add: (a) a density plot and McCrary-style statistic for whether dual candidates near the threshold appear in parliament, (b) a balance-on-selection variable table in Appendix B, and (c) a sensitivity analysis restricted to list-safe candidates. We agree that these additions are necessary for the RD to fully support a causal statement.

---

### Point 1.3 — The sign flip on District (OLS positive, RD negative)

**Referee:** Table 2 shows District ≈ +0.27pp (positive, all MPs, party×period FE). The RD shows District ≈ −0.93pp (negative, dual candidates near threshold). This inconsistency changes the substantive story about independence vs discipline and must be reconciled.

**Response:** We welcome this question because the sign flip is in fact informative, and we agree the current paper does not make the decomposition sufficiently explicit.

**The two estimates identify different estimands on different samples:**

- **Table 2 (OLS, +0.27pp):** This is a descriptive conditional correlation estimated on all Bundestag members — both duals and pure-list candidates — within party×period cells. It captures the average association between holding a district mandate and deviation from the party line, conditional on party composition and period. It is not a causal estimate. The positive sign here likely reflects **positive selection**: parties nominate their more locally embedded, ideologically independent-minded, or senior candidates for direct district races. These candidates are more willing to deviate regardless of the mandate type, so conditional on party×period, district members deviate slightly more.

- **RD (−0.93pp):** This is a causal local average treatment effect among **marginal dual candidates** — those who narrowly won or lost their district race and are otherwise comparable. For this group, winning a district seat reduces rebellion relative to entering as a list member. This reflects the **causal incentive effect of constituency accountability**: holding a district mandate ties the MP to local voters, increasing the cost of visible deviation from the party on issues visible to constituents.

The combination of positive OLS and negative RD is consistent with a classic selection-vs-treatment-effect pattern: parties select more rebellious candidates into districts (positive selection bias), but the causal effect of actually holding a district mandate is to discipline behavior (negative treatment effect). The OLS conflates these; the RD isolates the latter.

We will add a short "reconciliation" paragraph in Section 6 (or a new subsection) that presents this decomposition explicitly. We will show side-by-side estimates on: (a) all MPs, (b) all dual candidates, (c) dual candidates within the RD bandwidth, tracking how the District coefficient changes as the sample narrows toward the quasi-random assignment window. This will make the decomposition transparent for readers.

---

### Point 1.4 — Key assumptions not sufficiently tested

**Referee:** For the DDD, conditional ignorability within party×period is very strong and should be stated and probed. For the RD, standard diagnostics (McCrary density test, covariate continuity plots, placebo cutoffs, bandwidth robustness with RD-specific CIs) are missing or underreported.

**Response:** We will add the following in the revision:

1. **DDD assumption statement.** As noted in our response to Point 1.1, we will explicitly state the conditional ignorability assumption in Section 5.1 and discuss its plausibility. We will add a balance check comparing observable characteristics (tenure, prior office experience, state, east/west) of district vs list MPs within the same party×period cell to assess the within-cell selection margin.

2. **RD diagnostics.** We will add to Appendix B: (a) a formal McCrary (2008) density test adapted for discrete margins (rddensity from Cattaneo et al.), reporting the test statistic and p-value; (b) covariate continuity plots for gender, party, tenure, and state; (c) placebo cutoff estimates at ±5pp and ±10pp from the true threshold; (d) bandwidth sensitivity table showing rdrobust estimates across h = 3pp to 20pp with bias-corrected CIs; (e) explicit reporting of effective sample sizes on each side of the cutoff.

---

### Point 2.1 — Clustering and the effective sample size

**Referee:** Two-way clustering (MP + vote) appears to leave SEs unchanged to the 4th decimal in Table 6, which is surprising. The paper should verify and explain.

**Response:** We will verify the two-way clustering implementation and add clarifying text. The likely explanation is that vote-level variation in the outcome is largely absorbed by the party×period fixed effects (which are at the party-period level, above the vote level) and, in column 5, by direct vote fixed effects. Once these are partialed out, the residual within-vote correlation across MPs conditional on party×period is small, so adding the vote dimension to clustering has negligible effect on standard errors. We will confirm this programmatically and explain it in the Table 6 notes.

We will also add, in the main table notes, a brief statement of inference under party×period clustering (few clusters; likely conservative since we already partial out party×period FE), alongside the legislator-clustered SEs.

---

### Point 2.2 — Randomization inference specification mismatch

**Referee:** RI yields p=0.014 on the uncontrolled specification (Column 3), while asymptotic p=0.50 on the preferred controlled specification (Column 4). Reporting a statistically significant RI result alongside a precisely estimated null is not acceptable for a top journal. RI must be run on the exact preferred estimand.

**Response:** We agree entirely. This is a clear error in presentation, and we will correct it.

We will re-run the randomization inference on the preferred specification — Column 4 including the electoral safety control variable and party×period fixed effects, using 999 permutations within party×period cells. The corrected RI p-value will be reported in Table 6 alongside the asymptotic p-values. The current explanation in the text attributing the discrepancy to omitted variable bias from electoral safety will be replaced with a brief description of the corrected RI result and a note that the earlier uncontrolled result reflected specification mismatch.

If, after including the electoral safety control in the RI, the p-value remains near 0.014 while asymptotic p-values are near 0.50, we will investigate whether this reflects non-normal residuals, a leverage issue with specific legislators or periods, or misspecification of the permutation scheme. We do not anticipate this will be the case — the OVB explanation is compelling given the known correlation between electoral safety, gender, and mandate type — but we will report what the corrected RI finds.

---

### Point 2.3 — Binary outcome and LPM robustness

**Referee:** With a 1.6% mean, confirm robustness with a nonlinear model or MP-period fractional outcome regressions.

**Response:** We will add as a robustness check in Appendix D: (a) a logit specification with party×period fixed effects using the Fernandez-Val (2009) bias correction for high-dimensional fixed effects (via the `bife` package in R), and (b) MP-period level fractional outcome regressions where the outcome is the fraction of votes in a period deviating from the party line, estimated via OLS with the same fixed effects. The main coefficients are expected to be similar in direction and significance; we will report and discuss any discrepancies.

---

### Point 2.4 — RDD inference and reporting

**Referee:** Need explicit reporting of polynomial order, kernel, bias correction, effective N on each side, and handling of discrete running variable.

**Response:** We will revise Section 5.2 to explicitly state: triangular kernel, local linear polynomial (order 1), MSE-optimal bandwidth of 5.9pp, Calonico-Cattaneo-Titiunik (2014) robust bias correction. We will report effective N on each side of the threshold for the main bandwidth. Regarding discrete margins, we will follow the Cattaneo-Idrobo-Titiunik (2020) guidance for discrete running variables: we will report the `rddensity` test output and bandwidth robustness that spans multiple values to confirm the discrete mass-point structure does not drive the result.

---

### Point 3.1 — Party line definition robustness

**Referee:** Plurality among yes/no/abstain may misclassify dissent; show robustness to treating abstain as "no," excluding abstentions, and yes/no-only definition.

**Response:** We will add three alternative party-line definitions to the robustness table (Table 6): (a) treating abstention as deviation (any departure from the yes or no majority position counts as deviation regardless of abstain), (b) excluding votes where a party majority abstains (restricting to clear yes/no party positions), and (c) restricting to yes/no votes only among MPs (dropping abstaining votes from the denominator). We expect these to have minimal impact on the main null but will report the results transparently.

---

### Point 3.3 — Mechanisms: discipline vs preference convergence

**Referee:** The paper does not cleanly distinguish sorting from suppression. Suggest examining other behavior less whipped than floor votes (questions, speeches, bill co-sponsorship, amendments).

**Response:** We acknowledge this limitation and agree it is a genuine constraint of floor-vote data. We note that the free-vote analysis in Section 6.7 provides partial evidence bearing on this distinction: when the whip is removed, gender differences emerge (Female coefficient 0.59pp, five times larger than under whipping), which is directionally consistent with suppression rather than pure preference convergence. We cannot rule out that free-vote samples differ systematically from whipped votes, so we will be careful to describe this as suggestive.

Expanding to speeches, questions, or co-sponsorship data would require assembling a separate dataset and is beyond the scope of this revision, but we will note this as a direction for future research in the Discussion.

---

### Point 3.4 — Green Party exception: cell sizes and multiple testing

**Referee:** The Greens result (Female×District = 4.48pp) invites concern about small cell sizes, unmodeled heterogeneity, and multiple comparisons across parties.

**Response:** We will address this in the revision as follows:

1. **Cell sizes.** We will add a footnote or small table reporting the number of Green district-women, Green list-women, Green district-men, and Green list-men in the estimation sample, and the number of parliamentary periods in which each cell is populated. If the effect is driven by a small number of individuals or a single period, we will note this clearly.

2. **Policy domain decomposition.** As recommended by Referee 3, we will examine whether the Green Party female district deviation effect is concentrated in specific CAP policy domains (e.g., environmental/energy, social policy) or is broad-based. This will help distinguish whether the effect reflects organizational culture or issue-specific mandate independence.

3. **Multiple testing.** We will apply Holm-Bonferroni correction to the party-specific heterogeneity estimates reported in Figure 2, and will note in the text which party-specific interactions survive this correction. This follows the same approach already applied to the policy-domain results in Table 4.

---

### Point 4 — Missing literature

**Referee:** Suggests Hix, Noury & Roland (2005/2006) on European Parliament voting; Carey (2007) on discipline and candidate selection; Callaway & Sant'Anna (2021) etc. if DiD language is retained.

**Response:** We will add Hix, Noury & Roland (2005) as a comparative benchmark in the literature review — the EP is the closest available cross-national comparison with documented gender gaps in cohesion behavior, and citing this work helps position the Bundestag null against a broader institutional spectrum. We will also engage more directly with Carey (2007) on how candidate selection systems interact with legislative discipline.

We will remove DiD-specific language (Callaway & Sant'Anna, Sun & Abraham) from the paper since we are reframing the DDD as a descriptive decomposition rather than a parallel-trends design. These citations are not relevant to the actual design.

---

### Point 5.1 — Over-claiming relative to what is identified

**Referee:** "Party discipline overrides gendered behavioral differences" and "is the only one that matters on the floor" are too strong for the current identification.

**Response:** We agree and will revise the abstract and conclusion to use calibrated language. The new framing will be: "In recorded roll-call votes in the Bundestag from 1983 to 2021, we find no evidence that women deviate from the party line at different rates than men, and no evidence that this gender gap — or its absence — varies by electoral pathway. A close-election regression discontinuity confirms that winning a district seat reduces rebellion equally for men and women." The language "overrides" and "the only one that matters" will be removed.

---

### Point 5.2 — MDE and confidence intervals

**Referee:** Report CIs for the key interaction, not just MDE; interpret what effect sizes are ruled out.

**Response:** We will add 95% confidence intervals (in percentage points and as a share of the baseline mean) for the Female×District interaction in the main text discussion of Table 2. We will explicitly note that the 95% CI rules out interaction effects larger than approximately ±0.4pp, which corresponds to ±24% of the overall baseline deviation rate. We will frame this as: the paper can rule out effects that would be substantively meaningful by the standards of this literature.

---

---

## Response to Referee 2 (Grok-4.1-Fast — Minor Revision)

We thank Referee 2 for the detailed positive assessment and targeted revision requests.

---

### Must-Fix 1 — RI specification mismatch

**Referee:** Table 6 reports RI p=0.014 on the uncontrolled specification but lacks the RI p-value on the preferred controlled spec (Col. 4). This risks reader confusion about null credibility.

**Response:** We agree and will correct this. As described in our response to Referee 1, Point 2.2 above, we will re-run RI on the preferred specification (Column 4, with electoral safety control, within party×period permutation cells) and report the corrected p-value in Table 6. The main text in Section 6.2 will be revised to report the controlled RI result and remove the current confusing juxtaposition of p=0.014 (uncontrolled) against the null asymptotic result.

---

### Must-Fix 2 — RDD balance table and McCrary statistic

**Referee:** Balance tests are noted verbally in App. B but no table is shown; density described as "smooth" but no McCrary plot or statistic.

**Response:** We agree these are necessary for RD transparency at top journals. We will add to Appendix B:

1. **Balance table.** A formal table reporting means and differences in baseline covariates (gender, party, tenure, prior office, state, east/west indicator) for dual candidates just above and just below the threshold within the main bandwidth (h=5.9pp), with t-statistics for each covariate. A joint F-test for balance will also be reported.

2. **McCrary density test.** We will add the `rddensity` (Cattaneo, Jansson, Ma 2020) statistic and p-value, along with a density plot of the running variable (vote margin) with confidence bands around the threshold. The expectation is that the density is smooth, consistent with the verbal description in the current draft; the formal statistic will confirm this.

---

### High-Value 1 — Green Party exception and party-specific MDEs

**Referee:** The Green Party effect (4.48pp, p<0.001) is intriguing but underexplored. Suggest adding party-specific MDEs and testing parity×interaction.

**Response:** We will expand the treatment of the Green Party exception in Section 7.3. As detailed in our response to Referee 1, Point 3.4 above, we will report cell sizes for Green Party legislators by mandate type and gender, decompose the effect across policy domains (using CAP codes already in the data), and apply Holm-Bonferroni correction to the party-specific heterogeneity results. We will add a brief discussion of whether the effect is consistent with a "critical mass" mechanism (large female share in Green district positions creating different behavioral dynamics) or an organizational culture explanation (Green party norms around grassroots accountability).

Regarding party-specific MDEs: we will add a supplementary table in the appendix reporting MDEs by party, given the substantially smaller within-party samples. This helps calibrate what the party-specific null results can and cannot rule out.

---

### High-Value 2 — Missing MMP/gender comparables

**Referee:** Suggests citing New Zealand (Hanel/Rodriguez 2022 on mandate effects) or Japan (Nemoto/Iida 2016 on women/list) to address external validity.

**Response:** We will add a comparative paragraph in the Introduction or Discussion noting that the MMP system is used in approximately 10 countries, but systematic data on gender gaps in legislative rebellion under MMP are sparse. We will cite Hix, Noury & Roland (2005) on the European Parliament (as also suggested by Referee 1) as the closest available multi-party comparative benchmark. If Hanel/Rodriguez 2022 (New Zealand) and Nemoto/Iida 2016 (Japan) contain directly relevant evidence on gender and mandate type, we will cite them accordingly. We will be explicit that the Bundestag's specific combination of long panel, high discipline, and large female representation makes direct generalization uncertain, but the mechanism — party discipline as the equalizing force — should operate wherever parties exercise strong cohesion norms.

---

### Optional — Free-vote full specification table

**Referee:** Report free-vote full spec (Female/District/interaction table like Table 4).

**Response:** We will add the full free-vote specification to Appendix C, reporting all three coefficients (Female, District, Female×District) with SEs for the free-vote sample. This is a straightforward addition that improves transparency.

---

---

## Response to Referee 3 (Gemini-3-Flash — Minor Revision)

We thank Referee 3 for the positive assessment and focused revision requests.

---

### Must-Fix — Clarify RI discrepancy

**Referee:** RI p=0.014 (uncontrolled) vs asymptotic p=0.50 (preferred spec). For a top journal, RI must match the preferred specification. If RI remains significant while asymptotic is null after the fix, deeper investigation is needed.

**Response:** As detailed in our responses to Referees 1 and 2 above, we will re-run RI on the preferred specification and report the corrected result. We agree that if RI remains significant while asymptotic p-values are null after matching specifications, the discrepancy would require explanation in terms of distributional features or leverage. We do not anticipate this outcome — the OVB from omitting electoral safety is the most plausible explanation — but we will report the corrected results transparently regardless of what we find.

---

### High-Value — Expand on the Green Party mechanism

**Referee:** The Green Party effect (4.48pp given a 2.83% party baseline) is massive. Provide a table or discussion of which policy domains drive it to distinguish "Critical Mass" from "Organizational Culture" explanations.

**Response:** We will add this analysis. Using the CAP policy domain codes already coded in the dataset, we will estimate party×gender×mandate interactions separately by domain for the Green Party subsample and report which domains show the largest female district-member deviation effects. We expect the results will help distinguish whether the Green Party exception is concentrated in issue areas where Green female district MPs have strong local constituency mandates (e.g., energy/environment) or whether it is broad-based. This domain-level decomposition will be reported in Section 7.3 or a new Appendix table.

---

### Optional — Split RDD plot by gender

**Referee:** A version of Figure 5 showing male and female local linear fits separately would visually confirm that treatment effects are virtually identical by gender.

**Response:** We will add this to Figure 5 or a companion figure in the appendix. Specifically, we will plot the RD for male and female dual candidates separately, with local linear fits and 95% confidence bands on each side of the threshold, displayed on the same axes. This will make the "virtually identical" claim visually transparent and will directly address any reader concern that the pooled null conceals heterogeneity.

---

---

## Summary of Changes

The following table summarizes the principal changes committed to in this revision:

| Issue | Source | Action |
|-------|---------|--------|
| RI re-run on preferred spec (Column 4 with electoral safety) | All 3 referees | Will fix; controlled RI p-value added to Table 6 |
| DDD reframed as descriptive decomposition | Referee 1 | Will fix; causal language removed from DDD section |
| Causal claims confined to RD | Referee 1 | Will fix; abstract and conclusion revised |
| RD selection diagnostic (probability of appearing in sample) | Referee 1 | Will add density plot and list-safe sensitivity analysis |
| District sign flip reconciliation | Referee 1 | Will add explicit decomposition by sample restriction |
| McCrary density test (formal statistic) | Referees 1, 2 | Will add to Appendix B |
| Balance table for RD covariates (formal table) | Referees 1, 2 | Will add to Appendix B |
| RD bandwidth sensitivity, polynomial robustness | Referee 1 | Will add to Appendix B |
| Effective N on each side of RD threshold | Referee 1 | Will report in Section 5.2 |
| Party line definition robustness (abstain alternatives) | Referee 1 | Will add to Table 6 / robustness appendix |
| Green Party cell sizes | Referees 1, 2, 3 | Will add in Section 7.3 |
| Green Party policy domain decomposition | Referees 1, 3 | Will add in Section 7.3 / new appendix table |
| Holm correction for party-specific heterogeneity | Referee 1 | Will add to Figure 2 / Section 7.2 |
| Hix, Noury & Roland (2005) EP comparison | Referees 1, 2 | Will add in literature review and Discussion |
| MMP comparables (NZ, Japan) | Referee 2 | Will add in external validity discussion |
| Free-vote full specification table | Referee 2 | Will add to Appendix C |
| RD split by gender (Figure 5 companion) | Referee 3 | Will add as appendix figure |
| 95% CIs on key interaction reported in text | Referee 1 | Will add in Section 6.1 discussion |
| Two-way clustering explanation | Referee 1 | Will verify and explain in Table 6 notes |
| LPM robustness (logit / MP-period fractional) | Referee 1 | Will add to Appendix D |
