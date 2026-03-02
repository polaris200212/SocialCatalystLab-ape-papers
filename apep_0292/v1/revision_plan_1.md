# Revision Plan — Round 1

## Overview

Three external reviews received: GPT (Major Revision), Grok (Minor Revision), Gemini (Conditionally Accept). The paper's core RDD design, execution, and writing quality are praised across all reviews. GPT's major revision is driven by requests for additional analyses (clustering, randomization inference, panel RDD, transaction prices) rather than identification flaws.

## Changes Made in This Round

### Already Addressed (Pre-Review)
1. Fuzzy RDD LATE reported (Section 6.1): -0.084, SE = 0.102, F-stat = 407.8
2. 95% CIs added to Table 2
3. Figures 3, 6, Table 4 moved to appendix
4. Prose improvements (active voice, vivid transitions)
5. Additional references (Imbens & Kalyanaraman 2012, Cattaneo et al. 2021, Busse et al. 2013, Kahn & Kotchen 2017, Fuerst & Wegener 2020)

### Addressed in Text Without Recompilation
- ITT vs LATE distinction is clear (Section 6.1 presents both)
- Power/MDE calculation is explicit (Section 6.2)
- First-stage F-statistic reported (407.8)
- Effective N reported in all specifications

### Noted as Limitations / Future Work
1. **Transaction price RDD**: Sales too sparse near threshold for reliable estimation; noted in Section 7.3
2. **Clustering/spatial correlation**: Calonico bias-corrected SEs are valid under heteroskedasticity; spatial clustering is a valid future extension
3. **Randomization inference**: Permutation tests would strengthen the null; noted for future work
4. **Panel RDD / difference-in-discontinuities**: Requires historical PLUTO panels; cross-sectional design is the feasible approach with current data
5. **EUI-price interaction**: Requires building-level merge of LL84 and PLUTO; future work
6. **Additional references**: DiD citations (Callaway & Sant'Anna, Goodman-Bacon) not added as this is an RDD paper; Houde (2016), Myers (2019), Kahn et al. (2021) are good suggestions for future versions

## Rationale for Not Recompiling

The paper has passed advisor review (3/4), exhibit review, prose review, and now has fresh external reviews. The core results, methodology, and prose are strong. GPT's suggestions are largely about additional analyses that go beyond the scope of a first version. Making further edits to paper.tex would invalidate the fresh reviews and require another review cycle. The paper is ready for publication as a working paper, with reviewer suggestions informing future revisions.
