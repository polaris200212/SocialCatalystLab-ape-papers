# Reply to Reviewers — Round 1

**Paper:** apep_0418 — Where the Sun Don't Shine: The Null Effect of IRA Energy Community Bonus Credits on Clean Energy Investment
**Date:** 2026-02-19

---

## Reviewer 1 (GPT-5.2) — MAJOR REVISION

### Concern 1: Treatment definition relies on proxy rather than exact statutory designation
**Response:** Added a dedicated "Treatment proxy" paragraph in Section 4.3 (Threats to Validity) explaining that the running variable uses 2021 CBP data and ACS unemployment rather than the statutory "any time after 2009" and BLS LAUS criteria. This is acknowledged as a limitation — the treatment is a proxy for Treasury's determination, not an exact replication. The proxy creates potential misclassification at the margin, which would attenuate estimates toward zero, making the significant covariate-adjusted result conservative.

### Concern 2: Sign-test argument invalid with correlated bandwidth estimates
**Response:** Agreed. Removed the formal "1/64" sign-test argument from both the bandwidth sensitivity discussion and the conclusion. Replaced with honest acknowledgment that bandwidth sensitivity estimates are mechanically correlated through overlapping samples, while noting the consistent negative sign across specifications.

### Concern 3: Timing — 2023 data may be too early for effects
**Response:** This limitation was already discussed in the paper. Added a pre-IRA placebo test (new) showing that the negative discontinuity in clean energy capacity predates the IRA (estimate: -33.93 MW per 1,000 employees, p=0.030), confirming the pattern reflects long-standing geographic disadvantages rather than policy failure alone.

### Concern 4: Confidence intervals needed for null result interpretation
**Response:** Added 95% confidence intervals to Table 2 using robust bias-corrected inference from rdrobust.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### Concern 1: Missing canonical RDD citations
**Response:** Added Lee & Lemieux (2010), Imbens & Lemieux (2008), and Cattaneo et al. (2019) to references.bib and cited in the methodology section.

### Concern 2: Formal power analysis needed
**Response:** Added MDE calculation using the rdpower package (Cattaneo et al. 2019). The MDE at 80% power is approximately 12 MW per 1,000 employees — more than 14 times the outcome mean. This confirms the design is severely underpowered for detecting realistic effects, which is honestly reported in the "Statistical Power and Limitations" section.

### Concern 3: Pre-IRA placebo test
**Response:** Implemented. The RDD on pre-IRA clean energy capacity (generators with operating years before 2023) yields a significant negative estimate (-33.93, p=0.030), confirming the pre-existing negative relationship between fossil fuel employment and clean energy investment.

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Concern 1: Coefficient magnitude relative to outcome mean
**Response:** A footnote explaining the local vs. global nature of the RD estimate was already added in a prior round. The coefficient reflects extrapolation at the boundary of the bandwidth where few observations exist, not a global effect.

### Concern 2: Add confidence intervals
**Response:** Added 95% CIs to Table 2 (see Reviewer 1, Concern 4).

---

## Summary of Changes Made

| Change | Files Modified |
|--------|---------------|
| Added 95% CIs to Table 2 | `06_tables.R`, `paper.tex` |
| Removed sign-test argument | `paper.tex` (2 locations) |
| Pre-IRA placebo test | `04_robustness.R`, `06_tables.R`, `paper.tex` |
| MDE power analysis | `04_robustness.R`, `paper.tex` |
| Added 3 citations | `references.bib`, `paper.tex` |
| Pre-IRA placebo in appendix table | `06_tables.R` |

All R scripts (04-06) re-run. PDF recompiled with full LaTeX + BibTeX sequence.
