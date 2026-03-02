# Initial Research Plan: The First Retirement Age

## Research Question

Did Civil War pension eligibility at age 62 reduce elderly labor supply in early twentieth-century America? What was the labor supply elasticity with respect to pension income in an era without any other social insurance?

## Background

The Service and Age Pension Act of 1907 created a sharp statutory threshold: any Union Army or Navy veteran who had served 90+ days and reached age 62 became automatically eligible for a monthly pension of $12 (approximately $400/month in 2024 dollars, or ~30% of an unskilled laborer's annual income). Additional discontinuities existed at age 70 ($15/month) and age 75 ($20/month).

By 1910, the Civil War pension system consumed 28% of federal expenditures and covered over 90% of surviving Union veterans. It was the largest social program in American history before the New Deal — and the direct precursor to Social Security.

Despite this, no published paper applies a regression discontinuity design to the age-62 threshold. The existing literature (Costa 1998; Eli 2015; Salisbury 2017) relies on cross-sectional variation in pension amounts (via disability ratings, service length, and physician assignment). The sharp statutory cutoff — the most natural identification strategy — has never been exploited.

## Identification Strategy

**Design:** Sharp regression discontinuity at age 62.

- **Running variable:** Age of veteran at time of 1910 census enumeration.
- **Threshold:** Age 62 (statutory cutoff under the 1907 Act).
- **Treatment:** Automatic pension eligibility ($12/month).
- **Population:** Union Army and Navy veterans identified via VETCIVWR variable in the 1910 IPUMS full-count census.

**Additional cutoffs:** Age 70 ($12 → $15/month) and age 75 ($15 → $20/month) provide multi-cutoff robustness.

**Placebo test:** Confederate veterans in the 1910 census. They face the same aging process but received state-level (not federal) pensions with DIFFERENT eligibility rules. No discontinuity at 62 for Confederates = the effect is pension-driven, not aging-driven.

## Expected Effects and Mechanisms

**Primary hypothesis:** Pension eligibility at 62 reduces labor force participation (standard income effect). Veterans crossing the threshold receive a large unconditional income transfer, reducing the shadow value of market work.

**Magnitude benchmark:** Costa (1998) estimates pension elasticity of non-participation ≥ 0.66, implying the pension reduced LFP by 14-19 percentage points. An RDD at the threshold should recover a similar or larger effect (local average treatment effect at the cutoff vs. ATE across the distribution).

**Secondary outcomes:**
1. **Occupational downgrading:** Veterans may shift from physically demanding occupations to lighter work rather than fully exiting the labor force.
2. **Living arrangements:** Pension income may enable independent living (own household) vs. living with adult children (Costa 1997 JPE finds this effect).
3. **Property ownership:** Pension wealth may affect housing tenure.

**Mechanisms:**
- Pure income effect: Pension substitutes for labor income.
- Health channel: Pension income improves nutrition/health, potentially increasing labor supply (countervailing effect).
- Household bargaining: Pension shifts power within multi-generational households.

## Primary Specification

For Union veterans $i$ observed in the 1910 census:

$$Y_i = \alpha + \tau \cdot \mathbb{1}[\text{Age}_i \geq 62] + f(\text{Age}_i - 62) + \epsilon_i$$

where $Y_i$ is the outcome (labor force participation, occupation, living arrangement), $\mathbb{1}[\text{Age}_i \geq 62]$ is the treatment indicator, and $f(\cdot)$ is a flexible polynomial in centered age. Estimated using local polynomial regression with triangular kernel (rdrobust).

## Planned Robustness Checks

1. **McCrary density test** at age 62 (manipulation test)
2. **Covariate balance** at threshold: race, nativity, literacy, marital status
3. **Bandwidth sensitivity**: optimal (IK and CCT), half-optimal, double-optimal
4. **Donut-hole RDD**: Exclude exact age 62
5. **Exclude heaping ages**: Drop ages 60 and 65
6. **Polynomial order**: Linear, quadratic (avoid higher — Gelman & Imbens 2019)
7. **Placebo cutoffs**: Test for discontinuity at ages 58, 60, 64, 66 (no policy change)
8. **Confederate placebo**: Same RDD for Confederate veterans at age 62
9. **Multi-cutoff**: RDD at age 70 ($15/month) and age 75 ($20/month)
10. **Fuzzy RDD**: Instrument actual pension receipt with crossing age 62

## Data Requirements

- **IPUMS 1910 full-count census** (or 5% sample if memory-constrained)
- Variables: AGE, SEX, RACE, VETCIVWR, LABFORCE, OCC1950, OWNERSHP, RELATE, MARST, LIT, NATIVITY, STATEFIP, URBAN
- Filter: Males, ages 50-85, VETCIVWR = Union Army/Navy
- Expected sample: ~150,000+ Union veterans (full-count), ~7,500 (5% sample)

## Power Assessment

With ~150,000 Union veterans and a bandwidth of ±5 years around age 62, the effective sample is approximately 40,000-50,000 observations. For a binary outcome (LFP) with baseline rate ~60%, the minimum detectable effect (MDE) at 80% power is approximately 1-2 percentage points. Costa estimates a 14-19 pp effect, so power is not a concern.

Even with the 5% sample (~7,500 veterans, ~2,000 in bandwidth window), the MDE is ~5-7 pp — still well below the expected effect size.
