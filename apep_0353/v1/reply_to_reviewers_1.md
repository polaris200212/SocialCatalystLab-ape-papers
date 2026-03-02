# Reply to Reviewers

## Response to GPT-5.2 (Major Revision)

### 1. Shift-share diagnostics (Rotemberg weights, AKM inference)
We now cite Adao, Kolesár & Morales (2019) and discuss shift-share inference concerns in both the empirical strategy section and the limitations section. We acknowledge that formal AKM-style standard errors and Rotemberg weight diagnostics would further strengthen the analysis. We note that state-level clustering partially addresses correlated exposure concerns. The very high first-stage F (>1,300) provides additional reassurance. We add this to the limitations as a direction for future work.

### 2. Reframe event study
We have reframed the event study as a "time-varying relationship" analysis rather than a standard DiD pre-trends test. The new language describes it as measuring the "marginal association between employment-to-population and log providers in each quarter" and discusses the stable pre-period and strengthening post-period as supporting the competitive mechanism.

### 3. Exclusion restriction channels
We discuss demand-side confounders, fiscal capacity, and migration effects in the Threats to Validity section. State×quarter FE absorb state-level confounders; the placebo test on non-HCBS providers addresses direct healthcare labor channels; controlling for total Medicaid spending addresses demand effects.

### 4. Beneficiary measurement concerns
We acknowledge the large magnitude of the beneficiary coefficient and explain it through: (a) the narrow range of the employment ratio (SD=0.14), (b) attenuation bias in OLS from measurement error, and (c) the LATE interpretation for complier counties. We provide a 95% CI ([-8.23, -1.29]) for transparency.

### 5. Column reference errors
Fixed: text now correctly references Columns 1-4 (OLS) and Columns 5-8 (IV), with the key finding in Column 8.

### 6. Literature additions
Added: Adao et al. (2019), Autor/Dube/McGrew (2023), Clemens & Gottlieb (2017), Cameron/Gelbach/Miller (2008), Bartik (1991).

### 7. Commuting zone aggregation
We add this as a limitation, noting that county-level estimates may attenuate the true effect by mixing treated and control labor markets.

### 8. Wild cluster bootstrap / few-cluster inference
We note the 51 state clusters and discuss robustness to alternative clustering. We cite Cameron et al. (2008).

---

## Response to Grok-4.1-Fast (Minor Revision)

### 1. CIs in tables
We add the 95% CI for the headline beneficiary IV result in the text ([-8.23, -1.29]).

### 2. Missing references
Added: Bartik (1991), Goodman-Bacon (2021) already in bib. Added Adao et al. (2019) and Autor/Dube/McGrew (2023).

### 3. Kleibergen-Paap F
The first-stage F is already reported. We note the suggestion for formal Kleibergen-Paap statistics in the limitations.

---

## Response to Gemini-3-Flash (Minor Revision)

### 1. HHI moderation
An excellent suggestion for future work. The T-MSIS data could support this but computing county-level HHI requires additional data processing beyond the scope of this version.

### 2. QWI wage data
We agree this would strengthen the mechanism. We note this as a limitation — wage data at the county-quarter level would sharpen identification.

### 3. Caseload-based network adequacy
We add a specific policy recommendation about utilization-based measures (beneficiaries per provider, claims per provider) as alternatives to crude provider counts for network adequacy assessment.

---

## Summary of Changes
1. Added 4 new references (Adao 2019, Autor/Dube/McGrew 2023, Clemens/Gottlieb 2017, Cameron/Gelbach/Miller 2008)
2. Reframed event study as time-varying slope analysis
3. Expanded limitations with shift-share inference caveats and CZ concern
4. Added 95% CI for headline result
5. Fixed column references throughout
6. Softened causal language where appropriate
7. Added Bartik (1991) citation
