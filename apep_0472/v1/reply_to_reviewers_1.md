# Reply to Reviewers — apep_0472 v1

## GPT-5.2 (Major Revision)

### 1.1 Treatment definition too coarse (LA-level vs ward-level)
**Response:** We acknowledge this limitation but note that ward-level designation boundaries are not publicly available in machine-readable format for the 31 LAs. The LA-level ITT is conservative (attenuating toward zero), and the borough-wide subsample restriction provides a clean treatment definition. We have added discussion of this limitation and noted it as priority for future work with FOI-obtained boundary data.

### 1.2 TWFE contamination narrative inconsistent
**Response:** Fixed. Appendix C.3 now precisely explains that always-treated units' treatment indicator is collinear with unit FE and they do not directly identify β, but they influence time FE estimation and can enter Goodman-Bacon 2×2 comparisons implicitly. We note a formal Bacon decomposition is beyond scope.

### 1.3 C&S at LA-quarter vs LSOA-month
**Response:** Acknowledged as limitation. Running C&S at LSOA-month with 1.15M observations and 10 cohorts is computationally infeasible with the `did` package's current implementation. We validate the LA-quarter C&S against the LSOA-month TWFE and note the aggregation difference explicitly.

### 1.4 Parallel trends / short pre-periods
**Response:** Manchester/Luton have only 2 pre-treatment months in the quarterly aggregation. The event study pre-trend coefficients for early cohorts are admittedly thin. We discuss this limitation explicitly.

### 1.5 "Waterbed" not tested spatially
**Response:** Added explicit clarification that "waterbed effect" in this paper refers to categorical displacement (redistribution across offence types), not spatial displacement across LA boundaries. Future work with boundary data could implement buffer-zone designs.

### 2.1 Few treated clusters
**Response:** Wild cluster bootstrap p-value (0.641) and leave-one-out sensitivity analysis (coefficient ranges from -0.05 to -0.95 across 10 jackknife iterations) are now reported.

### 2.2 Multiple testing
**Response:** Added Holm family-wise error rate corrections. Public order and ASB remain significant after correction; vehicle crime becomes borderline. Discussion added to Section 5.3.

### 2.3 Poisson/IHS robustness
**Response:** Noted as valuable extension. The balanced panel with zeros is amenable to Poisson quasi-MLE; this is left for future work.

### 2.4 C&S SE documentation
**Response:** C&S uses doubly robust estimation with bootstrap inference via the `did` package defaults (not-yet-treated controls, no anticipation). Added clarification in text.

---

## Grok-4.1-Fast (Minor Revision)

### Drop short-post switchers
**Response:** Leave-one-out analysis shows the TWFE estimate is stable when dropping any single LA. Birmingham's removal has the largest effect (coefficient shrinks from -0.82 to -0.05), consistent with its large size. Results are robust.

### Spatial spillovers
**Response:** Discussed qualitatively (Section 6.2). Formal spatial test requires designation boundary data not currently available. Noted as top priority for future work.

### Weapons placebo
**Response:** Added discussion noting that weapons findings may reflect coincident policing intensity changes. Region×Month FE specification absorbs regional policing trends and yields insignificant aggregate coefficient.

### C&S at LSOA-month; Bacon decomposition
**Response:** Computationally infeasible at LSOA-month scale. Bacon decomposition noted as valuable but beyond scope given the Goodman-Bacon package's computational requirements.

---

## Gemini-3-Flash (Minor Revision)

### Weapons placebo
**Response:** Addressed with discussion of policing intensity and Region×Month FE robustness (see above).

### Spatial spillover test
**Response:** Noted as future work requiring boundary data (see above).

### Dosage/enforcement proxy
**Response:** Licensing fees and enforcement intensity data are not systematically available across LAs. Noted as valuable extension.

### Victimization data
**Response:** CSEW operates at higher geographic aggregation (Police Force Area) and limited annual samples, making LA-level DiD infeasible. Noted as triangulation opportunity for future work.
