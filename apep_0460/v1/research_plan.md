# Research Plan: Across the Channel
## APEP-0460 v1

## Research Question

Do economic shocks transmit across national borders through social networks? We study this question using Brexit as a quasi-natural experiment and Facebook's Social Connectedness Index (SCI) to measure cross-border social ties between 96 French départements and 183 UK GADM2 regions.

## Identification Strategy

**Design:** Continuous-treatment difference-in-differences.

**Treatment exposure:** Pre-Brexit SCI weights from each French département to UK GADM2 regions. These capture the density of Facebook friendship links and proxy for broader social and economic connections. The SCI is from the October 2021 vintage, reflecting social structures that largely predate the referendum by years or decades.

**Estimating equation:**

Y_{f,t} = α + β · log(SCI_f^UK) × Post_t + γ_f + δ_t + ε_{f,t}

Where:
- Y_{f,t} = outcome in French département f at time t
- log(SCI_f^UK) = log of total SCI from département f to all 183 UK GADM2 regions
- Post_t = 1 from 2016 Q3 (referendum) onward
- γ_f = département fixed effects
- δ_t = quarter-year fixed effects

**Exclusion restriction:** Conditional on département and time fixed effects, the only channel through which SCI-weighted UK exposure affects French local outcomes is through the social network connection itself. Tested via German placebo (mixed results — see below) and pre-trends.

## Actual Results

**Central finding: POSITIVE coefficient.** French départements with stronger UK social connections experienced relative housing price *appreciation* after the Brexit referendum — consistent with demand reallocation, not economic distress transmission.

**Main results:**
- Baseline (Column 1): β = 0.025, SE = 0.011, t = 2.19, p = 0.031
- Referendum period: β = 0.021, p = 0.048 (concentrated here)
- Transition period: β = 0.009, p = 0.43 (attenuated)
- Horse race (UK + DE): UK β = 0.016 (p = 0.19), DE β = 0.034 (p = 0.08)
- Transaction volume: β = 0.040, p = 0.43 (not significant — tension with demand story)
- Standardized: 1 SD log SCI → 0.7% price increase

**Placebo and robustness:**
- German placebo: β = 0.045, p = 0.008 — SIGNIFICANT (identification challenge)
- Swiss franc placebo: β = 0.015, p < 0.05 — positive (validates SCI channel)
- Permutation inference (2000 draws): p = 0.038
- Leave-one-UK-country-out: 0.021–0.026 (very stable)
- Two-way clustering: SE = 0.011 (unchanged)
- COVID control: β = 0.023, p = 0.028 (survives)
- Population vs probability weighted SCI: identical (β = 0.025)
- Event study: flat pre-trends, one outlier at τ = -4 (p = 0.005)

**Key identification challenge:** The German placebo is positive and more significant than the UK treatment. This means the results could reflect generic international connectivity rather than UK-specific Brexit exposure. The paper is transparent about this limitation.

## Mechanisms (Demand Reallocation Interpretation)

1. **Sterling depreciation:** Made French property cheaper for UK buyers
2. **EU residence hedging:** UK nationals purchased property to secure continental foothold
3. **Safe-haven diversification:** UK investors redirected capital to familiar continental locations

## Data

| Source | Level | Frequency | Years | Access |
|--------|-------|-----------|-------|--------|
| Facebook SCI (HDX GADM2) | GADM2 pairs | Static | Oct 2021 | Free download |
| DVF (data.gouv.fr) | Transaction → dept-quarter | Quarterly | 2014–2023 | Free bulk download |
| ONS Regional GVA | ITL3 (UK) | Annual | 1998–2023 | Excel download |

**Panel:** 96 départements × 40 quarters = 3,840 obs (3,523 non-missing for DVF)

**Note:** INSEE economic indicators (unemployment, firm creation, employment) could not be retrieved due to API access constraints. Analysis focuses exclusively on housing market outcomes.
