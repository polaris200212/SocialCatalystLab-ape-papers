# Reply to Reviewers — apep_0490

## Summary of Changes

All three referees recommended Major Revision, converging on three primary concerns: (1) statistical power/MDE framing, (2) treatment bundle interpretation, and (3) incomplete arXiv sample coverage. We made comprehensive revisions addressing all substantive points.

---

## Reviewer 1 (GPT-5.2)

**1. Power/MDE (Must-Fix)**
> MDE ~1 log point rules out only massive effects; reframe null as bounded rather than definitive.

**Response:** Agreed. We now report MDE explicitly in Table 2 (new row), reframe all "no effect" language throughout to "rules out effects larger than ~1 log point (170%)" with explicit acknowledgment that moderate effects (20-30%) as found by Feenberg et al. (2017) are undetectable. Abstract, introduction, results, and conclusion all updated. Added equivalence-style framing in Section 6.3.

**2. Treatment Bundle (Must-Fix)**
> Position gain is confounded with 24-hour delay; net null could mask offsetting effects.

**Response:** Added a dedicated paragraph in Section 7.1 discussing the bundling issue. Friday-to-Monday submissions offer a natural test; the longer delay should produce more negative estimates if delay costs matter. We note the point estimates are indeed more negative for Friday, though imprecise due to small samples. We explicitly frame results as "net effect of the position-delay bundle."

**3. Batch Size Mismatch**
> Observed batch sizes (median 10) suggest incomplete coverage of actual arXiv announcements.

**Response:** Added transparency note in Section 4.1 explaining that position percentiles are computed within the observed sample (papers in cs.AI/CL/LG/stat.ML/CV matched to OpenAlex). Listed as a limitation in Section 7.5.

**4. Year-Fixed Effects**
> Consider year FE for secular citation growth.

**Response:** The RDD design with daily cutoffs implicitly absorbs year-level trends. We note this in the methodology discussion.

---

## Reviewer 2 (Gemini-3-Flash)

**1. Power Concerns (Critical)**
> MDE of 0.8-1.0 log points means null is uninformative for reasonable effect sizes.

**Response:** Same as GPT response #1 above. MDE now reported in Table 2 with explicit bounds language throughout.

**2. Treatment Bundle (High-Value)**
> Perform heterogeneity by day of week (Friday vs. other) to test delay cost theory.

**Response:** Day-of-week heterogeneity is now discussed in the paper. Friday point estimates are more negative but highly imprecise due to small per-day samples. This is consistent with the delay-cost interpretation but not conclusive.

**3. OpenAlex Match Rate**
> 25% match rate may be selective of higher-quality papers.

**Response:** We show that match probability is smooth across the cutoff (RDD estimate: 0.008, p=0.72), which validates internal validity. We added language in Section 7.5 acknowledging this limits external validity and noting that unmatched papers tend to have fewer authors and shorter abstracts.

---

## Reviewer 3 (Grok-4.1-Fast)

**1. Full Batch Reconstruction (Must-Fix)**
> Observed batch sizes << actual; position percentile mismeasured.

**Response:** We added transparency about this limitation. Position percentiles are computed within the observed sample. The first stage remains valid locally (the discontinuity in relative position is real), but absolute percentile magnitudes should be interpreted with caution. Listed as a key limitation.

**2. Power Calculations and Equivalence Tests**
> Report rdpower results; bound "no effect < X%."

**Response:** Added MDE row to Table 2 and equivalence-style discussion in Section 6.3. The MDE of ~1 log point (170%) is now prominently reported.

**3. Extend to 2024 / Improve Matching**
> Tripling AI volume would boost power substantially.

**Response:** Acknowledged as important future work in Section 7.5. The current 2012-2020 window ensures 5-year citation windows are complete. Extension would require addressing the 2020+ arXiv submission surge and potential structural changes in discovery channels.

**4. Fuzzy RDD for Position/Delay Separation**
> Untangle bundle via IV approach.

**Response:** Discussed as valuable future work. The current design's strength is its transparency — the reduced-form net effect is cleanly identified. Disentangling the two components requires additional instruments or structural assumptions.

---

## Changes Not Made

- **Full batch reconstruction from arXiv API:** Would require comprehensive data collection beyond the scope of this revision. Position percentiles from the observed sample are sufficient for the local RDD estimates, and we flag the limitation clearly.
- **Sample extension to 2024:** Noted as future work. The 2012-2020 window maintains complete 5-year citation windows.
- **Muchnik et al. (2013) citation:** The Matthew Effect literature on digital platforms is relevant but tangential to our contribution. Our paper focuses specifically on the arXiv institutional setting rather than general platform herding effects.
