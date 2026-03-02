# Reviewer Response Plan — Round 1

## Summary of Reviews
- GPT-5.2: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MINOR REVISION

## Grouped Concerns and Actions

### 1. Identification / Causal Claims (All Reviewers)
**Concern:** Pre-trends violated; full-sample DiD not credible as causal.
**Action:** Already addressed transparently in v2. Soften remaining causal language; frame estimates as "informative bounds" not point estimates. Done.

### 2. Discussion Format (All Reviewers)
**Concern:** Bullet list in Discussion section is not journal-ready.
**Action:** Converted to flowing prose. Done.

### 3. Capital Effects Contradiction (GPT, Grok)
**Concern:** Text says "dramatically higher" but regression shows near-zero coefficient.
**Action:** Rewritten to clarify: descriptive evidence is strong but formal regression is uninformative due to saturation (only 3 capital districts). Done.

### 4. Missing References (GPT)
**Concern:** Missing Black (1999), Holmes (1998) for boundary design tradition.
**Action:** Added both to references.bib and cited in Introduction contributions paragraph. Done.

### 5. Causal Language Softening (GPT, Grok)
**Concern:** "0.40–0.80 range" could be read as precise causal estimates.
**Action:** Added qualifier: "under maintained assumptions of each estimator... informative bounds on a plausibly positive effect rather than precise causal point estimates." Done.

### 6. Telangana Sign Error (Gemini Advisor)
**Concern:** Text said "small positive effect" but coefficient is -0.06.
**Action:** Fixed to "near-zero effect (-0.06, p=0.32)." Done.

### Not Addressed (Acknowledged but Deferred)
- Adding 95% CIs to all tables (would require re-running R scripts with substantial table restructuring)
- Sub-district RDD figure (would require new code and exhibit)
- Border balance table (mentioned but time-prohibitive for this revision cycle)
