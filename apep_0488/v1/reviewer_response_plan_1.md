# Stage C Revision Plan

## Consensus Issues (All 3 Reviewers)

### 1. λ = 0.70 Unvalidated for Sample
**Fix:** Reframe λ as a range [0.50, 0.80] rather than point estimate. Add post-2015 evidence (Dave 2021, Horwitz 2021) suggesting λ may be lower in later periods. Add (β, λ) welfare heatmap discussion. Expand sensitivity analysis text.

### 2. Administrative Costs C'(τ) Omitted
**Fix:** Calibrate C'(τ) at $2–5 per prescription (PDMP query time cost: 3–5 min × physician hourly rate). Show how β* shifts when C'(τ) > 0. Add to welfare table notes.

### 3. Medicare Scope / External Validity
**Fix:** Add explicit subsection discussing how parameters differ for under-65 population (higher addiction risk → lower λ, lower v_L, lower β). Show directional effect on β*.

### 4. Mortality Uses TWFE Not CS-DiD
**Fix:** Add footnote/text acknowledging TWFE is used for mortality for comparability with existing literature and because CDC data suppression makes CS-DiD estimation unreliable for small-count states. Note the qualitative null is robust.

## Individual Reviewer Concerns

### GPT: Outcome-to-Welfare Unit Mapping
**Fix:** Add explicit paragraph mapping opioid prescribing rate (share) to welfare (per prevented Rx). The welfare formula uses the level reduction, not the share. Clarify.

### Gemini: Substitution to Illicit Opioids
**Fix:** Add paragraph in Discussion about how substitution to illicit opioids could increase externality e, partially offsetting welfare gains. The positive (insignificant) mortality point estimate is consistent with this channel.

### Grok: Exact Calibration Sources
**Fix:** Add calibration source table in Appendix C with exact mapping from parameter to source.

## Prose Improvements (Prose Review)

1. Replace opening sentences with vivid hook
2. Active voice in Results section
3. Kill throat-clearing phrases
4. Data section: describe through lens of research question

## Exhibit Improvements (Exhibit Review)

1. Move LOO figure (Fig 6) to appendix
2. Note: consolidating event studies would require regenerating figures; defer to text mention
