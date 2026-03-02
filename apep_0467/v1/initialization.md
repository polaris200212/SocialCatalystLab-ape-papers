# Human Initialization
Timestamp: 2026-02-26T17:39:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Questions Asked

1. **Country:** Which country?
   - Selected: **USA**

1b. **Data focus:** Medicaid (T-MSIS) or Open topic
   - Selected: **Medicaid (T-MSIS)**

2. **Method:** Which identification method?
   - Selected: **"Be smart. Be innovative."** → Agent discretion; continuous-treatment DiD with monopsony stress test framework

3. **API keys:** Are Census ACS and FRED keys configured?
   - Selected: **Yes**

4. **External review:** Include external model reviews?
   - Selected: **Yes (Recommended)**

5. **Other preferences:** Any other preferences or constraints?
   - User response: "Be smart. Be creative. Iterate with a shit ton of internal reasoning, together with data feasibility."

## Pre-Specified Research Idea

The user provided a detailed research concept:

**"Priced Out of Care: Medicaid Wage Competitiveness and Home Care Workforce Fragility"**

States set Medicaid HCBS reimbursement rates independently, creating wide variation in what personal care aides and home health workers can earn in the Medicaid market. Meanwhile, these workers' outside options — Amazon warehouses, fast-food chains, retail, gig delivery — pay $15-$17/hour with benefits in most states. The paper exploits the pre-COVID gap between state Medicaid reimbursement rates and local competing-sector wages as a treatment variable: states where the Medicaid-to-outside-wage ratio was lowest in 2019 should have the most fragile HCBS workforces entering the pandemic, and therefore the largest disruptions after March 2020. Unlike the exit-rate treatment in APEP-454, this wage-gap measure is determined by state rate-setting decisions and local labor market conditions — not by the dependent variable's own pre-period. It generates no mechanical pre-trends, admits a clean parallel-trends test, and connects directly to a standard economic mechanism (monopsony pricing below market-clearing wages). The T-MSIS provider spending data provides the outcomes; BLS Occupational Employment Statistics and KFF/MACPAC rate surveys provide the treatment. The identifying assumption is that, conditional on state fixed effects, the pre-COVID wage gap is uncorrelated with pandemic severity — testable via pre-trend balance and COVID-control stability.

## Setup Results

- **Country:** USA
- **Domain:** Health/Medicaid (HCBS workforce, monopsony, wage competitiveness)
- **Method:** Continuous-treatment DiD (pre-COVID wage ratio × post-March 2020)
- **Data era:** Modern (T-MSIS 2018-2024, BLS OES 2019)
- **Risk appetite:** Novel angle (classic HCBS data + novel monopsony stress test framework)
- **Other preferences:** Maximize innovation; monopsony framework; triple-diff Medicare placebo
