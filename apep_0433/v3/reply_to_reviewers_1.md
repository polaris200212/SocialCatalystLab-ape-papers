# Reply to Reviewers — apep_0433 v3

## Reviewer 1 (GPT-5.2) — MAJOR REVISION

### Concern 1: Compound Treatment
> The 1,000-inhabitant threshold bundles electoral system change with gender parity, making it difficult to isolate parity effects.

**Response:** We agree this is the central identification challenge and have restructured the paper to frame the estimand explicitly as a "bundled electoral reform" rather than claiming to isolate parity. The three validation strategies (council size test, 3,500 threshold, fuzzy IV) are presented as complementary evidence rather than as a definitive decomposition. We have removed the claim that the IV "nets out the direct effect of PR" and instead acknowledge the exclusion restriction limitation explicitly.

### Concern 2: Outcome Timing
> Political variables from 2020; labor outcomes rolling 2018-2022; facilities are 2024 stock.

**Response:** We have expanded the discussion of the 40/60 pre/post split, noting that the pre-2020 observations were collected under councils also subject to the same 1,000-inhabitant threshold (since 2014). The RP2021 outcome therefore captures cumulative exposure to two mandates under the same threshold rule. We add the BPE stock-vs-flow limitation explicitly. The 2016 census placebo (one cycle after the 2013 law) shows no effects, reinforcing the null.

### Concern 3: Multiple Testing Strategy
> Secondary outcomes rely on raw p-values; consider Benjamini-Hochberg or summary indices.

**Response:** The pre-specified hierarchy explicitly labels secondary outcomes as hypothesis-generating with raw p-values. We note that applying Benjamini-Hochberg correction within secondary families would not change conclusions, as only 2 of 16 secondary outcomes are marginally significant at the 5% level.

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### Concern 1: Introduction Formatting
> Findings presented as bullet points; convert to prose.

**Response:** We note the findings use italicized headers (\textit{First stage}, etc.) which is a standard format in empirical economics papers (cf. Autor, Dorn & Hanson 2013; Chetty et al. 2016). We have retained this format as it aids readability.

### Concern 2: Literature Gaps
> Missing references on EU quotas and rich-country nulls.

**Response:** We have added Clots-Figueras (2012), Folke & Rickne (2020), and Lippmann (2022) in the revision. The Italian quota literature (Baltrunaite et al. 2014) was already cited.

### Concern 3: IV Transparency
> Fuzzy RD-IV could be downplayed further.

**Response:** We have moved the fuzzy IV table to the appendix and strengthened the caveat about non-informative standard errors.

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Concern 1: Treatment Intensity
> 2.74pp first stage is modest; unclear whether nulls reflect "representation doesn't matter" vs "quota too small."

**Response:** We have added a paragraph in Section 5.1 documenting the female councillor share distribution near the cutoff (10th-90th percentiles: 0.30-0.52) and expanded the mechanisms discussion of treatment intensity. The paper now explicitly distinguishes between "parity does not change policy" and "this specific increment in female share is too small to change policy."

### Concern 2: BPE Stock Measurement
> Facilities measure stock, not flow; infrastructure changes slowly.

**Response:** We have added this as an explicit limitation. However, we note that the BPE stock reflects cumulative policy decisions over the entire 2014-2024 period — two full mandate cycles. If parity had gradually shifted priorities, the stock would capture it.

### Concern 3: Political Affiliation Heterogeneity
> Aggregate nulls may mask partisan shifts.

**Response:** We lack commune-level party affiliation data for small communes (below 1,000, elections are non-partisan). We note this as a limitation and a direction for future research.

## Exhibit Review Response
- Fixed BPE vintage labels (2023 → 2024) in all tables
- Retained Figure 4 (childcare RDD) in main text as it is the flagship new exhibit
- 3,500 validation kept in appendix for space; clearly cross-referenced

## Prose Review Response
- Removed roadmap paragraph (Section 1)
- Sharpened hedge language throughout (e.g., "The mayor null is important because" → "The mayoralty is the ultimate prize")
- Added concrete institutional example in Section 2.1 (crèche, school, sports complex)
