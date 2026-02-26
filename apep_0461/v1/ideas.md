# Research Ideas — apep_0461

## Idea 1: "Does Oil Hurt? Resource Dependence and Child Survival After the 2014 Price Crash"

**Policy:** The 2014–2016 global oil price crash (Brent crude fell from $110/bbl in June 2014 to $30/bbl in January 2016). Oil-dependent countries experienced massive fiscal contractions: Nigeria lost ~60% of government revenue, Angola ~45%, Iraq ~50%. These fiscal shocks directly reduced health and education spending, with human development consequences.

**Outcome:** Under-5 mortality rate, maternal mortality ratio, DPT immunization coverage, government health expenditure (% GDP), primary school enrollment — all from World Bank WDI (annual, 200+ countries, 2005–2024).

**Identification:** Continuous difference-in-differences with Bartik-style treatment intensity. Treatment = pre-2014 oil rents (% GDP, WB indicator NY.GDP.PETR.RT.ZS) × post-2014 indicator. Countries with higher pre-shock oil dependence experience larger fiscal contractions when prices crash. The identifying assumption is that conditional on country and year fixed effects plus time-varying controls, pre-2014 oil dependence is orthogonal to differential trends in health outcomes. This is plausible because oil endowments are geological, not chosen.

**Data sources (all verified accessible):**
- FRED: Monthly Brent crude prices (DCOILBRENTEU) — 180 obs, 2010–2024 ✓
- World Bank WDI: Oil rents, under-5 mortality, maternal mortality, immunization, health expenditure, school enrollment, GDP, military spending — 226 countries ✓
- DHS API: Nigeria state-level health outcomes (37 states × 3 waves: 2013, 2018, 2024) for supplementary within-Nigeria analysis ✓

**Why it's novel:**
1. First paper to use the 2014 crash as a natural experiment for the resource curse → health channel with a proper DiD design
2. Classic resource curse literature (Sachs & Warner 1995, 2001) relies on cross-sectional variation (endogenous). This paper uses exogenous time variation in oil prices.
3. Directly tests the fiscal mechanism: oil crash → government health spending cuts → worse child survival
4. Builds on Dube & Vargas (2013) commodities-conflict design but for health outcomes
5. Nigeria-centered policy implications: fiscal diversification as a public health intervention

**Feasibility check:**
- ≥25 countries with oil rents >5% GDP (treated), ~120+ non-oil countries (control) ✓
- 9 pre-treatment years (2005–2013), 11 post-treatment years (2014–2024) ✓
- All data from WB WDI + FRED — reliably accessible APIs ✓
- Pre-trends testable with 9 pre-periods ✓
- Not in APEP list ✓

---

## Idea 2: "Guns Over Vaccines: Military Spending Rigidity and Health Outcomes in Oil-Dependent States"

**Policy:** Same 2014 oil price crash, but focused on the fiscal composition channel. Oil-dependent governments facing revenue shortfalls often protect military/security budgets while cutting social spending. This "guns over vaccines" trade-off has distributional consequences for child health.

**Outcome:** Military expenditure (% GDP), health expenditure (% GDP), under-5 mortality, DPT immunization — World Bank WDI.

**Identification:** Triple-difference: Oil-dependent countries × post-2014 × high military spending share. Tests whether countries that maintained military spending at the expense of health spending saw worse child outcomes.

**Why it's novel:** First to quantify the intra-fiscal trade-off (military vs health) during a commodity price shock and its human development consequences. Speaks to the "butter vs guns" literature with clean identification.

**Feasibility check:** Same data as Idea 1. WB has military spending for 25 non-null obs in Nigeria and ~170 countries globally. ✓

---

## Idea 3: "The Oil Crash and Nigerian Children: Subnational Evidence from DHS"

**Policy:** 2014 oil price crash. Nigeria's 9 oil-producing states (Niger Delta: Rivers, Delta, Bayelsa, Akwa Ibom, Edo, Ondo, Imo, Abia, Cross River) receive 13% derivation revenue from oil. When prices crashed, these states lost disproportionate revenue.

**Outcome:** DHS state-level indicators: under-5 mortality, vaccination coverage, stunting, anemia, educational attainment.

**Identification:** DiD: Oil-producing states × post-2014 (comparing 2013 DHS to 2018/2024 DHS).

**Why it's novel:** First subnational analysis of oil revenue shocks → health in Nigeria using DHS.

**Feasibility concern:** Only 3 state-level DHS waves (2013, 2018, 2024). Cannot test pre-trends at state level. Zone-level data (6 zones) available from 2003/2008/2010 for pre-trends, but limited power. Only 9 oil-producing states as "treated" — below the ≥20 threshold. **This idea works as a supplementary analysis within Idea 1, not as a standalone paper.**

---

## Idea 4: "Petrodollars and Protests: Oil Revenue Shocks and Social Unrest in Developing Countries"

**Policy:** 2014 oil price crash → fiscal austerity → reduced public services → popular grievance → protests/unrest.

**Outcome:** World Bank governance indicators (voice and accountability, political stability, government effectiveness) + Cross-National Time-Series Data Archive protest indicators.

**Identification:** Bartik DiD: Oil dependence × post-2014 → governance/unrest outcomes.

**Why it's novel:** Links commodity shocks to social stability through the fiscal austerity channel (complements Dube & Vargas conflict channel).

**Feasibility concern:** Governance indicators are annual and somewhat coarse. Protest data from alternative sources (ACLED, GDELT) would be better but inaccessible from current environment. **Weaker than Idea 1.**

---

## Idea 5: "Nigeria's 2023 Fuel Subsidy Removal and Household Welfare"

**Policy:** President Tinubu removed Nigeria's fuel subsidy on May 29, 2023. Gasoline prices tripled overnight (₦185 → ₦500+). The largest fiscal reform in Nigerian history (savings: ~₦3.6 trillion/year).

**Outcome:** DHS 2024 vs 2018 — health, nutrition, education indicators by state. States vary in exposure based on urbanization, transport dependence, distance to fuel depots.

**Identification:** DiD: High-exposure states × post-2023.

**Feasibility concern:** Only 2 DHS time periods (2018, 2024). Cannot test pre-trends. Very recent — many confounds between 2018 and 2024 (COVID-19, exchange rate crisis, inflation). **Not viable as standalone.**
