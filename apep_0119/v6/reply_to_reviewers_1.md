# Reply to Reviewers: apep_0119 v6

## Parent: apep_0119 (v5)
## Revision Type: Shleifer-Style Prose Overhaul + Targeted Empirical Additions

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern 1: Inference for CS-DiD estimator lacks conservative cluster-robust tests
**Response:** We acknowledge that the v5 paper applied wild cluster bootstrap only to TWFE. The CS-DiD estimator reports analytical clustered SEs, which remain our preferred inference. We now more explicitly discuss the tension between TWFE bootstrap p-values (0.14) and CS-DiD analytical p-values (<0.01), noting that this reflects TWFE contamination bias rather than CS-DiD fragility. The Honest DiD sensitivity analysis (Rambachan & Roth 2023) provides the most informative robustness check for the parallel trends assumption.

### Concern 2: Long-run estimates fragile to parallel trends violations
**Response:** We agree and have rewritten the Results and Discussion sections to clearly delineate short-to-medium run estimates (0-8 years, robust) from long-run estimates (10-15 years, fragile). The paper now explicitly states that long-horizon magnitudes should be interpreted cautiously.

### Concern 3: Convert Introduction bullet-list contributions to prose
**Response:** **Fully addressed.** The Introduction has been completely rewritten as a 5-page Shleifer-style narrative. All enumerated contributions are now woven into flowing prose. The `\textit{First}`, `\textit{Second}`, `\textit{Third}` structure has been eliminated.

### Concern 4: Policy bundling / concurrent policies
**Response:** We now frame the estimate as the effect of the "EERS policy package" rather than claiming attribution to EERS alone. Controls for RPS and decoupling are retained. We added a commercial sector analysis (CS-DiD on commercial electricity, ATT = -6.5%, p<0.01) which corroborates that the effect extends beyond residential.

### Concern 5: Expand placebo and falsification exercises
**Response:** **Substantially addressed.** We now report three new analyses:
1. **Industrial placebo** (CS-DiD ATT = -19.3%, SE = 0.038) — discussed honestly as complicating clean falsification
2. **Commercial sector** (CS-DiD ATT = -6.5%, SE = 0.017) — corroborates main finding
3. **COVID robustness** (excluding 2020-2022: ATT = -4.2%, identical to main) — confirms pandemic does not drive results

### Concern 6: Add Abadie et al. (2010), Conley & Taber (2011), Imbens & Lemieux (2008)
**Response:** Added Abadie, Diamond & Hainmueller (2010) and Metcalf & Hassett (1999). Conley & Taber (2011) was already cited. Imbens & Lemieux (2008) omitted as no RDD is used.

### Concern 7: Report effective N per event-time
**Response:** Partially addressed. The event study discussion now notes that long-run estimates rely on a subset of early cohorts. Full effective-N annotation deferred to future revision.

---

## Reviewer 2 (Gemini-3-Flash): CONDITIONAL ACCEPT

### Concern 1: Commercial sector analysis
**Response:** **Fully addressed.** Added CS-DiD on commercial electricity (SEDS ESCCB). ATT = -6.5% (p<0.01), reported in the Placebo and Falsification subsection.

### Concern 2: COVID robustness check
**Response:** **Fully addressed.** Excluding 2020-2022 yields ATT = -4.2% (SE = 0.010), identical to the main estimate. Reported in Robustness section.

### Concern 3: Add Metcalf & Hassett (1999) for engineering-econometric gap
**Response:** **Fully addressed.** Added to references and cited in the Introduction when discussing the engineering-econometric gap.

---

## Reviewer 3 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Table industrial placebo results
**Response:** **Fully addressed.** Industrial placebo is now tabulated in the robustness summary and discussed in Section 7.3 (Placebo and Falsification). Result: ATT = -19.3%, which complicates a clean null falsification but is discussed honestly.

### Concern 2: Prose-ify Introduction contributions
**Response:** **Fully addressed.** Complete Shleifer-style rewrite. No enumerated lists remain in the Introduction.

### Concern 3: Add Mildenberger et al. (2022) as closest predecessor
**Response:** **Fully addressed.** Added to references and cited prominently in the Introduction as the closest prior study, noting it used biased TWFE.

### Concern 4: Extend mechanisms / dose-response
**Response:** Deferred. The Discussion section now explicitly identifies dose-response analysis using EIA Form 861 as a priority for future work.

### Concern 5: Long-run fragility acknowledgment
**Response:** **Addressed.** The Discussion now clearly separates robust short-run claims from fragile long-run estimates.

---

## Additional Changes (Not Reviewer-Driven)

### Structural Overhaul
- Flattened from 10 to 9 sections
- Merged Heterogeneity into Results
- Consolidated Robustness from 9 subsections to 3
- Eliminated all enumerated lists (predictions, specifications converted to prose)
- Removed roadmap paragraph from Introduction

### Prose Quality
- Active voice throughout
- Eliminated throat-clearing phrases
- Results contextualized before citing table/figure numbers
- Varied sentence rhythm
- Conclusion reframed with forward-looking research agenda

### New References
- Abadie, Diamond & Hainmueller (2010)
- Metcalf & Hassett (1999)
- Mildenberger et al. (2022)
