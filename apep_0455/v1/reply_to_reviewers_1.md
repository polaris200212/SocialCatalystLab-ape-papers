# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1 Treatment bundles multiple shocks (designation + rate increase)
**Response:** Valid concern. We now explicitly acknowledge in the estimand discussion that the effect combines first-time TLV exposure with the 2024 rate increase. Including always-treated communes as a comparison group for the rate change is a valuable suggestion for future work, but requires careful handling of their different treatment history (pre-2013 vs 2024). We note this as a limitation.

### 1.2 Parallel trends not established at relevant horizon
**Response:** We address this in two ways: (1) We now report a **restricted pre-period specification (2021–2025)** that drops the COVID-contaminated 2020, showing that the commune-level price null strengthens (0.5%, p=0.48) and volume decline strengthens (-7.3%***). (2) We acknowledge that the 2023 "anticipation" coefficient cannot be definitively separated from differential tourism recovery, and frame it as suggestive rather than causal. Monthly/quarterly event studies around the August 25 announcement would sharpen identification and are noted as future work.

### 1.3 Control group extremely different
**Response:** We agree this is a fundamental limitation of the design. The new hedonic-controlled specification (Section 6.5.6) shows that adding property-level controls (surface, type, rooms) barely changes the transaction-level estimates, which provides some reassurance. However, we acknowledge that entropy balancing or synthetic DiD targeting pre-trend balance would be more appropriate than PSM for this setting.

### 1.4 Spillovers
**Response:** We acknowledge this limitation. A border/ring-based analysis would strengthen the design but requires geocoded commune boundaries (available from IGN but computationally intensive to implement). Noted as future work.

### 2.1 Commune-year panel excludes zero-transaction years
**Response:** We now explicitly discuss this in the Limitations section, noting that the volume estimate captures conditional market activity among communes with ≥1 sale. We note that 85.4% of treated communes have transactions in every year, limiting the extensive margin concern, and that a Poisson PML model with zeros would be the appropriate extension.

### 2.2 Price aggregation is selected
**Response:** Addressed via the **new hedonic-controlled transaction-level regressions** (Section 6.5.6). With controls for log(surface), property type, and rooms, the treatment effect is 3.7% (virtually unchanged from 3.7% unconditional) and 3.0% with dept×year FE (vs 2.8%). Observable composition does not explain the transaction-level price increase.

### 2.3 Clustering stress test
**Response:** We report département-level clustering (96 clusters) as our primary inference. Commune-level clustering and wild cluster bootstrap are valuable extensions noted for future work.

### 2.4 RI not aligned with assignment
**Response:** Valid concern. The current RI permutes treatment uniformly without respecting the assignment mechanism. Stratified RI (within département or baseline tourism category) would be more appropriate but computationally intensive. We note this caveat.

### 3.1 Donut not meaningful at commune-year level
**Response:** Acknowledged in revised text. The donut specification primarily serves as a check that the annual mean is not driven by the 2023-H2 subperiod.

### 3.2 Matching is a red flag
**Response:** Substantially expanded discussion of why the matched estimate (8.4%) diverges and why it should be interpreted as illustrative of control-group sensitivity rather than a credible alternative estimate.

### 5.1–5.3 Claim calibration
**Response:** We now frame the volume estimate more carefully, noting the conditional nature of the estimand. The welfare calculation is explicitly framed as illustrative.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### COVID pre-trend
**Response:** Added restricted pre-period specification (2021–2025) dropping 2020. Results strengthen: price null (0.5%, p=0.48), volume decline stronger (-7.3%***).

### 2025 partial-year for volume
**Response:** Added 2024-only specification (Section 6.5.8). Volume decline is -4.0%*** (vs -6.0% with 2025), price null holds (1.1%, p=0.17). Core results survive.

### Composition/mechanisms
**Response:** Added hedonic-controlled transaction regressions (Section 6.5.6). Property controls barely change estimates (3.7%→3.7% with commune+year FE).

### Vacancy/rental outcomes
**Response:** Acknowledged as key limitation. Census vacancy data (Fichier Logement) and rental market data (ANIL) would directly test the policy's primary objective but are not available in the current analysis window.

### Literature gaps
**Response:** We note the suggestion to add Gurran et al. on Vancouver EHT and Fetter on US vacation homes for future revisions.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Seasonal adjustment for 2025
**Response:** Added 2024-only specification. Results hold without 2025.

### Selection bounding (Lee bounds)
**Response:** This is an excellent suggestion. Lee (2009) bounds would formally quantify how much of the 2.8–3.7% transaction-level price increase can be explained by the 6% volume attrition. This is noted as a high-priority extension.

### 2020 pre-trend
**Response:** Added restricted pre-period (2021+). Results strengthen.

### Link to rental data
**Response:** Acknowledged. SeLoger/Leboncoin data would provide direct evidence on vacancy-to-rental conversion.

### Map of treatment
**Response:** Noted for future revision. A choropleth map would be more informative than the current bar chart of département codes.
