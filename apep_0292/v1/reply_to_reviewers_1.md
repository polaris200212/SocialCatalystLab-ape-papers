# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### R1.1: Sharp vs. Fuzzy RDD / ITT vs LATE clarification
> "Clarify sharp vs. fuzzy RDD estimation and present both first-stage, reduced-form, and LATE results"

**Done.** Section 6.1 reports both ITT (sharp RDD: -0.040, SE = 0.059) and LATE (fuzzy RDD: -0.084, SE = 0.102). First-stage F-stat = 407.8. The distinction is explicit: ITT captures the policy effect of mandate eligibility; LATE captures the effect of actual filing for compliers.

### R1.2: Clustering / spatial correlation
> "Report robustness of main SEs to clustering at census tract, ZIP"

**Noted as future work.** Calonico bias-corrected robust SEs are valid under heteroskedasticity. Spatial clustering at tract/ZIP level is a valid extension for a future revision.

### R1.3: Power calculation clarity
> "Give SE, effective N, MDE formula"

**Done.** Section 6.2 reports: SE = 0.059, N_eff = 3,740, MDE = 0.059 x 2.8 = 0.165 log points (~16%). Compared to Eichholtz et al. (2010) premiums of 15-20%.

### R1.4: Multiple testing
> "Apply multiple-testing corrections for subgroups"

**Partially addressed.** Bonferroni correction is noted for borough subgroups. The heterogeneity analysis is presented as exploratory, not hypothesis-confirming.

### R1.5: Randomization inference / permutation tests
> "Provide permutation tests where you randomly shift the cutoff"

**Noted as future work.** Placebo cutoffs at 15K-45K (Table 6/Figure 4) serve a similar function. Formal permutation inference is a valuable extension.

### R1.6: Transaction price RDD
> "Use DOF Rolling Sales more fully"

**Acknowledged in limitations (Section 7.3).** Sparse transactions near the 25K threshold limit power. This is the primary avenue for future research.

### R1.7: Difference-in-discontinuities / panel RDD
> "Construct a panel of assessed values pre/post 2016"

**Noted as future work.** PLUTO releases are cross-sectional snapshots. Constructing a building-level panel across vintages requires matching by BBL across releases — a substantial data engineering task for future versions.

### R1.8: Missing DiD references
> "Callaway & Sant'Anna, Goodman-Bacon, Sun & Abraham"

**Not added.** These are DiD references; this paper uses RDD. The single mention of DiD is a brief suggestion for future LL97 research. Adding DiD methodology citations would be misleading about the paper's method.

### R1.9: Mechanisms tests
> "Test EUI-price correlation, variance, investment permits"

**Acknowledged in limitations.** DOB permit data returned 0 rows from the API for energy-related permits near the threshold. EUI-price interaction requires building-level merge. Both are noted as future work in Section 7.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### R2.1: Missing references
> "Eyer & Murphy (2023), Kahn et al. (2021), Hastings & Shapiro (2021)"

**Noted for future revision.** These are excellent suggestions. Kahn et al. (2021) on LL84/LL97 rent effects is particularly relevant.

### R2.2: Transaction data pooling
> "Pool with ACRIS deeds or Zillow RE sales for ~2x power"

**Noted as future work.** ACRIS deed data could increase sales coverage near the threshold.

### R2.3: 50K placebo
> "RDD at 50k sq ft isolates disclosure from LL87"

**Good suggestion, noted for future revision.** The 50K placebo would help distinguish LL84 from LL87 effects.

### R2.4: Mechanisms tests
> "RDD on post-2016 EUI/ENERGY STAR; permit text analysis; variance tests"

**Noted as future work.** These are valuable extensions beyond the current paper's scope.

---

## Reviewer 3 (Gemini-3-Flash): CONDITIONALLY ACCEPT

### R3.1: Additional literature
> "Houde (2016) on bunched energy labels; Myers (2019) on home buyer heating costs"

**Noted for future revision.** Both would strengthen the information revelation discussion.

### R3.2: Sales data visual
> "A plot of sale prices similar to Figure 2 in the appendix"

**Noted for future revision.** Visual evidence from transactions, even if underpowered, would provide useful reassurance.

### R3.3: EUI convergence check
> "Check whether EUI improved above threshold post-2016"

**Noted for future revision.** This is an important mechanism test that would distinguish "markets already informed" from "ineffective policy."

### R3.4: Heterogeneity by market tightness
> "Does the null hold during high vs. low vacancy?"

**Noted for future revision.** Vacancy rate interaction is an interesting moderator.
