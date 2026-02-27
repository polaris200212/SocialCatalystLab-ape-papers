# Initial Research Plan: apep_0477

## Title
Do Energy Labels Move Markets? Multi-Cutoff Evidence from English Property Transactions

## Research Question
Do Energy Performance Certificate (EPC) band labels causally affect residential property transaction prices in England and Wales? If so, is the effect driven by information provision (the label itself) or by regulation (the MEES prohibition on letting F/G-rated properties)? And does the salience of energy costs — dramatically heightened during the 2021-2023 energy crisis — amplify label capitalization?

## Identification Strategy
**Multi-cutoff sharp RDD** at EPC band boundaries.

The running variable is the EPC numerical score (1-100, derived from the Standard Assessment Procedure). At each band boundary, the letter label (A through G) changes discretely while the underlying energy characteristics are near-identical for properties scoring just above vs below the threshold.

We exploit five band boundaries:
- **E/F at score 39**: Information + MEES regulation (post-April 2018)
- **D/E at score 55**: Information only
- **C/D at score 69**: Information only
- **B/C at score 81**: Information only
- **A/B at score 92**: Information only (thin sample)

The key decomposition:
1. **Information effect** = average discontinuity at C/D and D/E boundaries (no regulatory overlay)
2. **Regulatory effect** = additional discontinuity at E/F beyond the average informational effect, specifically post-2018
3. **Crisis amplification** = change in discontinuity during Oct 2021 – Jun 2023 energy crisis

## Expected Effects and Mechanisms

**Information capitalization (all boundaries):**
- Properties just above a band boundary should sell for a premium relative to those just below
- Expected magnitude: 1-3% (consistent with Aydin et al. 2020 for Netherlands)
- Mechanism: buyer heuristic processing of salient categorical labels

**MEES regulatory effect (E/F boundary, post-2018):**
- Additional price penalty for properties rated F/G (cannot be legally let)
- Expected magnitude: 3-8% additional discount beyond information effect
- Mechanism chain: MEES → landlord cannot rent → must sell OR invest to upgrade → lower sale price OR compliance upgrading bunching

**Energy crisis amplification (all boundaries, Oct 2021 – Jun 2023):**
- Label effects should INCREASE during the crisis when energy costs are salient
- Expected magnitude: 1-2x amplification of pre-crisis effects
- Mechanism: energy prices make efficiency labels decision-relevant vs decorative

**Supply/investment adjustment (E/F, post-2018):**
- If MEES bites: landlord exit (increased sales of F/G rental properties), compliance upgrading (bunching at score 39), or exemption take-up
- The null rent result in the 2025 Energy Policy paper suggests adjustment occurs through quantity/investment, not price margins on rents

## Primary Specification

For each band boundary $c \in \{39, 55, 69, 81, 92\}$:

$$\log(P_i) = \alpha + \tau \cdot \mathbb{1}[S_i \geq c] + f(S_i - c) + X_i'\beta + \epsilon_i$$

where $P_i$ is transaction price, $S_i$ is EPC score, $f(\cdot)$ is a local polynomial (linear default), and $X_i$ includes property type, floor area, new-build status, year-quarter FE, and local authority FE.

Bandwidth selected by Calonico, Cattaneo, Titiunik (2014) MSE-optimal procedure with triangular kernel.

**Period interactions:**
$$\log(P_i) = \alpha + \sum_{t \in \{pre, crisis, post\}} \tau_t \cdot \mathbb{1}[S_i \geq c] \cdot \mathbb{1}[t] + f_t(S_i - c) + X_i'\beta + \epsilon_i$$

**MEES regulatory effect (E/F only):**
$$\text{MEES}_{\text{reg}} = \hat{\tau}_{E/F, \text{post-2018}} - \frac{1}{2}(\hat{\tau}_{D/E, \text{post-2018}} + \hat{\tau}_{C/D, \text{post-2018}})$$

## Exposure Alignment (RDD-specific)

- **Who is treated?** Properties scoring just above each band boundary receive a "better" letter label
- **Primary estimand:** Local average treatment effect (LATE) at each threshold — the causal effect of a label upgrade on transaction price for properties near the boundary
- **Placebo/control populations:**
  - Pre-MEES E/F discontinuity (pure information, no regulation)
  - Owner-occupied properties at E/F (MEES applies only to rentals)
  - Boundaries without regulatory overlay (C/D, D/E) as information-only benchmarks

## Power Assessment

- **EPC register:** ~30M domestic certificates, 2008-2025
- **Land Registry PPD:** ~24M transactions, 1995-2025
- **Matched sample (EPC × Land Registry):** Estimated 5-10M matches after linking
- **At each boundary (±5 score bandwidth):** ~200K-500K transactions
- **During crisis period (Oct 2021 – Jun 2023):** ~100K-200K per boundary
- **MDE:** With N=200K within bandwidth, σ(log price)≈0.5, we can detect effects of ~0.5% (log points) at conventional power — well below the expected 1-3% effect size

## Planned Robustness Checks

1. **McCrary density test** at all 5 boundaries × 3 time periods
2. **Donut RDD** excluding ±1 point around each threshold
3. **Covariate balance** at all boundaries (floor area, property type, new-build, postcode-level IMD)
4. **Bandwidth sensitivity** (0.5×, 1×, 1.5×, 2× of MSE-optimal)
5. **Polynomial order sensitivity** (local linear vs local quadratic)
6. **Placebo cutoffs** at non-boundary scores (e.g., 45, 50, 62, 75)
7. **Owner-occupied placebo** at E/F (MEES regulation should not affect them)
8. **Pre-MEES vs post-MEES** comparison at E/F
9. **Bunching analysis** using Kleven (2016) method at E/F post-2018
10. **Romano-Wolf** multiple testing correction across outcome families

## Data Sources

| Source | Purpose | Access |
|--------|---------|--------|
| EPC Register | Running variable (score), labels, tenure, property characteristics | Bulk download, free registration |
| Land Registry PPD | Outcome (transaction price), property type, location | Bulk CSV, free |
| postcodes.io | Postcode → LSOA/LA geocoding | Free API |
| ONS NSPL | Postcode lookup table | Free download |
| NOMIS | Local area labor market and demographic controls | API with key |
| OFGEM/ICE | Wholesale gas prices for crisis period definition | Published data |

## Timeline

1. Data fetch: EPC register + Land Registry PPD + postcodes
2. Data cleaning: Link EPC to Land Registry via postcode + address matching
3. Main analysis: Multi-cutoff RDD at all boundaries
4. Robustness: McCrary, donut, bandwidth, placebos
5. Mechanism: MEES decomposition, bunching, supply analysis
6. Crisis interaction: Period-specific RDD estimates
7. Paper writing
8. Internal review
9. External review
10. Revision and publication
