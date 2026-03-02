## Inherited from parent
- #1 ranked APEP paper (22.6 conservative, 10W-0L)
- v2 fixed code integrity (hand-edited tables → code-generated)
- Key lesson from v2: hand-editing LaTeX tables creates integrity risk — always generate from code

## Discovery
- **Revision trigger:** MAJOR REVISION from GPT and Grok; both flagged billing NPI ≠ workers as must-fix
- **Key finding:** Entity type data already exists in pipeline (hcbs_npi_month.rds has entity_type from NPPES) but was aggregated away at state×month rollup. Paper incorrectly claims it's unavailable.
- **Scope decision:** Focus on entity type decomposition (highest ROI) + RI strengthening. Skip ARPA spending analysis (data doesn't exist at needed granularity), dose-response (thin variation), COVID controls (post-treatment conditioning risk).

## Review
- **Advisor verdict:** 3 of 4 PASS (Round 2). GPT's remaining complaint was CS-DiD shouldn't show "State FE = Yes" — a presentation preference, not fatal.
- **Exhibit review:** "Very high quality." Suggested moving Figure 1 and Figure 7 to appendix (skipped — 35 pages is fine), adding Y-axis scale note to Figure 6 (done).
- **Prose review:** "Top-journal ready." Improved abstract entity type sentence per suggestion.
- **Referee decisions:** GPT=MAJOR, Grok=MINOR, Gemini=MINOR. All three flagged ARPA §9817; GPT also wanted constrained RI, sub-code heterogeneity, and restricted-window estimation.
- **Top criticism:** ARPA confounding (universal across all referee rounds, v2 and v3). Fundamentally unresolvable without data that doesn't exist.
- **What changed:** Fixed pointwise vs uniform CI overclaim, strengthened ARPA discussion with triple-diff argument, clarified differential-exposure window interpretation, sharpened entity interpretation language.
- **Key lesson:** When a confound is genuinely unresolvable (no data exists), be explicit about it but don't pretend you can fix it. The paper's existing mitigations (uniform FMAP, partisan lag, BH placebo, triple-diff) are as far as credible analysis can go.
