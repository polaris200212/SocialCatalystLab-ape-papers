# Reply to Reviewers

## Response to GPT-5.2 (Referee 1: REJECT AND RESUBMIT)

### 1.1 Treatment/eligibility measurement problem (New Build flag ≠ built-after-2009)

> "The actual proxy is the Land Registry New Build flag, which tags first sales only... the DDD is identified off a comparison between new-build first-sale transactions and all other transactions."

**Response:** We agree this is a fundamental limitation. We have substantially expanded the discussion of misclassification in Section 3.4 (Implications for Identification) to:
- Quantify the contamination: we estimate that by 2020, approximately 15–25% of "eligible" transactions in flood zones may involve post-2009 resales
- Explicitly acknowledge that the misclassification is non-classical and systematically correlated with the new-build market segment
- Note that attenuation toward zero is not guaranteed under non-classical measurement error
- Reframe the DDD as estimating the price differential between new-build first sales and all other transactions, which includes but is not limited to the insurance eligibility channel

We cannot obtain true construction year within the current data pipeline. We acknowledge in the revised Limitations section that linking to EPC registers, Valuation Office records, or local authority building control data would allow a cleaner eligibility classification and flag this as the highest-priority direction for future work.

### 1.2 Parallel trends: diagnostics show failure

> "The event study shows uniformly negative pre-treatment coefficients and rejects no-pretrends (joint p = 0.011)."

**Response:** We agree. The revised paper does not claim a clean causal null. We have recalibrated all claims throughout:
- Abstract: removed "precisely-estimated null" framing; now states "evidence against large positive capitalization but cannot isolate the Flood Re mechanism from confounding vintage trends"
- Introduction: explicitly states results "should be interpreted as evidence against large positive capitalization rather than as a clean causal null"
- Results: added placebo-adjusted bounds (main DDD minus Very Low placebo ≈ +0.12), suggesting any positive insurance effect is small
- Conclusion: all three conclusions explicitly hedged with identification caveats

### 1.3 Placebo test: strong evidence of confounding

> "A placebo of that magnitude essentially falsifies the mechanism-based DDD interpretation."

**Response:** We agree that the Very Low risk placebo (-0.134) is the most damaging diagnostic. The revised paper:
- Interprets the main DDD as an upper bound rather than a causal estimate
- Adds a crude placebo-adjusted bound calculation
- Adds a new paragraph in the Discussion section explicitly acknowledging that the failing placebo may indicate the DDD lacks power to isolate the insurance channel from vintage dynamics

### 1.4 No micro first stage

> "Without showing that transacted eligible properties actually experienced premium reductions, 'null capitalization' is uninterpretable."

**Response:** We have expanded the aggregate first-stage evidence paragraph (Section 3.3) citing Flood Re's 350,000 ceded policies and 97% quote availability under £1,250. We acknowledge explicitly in the Limitations section that this is aggregate, not micro, and that the reduced-form null could reflect low take-up among transacting properties. We flag micro premium/take-up data as essential for future work.

### 1.5 Policy conclusions outrun identification

> "Given identification failure, that inference is not supported."

**Response:** The entire Discussion section (7.3) has been rewritten. Policy implications are now explicitly conditional: "If the evidence against large positive capitalization reflects genuine non-capitalization rather than identification limitations..." All stakeholder-by-stakeholder analysis now includes appropriate hedging.

### 1.6 Jointly estimated event study

> "The current 'two-year window vs 2015' approach is nonstandard."

**Response:** We acknowledge this limitation in the revised paper. Implementing a jointly estimated specification would require restructuring the estimation code; we flag this as a direction for future work.

### 1.7 Cluster dimension reporting

**Response:** Added: "approximately 120 districts" and "68 quarters in the main 2009–2025 sample" to the empirical strategy section.

---

## Response to Grok-4.1-Fast (Referee 2: MAJOR REVISION)

### 2.1 Pre-trends/placebo failures

> "Core ID violation (p=0.011 pre-trends; Very Low placebo -13.4%); top journals reject without resolution."

**Response:** See responses to GPT 1.2 and 1.3. We have comprehensively recalibrated claims and added placebo-adjusted bounds. We agree that vintage confounders are the central weakness and have restructured the paper's framing accordingly.

### 2.2 Obtain/estimate first stage

> "Aggregate Flood Re cedants/premiums by vintage/risk (Flood Re reports)."

**Response:** We have expanded the first-stage evidence using Flood Re annual report data (Section 3.3). We acknowledge this is aggregate and flag micro data as essential for future work.

### 2.3 Refine eligibility

> "Restrict ineligible to new-build sales only (as-is), but add resale-only subsample."

**Response:** The ineligible group is already restricted to new-build first sales. We have added extensive discussion of the contamination in the eligible group (Section 3.4). A resale-only subsample analysis would require address matching across time; we flag this as future work.

### 2.4 Deeper vintage confounders (EPC ratings)

> "Proxy energy efficiency (post-2006 regs), add building age bins."

**Response:** We now discuss post-2006 energy efficiency standards as a potential vintage confounder in the Threats to Validity section. EPC matching is beyond current data capabilities but flagged as a high-value improvement for future work.

### 2.5 Missing literature

> "Cite Koster (2021), Ortega/Taspinar (2018), Atreya (2013)."

**Response:** Added all three:
- Koster and van Ommeren (2021, JUE) and Ortega and Taspinar (2018, JUE) added to Related Literature section on flood risk capitalization
- Atreya et al. (2013) added to the salience/risk updating discussion

---

## Response to Gemini-3-Flash (Referee 3: MAJOR REVISION)

### 3.1 Address misclassification bias quantitatively

> "The author must estimate the 'true' share of post-2009 resales."

**Response:** We have added a quantitative discussion in Section 3.4 estimating that by 2020, approximately 15–25% of "eligible" flood-zone transactions may involve post-2009 resales, based on the cumulative post-2009 stock and average holding periods. We also discuss the non-classical nature of the measurement error and its implications for bias direction.

### 3.2 Control for vintage trends / quadruple difference

> "Use the 'Very Low' risk group as a further control level."

**Response:** We have added crude placebo-adjusted bounds (main DDD minus Very Low placebo) as a rough approximation to this approach. A formal quadruple-difference specification would require careful implementation; we flag this as a promising direction for future work.

### 3.3 Hone moral hazard evidence

> "Find areas where planning rules didn't change but Flood Re eligibility did."

**Response:** We acknowledge the confound with planning regulations more explicitly in the revised text. Exploiting within-planning-regime variation would require detailed planning policy data at sub-national level; flagged as future work.

### 3.4 Council Tax band heterogeneity

> "Use actual bands rather than price quartiles."

**Response:** Council Tax band data is not available in the Land Registry PPD. We acknowledge this as a limitation and note it would provide a true dose-response test.

---

## Exhibit Improvements

Based on the exhibit review:
- Moved robustness table (Table 4) to appendix (redundant with forest plot Figure 2)
- Forest plot Figure 2 now stands alone in main text with reference to appendix table

## Prose Improvements

Based on the prose review (many already implemented in prior rounds):
- Opening hook with two-house comparison (already implemented)
- Fixed "SUTVA violations" → "Spillover effects" (already implemented)
- Improved Data section transition: now reads "To track how the market priced the 2009 eligibility cutoff, I use..."
- Results narration already improved in prior round (removed "Column X shows..." patterns)

## Summary of Changes

1. **Abstract:** Removed "precisely-estimated null"; reframed as evidence against large positive capitalization with identification caveats
2. **Introduction:** Explicitly states results cannot isolate Flood Re from vintage trends
3. **Section 3.4:** Expanded misclassification discussion with quantitative estimates and non-classical bias analysis
4. **Section 6.4:** Added placebo-adjusted bounds calculation
5. **Section 5.1:** Added cluster dimension counts (120 districts, 68 quarters)
6. **Section 7.1:** Rewritten to acknowledge identification may fail, not just substantive non-capitalization
7. **Section 7.3:** All policy conclusions now conditional on causal interpretation
8. **Section 7.4:** Substantially expanded limitations with six clearly articulated concerns
9. **Section 8 (Conclusion):** Three conclusions all appropriately hedged; limitations paragraph expanded; future directions explicit
10. **Literature:** Added Koster and van Ommeren (2021), Ortega and Taspinar (2018), Atreya et al. (2013)
11. **Appendix:** Robustness table moved from main text
