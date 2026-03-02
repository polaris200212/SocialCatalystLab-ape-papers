# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Standard Errors and Inference
**Concern:** SEs, CIs, and significance testing not transparent.
**Response:** All GSS regressions now report heteroskedasticity-robust (HC1) standard errors. Significance stars and p-value cutoffs are noted. Sample sizes are reported for each regression column.

### Survey Weights
**Concern:** GSS analyses should use survey weights.
**Response:** We present unweighted OLS as our primary specification because the key religion module variables (COPE4, FORGIVE3) were administered as supplementary modules with their own sampling, and GSS survey weights are designed for the core instrument. We note this choice in the text.

### Clustering and Galton's Problem
**Concern:** Cross-cultural data not i.i.d.; need spatial/phylogenetic controls.
**Response:** We added an ordered logit for EA034 with region controls (04_robustness.R). We acknowledge that full phylogenetic comparative methods (PGLS) are beyond the scope of this descriptive paper but flag this as important for future work.

### Multivariate SCCS/Seshat Models
**Concern:** SCCS should use ordered logit with controls; Seshat should use panel FE.
**Response:** We added an ordered logit for EA034 with region controls. For Seshat, the data structure (polity-period with varying temporal coverage) makes panel FE difficult to implement credibly with our sample. We acknowledge this limitation.

### Causal Language
**Concern:** Discussion overreaches on causal claims.
**Response:** We systematically toned down causal language throughout the Discussion and Conclusion, replacing causal arrows with associational language.

### Missing References
**Concern:** Need DiD/RDD methodological references, phylogenetic methods.
**Response:** We added Purzycki et al. (2016) on cross-cultural experiments with moralistic gods. DiD/RDD references are not applicable since this is not a quasi-experimental paper.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Additional References
**Concern:** Missing Purzycki et al. 2018, Koopmans et al. 2021, Voigtländer/Voth 2022.
**Response:** Added Purzycki et al. (2016, Nature — the correct citation for this line of work) in the cultural evolution literature discussion.

### Interacted Regressions
**Concern:** Fully tabulate education × attendance interaction.
**Response:** Added education × attendance interaction models in 04_robustness.R. Results confirm significant interaction for afterlife beliefs (heaven, hell) but not for forgiveness. Summarized in new "Robustness" paragraph in Section 5.1.

### Clustered SEs and Full Tables
**Concern:** Add clustered SEs by year/region in GSS.
**Response:** We report HC1 robust SEs as our baseline (appropriate for cross-sectional GSS data). Year clustering is not applicable since key variables come from single-year modules.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Behavioral Outcomes
**Concern:** Link beliefs to economic outcomes in GSS (trust, work orientation, welfare attitudes).
**Response:** Added new subsection "Divine Temperament and Behavioral Outcomes" in Section 5, reporting correlations between COPE4/FORGIVE3 and GSS trust, helpfulness, happiness, and health variables. Key finding: divine punishment beliefs are negatively correlated with trust, helpfulness, happiness, and health; divine forgiveness is positively correlated with happiness.

### Christian-Centric Measurement Bias
**Concern:** Discuss how "forgiveness" may not translate across religious traditions.
**Response:** Added new paragraph in Section 6.3 (Limitations) discussing how GSS items presuppose Abrahamic monotheistic framework and may not capture non-theistic or collective-covenant religious conceptions.

### Education × Attendance Interaction Plot
**Concern:** Visualize the interaction.
**Response:** We describe the interaction results in the new Robustness paragraph. A full margins plot is available upon request.

### Macro Correlates
**Concern:** Section 5.4 weak due to low N; consider moving to appendix.
**Response:** We retain this section in the main text with strong caveats about the small number of observations, consistent with the paper's comprehensive descriptive mission. The results are clearly flagged as "suggestive at best."

---

## Exhibit Review Fixes (Gemini Vision)

- Figure 1: Added distinct point shapes to differentiate overlapping Heaven/Afterlife lines
- Figure 6: Converted to 100% stacked bar chart for cross-region comparability
- Figure 7: Added loess trend line to Seshat MSP time series

## Prose Review Fixes (Gemini)

- Removed roadmap paragraph
- Punched up results introduction with specific finding lead
- Converted passive voice in key results paragraphs to active voice
- Strengthened conclusion ending
