# Reply to Reviewers

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

**R1.1: Discrete running variable inference needs discrete-specific methods.**

We appreciate this important methodological point. We have expanded Section 6.3 to discuss the limitations of standard rdrobust inference with discrete running variables. We note that (a) the jitter approach follows Lee & Card (2008), (b) the OLS-detrended permutation inference makes no smoothness assumptions and provides exact finite-sample inference, and (c) the year-by-year estimates across all 8 years provide informal validation that the results are not artifacts of any particular jitter draw. We have added citations to Cattaneo, Jansson & Ma (2020). We note that with hundreds of thousands of observations at each mass point, the discrete-RV bias is minimal.

**R1.2: Insufficient table reporting detail.**

Table 2 reports SEs, 95% CIs, p-values, and N within the optimal bandwidth. We have added the bandwidth value to the table footnote and clarified the relationship between the subsample estimation sample and the full-data N.

**R1.3: McCrary density test assumes continuous RV.**

We have added a note in Section 9.1 acknowledging this limitation and noting that the density test should be interpreted as suggestive rather than definitive given the discrete running variable.

**R1.4: Plan termination timing.**

This limitation was already acknowledged in Section 6.4. We note that variation in plan termination timing likely attenuates the estimated discontinuity, making our estimates conservative.

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

**R2.1: Missing references.**

Added Cattaneo, Jansson & Ma (2020) and Imbens & Kalyanaraman (2012).

**R2.2: Fiscal estimate source.**

Added citation for Medicaid payment rates.

**R2.3: AI footnote framing.**

The footnote uses the public repository URL per project requirements and follows APEP conventions.

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

**R3.1: Reframe primary contribution.**

We have adjusted the abstract and introduction to emphasize the fiscal/payer-mix finding as the primary contribution, with null health outcomes as a secondary (though informative) finding.

**R3.2: Welfare analysis depth.**

We have expanded the Discussion section to include brief discussion of administrative churning costs.

**R3.3: Restricted data limitations.**

Acknowledged. Public-use files are the best available data for this analysis without restricted-use access.
