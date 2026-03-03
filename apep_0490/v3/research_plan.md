# Initial Research Plan: The Price of Position

## Research Question

Does the quasi-random visibility boost from arXiv's daily listing position causally affect the diffusion of AI research — including citations, top-venue publication, and adoption by industry research labs?

## Identification Strategy

**Design:** Sharp RDD at arXiv's 14:00 ET (18:00 UTC) daily submission cutoff.

**Running variable:** Minutes from the cutoff (centered at 0). Negative values = submitted before cutoff (→ last in today's announcement batch). Positive values = submitted after cutoff (→ first in tomorrow's announcement batch).

**Treatment:** At the cutoff, listing position jumps discontinuously from approximately the last position in today's batch to the first position in tomorrow's batch — a swing from ~80th percentile to ~1st percentile of within-batch position. This is accompanied by a ~24-hour delay in announcement timing.

**Local randomization argument:** Within a narrow bandwidth (±15-60 minutes), the exact second a researcher clicks "submit" depends on idiosyncratic factors — network latency, file preparation time, meeting schedules, timezone confusion — that are plausibly uncorrelated with paper quality. The cutoff itself is sharp and publicly known, so the key assumption is that researchers cannot precisely control their submission second.

## Expected Effects and Mechanisms

1. **First stage (position):** Papers submitted just after the cutoff receive positions 1-5 in the next announcement. Papers just before receive positions 40-80+ (last in the current announcement). Expected F-stat > 100.

2. **Short-run attention:** First-listed papers receive more immediate visibility (clicks, reads). Based on Haque & Ginsparg (2009), the visibility premium in physics is ~44-100%. We expect a similar or larger premium in CS/AI given larger readership.

3. **Citation accumulation:** Through preferential attachment / Matthew effect, early visibility compounds into higher long-run citations. Expected effect: 15-40% citation premium at 3-5 years, with the position advantage partly offset by the 24-hour announcement delay.

4. **Top-venue publication:** Higher visibility → more feedback → better revisions → higher acceptance rate at NeurIPS, ICML, ICLR, AAAI, ACL.

5. **Industry adoption:** First-listed papers are more likely to be cited by researchers at Google, Meta, OpenAI, DeepMind, Microsoft Research — indicating adoption of ideas/methods by leading AI companies.

6. **Topic diffusion (mechanism extension):** If a paper introducing a novel method (e.g., a new attention mechanism) gets first-listed, does that method diffuse faster? Measured via keyword/topic propagation in subsequent submissions.

## Primary Specification

**Reduced-form RDD:**
$$Y_i = \alpha + \tau \cdot \mathbb{1}[T_i > 0] + f(T_i) + \epsilon_i$$

where $Y_i$ is the outcome (citations, industry citations, etc.), $T_i$ is minutes from cutoff, $f(\cdot)$ is a local polynomial, and $\tau$ is the causal effect of crossing the cutoff.

**Implementation:** `rdrobust` with MSE-optimal bandwidth selection, triangular kernel, robust bias-corrected confidence intervals. Complement with conventional and undersmoothed bandwidths.

**Sample:** cs.AI, cs.CL, cs.LG, stat.ML papers submitted 2012-2020 (allowing 3-5 years of citation accumulation through 2025).

## Planned Robustness Checks

1. **McCrary density test** (`rddensity`): Test for bunching at the cutoff
2. **Donut RDD:** Exclude papers within ±2, ±5, ±10 minutes of cutoff
3. **Covariate balance:** Test smoothness of author h-index, number of authors, abstract length, cross-listing count, author affiliation prestige
4. **Bandwidth sensitivity:** Report results for 50%, 100%, 150%, 200% of MSE-optimal bandwidth
5. **Placebo cutoffs:** Run RDD at fake cutoff times (12:00, 13:00, 15:00, 16:00 ET)
6. **Placebo categories:** Math subfields where listing order is less salient
7. **Day-of-week heterogeneity:** Thursday submissions (3-day weekend front page) vs. weekday
8. **Conference deadline exclusion:** Drop weeks around major ML conference deadlines (NeurIPS, ICML, ICLR)
9. **Local polynomial order:** Linear, quadratic, cubic
10. **Alternative kernels:** Triangular, Epanechnikov, uniform

## Data Pipeline

1. **arXiv metadata:** Bulk download from Kaggle (arxiv-metadata-oai-snapshot.json, ~4GB) containing exact version timestamps for 2.4M papers
2. **OpenAlex:** Query via `openalexR` R package for citation counts (total + by year), author affiliations, institutional data, venue information
3. **Industry classification:** Tag citing papers where any author is affiliated with: Google/DeepMind, Meta/FAIR, OpenAI, Microsoft Research, Amazon Science, Apple MLR, Anthropic, NVIDIA Research, Baidu Research, Tencent AI Lab
4. **Author careers:** Track h-index evolution, affiliation changes, and publication quality over time using OpenAlex author endpoints

## Code Structure

- `00_packages.R` — Libraries and configuration
- `01_fetch_data.R` — Download arXiv metadata + query OpenAlex API
- `02_clean_data.R` — Parse timestamps, compute running variable, merge datasets
- `03_main_analysis.R` — RDD estimation (rdrobust), first stage, reduced form
- `04_robustness.R` — Density tests, donut RDD, placebos, bandwidth sensitivity
- `05_figures.R` — RDD plots, binned scatterplots, density histograms
- `06_tables.R` — Main results, robustness, heterogeneity, mechanism tables
