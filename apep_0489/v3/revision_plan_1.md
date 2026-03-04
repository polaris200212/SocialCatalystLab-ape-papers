# Revision Plan — Round 1

## External Review Summary

- **GPT-5.2:** MAJOR REVISION — Wants stronger identification (1910 linkage, border counties), calibrated claims to match inference, population-weighted aggregation, resolve farmer-column divergence
- **Grok-4.1-Fast:** MINOR REVISION — Wants more bootstrap iterations, population-weighted aggregation, welfare quantification, second pre-trend
- **Gemini-3-Flash:** MAJOR REVISION — Wants block aggregation for power, Kline-Moretti comparison, FDR sensitivity plot

## Changes Made

### 1. Calibrate claims to inference (all three reviewers)
- **Abstract:** Rewritten to lead with the estimand (transition matrix), not the point estimates. Explicitly states most cells are imprecisely estimated and only clerical stay-rate is individually significant.
- **Introduction:** "Three findings" section rewritten. Lewis/entrepreneurial channels now described as "suggestive patterns" rather than established facts. Bootstrap imprecision acknowledged upfront.
- **Results narrative:** Added caveats throughout about frequency benchmark divergence on Farmer column.

### 2. Population-weighted aggregation (GPT-5.2, Grok)
- Replaced unweighted "11.4pp sum" with population-weighted implied destination share change ($\Delta\pi_k = \sum_j \pi_{j,1920} \Delta P_{jk}$), yielding -1.1pp farmer share decline.
- "22.6pp total disruption" reframed with caveat that it is not a standard population quantity.
- Structural transformation section now uses population-weighted measures.

### 3. Kline-Moretti comparison (Gemini)
- Added paragraph in TWFE section explaining why our 1.49pp < K&M's ~4pp: linked-sample selection, individual vs county-level data, share vs employment outcomes.

### 4. Farmer-column divergence (GPT-5.2)
- Added explicit caveat in Results that frequency benchmark shows mixed signs in Farmer column.
- "Uniform farmer avoidance" now qualified as potentially reflecting transformer's covariate conditioning or inductive bias.

### 5. Additional limitations (GPT-5.2, internal review)
- Added racial heterogeneity limitation (pooling races despite TVA-era occupational segregation).
- Added migration channel limitation (cannot separate migration from occupational transition).

## Changes NOT made (and why)

- **1910 linkage / border counties / matched county design:** Out of scope for this revision. Would require substantial new data construction and computation. Acknowledged as future work in conclusion.
- **500-1000 bootstrap iterations:** Computationally infeasible (each iteration = 7 min × 4 adapters). 100 iterations provides honest uncertainty even if wide. The paper is transparent about this.
- **Block aggregation with joint SE:** A valuable suggestion but requires additional bootstrap analysis infrastructure. The population-weighted implied shares address the same concern more directly.
- **Mover/stayer decomposition:** Requires additional data construction (identifying county changes across census waves). Acknowledged as limitation.
- **Permutation inference:** Computationally prohibitive (each permutation = full pipeline retrain). Noted as future work.
- **Wage/earnings linkage:** 1940 occupation wage scores could be appended but would require additional data sourcing. Mentioned as future work in conclusion.
