## Discovery
- **Policy chosen:** ACA Medicaid expansion (late expanders 2019-2024) — 7 states with staggered timing within the T-MSIS window, 10 never-treated controls. Political economy crossover (T-MSIS × FEC) is novel — no existing APEP paper does this.
- **Ideas rejected:** (1) HCBS rate shocks — near-universal treatment, no clean controls; (2) Medicaid unwinding — only 1 post-treatment election cycle; (3) Open Payments triple-linkage — no clean quasi-experiment; (4) State legislative donations — fragmented data across 50 states.
- **Data source:** T-MSIS (local Parquet, 227M rows) × NPPES (CMS bulk) × FEC bulk Schedule A (S3 downloads, 2018-2024). All worked after fixing FEC CCL column indices (column 4 not 2 for committee_id).
- **Key risk:** Few treated clusters (7 expansion states) proved to be the fundamental limitation. RI p=0.342 despite TWFE p<0.01.

### Critical bugs encountered
1. **data.table column shadowing:** Column `never_expanded` shadowed the external character vector → 0 control states in panel. Fix: rename to `is_never_expanded`.
2. **FEC CCL format:** Committee ID is column 4, not column 2. Column 2 is CAND_ELECTION_YR (integer), causing type mismatch on join.
3. **fixest pvalue masking:** `scales::pvalue()` masks `fixest::pvalue()`. Must use explicit `fixest::pvalue()`.
4. **Logical coefficient names:** fixest produces `post_expansionTRUE:medicaid_share` not `post_expansion:medicaid_share`. Use `grep()` matching everywhere.

### Text-results alignment
Paper was written ex ante. After running all code, comprehensive rewrite required: abstract, intro, results, mechanism, robustness, discussion, conclusion all updated to match actual results. Key finding: TWFE DDD significant (0.0037***) but RI (p=0.342) and CS-DiD (ATT=0.0014, n.s.) do not confirm. Honest reporting of this tension.

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT, Grok, Codex) after 12 rounds
- **Top criticism:** Cycle-level aggregation creates partial pre/post contamination for Idaho/Nebraska (2020 cycle = 2019+2020) and SD (2024 cycle = 2023+2024). Fixed by adding explicit Threats to Validity paragraph arguing attenuation bias (toward zero).
- **Surprise feedback:** Codex initially flagged TWFE as inappropriate for staggered DiD, not recognizing that DDD interaction mitigates negative-weighting. Fixed with detailed code comment. Also: FEC 2018 cycle covers 2017-2018 but T-MSIS starts 2018 — needed explicit data alignment discussion.
- **What changed:** (1) Added cycle contamination paragraph with attenuation bias argument; (2) Added event study scope clarification (within-expansion-state only, cross-state from Figure 1); (3) Added fixest singleton-removal footnotes for all N discrepancies; (4) Clarified FEC/T-MSIS 2018 cycle alignment; (5) Fixed abstract provider counts and linking universe description; (6) Filled Table 1 Panel B; (7) Dropped Social/Behavioral column from Table 4; (8) Cleaned all table labels.
- **Key lesson:** LLM advisors are stochastic — different models flag different issues each round. Gemini was the hardest to satisfy (persistent false positives on math that was actually consistent). The cycle contamination issue was the most legitimate structural concern.

## Summary
- **Final verdict:** 3/4 advisors PASS, all 3 referees MAJOR REVISION
- **Core limitation:** 7 treated states insufficient for credible inference. RI p=0.342 undercuts TWFE significance. This is an honest paper about a suggestive finding.
- **Data contribution:** T-MSIS × NPPES × FEC linkage is genuinely novel and enables future research.
- **Key methodological lesson:** In DDD with few treatment clusters, present RI as primary inference from the start. Don't lead with TWFE significance that RI will contradict.
- **Process lesson:** 12 advisor rounds before PASS. Most productive fix was addressing cycle contamination and FEC/T-MSIS timing alignment explicitly. Codex flagged TWFE-for-staggered, which was resolved by explaining DDD interaction mitigates negative weighting.
- **Tournament prediction:** Will likely rank below papers with cleaner identification and more statistical power. The data construction novelty may provide some tournament value.
