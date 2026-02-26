# Reply to Reviewers — Round 2 (External Referee Panel)

## Cross-Cutting Issues

### 1. Running Variable Timing (GPT §1.1, Grok §1, Gemini §1)
All three reviewers raise the use of current (rather than pre-2012) second-home shares as the running variable. We acknowledge this as the paper's primary limitation. Pre-2012 municipality-level ZWA data are not publicly available in digital form. We have:
- Strengthened the Threats to Validity discussion with explicit acknowledgment of bias ambiguity (measurement error in the running variable typically attenuates discontinuities)
- Added the 99.2% definitive ARE status finding
- Softened causal claims throughout (abstract, discussion, conclusion)
- Framed the paper's results as "reduced form without first stage"

### 2. No First-Stage Evidence (GPT §3.2, Grok §1, Gemini §3)
All three reviewers request municipal-level evidence that the ban reduced construction activity at the threshold. Municipal-level building permits by dwelling type are not available from BFS. We have:
- Added explicit "first stage" framing in the Discussion opening, acknowledging the null could reflect weak treatment bite
- Strengthened the cantonal mechanism discussion
- Noted this as a priority for future work with administrative data access

### 3. Small Treated N (GPT §2.2, Grok §2, Gemini §2)
We have added leave-one-out jackknife analysis showing the estimate is stable (range: [-0.060, 0.030], SD = 0.007). No single municipality drives the null.

## Reviewer-Specific Responses

### GPT-5.2
1. **Post-treatment running variable (§1.1)**: Addressed in cross-cutting section. We acknowledge bias direction is ambiguous and soften claims accordingly.
2. **Density test p=0.043 (§1.2)**: Already addressed via donut-hole specifications. Added institutional detail on 99.2% definitive status.
3. **Timing and outcome construction (§1.3)**: The pre/post collapse is a deliberate design choice for a cross-sectional RDD. Panel exploitation would require pre-treatment running variable (unavailable).
4. **Spillovers (§1.4)**: Added explicit acknowledgment that RDD controls are the most likely spillover recipients, biasing toward zero.
5. **Small treated N (§2.2)**: Added leave-one-out jackknife analysis.
6. **Power and null interpretation (§2.3)**: Softened log employment claims in abstract and conclusion. Employment growth remains the primary estimand.
7. **Multiple outcomes (§2.4)**: Revised to clarify primary vs. secondary estimands.
8. **First stage (§3.2)**: Addressed in cross-cutting section.
9. **Literature positioning (§4)**: Already positioned relative to Hilber (2019), Hsieh & Moretti (2019), and place-based literature.

### Grok-4.1-Fast
1. **Running variable post-policy (§1)**: Addressed in cross-cutting section.
2. **First-stage evidence (§1)**: Addressed in cross-cutting section.
3. **McCrary p=0.043 (§1)**: Addressed via donut-hole and institutional detail.
4. **Spillover test (§6.2)**: Added discussion of bias toward zero. Spatial aggregation left for future work.
5. **Heterogeneity (§6.2)**: Appendix includes geographic and size heterogeneity.
6. **Literature additions (§6.3)**: Noted for future revision.

### Gemini-3-Flash
1. **First-Stage Evidence (§6 must-fix)**: Addressed in cross-cutting section.
2. **N and Power (§6 must-fix)**: Added jackknife analysis; power discussion already in paper.
3. **Spatial spillovers (§6 high-value)**: Added bias-toward-zero discussion.
4. **Running variable snapshot (§6 high-value)**: Acknowledged as limitation; pre-2012 data unavailable.
5. **Hilber and Schöni (2020) (§4)**: Already cited as Hilber (2019) — will verify specific citation in future revision.

## Changes Made
1. Abstract: Softened claims, added specific estimates, noted "reduced-form" framing
2. Threats to Validity: Revised multiple outcomes paragraph
3. Discussion opening: Added first-stage caveat and alternative explanation (weak bite)
4. Spillovers section: Added bias-toward-zero acknowledgment
5. Conclusion: Added two-caveat paragraph (running variable, first stage)
6. Robustness: Added leave-one-out jackknife analysis (Section 6.6)
7. Code: Added jackknife to 04_robustness.R
