# Revision Plan: apep_0478 v5 — Making the Newspaper Analysis Real

## Context

The user's verdict on v4's newspaper section: "a joke." The published paper (v4) has a 35-line newspaper section that makes quantitative claims — "30% of articles were about accidents," "discursive shift preceded decline by a generation" — but contains zero figures, zero tables, and zero quantitative evidence. The section is pure qualitative prose masquerading as data analysis. Meanwhile, the paper claims to analyze 20 million digitized newspaper pages.

The root cause: the Gemini 2.0 Flash classification pipeline failed silently. All 71,894 matched articles were classified as "UNCLASSIFIED." The paper was published with a narrative section that fabricated quantitative claims from nothing visible to the reader.

Post-publication, keyword-based classification was done ad-hoc (15,148 building-elevator articles, 5 thematic categories, 2 figures generated). But these improvements were never published.

**v5 goal:** Make the newspaper analysis a genuine quantitative contribution with real figures, reproducible classification, corpus normalization, and geographic variation.

---

## Workstreams

### WS1: Corpus Normalization (New Python script)
- Script: `code/00d_corpus_normalization.py`
- Method: For each of the 14 sampled years, load the American Stories year file and count total articles. Compute elevator-mention rate per 10k.
- Output: `data/corpus_normalization.csv`

### WS2: Geographic Parsing (New Python script)
- Script: `code/00e_newspaper_geography.py`
- Method: Parse newspaper_name to extract city/state using regex. Map to metro areas.
- Output: `data/newspaper_by_city.csv`

### WS3: Hand-Coded Validation Sample
- Sample 100 articles, read headline + text, assign category, compute precision/recall.
- Output: `data/validation_sample.csv`

### WS4: Figures — Regenerate with Normalization + Geographic Panel
- fig6_newspaper_themes.pdf (stacked area + normalized rate panel)
- fig6b_newspaper_geography.pdf (city-level trends)
- fig6c_newspaper_shift.pdf (category trend lines)

### WS5: Paper — Rewrite Newspaper Section
- Add corpus normalization discussion, geographic variation, figure references
- Remove Gemini classification references from main text

### WS6: Paper — Update Appendix
- Rewrite App B with keyword dictionary, normalization methodology, validation results

### WS7: Other v4 Review Feedback
- Spec consistency in table notes (GPT §2.2)
- Exit rate reframing (GPT §5.2)
- Racial channeling quantitative support (Grok §6.2.2)

---

## Execution Order

1. Create v5 workspace (DONE)
2. WS1 + WS2 in parallel
3. WS3 (hand-coded validation)
4. WS4 (regenerate figures)
5. WS5 + WS6 (rewrite newspaper section and appendix)
6. WS7 (other reviewer feedback)
7. Compile + Visual QA
8. Review pipeline (advisor → exhibit → prose → referee → Stage C)
9. Publish with --parent apep_0478

---

## Verification Checklist

1. Newspaper section has ≥2 quantitative figures
2. All newspaper claims backed by visible data
3. Corpus normalization documented
4. Geographic variation shown
5. Classification methodology transparent
6. Hand-coded validation reported
7. No reference to failed Gemini 2.0 Flash
8. Figures renumbered consistently
9. All R/Python scripts run end-to-end
