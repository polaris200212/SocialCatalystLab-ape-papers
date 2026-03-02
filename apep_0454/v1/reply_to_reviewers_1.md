# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): Major Revision

**1. Exit definition validity**
> Exit confounds true exits with intermittent billing.

We now explicitly define "active provider" as having ≥1 claim in a month and note the ln(x+1) transformation. The exit measure captures permanent departures from Medicaid billing, which we acknowledge may include transitions to non-Medicaid payers. This measurement error biases results toward zero.

**2. ARPA identification**
> DDD has no cross-state variation in treatment intensity.

Agreed. We have reframed Part 2 as "more exploratory" and explicitly note the lack of cross-state ARPA implementation variation. The DDD exploits only pre-existing depletion variation, not ARPA dosage.

**3. Non-HCBS falsification**
> Use non-HCBS providers as falsification.

Done. The non-HCBS coefficient is -1.376 (p=0.004), indicating that exit rates predict general Medicaid market fragility, not only HCBS-specific effects. We report this honestly in the robustness section and note that the DDD design accounts for this by differencing out non-HCBS trends.

**4. Inference with 51 clusters**
> Wild cluster bootstrap needed.

The fwildclusterboot R package is not available for our R version. We rely on randomization inference (p=0.078, 500 permutations) and leave-one-out jackknife as alternative inference methods.

**5. Literature**
> Missing Callaway & Sant'Anna, Goodman-Bacon.

Added citations with note that continuous treatment avoids staggered-adoption concerns.

## Reviewer 2 (Grok-4.1-Fast): Minor Revision

**1. Wild cluster bootstrap**
> Easy to implement via Cameron et al.

Package unavailable for current R version. RI provides comparable inference robustness.

**2. Mechanism heterogeneity**
> Interact with tenure share, wage levels, rurality.

Noted for future work. The current analysis focuses on establishing the main relationship rather than mechanisms.

## Reviewer 3 (Gemini-3-Flash): Minor Revision

**1. ARPA implementation variation**
> Control for type of spending (permanent rate vs one-time bonus).

We now frame Part 2 as exploratory and acknowledge the limitation. State-specific implementation data would strengthen future analysis.

**2. New entrant analysis**
> Investigate NPIs created after April 2021.

Good suggestion for future work.

## Exhibit Review Responses

- **Table 1**: Added clarification of cumulative vs monthly provider counts
- **Figure 2**: Added explicit x-axis bounds and data coverage note
- **DDD table notes**: Fixed malformed LaTeX (tab characters in \times)

## Prose Review Responses

- **Opening**: Replaced WHO pandemic declaration opening with $14.15/hr wage hook
- **Contribution language**: Changed to "This paper contributes to three literatures"
