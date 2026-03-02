# Research Ideas

## Idea 1: From Safety Net to Gig Economy? Universal Credit and the Rise of Self-Employment in Britain

**Policy:** Universal Credit Full Service rollout across ~643 Jobcentre Plus offices, staggered from November 2015 to December 2018. UC replaced six legacy benefits (JSA, ESA, Income Support, Housing Benefit, Child Tax Credit, Working Tax Credit) with a single monthly payment and a unified taper rate (initially 65p, reduced to 55p in April 2017). The Full Service rollout determined when existing claimants were migrated to UC, creating staggered treatment at the local authority level.

**Outcome:** Self-employment rates, employment composition (employee vs self-employed), and business formation at the local authority level. Data from NOMIS Annual Population Survey (quarterly, LA-level, back to 2004) for employment/self-employment rates, and Companies House bulk data for sole trader/micro-company formation. Claimant Count data (monthly, LA-level) for worklessness.

**Identification:** Staggered difference-in-differences exploiting the phased rollout of UC Full Service across ~325 English local authorities from 2016-2018. Treatment is defined as the month/quarter when a local authority's Jobcentre Plus office transitioned to Full Service. Control LAs are those not yet transitioned. Use Callaway-Sant'Anna (2021) estimator for heterogeneous treatment effects.

Pre-treatment period: 2013 Q1 - rollout date (12+ quarters for most LAs).
Post-treatment period: rollout date - 2019 Q4 (pre-COVID endpoint).

**Why it's novel:**
1. No top-5 journal paper studies UC's employment effects with modern staggered DiD.
2. The self-employment composition angle is entirely unstudied — existing work focuses on overall employment or mental health.
3. UC's design features (monthly assessment, digital-first reporting, simplified self-employment declaration) may differentially encourage self-employment as a pathway off benefits.
4. The Minimum Income Floor (assumed minimum earnings for self-employed after 12 months) creates a second within-UC policy shock that can be tested.
5. This speaks to the broader "gig economy" debate — do welfare system reforms inadvertently shape the quality, not just quantity, of employment?

**Mechanism chain:**
UC Full Service → simplified monthly reporting + single taper rate → lower EMTRs for combined work+benefits → increased returns to ANY work → but self-employment is easier to start (no employer needed) and easier to report monthly → disproportionate shift toward self-employment → potential quality concerns (low-earning, precarious self-employment).

**Feasibility check:**
- ✅ Staggered variation: 643 JCPs rolled out over 30 months (2016-2018)
- ✅ Data: NOMIS APS quarterly at LA level back to 2004; Claimant Count monthly from 2013; rollout schedule publicly available from DWP
- ✅ Pre-periods: 12+ quarters before most treatments
- ✅ Novelty: No AER/QJE/JPE paper on UC employment composition
- ✅ Scale: ~325 English LAs, millions of claimants affected
- ⚠️ Risk: APS estimates have wide CIs for small LAs; rollout may not be fully exogenous


## Idea 2: The Hidden Tax on Work: Council Tax Support Localization and Labour Supply in England

**Policy:** In April 2013, the UK government abolished national Council Tax Benefit and required each English local authority to design its own Local Council Tax Support (LCTS) scheme. With a 10% funding cut, most LAs introduced "minimum payments" — requiring working-age claimants to pay 5-30% of their council tax bill (previously 0%). This created sudden cross-LA variation in effective marginal tax rates on work for low-income households.

**Outcome:** Employment rates, claimant counts, and council tax collection rates at the LA level. Data from NOMIS (claimant count, APS employment) and MHCLG council tax statistics.

**Identification:** DiD comparing LAs that introduced minimum payments (treated, ~230 LAs) versus those that maintained full support (control, ~43 LAs). Pre-period: 2010-2013 Q1. Post-period: 2013 Q2 - 2019. Additional variation from the continuous minimum payment rate (5-30%).

**Why it's novel:** The LCTS reform created a natural experiment in benefit design that directly tests the canonical labor supply model — higher effective tax rates on low-income work should reduce labor supply. Limited academic work exists (IFS descriptive reports, Adam & Browne 2013) but no modern DiD paper in a top journal.

**Feasibility check:**
- ✅ Treatment variation: ~230 treated LAs vs ~43 control LAs
- ✅ Data: NOMIS claimant count monthly; MHCLG council tax statistics annual
- ✅ Pre-periods: 3+ years pre-2013
- ✅ Novelty: No top journal paper
- ⚠️ Risk: Simultaneous April 2013 adoption = not truly staggered; relies on cross-sectional variation in minimum payment rates


## Idea 3: Capping Welfare, Pushing to Work? The 2016 Benefit Cap Reduction and Employment Transitions

**Policy:** The Benefit Cap was reduced in November 2016 from £26,000/year to £20,000 outside London (£23,000 in London). This dramatically increased the number of households affected — from ~20,000 to ~68,000. Households exceeding the cap had their Housing Benefit reduced.

**Outcome:** Employment transitions (benefit-to-work moves), claimant count, housing mobility, and eviction rates at the LA level.

**Identification:** DiD exploiting geographic variation in the "bite" of the 2016 cap reduction. LAs with higher pre-reform housing costs and larger families were differentially affected. Treatment intensity = share of households newly capped in 2016. Pre-period: 2013-2016 Q3. Post-period: 2016 Q4 - 2019.

**Why it's novel:** Fetzer, Sen, and Souza (2019, J. Public Econ) study the 2013 cap but focus on housing/wellbeing, not employment. The 2016 reduction was much larger in scope. DWP evaluations exist but lack modern causal methods. The question — does cutting benefits push people into work or into destitution? — remains hotly contested.

**Feasibility check:**
- ✅ Treatment variation: Geographic variation in bite (high-rent vs low-rent LAs)
- ✅ Data: DWP Stat-Xplore for cap cases by LA; NOMIS for employment
- ✅ Pre-periods: 3+ years
- ⚠️ Risk: "Treatment intensity from pre-period outcomes" (housing costs) may generate mechanical pre-trends
- ⚠️ Risk: Small treated population at LA level may limit power


## Idea 4: Austerity and Local Labour Markets: The Employment Effects of Council Spending Cuts

**Policy:** Between 2010 and 2019, English local authorities experienced real-terms funding cuts of 20-60%, driven primarily by central government grant reductions under the coalition and Conservative governments. The cuts were unevenly distributed — more deprived LAs lost more per capita because they relied more heavily on Revenue Support Grant.

**Outcome:** Total employment, public sector employment, private sector employment, and earnings at the LA level. Data from NOMIS BRES (annual by sector) and APS.

**Identification:** Continuous treatment DiD using the formula-driven component of grant reductions as treatment intensity. The Settlement Funding Assessment formula allocates grants based on deprivation, population, and area cost adjustment — creating quasi-exogenous variation in the size of cuts across LAs. Instrument: pre-reform grant dependence (share of revenue from central grants) × post-2010 aggregate cut.

**Why it's novel:** Fetzer (2019, APSR) shows austerity drove UKIP voting, but the local labour market channel is understudied. Alesina et al. (2019) study country-level austerity. A local labour market multiplier paper for UK austerity with administrative data would be novel.

**Feasibility check:**
- ✅ Treatment variation: 326 English LAs with varying cut intensity
- ✅ Data: DLUHC revenue outturn by LA; NOMIS BRES; APS
- ⚠️ Risk: Continuous treatment intensity (tournament warns against this)
- ⚠️ Risk: Endogenous grant allocation (deprivation correlates with labour market conditions)
- ⚠️ Risk: Multiple concurrent austerity policies (welfare reform, NHS cuts) confound


## Idea 5: Apprenticeship Levy and the Training Paradox: Did Mandatory Contributions Reduce Skill Investment?

**Policy:** In April 2017, the UK introduced an Apprenticeship Levy — a 0.5% payroll tax on employers with annual pay bills exceeding £3 million. Levy funds are ring-fenced for apprenticeship training. Smaller employers (below the threshold) receive co-investment support but face different incentives.

**Outcome:** Apprenticeship starts, training intensity, wages, and employment at the LA/sector level. Data from Education and Skills Funding Agency (apprenticeship statistics), NOMIS BRES (employment by industry), and APS (qualification attainment).

**Identification:** DiD comparing areas/sectors with high levy exposure (large-employer concentrated) versus low exposure (small-employer dominated). The £3M payroll threshold creates firm-size variation that maps to geographic and sectoral patterns.

**Why it's novel:** Apprenticeship starts fell 25% after levy introduction — the opposite of the policy's intent. No top journal paper has credibly estimated whether the levy caused this decline or merely coincided with other trends. The "training paradox" — mandating training investment reduces training — speaks to the Becker (1962) framework and employer vs worker investment incentives.

**Feasibility check:**
- ✅ Data: ESFA apprenticeship data by LA and sector; NOMIS for employment
- ✅ Sharp threshold: £3M payroll creates natural treatment/control
- ⚠️ Risk: National policy with cross-sectional variation only (not truly staggered)
- ⚠️ Risk: Difficult to separate levy effect from concurrent education reforms (e.g., apprenticeship standards reform)
