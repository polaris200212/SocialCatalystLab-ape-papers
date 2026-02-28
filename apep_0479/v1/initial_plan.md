# Initial Research Plan: apep_0479

## Research Question

How did the Durbin Amendment's debit interchange fee cap affect banks' physical infrastructure decisions and banking labor markets? Specifically, did the revenue shock to large banks (>$10B assets) lead to branch closures and teller employment reductions in counties more exposed to treated banks?

## Identification Strategy

**Design:** Bartik/shift-share difference-in-differences with triple-difference extension.

**Treatment intensity:** County-level exposure to Durbin Amendment = pre-treatment (June 2010) share of county deposits held in banks with total assets exceeding $10 billion.

**Timing:** Dodd-Frank signed July 2010; Regulation II final rule June 2011; effective October 1, 2011. Treatment onset defined as 2012 (first full post-implementation year). 2010–2011 treated as phase-in/anticipation window.

**Core specification (DiD):**
```
Y_{ct} = α + Σ_k β_k(Exposure_c × 1[Year=k]) + γ_c + δ_t + X_{ct}η + ε_{ct}
```
Where Y is branch count per capita or banking employment, Exposure_c is pre-Durbin large-bank deposit share, and 2009 is the omitted reference year. County FE (γ_c) and year FE (δ_t) absorb time-invariant county characteristics and national trends.

**Triple-difference (DDD):**
```
Y_{cst} = α + β₁(Exposure_c × Post_t × Banking_s) + sector×county FE + sector×year FE + county×year FE + ε
```
Where s indexes sectors (banking vs. non-banking). This absorbs county-specific macro shocks affecting all industries.

**Clustering:** State level (~50 clusters), with robustness to county-level clustering.

## Exposure Alignment (DiD Requirements)

- **Who is treated:** Banks with assets >$10B, subject to interchange fee cap
- **Primary estimand population:** Counties with high exposure (large share of deposits in treated banks)
- **Control population:** Counties with low exposure (deposits primarily in exempt banks)
- **Design:** Continuous-treatment DiD with DDD extension

## Power Assessment

- **Pre-treatment periods:** 2006–2009 (4 clean pre-periods; 2010–2011 are anticipation window)
- **Treated clusters:** ~3,100 counties with BLS QCEW banking employment data
- **States for clustering:** 50+
- **Post-treatment periods:** 2012–2018 (7 years)
- **MDE:** With 3,100 counties and continuous treatment, power should be sufficient to detect moderate effects (5–10% employment changes). Formal MDE calculation will be performed after data assembly.

## Expected Effects and Mechanisms

**Mechanism chain:**
1. Durbin Amendment caps interchange fees → large banks lose ~$6–8B annual revenue
2. Banks partially offset with higher account fees (documented by Kay et al. 2014)
3. Banks also cut costs by closing marginal branches → fewer branches in high-exposure counties
4. Fewer branches → fewer tellers → banking employment declines
5. Consumer response: deposits shift from large (treated) banks to small (exempt) banks, or reduced physical banking access

**Expected signs:**
- Branch count per capita: Negative (more closures in high-exposure counties)
- Banking employment: Negative
- Teller employment: Negative
- Exempt bank deposits: Positive (deposit reallocation)
- Non-banking employment: Null (placebo)

## Primary Specification

1. **First stage:** Show Durbin exposure predicts branch closures (FDIC SOD)
2. **Main result:** Durbin exposure predicts banking employment declines (QCEW)
3. **Mechanism:** Teller-specific effects (OES data, MSA level)
4. **Reallocation:** Deposit shifts from treated to exempt banks (FDIC SOD)
5. **DDD:** Banking vs. non-banking employment in same counties

## Planned Robustness Checks

1. **Pre-trend tests:** Joint F-test, visual event study, HonestDiD
2. **Alternative exposure measures:** Binary (above/below median), terciles, continuous
3. **Bandwidth sensitivity:** Narrow (2009–2014) vs. wide (2006–2018)
4. **Placebo sectors:** Manufacturing, retail, healthcare employment
5. **Alternative clustering:** State, county, commuting zone
6. **Excluding crisis counties:** Drop counties with bank failures 2008–2010
7. **Asset threshold manipulation:** Test for bunching below $10B
8. **Leave-one-state-out:** Jackknife to check no single state drives results

## Data Sources

| Source | Unit | Time | Variables |
|--------|------|------|-----------|
| FDIC SOD | Branch × Year | 1994–2023 | Deposits, CERT, county, branch type |
| FDIC Financials | Bank × Quarter | 2006–2018 | Total assets, CERT |
| BLS QCEW | County × Year | 2006–2018 | NAICS 52211 employment, wages |
| BLS OES | MSA × Year | 2006–2018 | SOC 43-3071 teller employment, wages |
| FRED | National × Year | 2006–2018 | Banking aggregates, controls |
| Census ACS | County × Year | 2006–2018 | Demographics for controls |

## Key Literature

- Bessen (2015): ATMs complemented tellers 1970–2010 via branch expansion
- Kay, Mark, Schardin (2014, Fed): Bank responses to Durbin — fees, not cost-cutting
- Wang, Schwartz, Mitchell (2014): Durbin impact on bank profitability
- Acemoglu & Restrepo (2019): Task framework for automation and employment
- Autor (2015): Why automation hasn't eliminated jobs — task reallocation
- Jayaratne & Strahan (1996): Branching deregulation effects
