# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-24T17:42:06.841451
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 23323 in / 4650 out
**Response SHA256:** 101ae23d65630a2a

---

## Referee Report: “Locked Out of Home Care: COVID-19 Lockdown Stringency and the Persistent Decline of Medicaid HCBS”

### Summary
The paper asks an important policy question: did stricter COVID-19 lockdown policies generate persistent reductions in in-person Medicaid HCBS? The empirical design is a triple-difference (DDD) using 2018–2024 state-by-month outcomes from newly released T-MSIS Provider Spending data, comparing a “clean” subset of in-home T-codes to telehealth-eligible behavioral health (H-codes), interacted with cross-state April 2020 lockdown stringency.

The paper is well-motivated, uses a valuable new dataset, and takes inference seriously (clustered SEs, CIs, and randomization inference). However, for a top general-interest journal, the identification argument still hinges heavily on the validity of behavioral health as a counterfactual and on the strength of the “differential parallel trends” assumption. The results are economically large but statistically imprecise; several robustness checks (notably the placebo magnitudes and the “exclude never-lockdown states” sign flip) indicate that the main identifying variation may be fragile. I think the paper is *promising* but needs a substantial revision that tightens identification, clarifies what is and is not identified with the three-way FE structure, and strengthens the empirical validation of assumptions.

---

# 1. FORMAT CHECK

**Length**
- The LaTeX source appears to be comfortably **>25 pages** in 12pt, 1.5 spacing (likely ~35–45 pages excluding references/appendix). **PASS**.

**References / bibliography coverage**
- The text cites some key COVID/telehealth and DiD methods papers, but the methods and policy literatures are **not yet adequately covered** for a top journal. Missing are several canonical DDD references and modern event-study/DiD inference references, plus key HCBS/pandemic policy and Medicaid HCBS policy funding references (see Section 4 below). **NEEDS WORK**.

**Prose vs bullets**
- Major sections are written in paragraphs. Bullets are used appropriately for code lists and appendix construction steps. **PASS**.

**Section depth**
- Introduction and Discussion have 3+ substantive paragraphs; Institutional Background and Data do as well. Results section is long enough. **PASS**.

**Figures**
- Figures are included via `\includegraphics{...}`; as this is LaTeX source, I cannot verify axes/data visibility. I will not flag figure quality, but you should ensure all figures have clear axes, units, sample, and notes. **UNVERIFIED**.

**Tables**
- Tables contain real numbers and standard errors. **PASS**.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

Overall, the paper clears the minimal bar for inference, but there are several methodological points that need strengthening/clarification.

### 2a) Standard errors
- Main regression tables include **SEs in parentheses** (Table 1, Table 2, robustness table). **PASS**.

### 2b) Significance testing
- p-values are reported, and RI p-values are also reported. **PASS**.

### 2c) Confidence intervals
- 95% CIs are reported for key results. **PASS**.

### 2d) Sample sizes
- N is reported for main regressions. **PASS**, but: the unit of observation is state×service×month and the effective sample after absorbing singletons is 8,038. I strongly recommend also reporting:
  - number of clusters (=51),
  - number of treated “intensity” distinct values / distribution of stringency,
  - and in event-study figures, the number of state-month cells per quarter (or at least confirm balancedness).

### 2e) DiD with staggered adoption / TWFE issues
- You correctly note that adoption is common timing (April 2020), so staggered adoption concerns (Goodman-Bacon decomposition / “already treated as controls”) are not directly the problem **in the standard sense**.
- However, you are running a **continuous treatment intensity** design with a single break date, which creates its own issues:
  1. **Functional form:** the estimand is a linear “dose response” in stringency; this should be tested (e.g., bins of stringency, splines, or saturated indicators).
  2. **Cluster-level regressor:** stringency is state-level, fixed over time; with high-dimensional FEs, inference can behave like “few effective treatment units.” RI is a good step, but you should also consider **wild cluster bootstrap with appropriate implementation** (see below).

### 2f) RDD requirements
- Not applicable.

### Inference concerns and fixes
1. **Wild cluster bootstrap “failed due to singletons”**: this is not an acceptable endpoint in a top-journal submission. There are ways around this:
   - Use an estimator/implementation that can bootstrap with absorbed FEs robustly (e.g., `fixest` in R with `boottest`-style routines, or Stata `reghdfe` + `boottest` with careful handling).
   - Alternatively, **collapse data further** to eliminate singleton absorption issues (e.g., quarter instead of month) for the bootstrap check, or pre-drop singleton groups deterministically before bootstrapping so the bootstrap sample structure is stable.
   - If bootstrap remains infeasible, justify clearly and provide additional finite-sample checks (e.g., **randomization inference under alternative assignment mechanisms**, see below).

2. **Randomization inference design**: you permute stringency across states. That is helpful, but the identifying threat is that stringency correlates with observables (politics, urbanization, early COVID severity) that could differentially affect HCBS vs BH even after state×month FE. Consider RI variants:
   - **Permutation within strata** (e.g., Census region, governor party, early COVID burden quartiles) to preserve broad correlates of stringency.
   - **Sign-flip/wild permutation** approaches at the cluster level for the key coefficient.

3. **Multiple outcomes / specification mining risk**: Many outcomes and robustness checks are shown; a general-interest journal will ask whether the one marginally significant coefficient (beneficiaries, p=0.091) is an artifact. Consider:
   - Pre-specifying a **primary outcome index** (e.g., standardized average of paid/claims/beneficiaries/providers) or naming one primary outcome with a sharper welfare interpretation.
   - Reporting **family-wise adjusted** p-values for the small set of primary outcomes, or at least discussing multiplicity.

---

# 3. IDENTIFICATION STRATEGY

### What is identified with your three-way FE DDD?
Equation (1) includes **state×month FE** and **service×month FE**, which is very demanding. Intuitively, you are comparing within a given state-month how HCBS differs from BH, and then asking whether the post-2020 change in that within-state-month gap is larger in high-stringency states. That’s a reasonable DDD, but readers will want a very clear statement of:

- **What variation remains** after these FEs,
- why this variation isolates the causal channel,
- and what kinds of confounding could still survive (i.e., factors that differentially shift HCBS vs BH in a state-month and correlate with stringency).

Right now, the paper says state×month FE absorb “all state-level COVID severity, economic conditions, and common federal policies.” True, but **the main residual threat is exactly what you acknowledge**: factors that shift HCBS relative to BH within the same state-month. The most important ones are plausibly:
- differential telehealth policy generosity by state (parity laws, licensure flexibilities),
- differential HCBS waiver/eligibility expansions and ARPA HCBS spending deployment,
- differential nursing home shocks driving substitution away from HCBS (or toward it),
- differential managed care encounter reporting changes by service type, correlated with pandemic intensity.

### Parallel trends / diagnostics
You present an event study and claim flat pre-trends. This is good, but two things need tightening:

1. **Formal pretrend evidence**: You mention a joint test “fails to reject.” Report:
   - the F-statistic, p-value, and number of pre-period coefficients tested,
   - and show the same event study for **other outcomes** (beneficiaries/providers at least), not just log paid.

2. **Placebo magnitudes are concerning**: Table 4 placebo coefficients around -1.09 are not statistically significant, but they are not “near zero,” and you note they are about half the main estimate. This suggests either:
   - residual differential trending in the HCBS/BH gap correlated with stringency even pre-2020,
   - or sensitivity to sample restriction (placebo uses N=2,652) and perhaps different FE structure/period window.
   
   This is a *material identification warning sign*. You should:
   - replicate placebo tests with **exactly the same window length** as the main design (e.g., pretend treatment in April 2019 and use Jan 2018–Sep 2020 as pre/post around that fake date) so that the placebo design mirrors the main one;
   - show placebo event studies (not just single post indicators);
   - examine whether placebo effects are driven by particular service codes within “clean HCBS” (e.g., T2016 residential habilitation may behave differently).

### The “exclude never-lockdown states” sign flip
The robustness check dropping the 9 never-lockdown states flips the coefficient positive (though imprecise). That is not just “loss of variation”: it suggests the estimate may be identifying primarily from the extreme low-stringency tail. That can be okay, but then the paper should explicitly reframe the estimand as “difference between very low-stringency states and everyone else,” and demonstrate results are not an artifact of those states having systematically different Medicaid systems or coding/reporting.

Concrete fixes:
- Show binned scatter / semi-parametric estimates: e.g., estimate effects by **stringency quartile** (or deciles), and plot the implied post effect by bin. If the effect is driven by the bottom bin, say so and discuss.
- Provide a **balance table**: correlate stringency with pre-period levels and trends in HCBS/BH ratios and other state covariates (urbanization, nursing home beds, Medicaid managed care penetration, political control, pre-COVID HCBS generosity). This will help readers judge plausibility.

### Mechanisms
The workforce scarring story is plausible and fits the delayed timing, but currently it is not cleanly tested. The “provider churn” paragraph is suggestive but confusing (exit rises more in low-stringency states in your numbers, which seems inconsistent with the main result). Mechanism evidence should be made consistent and sharper:

- Define exactly how “exit rate” is computed (from T-MSIS billing NPIs?), at what periodicity, and whether it is HCBS-only.
- Then test whether **provider exit responds differentially** to stringency in an event-study DDD (provider-level or state-level).
- If possible, validate with external labor data at annual frequency (BLS OEWS/QCEW/ACS), even if coarse.

### Conclusions vs evidence
You do a commendably “honest” discussion emphasizing suggestive evidence. For a top journal, you still need a more compelling case that:
- the comparison group is valid,
- the identifying assumption is plausible,
- and the result is not a pre-existing differential trend continuation.

Right now, the evidence does not yet rise to the level of a definitive causal claim.

---

# 4. LITERATURE (with missing references + BibTeX)

### Methods / identification (missing or should be emphasized)
You cite some modern DiD papers, but for a DDD/event-study design with policy intensity and concerns about pretrends, functional form, and inference, you should add:

1) **DDD foundational**
- Angrist & Pischke discussion of DDD; and/or a canonical applied DDD reference beyond Gruber (1994).
- While there is no single “DDD bible,” top-journal readers will expect clearer grounding and references.

2) **Event study / pretrend and staggered DiD diagnostics**
Even though not staggered, the event-study issues (pretrend testing, over-weighting, dynamic effects) are relevant.
- Sun & Abraham (2021) you cite; also consider Borusyak et al. (2021) and Roth (2022) on pretrend sensitivity.

3) **Randomization inference / permutation inference in DiD**
You cite Rosenbaum (2002), but add more targeted references for cluster-level or DiD RI.

**Suggested BibTeX**

```bibtex
@article{BorusyakJaravelSpiess2021,
  author = {Borusyak, Kirill and Jaravel, Xavier and Spiess, Jann},
  title = {Revisiting Event Study Designs: Robust and Efficient Estimation},
  journal = {arXiv preprint arXiv:2108.12419},
  year = {2021}
}

@article{Roth2022Pretrends,
  author = {Roth, Jonathan},
  title = {Pretest with Caution: Event-Study Estimates after Testing for Parallel Trends},
  journal = {American Economic Review: Insights},
  year = {2022},
  volume = {4},
  number = {3},
  pages = {305--322}
}

@article{Fisher1935,
  author = {Fisher, Ronald A.},
  title = {The Design of Experiments},
  journal = {Oliver and Boyd},
  year = {1935}
}
```

(If you prefer journal-only citations, you can cite Fisher as a book and Roth as AERI. For Borusyak et al., cite the QJE version if/when published; as of my cutoff it’s widely cited as working paper.)

### Policy / domain literature (HCBS, Medicaid LTSS, COVID)
The paper cites some relevant sources (Werner et al. 2022; Scales; Stone; etc.) but should engage more directly with:
- ARPA HCBS enhanced FMAP and state implementation heterogeneity,
- COVID-era HCBS-specific guidance and program changes,
- nursing home shocks and substitution with HCBS,
- and the broader literature on non-COVID fragility of the home care workforce.

A few high-salience additions:

```bibtex
@article{GoolsbeeSyverson2021,
  author = {Goolsbee, Austan and Syverson, Chad},
  title = {Fear, Lockdown, and Diversion: Comparing Drivers of Pandemic Economic Decline},
  journal = {Journal of Public Economics},
  year = {2021},
  volume = {193},
  pages = {104311}
}

@article{GoodmanBacon2021,
  author = {Goodman-Bacon, Andrew},
  title = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  number = {2},
  pages = {254--277}
}

@article{CallawaySantAnna2021,
  author = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title = {Difference-in-Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  number = {2},
  pages = {200--230}
}

@article{SunAbraham2021,
  author = {Sun, Liyang and Abraham, Sarah},
  title = {Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  number = {2},
  pages = {175--199}
}
```

Even if you argue staggered timing is not central, these citations signal awareness and help defend the event-study approach and FE structure.

You may also want to cite work on HCBS policy and spending trends (e.g., MACPAC reports on HCBS, KFF issue briefs) and any empirical work on COVID’s effects on home health/home care labor supply specifically (if available).

---

# 5. WRITING QUALITY (CRITICAL)

### Prose vs bullets
- Major sections are in paragraphs. **PASS**.

### Narrative flow
- The introduction is strong, with an effective hook (“You cannot deliver a bath over Zoom.”). The motivation and design are clearly stated early. This is a real strength for a general-interest outlet.

### Sentence quality and accessibility
- Generally clear and readable, with good intuition for the DDD.
- However, there are a few places where the paper oversells “methodological improvements” (e.g., “clean HCBS classification” is a conceptual improvement, but it is also a selection that changes the estimand; you should be explicit about what population of HCBS you now represent and what you exclude).
- Several sections would benefit from **more explicit definitions**:
  - What exactly is “behavioral health” in H-codes? Which major codes dominate spending? Is it stable across states?
  - What is the precise unit of analysis and how do suppressed cells/zeros affect log(Y+1)?

### Tables
- Tables are mostly self-contained with notes. Very good inclusion of 95% CIs.
- Suggest adding to Table 1:
  - mean of dependent variable (or pre-period mean) to help magnitude interpretation,
  - and perhaps a “% implied effect for 1 SD” row to reduce reader burden.

---

# 6. CONSTRUCTIVE SUGGESTIONS (MOST IMPORTANT)

## A. Strengthen identification by stress-testing the comparison group
1. **Show BH is not itself “treated” by lockdown stringency** in ways that matter:
   - Expand the decomposition beyond “post” to a **BH event study**: estimate BH-only dynamic effects by stringency and plot coefficients. You partly do this conceptually, but show it formally.
2. Add at least one **additional comparison group** that is plausibly in-person but not home-based (or vice versa), to triangulate:
   - e.g., home health (if identifiable), or other outpatient services with limited telehealth substitutability.
3. Alternatively, use **multiple control groups** and implement a stacked DDD or an outcome index.

## B. Address the placebo magnitude problem directly (this is key)
- Implement “placebo reforms” that mirror your main design’s window length and FE structure.
- Report whether pre-period *trends in the HCBS/BH ratio* correlate with stringency (regress the pre-2020 slope of the ratio on stringency).
- If there is correlation, consider adding **state-specific pre-trends interacted with service type** (i.e., allow the HCBS/BH gap to have a linear pretrend by state) and show sensitivity. This is common in DDD/DiD where pretrend concerns arise, though it comes with its own risks; you can present it as a robustness check.

## C. Replace/augment linear dose response with semi-parametric evidence
- Estimate the DDD with **stringency bins** (quartiles/deciles) interacted with Post×HCBS, and plot bin coefficients. This will:
  - clarify whether effects are monotone,
  - diagnose whether never-lockdown states drive results,
  - and make the result more transparent to readers.

## D. Bring mechanism evidence closer to the design
- If workforce scarring is the story, the most compelling evidence would be:
  - DDD on **provider counts** (you already have) with a dynamic design and more focus on entry/exit.
  - A provider-level hazard model: probability an HCBS provider stops billing post-2020 as a function of state stringency, with provider pre-2020 size controls (even if only descriptive).
- Clarify the confusing churn numbers and align them with the main claim.

## E. Clarify the role of ARPA HCBS funds and other post-2020 policies
- Since effects appear 2021–2024, the post period overlaps:
  - ARPA HCBS enhanced FMAP (2021) and state spending plans,
  - ongoing COVID waves and provider relief,
  - reopening policies and school closures affecting caregiver labor supply.
  
Because you include state×month FE, you are netting out many of these state-level shocks if they affect HCBS and BH similarly; but if they differentially affect HCBS vs BH and correlate with stringency, they matter. At minimum:
- discuss whether ARPA HCBS implementation intensity correlates with initial stringency and could confound (likely in the opposite direction—high-stringency states may also be more policy-active in HCBS supports).

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Important question with clear policy relevance (Medicaid HCBS is huge and fragile).
- High-quality narrative and motivation; the DDD intuition is accessible.
- Valuable new data source (T-MSIS provider spending 2018–2024) and careful code classification.
- Serious approach to inference: clustered SEs, CIs, and RI.

### Critical weaknesses
- Identification remains **fragile**: placebo magnitudes, sensitivity to excluding never-lockdown states, and potential differential shocks to BH vs HCBS correlated with stringency.
- Mechanism story is plausible but not tightly linked to the causal design; churn evidence needs clarification and stronger tests.
- Functional form (linear continuous stringency) is not sufficiently stress-tested.
- Wild cluster bootstrap / finite-sample inference is not fully resolved; “failed” is not enough for a top journal.

### Bottom line
The paper is not yet ready for acceptance, but it has a clear path to becoming a strong AEJ:EP / general-interest-field piece if it (i) convincingly defends the comparison group and differential parallel trends, (ii) resolves the placebo/sensitivity issues, and (iii) strengthens mechanism evidence.

DECISION: MAJOR REVISION