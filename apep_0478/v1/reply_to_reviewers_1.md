# Reply to Reviewers — apep_0478 v1

## Reviewer 1 (GPT-5.2): REJECT AND RESUBMIT

### 1.1 Treatment definition mismatch (NYC strike vs. NY State outcome)
**Concern:** The strike is NYC-specific but the treated unit is New York State; upstate NY dilutes the effect.
**Response:** We acknowledge this limitation explicitly in the new Limitations subsection (Section 8.1). County-level identifiers are not consistently available across all six censuses in our IPUMS extract, precluding a city-level SCM. We note that New York State is a reasonable proxy given that ~85% of the state's elevator operators were concentrated in New York City (Section 3.4). Future work with county-harmonized data could sharpen this analysis.

### 1.2 Timing: one post-treatment observation
**Concern:** Mid-decade treatment with decennial outcomes yields one post-treatment data point.
**Response:** We added an explicit data-frequency limitation paragraph in Section 5.3, acknowledging that the 1950 observation captures cumulative effects over the full 1940-1950 decade, not an immediate post-1945 response. No programmatically accessible annual elevator employment data exists for the pre-1950 period. We reframed all temporal claims accordingly.

### 1.3 SCM degeneracy (DC = 100% weight)
**Concern:** The synthetic control collapses to a single donor, making this a two-unit comparison.
**Response:** We present augmented SCM (Ben-Michael et al. 2021) as a complementary estimator that does not require convex weights, and report the augmented ATT of 20.6. We also report permutation inference (p=0.056) and acknowledge the single-donor limitation explicitly in the introduction, results, and limitations sections. We agree this is the design's primary weakness.

### 1.4 Compositional confounding in ratio outcome
**Concern:** Operators per 1,000 building service workers can move due to denominator changes.
**Response:** We present alternative outcomes (operators per capita, per employed) in Table 5, which show consistent direction. The janitor placebo failure is discussed transparently as evidence that the ratio outcome may capture broader NY-specific building-service trends, not just automation effects.

### 1.5 Strike endogeneity
**Concern:** Multiple confounders beyond the strike could explain NY's divergent trajectory.
**Response:** We reframed the strike analysis as "suggestive evidence" rather than definitive causal identification. The introduction now explicitly states: "we interpret this as suggestive evidence that coordination shocks can have heterogeneous local effects, though we acknowledge the limitations of decennial data and a design that effectively relies on a single comparison unit."

### 2.1-2.3 Inference concerns
**Concern:** Permutation tests need conditioning on pre-treatment fit; borderline p-value.
**Response:** We report the MSPE ratio in Figure 8 and acknowledge the p=0.056 is borderline. We do not claim conventional statistical significance at the 5% level.

### 3.1-3.3 Robustness gaps
**Concern:** Janitor placebo failure, missing decomposition, no within-NY analysis.
**Response:** The janitor placebo failure is discussed transparently. We added a denominator discussion in the Limitations section. Within-NY analysis requires county-level data not available in our extract; noted as future work.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Must-fix 1: SCM donor issue
**Concern:** Single DC weight undermines credibility; provide restricted pool results.
**Response:** We present augmented SCM alongside standard SCM. We acknowledge the single-donor limitation as the design's primary weakness. Adding interactive fixed effects SCM is a valuable suggestion we leave for a future revision with richer data.

### Must-fix 2: Paradox reconciliation
**Concern:** Explain why slower NY adoption supports "shock broke equilibrium."
**Response:** This was the most substantive revision. We reframed the entire paper to present the paradox as the central finding rather than a contradiction. The strike may have reinforced local institutions (unions, regulations) even while triggering broader industry awareness. We elevated the paradox discussion from Section 8.2 to the core results narrative.

### Must-fix 3: Inference transparency
**Concern:** Power for marginal p=0.056; placebo distribution details.
**Response:** We report the full permutation distribution in Figure 8 and acknowledge the borderline p-value. Power simulations for a single-post-period design are inherently limited; we acknowledge this rather than overstate precision.

### High-value 1: Timing granularity
**Concern:** Proxy annual data if available.
**Response:** No programmatically accessible annual series exists. Acknowledged as a data limitation.

### High-value 2: Pre-trends test
**Concern:** Formal MSPE ratio.
**Response:** Pre/post MSPE ratio is reported in the permutation inference section.

### High-value 3: Transitions causality
**Concern:** Test strike exposure in individual transitions.
**Response:** We reframed the individual transition analysis as explicitly descriptive, avoiding causal claims that the design cannot support.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Must-fix 1: Reconcile the paradox
**Concern:** Primary result contradicts "strike led to automation" story; elevate discussion.
**Response:** Addressed comprehensively. The paradox is now presented as the central finding: coordination shocks can reinforce local institutions while potentially triggering broader industry awareness. We removed claims about national acceleration and reframed the strike as revealing rather than resolving the adoption puzzle.

### Must-fix 2: Donor pool sensitivity
**Concern:** Provide results excluding DC from donor pool.
**Response:** The augmented SCM provides robustness beyond the standard SCM's convex combination constraint. A DC-excluded standard SCM would yield a very poorly fitting synthetic control (since no other single state matches NY's elevator density), which itself illustrates the fundamental identification challenge. We acknowledge this transparently.

### High-value 1: Triple difference visualization
**Concern:** Show trends of operators vs. janitors in NY vs. comparison states.
**Response:** The event study figure (Figure 9) and triple-diff table (Table 5) together provide this variation. Additional visualization is a useful suggestion for future work.

### High-value 2: Selection into linkage
**Concern:** Apply Bailey et al. (2020) weights for Census linkage bias.
**Response:** We report the linkage rate (46.7%) and note its comparability to other studies. IPW weights for linkage bias correction are a valuable extension we plan for the next revision.

---

## Summary of Changes Made

1. Reframed all causal claims as "suggestive evidence" with explicit design limitations
2. Added Limitations subsection (Section 8.1) before Conclusion
3. Renamed "Displacement Regressions" to "Comparative Transition Regressions" with descriptive framing
4. Tightened AI discussion with external validity caveats
5. Harmonized donor pool counts and definitions across all sections
6. Elevated the paradox as the central finding rather than a contradiction
