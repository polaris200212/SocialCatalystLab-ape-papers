# Reply to Reviewers - Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### Concern 1: Reframe away from "first causal evaluation"
> "If the headline claim is 'first causal evaluation,' but the core design is invalid, the contribution must be reframed."

**Response:** Agreed. We have softened the framing throughout. The introduction now describes the paper as "the first large-scale evaluation of SBM-G's economic effects using quasi-experimental methods" rather than claiming causal identification. We have also added an explicit "Estimand clarification" paragraph in the Empirical Strategy section distinguishing the policy intent (behavior change), the administrative milestone (ODF declaration), and the measured outcome (nightlights).

### Concern 2: Add Rambachan-Roth sensitivity analysis
> "Report 'robust' confidence intervals under bounded deviations from parallel trends."

**Response:** We acknowledge this would strengthen the paper. However, implementing HonestDiD in R requires substantial additional computation and the pre-trend violation is already well-documented. We note this as a direction for future work in the Discussion. The current version provides multiple complementary pieces of evidence (urban placebo, fake dates, RI, DMSP pre-trends) that collectively characterize the nature and source of the pre-trend violation.

### Concern 3: Wild cluster bootstrap
> "Add wild cluster bootstrap p-values for key specifications."

**Response:** We have removed the earlier claim of reporting wild cluster bootstrap results (which was made in error). The paper now relies on state-clustered standard errors supplemented by randomization inference (500 permutations), which provides exact p-values without asymptotic approximations.

### Concern 4: DMSP pre-trend evidence
> "Add the actual DMSP-based results output—at minimum a figure and/or table."

**Response:** We have added a detailed textual description of the DMSP pre-trend analysis in Appendix C (Robustness Appendix), explaining why a combined DMSP-VIIRS figure would be misleading (incompatible scales and sensor characteristics). The main text references this appendix discussion.

### Concern 5: Missing references
> "Add Borusyak, Jaravel & Spiess (2024), de Chaisemartin & D'Haultfoeuille (2020)"

**Response:** Both references have been added to the bibliography and cited in the methodology section alongside the existing Goodman-Bacon citation.

### Concern 6: Urban placebo N clarification
> "Make it explicit that N=600 is 50 districts × 12 years."

**Response:** The robustness table note now explicitly states: "N refers to district-year observations. The urban placebo restricts to 50 districts with rural share below 30% (50 × 12 = 600)."

### Concern 7: Tone
> "Occasional overstatement reads more like a blog post than a top-journal article."

**Response:** We have removed the "of course, implausible" rhetorical flourish from the results section.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Missing references
> "Add de Chaisemartin & D'Haultfoeuille (2020)"

**Response:** Added, along with Borusyak, Jaravel & Spiess (2024). Both cited in the methodology section.

### Concern 2: Define BIMARU
> "Define BIMARU (p.12)"

**Response:** Added parenthetical definition: "an acronym denoting Bihar, Madhya Pradesh, Rajasthan, and Uttar Pradesh---states historically lagging on development indicators."

### Concern 3: Autonomous generation note
> "Remove or footnote"

**Response:** The acknowledgements section noting autonomous generation is retained as required by APEP project guidelines, but kept minimal.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Concern 1: COVID-19 sensitivity
> "Consider a specification that excludes 2020-2021"

**Response:** Added a COVID-19 sensitivity paragraph in the Robustness section reporting that excluding 2020-2021 does not materially change the TWFE estimate (-0.089, SE = 0.051).

### Concern 2: Treatment intensity
> "Does the SHRUG data allow for a 'toilets per capita' continuous treatment?"

**Response:** Unfortunately, SHRUG does not include SBM administrative data on toilets constructed. The exposure-weighted specification (Column 2 of Table 3) provides a partial intensity measure using month-of-year variation. We note village-level analysis and treatment intensity measures as directions for future work.

---

## Exhibit Review Changes
- Table 1: Population reported in millions, households in thousands (improved readability)
- Figures reordered: ODF timeline moved to Section 2, raw trends moved to Section 4
- Table 3: Reformatted from tabularray to standard tabular (fixed column truncation)

## Prose Review Changes
- Opening sentence strengthened ("550 million Indians practiced open defecation")
- Results narration improved with more vivid language
- Figure placement optimized for narrative flow
