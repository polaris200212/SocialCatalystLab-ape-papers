# Reply to Reviewers

## Reviewer 1 (GPT-5-mini): Major Revision

**Concern 1: CS-DiD vs TWFE discordance**
> The Callaway-Sant'Anna estimator shows pre-trend violations and a much larger ATT than the TWFE DDD.

We have substantially revised the CS-DiD discussion to honestly acknowledge the pre-trend violations visible at k=-5 and k=-4 (Section 6.3). We now explain that the CS estimator restricts to high-flood counties vs never-treated high-flood counties — a narrower sample where county-specific trends are more influential — and explicitly state that the CS-DiD results should be interpreted with "considerable caution" and that the large ATT (0.097) "likely reflects pre-existing differential trends rather than a causal effect." The TWFE event study, which shows clean pre-trends on the full DDD sample, provides the more credible dynamic evidence.

**Concern 2: Coarse flood exposure proxy**
> Pre-1992 FEMA disaster declarations at county level are a coarse proxy.

Acknowledged as a limitation (Section 8.4). We note that property-level data from First Street Foundation could improve the exposure measure. However, we test multiple definitions of flood exposure (binary high-flood, any-flood, continuous count) and find consistent null results, suggesting the null is robust to measurement choice. The NRDC grade intensity check (Table 3, Column 3) also shows no effect.

**Concern 3: Treatment compliance and enforcement**
> Legal adoption ≠ compliance ≠ market impact.

Added discussion in Section 8.4 noting that the treatment captures legal requirements, not actual compliance. The NRDC grade variation (A through D) partially captures enforcement quality, and the intensity specification (Table 3, Column 3) shows no dose-response relationship, consistent with either full pre-existing capitalization or weak implementation.

**Concern 4: Power analysis**
> Paper claims "precisely estimated null" but lacks formal power discussion.

Added Section 5.5 (Statistical Power) with formal MDE calculation: the design can detect effects as small as 0.8% (approximately $1,400 for the median home). The 95% CI rules out effects exceeding 2.5% ($4,375), well below effects found for earthquake disclosure (4-8%) and sea-level rise (7%).

**Concern 5: Wild bootstrap inference**
> With 49 clusters, consider wild cluster bootstrap.

With 49 state clusters, standard cluster-robust inference is reliable per the simulation evidence in Cameron, Gelbach & Miller (2008). Two-way clustering (state + year) yields virtually identical SEs (Table 3, Column 5), confirming robustness.

**Concern 6: Additional references**
> Integrate Goodman-Bacon, Sun & Abraham, Cameron et al.

Added citations for Cameron, Gelbach & Miller (2008) and Baldauf et al. (2020). Goodman-Bacon (2021), Callaway & Sant'Anna (2021), de Chaisemartin & D'Haultfœuille (2020), and Rambachan & Roth (2023) were already cited.

## Reviewer 2 (Grok-4.1-Fast): Minor Revision

**Concern 1: Map figure**
> A map showing geographic distribution would strengthen the paper.

We agree this would be a valuable addition but have prioritized the analytical improvements. The adoption timeline (Figure 5) and treatment table (Appendix Table) provide the geographic information.

**Concern 2: Heterogeneity by market tightness**
> Urban/rural and hot/cold market effects could mediate the seller's dilemma mechanism.

Good suggestion. We discuss the sorting and seller's dilemma mechanisms in Section 7.3 but acknowledge that county-level data limits our ability to test within-county sorting patterns. This is noted as a direction for future research.

## Reviewer 3 (Gemini-3-Flash): Minor Revision

**Concern 1: CS-DiD pre-trends**
> Figure 2 shows significant pre-treatment effects that contradict the text.

Fixed. The text now honestly describes the pre-trend violations and explicitly downgrades the CS-DiD results relative to the TWFE event study (Section 6.3).

**Concern 2: MDE and power**
> Need formal power analysis to validate "precisely estimated null" claim.

Added Section 5.5 with formal MDE calculation ($1,400 for median home at 80% power).

## Exhibit and Prose Improvements

Per exhibit review:
- Fixed Table 2 formatting (coefficients now properly aligned with column headers)
- Moved Table 4 (state adoption dates) to appendix
- Fixed "above-median" terminology throughout (was incorrectly "top tertile" in table notes)

Per prose review:
- Replaced opening throat-clearing with a concrete hook about the disclosure paradox
- Translated all key coefficients to dollar amounts for the median home
- Fixed "column-itis" in Results section to focus on findings rather than table structure
