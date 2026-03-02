# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-24T16:12:41.947679
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 20917 in / 4799 out
**Response SHA256:** 3847e6d18489f51f

---

## Referee Report: *“Criminal Politicians and the Composition of Local Development: Evidence from Close Elections in India”*

### Summary
The paper revisits a prominent claim in the political economy of development: that electing “criminal” politicians harms local development. Using a close-elections sharp RDD (criminal vs. non-criminal top-two candidates) in Indian state assembly elections, the paper finds the opposite sign from Prakash, Rockmore, and Uppal (2019): criminal winners increase nightlights growth by ~13–17pp. The paper then “decomposes” development using Census Village Directory outcomes (electricity, post office, commercial bank presence) and finds no effects on electricity or post offices but a negative effect on bank presence (p≈0.019), with heterogeneity concentrated in BIMARU states.

The paper is promising: it addresses an important question, uses a quasi-experimental design, and attempts to reconcile nightlights with specific public-goods channels. However, in its current form, several identification and measurement issues materially weaken interpretability—especially (i) sample selection induced by defining the RDD sample using the *top-two candidates with differing criminal status*, and (ii) the nightlights outcome construction with truncated/variable post-windows that mechanically differ by election year and potentially by treatment. These are fixable, but they require substantial additional analysis and clarity.

---

# 1. FORMAT CHECK

### Length
- Appears to be **well above 25 pages** in compiled form (main text + multiple appendices, many figures/tables). Likely ~35–50 pages excluding references, depending on formatting. **PASS**.

### References / bibliography coverage
- Cites key items (Lee 2008; Calonico et al.; McCrary; Henderson; Vaishnav; SHRUG; Prakash et al.).
- **But** the RDD literature positioning is incomplete (missing several canonical RDD review and practice references), and the nightlights measurement literature could be strengthened (VIIRS transition; DMSP comparability; saturation corrections). See Section 4 for concrete additions. **Needs strengthening**.

### Prose vs bullets
- Major sections are in paragraph form. Bullets are used appropriately only for lists in the appendix. **PASS**.

### Section depth
- Introduction, data, strategy, results, discussion each have ≥3 substantive paragraphs. **PASS**.

### Figures
- Since this is LaTeX source with `\includegraphics{...}`, I cannot visually verify axes/data. Captions suggest proper axes and binned scatter / density plots. **No flag** (per your instruction).

### Tables
- Tables contain real numbers and standard errors; no placeholders. **PASS**.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard errors for every coefficient
- Main treatment effects are reported with SEs in parentheses in Tables 2, 3, 4, etc. **PASS**.

### (b) Significance testing
- p-values are reported, and the text interprets them. **PASS**.

### (c) 95% confidence intervals
- Some figures mention 95% bands, but **tables generally do not report 95% CIs** explicitly.
- Top journals increasingly expect confidence intervals at least for headline results (and rdrobust naturally produces them). **Fix**: add 95% robust bias-corrected CI columns (or bracketed intervals) in the main results tables (nightlights and mechanisms) and heterogeneity table.

### (d) Sample sizes
- Tables report Total N and effective N in key specifications. **PASS**.

### (e) DiD with staggered adoption
- Not applicable (RDD paper). **N/A**.

### (f) RDD requirements: bandwidth sensitivity & manipulation test
- Bandwidth sensitivity is presented; McCrary test is presented (also `rddensity`). **PASS**.

### Additional inference concerns (important)
1. **Clustering / dependence structure**:  
   - You include a “state-clustered SE” robustness column. But the unit is constituency-election; outcomes (nightlights) and politics are spatially correlated; many constituencies are observed across elections? (Your construction suggests one observation per constituency-election, but a constituency can appear multiple times across years.)  
   - If constituencies repeat over time, you should consider **two-way clustering** (state × constituency) or at least **constituency clustering** when the same constituency appears multiple times, and clarify whether/why repeats matter for your estimand. RDD typically leans on local randomization, but dependence can still understate uncertainty.

2. **Multiple testing**:
   - You correctly discuss Bonferroni for 3 mechanism outcomes. Good.  
   - But heterogeneity splits (BIMARU, SC reserved, state-by-state, period split) are numerous. At minimum, be explicit: which heterogeneity analyses are pre-specified vs exploratory; consider controlling the false discovery rate or presenting them as descriptive.

---

# 3. IDENTIFICATION STRATEGY (MOST IMPORTANT)

The basic “close election RDD” logic is standard, and you implement modern rdrobust practices. The main threats are not generic RDD issues; they arise from **how the running variable and sample are constructed** and from **timing/measurement choices**.

## 3.1. Key identification threat: endogenous sample definition (top-two “differ in criminal status”)
You restrict to elections where the **top two vote-getters differ in criminal status**, then define the running variable as the margin between those two.

This is potentially a *selection-on-a-post-treatment/collider-type event*: whether a criminal candidate is in the top two (and whether the top two differ) is itself an equilibrium outcome influenced by constituency characteristics, party entry, candidate quality, and potentially **criminal networks**. Even if margin near zero is quasi-random *conditional on being in this selected set*, the estimand becomes “effect of electing a criminal candidate **in elections where a criminal and non-criminal are the top two**,” which may be a highly selected political environment. You acknowledge external validity limits, but the deeper issue is that this selection may differ *smoothly* or *discontinuously* around the cutoff in ways that interact with outcomes.

**Concrete checks / fixes**
- **Continuity of selection probability**: Show that the probability an election falls into the “RDD-eligible” set is smooth in a neighborhood around the cutoff *under an alternative pre-defined running variable*. This is tricky because your current running variable is defined only for eligible races. A more convincing approach:
  1. Define a running variable that exists for all elections (e.g., margin between winner and runner-up regardless of criminal status; or winner’s criminal status indicator with margin to runner-up).
  2. Examine whether “top-two differ in criminal status” changes discontinuously at any relevant threshold (it shouldn’t mechanically, but the point is to demonstrate selection isn’t tied to close races in a way that invalidates inference).
- **Alternative estimand / design**: Consider a design defined as: among all elections where at least one of the top two is criminal, estimate an RD where treatment is “winner is criminal,” running variable is winner’s margin over runner-up, and include an interaction for whether runner-up is criminal. This avoids conditioning on “different criminal status” as a sample inclusion rule (or at least lets you show robustness).
- At minimum, clarify in the abstract/introduction that the causal effect is **for a selected set of close two-way contests with mixed criminal status**, and discuss how that compares to Prakash et al.’s construction (did they use the same restriction?).

## 3.2. Nightlights outcome construction and truncation is a serious concern
You define “NL growth” using a pre-window up to 3 years and a post-window up to 5 years, **capped at 2013** due to DMSP-OLS. For elections near 2012, the post window is mechanically shorter. You note this in Discussion, but it is not treated as a core threat.

This can create **systematic measurement differences by election year**, and if criminal winners are not perfectly balanced across election years within bandwidth, you can get biased estimates. Even if year balance holds, the estimand changes across elections (2-year effect vs 5-year effect), which complicates interpretation and comparison to Prakash et al.

**Concrete fixes**
- Use a **fixed-horizon outcome** whenever possible, e.g.:
  - \( \Delta NL_{t+2} - NL_{t-1} \) (or log difference) with a constant 2-year post horizon for all elections (dropping elections without full horizon).  
  - Show robustness for horizons 1, 2, 3, 4 years (event-time style).
- Alternatively, estimate separate RDs by election-year groups where the post-window length is constant, and then meta-analyze.
- Present a table that shows distribution of post-window lengths by treatment status within the MSE bandwidth (to document whether truncation is differential).

Given the headline result is a sign reversal relative to the benchmark study, this measurement issue needs to be addressed more forcefully than a short discussion paragraph.

## 3.3. Donut sensitivity
Your donut results show attenuation and loss of significance by ±1.5pp. You interpret two possibilities (loss of power vs manipulation). This is good, but for a top journal this will be viewed as a major fragility unless you can pin down why.

**Suggestions**
- Implement **local randomization inference** (Cattaneo, Titiunik, et al.) for very small windows (e.g., ±1pp, ±2pp) to complement rdrobust. If close races are “as good as randomized,” randomization inference can be persuasive and may clarify whether the very closest races behave oddly.
- Examine whether **election administration intensity** (e.g., turnout, number of polling stations, complaints, repolls if data exist) differs at the cutoff and especially within ±1–2pp. Even descriptive evidence would help adjudicate manipulation concerns.
- Show whether the donut attenuation is driven by **excluding the most informative mass** (many observations cluster near zero). A power calculation / minimal detectable effect could help interpret insignificance.

## 3.4. Village Directory mechanisms: timing and interpretation
You restrict mechanisms to 2008–2010 elections, which is sensible for temporal precedence. But two concerns remain:

1. **Heterogeneous exposure length** even within 2008–2010 (1–3 years). That likely attenuates effects; but it could also interact with criminal type or state capacity.  
   - Consider estimating separately for 2008 vs 2009 vs 2010 (even if imprecise), or use a simple exposure-weighted outcome (e.g., treat 2008 elections as 3-year exposure, 2010 as 1-year exposure) and test for monotonicity.

2. **Bank presence as “public good”**: commercial banks are not purely government-provided infrastructure. Branch placement responds to private profitability, regulation, and crime risk. A negative effect could mean reduced formal finance due to intimidation/extortion (consistent with your story), but also could reflect shifts to non-bank finance or changes in measurement/aggregation.
   - Strengthen interpretation by adding auxiliary outcomes if feasible: cooperative banks, ATMs (if available), SHG penetration, MFI presence, or credit/deposit data at district level (RBI’s Basic Statistical Returns / SLBC where feasible).

---

# 4. LITERATURE (MISSING REFERENCES + BibTeX)

You cite many relevant works, but for a top general-interest outlet you should add several foundational RDD and nightlights measurement references, and (depending on framing) additional political selection/corruption literature.

## 4.1 RDD foundations / practice (strongly recommended)
1. **Lee & Lemieux (2010, JEL)** — canonical RDD review; especially important since this is an elections-RD paper.  
```bibtex
@article{LeeLemieux2010,
  author  = {Lee, David S. and Lemieux, Thomas},
  title   = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year    = {2010},
  volume  = {48},
  number  = {2},
  pages   = {281--355}
}
```

2. **Imbens & Kalyanaraman (2012, REStud)** — bandwidth selection classic (even if you use CCT/rdrobust).  
```bibtex
@article{ImbensKalyanaraman2012,
  author  = {Imbens, Guido and Kalyanaraman, Karthik},
  title   = {Optimal Bandwidth Choice for the Regression Discontinuity Estimator},
  journal = {Review of Economic Studies},
  year    = {2012},
  volume  = {79},
  number  = {3},
  pages   = {933--959}
}
```

3. **Cattaneo, Idrobo & Titiunik (2020 book)** — practical RD guidance, local randomization, and reporting norms.  
```bibtex
@book{CattaneoIdroboTitiunik2020,
  author    = {Cattaneo, Matias D. and Idrobo, Nicolas and Titiunik, Rocio},
  title     = {A Practical Introduction to Regression Discontinuity Designs: Foundations},
  publisher = {Cambridge University Press},
  year      = {2020}
}
```

4. **Cattaneo, Jansson & Ma (2020, JASA)** — modern manipulation/density testing framework (you cite “practical” but the formal ref is useful).  
```bibtex
@article{CattaneoJanssonMa2020,
  author  = {Cattaneo, Matias D. and Jansson, Michael and Ma, Xinwei},
  title   = {Simple Local Polynomial Density Estimators},
  journal = {Journal of the American Statistical Association},
  year    = {2020},
  volume  = {115},
  number  = {531},
  pages   = {1449--1455}
}
```

## 4.2 Nightlights measurement and DMSP vs VIIRS (recommended)
5. **Chen & Nordhaus (2011, PNAS)** — validation and measurement of lights as economic proxy.  
```bibtex
@article{ChenNordhaus2011,
  author  = {Chen, Xi and Nordhaus, William D.},
  title   = {Using Luminosity Data as a Proxy for Economic Statistics},
  journal = {Proceedings of the National Academy of Sciences},
  year    = {2011},
  volume  = {108},
  number  = {21},
  pages   = {8589--8594}
}
```

6. **Elvidge et al. (2017, Remote Sensing)** — VIIRS improvements over DMSP, relevant for your “future work” and for interpreting truncation/saturation.  
```bibtex
@article{Elvidge2017,
  author  = {Elvidge, Christopher D. and Baugh, Kimberly E. and Zhizhin, Mikhail and Hsu, Feng-Chi and Ghosh, Tilottama},
  title   = {VIIRS Night-Time Lights},
  journal = {Remote Sensing},
  year    = {2017},
  volume  = {9},
  number  = {7},
  pages   = {1--15}
}
```
*(Page ranges vary by journal formatting; please verify exact pagination for your BibTeX.)*

## 4.3 Political selection / criminal politicians (optional but potentially useful)
Depending on how you frame the sign reversal and mechanisms, consider citing work on politician quality/selection and corruption’s effects (e.g., Ferraz & Finan on audits; political selection models). You already cite some corruption-related work, but the paper currently leans heavily on Vaishnav and Prakash et al. Strengthening the broader selection/discipline context could help readers interpret “criminal” as a bundle.

---

# 5. WRITING QUALITY (CRITICAL)

### Prose vs bullets
- Strong: narrative is in full paragraphs; bullets are not misused. **PASS**.

### Narrative flow
- The introduction sets up the puzzle well and clearly states contribution and findings.
- However, because the main result contradicts a benchmark, readers will immediately ask: “Is this a design difference, a measurement difference, or a real structural change?” You partially answer this in Discussion, but the paper would benefit from moving **some reconciliation work earlier**—e.g., a short “Why might our design differ?” paragraph in the introduction that previews the key comparability checks you will implement (common horizon nightlights; sample harmonization; replication-style table).

### Accessibility
- Generally accessible; RDD is explained clearly.
- Some interpretations are currently stronger than the evidence (e.g., “criminal politicians crowd out banks” vs “associated with lower bank presence”). Tighten causal language around mechanisms given borderline multiple-testing adjustment and measurement limitations.

### Tables
- Tables are mostly self-contained and professional.
- Recommended: add 95% CIs; add a note clarifying whether observations repeat across constituencies over time and how SEs address this.

---

# 6. CONSTRUCTIVE SUGGESTIONS (HOW TO MAKE THIS PAPER MORE IMPACTFUL)

## 6.1 Make reconciliation with Prakash et al. (2019) a first-class contribution
Right now, the paper says “period/bandwidth/delimitation may explain differences,” but does not *demonstrate* it. A top-journal reader will want a structured reconciliation:

- **Harmonize sample and outcome definitions** as closely as possible:
  - Same election years overlap (e.g., replicate their pre-2008 subset).
  - Same bandwidth choices (their fixed bandwidths vs your MSE-optimal).
  - Same outcome horizon (fixed 2-year/3-year post windows).
- Provide a “specification ladder” table showing how the estimate evolves as you move from their setup to yours. This is often the single most persuasive way to resolve sign reversals.

## 6.2 Strengthen the RDD estimand and reduce concerns about endogenous “top-two differs” selection
- Provide robustness using an alternative definition of the running variable / sample that does not condition on “top-two differ” in the same way.
- At minimum, show descriptive comparability of your selected RDD elections to the full set and discuss what is identified.

## 6.3 Treat timing/truncation as an identification issue, not just a limitation
- Re-estimate nightlights effects with **fixed post-election horizons** and show whether the sign persists.
- Consider using **VIIRS (2012+)** to extend and also to avoid the 2013 truncation (even if not perfectly comparable to DMSP, you can use within-sensor panels).

## 6.4 Deepen mechanisms beyond three village amenities (if feasible)
The “private prosperity without public investment” interpretation is intriguing but currently under-identified. Consider adding at least one of:

- Roads (PMGSY) completion near constituency (if data exist), or SHRUG infrastructure measures.
- Nightlights decomposition: urban vs rural pixels; saturation-prone vs non-saturated areas; new lighted area (extensive margin) vs intensity (intensive margin).
- Crime/violence outcomes (if available) to support the “informal coercion” channel that could deter banks.

## 6.5 Clarify interpretation of “criminal”
Given the binary measure, readers will ask: is this about serious violent criminals, minor cases, or politically motivated charges?
- Provide heterogeneity by **serious charges** and **number of cases** (even if noisy), at least for nightlights. Even a simple split (0 vs 1–2 vs 3+) or serious vs non-serious would help.

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Important question with broad interest (governance, political selection, development).
- Clear design and implementation using modern RDD tooling (rdrobust, density tests, bandwidth sensitivity, placebo cutoffs).
- Novel and valuable attempt to connect aggregate satellite proxies to specific “composition” outcomes.
- Heterogeneity (BIMARU) is substantively meaningful and potentially a major insight.

### Critical weaknesses (need substantial work)
1. **Endogenous sample construction (top-two differ in criminal status)** raises concerns about what is identified and comparability to prior work.
2. **Nightlights growth measurement with variable/truncated post windows** could plausibly drive sign and magnitude; must be addressed with fixed-horizon outcomes.
3. **Donut fragility** remains unresolved; without additional evidence (local randomization inference, administrative manipulation correlates, etc.), many readers will discount the headline estimate.
4. Mechanism claim (“crowding out banks”) is intriguing but currently **borderline under multiple testing** and could reflect bank-specific economics rather than public-good provision.

### Most productive path forward
- Add fixed-horizon nightlights results and a reconciliation “ladder” with Prakash et al.
- Provide alternative sample/running-variable robustness that reduces selection concerns.
- Add local randomization / close-window inference and deeper investigation of donut sensitivity.
- Expand and sharpen the mechanism story with additional outcomes or more careful causal language.

---

DECISION: MAJOR REVISION