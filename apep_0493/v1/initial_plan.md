# Initial Research Plan — apep_0493

## Research Question

Did the localisation of Council Tax Support in England (April 2013) increase employment among low-income households, or did it primarily create financial distress? We exploit the heterogeneous scheme designs adopted by 326 English Local Authorities — ranging from full protection to 40%+ minimum payments — to identify the causal effect of benefit conditionality on employment and financial outcomes.

## Background

In April 2013, the UK government replaced the national Council Tax Benefit (CTB) with locally-designed Council Tax Support (CTS) schemes, devolving responsibility to Local Authorities with a 10% budget cut. This created an unprecedented natural experiment: ~264 LAs imposed minimum council tax payments (5-40%) on previously-exempt working-age claimants, while ~62 LAs maintained full protection. The reform effectively imposed a lump-sum tax on non-employment for millions of low-income households in cut LAs.

## Identification Strategy

**Design:** Continuous-treatment Difference-in-Differences

- **Treatment group:** LAs that imposed minimum council tax payments on working-age CTS claimants (varied intensity: 5-40%+)
- **Control group:** LAs that maintained 100% support (passthrough schemes)
- **Treatment timing:** April 2013 (simultaneous for all LAs, but intensity varies)
- **Pre-period:** January 2008 – March 2013 (63 months under identical national CTB)
- **Post-period:** April 2013 – December 2023 (129 months under local CTS)

**Estimator:** Two approaches:
1. **Binary DiD:** Compare ~264 "cut" LAs vs. ~62 "protected" LAs using Callaway & Sant'Anna (2021)
2. **Continuous treatment:** Regress outcomes on treatment intensity (minimum payment % or change in CTS reduction per dwelling) interacted with post-reform indicator

**Key identifying assumption:** Conditional on observable LA characteristics, CTS scheme generosity is uncorrelated with unobserved time-varying shocks to local employment. Testable via pre-trends under the identical national CTB regime (2008-2013).

## Exposure Alignment (DiD Required Section)

- **Who is actually treated?** Working-age council tax benefit claimants in LAs that imposed minimum payments. These are low-income households (typically on JSA, ESA, Income Support, or low earnings) who previously paid zero council tax.
- **Primary estimand population:** Working-age residents in "cut" LAs (treatment group)
- **Placebo/control populations:** (1) Pensioners (protected from CTS cuts by statute — should show no effect); (2) Working-age residents in "passthrough" LAs
- **Design:** Standard two-group DiD with continuous treatment intensity

## Power Assessment

- **Pre-treatment periods:** 63 months (Jan 2008 – Mar 2013)
- **Treated clusters:** ~264 LAs
- **Control clusters:** ~62 LAs
- **Post-treatment periods:** 129 months (Apr 2013 – Dec 2023)
- **Unit of observation:** LA × month
- **Expected effect size:** The IFS (2019) found null effects but used cross-sectional methods. DWP Benefit Cap evaluation found ~5pp employment increase for capped households. We target an MDE of 0.5-1pp change in claimant rate (economically meaningful given ~5% baseline claimant rate in many LAs).

## Expected Effects and Mechanisms

**Two competing hypotheses:**

1. **Work incentive channel:** Minimum payments create a financial penalty for non-employment → some claimants move into work → claimant count falls, employment rises
2. **Financial distress channel:** Minimum payments impose unaffordable costs on already-poor households → council tax arrears increase, financial stress rises → no employment effect (or negative effect via debt/mental health spiral)

**Mechanism chain to test:**
- First stage: CTS cuts → increased council tax liability for working-age claimants (verify with taxbase data)
- Collection: Did LAs actually collect the additional tax? (collection rates, arrears data)
- Employment: Did claimant counts change differentially? (NOMIS monthly data)
- Financial distress: Did arrears and write-offs increase? (DLUHC collection data)

## Primary Specification

```
Y_{it} = α_i + γ_t + β × (Treatment_i × Post_t) + X_{it}'δ + ε_{it}
```

Where:
- Y_{it}: Claimant count rate (claimants / working-age population) in LA i, month t
- α_i: LA fixed effects
- γ_t: Month fixed effects
- Treatment_i: CTS cut intensity (binary or continuous minimum payment %)
- Post_t: Indicator for April 2013+
- X_{it}: Time-varying controls (LA spending cuts, UC rollout, Benefit Cap exposure)

**Event-study specification:**
```
Y_{it} = α_i + γ_t + Σ_{k=-24}^{48} β_k × (Treatment_i × 1{t = k}) + ε_{it}
```
where k = 0 is April 2013.

## Planned Robustness Checks

1. **Pre-trends:** Joint F-test on pre-period event-study coefficients
2. **HonestDiD (Rambachan & Roth 2023):** Sensitivity bounds under trend departures
3. **Pensioner placebo:** Run identical specification on pensioner claimant counts (should show null — pensioners are protected from CTS cuts)
4. **Leave-one-out regions:** Drop each of 9 English regions
5. **Coincident reform controls:** Include Benefit Cap exposure, UC rollout timing, broader austerity spending (Beatty & Fothergill measures)
6. **Alternative treatment measures:** Binary (cut vs. protected), continuous (minimum payment %), taxbase-derived (change in CTS reduction)
7. **Wild cluster bootstrap:** Clustered inference at LA level with wild bootstrap for robustness
8. **Donut specification:** Exclude April-September 2013 (transition period)

## Data Sources

| Data | Source | Granularity | Years |
|------|--------|-------------|-------|
| Claimant count | NOMIS (NM_162_1) | LA × month | 2008-2023 |
| Working-age population | ONS mid-year estimates | LA × year | 2008-2023 |
| CTS reduction in taxbase | DLUHC Council Taxbase | LA × year | 2012-2023 |
| Pre-reform CTB caseloads | DWP Stat-Xplore | LA × quarter | 2008-2013 |
| Collection rates | DLUHC Collection Rates | LA × year | 2004-2023 |
| Arrears | DLUHC Collection Rates (Table 8) | LA × year | 2004-2023 |
| Band D council tax | DLUHC Council Tax Levels | LA × year | 2008-2023 |
| Benefit Cap exposure | DWP | LA × quarter | 2013-2023 |

## Related Literature

- Adam, Joyce, Pope (2019, IFS): CTS localisation effects — null employment result (cross-section)
- Fetzer (2019, AER): UK austerity → Brexit — uses bundled welfare reform exposure
- Beatty & Fothergill (2013, CRESR): Simulated per-capita welfare losses by district
- Brewer, Browne, Jin (2012, IFS): Pre-reform analysis of CTB design options
- Blundell et al. (various): UK in-work benefits and labour supply
