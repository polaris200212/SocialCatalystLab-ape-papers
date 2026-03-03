# Reply to Reviewers

## Reviewer 1 (GPT-5.2) — Major Revision

### Power and MDE
> The effective N is ~86 with only 14 Tier-1 events. MDEs of 0.073 on base rate 0.053 mean you can only detect effects >140% of baseline.

We have added explicit MDE discussion to the abstract, introduction, and data section. The abstract now states: "with a baseline adoption rate of 5%, the design can only detect effects exceeding 140% of the baseline." We agree this is a significant limitation and have framed the null accordingly.

### Compound Treatment
> Title/abstract claim "visibility delay" but design identifies position + delay bundle.

We have changed the title to "Listing Position, Announcement Delay, and Frontier AI Adoption" and reframed the introduction to explicitly acknowledge the compound treatment throughout.

### Cox Censoring
> Right-censoring at 1,095 days is impossible for 2023-2024 papers.

Fixed. All censoring is now min(1,095 days, days to data end). Updated in text, table notes, and outcome definitions.

### Missing Tables
> Placebo cutoffs, polynomial/kernel sensitivity, and day-of-week splits lack tables.

Added Appendix Tables A1 (placebo), A2 (day-of-week), and A3 (polynomial × kernel).

## Reviewer 2 (Grok-4.1-Fast) — Minor Revision

### Power Transparency
> Front-load power warnings in Abstract/Intro/Conclusion.

Done. MDE is now discussed in abstract, introduction, data section, and conclusion.

### Match Rate Concerns
> 40% match rate is concerning.

Added data flow description with explicit attrition from 50,000 → 1,845 → 289 → 86.

## Reviewer 3 (Gemini-3-Flash) — Major Revision

### Sample Size
> N=86 with 5% base rate is severely underpowered.

Acknowledged throughout with MDE analysis. This is a limitation of the design that cannot be resolved without expanding the dataset.

### Outcome Definitions
> "Any frontier citation" is right-censored, not "any horizon."

Renamed to "Any Frontier Citation (by 2026)" with explicit censoring note throughout.

## Exhibit Review (Gemini-3-Flash)

### Figure 1 text box
> Transform into visual timeline.

Not addressed (would require new figure generation).

### Table alignment
> Use decimal alignment.

Noted for future versions.

## Prose Review (Gemini-3-Flash)

### Opening sentence
> Replace cliché with concrete example.

Done. New opening: "Every weekday at 14:00 ET, the pace of global AI research is decided by a timestamp."

### Null result framing
> Be more assertive about what the null means.

Done. Results and conclusion now frame the null as substantive finding about frontier lab discovery infrastructure.
