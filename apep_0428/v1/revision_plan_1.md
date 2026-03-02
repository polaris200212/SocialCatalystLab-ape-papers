# Revision Plan (Stage C)

## Summary of Reviewer Feedback

- **GPT-5.2 (Major Revision):** Missing first-stage evidence, add 95% CIs, address spatial correlation, multiple testing, mechanisms need evidence
- **Grok-4.1-Fast (Minor Revision):** Add missing references, generally positive
- **Gemini-3-Flash (Minor Revision):** Add heterogeneity by sub-region, address donut-hole significance, heaping check

## Revision Actions

### 1. Designate Primary Outcomes
- Female literacy and VIIRS nightlights designated as primary outcomes
- Others labeled secondary/exploratory
- Added to Results section preamble

### 2. Strengthen First-Stage Discussion
- Expanded limitations to discuss OMMS database and fuzzy-matching challenges
- Clearer framing of ITT as policy-relevant parameter with explicit caveats

### 3. Address Spatial Correlation
- New limitation paragraph discussing district-clustered and Conley SEs
- Noted as important extension for future work

### 4. Add Missing References
- Imbens & Kalyanaraman (2012) — bandwidth choice
- Cattaneo, Frandsen & Titiunik (2015) — local randomization
- Conley (1999) — spatial HAC
- Donaldson & Storeygard (2016) — satellite data applications

### 5. Improve Exposition
- Moved RDD binscatter (Figure 2) and nightlight event study (Figure 5) to main text
- Improved opening paragraph with vivid monsoon imagery
- Added footnote explaining bandwidth sensitivity vs. main table differences

### 6. Not Addressed (Future Work)
- OMMS first-stage matching (data access constraint)
- State-level heterogeneity (sample size constraint)
- Formal multiple testing adjustment (Benjamini-Hochberg)
- Geographic map of study area
