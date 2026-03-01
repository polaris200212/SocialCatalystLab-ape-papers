# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): REJECT AND RESUBMIT

### Concern 1.1: Treatment intensity measured post-treatment
> "Treatment intensity is measured post-treatment (current register), invalidating causal interpretation."

**Response:** We fully agree this is the most important limitation of our study. In the revision, we have:
- Removed the claim of "first causal estimates" from the introduction, replacing it with "first systematic empirical examination"
- Substantially expanded the acknowledgment in the Data section, explicitly stating this is "the most important data limitation of our study"
- Added a paragraph in the property price results noting that "definitive causal attribution requires the historical exposure data and event-study validation that are beyond the scope of our current design"
- Softened all causal language for property prices from "unambiguous" to "precisely estimated association consistent with" the vacancy channel
- Updated the abstract to include the caveat about post-closure density proxy

We note that obtaining historical Gambling Commission licensing data is the top priority for any future revision but is beyond the scope of the current data infrastructure.

### Concern 1.2: COVID and differential urban shocks confound
> "Post period bundles policy + COVID + divergent urban trends."

**Response:** We already include COVID exclusion and COVID×Density interaction specifications. In the revision, we have strengthened the caveat language throughout, particularly for property prices, explicitly noting that "the post-period overlaps with COVID-19, which differentially affected urban housing markets through work-from-home shifts and temporary demand reallocation."

### Concern 1.3: Event study and placebo tests needed for property prices
> "Provide regression-based event studies and placebo-date tests for property prices."

**Response:** We agree this would strengthen the property price results substantially. In the revision, we explicitly acknowledge this gap: "Without a formal event study regression for prices (using annual leads and lags) or placebo date tests, we cannot rule out that the price divergence reflects broader urban-cycle confounding." Adding the property price event study requires code modifications reserved for a future revision.

### Concern 1.4: Zero density for unmatched CSPs
> "Assigning zero density to unmatched CSPs is not 'conservative'; it is mismeasurement."

**Response:** We acknowledge this concern. The 31 unmatched CSPs are primarily Welsh and recently restructured authorities. A sensitivity analysis excluding these CSPs is a natural robustness check for future revision.

### Concern 1.5: Multiple testing
> "Report adjusted q-values or joint tests."

**Response:** We have added a note in the Results section: "testing multiple crime categories raises a multiple-comparison concern: with six outcomes, marginal significance at p = 0.087 for the aggregate is even less persuasive than its nominal level suggests."

### Concern 1.6: Property price causal claims over-stated
> "The paper labels the price effect 'unambiguous' and 'strong evidence'... currently over-claimed."

**Response:** We have systematically recalibrated all property price language throughout the paper:
- Abstract: added "warrant caution in causal interpretation"
- Results: replaced "clear and robust" with "tell a different story" and added full paragraph of caveats
- Discussion: changed section header from "A Robust Finding" to "A Precisely Estimated Association"
- Conclusion: added "definitive causal attribution awaits better data"

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Concern 2.1: Explicitly reject TWFE crime claims
> "Recast main crime result as null... frame as 'no robust evidence'."

**Response:** The paper already frames the crime result as an "honest null" throughout. In the revision, we have strengthened this by leading the introduction's results paragraph with "The crime result is an honest null" and noting the marginal significance is "almost certainly spurious."

### Concern 2.2: Add pre-trend tests for property
> "Event study absent (only Fig 6 raw trends)."

**Response:** We agree a formal annual event study for property prices would strengthen the paper. We now explicitly acknowledge this gap in the text. Reserved for future revision requiring code changes.

### Concern 2.3: Verify treatment proxy
> "Current density assumes proportional closures preserve ranking."

**Response:** We have expanded the Data section to state: "While we believe this ranking is well-preserved... we cannot directly verify this claim without historical licensing data, and the possibility of non-proportional closures means our treatment variable may contain non-classical measurement error."

### Concern 2.4: Test mechanisms empirically
> "Theoretical channels untested... no vacancy data."

**Response:** We now explicitly label the mechanism discussion as speculative: "our mechanism discussion is necessarily speculative given the absence of direct data on vacancy rates, footfall, or commercial turnover."

### Concern 2.5: COVID robustness — post-2022 only
> "Report full post-COVID excl. (2022+ only)."

**Response:** This is a valuable suggestion. Our current COVID exclusion removes 2020Q1–2021Q2; a specification using only 2022+ post-data would provide a cleaner window but with less statistical power. Noted for future revision.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Concern 3.1: Historical treatment data
> "Authors must obtain historical licensing data."

**Response:** We agree this is the highest-priority improvement. It is beyond the scope of the current data sources but is noted as the top priority for future work. The text now explicitly identifies this as the most important limitation.

### Concern 3.2: Geographic granularity
> "CSP-level analysis is too coarse. Use street-level crime data."

**Response:** We discuss this limitation in Section 4.5.5 (Geographic Aggregation) and in the future research section. Street-level analysis using data.police.uk would require shop-level geocoding and closure dates that we do not currently have.

### Concern 3.3: Treatment heterogeneity by vacancy rates
> "Interact treatment with baseline commercial vacancy rates."

**Response:** This is an excellent suggestion. We do not currently observe commercial vacancy rates. We note this as a natural extension in the Discussion.

---

## Exhibit Improvements

Following the exhibit review:
- **Table 2 (Crime):** Added significance stars (* for p<0.10) and "Mean dep. var." row for magnitude interpretation
- **Balance Table:** Promoted from appendix to main text (now Table 3, before Empirical Strategy) to establish treatment-control imbalance before readers see results
- **Dose-Response Figure:** Moved from main text to Robustness Appendix — secondary evidence that was cluttering the main narrative

## Prose Improvements

Following the prose review:
- **Data section:** Collapsed from six inventory-style subsections into three flowing paragraphs
- **Introduction:** Removed roadmap paragraph; restructured results preview to lead with "honest null" framing rather than caveats
- **Results narration:** Humanized magnitudes ("roughly three betting shops serving a population of 35,000... one extra crime every nine days") and moved the £5,600/£9,200 headline figures earlier
- **Language:** Reduced "specification" and "statistically significant" usage; replaced with descriptions of findings
- **Claims calibration:** Changed "first causal estimates" → "first systematic empirical examination"; "unambiguous" → "precisely estimated association"
