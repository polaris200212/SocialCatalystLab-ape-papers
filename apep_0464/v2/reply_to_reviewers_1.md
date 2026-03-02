# Reply to Reviewers — apep_0464 v2

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### Must-Fix Issues Addressed

**1. SCI 2024 vintage (post-treatment network measurement)**
- *Concern:* Network matrix measured post-treatment may be endogenous.
- *Response:* Added explicit limitation discussion in Appendix (Identification section). Three mitigating arguments: (a) Bailey et al. (2018) show SCI is highly stable, driven by long-standing ties; (b) pre-treatment event study coefficients near zero would be unlikely if 2024 SCI captured post-2014 sorting; (c) Facebook penetration >50% by 2012 (pre-treatment). Acknowledged as limitation; future work should exploit earlier vintages.

**2. Event study should include Own × event-time**
- *Concern:* Event study equation showed only Net × event-time.
- *Response:* Updated Equation (9) to include both Own × event-time and Net × event-time, matching the actual estimation. Figure 3 already shows both panels.

**3. Effective sample size / Moulton problem**
- *Concern:* Treatment varies at département level, not commune level.
- *Response:* Added explicit "Effective sample size" paragraph in Section 5.1 noting that identifying variation is at 96 depts × 10 elections = 960 cells. Point to dept-level regressions (Table 3) and inference comparison (Table 6) as complementary evidence at the appropriate level.

**4. Structural counterfactuals over-claimed**
- *Concern:* SAR/SEM observational equivalence means counterfactuals are not identified as causal.
- *Response:* Completely reframed Section 7.3 counterfactuals as "upper bounds under the SAR interpretation." Added explicit caveat that under SEM interpretation, the network contribution would be smaller. Presented the 11pp counterfactual as a range (0 under pure SEM to 11 under pure SAR).

**5. Joint pre-trend test**
- *Concern:* No formal test of pre-treatment coefficients = 0.
- *Response:* Added statement in Appendix that joint F-test fails to reject (p > 0.10).

### Issues Noted but Not Addressable in This Revision
- Adão, Kolesár, and Morales (2019) shift-share robust SEs: Requires new R package implementation. The paper reports four alternative inference methods including block RI which is arguably more appropriate for this design.
- Distance-bin decomposition: Good suggestion for future work; the 200km restriction test provides a single cutoff test.
- Survey/attitudinal data: Beyond scope of current data infrastructure.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Must-Fix Issues Addressed

**1. WCB discrepancy resolution**
- *Concern:* p=0.377 undermines inference validity.
- *Response:* Extensive discussion already in paper (pp. 22-23). Added explicit note that same WCB code produces p=0.015 for own-exposure (ruling out code error). Explained that low between-cluster variation (SD=0.02 raw) reduces WCB power. Three of four inference methods support significance.

**2. Spatial models on N=96**
- *Concern:* Low power with tiny N.
- *Response:* Acknowledged in text that structural results are secondary to reduced-form evidence. Added N=96 to Table 4 as requested. Reframed counterfactuals as upper bounds.

### High-Value Improvements Addressed

**3. Joint pre-trends test**
- Added formal statement (p > 0.10) in Appendix.

**4. Shift exogeneity p=0.108**
- *Concern:* Borderline result.
- *Response:* Already discussed in Appendix with Rotemberg weights. The borderline p-value warrants caution but does not reject exogeneity at conventional levels.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Must-Fix Issues Addressed

**1. WCB inference**
- *Response:* See Reviewer 2, item 1 above. Added code-verification argument.

**2. SCI vintage**
- *Response:* See Reviewer 1, item 1 above. Added explicit limitation discussion with three mitigating arguments.

### High-Value Improvements Addressed

**3. Multiplier magnitude calibration**
- *Concern:* 22.2 and 2.4 multipliers are very large.
- *Response:* Expanded explanation distinguishing scalar (22.2, theoretical) from nationally-weighted (2.4, empirical) multipliers. Added that the factor-of-nine gap is a direct consequence of network heterogeneity, not a calculation error.

**4. Counterfactual framing**
- *Response:* See Reviewer 1, item 4. Reframed as upper bounds.

---

## Summary of Changes

| Issue | Status |
|-------|--------|
| SCI vintage limitation | **Addressed** — explicit discussion added |
| Event study equation | **Addressed** — includes both Own and Net interactions |
| Effective N / Moulton | **Addressed** — paragraph added to Section 5.1 |
| Counterfactual framing | **Addressed** — reframed as upper bounds |
| Joint pre-trend test | **Addressed** — formal test reported |
| WCB discussion | **Addressed** — code verification argument added |
| Spatial table N | **Addressed** — N=96 added |
| "All three referees" meta-language | **Addressed** — removed |
| AKM (2019) shift-share SEs | Not addressed (future work) |
| Distance-bin decomposition | Not addressed (future work) |
| Survey/attitudinal mechanism data | Not addressed (beyond data scope) |
| Facebook penetration heterogeneity | Not addressed (future work) |
