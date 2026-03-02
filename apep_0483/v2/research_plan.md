# Research Plan: Teacher Pay Competitiveness and Student Value-Added (v2)

## Question
Does the erosion of teacher pay competitiveness — driven by the interaction of frozen national STPCD pay scales with spatially heterogeneous private-sector wage growth — reduce student value-added (Progress 8) in English secondary schools?

## Identification Strategy

### Main Specification: School Fixed Effects
`progress8 ~ comp_ratio | school_id + year` with LA-clustered SEs. Continuous treatment (time-varying competitiveness ratio). School FE absorb all time-invariant school characteristics. Year FE absorb national trends.

### Academy Triple-Difference (Key Innovation)
Academies can legally deviate from STPCD pay scales; maintained schools cannot. If the STPCD constraint is the mechanism:
- Maintained schools: negative effect of declining competitiveness on Progress 8
- Academies: weaker/no effect (can adjust pay to local market)

This controls for everything at the LA-year level (economic conditions, demographics, COVID recovery).

### Bartik IV
Instrument local wage growth with 2011 Census industry shares × national industry wage trends. Addresses reverse causality (school quality → house prices → wages).

### Mechanism: Vacancy First Stage
Show competitiveness ↓ → teacher vacancy rate ↑ using SWC data.

## Data
- **KS4:** School-level Progress 8 + Attainment 8 from DfE (2016/17-2023/24, excluding COVID years)
- **GIAS:** School characteristics (academy/maintained status, FSM%, LA, URN)
- **ASHE:** LA-level median private-sector earnings from NOMIS
- **STPCD:** Teacher pay scales with London/Fringe/Rest-of-England bands
- **SWC:** Teacher vacancy rates by LA

## Panel: ~3,000 schools × 6 years = ~18,000 observations
Pre-COVID: 2016/17, 2017/18, 2018/19
Post-COVID: 2021/22, 2022/23, 2023/24

## Key Risks
1. Historical school-level KS4 may require manual download → script has fallbacks
2. Pre-trends may fail → apply HonestDiD bounds
3. Academy DDD shows no differential → informative null (academies don't exercise pay freedom)
4. Bartik first stage weak → report AR confidence sets
