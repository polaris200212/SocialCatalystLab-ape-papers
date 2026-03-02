# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-22T00:37:12.814664
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 18349 in / 4619 out
**Response SHA256:** 9ab4295f170a58d6

---

## Referee Report

### Summary and contribution
The paper asks a clean and original question: whether multiple cultural dimensions (language and religion) combine additively (“modularity”) or interact in shaping political preferences. Switzerland is an unusually good setting because (i) the language border and confessional history are old and plausibly predetermined, (ii) the boundaries are not collinear and cross to create a 2×2 factorial structure, and (iii) referenda provide repeated, comparable measurements of revealed preferences. The headline result—large, stable main effects and a precisely estimated near-zero interaction, supported by permutation inference—is potentially important for the cultural economics literature because it speaks directly to an implicit assumption in much empirical work.

At the same time, for a top general-interest journal, the paper needs a tighter and more credible identification argument (beyond “predetermined centuries ago”), a more careful treatment of inference given spatial correlation and the small number of cantonal clusters for “religion,” and clearer handling of multiple outcomes (six referenda; gender vs non-gender panels). None of these are fatal, but they require substantial revision.

---

# 1. FORMAT CHECK

**Length**
- Based on the LaTeX source, the main text through the conclusion is plausibly **~25–35 pages** in 12pt, 1.5 spacing, excluding references and appendices. This likely meets the “25+ pages” norm, but please verify with the compiled PDF.

**References / bibliography coverage**
- The paper cites some key Switzerland-border papers (Eugster; Basten; Cantoni) and some foundational culture/identity models (Akerlof & Kranton; Bisin & Verdier).
- However, the reference list is not visible (only `\bibliography{references}`), so I cannot confirm breadth. Conceptually important literatures that appear missing (details + BibTeX below) include:
  - **Spatial discontinuity / geographic RD** methods and inference;
  - **Randomization inference and clustered inference best practices**;
  - Broader **culture economics reviews/handbooks** that would help position the “modularity” claim.

**Prose vs bullets**
- Introduction, framework, results, discussion, conclusion are written in paragraphs (good).
- Bullets appear mainly for referendum lists and mechanisms; that is appropriate.

**Section depth**
- Major sections generally have **3+ substantive paragraphs**. The Results and Discussion sections are well developed. Data and Empirical Strategy are adequate.

**Figures**
- As LaTeX source uses `\includegraphics{...}`, I cannot verify axes/visibility. Do not treat this as a failure, but ensure in the PDF that each figure has labeled axes, units, sample, and notes sufficient to stand alone.

**Tables**
- Tables contain real numbers and standard errors; no placeholders observed. Good.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard errors
**PASS.** Regression tables report SEs in parentheses (e.g., Table 2/`tab:main`, `tab:time_gaps`, `tab:robustness`).

### (b) Significance testing
**PASS.** Stars/p-values are reported, and permutation p-values are provided for key coefficients.

### (c) Confidence intervals
**Mostly PASS but should be systematized.**
- The abstract and text report a 95% CI for the pooled interaction, which is good.
- However, the main tables mostly show coefficients+SEs but not CIs. For a paper whose central claim is a “tight bound around zero,” I strongly recommend that **the main results table report 95% CIs explicitly** (at least for the interaction term), and that figures (e.g., forest plot) show CIs clearly.

### (d) Sample sizes
**PASS.** N is shown in main regression tables; referendum-by-referendum table reports N.

### (e) DiD with staggered adoption
Not applicable (no DiD design).

### (f) RDD requirements
Not applicable, but see below: parts of the narrative implicitly borrow credibility from the Swiss “border RDD” literature while not implementing a geographic RD. That creates an expectations gap that you should address more carefully.

### Additional inference concerns (important)
Even though the paper “passes” the mechanical inference checklist, there are **two serious econometric risks** that could overturn precision claims:

1) **Small number of effective clusters for religion**
- Religion is assigned at the **cantonal level** (Catholic vs Protestant cantons), and you exclude mixed cantons, leaving **~21 cantons**. Municipality-clustered SEs (your baseline) may substantially understate uncertainty for coefficients that vary only at the canton level or are highly correlated within cantons.
- You do report canton-clustered SEs in robustness, which is good, but the paper then leans heavily on the “precisely zero” conclusion.

**Suggested fix (high priority):**
- Use **wild cluster bootstrap** p-values / CIs for coefficients involving religion and the interaction (at the canton level). Report these alongside conventional CRSEs.
- Consider **randomization inference that permutes treatment at the canton level** for religion (or uses a restricted permutation scheme consistent with the assignment mechanism).

2) **Spatial correlation / geographic smoothing**
- Municipalities near each other share media markets, commuting zones, socioeconomics, and political campaigns. This can create strong spatial correlation not addressed by municipality clustering (which only accounts for within-municipality correlation across referenda).
- Your panel has repeated outcomes, but the main identifying variation is cross-sectional. Conley-type spatial HAC SEs (or border-segment clustering) may be more appropriate.

**Suggested fix (high priority):**
- Add **Conley (spatial HAC)** standard errors as a robustness check for the main pooled specification.
- Alternatively (or additionally), cluster by **spatial units** (district/Bezirk) or by **cantonal administrative regions**, and show sensitivity.

3) Permutation inference design
- The permutation described (“random reassignments of language and religion labels across municipalities”) is not obviously aligned with the historical assignment process and ignores geography. Unrestricted permutation can be anticonservative or misleading when outcomes are spatially structured.

**Suggested fix:**
- Implement **restricted permutations**:
  - permute language labels *within border-adjacent regions* or within cantons (for language), and permute religion at the canton level (for religion);
  - or permute at the level of “border segments” (e.g., within a bandwidth of the language border) if you move toward a geographic-discontinuity design.

---

# 3. IDENTIFICATION STRATEGY

### What is credible
- The factorial setup is intuitive and the empirical exercise is transparent: you estimate main effects and an interaction, and the interaction is small across many specifications.
- The within-bilingual-canton language estimate (Table 2 col. 5) is a useful check that the language coefficient is not purely “cantonal institutions.”

### What remains weak / under-argued
1) **“Predetermined centuries ago” is not sufficient for causal interpretation**
- Yes, the boundaries were historically determined, but present-day municipality composition, urbanization, sectoral structure, education, and political party systems can all differ systematically across these cultural regions. That can generate a spurious interaction near zero even if there is selection on both dimensions that happens to be additive in outcomes.

2) **Interaction identification is especially demanding**
- Even if the main effects are confounded, the *interaction* could still be identified if the confounding structure is additive. But that is an assumption that should be stated and defended.
- Right now, the paper sometimes reads as if a zero interaction “validates” single-dimension studies as unbiased. That does not follow unless you also argue that (i) main effects are causally identified, or (ii) bias is also additive and does not distort single-dimension estimates in meaningful ways.

3) **A stronger design is available but not used: geographic border discontinuities**
- You explicitly state you are not doing a spatial RDD. That is fine, but then you should not implicitly import the credibility of the border RDD literature without providing a substitute identification argument of similar strength.
- Given the topic and Switzerland setting, the natural next step is to show that results—especially the interaction—also hold **in a border sample** where observables and unobservables are more plausibly balanced.

### Concrete robustness / placebo checks to strengthen identification
High value additions (I strongly recommend at least 2–3 of these):

1) **Border-sample analysis (most important)**
- Restrict to municipalities within X km of the **language border** and/or **confessional border**, and estimate the same interaction model with flexible controls for distance-to-border, canton-pair fixed effects, or border-segment fixed effects.
- Even if you do not present it as a formal RDD, “local-to-border” evidence would substantially raise credibility.

2) **Covariate balance + adjustment**
- Show balance tables/plots for key municipality covariates (population, urbanization, education, income, sector shares, age structure) by the 2×2 groups, and especially within bilingual cantons and within border bandwidths.
- Re-estimate including a richer covariate set (and show interaction stability).

3) **Placebo outcomes**
- You do a gender vs non-gender comparison, which is nice, but it’s not a clean placebo because non-gender referenda differ in topic composition, time period, and partisan bundling.
- Add outcomes that should be unrelated to the proposed channels (e.g., municipal geography features, historical variables predetermined long before modern politics, or pre-period votes on issues plausibly orthogonal to gender norms).

4) **Multiple-testing / outcome-selection transparency**
- You have six gender referenda and (apparently) multiple non-gender votes. A top journal will want clarity on:
  - how the six were chosen;
  - what the full set of plausible “gender referenda” is;
  - whether results hold for the full universe of gender-related proposals since 1981.
- Consider pre-specifying or providing an appendix listing **all candidate referenda** and showing robustness to inclusion/exclusion.

### Do conclusions follow from evidence?
- The paper’s strongest supported claim is narrow: **in this Swiss municipal referendum context, language and historical cantonal religion effects appear additive for the constructed outcomes**.
- The paper’s broader claim—“validating the single-dimension approach that dominates the literature” and implying “unbiasedness”—needs to be toned down or reframed unless you provide stronger causal identification for main effects and/or show that confounding is unlikely.

### Limitations
You do include a limitations subsection; good. I would add explicitly:
- limits from canton-level coding of religion (treatment misclassification);
- spatial correlation and campaign spillovers;
- sensitivity of “domain reversal” to which non-gender votes are selected.

---

# 4. LITERATURE (missing references + BibTeX)

Below are key additions that would materially improve positioning and methods credibility.

## (i) Spatial discontinuity / geographic RD / border designs
These papers provide the right language and best practices for “border” identification and spatial inference, which is central to your setting.

```bibtex
@article{KeeleTitiunik2015,
  author = {Keele, Luke and Titiunik, Roc{\'\i}o},
  title = {Geographic Boundaries as Regression Discontinuities},
  journal = {Political Analysis},
  year = {2015},
  volume = {23},
  number = {1},
  pages = {127--155}
}
```

```bibtex
@article{KeeleTitiunikZubizarreta2015,
  author = {Keele, Luke and Titiunik, Roc{\'\i}o and Zubizarreta, Jos{\'e} R.},
  title = {Enhancing a Geographic Regression Discontinuity Design through Matching to Estimate the Effect of Ballot Initiatives on Voter Turnout},
  journal = {Journal of the Royal Statistical Society: Series A},
  year = {2015},
  volume = {178},
  number = {1},
  pages = {223--239}
}
```

(If you prefer economics citations, you can also cite applied “border RD” work, but the above are the core methods references.)

## (ii) Spatial HAC / Conley standard errors (for spatial correlation)
```bibtex
@article{Conley1999,
  author = {Conley, Timothy G.},
  title = {GMM Estimation with Cross Sectional Dependence},
  journal = {Journal of Econometrics},
  year = {1999},
  volume = {92},
  number = {1},
  pages = {1--45}
}
```

## (iii) Clustered inference best practices / wild bootstrap
```bibtex
@article{CameronMiller2015,
  author = {Cameron, A. Colin and Miller, Douglas L.},
  title = {A Practitioner's Guide to Cluster-Robust Inference},
  journal = {Journal of Human Resources},
  year = {2015},
  volume = {50},
  number = {2},
  pages = {317--372}
}
```

```bibtex
@article{RoodmanEtAl2019,
  author = {Roodman, David and Nielsen, Morten {\O}rregaard and MacKinnon, James G. and Webb, Matthew D.},
  title = {Fast and Wild: Bootstrap Inference in Stata Using boottest},
  journal = {The Stata Journal},
  year = {2019},
  volume = {19},
  number = {1},
  pages = {4--60}
}
```

(You already cite Young 2019; adding Cameron–Miller and a wild-bootstrap reference would bolster the inference discussion.)

## (iv) Culture economics: syntheses to frame “modularity”
```bibtex
@article{AlesinaGiuliano2015,
  author = {Alesina, Alberto and Giuliano, Paola},
  title = {Culture and Institutions},
  journal = {Journal of Economic Literature},
  year = {2015},
  volume = {53},
  number = {4},
  pages = {898--944}
}
```

```bibtex
@article{GiulianoNunn2021,
  author = {Giuliano, Paola and Nunn, Nathan},
  title = {Understanding Cultural Persistence and Change},
  journal = {The Review of Economic Studies},
  year = {2021},
  volume = {88},
  number = {4},
  pages = {1541--1581}
}
```

(Exact pages/issue should be verified; cite the canonical version you use. The point is: anchor the “modularity assumption” claim in widely cited culture overviews.)

## (v) Randomization inference foundations (optional but helpful)
```bibtex
@book{ImbensRubin2015,
  author = {Imbens, Guido W. and Rubin, Donald B.},
  title = {Causal Inference in Statistics, Social, and Biomedical Sciences},
  publisher = {Cambridge University Press},
  year = {2015}
}
```

---

# 5. WRITING QUALITY (CRITICAL)

### (a) Prose vs bullets
**PASS.** The paper is readable and written in paragraphs. Bullets are used appropriately for lists.

### (b) Narrative flow
Strong overall arc: puzzle → modularity assumption → Swiss factorial design → results → implications. The introduction is engaging and clear.

Two narrative risks to address:
1) The paper occasionally over-claims what the evidence supports (e.g., “validating the single-dimension approach” as generally unbiased).
2) The “first direct test” claim is plausible but should be carefully scoped: first direct test *in this setting / using revealed-preference referendum data / with orthogonal historical borders*, etc.

### (c) Sentence quality
Generally crisp and professional. A minor style issue: the paper sometimes repeats “precisely zero” many times; consider varying phrasing and leaning more on graphical CI/bounds.

### (d) Accessibility
Good for a general economics audience. A suggestion: add a short intuitive paragraph early in Results explaining why the interaction is the object of interest and what magnitude would be “economically meaningful” (you do this partially with the ±1.7 pp bound; make it even more explicit).

### (e) Tables
Tables are mostly self-explanatory. Improvements:
- Ensure every table note states the unit (municipality-level), weighting (if any), FE structure, and clustering.
- In Table `tab:time_gaps`, clarify whether SEs are heteroskedastic-robust, clustered, or simple OLS—currently it just says “from OLS” (needs clustering detail).

---

# 6. CONSTRUCTIVE SUGGESTIONS (to increase impact)

1) **Move from “full-sample OLS” to a border-local design (even as robustness)**
   - A local-to-border analysis would dramatically increase credibility and would connect your contribution to the best-known Swiss “culture border” identification tradition.
   - You can still keep the factorial framing; just estimate it on municipalities near where the boundaries cross or near each boundary.

2) **Strengthen inference around the interaction with small-cluster-robust methods**
   - Report wild cluster bootstrap CIs for (Catholic) and (French×Catholic).
   - Consider Conley SEs.

3) **Clarify the construction of “non-gender referenda” and the reversal result**
   - List the non-gender votes used, time period, and a classification rule.
   - Show that the “reversal” is not driven by a particular subset (e.g., EU/immigration votes vs tax votes).
   - Consider a stacked framework: estimate culture effects separately by policy area (immigration, fiscal, defense) rather than a single non-gender index.

4) **Address multiple-outcome inference**
   - You highlight significant interactions for 1981, 2020, 2021 and then emphasize the pooled null. Readers will worry about cherry-picking and multiple testing.
   - Provide a unified approach:
     - family-wise error control / false discovery rate for the six interactions; and/or
     - a hierarchical model or meta-analytic pooling showing mean ≈ 0 with heterogeneity.

5) **Interpretation: what exactly does “modularity” validate?**
   - Tighten the logic:
     - “Additive in outcomes” does not imply “single-dimension estimates are causal/unbiased.”
     - It implies: “If your estimand is the *difference in means by language*, controlling for referendum FE, then omission of religion does not bias the *language main effect* if the true model is additive and religion is independent of language, or if any correlation does not create interaction-driven bias.” Spell out the conditions explicitly.
   - Consider presenting your contribution as: **evidence that interactions are empirically small in a best-case setting**, rather than blanket validation of single-dimension work.

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Novel and clean question; the “modularity assumption” framing is insightful and potentially broadly relevant.
- Switzerland setting is unusually well suited; repeated referenda outcomes are a strong measurement advantage.
- Main empirical result is transparent and (within your chosen specification class) robust.
- You take inference seriously (clustering variants; permutation inference).

### Critical weaknesses (need addressing for top journal)
- Identification is not yet strong enough to support the broad interpretive claims; “historically predetermined” is helpful but not decisive.
- Inference may be overstated given (i) religion assigned at canton level with relatively few cantons, and (ii) spatial correlation not explicitly handled.
- Permutation inference appears insufficiently aligned with the assignment mechanism and geography.
- Outcome selection / multiple-testing concerns for referendum-specific interactions and non-gender construction need more transparency and unified inference.

### Specific path to improvement
Add border-local analyses + spatial/small-cluster-robust inference; clarify non-gender vote selection; and temper/clarify claims about “validating” the broader literature unless you can strengthen the causal argument for main effects.

---

DECISION: MAJOR REVISION