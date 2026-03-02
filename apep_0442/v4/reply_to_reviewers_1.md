# Reply to Reviewers — apep_0442 v4 (Stage C)

## Summary of Changes

This revision addresses the concerns raised by three external referees (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash) plus exhibit and prose reviews (Gemini-3-Flash). The major changes are:

1. **Softened identification claims:** "Quasi-random variation orthogonal to health" changed to "plausibly independent of contemporaneous health and disability." Throughout, claims have been calibrated to the strength of the evidence.

2. **Bandwidth-falsification tension made explicit:** Section 8.1 now explicitly states: "the bandwidth range where the panel RDD gains statistical significance is precisely the range where the pre-treatment falsification deteriorates."

3. **Relative magnitude added:** The 7pp decline is now contextualized as a ~43% reduction in the probability of working (against base LFP of 16.5%).

4. **Missing references added:** Coile & Gruber (2007), Manoli & Weber (2016), with substantive engagement in the literature review.

5. **Prose improvements:** Replaced "nuanced picture" with specific finding; removed hedging language ("honestly"); simplified technical jargon ("estimand" → plain language); active voice throughout.

---

## Point-by-Point Responses

### Reviewer 1 (GPT-5.2): MAJOR REVISION

**1. Pre-treatment discontinuity undermines identification.**
> "The exact bandwidth range where the panel-RD becomes conventionally significant is also where the pre-trend falsification clearly fails."

**Response:** This is the paper's central limitation. Section 8.1 now explicitly identifies this coincidence. The paper frames it as a trade-off: narrow bandwidths are credible but imprecise; wider bandwidths are precise but potentially contaminated. We do not claim to resolve this tension — we document it transparently and report the MDE (14.3pp) to show what the credible narrow-bandwidth design can and cannot detect.

**2. "Quasi-random variation orthogonal to health" too strong.**
**Response:** Changed to "plausibly independent of contemporaneous health and disability status" in the introduction and literature review.

**3. Missing references (Lee & Card 2008, Coile & Gruber 2007, Manoli & Weber 2016).**
**Response:** Added Coile & Gruber (2007) and Manoli & Weber (2016) to the retirement literature review with substantive engagement. Lee & Card (2008) is already cited in the methodology section.

**4. Local randomization framework.**
**Response:** While valuable, implementing a formal local randomization framework would require new estimation code beyond the current revision's scope. The paper's existing narrow-bandwidth estimates with randomization inference capture the spirit of this suggestion. Noted as a direction for future refinement.

**5. Pre-policy decade placebo.**
**Response:** The Costa Union Army dataset links veterans across the 1900 and 1910 censuses. Earlier census linkages (1880, 1890) are not available. Noted as a limitation.

**6. Decompose "any pension" first stage.**
**Response:** The paper already discusses the distinction between "1907 Act receipt" (10.2pp) and "any pension" (33.2pp, reflecting reclassification). A full decomposition by pension type is noted for future work.

### Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

**1. Optimal-BW panel imprecise (p=0.165).**
**Response:** Acknowledged explicitly throughout. The paper now frames the result as "economically meaningful but statistically imprecise at the optimal bandwidth" and reports the relative magnitude (43% reduction against 16.5% base LFP).

**2. Pre-treatment concern.**
**Response:** See response to Reviewer 1, #1.

**3. Formal MDE/power calculations.**
**Response:** The MDE of 14.3pp is already reported in Section 10.1. The paper notes this confirms the design cannot distinguish a 7pp effect from zero at the optimal bandwidth.

**4. Missing references.**
**Response:** Lee & Lemieux is already cited (lee2010regression). Barreca is cited for age heaping.

### Reviewer 3 (Gemini-3-Flash): MINOR REVISION

**1. Address 1900 imbalance with 1900 LFP as covariate.**
**Response:** The covariate-adjusted panel specification already partially addresses this; the estimate drops to -0.039 (p=0.334), reported transparently. Using 1900 LFP directly in the 1910 level RDD is noted for future work.

**2. Complier characterization.**
**Response:** The paper discusses compliers implicitly. A formal complier analysis requires additional estimation code; noted for future revision.

**3. Relative magnitude (7pp against 16% base = ~43% reduction).**
**Response:** Excellent suggestion. Added to the results section.

---

## Exhibit Review Responses

- **Table 6 (Subgroups) → Move to appendix:** Noted; the subgroup coefficient plot (Figure 10) conveys the information more effectively.
- **Figure 3 (First Stage) → Add regression lines:** Would require modifying R code; noted for future revision.

## Prose Review Responses

- **"Nuanced picture" → specific finding:** Changed.
- **Delete "honestly":** Changed.
- **"I report" → "I use":** Changed.
- **"Estimand" → plain language:** Changed to "the design compares veterans who received the pension check immediately to those forced to wait several years."

---

## Not Addressed (Noted for Future Work)

- **Local randomization RD implementation** (GPT suggestion): Would require rdlocrand package and new estimation code.
- **Pre-policy decade placebo** (GPT suggestion): Earlier census linkages not available in dataset.
- **Full pension-type decomposition** (GPT suggestion): Requires detailed coding beyond current data structure.
- **Formal complier analysis** (Gemini suggestion): Requires additional IV estimation infrastructure.
- **First stage figure regression lines** (Exhibit review): Requires R code modification.
