# Initial Research Plan: The Lex Weber Shock

## Research Question

Does restricting second home construction in Swiss tourism municipalities reduce local employment, or does the sectoral composition of employment shift toward higher-value services?

## Policy Background

On March 11, 2012, Swiss voters approved the Second Home Initiative (Zweitwohnungsinitiative / "Lex Weber") by a narrow margin of 50.6%. The initiative caps the share of second homes at 20% of the total housing stock in every municipality. Municipalities already above the 20% threshold lost the right to issue building permits for new second homes; municipalities below 20% remained unconstrained. The federal implementation ordinance took effect September 2012, with the full implementation law (Zweitwohnungsgesetz, ZWG) effective January 1, 2016.

The initiative was a surprise outcome — polls had predicted rejection — providing plausibly exogenous treatment timing. The policy was motivated by environmental and landscape preservation concerns in Alpine regions, not by labor market conditions.

## Identification Strategy

### Primary Design: Difference-in-Differences

- **Treatment:** Municipality had a second home share ≥ 20% as of 2012 (predetermined before the vote)
- **Control:** Municipality had second home share < 20% as of 2012
- **Treatment onset:** Two candidate dates tested
  - **Main specification:** January 1, 2016 (ZWG implementation, 5 pre-treatment years: 2011-2015)
  - **Robustness specification:** March 2012 (vote date, 1 pre-treatment year only; anticipation effects 2012-2015 are part of the analysis)
- **Unit of analysis:** Municipality × NOGA sector × year
- **Estimator:** Canonical two-period DiD (single treatment date) with municipality and year fixed effects; sector-specific regressions

### Secondary Design: Near-Threshold RDD

- **Running variable:** Pre-2012 second home share (continuous)
- **Cutoff:** 20%
- **Compare:** Municipalities at 19-20% vs. 20-21% second home share
- **Bandwidth:** Optimal (IK/CCT) with robust bias-corrected confidence intervals
- **Purpose:** Credibility anchor for the DiD results; municipalities just above and just below 20% are similar on observables

### Triple-Difference

- **Third difference:** Low-exposure sectors (finance, public administration, health) serve as within-municipality placebo. If the effect concentrates in construction, real estate, and accommodation/food sectors but not in unexposed sectors, this strengthens causal interpretation.

## Exposure Alignment

- **Who is treated?** Municipalities with ≥ 20% second home share, where new second home construction is prohibited
- **Primary estimand:** Change in sectoral employment (FTEs) in treated municipalities relative to control municipalities after 2016
- **Placebo population:** Employment in non-tourism sectors within treated municipalities
- **Design:** DiD (primary) + RDD near threshold (secondary) + DDD (sector exposure)

## Expected Effects and Mechanisms

1. **Construction sector:** Negative effect (fewer building permits → fewer construction jobs)
2. **Real estate:** Negative effect (fewer transactions, less development)
3. **Accommodation/food:** Ambiguous
   - Negative: fewer new tourist beds → reduced tourism capacity
   - Positive: scarcity may shift tourism toward hotels/services over apartments
4. **Retail/personal services:** Modest negative (reduced construction activity spillovers)
5. **Overall employment:** Likely modest negative in treated municipalities, concentrated in construction
6. **Compositional shift:** Tourism employment may shift from construction-driven to service-driven

## Primary Specification

$$\log(Y_{mst}) = \alpha + \beta \cdot \text{Treated}_m \times \text{Post}_t + \gamma_{ms} + \delta_{st} + \epsilon_{mst}$$

Where:
- $Y_{mst}$: Employment (FTEs) in municipality $m$, sector $s$, year $t$
- $\text{Treated}_m$: Indicator for pre-2012 second home share ≥ 20%
- $\text{Post}_t$: Indicator for $t \geq 2016$
- $\gamma_{ms}$: Municipality × sector fixed effects
- $\delta_{st}$: Sector × year fixed effects
- Standard errors clustered at municipality level

## Power Assessment

- **Pre-treatment periods:** 5 years (2011-2015) using 2016 onset
- **Treated clusters:** ~500 municipalities above 20% threshold (exact count to be verified with data)
- **Control clusters:** ~1,600 municipalities below 20%
- **Post-treatment periods:** 7 years (2016-2022), possibly 8 (2016-2023)
- **Total observations:** ~2,100 municipalities × 13 years × multiple sectors
- **MDE:** To be computed after data acquisition; with ~500 treated units, standard DiD should detect effects of 3-5% with 80% power

## Planned Robustness Checks

1. **Event study:** Year-by-year coefficients for 2011-2023 (pre-trend test + dynamic effects)
2. **Near-threshold RDD:** Restrict to municipalities within ±5pp of the 20% cutoff
3. **Dose-response:** Interact treatment with pre-2012 second home share (municipalities at 40% are more constrained than at 21%)
4. **Anticipation effects:** Test for effects in 2012-2015 (between vote and implementation)
5. **Randomization inference:** Permute treatment status across municipalities for exact p-values
6. **Placebo sectors:** Run main specification on sectors unaffected by construction (health, education, public admin)
7. **Excluding border cases:** Drop municipalities within 1pp of the 20% threshold
8. **COVID interaction:** Test whether effects change after 2020 (COVID reduced tourism)
9. **Callaway-Sant'Anna with 2012 onset:** Treat the 2012 vote and 2016 law as two cohorts
10. **Bacon decomposition:** Verify TWFE estimates are not driven by problematic comparisons

## Data Sources

1. **STATENT** (BFS): Annual employment by municipality × NOGA sector, 2011-2023
   - Access: BFS PXWeb API (table px-x-0602010000_101, German endpoint)
   - Variables: Workplaces, employees, FTEs by gender

2. **Second home share by municipality:** ARE (Federal Office for Spatial Development) / BFS
   - Need pre-2012 baseline shares to define treatment
   - Post-2012 shares published annually for monitoring compliance

3. **Building permits:** BFS Bau- und Wohnbaustatistik
   - Annual new building permits by municipality
   - Mechanism check: does treatment reduce permits?

4. **Municipal characteristics:** BFS (population, area, altitude, language region, canton)
   - Balance table controls
