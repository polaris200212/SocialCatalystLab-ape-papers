# Research Ideas

## Idea 1: Opportunity Zone Designation and Data Center Investment — A Fuzzy RDD at the Poverty Threshold

**Policy:** The 2017 Tax Cuts and Jobs Act created Opportunity Zones (OZs), designating ~8,764 census tracts for capital gains tax deferral. Eligibility required a poverty rate ≥ 20% (from ACS 2011-2015). Governors selected ~25% of eligible tracts. The program attracted massive data center investment: ~25% of new data center square footage under construction is in designated OZs, despite OZs containing <10% of existing facilities.

**Outcome:** Data center establishment counts and employment (Census County Business Patterns, NAICS 5182), total business formation (Census Business Dynamics Statistics), construction employment (BLS QCEW NAICS 23), and commercial property values (Zillow/CoreLogic at ZIP level). At the tract level: building permits (Census Building Permits Survey), new establishment counts.

**Identification:** Fuzzy RDD at the 20% poverty threshold. The running variable is tract-level poverty rate from ACS 2011-2015. Below 20%, tracts are ineligible for OZ designation (probability = 0). Above 20%, ~25% of tracts were selected by governors. This creates a sharp first-stage discontinuity in designation probability. The reduced-form estimates show whether tracts just above the threshold experienced more investment than those just below. The exclusion restriction requires that the 20% poverty cutoff affects outcomes only through OZ designation, not through other programs (though NMTC eligibility uses the same threshold — a testable concern).

**Why it's novel:** While OZ RDDs exist (Freedman et al. 2023 study housing prices; Chen et al. 2023 study residential investment), no paper has examined the data center and tech investment channel specifically. This is important because: (1) data centers are the single largest category of OZ investment by dollar volume; (2) critics argue OZ subsidized data centers that would have been built regardless (the "but-for" question); (3) emerging markets worldwide are creating OZ-like programs to attract data center investment, making US evidence directly policy-relevant.

**Feasibility check:** ✅ Confirmed: Census ACS tract-level poverty data accessible via API. National sample of ~73,000 tracts with ~30,000+ near the 20% threshold (estimated). Census CBP provides NAICS 5182 county-level data (19 GA counties with establishments in 2022). Fuzzy RDD is well-powered. OZ designation lists are published by CDFI Fund/Treasury.


## Idea 2: State Data Center Tax Incentive Adoption — Spatial Border County RDD

**Policy:** Between 2005-2025, 37 US states adopted sales tax exemptions and/or property tax abatements specifically for data center equipment and operations. Staggered adoption creates ~50+ state border pairs where one state has data center incentives and the adjacent state does not (or adopted much later).

**Outcome:** County-level employment in NAICS 5182 (Data Processing, Hosting), total county employment and wages (BLS QCEW), county-level commercial electricity consumption (EIA Form 861), and construction employment (NAICS 23).

**Identification:** Spatial RDD at state borders. Compare counties immediately on either side of state borders where one state offers data center tax incentives and the other does not. Running variable: distance to state border (or latitude/longitude normalized by border position). Treatment: being in the incentive-adopting state. Standard spatial RDD assumptions: outcomes vary smoothly in geography except for the policy discontinuity at the border.

**Why it's novel:** No rigorous causal evaluation of data center tax incentives exists. The Georgia audit (2025) found 70% of investment would have occurred regardless, but used descriptive methods. A spatial border RDD provides credible causal identification.

**Feasibility check:** ⚠️ Partially confirmed: BLS QCEW county-level data accessible via CSV download. Census County Business Patterns confirmed accessible. KEY CONCERN: Data centers concentrate in major metro areas, not in border counties. NAICS 5182 data is heavily suppressed at the county level (only 16 GA counties have disclosed employment). The spatial variation at borders may be too sparse for detection. Power is a serious concern for data-center-specific outcomes, though total employment and construction employment would have less suppression.


## Idea 3: Georgia Data Center Tax Tiers — Multi-Cutoff RDD at Population Thresholds

**Policy:** Georgia's 2018 High-Tech Data Center Equipment Exemption (HB 696) created tiered investment thresholds based on county population: counties with <30,000 residents must invest $100M, counties with 30,000-50,000 must invest $150M, and counties with >50,000 must invest $250M. Population is measured by the most recent decennial census.

**Outcome:** Data center establishments and employment (CBP NAICS 5182), total employment (QCEW), county tax revenue (Census of Governments), construction permits, and Georgia DOR exemption expenditure data (published by county).

**Identification:** Multi-cutoff RDD with running variable = county population (2010 Census). Sharp cutoffs at 30,000 and 50,000. Counties just below 30,000 face a $100M threshold (easier to qualify), while those just above face $150M. The $50M difference in investment requirements at the cutoff creates differential access to the exemption.

**Why it's novel:** Would be the first RDD exploiting population-based incentive tiers for data center policy. Georgia is the 2nd largest US data center market and has foregone $2.5B in tax revenue since 2018.

**Feasibility check:** ❌ LIKELY UNDERPOWERED: Georgia has 37 counties within 10K of the 30K threshold and 12 near the 50K threshold — decent RDD sample. However, ALL 19 Georgia counties with NAICS 5182 establishments are large metro counties (>100K population), far from either threshold. Data centers do not locate in small/mid-size Georgia counties regardless of the incentive tier. The thresholds may not bind because most data center investments exceed $250M. BROADER OUTCOMES (total employment, tax revenue) could still detect spillover effects, but the mechanism would be indirect. Recommend pursuing only if Idea 1 fails.


## Idea 4: Qualified Opportunity Fund Investment in Data Center Tracts — RDD with Treasury Reporting Data

**Policy:** Same OZ program as Idea 1, but focused on the investment threshold for Qualified Opportunity Fund (QOF) reporting. QOFs must invest ≥90% of assets in OZ property. The IRS publishes aggregate QOF investment by census tract (Form 8996 data). Recent policy proposals (the "One Big Beautiful Bill" of 2025) would extend OZ benefits with enhanced 30% step-up for rural investments, potentially reshaping data center location incentives.

**Outcome:** QOF dollar investment by census tract (IRS aggregate data), combined with data center location data (OpenStreetMap / IM3 Atlas), construction activity (building permits), and employment change (LODES/LEHD at tract level).

**Identification:** Same fuzzy RDD framework as Idea 1 (poverty threshold at 20%), but using direct QOF investment amounts as both outcome and mechanism. Can decompose total QOF investment into data-center-related vs. other categories using SIC/NAICS matching.

**Why it's novel:** Combines two growing literatures — OZ evaluation and data center industrial policy — with direct investment data. The policy extension to rural OZs (30% step-up) creates a new margin for data center incentives that has not been studied.

**Feasibility check:** ⚠️ Partially confirmed: IRS has released aggregate QOF data but tract-level investment amounts may be suppressed for confidentiality. Need to verify IRS Form 8996 data availability. Census LEHD/LODES provides tract-level employment data. Main risk is data suppression at the tract level.
