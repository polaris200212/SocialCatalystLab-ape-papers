# Reply to Reviewers — Round 1

## Overview

We thank all three reviewers for their detailed and constructive feedback. The reviews converge on several key themes, which we address below. The most significant revision is a substantial recalibration of the paper's claims to accurately reflect what the available data window (2020-2025) can identify.

---

## Reviewer 1 (GPT-5.2): REJECT AND RESUBMIT

### 1.1 "Core issue: post-treatment cross-sectional design"

**Concern:** The main regression is a cross-sectional hedonic comparison, not a credible causal design. Cannot attribute cross-sectional level differences to the reform without pre-reform data.

**Response:** We agree this is the central limitation. We have:
- Added an explicit paragraph in Section 5 acknowledging that the DVF data for 2014-2019 has been removed from the public portal (rolling 5-year window), preventing pre-trend tests
- Recalibrated all claims from "no capitalization" to "no cross-sectional capitalization in the post-reform period"
- Explicitly noted in the abstract and conclusion that early capitalization (2017-2019) cannot be tested
- Added this as the first and most prominent limitation, noting it as "the single most valuable addition" for future work

### 1.2 "Event study is post-treatment only"

**Response:** Acknowledged. We now explicitly state that the event study within 2020-2025 is a weaker test that cannot substitute for pre-reform parallel trends. The flat profile is consistent with either no capitalization or early capitalization already complete by 2020.

### 1.3 "Treatment intensity mismeasured"

**Concern:** Commune voted TH rate ignores cadastral bases, EPCI layers, income composition, primary/secondary shares.

**Response:** We acknowledge this concern in the limitations. The commune voted rate is the most granular measure available in the REI. Multi-layer decomposition would require EPCI-level tax data and cadastral detail not publicly available. We now note this as a data limitation.

### 1.4 "Fiscal substitution: mechanical vs behavioral"

**Concern:** 22pp increase is largely mechanical; conditional regression shows weak behavioral response.

**Response:** We have substantially revised the fiscal substitution narrative (Section 6.5) to:
- Explicitly acknowledge the conditional coefficient is small (~0.004) and only marginally significant
- Reframe: substitution was primarily a national-level mechanical phenomenon (département share transfer)
- Clarify that for the capitalization analysis, the mechanical/behavioral distinction is immaterial
- Remove language suggesting "strongly correlated" conditional behavioral response

### 1.5 "Euro-denominated effects"

**Response:** Added a back-of-envelope calculation after the main results translating rate-point estimates into euro terms: for a median commune, full capitalization would imply ~€15,000 per dwelling (5-8% of median price), and our estimates can rule out effects as small as 0.8% per 10pp TH rate.

### 1.6 "Wild cluster bootstrap"

**Response:** We acknowledge this suggestion but note that with 93 département clusters and massive N, conventional cluster-robust SEs are typically reliable. We leave wild bootstrap implementation to future work but note this would be straightforward with the `fwildclusterboot` R package.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### 2.1 "Pre-2020 DVF and parallel trends"

**Response:** See 1.1 above. We tried to obtain the 2014-2019 DVF files but they have been removed from the public portal. This is now explicitly acknowledged.

### 2.2 "TH endogeneity — IV or matching"

**Response:** We discuss this in Threats to Validity. Within-département, TH rates reflect decades of local fiscal decisions largely uncorrelated with current economic conditions (due to the 1970 cadastral base). We strengthen this argument in the text. A formal IV (e.g., 1970 cadastral base characteristics) would require historical data not currently available.

### 2.3 "Decompose mechanical vs behavioral TFB + net regression table"

**Response:** See 1.4 above. The decomposition requires the exact département-to-commune transfer formula, which is not publicly available at the commune level. We now frame this transparently as a data limitation and note it as a priority for future work.

### 2.4 "Missing citations"

**Response:** The bibliography already includes Callaway & Sant'Anna (2021), Cellini et al. (2010), Hilber (2017), and other key references from the capitalization literature. We note the suggestion to add Schulhofer-Wohl and Fuest (2018) — Fuest is already cited.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### 3.1 "Data extension to 2014-2019"

**Response:** See 1.1 above.

### 3.2 "Mechanical vs behavioral substitution"

**Response:** See 1.4 above.

### 3.3 "Placebo test with secondary residences"

**Response:** DVF does not flag primary vs secondary residences at the transaction level. We note the suggestion to use commune-level secondary residence shares from census data as a triple interaction. This is a valuable extension but requires merging INSEE census data that is not part of the current data pipeline. We flag this in the limitations.

---

## Exhibit and Prose Review Improvements

Based on the exhibit review (Gemini):
- Improved event study figures with reference lines and better formatting
- Added zero-reference lines to all iplot-based figures

Based on the prose review (Gemini):
- Rewrote opening paragraph with Shleifer-style hook ("Between 2018 and 2023, the French government abolished a €22 billion tax...")
- Replaced table narration in results section opening
- Shortened roadmap paragraph
- Replaced "These findings contribute to several literatures" with "These results challenge three established views"
- Trimmed throat-clearing throughout

---

## Summary of Changes

1. **Claims recalibrated** throughout: "no cross-sectional capitalization during 2020-2025" rather than "no capitalization whatsoever"
2. **Data limitation acknowledged upfront** in Section 5 and prominently in Limitations
3. **Fiscal substitution reframed** as primarily mechanical/national, with weak conditional behavioral component
4. **Euro-denominated power analysis** added to Results
5. **Prose improvements** from exhibit and prose review feedback
6. **Opening rewritten** with concrete hook
