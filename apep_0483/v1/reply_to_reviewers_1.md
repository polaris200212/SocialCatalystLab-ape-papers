# Reply to Reviewers — Round 1

## GPT-5.2 (Reject and Resubmit)

**1. "Cross-sectional selection-on-observables with limited covariates"**
We agree this is the fundamental limitation. The design exploits a plausible institutional feature (national pay interacting with local wage variation), but the treatment is ultimately driven by local private-sector wage growth. We have softened all causal language to frame results as associations rather than definitive causal effects.

**2. "No pre-treatment outcome data"**
Acknowledged as the most significant limitation. Pre-2018 KS4 data (% 5+ A*-C) exists in DfE archives but was not accessible via the API used. Future work should incorporate this data to enable a DiD/event-study design.

**3. "Placebo test is similar magnitude"**
We now acknowledge the placebo concern prominently in the introduction and conclusion. The abstract explicitly notes that "a placebo test raises concerns about pre-existing differences."

**4. "RF-AIPW significance may not survive cross-fitting"**
**Addressed.** We have implemented 5-fold cross-fitted AIPW following Chernozhukov et al. (2018). The cross-fitted estimate is -0.57 (SE=1.69, p=0.737), confirming that in-sample significance does not survive conservative inference. This result is reported in Table 2 (Column 5b) and discussed in the text.

**5. "Covariate set too thin"**
We attempted to add IMD deprivation scores and other baseline covariates from NOMIS/gov.uk APIs, but data access was not successful within this revision cycle. We acknowledge this limitation explicitly.

**6. "Missing citations: Chernozhukov et al. 2018"**
Added and cited in the context of the cross-fitted AIPW results.

## Grok-4.1-Fast (Major Revision)

**1. "Failed placebo"**
Acknowledged prominently in introduction and conclusion.

**2. "Geographic sorting: treated overrepresent Unitary authorities"**
Already documented in leave-one-region-out analysis. We add explicit discussion that the result is driven by Unitary treated vs. London borough controls.

**3. "Add spending/demog controls"**
Data access limitations prevented this. Acknowledged as a limitation.

**4. "Add Falch (2011), Jackson (2020)"**
Noted for future revision. These are relevant comparisons for centralized pay systems and teacher experience effects.

## Gemini-3-Flash (Major Revision)

**1. "Placebo failure suggests persistent structural differences"**
Fully acknowledged. The abstract and conclusion now frame results as "suggestive" with explicit caveats.

**2. "ML-based significance where OLS fails raises concerns"**
**Addressed.** The cross-fitted AIPW confirms that the in-sample RF precision gain does not survive out-of-fold estimation. We present this transparently as Column 5b.

**3. "Clustering at higher level"**
We note that with only 4 region types, region-level clustering would be unreliable. The heteroskedasticity-robust SEs are appropriate for the cross-sectional design.

## Prose Workstream

Based on the prose review:
- Improved opening hook (specific £14.15/hour figure)
- Reduced table narration in results section
- Punchier abstract opening
- Stronger conclusion ending

## Exhibits Workstream

Based on the exhibit review:
- Added significance stars to Table 2
- Added cross-fitted result row (Column 5b)
