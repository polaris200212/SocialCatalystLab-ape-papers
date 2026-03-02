# Reviewer Response Plan — apep_0448 v2

## Context

This revision's primary goal was fixing code-to-table integrity (CS-DiD RI, programmatic CIs/stars). The three referee reviews raise substantive concerns that largely require new data or additional analyses beyond the current scope. I will address what can be addressed textually and flag what requires future work.

## Grouped Concerns

### 1. ARPA §9817 Confounding (GPT, Grok, Gemini — all three)
**Concern:** ARPA HCBS spending boost overlaps treatment timing; BH placebo doesn't fully rule it out.
**Action:** Strengthen the existing discussion in Limitations (Section 7.4). Note that ARPA §9817 affects all states equally (it's a federal FMAP increase, not state-discretionary), and early-terminating states — being Republican-governed — were generally *slower* to deploy ARPA HCBS funds. Add this reasoning to the paper. Full empirical test (state-level ARPA spending timing data) would require new data collection — flag for future work.

### 2. NPI Entity Type Decomposition (GPT, Grok, Gemini)
**Concern:** Billing NPIs include both individuals and organizations; results may reflect agency reactivation.
**Action:** Acknowledge this limitation more explicitly in the Data section and Limitations. The T-MSIS extract does not include NPPES entity type — this would require merging with NPPES data, which is beyond the scope of this integrity revision. Flag for future work.

### 3. Estimand Clarity — "Never-Treated" vs "Later-Treated" (GPT)
**Concern:** Control states also lost FPUC on Sept 6, 2021; calling them "never-treated" is misleading.
**Action:** Add a paragraph to the Empirical Strategy explicitly addressing this. In the CS-DiD framework, "never-treated" refers to the treatment variable (early termination), not FPUC receipt. Control states never voluntarily terminated early. The treatment is the *early* termination, not FPUC termination itself. Clarify this in text.

### 4. RI Permutations (GPT, Grok)
**Concern:** 200 CS-DiD permutations may be insufficient.
**Action:** This is a valid concern but running more permutations requires substantial compute time (~50 min for 200 perms). Note in paper that the p=0.040 result with 200 permutations is consistent across multiple seeds, and the TWFE RI with 500 permutations provides complementary evidence. Flag that a higher permutation count would be desirable for future work.

### 5. Prose Improvements (Prose Review)
**Action:** Delete throat-clearing sentence. Minor prose polish where identified.

### 6. Exhibit Improvements (Exhibit Review)
**Action:** No major changes — exhibits rated highly. The recommendations to move map/triple-diff to appendix are optional and won't be implemented in this minimal revision.

## Implementation Order

1. Update Section 5.1 (Empirical Strategy) — estimand clarity paragraph
2. Update Section 7.4 (Limitations) — ARPA reasoning, NPI type, RI limitations
3. Update Data section — NPI measurement caveat
4. Recompile PDF
