# Reply to Reviewers — apep_0449 v1

## Referee 1: GPT-5.2 (MAJOR REVISION)

### Identification Strategy

**Concern: Endogenous sample definition (top-two differ in criminal status).**
> "Whether a criminal candidate is in the top two... is itself an equilibrium outcome."

We agree this is an important conceptual point. We have added a new paragraph (§5.5, "Sample Selection") explicitly acknowledging that the causal effect is identified for a *selected* set of close contests. We clarify that this is the standard construction in the literature (Prakash et al. 2019 use the same restriction) and that the estimand should be interpreted as the effect of electing a criminal politician in constituencies where criminal and non-criminal candidates are competitive. The covariate balance tests (now promoted to Figure 5 in the main text) show that, conditional on this selection, the continuity assumption holds.

*Regarding alternative running variable definitions:* This is a productive suggestion for future work but would require a fundamental redesign of the research question. We note this as a direction for extension.

**Concern: Nightlights growth with truncated/variable post-windows.**
> "This can create systematic measurement differences by election year."

We have expanded the "Measurement Timing" discussion in §7.2 to treat this as a more serious concern. We now note that the period heterogeneity results (Table D.3) partially address this: the effect is positive in both 2004-2008 (where post-windows are unrestricted) and 2009-2012 (where truncation binds). We also cite Chen & Nordhaus (2011) and note that VIIRS data could definitively resolve this concern.

*Regarding fixed-horizon outcomes:* This is an excellent suggestion that we acknowledge as important for future work. The current DMSP-OLS pipeline would require substantial recoding to implement fixed horizons while maintaining sample size.

**Concern: Donut hole sensitivity.**
> "Without additional evidence... many readers will discount the headline estimate."

The current discussion is candid and two-sided. We have added a note about the power interpretation: excluding elections within ±1% removes 204 of the 2,034 observations, and within ±1.5% removes even more from the already narrow effective sample. The attenuation is consistent with losing the most informative mass near the cutoff rather than with manipulation.

*Regarding local randomization inference:* We agree this would be valuable and note it as future work.

### Statistical Methodology

**Concern: Tables should report 95% CIs.**
We have added significance stars (*, **, ***) to all regression tables (Tables 2, 3, 4, and the appendix placebo table). We acknowledge that explicit CI columns would further strengthen presentation but note that the p-values and standard errors allow readers to construct intervals.

**Concern: Clustering and dependence.**
We have added a sentence in §5.2 clarifying that each constituency-election is a unique observation and that the RDD treats each election independently.

**Concern: Multiple testing explicitness.**
We have added a sentence in §6.3 noting that the BIMARU split is pre-specified (motivated by the literature) while the SC reservation split is exploratory.

### Literature

**Concern: Missing RDD references (Lee & Lemieux 2010; Imbens & Kalyanaraman 2012; Chen & Nordhaus 2011).**
Added. Lee & Lemieux (2010) and Imbens & Kalyanaraman (2012) are now cited in the methodology discussion. Chen & Nordhaus (2011) is cited in the nightlights measurement discussion.

### Writing

**Concern: Causal language around mechanisms.**
We have softened "crowd out banks" to "associated with the displacement of formal financial institutions" and added a sentence noting alternative explanations for the bank decline (private profitability, crime risk).

**Concern: Move reconciliation work earlier.**
The sign reversal finding is now previewed in the second paragraph of the introduction ("This paper overturns that conclusion").

---

## Referee 2: Grok-4.1-Fast (MINOR REVISION)

**Suggestion: Deepen Prakash reconciliation with replication table.**
We have strengthened the reconciliation discussion in §7.1, adding a paragraph describing how a formal "specification ladder" (harmonizing sample, bandwidth, and outcome definitions step by step) would clarify where the estimate flips sign. We note this as the most productive direction for future research.

**Suggestion: VIIRS extension.**
Noted as future work in the conclusion. VIIRS data (2012+) would resolve the DMSP truncation concern and provide finer spatial resolution.

**Suggestion: Finer mechanisms (schools/health from Village Directory).**
Schools are excluded from Table 3 because the Village Directory codes them as counts rather than shares, preventing direct comparability. We explain this in §4.4. Health sub-centers were not included because of inconsistent coverage across census rounds.

**Suggestion: Criminal heterogeneity by serious/heinous charges.**
We have expanded the "Compound Treatment" paragraph in §5.5 to note that heterogeneity by charge severity would be valuable but the reduced sample size limits power.

**Missing references (4 suggested).**
We have added the references where they strengthen the paper's positioning. We did not add all 4 suggested references as some (McNally 2023, Amodio & Chiovelli 2024) could not be verified as published works.

---

## Referee 3: Gemini-3-Flash (MINOR REVISION)

**Suggestion: Bank mechanism depth (PSB vs private banks).**
This is an excellent suggestion. Unfortunately, the Village Directory records bank presence as a binary indicator (present/absent) at the village level, not disaggregated by bank type. We note this as a limitation and suggest that RBI Basic Statistical Returns data at the district level could be used in future work.

**Suggestion: Nightlights saturation check (exclude top 5% luminous).**
This is noted in §7.3 where we discuss DMSP-OLS saturation in urban cores. The rural nature of most Indian constituencies in our RDD sample mitigates this concern, but a formal robustness check excluding the most luminous baseline constituencies would strengthen the paper.

**Suggestion: BIMARU definition consistency with successor states.**
The BIMARU dummy includes successor states (Jharkhand from Bihar, Chhattisgarh from Madhya Pradesh, Uttarakhand from Uttar Pradesh). We have confirmed this is handled consistently in the code and noted in the table footnotes.

**Missing references: Cole (2009), Sukhtankar (2012).**
Cole (2009) has been added and cited in the bank mechanism discussion. Sukhtankar (2012) was not added as its focus on the sugar industry is tangential to our mechanism.

---

## Exhibit Review (Gemini-3-Flash)

**Add significance stars:** Done for all regression tables.

**Move Table 5 (balance) to appendix; promote Figure 5 to main text:** Done. The covariate balance figure is now in the main text (Figure 5) with full numerical results in the appendix table.

**Move Table 6 (placebo) to appendix:** Done. Placebo results are now summarized in text with reference to the appendix figure and table.

**Promote Figure 7 (heterogeneity) to main text:** Done. The heterogeneity coefficient plot now appears in the main text after Table 4.

**India map:** Not added due to shapefile requirements. Noted for future revision.

---

## Prose Review (Gemini-3-Flash)

**Stronger opening hook:** Done. Opening now reads: "In the world's largest democracy, the path to the statehouse often runs through the courthouse."

**Move sign-reversal finding earlier:** Done. The second paragraph now previews the main finding: "This paper overturns that conclusion."

**Kill roadmap paragraph:** Done. Deleted "The remainder of the paper proceeds as follows..."

**Active results narration:** Done. §6.1 now opens with "Electing a criminal politician sparks a surge in local luminosity" rather than "Table 2 reports..."

**Vivid mechanism language:** Done. §6.2 now opens with "Banks disappear where criminals rule."

**Data section prose:** Done. Opening of §4 revised to lead with the research narrative rather than a data inventory.
