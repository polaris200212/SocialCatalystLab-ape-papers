# Reply to Reviewers

## Referee 1 (GPT-5.2) — Major Revision

### 1.1 Postcode matching and measurement error
**Concern:** Postcode-level matching introduces non-classical measurement error; mismatch may generate artificial discontinuities.
**Response:** We added a new paragraph in Section 4.5 discussing postcode matching limitations, noting that mismatch attenuates RD estimates (consistent with the donut RDD finding larger effects), and that the owner-occupied placebo provides reassurance against spatial confounders. We acknowledge this as a lower-bound interpretation. UPRN matching is noted as a priority for future work.

### 1.2 Decomposition not identified via cross-cutoff comparison
**Concern:** Different cutoffs serve different populations; D/E contaminated by density test failure.
**Response:** We now use the C/D boundary alone as the preferred informational benchmark (density test passes, p=0.220) and report the D/E+C/D average as a robustness check. We added explicit caveats about the cross-cutoff assumption and reframed the within-cutoff tenure comparison as the primary identification strategy for the regulatory effect.

### 1.3 Crisis amplification not cleanly identified
**Concern:** Period-specific RD estimates may reflect compositional changes, not causal amplification.
**Response:** We acknowledge this limitation in the text. The tenure comparison (rentals vs. owners) within each period provides some protection against compositional confounders that affect all properties symmetrically.

### 1.4 Clustering/inference
**Concern:** Standard errors may be understated due to within-postcode correlation.
**Response:** We added discussion of this concern in Section 4.5, noting that postcode-level clustering is infeasible with the current sample structure but that the near-zero owner-occupied placebo provides reassurance.

### 1.5 Over-claiming on "information is near zero"
**Concern:** Cross-cutoff evidence does not prove labels have no informational value.
**Response:** We moderated language throughout: "near zero" → "small," added caveat that small discrete label effects do not preclude continuous score effects. The abstract and introduction now use more cautious framing.

---

## Referee 2 (Grok-4.1-Fast) — Major Revision

### 2.1 Postcode matching bias
**Response:** See 1.1 above.

### 2.2 D/E contamination in decomposition
**Response:** See 1.2 above. C/D-only benchmark now primary.

### 2.3 Pre-MEES anticipation
**Concern:** 16% pre-MEES E/F effect complicates regulatory story.
**Response:** Added new paragraph in Discussion addressing MEES anticipation (announced in 2015 Energy Act, widely publicized before April 2018 implementation). Noted that pre-MEES tenure-specific estimates are imprecise and neither confirm nor rule out anticipation.

### 2.4 Missing citations
**Concern:** Add Chegut et al. (2019), Bramley et al. (2022), Ganslmeier (2022).
**Response:** Noted for future revision; these would strengthen positioning.

---

## Referee 3 (Gemini-3-Flash) — Minor Revision

### 3.1 Refine decomposition benchmark
**Response:** See 1.2 above. C/D-only now primary benchmark.

### 3.2 Rental magnitude (34.2%)
**Concern:** Exceptionally large for a £3,500 investment.
**Response:** The welfare section already discusses this — the premium reflects the regulatory option value (lettability vs. unlettability), not just the remediation cost. A brief comparison to annual rent loss would strengthen this section in future revision.

### 3.3 Selection into rental sector
**Concern:** Tenure misreporting could contaminate placebo.
**Response:** Valid concern. Cross-validation with Land Registry corporate body flags noted as valuable future work.
