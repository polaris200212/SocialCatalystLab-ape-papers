# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-10T15:03:04.613778
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 30349 in / 4664 out
**Response SHA256:** 6d31923f76a374c8

---

Thank you for the opportunity to review. This is a careful, interesting paper on an important question—whether sub‑national policy experience builds support for federal environmental reform—leveraging a rich Swiss setting and multiple complementary identification strategies. The authors have assembled a large dataset, used appropriate modern methods for staggered adoption and few clusters, and presented a transparent hierarchy of evidence. The paper is close to being publishable in a top journal after addressing the points below. I structure the review to be constructive: first format/packaging issues, then a focused review of empirical/statistical methodology (critical), identification, literature suggestions (with BibTeX), writing quality, constructive suggestions for strengthening the paper, and an overall assessment and decision.

1) FORMAT CHECK

- Length: The LaTeX source is substantial. Judging by sections and appendices, the manuscript is well above 25 pages (main text ~25–30 pages plus extensive appendix; overall nearer 60+ pages with appendix). This exceeds typical top‑journal length for main text + appendices; consider moving some lengthy robustness tables/plots into an online appendix if the journal requests shorter main text.

- References: The bibliography is broad and includes many core methodological and topical references (RDD, Callaway–Sant'Anna, wild cluster bootstrap, thermostatic literature, Swiss politics). Coverage of DiD/RDD/cluster inference is good. I recommend adding a couple of recent, relevant methods papers (see Section 4 below for precise suggestions and BibTeX entries).

- Prose / Structure: Major sections (Introduction, Theoretical Framework / Lit, Institutional Background, Data, Empirical Strategy, Results, Discussion, Conclusion) are written as paragraphs, not bullets. Good.

- Section depth: Most major sections are substantive and contain multiple paragraphs. The Introduction, Methods, Results, Discussion and Appendix are well developed. Good.

- Figures: The LaTeX references to figures are present and captions are substantive. I could not render the images, but the captions suggest axes and scales are described. When you submit, ensure all figures have labeled axes, units, and sample sizes displayed (e.g., number of bins / bin width on RD plots). In particular: RDD graphs should show the running variable scale and bin widths, and the axis range should be symmetric enough to show pre/post sides comparably.

- Tables: Tables in the source contain real numbers, SEs in parentheses, p‑values, sample sizes, and notes. No placeholders found. Ensure all table notes fully explain estimation methods, standard error methods (cluster/WCB), and bandwidth choices.

Summary: format is good overall. Minor packaging suggestions above.

2) STATISTICAL METHODOLOGY (CRITICAL)

I treat methodology issues as essential; a paper cannot pass without appropriate inference. You have taken many correct steps. Below I flag what is done well and what still needs clarification / possible improvement.

What the authors have done (strong points)
- Every reported coefficient has standard errors or CIs. RDD tables include SE and 95% CI.
- Sample sizes (N) are reported for regressions and RDD bandwidths (# left / # right).
- For staggered DiD timing the panel models use time‑varying D_{ct} and explicitly apply Callaway–Sant'Anna, which is appropriate.
- RDD follows modern practice: local linear, triangular kernel, MSE‑optimal bandwidth, bias‑corrected CIs (Calonico et al.), bandwidth sensitivity, local polynomial robustness, McCrary density test, donut RDD, covariate balance tests.
- Few‑cluster inference is acknowledged: standard cluster SEs supplemented with wild cluster bootstrap (Webb six‑point) and stratified randomization inference (permutations within German‑speaking cantons). Good.
- Authors calculate per‑segment border distances and distinguish same‑language borders—this is important.

Issues (and required / recommended fixes)
- Clarity on standard errors / inference for each major estimate:
  - For OLS, you cluster SEs by canton and report WCB p‑values—please explicitly state in each table note which inference is primary (clustered SEs + conventional p, and WCB p). For RDD, clarify whether SEs are heteroskedasticity‑robust, bias‑corrected Calonico SEs, and whether standard errors are clustered (and at what level). The RDD uses individual municipalities and distance as running variable; I recommend reporting bias‑corrected RD CIs (Calonico et al.) and also provide robust cluster SEs by border segment (or canton) as a sensitivity check.
  - For border‑pair RDD heterogeneity, explain how SEs are computed when N per segment is small—use caution interpreting those segment estimates.

- Spatial correlation and Conley SEs: Municipalities are spatially correlated. The RDD reduces this concern by localizing near borders, but OLS and panel estimates may still be subject to spatial autocorrelation beyond canton clustering. Consider adding Conley standard errors (spatial HAC) as an alternative sensitivity check, or discuss why canton‑level cluster plus WCB is sufficient. If Conley SEs materially change inference, report.

- Randomization inference assumptions: The stratified permutation test (conditioning on German‑speaking cantons) is well motivated. However, the permutation test is exact only under a sharp null. Please be explicit in the text that RI tests the sharp null and is not a panacea for selection bias. Also: provide more detail on the number of unique permutations available under the stratified scheme and the random seed procedure; show that RI p‑values are stable (e.g., 1,000 vs 5,000 permutations). If computationally feasible, report both stratified and unstratified RI in an appendix.

- Donut RDD odd pattern: The donut RDD estimates appear more negative (and significant) as the donut radius increases—this is unexpected because removing observations near the border often reduces biases from spillovers but also reduces sample size and increases SEs. The authors interpret larger negative effects as attenuation by spillovers near the border. This is plausible but deserves more careful exploration:
  - Provide graphical evidence of outcomes vs distance to show whether the immediate border zone is more pro‑federal than areas a bit further away.
  - Consider testing for spillovers explicitly: e.g., regress yes‑share on distance bins controlling for other covariates to see the functional form. Alternatively, estimate local treatments accounting for spatial exposure (distance‑weighted treatment intensity).
  - Discuss whether the MSE‑optimal bandwidth selection is affected by including vs excluding near‑border observations; present the bandwidth selection outputs.

- RDD running variable construction: You compute signed distance from centroid to the nearest treated‑control border; that's standard. But centroids can be misleading in long thin municipalities. Provide robustness using shortest distance from any point in the municipality polygon (this is often used) or population‑weighted centroids. The appendix should document tests confirming centroids vs polygon‑edge distance produce similar estimates.

- Panel DiD inference details:
  - TWFE vs CS: You report a TWFE estimate of −5.2 pp (SE 1.55, p = 0.002) and a CS ATT of −5.0 pp (SE 3.34). The larger SE in CS is expected given heterogeneity correction and sample size. Please include an explicit discussion of the weighting that TWFE implicitly uses in staggered designs (Goodman‑Bacon decomposition), show the decomposition summary (or at least mention whether negative weights are present), and show event‑study plots with Sun & Abraham style or Rambachan & Roth sensitivity checks. You partly do this with CS, but add a compact figure/table summarizing cohort weights and potential negative weighting.
  - For Callaway–Sant'Anna: clarify the choice of control group for each cohort (never‑treated vs not‑yet‑treated) and specify whether clustering is by canton.

- Multiple hypothesis testing: The paper examines many specifications, placebo votes, heterogeneity splits. Consider explicitly controlling for multiple testing where appropriate (especially when interpreting marginally significant heterogeneity findings). At minimum, avoid overinterpreting borderline p‑values.

- Power / MDE: You present MDEs—good. When interpreting nulls, be precise about which magnitudes you can rule out. The same‑language RDD rules out positive effects larger than ~0.7 pp—this is a strong statement; double‑check the calculation and ensure these bounds are clearly caveated (local sample, same‑language borders only).

- Small number of treated clusters: You do the right things (WCB, RI). One remaining useful robustness is to implement alternative estimators that work with small treated counts (e.g., synthetic difference‑in‑differences / synthetic controls across cantons, or weighted DiD methods). See Section 4 for references.

Overall methodological judgment: The authors have implemented modern, appropriate procedures for the major issues (staggered timing; few clusters; RDD diagnostics). The remaining tasks are mostly clarifications, additional sensitivity checks (Conley SEs; centroid vs polygon distance; robustness of WCB/RI), and clearer documentation of inference choices in table notes and text.

3) IDENTIFICATION STRATEGY

Main identification strategies are well motivated and ordered by credibility: same‑language spatial RDD, pooled RDD, OLS + language controls, stratified RI, panel DiD with CS.

Credibility strengths
- Same‑language RDD is the cleanest cross‑sectional design to separate language confounding.
- The panel DiD with time‑varying D_{ct} and use of CS addresses staggered treatment issues.
- Randomization inference stratified to German cantons is appropriate given all treated cantons are German‑speaking.
- RDD diagnostics (McCrary, covariate balance, bandwidth sensitivity) are performed.

Key assumptions and discussion
- Parallel trends for DiD: authors examine pre‑trend evidence across 2000 & 2003 votes. Table 6 and event study suggest treated cantons were slightly more pro‑energy pre‑treatment (positive gap) that narrows—this helps, and the CS event study shows heterogeneity. Still, four referendum periods is limited; stress caveats on DiD inference more clearly in the text.
- Continuity for RDD: McCrary test is reported and covariate balance largely holds except for turnout. The authors discuss turnout as potentially post‑treatment; but turnout could be a confound if cantons differ in mobilization because of long‑standing differences. Provide an RDD result controlling for pre‑determined covariates where possible (e.g., pre‑2000 turnout) and repeating balance tests for other pre‑treatment measures (e.g., pre‑2000 referendum outcomes, economic indicators).
- Placebo tests: good set (immigration, healthcare, public service). The positive discontinuities for healthcare and service public are concerning: they imply treated‑side municipalities tend to favor federal initiatives on some topics. The interpretation offered (treated cantons generally favor federal initiatives but not energy) is plausible, but alternative explanations (residual confounding, policy‑domain heterogeneity) should be explored. For example, are those positive placebos concentrated in French‑language borders? Are they robust to same‑language RDD? Present placebo RDDs both pooled and same‑language.

Suggested additional robustness / checks to strengthen identification
- Municipality‑level language and socio‑demographic controls (census): the paper uses canton majority language; where feasible add municipality language share and include as a control or conduct same‑language RDD using municipality language shares to ensure local exceptions (e.g., French pockets in BE) are not biasing results.
- Spatial spillovers: explicitly model potential spillovers across the border (distance decay) rather than binary treated side. Estimate treatment intensity as inverse‑distance exposure to treated canton policy and compare with binary RDD.
- Synthetic control or synthetic DiD (see Section 4) as an alternative to DiD; especially since treated cantons are geographically clustered and few.
- Closer discussion of heterogeneous border estimates: the forest plot shows large heterogeneity (e.g., GR–SG positive). Instead of averaging all borders, consider reporting pooled RDD with border fixed effects weighted by border length or population, and discuss reasons for heterogeneity (economic structure, tourism, urbanization). If heterogeneity is meaningful, explore correlates (income, homeownership rates, building stock age, existing renewable penetration).

4) LITERATURE (Provide missing references)

The literature review is strong and cites most of the key methodological and substantive works. A few potentially useful references to add:

- Arkhangelsky et al. (2021) on Synthetic DiD: useful as an alternative approach to strengthen panel causal claims when treated clusters are few and pre‑intervention periods exist.
- Abadie, Diamond & Hainmueller (2010) synthetic control method: a useful complementary approach for canton‑level analysis (treat each treated canton separately and build synthetic control from never‑treated cantons).
- Athey & Imbens (2018) on design‑based inference or the importance of treatment effect heterogeneity; or Sun & Abraham (2021) already cited, but emphasize this in event study robustness.
- Bell & McCulloch? Not necessary.

I provide BibTeX entries for two concrete suggested additions:

- Arkhangelsky et al. (2021), Synthetic Difference-in-Differences (useful for panel robustness).

```bibtex
@article{Arkhangelsky2021,
  author = {Arkhangelsky, Dmitry and Athey, Susan and Hirshberg, Daniel and Imbens, Guido and Wager, Stefan},
  title = {Synthetic Difference-in-Differences},
  journal = {American Economic Review},
  year = {2021},
  volume = {111},
  number = {12},
  pages = {4088--4118}
}
```

- Abadie, Diamond & Hainmueller (2010), Synthetic Control:

```bibtex
@article{Abadie2010,
  author = {Abadie, Alberto and Diamond, Alexis and Hainmueller, Jens},
  title = {Synthetic control methods for comparative case studies: Estimating the effect of California's tobacco control program},
  journal = {Journal of the American Statistical Association},
  year = {2010},
  volume = {105},
  number = {490},
  pages = {493--505}
}
```

Why these are relevant:
- Arkhangelsky et al. give an estimator that blends synthetic control and DiD, often with good finite‑sample properties in staggered/adoption designs; applying it would strengthen the panel results and provide a robustness check against the TWFE/CS estimates.
- Abadie et al. offer the synthetic control method that can be applied at the canton level (e.g., for Bern or Graubünden individually), particularly useful when units are few and there is pre‑treatment information.

5) WRITING QUALITY (CRITICAL)

Overall the prose is solid—clear, logically organized, and engaging. A few suggestions:

- Intro hook: The opening is good; you might strengthen the hook by summarizing the main numeric finding (same‑language RDD −1.6 pp, panel DiD −5.2 pp) in one crisp sentence to underscore why the finding is surprising given canonical policy‑feedback expectations.

- Flow & transitions: A few long subsections (e.g., the Discussion) contain long paragraphs; consider breaking some into shorter paragraphs with first‑sentence topic statements to help reader navigation.

- Jargon & accessibility: The econometric choices are well explained for a non‑specialist, but when invoking multiple modern methods (CS, WCB, stratified RI) add 1–2 sentences each explaining intuitively what they address and what their limitations are.

- Table/figure notes: For each major table include a short explicit statement of the exact inference method used (e.g., cluster‑robust SE by canton; WCB p using Webb 6‑point; Calonico bias‑corrected CI). This helps referees/readers know which p‑value/CIs are primary.

- Minor language issues: A few long sentences are dense—shorten where possible. Example: in the abstract, the parenthetical about corrections in the title footnote is dense; keep the abstract tight and move extended footnote details to a data/replication section.

- Bullets vs prose: Data/Methods has a few lists (acceptable). No major sections are in bullets. Good.

6) CONSTRUCTIVE SUGGESTIONS (to make paper more impactful)

- Add municipality‑level language shares and socio‑demographic controls: this will tighten the same‑language RDD and address concerns about within‑canton language pockets.

- Provide Conley spatial SEs in OLS and as a sensitivity check for cluster inference.

- Report RD estimates with alternative distance measures (polygon edge vs centroid; population‑weighted centroid) so readers see robustness.

- Use synthetic DiD (Arkhangelsky et al.) or synthetic control for canton‑level case studies (e.g., Bern or Graubünden) as complementary evidence to the panel DiD. This is especially useful because treated cantons are clustered geographically.

- Explore an outcome that measures local policy implementation intensity (e.g., number of retrofits, heat‑pump installations, building permits, solar panels installed) as a mediator. If data exist at canton/Gemeinde level, show that treated cantons did experience more implementation and that implementation intensity correlates with the negative votes in rural areas. This would strongly bolster a cost‑salience mechanism.

- Provide a clearer causal pathway section: use mediation or subgroup analysis to show whether homeownership rates, construction activity, or socioeconomic factors mediate the negative effect.

- Reconcile donut RDD pattern: provide a more granular explanation (spillovers versus sorting) and consider modeling exposure continuously.

- For transparency, release code snippets that reproduce key RDD bandwidth selection and Calonico outputs in the replication repo (you already provide a GitHub link; ensure scripts are runnable and document packages/versions).

7) OVERALL ASSESSMENT

Key strengths
- Strong, policy‑relevant research question with an excellent empirical setting.
- Multiple complementary, modern identification strategies used appropriately (same‑language spatial RDD, placebo tests, WCB, stratified RI, staggered DiD + CS).
- Clear exposition, comprehensive robustness checks, rich appendix documenting data and implementation details.
- Plausible and interesting substantive conclusion: sub‑national policy experience does not necessarily translate into more federal support and may even reduce it in some groups.

Critical weaknesses (fixable)
- A few remaining inference clarifications and sensitivity checks are needed (Conley SEs, centroid vs polygon distance, cluster SE reporting consistency; clarify SE method for each table/figure).
- The donut RDD pattern and border‑pair heterogeneity deserve deeper exploration and clearer interpretation.
- Consider additional robustness via synthetic DiD / synthetic control and municipality‑level language controls to strengthen causal claims.
- Better articulation (and empirical test) of mechanisms via local implementation intensity or ownership data.

Decision rationale
- The paper is methodologically careful and the authors have taken many appropriate steps to deal with small treated counts and staggered adoption. Remaining issues are important but generally fixable in a revision: clarify inference reporting, add a handful of robustness checks (Conley, centroid vs polygon, synthetic DiD / SC), and expand discussion of donut RDD and border heterogeneity. These are substantial but not fatal.

FINAL RECOMMENDATION

- I recommend a revision that addresses the points above before acceptance. Given the paper’s strengths and the relative fixability of the issues, the appropriate decision is:

DECISION: MINOR REVISION

(If the authors address the remaining inference clarifications, add the suggested robustness checks, and tighten exposition, this paper should be suitable for a top general interest journal.)