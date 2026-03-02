# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-22T18:14:15.964564
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 15843 in / 4608 out
**Response SHA256:** 7ccbaa1175319b2a

---

## Referee Report: “Smaller States, Bigger Growth? Two Decades of Evidence from India’s State Bifurcations”

### Summary
The paper asks an important and policy-relevant question—whether creating smaller subnational states accelerates economic development—using India’s 2000 trifurcation (Uttarakhand, Jharkhand, Chhattisgarh). It assembles a long district-year panel of nightlights (1994–2013, with an extension to 2023) and applies DiD/event-study methods, modern staggered-adoption DiD estimators, a border-discontinuity restriction, a spatial RDD at the new borders, and Rambachan–Roth (“Honest DiD”) sensitivity bounds.

The paper is unusually transparent about its main identification problem: strong pre-trends and rejection of parallel trends (p=0.005). The revision’s main contribution is to respond to that failure with alternative designs (border restriction, spatial RDD, sensitivity analysis). This is the right direction. However, several inference and design choices remain under-developed or internally inconsistent, and the paper currently overstates what the added designs can salvage given (i) only three treated “events,” (ii) only six state clusters, (iii) pre-trends that likely reflect selection/anticipation, and (iv) a spatial RDD where the “treatment” is a large bundle of state-level changes but the border is also a deep cultural/administrative discontinuity that predates 2000.

I think the project is promising, but it needs a more disciplined identification narrative and a more rigorous, unified inference strategy before it is ready for a top general-interest outlet.

---

# 1. FORMAT CHECK

### Length
- Appears to be **~30–40 pages** of main text in LaTeX (excluding appendix/references), so it likely **meets the 25-page minimum**, but you should confirm final compiled PDF pagination.

### References
- Cites several key items (Oates; Alesina & Spolaore; Callaway–Sant’Anna; Sun–Abraham; Goodman-Bacon; Rambachan–Roth; Calonico et al.; SHRUG; Henderson et al.).
- **Coverage is directionally good but incomplete** for: (i) border discontinuity/spatial DiD practices, (ii) inference with few clusters, (iii) recent DiD pre-trend/test power issues, and (iv) nightlights measurement/VIIRS-DMSP bridging.

### Prose (bullets vs paragraphs)
- **Introduction/Results/Discussion are in paragraphs** (good).
- Institutional background contains some bullet lists (acceptable for describing acts/districts).

### Section depth
- Introduction and Background have multiple substantive paragraphs.
- Some sections (e.g., “Extended Panel” subsection in robustness) read more like brief notes; consider expanding interpretation and linking to identification.

### Figures
- Since this is LaTeX source, I cannot verify rendered figures. You use `\includegraphics{...}` with plausible filenames and captions. **No format flags** here.

### Tables
- Tables contain real numbers (good). Main results include SEs and Ns (good).

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

You do many things right (SEs, clustering discussion, wild cluster bootstrap, permutation tests, RDD with McCrary mention). But there are several critical issues to fix to meet top-journal standards.

## (a) Standard errors
- **PASS** in main TWFE tables: coefficients have SEs in parentheses (Table 2).
- **However**: the paper sometimes reports p-values without also giving **95% confidence intervals** for the same estimand in tables. Figures may have bands, but main tables should show CIs for headline estimates.

## (b) Significance testing
- **PASS**: p-values are reported; you also use wild bootstrap and randomization inference.

## (c) Confidence intervals (95%)
- **PARTIAL FAIL**: spatial RDD reports a robust CI in text ([0.79, 2.27]) which is good, and HonestDiD figure likely shows robust CIs, but **main DiD estimates (TWFE, CS ATT, border DiD)** should also report **95% CIs in the main table or text** in a consistent way.
- Recommendation: add a column or notes line that reports **95% CI** for the main estimate under your preferred inference method (see below).

## (d) Sample sizes
- **PASS**: N is shown (Obs; Districts; Clusters). Good.

## (e) DiD with staggered adoption
- The 2000 trifurcation is essentially **single adoption time** (all treated at 2000/2001). So classic staggered-adoption pathologies are not the central issue, but you still cite Goodman-Bacon and use CS/Sun-Abraham. This is fine.
- What *is* central is **selection/pre-trends** and **few treated clusters**.

## (f) RDD requirements (bandwidth sensitivity, McCrary)
- You mention: optimal BW = 61 km; McCrary p=0.62; robustness across bandwidths (50–250 km) in text.
- **Needs strengthening to PASS at top-journal RDD standards**:
  1. **Show the bandwidth sensitivity in a table/figure** (e.g., rdrobust at 30/45/61/90/120 km; or CCT/IK bandwidths; include polynomial order sensitivity).
  2. Clarify whether you use **bias-corrected robust inference** (Calonico–Cattaneo–Titiunik) and report robust SEs.
  3. Address **spatial correlation**: a boundary RDD with geographic units often needs spatial HAC or randomization inference along the border; simple Eicker-Huber SEs may be optimistic.

### **Most important inference concern: few clusters and inconsistent clustering choices**
- Main TWFE clusters at the **state level (6 clusters)**. That is appropriate in principle given state-level treatment, but with 6 clusters the asymptotics are very weak.
- In Table 5 heterogeneity-by-pair, you cluster at **district level because only 2 clusters per pair**. This is **not credible** for treatment assigned at the state level; district clustering will understate uncertainty because shocks/policies are correlated within states (and the “treatment” is at the state level).
- You need a coherent approach for inference under **(i) few treated clusters** and **(ii) treatment at the state level**:
  - Use **randomization inference** (RI) at the state level more systematically, but acknowledge the support is tiny (20 assignments).
  - Use **wild cluster bootstrap-t** with small G, but also report the limitations.
  - Consider **Conley–Taber (2011)** / **Ferman–Pinto** style inference for DiD with few treated groups (depending on structure).
  - Consider aggregating to the **state-year** level for some estimands (with only 6 units it’s not ideal, but it clarifies what variation identifies the effect), and use permutation/randomization-based inference transparently.

**Bottom line:** Inference is not yet consistently defensible across your core results. This is fixable but requires reworking tables and the “preferred” inferential procedure.

---

# 3. IDENTIFICATION STRATEGY

### What works
- You are forthright that parallel trends fails and you do not sweep it under the rug. That is a strength.
- The border restriction and HonestDiD are reasonable attempts to bound/understand sensitivity.
- Heterogeneity across the three new states is interesting and plausibly important.

### Main identification concerns

#### 3.1 Pre-trends are not just a nuisance—they are evidence of selection/anticipation
Your own narrative says the treated regions were those with political movements and perceived neglect, and you show strong convergence before 2000. That suggests:
- **Selection into treatment** (regions were chosen because of persistent differences and political dynamics),
- Potential **anticipation** (mobilization and pre-2000 investments),
- Or broader **regional convergence** that differs systematically.

Border restriction attenuates but does not eliminate pre-trends. HonestDiD shows breakdown at \(\bar M=0.5\), but your interpretation risks being too optimistic: when pre-trends are large and systematic, many readers will view \(\bar M=0.5\) as not particularly reassuring unless you provide a strong reason that post-period violations must be less than half the maximum pre-period violation.

**Actionable fix:** Make the paper’s central estimand explicit:
- Are you trying to estimate an **average causal effect of state creation** for the three cases?
- Or a **local effect near borders** (RDD)?
- Or a **bound** given non-parallel trends?

Right now, the paper toggles between these without a unifying identification hierarchy.

#### 3.2 Border DiD is not a design unless the identifying assumption is clarified
“Within 150 km of the border” is a sample restriction, not itself identification. You still need:
- A defensible **local parallel trends** assumption,
- Evidence of pre-trends in the border sample,
- And a clear statement of what “local” estimand this identifies.

You show pre-trends are smaller but still present. Then the border DiD still suffers from the same core problem, just reduced.

**Actionable fix:** Treat border DiD as *supporting evidence* and put more weight on:
- A **border event study** with explicit pre-trend tests and a discussion of power.
- A **matched border-pair approach** (see suggestions below), which is often more credible than a simple distance cutoff.

#### 3.3 Spatial RDD at a state boundary is delicate here
State borders in India are historically meaningful. Your own text notes boundaries follow pre-existing divisions (linguistic/cultural/topographic). That undermines a “as-good-as-random at the cutoff” story.

RDD can still be informative if you can argue that:
- Potential outcomes are smooth in distance absent treatment,
- The boundary is not associated with other discontinuous policies *besides* statehood,
- And covariates (including baseline nightlights, growth pre-2000) are smooth.

You mention some covariates; ST share is marginal. But the key threat is **unobserved** discontinuities correlated with the border (administrative capacity, historical institutions, conflict intensity, tribal governance, forest cover, mining geography).

**Actionable fix:** Do stronger RDD validity work:
- Show **pre-period outcomes** (e.g., 1994–2000 growth) do *not* jump at the border (a “placebo RDD”).
- Show **baseline nightlights (1994)** and **pre-2000 trend slope** are continuous at the border.
- Consider **donut RDD** (drop closest observations) if capitals/border towns are special.
- Consider a **border-segment fixed effects** approach (divide boundary into segments; compare nearest neighbors across each segment).

#### 3.4 Mechanisms are mostly narrative
The capital story is plausible, but the paper admits formal capital interaction is uninformative (only 3 capitals). The census comparisons are cross-sectional and likely reflect selection.

**Actionable fix:** Either (i) scale back mechanism claims, or (ii) bring in additional plausibly causal mechanism evidence:
- changes in **public spending**, **road building**, **electrification**, **school/health facility expansion** (many are available in Indian administrative datasets / SHRUG),
- changes in **transfer flows** from Finance Commissions.

---

# 4. LITERATURE (missing references + BibTeX)

You cite some key methods papers, but important related work is missing. Below are high-priority additions.

## 4.1 Few clusters / inference
You cite Conley–Taber (2011) and Cameron et al. (2008), but consider adding:
- **MacKinnon & Webb** on wild cluster bootstrap refinements and reliability.
- **Imbens & Rosenbaum**-style randomization inference framing (conceptual), or **Young (2019)** on robustness (optional).

```bibtex
@article{MacKinnonWebb2017,
  author = {MacKinnon, James G. and Webb, Matthew D.},
  title = {Wild Bootstrap Inference for Wildly Different Cluster Sizes},
  journal = {Journal of Applied Econometrics},
  year = {2017},
  volume = {32},
  number = {2},
  pages = {233--254}
}
```

## 4.2 DiD pre-trends and event-study interpretation
You cite Roth (2022). Also consider:
- **Roth, Sant’Anna, Bilinski, Poe (2023)** on event-study estimators and inference (depending on what you do).
- **Bilinski & Hatfield** on event-study with staggered adoption (even if not staggered, they discuss pitfalls).

```bibtex
@article{RothSantAnnaBilinskiPoe2023,
  author = {Roth, Jonathan and Sant'Anna, Pedro H. C. and Bilinski, Alyssa and Poe, John},
  title = {What's Trending in Difference-in-Differences? A Synthesis of the Recent Econometrics Literature},
  journal = {Journal of Econometrics},
  year = {2023},
  volume = {235},
  number = {2},
  pages = {2218--2244}
}
```

## 4.3 Border discontinuity / geographic RD best practice
You cite Keele et al. (2015), Holmes (1998), Black (1999). Add work that formalizes border RD/border designs:
- **Dell (2010)** is cited; also consider **Cattaneo, Keele, Titiunik, Vazquez-Bare** on geographic RD.
- Also consider **Gibbons, Overman**-style border approaches (context dependent).

```bibtex
@article{CattaneoKeeleTitiunikVazquezBare2016,
  author = {Cattaneo, Matias D. and Keele, Luke and Titiunik, Rocio and Vazquez-Bare, Gonzalo},
  title = {Interpreting Regression Discontinuity Designs with Multiple Cutoffs},
  journal = {Journal of Politics},
  year = {2016},
  volume = {78},
  number = {4},
  pages = {1229--1248}
}
```

(If you instead use a different Cattaneo et al. geographic RD reference, cite the exact one you rely on; the point is to engage the geographic-RD guidance explicitly.)

## 4.4 Nightlights measurement and DMSP–VIIRS bridging
You cite Henderson et al. (2012) and Chen & Nordhaus (2011). Add:
- **Hsu et al.** (cross-sensor calibration, common in nightlights work)
- **Beyer et al.** (systematic comparison of DMSP/VIIRS)

```bibtex
@article{BeyerFrancoBedoyaGaldo2022,
  author = {Beyer, Robert C. M. and Franco-Bedoya, Santiago and Galdo, Virgilio},
  title = {Examining the Economic Impact of Nighttime Lights: A Review and Recommendations},
  journal = {World Bank Research Observer},
  year = {2022},
  volume = {37},
  number = {2},
  pages = {209--235}
}
```

(If you use a different review, swap accordingly; but you should cite a paper that directly addresses measurement limitations and cross-era comparability.)

## 4.5 Policy/domain literature on state formation and Indian federalism outcomes
You cite Tillin and Chand. Consider adding empirical political economy work on Indian state capacity/federal transfers and subnational reorganization if available (even if qualitative). At minimum, the paper would benefit from engaging more deeply with:
- India Finance Commission / transfer allocation literature,
- Empirical work on the effects of administrative decentralization in India (panchayat reforms etc.), to triangulate mechanisms.

---

# 5. WRITING QUALITY (CRITICAL)

### Prose vs bullets
- **PASS** for major sections. The paper is readable and mostly well structured.

### Narrative flow
- Introduction is strong: concrete historical hook + why it matters + what you do + what you find + why it is hard.
- The main weakness is that the narrative sometimes implies a cleaner causal interpretation than the identification section warrants. You partially correct this in Discussion, but you should align claims throughout:
  - If the preferred contribution is “bounds + local evidence,” say so early and consistently.

### Sentence quality / accessibility
- Generally clear. Some claims would benefit from more disciplined language (“suggestive,” “consistent with,” “bounds”) especially around the RDD and the 0.40–0.80 range.

### Tables
- Tables are well formatted. Two improvements:
  1. Put **95% CIs** (or at least a row with CI endpoints) for headline estimates.
  2. Be consistent and transparent about **clustering choice** and when/why it changes.

---

# 6. CONSTRUCTIVE SUGGESTIONS (to strengthen contribution)

## 6.1 Choose a “preferred estimand” and build a hierarchy of evidence
Right now there are four competing “main” numbers: TWFE 0.80, CS ATT 0.29, border DiD ~0.69, spatial RDD 1.37, and trend-adjusted 0.40. A top journal will demand clarity on:
- Which is your **headline causal claim**, if any?
- Which are **diagnostics** vs **bounds** vs **local effects**?

A coherent structure could be:
1. Full-sample DiD: shows patterns but fails PT.
2. Border + pre-period placebo tests: improves comparability but still not decisive.
3. HonestDiD: converts PT violation into transparent sensitivity/bounds (primary).
4. Spatial RDD: separate local design; treated as complementary local evidence, with strong validity checks.

## 6.2 Make the RDD design more credible (or scale it back)
Minimum additions:
- **RDD placebo using pre-period growth**: outcome = 1994–2000 growth; cutoff at border; expect no jump.
- **Continuity of baseline level and pre-trend slope** at cutoff.
- **Bandwidth/polynomial order sensitivity table**.
- Consider a **border-segment matched pairs**: for each treated district near border, match to nearest control district across border (or nearest k), then run paired differences. This is often more intuitive than distance polynomials with 100-ish observations.

## 6.3 Fix inference uniformly (especially heterogeneity)
- Do not cluster at district level when treatment is state-level. Instead:
  - Use **randomization inference within each pair**? (Though with 2 states per pair, assignment is fixed—so you need a different approach.)
  - If you insist on within-pair estimation, treat it as **descriptive heterogeneity** and avoid stars; or use **time-series style** inference within states cautiously.
  - Better: estimate heterogeneity within the unified panel using interactions and keep inference at the state level with wild cluster bootstrap/RI, explicitly acknowledging low power.

## 6.4 Address spillovers and general equilibrium
State creation could shift activity across borders (firms relocate to new capital, migration, reallocation of spending). A border RDD estimates a discontinuity that may partly reflect **re-sorting** rather than net creation. Consider:
- migration/census population changes 1991–2011 near the border,
- whether growth on treated side coincides with decline on control side (zero-sum near border).

## 6.5 Mechanisms: bring one “hard” mechanism measure
Even one strong mechanism result would raise impact:
- Finance Commission transfers per capita (pre/post) by state (even if only 6 states),
- nighttime lights decomposition: urban vs rural masks; or electrification (SHRUG has some infrastructure variables),
- government employment growth (you mention 200k in Uttarakhand—cite and, if possible, measure systematically).

## 6.6 Reframe contribution: from “does it work?” to “when does it work?”
The heterogeneity result is arguably the most compelling. You could elevate this by:
- constructing a pre-2000 governance/capacity index (literacy, road density, conflict incidence, administrative presence),
- interacting treatment with that index (cautiously, given low G),
- interpreting as suggestive “conditions for success.”

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Important question with broad relevance (decentralization/state formation).
- Strong data advantage: long-run district panel of nightlights.
- Transparent about the pre-trends problem; does not hide violations.
- Uses several modern tools (CS DiD, HonestDiD, wild bootstrap, spatial RD).

### Critical weaknesses (must address)
1. **Identification remains fragile**: parallel trends fails; border DiD doesn’t fully fix it; spatial RDD needs much stronger validity work for historically meaningful borders.
2. **Inference is not consistently defensible**, especially heterogeneity results that switch to district clustering.
3. **Multiple estimators yield very different magnitudes**; the paper needs a clear hierarchy and a more cautious causal interpretation.

### Specific improvements (high priority)
- Add RDD placebo tests and bandwidth/polynomial sensitivity tables.
- Standardize inference (preferably RI/wild bootstrap at the treatment assignment level) and remove/avoid misleading “significance” where clustering is inappropriate.
- Present main results as **bounded/sensitivity-based** rather than as a single causal estimate, unless you can credibly restore an identifying assumption.

DECISION: MAJOR REVISION