# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### Concern 1: Emergency vs. permanent parity distinction
> "May not generate meaningful change relative to COVID-era baseline"

**Response:** We added a new paragraph in Section 2.2 explicitly distinguishing emergency telehealth authorizations (March-April 2020, temporary, executive orders) from permanent payment parity laws (statutory, no sunset, rate equality mandated). We discuss whether permanent laws created additional incentives beyond the emergency regime and note that the event-study design can address this question by examining outcomes at the permanent law effective date.

### Concern 2: Pre-trend testing
> "Singular covariance matrix prevents joint test"

**Response:** The Callaway-Sant'Anna event-study estimates include simultaneous confidence bands (plotted in Figures 3-4) that provide a visual and statistical assessment of pre-trends. All eight pre-treatment quarterly estimates are individually indistinguishable from zero. We acknowledge this limitation in the text.

### Concern 3: CMS suppression bias
> "Small-volume entrants may be mechanically hidden"

**Response:** We added a paragraph in the Data section (Section 4.5) discussing the CMS suppression threshold (<12 claims) and explaining that: (a) state-level aggregates minimize suppression impact; (b) the null extends to claims and spending outcomes that are less sensitive to small-cell suppression; and (c) suppression affects a negligible share of total spending.

### Concern 4: 95% confidence intervals
> "Main tables lack 95% CIs"

**Response:** We added a 95% CI column to Table 3 (Callaway-Sant'Anna ATT estimates). The CIs confirm that effects larger than approximately ±10% can be ruled out for all outcomes.

### Concern 5: Treatment heterogeneity
> "Audio-only vs. video-only, FFS vs. MCO scope not characterized"

**Response:** We acknowledge this as a valuable direction for future research. Coding treatment heterogeneity across all 26 states requires systematic legal analysis beyond the scope of this initial study. We discuss this in the Limitations section.

### Concern 6: Missing significance notation
> "Stars defined but never appear in tables"

**Response:** We added explicit notes to Tables 2 and 3 stating that no coefficient reaches statistical significance at the p < 0.10 level.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Missing recent literature
> "BDO 2023, Mulcahy 2022, Cunningham 2020 not cited"

**Response:** We note these suggestions for a future revision. The current bibliography covers the core methodological and policy literatures adequately for the primary contribution.

### Concern 2: 95% CIs in Table 3
> "CS ATT table lacks CI columns despite reporting in text"

**Response:** Fixed. Added 95% CI column to Table 3.

### Concern 3: Provider type heterogeneity
> "Individual vs. organizational NPIs not split"

**Response:** This is a valuable suggestion. The NPPES taxonomy could distinguish organizational (Type 2) from individual (Type 1) NPIs, which may respond differently to parity. We note this as an important extension.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Concern 1: Treatment heterogeneity by scope
> "Audio-only vs. video-only not addressed"

**Response:** We discuss this limitation in the text. Policy scope heterogeneity is an important dimension for future work.

### Concern 2: Modality shift unmeasurable
> "Cannot observe telehealth vs. in-person share"

**Response:** Already acknowledged as a key limitation. The T-MSIS aggregate file lacks telehealth modifiers. We note that our focus is on extensive margin (supply) rather than intensive margin (modality composition).

### Concern 3: Geographic reallocation
> "State-level null may mask within-state reallocation"

**Response:** An interesting suggestion. NPPES ZIP codes could support sub-state analysis in future work. The state-quarter panel is the appropriate unit for evaluating state-level policy effects.

---

## Exhibit Review Response

- **Figure 3 annotation:** Acknowledged; ATT could be annotated in the figure. Minor visual improvement for future revision.
- **Figures 4, 6, 7 to appendix:** Acknowledged; these are supporting exhibits. Maintained in main text for completeness in this version.
- **Figure 8 promotion:** Acknowledged; the tile map could enhance the institutional background section.

## Prose Review Response

- **Roadmap paragraph:** REMOVED. Section headers are sufficient.
- **Abstract closing:** STRENGTHENED. Now emphasizes structural barriers rather than generic insufficiency.
- **Active voice:** Improved in revised sections.
- **Result sentences:** Strengthened with interpretive language in the TWFE/CS reconciliation paragraph.
