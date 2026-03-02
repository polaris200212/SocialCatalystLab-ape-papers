# Reviewer Response Plan

## Feedback Summary

### Referee Decisions
- **GPT-5.2:** REJECT AND RESUBMIT
- **Grok-4.1-Fast:** MAJOR REVISION
- **Gemini-3-Flash:** MAJOR REVISION

### Consensus Concerns (All 3 Reviewers)

1. **Pre-trends and placebo failure compromise identification.** All three reviewers flag the joint pre-trend test (p=0.011) and the Very Low risk placebo (-0.134***) as the most damaging findings. The DDD is picking up vintage depreciation in flood-classified areas, not the Flood Re insurance channel.

2. **Eligibility proxy (New Build flag) is not construction year.** GPT is most critical: the "ineligible" group is new-build first sales, not "post-2009 properties." Grok and Gemini agree the measurement error is non-trivial. GPT argues the bias direction is not necessarily conservative.

3. **No micro first stage.** All three note the absence of property-level premium data. The reduced-form null is ambiguous without confirming the subsidy actually reached transacted properties.

4. **Claims are overcalibrated.** "Precisely-estimated null" is not supported given diagnostic failures. All reviewers want claims substantially softened.

### Reviewer-Specific Concerns

**GPT (harshest):**
- Wants redesigned empirical approach (repeat sales, RD around 2009, micro first stage)
- Argues policy conclusions outrun identification
- Wants jointly estimated event study (not two-year windows)
- Requests cluster dimension reporting

**Grok:**
- Wants vintage×risk interactions to control for confounding trend
- Suggests placebo-adjusted bounds (main - placebo)
- Requests first-stage data from Flood Re annual reports
- Missing literature: Koster et al. (2021), Ortega & Taspinar (2018), McCoy et al. (2023), Atreya et al. (2013)

**Gemini:**
- Wants misclassification bias quantified (estimate true post-2009 resale share)
- Suggests quadruple difference using Very Low risk as further control
- Wants Council Tax band heterogeneity (not price quartiles)
- Requests HonestDiD for moral hazard outcome

### Exhibit Review Feedback
- Table 1: Decimal-align, comma-separate N, explain abbreviations
- Table 2: Add p-values to balance differences
- Table 4: Convert to forest plot (or promote appendix figures 5/6)
- Figure 1: Remove vertical gridlines
- Figure 8: Fix scale issue (dual axis)
- Table 5: Move to appendix (redundant with Figure 2)
- Missing: Flood risk map of England

### Prose Review Feedback
- Opening: Already rewritten with hook (done in prior round)
- Results: Fix remaining "Table X shows..." narration
- Background: Strong, keep
- Data section: Connect to institutional story
- Jargon: Already fixed SUTVA→Spillovers (done in prior round)

---

## Revision Strategy

### What We CAN Address (Within Scope)

**Workstream 1: Recalibrate Claims (Priority 1)**
- Rewrite abstract to remove "precisely-estimated null" framing
- Reframe as "evidence against large positive capitalization" with honest caveats
- Soften policy conclusions throughout
- Make the honest interpretation the headline: the data cannot isolate Flood Re from vintage trends

**Workstream 2: Strengthen Identification Discussion (Priority 2)**
- Add placebo-adjusted bounds as Grok suggests (main minus Very Low placebo)
- Expand HonestDiD discussion with clearer interpretation
- Add cluster dimension counts (number of districts, number of year-quarters)
- Discuss what the results do and don't tell us more carefully

**Workstream 3: Quantify Misclassification (Priority 2)**
- Estimate the share of post-2009 resales in the "eligible" group using time-series logic
- Add a brief analytical bound on attenuation factor
- Discuss GPT's point that bias direction depends on market segment correlation

**Workstream 4: First-Stage Evidence (Priority 3)**
- Add aggregate first-stage evidence from Flood Re annual reports (already partially done)
- Cite specific Flood Re cession data by risk band
- Acknowledge this is aggregate, not micro

**Workstream 5: Literature Additions (Priority 3)**
- Add Koster et al. (2021), McCoy et al. (2023), Atreya et al. (2013) if they are real papers
- Add any missing relevant literature from GPT's suggestions

**Workstream 6: Exhibit Improvements (Priority 3)**
- Fix Table 1 formatting
- Add p-values to Table 2
- Move Table 5 to appendix
- Promote appendix forest plots for heterogeneity

**Workstream 7: Prose Polish (Priority 4)**
- Fix remaining table narration in Results
- Improve Data section transition
- Ensure conclusion matches recalibrated claims

### What We CANNOT Address (Out of Scope for This Revision)

These would require fundamentally new data or redesigned methodology:
- Obtaining true construction year from EPC/VOA (data not available in pipeline)
- Repeat-sales panel construction (requires address matching infrastructure)
- RD around 2009 cutoff with true build year
- Micro first-stage with property-level premium data
- Jointly estimated event study (would require restructuring the estimation code)
- Council Tax band data (not in Land Registry PPD)
- Construction starts/completions data from planning authorities
- Historical flood risk maps by year

These are acknowledged as limitations and directions for future work.

---

## Execution Order

1. Recalibrate claims in abstract, introduction, results, discussion, conclusion
2. Add placebo-adjusted bounds and cluster counts to results
3. Add misclassification quantification section
4. Expand first-stage evidence paragraph
5. Add missing literature citations
6. Fix exhibits (tables, figure notes)
7. Final prose polish
8. Recompile and verify
