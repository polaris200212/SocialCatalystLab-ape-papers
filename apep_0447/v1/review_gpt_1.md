# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-24T15:16:18.096534
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 17029 in / 5615 out
**Response SHA256:** 173cff784099390f

---

## Referee Report: “Locked Out of Home Care: COVID-19 Lockdown Stringency and the Persistent Decline of Medicaid HCBS”

### Summary and contribution
The paper studies how COVID-era lockdown stringency affected Medicaid home and community-based services (HCBS), using newly released T‑MSIS provider spending/claims data (2018–2024). The empirical design is a triple-difference (DDD) comparing (i) in-person HCBS “T-codes” to (ii) telehealth-eligible behavioral health “H-codes,” before vs after April 2020, with cross-state variation in lockdown stringency (OxCGRT). The headline result is a sizeable relative decline in HCBS claims in higher-stringency states, and—most interestingly—the effect appears to emerge gradually after 2020 rather than during the acute lockdown months.

This is a timely question with clear policy relevance (pandemic preparedness; workforce fragility in long-term care) and the T‑MSIS provider spending file is potentially a major data contribution. The paper is also unusually transparent about limitations and includes several good-practice checks (pre-trends/event study, placebo timing test, randomization inference).

That said, for a top general-interest journal (or AEJ:EP), the paper needs a substantially stronger case that the DDD comparison is isolating HCBS *supply-side scarring from lockdowns* rather than capturing (a) differential demand shocks to behavioral health that are correlated with stringency, (b) differential pre-existing trends in HCBS vs BH that correlate with state “policy type,” and/or (c) compositional/measurement artifacts in T‑MSIS and code definitions. The core pattern—“no acute effect, but growing divergence later”—is intriguing, but it also raises alternative explanations (telehealth take-up, mental health utilization, Medicaid redetermination timing, coding shifts, ARP HCBS investments) that are not yet ruled out.

Below I separate **format**, **statistical/inference**, **identification**, **literature**, **writing**, and **concrete suggestions**.

---

## 1. FORMAT CHECK

**Length**
- The LaTeX source appears to be roughly **30–40 pages** of main text plus appendix (hard to be exact without the compiled PDF). This is consistent with the “25+ pages” expectation.

**References**
- A bibliography is called (`\bibliography{references}`) but not included in the source provided, so I cannot verify coverage. Based on in-text citations, you cite key DiD papers and some COVID/HCBS context, but the **telehealth/behavioral health COVID literature** and **DDD-specific identification discussion** look underdeveloped (see Section 4).

**Prose vs. bullets**
- Major sections (Introduction, Institutional Background, Data, Empirical Strategy, Results, Discussion) are in **paragraph form**. Bullets appear mainly in the appendix for data construction/classification—appropriate.

**Section depth**
- Most major sections have **3+ substantive paragraphs**. One exception: some Results subsections (e.g., “Heterogeneity”) read as summary paragraphs without showing the underlying estimates/tables. For a top journal, heterogeneity claims should be either (i) fully tabled, or (ii) cut/toned down.

**Figures**
- You include `\includegraphics{...pdf}` for figures. Since I’m reviewing LaTeX source, I cannot verify axes/visibility. I will not flag figure quality.

**Tables**
- Tables contain real numbers (no placeholders). Good.

---

## 2. STATISTICAL METHODOLOGY (CRITICAL)

Overall, the paper **does not fail** on basic inference—SEs and p-values are reported in the main table. Still, several inference upgrades are needed for top-journal standards.

### (a) Standard errors
- **PASS**: Table 2 (“Main Results”) reports **clustered SEs in parentheses** for each coefficient.
- However, several other key results discussed in text (e.g., “jointly significant from quarter 6 onward,” “F-test rejects…”) should be reported in a table/footnote with exact test definitions, degrees of freedom, and p-values.

### (b) Significance testing
- **PASS**: p-values are reported and used.

### (c) Confidence intervals (95%)
- **Partially fails current presentation standard**: you report a 95% CI for one coefficient in the text, and figures mention 95% CI bands, but **main tables do not consistently report 95% CIs**.
- Strong suggestion: add **CI columns** (or a table note) for the main estimands (at least the headline outcome(s): log claims, log paid).

### (d) Sample sizes
- **PASS**: N is reported for main regressions (8,160). States = 51 also reported.

### (e) DiD with staggered adoption
- Not a staggered adoption DiD; treatment is a cross-state intensity with a common post period. Your claim that “forbidden comparisons” concerns do not apply is broadly right. Still, there *is* a modern concern adjacent to that literature: **treatment effect heterogeneity over time** interacting with TWFE/event-study parameterization and the choice of reference period. You should be explicit that the design is not subject to Goodman-Bacon weighting pathologies because adoption timing is common, but that dynamic effects still require careful interpretation (see Identification section).

### (f) Other inference concerns (important)
1. **51 clusters** is usually acceptable, but many readers will still want **wild cluster bootstrap** p-values (Roodman et al.) or randomization inference tied to the identifying variation. You already do randomization inference; I would:
   - Add **wild cluster bootstrap-t** p-values for the headline coefficient as a complement (and explain how RI is implemented—what is permuted, whether FE structure is re-estimated each time, etc.).
2. With only **two “groups” per state (HCBS vs BH)**, the error structure could be highly serially correlated within state×service over 80 months. State clustering is a start, but consider:
   - Showing robustness to **state×service clustering** (still 102 clusters) *and* state clustering (two-way clustering is not feasible with only 2 service types, but clustering at state×service is feasible).
   - Alternatively, report **Driscoll–Kraay** SEs as a robustness check (common in long panels with cross-sectional dependence), although the FE structure is already heavy.

---

## 3. IDENTIFICATION STRATEGY

### What is credible / strong
- The **DDD setup with state×month FE** is a real strength: it absorbs contemporaneous state-level pandemic severity, unemployment, and broad policy environment—anything that hits both HCBS and BH similarly within a month.
- The **event study pre-trends** are helpful and, if they look as described, substantially increase credibility for *differential* parallel trends.

### Central identification threat: the comparison group is plausibly treated
The biggest issue is that your “control” service category—behavioral health—was likely affected by lockdown stringency through **demand**, **telehealth policy expansions**, and **provider behavior**, and these effects may be **persistent**, not purely contemporaneous.

Concretely, the key identifying assumption is not simply “parallel pre-trends,” but something closer to:

> Absent lockdown stringency differences, the *difference* between HCBS and BH would have evolved similarly across states; and any lockdown-driven BH changes are either (i) orthogonal to stringency or (ii) limited to short-run months such that the long-run divergence is attributable to HCBS.

That assumption is not yet convincingly established.

Why the “slow scarring” pattern can be confounded:
- **Mental health utilization increases** may be persistent (not only 2020). If high-stringency states had larger, longer-lasting behavioral health utilization increases (or better telehealth supply), then the HCBS/BH ratio could fall even if HCBS recovered similarly.
- **Telehealth capability** is not randomly distributed. States that were administratively “stricter” may also have had earlier/larger investments in telehealth infrastructure, broadband, managed care contracting, etc. That could generate a BH advantage that grows over time (as telehealth normalizes), mechanically producing your delayed divergence.

Your current argument that the timing “rules out demand shocks” is not fully persuasive because:
- “Demand shocks” need not be concentrated in April–June 2020; they can persist and compound via diagnosis, chronic SUD, provider capacity, and ongoing telehealth reimbursement norms.
- The observed positive coefficient in lockdown months could reflect short-run disruptions to BH operations, followed by a stronger medium-run BH expansion in high-stringency states.

### Recommended design upgrades to strengthen identification (high priority)
1. **Show separate series by service type** in a more formal way:
   - You currently emphasize that BH trends are “broadly parallel.” Make that testable: run a DiD-style regression **only on BH outcomes** with `Stringency_s × Post_t` (and appropriate FE) to show whether BH itself is differentially affected by stringency.
   - Likewise, run the analogous regression **only on HCBS**. This will help readers see whether the DDD is “HCBS falling” vs “BH rising,” which matters for the mechanism and credibility.

2. **Expand comparison groups beyond BH in a systematic way**:
   - You have one alternative (CPT professional). Consider a more convincing “placebo service set” approach:
     - Compare HCBS (T-codes that are truly in-home personal care/habilitation) to other **in-person essential services** that should face similar mobility constraints but different workforce structure.
     - Or compare BH (H-codes) to other telehealth-amenable categories to see whether high-stringency states experienced generalized “telehealth expansion” rather than HCBS-specific scarring.

3. **Pre-period predictors and differential trends**:
   - Given the cross-state nature of treatment, readers will worry that stringency correlates with **state type** (politics, urbanization, Medicaid generosity, managed care penetration).
   - You can’t include time-invariant state controls directly because of state×month FE, but you *can* test for differential pre-period evolutions in the HCBS–BH gap by interacting stringency with:
     - pre-2020 trends (e.g., 2018–2019 slope in HCBS/BH ratio),
     - baseline telehealth adoption proxies (if available),
     - baseline BH share / HCBS share,
     - managed care share in Medicaid (MACPAC data),
     - urbanization/broadband.
   - At minimum, show that stringency is not strongly predicted by **pre-period changes** in the HCBS/BH ratio.

4. **Mechanism evidence needs to be elevated from narrative to analysis**
   - The mechanism story is workforce exit. You have provider counts, but the estimates are noisy and not clearly tied to the long-run divergence.
   - You should add at least one of:
     - **BLS state-level employment/wage series** for home health/personal care aides (SOC 31-1120/31-1121; OES/OEWS; QCEW industry series) interacted with stringency; or
     - **HHA/PCS agency closures / NPI exits** in NPPES (deactivation, taxonomy changes) to show actual provider attrition patterns; or
     - evidence that declines are concentrated in the most in-person codes (e.g., **T1019** specifically) rather than T-codes that are not strictly home-care (you mention T1015 as FQHC, which is not HCBS—this classification choice is a red flag; see below).

### A potentially serious measurement/classification concern: what exactly are “T-codes HCBS”?
In multiple places you equate “T-prefix codes” with “HCBS.” But **T-codes include services that are not HCBS** (your own example: **T1015 = FQHC visit** is not HCBS/home care). This is a major concern because:
- If your “HCBS” basket includes clinic-based services, the in-person vs telehealth contrast is blurred.
- The credibility of the design rests on a sharp modality distinction.

**This needs to be fixed or at least tightly justified**:
- Provide a **code list** (top 20 by spending/claims) and classify which are truly in-home personal care/habilitation/attendant care.
- Re-run main results restricting to a “clean HCBS subset,” e.g., personal care/attendant/habilitation codes commonly used in 1915(c) waivers and state plan personal care.
- Consider using **place-of-service** or provider taxonomy if available (even imperfect) to distinguish home-based from clinic-based.

If after cleaning the code set the results remain, the paper becomes much more persuasive.

---

## 4. LITERATURE (with missing references + BibTeX)

Because the `.bib` file is not shown, I focus on **likely missing key citations** given the design and domain.

### (A) Methods / identification for DiD/event studies and inference
You cite some (Goodman-Bacon; Callaway & Sant’Anna; Sun & Abraham; Cameron & Miller). I strongly recommend adding:

1. **de Chaisemartin & D’Haultfoeuille** on TWFE with heterogeneous effects (even if you argue it doesn’t apply, referees expect you to acknowledge and delimit it).
```bibtex
@article{DeChaisemartinDHaultfoeuille2020,
  author  = {de Chaisemartin, Cl{\'e}ment and D'Haultf{\oe}uille, Xavier},
  title   = {Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects},
  journal = {American Economic Review},
  year    = {2020},
  volume  = {110},
  number  = {9},
  pages   = {2964--2996}
}
```

2. **Roodman et al.** on wild cluster bootstrap for DiD-style settings.
```bibtex
@article{RoodmanEtAl2019,
  author  = {Roodman, David and Nielsen, Morten {\O}rregaard and MacKinnon, James G. and Webb, Matthew D.},
  title   = {Fast and Wild: Bootstrap Inference in Stata Using boottest},
  journal = {The Stata Journal},
  year    = {2019},
  volume  = {19},
  number  = {1},
  pages   = {4--60}
}
```

3. If you keep randomization inference as a featured robustness device, cite a canonical reference:
```bibtex
@book{Rosenbaum2002,
  author    = {Rosenbaum, Paul R.},
  title     = {Observational Studies},
  publisher = {Springer},
  year      = {2002},
  edition   = {2}
}
```

### (B) COVID telehealth and behavioral health utilization
To defend BH as a comparison group (or to discuss threats), you need to engage the telehealth/BH surge literature more directly. Suggested additions:

```bibtex
@article{PatelMehrotraHuskampUscherPittman2018,
  author  = {Patel, S. and Mehrotra, A. and Huskamp, H. A. and Uscher-Pines, L. and Ganguli, I. and Barnett, M. L.},
  title   = {Trends in Outpatient Care Delivery and Telemedicine During the {COVID-19} Pandemic in the {US}},
  journal = {JAMA Internal Medicine},
  year    = {2021},
  volume  = {181},
  number  = {3},
  pages   = {388--391}
}
```

```bibtex
@article{Bokolo2020,
  author  = {Bokolo, Anthony Jnr},
  title   = {Use of Telemedicine and Virtual Care for Remote Treatment in Response to {COVID-19} Pandemic},
  journal = {Journal of Medical Systems},
  year    = {2020},
  volume  = {44},
  number  = {7},
  pages   = {132}
}
```

(If you prefer economics/health policy outlets, you could instead cite NEJM Catalyst / Health Affairs telehealth syntheses; the key is to document differential telehealth expansion plausibly correlated with state policy strictness.)

### (C) HCBS / long-term care during COVID
You cite some workforce pieces, but you should connect to work on long-term care disruptions during COVID (even if focused on nursing homes) to place your mechanism and timing. For example, nursing home policy and spillovers are heavily studied; even if your setting is HCBS, readers will want that context. One candidate:
```bibtex
@article{GorgesKonetzka2020,
  author  = {Gorges, Robert J. and Konetzka, R. Tamara},
  title   = {Staffing Levels and {COVID-19} Cases and Outbreaks in {US} Nursing Homes},
  journal = {Journal of the American Geriatrics Society},
  year    = {2020},
  volume  = {68},
  number  = {11},
  pages   = {2462--2466}
}
```

(You may also want to add policy/measurement sources for Medicaid HCBS such as MACPAC reports, KFF issue briefs, and CMS guidance specific to HCBS waivers.)

### (D) T‑MSIS data quality and Medicaid claims measurement
Given you hinge part of the contribution on “newly released T‑MSIS provider spending,” top journals will expect discussion/citation of known T‑MSIS completeness/quality issues and validation:
```bibtex
@misc{MACPAC2023TMSIS,
  author = {{Medicaid and CHIP Payment and Access Commission}},
  title  = {T-MSIS Data Quality and Use},
  year   = {2023},
  note   = {Issue brief / report},
  url    = {https://www.macpac.gov/}
}
```
(Replace with the exact MACPAC document you use.)

---

## 5. WRITING QUALITY (CRITICAL)

### Strengths
- Clear motivation and strong opening. The “you cannot deliver a bath over Zoom” line is effective and accessible.
- Good signposting: the intro explains the design and preview results cleanly.
- The paper generally avoids jargon and explains the DDD intuition.

### Main writing/communication issues to address
1. **Over-claiming vs. what is estimated**
   - At times the narrative moves from “relative decline in claims” to “workforce scarring” as if established. Right now, “workforce scarring” is a plausible interpretation, not yet a demonstrated mechanism.
   - I recommend tightening language: “consistent with,” “suggestive of,” and reserve stronger claims for when you add mechanism evidence.

2. **Clarify what is actually identified**
   - You identify the effect of cross-state differences in *peak lockdown stringency* on the *post-2020 relative trajectory of T-codes vs H-codes*. That is not the same as “lockdowns caused persistent HCBS decline” unless the comparison group is credibly counterfactual for HCBS.
   - A short paragraph in the Empirical Strategy section explicitly stating “What β is / is not” would reduce reader skepticism.

3. **HCBS definition needs precision**
   - Calling all T-codes “HCBS” while listing T1015 (FQHC) as an example undermines confidence. This is both a methodological and an expository problem.

4. **Robustness table interpretation**
   - Table 4 includes “Monthly Stringency (Post Only)” with a different scale and sign; the explanation is plausible but currently reads ad hoc. Consider moving that to an appendix unless it is fully integrated (exact specification, interpretation, why it’s informative rather than contradictory).

---

## 6. CONSTRUCTIVE SUGGESTIONS (TO MAKE IT MORE IMPACTFUL)

### A. Make the “HCBS” treatment sharper (highest priority)
- Build a “clean HCBS” subset:
  - Personal care/attendant care/habilitation codes (e.g., T1019 and closely related).
  - Exclude ambiguous or clearly non-HCBS T-codes (e.g., FQHC-related).
- Show that results hold for:
  - (i) T1019 alone,
  - (ii) top 5 HCBS codes by spending,
  - (iii) “all T-codes” as a broader, secondary measure.

### B. Decompose whether DDD comes from HCBS falling or BH rising
- Add two simple, transparent regressions:
  1. Outcome = log(HCBS) at state×month; estimate `Stringency_s × Post_t` (with state FE and month FE, maybe state trends).
  2. Outcome = log(BH) similarly.
- Even if you prefer the saturated FE DDD as the main specification, these decompositions help readers understand the source of the ratio change and assess threats.

### C. Strengthen the case against “BH is treated” confounding
- Use additional comparison categories:
  - Another telehealth-amenable category besides BH (e.g., outpatient E&M CPT codes) but explicitly isolate those most telehealthable.
  - Another in-person non-HCBS category to show that the divergence is specific to home care rather than generic in-person care.
- Consider a “stacked DDD” across multiple comparison groups to show stability.

### D. Mechanism: workforce scarring—bring data
- Link to external labor market data:
  - State-level employment/wages for home health/personal care aides, interacted with stringency.
- Within T‑MSIS/NPPES:
  - Track **provider exit**: NPI-month activity spells, permanent exits, re-entries.
  - Examine whether exits are concentrated among **individual NPIs vs organizational NPIs**, consistent with your small-provider vulnerability story.

### E. Policy interactions that could explain the long-run divergence
Because your effects grow in 2021–2024, you should address other major policy changes that differ across states and could correlate with stringency:
- ARP HCBS enhanced FMAP implementation choices (state take-up and timing).
- State-level Medicaid rate increases for personal care.
- Managed care contracting changes.
Even if you cannot include them cleanly due to FE, you can:
- Show that stringency is not strongly correlated with ARP HCBS spending responses (or explicitly analyze heterogeneity by ARP take-up).

### F. Clarify the estimand and timing logic
- The “peak April 2020 stringency” is a cross-sectional “dose.” Make explicit:
  - Why April peak is the right dose rather than duration/cumulative restrictions.
  - Why a single-month dose predicts a 4-year divergence (this is plausible via scarring, but readers will want a more explicit conceptual model).

---

## 7. OVERALL ASSESSMENT

### Key strengths
- Important question with direct policy relevance and a potentially high-value new dataset.
- Thoughtful baseline design with heavy fixed effects and clear exposition.
- Event-study pre-trends, placebo timing, and randomization inference are all good signals.

### Critical weaknesses (fixable but substantial)
1. **Comparison group validity (BH may be affected by stringency in persistent ways)** is not yet convincingly resolved.
2. **HCBS classification via T-codes appears too broad** and includes non-HCBS services; this threatens the core in-person vs telehealth distinction.
3. Mechanism (“workforce scarring”) is currently more narrative than evidenced, while the key empirical novelty is the delayed divergence.

### Specific, high-return improvements
- Redefine HCBS using a clean code subset and re-estimate.
- Decompose effects into HCBS-only and BH-only responses to stringency.
- Add external workforce evidence (BLS/QCEW/OEWS) or provider exit/re-entry patterns.
- Expand and tighten the literature discussion around telehealth/BH shifts and T‑MSIS data quality.

Given the promise of the question and the encouraging pre-trend evidence, I view this as **salvageable and potentially publishable**, but it needs a substantial redesign of the service classification and a stronger argument that the DDD comparison isolates HCBS-specific disruption rather than a treated comparison group.

DECISION: MAJOR REVISION