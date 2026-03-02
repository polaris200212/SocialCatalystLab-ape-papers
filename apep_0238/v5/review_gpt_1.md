# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-13T02:16:59.687386
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 25592 in / 6187 out
**Response SHA256:** 7e832e4ed5a8c8d2

---

Summary
This is an interesting, timely, and well-motivated paper that compares the long-run labor-market effects of two large US downturns—the Great Recession (characterized as demand-driven) and the COVID shock (characterized as supply-driven). The author uses cross-state local projections (LPs) to show that states exposed to the housing boom/bust experienced persistent employment scarring, while states exposed to COVID-industry shocks recovered quickly. A calibrated search-and-matching model with endogenous participation and skill depreciation is used to rationalize the asymmetry and to perform counterfactual/welfare calculations.

The paper has the potential to make a strong contribution: it combines reduced-form evidence across two recessions with a structural mechanism to quantify how and why demand shocks can permanently scar the labor market while supply shocks do not. That said, several important methodological, identification, inference, and exposition issues must be addressed before this is suitable for a top general-interest journal.

Below I follow your requested review structure.

1) FORMAT CHECK

- Length: The LaTeX source (main text + extensive appendix) is long. Judging by the amount of main text and the multiple appendices, the manuscript is well over 25 pages excluding references/appendix (likely in the 40–70 page range including appendices). This satisfies the length criterion for a top journal submission.

- References: The .tex cites an extensive set of papers throughout the text, but I could not inspect the rendered bibliography (the source calls \bibliography{references}, but that file is not shown). Ensure the final compiled PDF includes a complete bibliography. See Section 4 below for additional specific methodological and topical citations that should be added.

- Prose: Major sections (Introduction, Institutional Background, Conceptual Framework, Data, Empirical Strategy, Results, Mechanisms, Model Estimation, Robustness, Conclusion) are written in paragraphs, not bullets. Good.

- Section depth: Major sections are substantive. Most major sections contain multiple paragraphs and sub-sections, e.g., Conceptual Framework, Data, Empirical Strategy, Results, Mechanisms, Model Estimation. Sufficient depth overall.

- Figures: Figures are included via \includegraphics; I could not view the rendered PDF here. In the LaTeX source figures appear to be in Figures/ and are referenced and captioned. Verify in the compiled PDF that all figures display actual data (no placeholder graphics), have readable axes and labels, and include 95% confidence interval shading where stated.

- Tables: The main text uses \input for tables (e.g., tables/tab1_summary.tex). Several appendix tables (e.g., pretrend, LFPR) show coefficients and standard errors in the source; main tables should be checked in the compiled PDF to ensure all coefficients are reported with standard errors or confidence intervals and sample sizes N are shown. Ensure there are no placeholder numbers in any table.

Format recommendations (fixable):
- Include explicit sample size (N) and number of clusters (if clustering) in the notes of every table and in figure captions where regressions are summarized. Some appendix tables have N=50 but make this explicit in every main-table note.
- Ensure all main-text tables include standard errors (or CIs) in parentheses and indicate the inference method (HC1, cluster, permutation).
- Provide 95% confidence intervals in main figures (your text says HC1 CIs are plotted—show them).
- Ensure the compiled bibliography is complete and formatted per journal style.

2) STATISTICAL METHODOLOGY (CRITICAL)

This is the most important section. A paper cannot pass without correct inference and clear handling of identification threats.

a) Standard errors and reporting
- The text states that HC1 robust standard errors are used and that permutation p-values (1,000 draws) are reported “in brackets in Table 2,” and that cluster-by-division (9 clusters) checks are included in Appendix. Appendix tables show HC1 standard errors in parentheses for many regressions. That is good practice. However:
  - I could not see the main tables (they are input from external files). Please ensure every reported coefficient in the main tables is accompanied by standard errors (or CIs) and that 95% CIs are also displayed in the corresponding figures.
  - In addition to HC1, the paper should prominently present inference robust to the small cross-sectional sample (N = 50). With only 50 state observations, standard HC1 inference can be misleading. The author already reports division clustering but there are only nine clusters—standard cluster-robust asymptotics are suspect. I recommend:
    - Reporting wild cluster bootstrap p-values when clustering (http://dx.doi.org/10.1016/j.jeconom.2019.08.005).
    - Presenting permutation inference prominently (you already have permutations for IV/Bartik) but make clear how permutation maintains observables (e.g., permute exposure among states conditional on covariates or use residual permutation), and place those p-values in main tables/figures (not just appendix).
    - For shift-share (Bartik) inference, use the exposure-robust standard errors (Adao, Kolesár & Morales 2019) and the Borusyak-Hull (2022)/Adão variants as robustness.

b) Significance testing and CIs
- Main results should present 95% confidence intervals for β_h at each horizon in the main figures and tables (text mentions HC1 95% CIs are shaded; make sure they are present and described).
- Permutation p-values should be reported alongside HC1 and clustered p-values.

c) Sample sizes
- The manuscript states that the cross-sectional LP is estimated on 50 states. Report N in each table and note if any regressions use fewer observations (e.g., COVID horizons limited to 48 months, some LP horizons may have smaller effective sample). In certain robustness subsamples (exclude Sand States) provide the reduced N.

d) DiD / Staggered adoption concern
- The paper does not use TWFE staggered DiD; it uses cross-sectional local projections at single event dates. The primary warnings about TWFE/staggered DiD (Goodman-Bacon, Callaway & Sant’Anna) do not directly apply. The author correctly justifies using LP since exposure is continuous and event timing is fixed. This is acceptable.

e) Shift-share / Bartik inference
- The paper uses a Bartik exposure for COVID. The author notes the use of leave-one-out national industry shocks and mentions Adao et al. exposure-robust standard errors. That is good practice; please:
  - Explicitly report the Adao-Kolesar-Morales standard errors and permutation tests for the Bartik results in the main table/figure and describe implementation details (number of industries J, leave-one-out formula).
  - Report first-stage diagnostics for the Bartik (show variation across states; report standard deviation of the Bartik and the per-1-SD effect for interpretability — you already do this in some places; make it systematic).

f) Other methodology items
- Local projections: LPs are a flexible reduced-form approach for dynamic effects; but the regressions used are cross-sectional (Δ y_{s,h} on Z_s and pre-recession covariates). This is effectively a cross-section of long differences rather than time-series LPs. That is fine, but emphasize why cross-sectional LP (single-event cross-section) identifies heterogeneous cross-state impulse responses and what assumptions are needed (e.g., no omitted state-level determinants correlated with Z_s that affect long-run employment).
- Pre-trends: The author shows pre-trend checks (Figure in appendix). Good. Given only 50 observations, show quantile-based placebo and randomization inference as you already partly do.
- Migration and other confounders: The LP coefficient on employment levels conflates local scarring with out-migration. The paper argues migration likely understates scarring and cites literature, but you should provide direct checks (see suggestions below).

Fundamental methodological issues (fatal vs. fixable)
- I do NOT consider the paper fatally flawed on methodology, but several important threats to identification and inference require additional empirical work to be convincing for a top journal:
  1. Exogeneity of the housing-boom exposure is plausibly but not incontrovertibly exogenous. The author controls for pre-trends and pre-recession growth; scholars often instrument housing-boom exposure with exogenous supply-side determinants (see Saiz 2010 on geographic housing supply) or include additional controls (credit-supply shocks, local mortgage-lending expansion). I recommend more extensive sensitivity checks and, if possible, an IV first-stage using plausibly exogenous predictors.
  2. Small-sample inference: N=50 means conventional standard errors are fragile. The author must make permutation/wild-bootstrap/interquartile inference a primary inference method and include it in all main tables and figures.
  3. Mechanism identification: the participation and skill-depreciation channels are central, yet the state-level LP for LFPR is inconclusive (as the author acknowledges). More worker-level evidence is needed to link exposure to durations, skill loss, and exits cleanly.

Below I give concrete suggestions to fix these issues.

Suggested fixes and additions (statistical methodology)
- Make permutation inference and exposure-robust shift-share standard errors a front-and-center part of the main results (present HC1, clustered, permutation, and exposure-robust SEs side-by-side in one main table).
- Provide wild cluster bootstrap p-values when doing census-division clustering (9 clusters).
- Show first-stage or at least show the predictive strength (partial R^2) of the housing boom on short-run employment declines (this is referred to in the text but should be tabulated). If using IV, report F-statistics.
- Provide a simple Monte Carlo / placebo exercise on synthetic data (e.g., permuted exposures) to illustrate the distribution of estimates under the null (you have permutation exercises in appendix—move key ones to main text).
- Clarify exactly how the LP is implemented: OLS on N=50 states per horizon? Do you weight states? Are series demeaned? Explain estimator equation and estimation sample for each horizon in a consistent table.

3) IDENTIFICATION STRATEGY

Is the identification credible?
- The core identification strategy is cross-state exposure variation:
  - Great Recession: pre-2006 housing boom measured as log change 2003Q1–2006Q4 (HPI_s). Identification rests on the assumption that this exposure predicts demand collapse severity (via mortgage losses, balance sheet effects), and that after controlling for pre-recession trends and size, HPI_s is exogenous to longer-run employment trends aside from its effect via the recession.
  - COVID: state Bartik exposure constructed from 2019 industry shares × national industry employment shocks (leave-one-out) between Feb–Apr 2020. This is standard and plausible for COVID.
- The strategy is plausible but not airtight, especially for the housing-boom measure.

Key assumptions and whether they are discussed
- The author discusses pre-trends, migration, and policy endogeneity—good.
- However, the paper should more explicitly state and test the assumption: conditional on X_s, HPI_s is uncorrelated with other, non-recession determinants of long-run employment. This requires richer controls and placebo checks.

Placebo tests and robustness
- The paper includes pre-trend event-study checks and leave-one-out sensitivity, and robustness excluding Sand States. Good.
- Additional useful robustness/placebo tests:
  - Use alternative pre-boom windows to compute housing-exposure (e.g., 2002–2006, 2004–2006) to show results are not sensitive to the exact window.
  - Use alternative exposure measures: (i) county-level HPI aggregated to states with different weighting; (ii) housing construction boom (permit growth) rather than price appreciation; (iii) initial mortgage-lending expansions per capita (to show credit supply channel).
  - An IV strategy: if feasible, instrument HPI_s with a plausibly exogenous supply-side measure (e.g., Saiz 2010 geographic supply elasticity or pre-boom geographic constraints such as coastal share) or with exogenous credit supply shifts (national lenders’ expansion intensity interacted with state-level mortgage share) used in Mian & Sufi or others. This would help percolate exogeneity concerns.
  - Migration check: use net-migration flows (Census) to adjust employment levels or show that controlling for net migration does not eliminate the effect—or estimate employment per resident rather than payroll employment.
  - Worker-level evidence: link exposure to individual earnings and employment persistence using CPS/LEHD/SSA microdata (if feasible). E.g., show that workers from high-HPI states had longer unemployment durations and larger earnings losses even conditional on initial characteristics. This would directly test the scarring channel.
- Mechanism tests should be stronger. The model says scarring works through long durations leading to skill depreciation and LFPR exit. The aggregate LFPR LP is imprecise. I suggest:
  - Use cross-state (or county-level) long-term unemployment shares (27+ weeks) and duration distributions and run the same LPs to show that housing exposure predicts long-term unemployment more strongly than it predicts short-term unemployment or total job loss.
  - Use state-level measures of earnings losses (average wage per job) to test for quality-of-match declines.
  - Use UI data (if available) on temporary vs. permanent layoffs (for COVID the fraction temporary was high).

Do conclusions follow from evidence and are limitations discussed?
- The conclusions follow the evidence but would be more credible if augmented by the robustness and mechanism checks suggested above.
- The limitations paragraph in the conclusion is good; emphasize that the cross-state strategy captures local-level effects and may not identify national GE effects.

4) LITERATURE (Provide missing references)

The paper cites many relevant works. Still, the methodological literature relevant to the empirical methods and shift-share inference should be explicitly cited and discussed. Important missing or under-emphasized papers include:

- Goodman-Bacon (2021) and Callaway & Sant'Anna (2021): for staggered DiD issues (the author mentions them briefly; cite explicitly).
- Borusyak, Hull & Jaravel (2022) / Borusyak & Jaravel: shift-share identification and quasi-experimental designs.
- Adão, Kolesár & Morales (2019): inference for shift-share designs.
- F. Jorda (2005): local projections (you cite Jorda 2005 in text; ensure the full reference is in the bibliography).
- Wild cluster bootstrap methods & small-cluster inference: Cameron, Gelbach, and Miller (2008); MacKinnon & Webb (2017) maybe.
- For the model literature: Shimer (2005), Hall (2005) are cited; ensure Imbens & Lemieux (2008) and Lee & Lemieux (2010) are cited if RDD not used; Imbens & Wooldridge on causal inference can be useful.

Please add these BibTeX entries in your references (below I provide specific items I recommend adding; include the BibTeX in your .bib file):

Suggested citations with BibTeX (add to references.bib):

- Adão, Kolesár & Morales (shift-share inference)
```bibtex
@article{adao2019shift,
  author = {Adão, Rodrigo and Kolesár, Michal and Morales, Eduardo},
  title = {Shift-share designs: Theory and inference},
  journal = {Quarterly Journal of Economics},
  year = {2019},
  volume = {134},
  pages = {1949--2010}
}
```

- Borusyak, Hull & Jaravel (quasi-experimental shift-share)
```bibtex
@article{borusyak2022quasi,
  author = {Borusyak, Kirill and Hull, Paul and Jaravel, Xavier},
  title = {Quasi-experimental shift-share research designs},
  journal = {Review of Economic Studies},
  year = {2022},
  volume = {89},
  pages = {1811--1847}
}
```

- Goodman-Bacon (2021) (staggered DiD decomposition)
```bibtex
@article{goodmanbacon2021difference,
  author = {Goodman-Bacon, Andrew},
  title = {Difference-in-differences with variation in treatment timing},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {254--277}
}
```

- Callaway & Sant'Anna (2021) (DiD with multiple time periods)
```bibtex
@article{callaway2021difference,
  author = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title = {Difference-in-differences with multiple time periods},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {200--230}
}
```

- Jorda (2005) (Local projections)
```bibtex
@article{jorda2005estimation,
  author = {Jordà, Òscar},
  title = {Estimation and inference of impulse responses by local projections},
  journal = {American Economic Review},
  year = {2005},
  volume = {95},
  pages = {161--182}
}
```

- MacKinnon & Webb (2017) (wild cluster bootstrap)
```bibtex
@article{mackinnon2017wild,
  author = {MacKinnon, James G. and Webb, Matthew D.},
  title = {The wild bootstrap for few (treated) clusters},
  journal = {Econometrics Journal},
  year = {2017},
  volume = {20},
  pages = {C31--C72}
}
```

- Saiz (2010) (housing supply geographic constraints—useful to instrument HPI)
```bibtex
@article{saiz2010geographic,
  author = {Saiz, Albert},
  title = {The geographic determinants of housing supply},
  journal = {Quarterly Journal of Economics},
  year = {2010},
  volume = {125},
  pages = {1253--1296}
}
```

- Borjas (migration literature) or papers on migration response to labor shocks (if you use migration checks).
(Include classic migration papers as needed.)

Explain relevance briefly:
- Adão et al. (2019) and Borusyak et al. (2022) are crucial for proper inference and interpretation of shift-share (Bartik) regressions and should be used for standard errors and discussion.
- Goodman-Bacon and Callaway & Sant’Anna are essential when readers consider staggered DiD issues; even if not directly applied, discuss why the present cross-sectional LP avoids the TWFE biases.
- Saiz (2010) gives a credible source of plausibly exogenous housing-supply variation that could serve as an instrument for local housing booms or at least be used as control variables to bolster exogeneity claims.
- Jorda (2005) should be cited early and clearly as the basis for local projections.

5) WRITING QUALITY (CRITICAL)

Overall, the paper is well-written and organized with a clear narrative. Still, several improvements would increase readability and persuasiveness.

a) Prose vs bullets
- The main sections are in paragraph form. Good.

b) Narrative flow
- The Introduction clearly motivates the question with a striking fact (two severe recessions with different persistence), and it previews the empirical strategy and findings. The flow from motivation → method → findings → implications is logical.
- Suggest tightening the Intro by reducing some repetition: the phrases about “not all recessions are created equal” appear multiple times.

c) Sentence quality
- Generally crisp and readable. Avoid long sentences that cram multiple claims—occasionally trim or split for clarity.

d) Accessibility
- The LP approach is well-explained, but include an intuition paragraph that links cross-state exposure to an impulse-response: i.e., what exactly is being estimated when regressing Δy_{s,h} on Z_s? (In particular emphasize differences between this cross-sectional LP and time-series LP.)
- When discussing welfare numbers (very large CE losses), add a stronger caveat in the main text: the welfare ratios are sensitive to assumptions—risk neutrality, discounting, and the calibration of λ. You note this in the appendix; highlight it in the main text (and present a sensitivity figure).

e) Tables and notes
- Ensure all tables have clear notes: define all variables, indicate time windows, list the exact standard error methods, sample sizes, and whether the instrument is leave-one-out. Some appendix tables already do this—ensure main text tables match that quality.

6) CONSTRUCTIVE SUGGESTIONS (If the paper is promising)

This is promising and I recommend the following to strengthen identification, inference, and the mechanism story.

Empirical additions and robustness
- Instrumenting HPI: attempt to use a plausible instrument for HPI (e.g., geographic supply elasticity from Saiz 2010 interacted with national mortgage credit growth or other lenders’ expansion) to strengthen the exogeneity claim. If not implementable, present more convincing placebo/partial-out tests and more pre-boom controls (local pre-boom employment growth, industry shares, initial credit conditions).
- Micro-level evidence: incorporate individual-level microdata (CPS, SIPP, LEHD, UI) to show that workers from high-HPI states experienced longer durations, greater long-term unemployment shares, larger earnings losses, and higher labor-force exit rates. This would directly tie the macro patterns to the scarring mechanism.
- Duration/long-term unemployment as dependent variables: run the same cross-state LPs with the share of unemployed 27+ weeks (or median duration) as dependent variable. If HPI strongly predicts long-term unemployment but Bartik does not, that would support the mechanism.
- Migration: use Census migration flows to control for or decompose employment changes into local job creation/destruction vs. migration. At minimum, show that the main result is not driven by differential out-migration (or show the employment-per-resident result).
- Policy controls: while the author is right to avoid “post-treatment” controls, it would be informative to include pre-determined policy variables (pre-recession fiscal capacity, pre-existing unemployment insurance generosity) as covariates and to present a sensitivity panel where post-recession support intensity is included as a mediator (with suitable caution).
- Show results by state-size and region (you have some of this in appendix), and if meaningful, provide county-level checks where N is larger (counties raise power but bring additional endogeneity; use them for robustness).
- For Bartik: present the Adao et al. robust SEs and an exposure-robust permutation test. Also show the implied per-1-SD effect in the main tables (you already compute some per-1-SD numbers—make those consistent across tables).

Model/modeling suggestions
- Welfare calculations: the estimated CE losses are very large (33.5% demand shock vs 0.23% supply). These are useful illustrative numbers, but given they are sensitive to utility assumptions and calibration (risk neutrality, discounting, λ), I recommend:
  - Provide a clear robustness table of CE losses under CRRA preferences (reasonable σ), different discount rates, and alternative λ values (you have some of this in appendix; bring key robustness to main text).
  - Clarify how "welfare loss" is interpreted—does the CE number correspond to lifetime consumption equivalence for the representative worker? Are distributional effects considered? State these limitations clearly in the main text.
- Microfoundations of scarring: the model uses a simple rule for scarring (after d* periods, h→h(1−λ)). Consider alternative formulations: gradual depreciation as a function of duration or an endogenous probability of permanent skill loss (could be more realistic). At minimum, discuss alternative specifications and show sensitivity.

Presentation and transparency
- Move key robustness / placebo figures/tables (permutation distributions, pretrend event studies, Bartik exposure-robust SEs, long-term unemployment LPs) from appendix into the main paper or at least one high-quality robustness figure in the main text.
- Provide code and data (you have a GitHub link in the header—good). Make sure replication materials include scripts for permutation inference and for the model calibration.

7) OVERALL ASSESSMENT

Key strengths
- Clear, important question with strong motivation.
- Uses two naturally comparable episodes (Great Recession and COVID) with careful cross-state exposure measures.
- Good combination of reduced-form evidence and structural modeling to argue for a mechanism (skill depreciation + participation exit).
- Thorough appendices and many robustness checks already performed.

Critical weaknesses (to be addressed)
- Identification of housing-boom exposure as exogenous needs further bolstering (IV, supply-side instruments, or richer pre-treatment controls).
- Inference must be made robust to small cross-sectional N = 50 (move permutation/exposure-robust standard errors / wild cluster bootstrap to the forefront).
- Mechanism identification is presently suggestive but not definitive: the LFPR cross-state LP is underpowered; micro-level evidence on durations, long-term unemployment, and earnings losses is needed.
- Welfare numbers are striking but very sensitive to calibration and strong assumptions (risk neutrality, permanent productivity shocks, depreciation formulation). The paper must more carefully present and caveat the welfare results.

Specific suggestions for improvement (short list)
- Provide complete, compiled bibliography and ensure all key methodological papers are cited (see Section 4).
- Make permutation inference and exposure-robust SEs a main result, and report wild cluster bootstrap p-values for clustered inference.
- Augment reduced-form identification: instrument housing-boom exposure using supply-side variables (Saiz or mortgage-supply variables) or present richer placebo/IV/controlled specifications.
- Present micro-level evidence linking exposure → duration → earnings/labor-force exit if possible.
- Strengthen mechanism tests: LPs with long-term unemployment share and median duration as dependent variables; migration decomposition; UI and JOLTS decompositions in main text.
- Temper and clearly caveat welfare claims; bring sensitivity analysis to the main text.

Final recommendation / decision
The paper has substantial promise but requires further work on identification, inference, and mechanisms before it would be suitable for a top general-interest journal. I therefore recommend:

DECISION: MAJOR REVISION

If you address the methodological concerns above (exogeneity of HPI, small-sample inference, stronger mechanism evidence) and implement the recommended robustness and presentation improvements, the paper could make a valuable and publishable contribution.