# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-13T17:13:01.062007
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 17058 in / 5928 out
**Response SHA256:** e43c8827c0d08286

---

Thank you for the opportunity to review. This is an interesting and policy-relevant paper: a clean, well-motivated question, careful use of modern staggered-DiD methods, and a large data source spanning many years. The null finding is informative and well motivated. Below I give a structured, comprehensive referee report covering format, methodology, identification, literature, writing, concrete suggestions for strengthening the paper, and an overall assessment and decision.

1. FORMAT CHECK

- Length: The main manuscript (excluding references and appendix) appears to be roughly 30+ pages (Introduction through Conclusion plus Figures/Tables embedded) and the appendix adds substantial material. So the overall length is acceptable for a top journal submission.

- References: The bibliography includes many relevant citations (Callaway & Sant’Anna, Goodman-Bacon is mentioned in-text, Adda 2010, CDC reports, etc.). However some fundamental methodological and data-quality references are missing (see Section 4 below). Also there should be more engagement with the tobacco-policy literature on concurrent state-level policies (taxes, program spending), and literature on BRFSS survey design changes (weighting/mode) that could affect comparability over time.

- Prose: Major sections are written in paragraphs (Intro, Institutional Background, Data, Empirical Strategy, Results, Discussion, Conclusion). Good.

- Section depth: Major sections (Intro, Institutional Background, Conceptual Framework, Data, Strategy, Results, Robustness, Discussion) are substantive; each has 3+ paragraphs (except perhaps some shorter subsections), so depth is adequate.

- Figures: Figures appear to be included via \includegraphics; captions are informative. In the LaTeX source figures are referenced and described; I could not render the images here, but captions indicate axes and notes. When preparing the submission, confirm that all figure axes are labeled, scales legible, and that color/shade choices are accessible in grayscale print.

- Tables: Tables are referenced by \input{tables/...}. The main text quotes coefficient estimates and SEs (e.g., ATT = -0.0027 (SE = 0.0031)). The paper appears to have real numbers in tables rather than placeholders. In the final submission, ensure table notes clearly define units, sample, and what each column displays.

Formatting issues to fix (minor)
- Consistent citation formatting: several in-text citations appear to be shorthand in the source (e.g., \citet{goodman2021difference} vs. \citet{goodman2021difference, de2020two} — ensure bibliography entries match and are complete).
- Table and figure numbering: make sure cross-references (\Cref{tab:main_results} etc.) match the final compiled numbering.
- Replication link and data-access statements should include version and DOI/Zenodo if possible.

2. STATISTICAL METHODOLOGY (CRITICAL)

The paper recognizes correctly that modern staggered-adoption DiD requires modern estimators, and implements the doubly-robust Callaway–Sant’Anna (CS) estimator. That is the right direction. Below I evaluate each required element from your checklist.

a) Standard Errors
- The paper reports SEs (e.g., SE = 0.0031) and reports 95% CIs in places. It also states clustering at the state level. This passes the requirement that coefficients have SEs/CIs. Ensure all reported coefficients in tables have SEs (parentheses) and that figures showing event studies have pointwise 95% CIs.

b) Significance testing
- The paper reports p-values and performs randomization inference (RI). Good.

c) Confidence intervals
- 95% CIs are referenced and used (e.g., “The confidence interval for the prevalence effect ([-0.009, 0.003])”). Make sure all main results table rows list 95% CIs (either explicitly or via SE and threshold).

d) Sample sizes
- The main text reports sample size in aggregate (7.5 million BRFSS observations) and state-year panel cell counts (1,120 cells). However, N should also be reported for each regression / outcome: e.g., number of state-year observations used for each outcome, number of ever-smokers for quit-attempt regressions, and number of contributing cohorts per event-time cell. Table notes should list N for each estimated model (both raw N and number of clusters = 51). Right now the manuscript notes the quit-attempt panel “contains fewer state-year observations; exact count reported in \Cref{tab:main_results}” — ensure that table indeed shows Ns. Add per-estimate Ns.

e) DiD with staggered adoption
- PASS: the paper uses Callaway & Sant'Anna DR estimator and never-treated as the primary control group. This addresses the canonical bias of simple TWFE under staggered adoption. The paper additionally compares to TWFE estimates and reports that results are similar — useful diagnostic.

Important details and potential methodological concerns (must address)
1) Base period / pre-treatment windows and treatment definition
- You choose base_period = "universal" and include adoption year as treated (but you also report dropping the partial-exposure year as a robustness check). This is acceptable but you must be explicit throughout (tables/figure notes) about which specification is main and which are robustness. Because the adoption year often contains both pre/post interviews, using the adoption year as treated could attenuate short-run effects; I recommend making the main specification the one with adoption year dropped (or at least present both as equally prominent). At minimum, show main-table columns for: (A) adoption-year included, (B) adoption-year excluded.

2) Use of never-treated as control
- Using never-treated states as controls is standard. The paper also reports robustness using not-yet-treated which is good. Still, given selection into treatment (treated states have lower pre-treatment smoking prevalence), include evidence that the propensity score model used in the DR step balances key covariates and smoking levels across cohorts after weighting (balance tables/plots). Show whether re-weighting shifts covariate means and pre-trends.

3) Aggregation to state-year cell means vs. individual-level estimation
- The paper constructs state-year means and then runs CS-DiD at the state-year panel level (I infer this because you say you aggregate into a state-year panel of 1,120 cells). Callaway–Sant’Anna supports individual-level panel data (units = individuals with unit fixed effects or group indicators); aggregating to state-year is fine but sacrifices variation (and complicates use of individual-level covariates and survey weights) and may understate SEs, or at least change inference. Two requests:
  - Justify the aggregation choice explicitly and show main results re-estimated at the individual level (outcome = individual current smoking, with individual covariates, clustering at state). Doing the CS DR estimator on individual-level data will (a) exploit microvariation, (b) allow direct inclusion of survey weights more straightforwardly, and (c) permit richer heterogeneity (age, gender, race). If computational burden is a concern, show a representative individual-level specification as a supplementary table.
  - Report whether results differ between state-year aggregated and individual-level analyses.

4) BRFSS sampling weights and survey redesigns
- The BRFSS changed design and weighting (notably 2011 the adoption of raking and inclusion of cellular telephone respondents) and there were other methodological updates that affect comparability across years. The paper uses the final sampling weight (\_LLCPWT) to construct survey-weighted estimates. But the manuscript does not cite or discuss BRFSS redesign issues and their implications. This is important: if treated and control states differ in sampling mode trends or in the timing of state-level uptake of cell-phone interviews, this could bias measured smoking rates over time. Action items:
  - Cite the BRFSS methodological notes (e.g., CDC documentation, Pierannunzi et al. (2013) or related BRFSS methodology papers) describing weighting and design changes and discuss how changes were accommodated.
  - As a robustness check, re-run analyses restricted to years before the major redesign (or to post-redesign years only) and show results are similar. Alternatively, include interview mode shares or indicators for pre- vs post-weighting change as controls, or include state-specific linear trends to absorb state-level structural breaks.
  - Provide balance/summary statistics across redesign boundaries and show that the treatment effect is not driven by those years.

5) Concurrent tobacco-control policies / controls
- You include cigarette excise taxes and Medicaid expansion. But other relevant time-varying confounders include:
  - State tobacco-control program funding (media campaigns, cessation program spending) — these can vary and correlate with both bans and quit attempts.
  - Local ordinances and pre-existing local bans (in many states bans began at city/county level before state adoption).
  - Changes in smoke-free workplace enforcement intensity, smoke-free housing policies, and large federal policies (e.g., 2009 federal tax increase you note).
  - E-cigarette availability/use trends and state-level vaping policies (these can change smoking patterns and quit attempts).
- I recommend assembling and adding more state-level time-varying controls (program spending, local ban coverage indicators, cigarette price including taxes and retail price indices, e-cigarette prevalence proxies) or doing sensitivity analysis showing results are robust to inclusion of these variables. If data are not available for all years, show alternative specifications restricted to years where controls exist.

6) Inference and clustering
- You cluster at the state level (51 clusters). Good. But because the number of clusters is moderate, consider reporting wild cluster bootstrap p-values as an additional robustness check, especially for borderline results (e.g., everyday smoking increase). Also, for CS estimator the appropriate variance estimation is implemented in the did package — report exactly how SEs were computed (analytic bootstrap? influence function?) and whether the cluster-robust SEs rely on asymptotics that are appropriate with 51 clusters.

7) Power
- You discuss minimum detectable effect of roughly 1–2 percentage points which is helpful. Please show formal power calculations (table or appendix) with the actual variance observed in the data and the effective number of independent observations (taking into account clustering and staggered adoption) so readers can evaluate whether the null is meaningful.

8) Event study granularity and attrition of cohorts at long horizons
- The paper correctly notes that later event times have fewer contributing cohorts and thus wider CIs. In event-study figures add the number of cohorts contributing at each event time as a small table/panel under the x-axis or as text to remind readers which coefficients are well-identified.

9) Placebo and falsification tests
- You perform RI permutations and a never-smokers placebo. That’s good. Consider adding:
  - A placebo treatment year test (assign false placebo adoption years to treated states and re-estimate).
  - A test using outcomes that should not respond (e.g., vaccination uptake or other unrelated health behavior) to check for spurious correlation.

f) RDD requirements
- Not applicable (no RDD used).

Summary: methodological choices are generally appropriate and the use of Callaway–Sant’Anna DR estimator is a strength. The main methodological weaknesses are (i) possible measurement issues related to BRFSS redesign; (ii) aggregation at the state-year level rather than individual-level specification; (iii) incomplete adjustment for other time-varying tobacco policies and local ordinances. These are fixable but important.

3. IDENTIFICATION STRATEGY

Is identification credible?
- The causal parameter (ATT for treated states) is clearly stated and the use of CS estimator addresses staggered adoption bias. The authors explicitly discuss parallel-trends concerns and provide event-study pre-trend evidence. This is the right approach.

Key assumptions discussed?
- Yes: the paper states the parallel trends assumption and implements event studies and Rambachan & Roth (HonestDiD) sensitivity analysis.

Placebo tests and robustness checks
- The paper performs several robustness checks: leave-one-region-out, not-yet-treated controls, dropping adoption year, randomization inference permutations, and placebo on never-smokers. It also does border-state comparisons (appendix). These are helpful.

Do conclusions follow from the evidence?
- The main conclusion — that comprehensive indoor smoking bans did not lead to detectable increases in quit attempts or large reductions in overall smoking, and thus do not provide strong evidence of broad private norm internalization — follows from the reported null ATTs and event studies. However, because of the power limitations and possible confounders above, the conclusion should be framed a bit more cautiously: the paper can rule out effects larger than roughly 1 percentage point (5% of baseline) but cannot rule out smaller effects or effects concentrated in subpopulations not captured at state-year aggregation.

Limitations discussed?
- The manuscript has a candid limitations section covering parallel trends untestability, concurrent policies, BRFSS self-report bias, missing years, and lack of direct measures of norms. That is good. However, as noted, the discussion should be expanded to address BRFSS redesign concerns and potential attenuation bias from defining adoption-year as treated.

4. LITERATURE (Provide missing references)

The paper cites many relevant works but is missing several foundational or directly related references that are important to position the contribution. Below I list recommended additions, why they matter, and provide BibTeX entries.

A. Staggered DiD and recent methodological papers the paper should cite and engage with explicitly (some are mentioned in text but not all appear in the bibliography):

- Goodman-Bacon (2021) — decomposition of TWFE
- Sun & Abraham (2021) — event-study estimator and discussion of TWFE biases for heterogeneous effects
- Rambachan & Roth (2023) — HonestDiD sensitivity (you cite this, but ensure full reference)
- Borusyak, Jaravel, & Spiess (2022) or Borusyak & Jaravel (2017/2021) on two-way fixed effects revisited (you have Borusyak referenced; ensure bib entry)
- Roth (2022) or Roth & Sant’Anna for pre-trend testing warnings

BibTeX entries:

```bibtex
@article{goodman2021difference,
  author = {Goodman-Bacon, Andrew},
  title = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {254--277}
}
```

```bibtex
@article{sun2021estimating,
  author = {Sun, Liyang and Abraham, Sarah},
  title = {Estimating dynamic treatment effects in event studies with heterogeneous treatment effects},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {175--199}
}
```

```bibtex
@article{rambachan2023more,
  author = {Rambachan, Ashesh and Roth, Jonathan},
  title = {More credible inference for difference-in-differences},
  journal = {Journal of Econometrics},
  year = {2023},
  volume = {249},
  pages = {110--142}
}
```

```bibtex
@article{borusyak2022revisiting,
  author = {Borusyak, Kirill and Jaravel, Xavier},
  title = {Revisiting event study designs},
  journal = {Econometrica},
  year = {2022},
  volume = {90},
  pages = {1737--1774}
}
```

B. BRFSS survey design and weighting changes (critical to address):
- Pierannunzi, Hu, & Balluz (2013) — description of BRFSS, weighting and design changes
- CDC BRFSS methodological reports (2011 change to raking; cell-phone inclusion)

BibTeX entries (approximate—please check exact details & page numbers for final bib):

```bibtex
@techreport{pierannunzi2013description,
  author = {Pierannunzi, C. and Hu, S. and Balluz, L.},
  title = {A Description of the Behavioral Risk Factor Surveillance System (BRFSS)},
  institution = {Centers for Disease Control and Prevention, CDC},
  year = {2013}
}
```

(If you cite CDC pages directly, include web citations for the BRFSS methodology and the 2011 weighting change.)

C. Tobacco-control literature on displacement and ban effects:
- Adda & Cornaglia (2010) — you cite this, good.
- Carpenter & Cook (2008/2011) — you cited Carpenter 2011 but include Carpenter & Cook 2008 on secondhand smoke/mortality? Ensure all major empirical works on smoking bans and health/consumption are included (e.g., Meyers et al. 2009, Mackay et al. 2010 — you cite some).

D. Norms and expressive law literature:
- Sunstein (1996) and McAdams (2000) are cited; consider adding Bicchieri (2006) or follow-up works on norms and legal change (you cite Bicchieri 2005; consider Bicchieri 2016).

E. Papers on BRFSS-based policy evaluation and potential pitfalls (examples)
- Klein, G., (2016) — sample of papers that discuss BRFSS comparability across years; include any paper that documents time-series discontinuities related to weighting changes.

If any of these are already in your references, ensure full citations are present and that you engage them in the literature review / methods.

5. WRITING QUALITY (CRITICAL)

Overall the paper is well written — clear motivation, logical flow, and the narrative is persuasive. A few points to improve readability and accessibility:

a) Prose vs bullets
- The conceptual framework currently uses bullet lists for predictions C1–C4 and N1–N4. That is acceptable, but in the main text you might also briefly synthesize these bullets in a paragraph to improve narrative flow.

b) Narrative flow
- The Introduction is strong and hooks the reader. Consider emphasizing earlier the precise empirical test (quit attempts as the sharp test of norm internalization) so readers know up front what the single most informative outcome is.

c) Sentence quality
- Generally crisp. A few long sentences can be shortened for readability (e.g., the paragraph summarizing BRFSS availability/years could be split). Place key numerical magnitudes at the start of the paragraph when possible (e.g., "The ATT on current smoking prevalence is -0.0027 (SE=0.0031), i.e., less than three-tenths of a percentage point.").

d) Accessibility
- You explain the intuition behind the CS-DiD estimator but might add one short sentence on why the “doubly-robust” aspect matters (practically: guards against misspecification of either the propensity score or outcome model). You already mention this; consider a footnote clarifying the exact models used (logit/probit for propensity, linear outcome regression with covariates) so an applied reader can replicate.

e) Tables and notes
- Table notes should explicitly state: unit of observation, whether weights were used and how, clustering, base period choice, treatment definition (adoption-year included/excluded), and sample N (both individuals and state-years). For event-study figures include the number of cohorts contributing to each event-time.

6. CONSTRUCTIVE SUGGESTIONS (How to make it stronger)

Below are concrete analyses and presentation changes that would materially strengthen the paper and address remaining concerns.

A. Address BRFSS design/weighting changes
- Add explicit discussion and citation of BRFSS methodology changes (2011 raking/phone inclusion). Run robustness checks:
  - Restrict sample to continuous period before the main redesign and show the results are similar.
  - Restrict to the post-redesign period only (if feasible) as another check.
  - Add an indicator for pre/post BRFSS redesign in the outcome regression or allow for a break in state-specific trends at the redesign year.
  - Show balance of sample composition across the redesign year for treated and control states.

B. Re-estimate at individual level
- Re-run the main CS-DR estimator at the individual level (outcome is indicator for current smoking / quit attempt; state and year fixed effects as appropriate; cluster at state; incorporate \_LLCPWT survey weights or use regression with weights). Compare aggregated-state estimates to micro estimates. This will also allow you to:
  - Explore heterogeneity by age/cohort (young adults vs older adults), race/ethnicity, and worker status (e.g., hospitality workers) — perhaps norms operate in narrower groups.
  - Interact treatment with measures of local social norms (if any proxies exist) or with county-level smoking prevalence.

C. Enrich control list and sensitivity to concurrent policies
- Add state-level tobacco-control program spending, local smoke-free ordinances coverage (percent of population covered by local bans before state-level ban), e-cigarette prevalence or policy proxies, and cigarette price indexes. If these data are unavailable for all years, show a restricted-sample robustness with these additional controls.

D. Direct measures of norms
- The BRFSS lacks direct normative questions, but other surveys have questions about attitudes toward smoking (e.g., General Social Survey, Tobacco Use Supplement to the Current Population Survey, or Pew/ANES modules). Consider:
  - Bringing in (where feasible) complementary evidence from attitude surveys on whether attitudes toward smoking changed in treated vs control states.
  - If not possible, state explicitly that the paper measures behavior not beliefs and discuss the implications.

E. Decompose everyday vs some-days vs quitters more explicitly
- You already present evidence that the everyday increase and some-days decline sum to nearly zero and that the total prevalence is unchanged. Make this decomposition a clear table (and possibly a figure) to show the mechanical accounting identity. Also examine whether the “some-day” decline is concentrated among certain demographic groups.

F. Show propensity-score balance and weighted pre-trends
- Display covariate balance before and after weighting by the estimated propensity scores (for each cohort or overall). Show pre-trend graphs after DR weighting to demonstrate that weighting improves parallel trends.

G. Event-study: indicate contributing cohorts and effective sample sizes
- For each event-time x-axis tick include a small label or table showing how many cohorts/states contributed; discuss robustness where few cohorts contribute.

H. Alternative estimators and cross-checks
- Present Sun & Abraham event-study estimates or the imputation-based estimator as an additional robustness check (in addition to CS-DR). While CS is fine, reporting an alternative estimate improves credibility.
- Consider a synthetic-control style check for a few illustrative states (e.g., Delaware 2002, New York 2003, Massachusetts 2004) to demonstrate the same null.

I. Power and MDE
- Include formal power calculations tailored to the effective sample (51 clusters, number of treated clusters, variance observed) to support the claim about detectability and to interpret the null.

J. Clarify implementation details
- In the appendix (Identification Appendix) you explain did package options. Add explicit model forms: which covariates in the propensity model, functional forms (logit?), how outcome regressions are specified, and whether you estimate separate models by cohort or pooled.

7. OVERALL ASSESSMENT

Key strengths
- Clean, policy-relevant question with clear theory distinguishing compliance vs norm channels.
- Use of modern staggered-adoption methodology (Callaway & Sant'Anna doubly-robust estimator).
- Large, long BRFSS dataset and multiple robustness checks (event study, region leave-one-out, RI, border analysis).
- Honest and careful discussion of limitations and power.

Critical weaknesses (fixable)
- Potentially important BRFSS measurement/design issues (weighting/mode changes and missing years) are not sufficiently discussed or handled in robustness checks.
- Aggregation to state-year means rather than micro-level CS estimation loses information and complicates interpretation with survey weights and heterogeneity. Individual-level re-estimation is recommended.
- Incomplete control for concurrent, potentially confounding tobacco-control policies (program spending, local ordinances, e-cigarette trends).
- Need to add a few key methodological citations to the literature review and show propensity-score balance.
- More precise reporting of sample sizes per estimate and clear statement of main vs robustness specifications (adoption year handling).

Specific suggestions for improvement (summary)
- Re-run core analyses at the individual level using the CS-DR estimator (or provide reasoned justification for aggregated approach).
- Address BRFSS redesign: add citations, run pre/post redesign robustness or adjust models as needed.
- Expand state-time controls and show robustness to their inclusion.
- Add propensity score balance diagnostics and show post-weighting pre-trends.
- Add direct evidence on normative beliefs if possible (GSS/CPS supplement) or explicitly frame limitations as measuring behavior, not beliefs.
- Provide power calculations and indicate number of cohorts contributing to each event-time in figures.

8. DECISION (REQUIRED)

Given strengths and the important but fixable concerns above, my recommendation is that the paper is promising and salvageable, but needs additional substantive robustness checks and clearer discussion of survey-design issues before it is suitable for a top general-interest or field-top journal.

DECISION: MAJOR REVISION

(Reasoning: the paper has solid core methods and valuable results, but issues that could materially affect inference—BRFSS redesign and aggregation choices, and additional state-level confounders—must be addressed. These are fixable but non-trivial, hence a major revision.)