# Initial Research Plan: From Safety Net to Gig Economy? Universal Credit and the Rise of Self-Employment in Britain

## Research Question

Did the rollout of Universal Credit Full Service cause a shift in the *composition* of employment — specifically, an increase in self-employment relative to employee jobs — among benefit claimants transitioning to work?

## Background

Universal Credit (UC) replaced six legacy benefits with a single monthly payment system. The Full Service rollout across ~643 Jobcentre Plus offices between November 2015 and December 2018 created staggered treatment timing across English local authorities. UC's design features — monthly assessment periods, digital-first reporting, a unified 55p taper rate, and simplified self-employment declaration — may differentially encourage self-employment as a route off benefits, even if that self-employment is low-earning and precarious.

## Identification Strategy

**Design:** Staggered difference-in-differences exploiting the phased UC Full Service rollout across English local authorities.

**Treatment:** The quarter in which a local authority's Jobcentre Plus office(s) transitioned to UC Full Service (publicly available from DWP rollout schedules).

**Unit of analysis:** Local authority × quarter.

**Estimator:** Callaway and Sant'Anna (2021) — heterogeneous treatment effects with not-yet-treated as control group.

**Pre-treatment window:** 2013 Q1 through quarter before treatment (minimum 4 quarters, most LAs have 12+).

**Post-treatment window:** Treatment quarter through 2019 Q4 (to avoid COVID contamination).

## Expected Effects and Mechanisms

### Primary hypothesis
UC Full Service rollout *increases* the self-employment rate and the self-employment *share* of total employment in treated local authorities.

### Mechanism chain
1. **First stage:** UC Full Service replaces legacy benefits → claimants face UC's taper rate and reporting system
2. **Behavioural response:** UC's monthly assessment + single taper rate reduces effective marginal tax rates on combined work + benefits → but self-employment is easier to start (no employer search), more flexible, and easier to report under UC's digital system
3. **Composition effect:** Disproportionate shift toward self-employment vs employee jobs
4. **Quality concern:** The "self-employed" UC claimants may be in low-earning, precarious gig work — not genuine entrepreneurship

### Counter-hypothesis
UC's stricter conditionality and work search requirements may push claimants toward employee jobs (which satisfy conditionality more easily) and *reduce* self-employment.

## Primary Specification

Y_{it} = self-employment rate (or self-employment share of total employment) in LA i, quarter t.

Treatment: D_{it} = 1 if LA i has transitioned to UC Full Service by quarter t.

Controls: LA fixed effects, quarter fixed effects, region × time trends.

Callaway-Sant'Anna group-time ATT with not-yet-treated as controls.

## Exposure Alignment

- **Who is treated?** Working-age benefit claimants in local authorities that transitioned to UC Full Service. The treatment affects all new claims (and eventually existing claimants via managed migration).
- **Primary estimand population:** Working-age adults in treated LAs (intent-to-treat at the LA level, since UC affects the entire local benefit claimant population).
- **Placebo/control population:** (a) LAs not yet transitioned (not-yet-treated); (b) Pension-age adults in treated LAs (unaffected by UC); (c) High-income areas with few benefit claimants (low treatment intensity).

## Power Assessment

- **Pre-treatment periods:** 12+ quarters (2013 Q1 to ~2016 Q1 for early adopters)
- **Treated clusters:** ~325 English LAs (far exceeds 20)
- **Post-treatment periods:** 8-16 quarters per cohort (depending on adoption date)
- **Outcome variation:** Self-employment rate varies from ~5% to ~15% across LAs
- **Expected MDE:** With 325 LAs and quarterly data, should detect effects of ~0.5-1 percentage point

## Planned Robustness Checks

1. **Event study:** Dynamic treatment effects (pre-trend validation + post-treatment dynamics)
2. **Placebo outcome:** Pension-age employment (should be unaffected by UC)
3. **Placebo timing:** Randomize rollout dates and re-estimate
4. **Treatment intensity:** Interact with pre-UC claimant share (higher share = more treated)
5. **TWFE comparison:** Show conventional TWFE and where it diverges from CS estimates
6. **HonestDiD:** Sensitivity to violations of parallel trends
7. **Alternative estimator:** Sun and Abraham (2021) for comparison
8. **Excluding London:** London LAs may have different labour market dynamics
9. **Claimant Count as first stage:** Verify UC rollout actually changed the benefit system
10. **Companies House data:** Verify self-employment rise with business formation data

## Data Sources

| Data | Source | Granularity | Period |
|------|--------|-------------|--------|
| Self-employment rates | NOMIS APS | LA × quarter | 2004-2024 |
| Employment rates | NOMIS APS | LA × quarter | 2004-2024 |
| Claimant count | NOMIS/ONS | LA × month | 2013-2024 |
| UC rollout dates | DWP GOV.UK | JCP → LA mapping | 2015-2018 |
| Business formation | Companies House | Postcode → LA | 2010-2024 |
| Population | ONS mid-year estimates | LA × year | 2010-2024 |
