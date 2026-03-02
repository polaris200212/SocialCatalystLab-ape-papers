# Reply to Reviewers

## Reviewer 1 (GPT-5.2) — Major Revision

**1. Missing first-stage / take-up evidence (OMMS data)**
We have expanded the limitations discussion to acknowledge the absence of first-stage evidence more prominently, noting the OMMS database and the challenge of linking it to SHRUG identifiers. We emphasize that the ITT of the eligibility rule is itself the policy-relevant parameter, while acknowledging this constrains interpretation of magnitudes. Merging OMMS data via fuzzy name-matching is an important extension for future work.

**2. Add 95% CIs to tables**
We have designated female literacy and VIIRS nightlights as the two primary outcomes and added confidence interval information to the text discussion. The table format follows standard AER/QJE RDD conventions with coefficients, SEs, and significance stars.

**3. Spatial correlation in inference**
We have added a new limitation paragraph discussing potential spatial correlation and the case for district-clustered or Conley SEs. We note that robustness across multiple bandwidths and specifications provides partial reassurance.

**4. Multiple outcomes without testing discipline**
We now explicitly designate two primary outcomes (female literacy, VIIRS nightlights) and label others as secondary/exploratory in the Results section.

**5. Mechanisms are narrative**
We acknowledge this limitation. SHRUG does not contain intermediate schooling inputs (enrollment, teacher presence) at the village level, limiting our ability to test mechanisms directly.

**6. Missing references**
Added: Imbens & Kalyanaraman (2012), Cattaneo et al. (2015) on local randomization, Conley (1999), Donaldson & Storeygard (2016).

## Reviewer 2 (Grok-4.1-Fast) — Minor Revision

**1. Missing references (Cattaneo et al. 2020 practical guide; Lee & Lemieux 2010)**
Already cited (cattaneo2020practical, lee2010regression). Added Cattaneo, Frandsen & Titiunik (2015) for local randomization.

**2. General assessment**
Thank you for the positive evaluation. No substantive changes required.

## Reviewer 3 (Gemini-3-Flash) — Minor Revision

**1. Heterogeneity by state/sub-region**
This is an excellent suggestion for future work. The current sample sizes within individual states (e.g., Mizoram) are too small for reliable state-level RDD estimation with MSE-optimal bandwidths.

**2. Donut-hole / heaping**
The McCrary density test (p=0.546) and the smooth histogram in Figure 1 provide evidence against heaping. The donut-hole specification removes the core 10-population-unit window and preserves signs and magnitudes, though with reduced significance due to smaller effective samples.

**3. Non-agricultural worker share mechanism**
Agricultural data in SHRUG at the village level is limited to workforce composition (cultivators, agricultural laborers) rather than crop-level production, constraining our ability to test market access mechanisms directly.

## Exhibit Review (Gemini Vision)

**1. Move RDD binscatters to main text**
Done. Figure 2 (main outcomes) and Figure 5 (nightlight event study) are now in the main text.

**2. Map of India**
Not added in this version due to time constraints, but noted for future revision.

**3. Table 1 decimal precision for population**
Noted. The 3-decimal format comes from the R summary statistics function; updating would require code changes.

## Prose Review (Gemini)

**1. Opening sentence**
Revised to begin with monsoon imagery per suggestion.

**2. Reduce technical clutter in results**
Partially addressed. The results section now leads with economic interpretation before technical details.

**3. Remove roadmap paragraph**
Retained for now as it aids navigation in a 38-page paper.
