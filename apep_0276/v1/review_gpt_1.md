# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-13T13:52:26.253782
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 11444 in / 5795 out
**Response SHA256:** f0ca6eb983e03b13

---

Thank you for the opportunity to review this paper. This is an important and timely question — whether restoring felon voting rights alters Black political participation at the community level — and the author(s) employ a modern staggered-DiD toolkit and the CPS Voting Supplement to address it. The paper is well organized, the central finding (registration up; turnout down or unchanged) is interesting and policy-relevant, and the use of multiple estimators (cell-level DD, Callaway–Sant’Anna, Sun–Abraham, DDD) is appropriate. That said, there are a number of substantive, methodological, and presentation issues that must be addressed before this work is suitable for a top general-interest journal. Below I give a comprehensive review organized by the requested headings: format, statistical/inference issues, identification, literature, writing quality, constructive suggestions, overall assessment, and decision.

1. FORMAT CHECK

- Length: From the LaTeX source, the main text appears substantial (Introduction through Conclusion plus multiple sections and appendices). My best estimate of the rendered main-text length (excluding references and appendices) is roughly 25–35 pages. That meets the usual length expectations for a major journal submission. Please confirm rendered page count and ensure main text is at least 25 pages excluding references/appendix if the journal requires that.

- References: The paper cites many relevant works (Callaway & Sant’Anna, Sun & Abraham, Goodman-Bacon, Burch, Manza & Uggen, etc.). However, I recommend adding/strengthening a few methodological and substantive citations (see Section 4 below). Also ensure the .bib contains all cited entries (I could not inspect the references.bib file here).

- Prose: Major sections (Introduction, Background, Data, Empirical Strategy, Results, Discussion, Conclusion) are written in paragraph form. No major bullet-lists appear except in small enumerations (e.g., the list of identification checks), which is fine.

- Section depth: Most major sections have multiple substantive paragraphs. The Introduction, Background, Conceptual Framework, Data, Strategy, Results, and Discussion sections all have 3+ paragraphs. Good.

- Figures: The LaTeX uses \includegraphics for figures. In this source I cannot render the PDF, so I cannot visually verify axes/labels/data points. Please ensure all figures in the compiled PDF have readable axes, legend entries, and sample sizes noted where relevant. Caption text in the source is informative.

- Tables: The source uses \input{tables/...} for main tables. The main-text reports numeric coefficients and SEs in text (e.g., -0.037 (SE=0.015), +0.023 (SE=0.006)). If the compiled PDF contains real tables with numbers and not placeholders, that is fine. If any table files are missing from submission, include them. Also ensure table notes fully explain variable definitions, units, weights, clustering level, and the number of clusters.

2. STATISTICAL METHODOLOGY (CRITICAL)

A paper cannot pass without proper statistical inference. Overall the paper does a good job, but several necessary clarifications and corrections are needed.

a) Standard errors
- The paper reports standard errors (in parentheses) and p-values for main coefficients. This is good. All main coefficients have SEs in the text and in tables (per the source narrative).

b) Significance testing
- Hypothesis tests are reported (p-values). Good.

c) Confidence intervals
- The paper reports SEs and p-values but does not explicitly display 95% confidence intervals in tables or figures. Top journals expect 95% CIs for main estimates (in tables or event-study plots). Please add 95% confidence intervals in main tables and shaded CI bands in event-study plots.

d) Sample sizes
- The paper reports overall sample counts (1,099,677 respondents) and median cell sizes (median cell contains 74 Black respondents and 1,048 White respondents). However, for each regression/table you must report N (number of state-race-year cells for cell-level DD; number of states × years or number of clusters when using state-level outcome for CS estimator). Also explicitly report the number of clusters used for clustering inference (e.g., number of states) in each table note. If some specifications drop states or cohorts, report the sample size for those specifications as well.

e) DiD with staggered adoption (critical)
- This is handled carefully: the paper uses Callaway & Sant'Anna (2021) and Sun & Abraham (2021) as primary staggered-DiD approaches, in addition to the cell-level DD. That is appropriate and required. Good.
- However, the paper reports divergent signs and magnitudes between the cell-level DD and CS estimator. This is a major issue that needs deeper examination, not just an explanation of weighting differences. The author(s) must:
  - Reconcile why the cell-DD (weighted by cell size with state×year FE and clustering at state) yields a negative and significant turnout gap effect while Callaway-Sant’Anna yields a positive but insignificant ATT. Provide decomposition diagnostics (cohort-level ATTs, cohort sizes, weights, and which cohorts drive each estimator).
  - Provide tables with cohort-specific ATTs (ATT(g,t) or ATT by cohort) so readers can see heterogeneity across cohorts and state sizes.
  - Show sensitivity of the sign/magnitude to reasonable weighting schemes (e.g., population-weighted state gaps, unweighted state gaps, weighting by Black population share). The paper mentions weighting differences but should formally present alternative aggregations and their implications.
  - Report how many cohorts were dropped by CS for a balanced-panel requirement if any, and how that affects inference.
- Also, clarify which version of the CS estimator you use (the paper says “doubly-robust inference” and bootstrapping 1,000 times) and ensure standard errors are appropriately clustered (CS allows clustering; be explicit).

f) RDD
- Not applicable here, but the paper references RDD literature in the review instructions; no RDD tests are necessary.

Additional inference issues and fixes
- Small number of clusters? You cluster at the state level and have ~46 states in the main sample (reversal states excluded). Clustering with 46 clusters is generally acceptable, but if some specifications use smaller numbers (e.g., only treated states or cohorts), asymptotic approximations may be poor. Use wild cluster bootstrap when cluster count is small (<50 is a grey zone; many editors request wild cluster bootstrap as a robustness check). At a minimum: (i) report number of clusters; (ii) show p-values from wild cluster bootstrap as robustness.
- Multiple hypothesis concerns: the paper runs many specifications (turnout, registration, subgroups, placebo). Consider clarifying which are primary outcomes and which are exploratory. If multiple outcomes are tested, discuss multiplicity or show False Discovery Rate adjustments as robustness.
- Measurement/weighting: cell-level outcomes are weighted means. Explicitly show formula for cell weights and why weighting by cell size is preferred. Explore whether using weights equal to population shares (Census population) rather than CPS cell respondent counts changes results.

Bottom line on methodology: The paper largely satisfies basic inference requirements (SEs, clustering, CS/Sun-Abraham). However, the divergent estimators and lack of explicit cohort-level ATTs, 95% CIs, and wild-cluster-bootstrapped p-values are serious issues. Resolve these with additional diagnostics and present CIs in main tables/figures.

3. IDENTIFICATION STRATEGY

Credibility and weaknesses

- Credibility: The staggered DiD comparing Black-White gaps in reform vs never-reform states is a plausible strategy to identify effects on racial gaps when reforms are plausibly exogenous to within-state racial differential trends. The use of state×year FEs and race interaction helps absorb race-neutral, state-time-varying shocks.

- Key assumptions: The paper discusses parallel trends and presents event studies using CS. That is correct. It also presents placebo tests (Hispanic-White gap), concurrent voting law controls, and robustness to excluding reversal states. Good.

- Remaining threats:
  1. Treatment endogeneity. States adopting restoration are not randomized. If adoption coincides with targeted efforts to mobilize Black voters, or follows a period of activism that changes racial turnout trends, estimates may be biased. The paper partially addresses this via event-study pre-trends and placebo tests, but more is needed:
     - Present descriptive balance tests on pre-trend levels and trends for treated vs control states for key pre-treatment covariates separately by race (e.g., unemployment rates, Black party registration share, targeted mobilization expenditures if data available).
     - Show cohort-level trends in the pre-period by cohort to see whether the pre-trends are heterogeneous.
  2. Composition and measurement. The CPS does not identify individual felony status. The chief empirical design measures race-level averages (Black vs White), which conflates direct effects on ex-felons and spillovers. The triple-difference using low/high felony-risk subgroups is a creative fix but relies on the assumption that the low-risk groups are unaffected directly. That assumption is plausible but not ironclad. Please:
     - Provide evidence on felony conviction rates by the demographic subgroups used (women 50+, college-educated, men 25–44 without college) with cites and summary numbers, ideally in table form.
     - Consider additional robustness: test alternate low-risk definitions (e.g., women 40+, or college-educated vs some-college) to show robustness to subgroup definition.
  3. Mechanical composition dilution. The “registered but not voting” explanation is plausible: adding low-propensity new registrants can mechanically reduce the observed turnout rate among Blacks. The paper discusses this plausibly, but it should quantify the mechanical effect more precisely:
     - Produce a back-of-the-envelope decomposition: given best estimates of number of newly eligible, new registration rate, and turnout propensity among newly registered, compute the implied change in aggregate Black turnout. Present a small table or appendix calculation with plausible parameter ranges.
     - If possible, use any external administrative data (state voter registration files for a subset of states or Florida’s administrative records post-Amendment 4) to validate whether newly registered formerly-disenfranchised adults have markedly lower turnout rates.
  4. Migration and composition. If Black population in treated states changes differentially around reform dates (e.g., return migration by ex-felons or relocation of other residents), that could bias cell-level rates. Test whether Black population counts (or CPS population weights) change abruptly post-treatment.
  5. Differential treatment of counties/cities. The treatment is state-level, but some localities might implement local mobilization contemporaneously. Consider exploring heterogeneity by state political context (red vs blue, presence of civil-society organizing groups) or by county-level proxies (if data allow).

- Placebo and robustness checks: The Hispanic-White placebo is a useful negative control. Additional useful placebos that would strengthen identification:
  - Lead-treatment placebo (fake reform dates several years earlier) to show no effects pre-treatment beyond noise.
  - Test outcomes that should not be affected (e.g., rates of school voting by children is not applicable, but civic engagement measures unrelated to voting could work if available).
  - Use pre-treatment covariate balance and event-study significance testing for the earliest leads (tight CI bands) to demonstrate parallel trends more convincingly.

Overall: The identification is plausible but not airtight. The biggest identification concern is the divergence between estimators and the inability to observe felon status. These must be addressed with more evidence and diagnostics.

4. LITERATURE (Provide missing references)

The paper cites many relevant works, but the review and positioning would improve by adding a few methodological and empirical references and clarifying how this paper’s contribution differs from them.

Suggested additions (with brief rationale and BibTeX):

- Goodman-Bacon (2021): foundational decomposition of TWFE bias in staggered designs. Although the paper cites goodman2021, add a full BibTeX and reference when discussing estimator choices and potential biases.
```bibtex
@article{GoodmanBacon2021,
  author = {Goodman-Bacon, Andrew},
  title = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {254--277}
}
```

- Sun & Abraham (2021): event-study estimator addressing heterogeneous treatment effects (you cite sun2021 but include BibTeX).
```bibtex
@article{SunAbraham2021,
  author = {Sun, Liyang and Abraham, Susan},
  title = {Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {175--199}
}
```

- Callaway & Sant’Anna (2021): you use it, but include BibTeX for completeness.
```bibtex
@article{CallawaySantAnna2021,
  author = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title = {Difference-in-Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {200--230}
}
```

- Rambachan & Roth (2023) / HonestDiD: you cite this but include BibTeX; it’s helpful for parallel-trend sensitivity.
```bibtex
@article{RambachanRoth2023,
  author = {Rambachan, Ash and Roth, Jonathan},
  title = {Honest Confidence Sets for Impulse Responses under Conditional Heteroskedasticity},
  journal = {Econometrica},
  year = {2023},
  volume = {91},
  pages = {xxxx--xxxx}
}
```
(If Rambachan & Roth have a different title/year in your sources, please adjust.)

- On voting and felon disenfranchisement: important empirical/disciplinary studies to cite in addition to those already in the paper:
  - Uggen, Manza, Thompson (2006/2020): on felon disenfranchisement and rates; you cite Uggen2022 but ensure citations to classic pieces are present.
  - Burch (2013) and other community-level work are cited; consider including:
    - Manza, Michael and Christopher Uggen. 2006. Locked Out: Felon Disenfranchisement and American Democracy. (If not present.)
```bibtex
@book{ManzaUggen2006,
  author = {Manza, Michael and Uggen, Christopher},
  title = {Locked Out: Felon Disenfranchisement and American Democracy},
  publisher = {Oxford University Press},
  year = {2006}
}
```

  - Gerber, M. et al. studies on turnout of ex-felons / effects of clemency programs (if there are direct studies).
  - Meredith (2009) is cited for turnout of restored citizens; make sure the exact reference is provided (you cite meredith2009).

If there are important empirical papers on the turnout behavior of newly-registered ex-felons or on Florida’s Amendment 4 implementation studies, include them (e.g., studies using administrative data). Specific candidate papers:
- LaForest, et al. analyses of Amendment 4 implementation — include any peer-reviewed/working-paper evidence that newly-enfranchised individuals have low turnout or face financial barriers.

Why these matter: they help place your contribution — showing that prior work documents direct effects on restored individuals and mobilization changes, while your paper addresses community-level spillovers using staggered DiD.

5. WRITING QUALITY (CRITICAL)

Overall the prose is good and generally at the level expected for a top journal. Specific comments:

a) Prose vs. bullets
- Major sections are written in full paragraphs. No fail here.

b) Narrative flow
- Solid. The Introduction hooks with a strong motivating fact and states clear hypotheses. The conceptual framework clarifies testable predictions. The Results section is organized and compares registration vs turnout cleanly. Maintain the narrative strength.

c) Sentence quality
- Prose is crisp and readable for an academic audience. Consider trimming some repetitive sentences in the Discussion.

d) Accessibility
- Intuition for econometric choices is provided; make the intuition even clearer in one consolidated paragraph: why use Black-White gap (controls for race-neutral state-time shocks), why use CS estimator, and why the DDD isolates spillovers.

e) Tables
- Ensure each table has full notes: define outcome variable (e.g., turnout = fraction of respondents in cell reporting voted; registration = fraction reporting registered), state cluster count, weights used, whether SEs are clustered, sample size (cells), and the time period. For event-study and CS plots, include 95% CI bands and a table of event-study coefficients in appendix (you refer to it; ensure it is present and clearly labeled).

6. CONSTRUCTIVE SUGGESTIONS (to strengthen the paper)

Data & empirical extensions
- Attempt to validate the mechanical composition channel with external administrative data where possible. For example:
  - Use state voter files where accessible (some states publish public registration rolls) to directly observe the registration surge among restored individuals in a subset of states (Florida, California) and track their turnout across elections.
  - If administrative linkage is impossible, consider combining CPS results with Sentencing Project or BJS microdata to more precisely estimate the size of the newly eligible population and their likely turnout contribution.
- Report cohort-specific ATTs and a table showing which cohorts/states drive the positive CS ATT and which drive the negative cell-DD estimate. If small cohorts produce large positive CS ATTs, discuss external validity.
- Provide wild-cluster-bootstrap p-values for clustered SEs (especially for clustered specifications with smaller clusters).
- Present 95% CIs for main estimates in tables and plots. Also show effect sizes relative to baseline turnout/reg rates (e.g., -3.7 pp relative to mean Black turnout of X%).
- Conduct an alternative individual-level regression (rather than collapsed cells) with person-level outcome and individual covariates, interacting Black and reform, and using state×year FE as in the main design. This can help with power and allow inclusion of demographic covariates. Use survey weights and cluster at state. Compare cell-level and individual-level results.
- Explore placebos that randomly assign reform dates to never-treated states to evaluate empirical distribution of effects and show how extreme the observed coefficient is.

Mechanisms & heterogeneity
- Flesh out the mechanical decomposition quantitatively and present it as a table. This is one of the paper’s most important interpretations; quantify how much of the -3.7 pp could be explained mechanically.
- Investigate whether registration rises are concentrated among age/gender/education subgroups (are new registrants predominantly men 25–44?). This would support the composition story.
- Explore heterogeneity by state implementation detail (e.g., Florida’s fines/fees implementation differed from other states; registration-to-vote friction likely varies). Present state-level heterogeneity in a figure or table.
- Consider event-study plots for registration and turnout by subgroup (high-risk vs low-risk) and by large-reform states (e.g., Florida, California, if included).

Robustness and transparency
- Add a table listing the 22 treated states, the reform type (legislative/executive/ballot), the exact effective date, and how you coded the first treated election (maybe already present in tab2_reform_timing — ensure it’s in PDF).
- Make the data and code publicly available (you link to a GitHub repo — ensure replication materials are complete and include the treatment timing database, the code to collapse CPS to cells, and the code implementing CS/SunAbraham).
- Include placebo leads (e.g., pretend reform occurred 2 elections earlier) and report those coefficients.
- Provide power calculations or minimal detectable effects given sample sizes and cluster counts, especially for the event-study and DDD tests.

Presentation
- Emphasize in the abstract and introduction that registration increases but turnout does not, and note mechanical dilution as main interpretation. Many readers will want this succinctly upfront.
- Add a short paragraph in the Methods/Data summarizing limitations of CPS self-reported turnout and how that may bias estimates (CPS over-reporting could interact with newly registered ex-felons who may be less prone to over-reporting).

7. OVERALL ASSESSMENT

Key strengths
- Important policy question with broad public interest.
- Use of modern staggered-DiD estimators (Callaway–Sant’Anna, Sun–Abraham) plus a traditional cell-level DD and triple-difference identification is methodologically strong.
- Creative DDD using felony-risk subgroups to test spillovers.
- Clear and accessible writing; a compelling narrative linking registration increases to a lack of turnout increase.

Critical weaknesses (must be addressed)
- Divergent results between the cell-level DD (significant negative turnout effect) and Callaway–Sant’Anna (insignificant positive ATT). This divergence undermines the core inference and requires a careful decomposition (cohort-specific ATTs, weight analyses, explanation of which estimator better captures the policy question).
- Lack of explicit 95% CIs and insufficient reporting of cluster counts and sample sizes for each regression/table.
- Identification depends on CPS (which does not observe felony status) and on the assumption that low-risk subgroups are unaffected directly. Strengthen this with additional evidence, sensitivity analyses, and decomposition of mechanical effects.
- Need for additional robustness to small-cluster inference (wild cluster bootstrap) and more thorough pre-trend/lead placebo testing.
- Some important literature (Goodman-Bacon, Sun & Abraham, cohort-specific treatments) should be explicitly cited with BibTeX entries if not already.

Specific suggestions for improvement (concise)
- Add cohort-level ATTs and weight decomposition showing which states/cohorts drive each estimator’s result.
- Add 95% CIs everywhere and wild-cluster-bootstrap p-values for clustered SEs.
- Perform an individual-level regression and compare to cell-DD.
- Quantify the mechanical composition effect with explicit calculations.
- Provide additional robustness: placebo leads, alternate subgroup definitions, and alternate weighting schemes (population-weighted vs CPS cell-weighted vs unweighted).
- If feasible, validate claims about newly-registered ex-felon turnout using administrative voter files in a subset of states.

8. DECISION

This is a promising paper that addresses an important question with appropriate modern methods. However, the divergence across estimators and the need for deeper robustness checks and mechanistic evidence are serious and central. The paper is therefore not yet ready for acceptance; substantial revisions and additional analyses are required.

DECISION: MAJOR REVISION

(If the authors address the estimator divergence, provide cohort-level ATTs and decomposition, include 95% CIs and wild-cluster-bootstrap inference, quantify the mechanical dilution, and strengthen the mechanism evidence as described above, the paper could become suitable for a top general-interest journal.)