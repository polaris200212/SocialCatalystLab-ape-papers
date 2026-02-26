# Research Ideas

## Idea 1: Cantonal Minimum Wages and Low-Wage Employment in Switzerland

**Policy:** Five Swiss cantons adopted cantonal minimum wages in staggered fashion: Neuchâtel (Aug 2017, CHF 19.78/hr), Jura (Jan 2018, CHF 20/hr), Geneva (Nov 2020, CHF 23/hr), Ticino (Jan 2021, CHF 19-19.50/hr, sector-specific), Basel-Stadt (Jul 2022, CHF 21/hr). The remaining 21 cantons have no minimum wage, after a federal proposal was rejected in the 2014 referendum by 76%.

**Outcome:** Employment (number of workers, FTEs) by canton and NOGA economic sector from the BFS STATENT (Structural Enterprise Statistics), annual, 2011–2023. The STATENT is administrative data derived from OASI social security registers — it is a census, not a sample. Available via BFS PXWeb API (confirmed accessible, table px-x-0602010000_101). Also: SECO registered unemployment by canton (monthly).

**Identification:** Staggered difference-in-differences using Callaway & Sant'Anna (2021) estimator. Treatment: canton adopts minimum wage in year t. Control: 21 never-treated cantons. Unit of analysis: canton × NOGA sector × year (5 treated cantons × ~20 low-wage sectors = ~100 treated clusters). Pre-treatment: 6 years (2011-2016) before first adopter (Neuchâtel). The five adoption dates (2017, 2018, 2020, 2021, 2022) provide five distinct treatment cohorts. Triple-difference (canton × sector × time) isolates the effect on low-wage sectors (accommodation/food, retail, cleaning, personal services) vs. high-wage sectors (finance, pharma, ICT) as placebo.

**Why it's novel:** Only one published paper exists on Swiss cantonal minimum wages: Berger & Lanz (2020, Swiss J. Econ. Stat.) — a survey-based study of restaurants in a single canton (Neuchâtel). One working paper (Zigova & Zwick 2025) studies training effects, not employment. **No published paper exploits the full five-canton staggered adoption with administrative employment data.** Switzerland is a high-wage economy (median CHF ~6,500/month) where cantonal minimum wages represent a Kaitz ratio of ~0.54 — an interesting contrast to the US (Kaitz ~0.35) and Western European settings studied in the literature (UK, Germany, Hungary). The direct democracy channel (4 of 5 cantons adopted via popular referendum) provides plausibly exogenous treatment timing.

**Feasibility check:**
- Variation: 5 treated cantons, 21 controls, staggered 2017-2022 ✓
- Data: BFS STATENT confirmed accessible via PXWeb API (2011-2023, 26 cantons × 96 NOGA sectors) ✓
- Novelty: No multi-canton employment DiD in the literature ✓
- Sample size: 26 cantons × 96 sectors × 13 years ≈ 32,448 canton-sector-year observations ✓
- Risk: COVID overlap for GE/TI/BS; early adopters (NE/JU) are clean pre-COVID

---

## Idea 2: Cantonal Energy Laws and the Building Heating Transition

**Policy:** Swiss cantons adopted comprehensive energy law reforms (Energiegesetz) on a staggered schedule, primarily implementing the Model Cantonal Energy Prescriptions (MuKEn 2014) framework. Early adopters: GR (2010), BE (2011), AG (2012). Mid-wave: BL (2016), BS (2016), LU (2017). Later: FR (2019), AI (2020), ZH (2022), TG (2020), OW, JU. By 2023, 22 of 26 cantons had implemented MuKEn. These reforms mandate renewable energy shares for heating replacement, building envelope standards, and in some cantons near-total bans on new fossil heating installations (Zurich 2022).

**Outcome:** Share of residential buildings using heat pumps vs. oil/gas by municipality/canton, from the Federal Register of Buildings and Dwellings (GWR). Available via opendata.swiss and BFS STAT-TAB (table px-x-0902020100_105): buildings by heating energy source, canton, construction period, year. Also: building permits and construction activity from BFS Bau- und Wohnbaustatistik.

**Identification:** Staggered DiD using Callaway & Sant'Anna. Treatment: canton implements MuKEn-based energy law. Control: 4 cantons that had not yet adopted by end of study period. Unit: canton-year (or potentially municipality-year if municipal data is available across all cantons). Pre-treatment: varies by cohort (up to 12 years for late adopters). The design compares the annual change in the share of buildings with renewable heating before vs. after energy law adoption, across early-adopting and late-adopting cantons. Placebo: new construction vs. existing buildings (new construction is required to comply regardless, so the effect should concentrate in heating replacement of existing buildings).

**Why it's novel:** No published paper uses the staggered cantonal adoption of MuKEn-based energy laws as a natural experiment for causal identification. Existing literature includes: Alberini et al. (2023) on subsidy effectiveness using 432 buildings (cross-sectional), Buso et al. (2022) descriptive comparison of heat pump adoption. The policy question is first-order: Switzerland's building sector accounts for ~25% of CO2 emissions. Whether cantonal regulation actually accelerates the fossil-to-renewable heating transition — or merely relabels trends already underway — is directly policy-relevant. The Swiss setting is unique because some cantons had their MuKEn referendums rejected (AG, SO), providing an additional "near-miss" placebo.

**Feasibility check:**
- Variation: 22 treated cantons over 2010-2022, 4 not-yet-treated controls ✓
- Data: BFS STAT-TAB building energy data confirmed (2009-2023, all cantons) ✓
- Novelty: No causal study using this variation ✓
- Sample size: 26 cantons × ~14 years = 364 canton-years (or 2,100+ municipalities × 14 years) ✓
- Risk: Treatment timing is precise for full law revisions but fuzzy for incremental MuKEn provisions; heating stock data may be slow-moving (annual snapshots of building stock)

---

## Idea 3: The Lex Weber Shock: Second Home Caps and Tourism Labor Markets

**Policy:** On March 11, 2012, Swiss voters approved the "Second Home Initiative" (Zweitwohnungsinitiative / Lex Weber) by 50.6%, capping second homes at 20% of the housing stock in every municipality. The law affected Alpine tourism municipalities disproportionately: municipalities already above the 20% threshold could no longer issue building permits for new second homes, while those below were unaffected. The federal implementation law took effect January 1, 2016. The 2012 vote was extremely close (50.6% yes) and was a surprise outcome that contradicted polls.

**Outcome:** Employment in tourism-related sectors (accommodation, food services, real estate, construction) by municipality from STATENT (annual, 2011-2023). Also: building permits from BFS construction statistics, and real estate prices.

**Identification:** Difference-in-differences comparing municipalities above vs. below the 20% second home threshold before and after the 2012 vote (or 2016 implementation). The binding/non-binding distinction creates a sharp treatment: above-threshold municipalities lose the ability to build new second homes, below-threshold municipalities are unaffected. Unit: municipality × year × sector. This is strengthened by the surprise result of the 2012 vote — municipalities and developers could not have anticipated the outcome. Robustness: RDD around the 20% cutoff (compare municipalities at 19.5% vs 20.5% second home share). Also: dose-response (municipalities at 40% vs 25% second homes faced very different constraints).

**Why it's novel:** Hilber & Schöni (2016, J. Public Economics) studied the housing price effects of Lex Weber but not the labor market consequences. The question of whether restricting housing construction in tourism regions creates unemployment or induces a shift toward higher-value tourism (quality over quantity) is understudied. The municipality-level analysis with 2,100+ units gives excellent statistical power. The setting is policy-relevant: many jurisdictions (e.g., Barcelona, Amsterdam, New Zealand) restrict foreign/second home ownership; understanding the employment consequences informs these debates.

**Feasibility check:**
- Variation: ~500 municipalities above 20% threshold (treated) vs ~1,600 below (control) ✓
- Data: STATENT employment by municipality available via BFS PXWeb; construction permits from BFS ✓
- Novelty: Labor market effects of Lex Weber not studied (Hilber & Schöni focused on prices) ✓
- Sample size: ~2,100 municipalities × 13 years × multiple sectors ✓
- Risk: Need municipality-level second home share data to determine treatment status; may need BFS housing census or are.admin.ch data

---

## Idea 4: Professionalization of Child Protection: The KESB Reform and Family Outcomes

**Policy:** On January 1, 2013, Switzerland replaced lay guardianship authorities (Vormundschaftsbehörden) with professional Child and Adult Protection Authorities (Kindes- und Erwachsenenschutzbehörde, KESB). This was a federal mandate affecting all 26 cantons simultaneously, but cantons organized their KESB units very differently: some created canton-wide centralized authorities, others maintained decentralized regional boards with varying staffing levels and professional qualifications. Several cantons reformed their KESB organizational structure after the initial implementation (AG 2012, AR 2012, BE 2021).

**Outcome:** Child protection cases (out-of-home placements, care orders, guardianships) from KOKES annual statistics, published at cantonal level. Also: cantonal statistics on foster care, institutional care, and voluntary vs. involuntary placements.

**Identification:** Cross-cantonal variation in KESB organization (centralized vs. decentralized, staffing ratios, professional vs. semi-professional staff) as quasi-experimental variation in treatment intensity. This is a dose-response/intensity design rather than a pure staggered DiD. Supplemented by the federal before/after comparison (pre-2013 lay system vs post-2013 professional system). Potential instrument: political composition of cantonal council at time of KESB organizational decisions.

**Why it's novel:** No causal study exists on the effects of child protection professionalization. The KESB reform was highly controversial in Switzerland (multiple popular initiatives attempted to reverse it), making the evidence especially policy-relevant.

**Feasibility check:**
- Variation: Cross-cantonal in organizational structure (26 cantons) ✓ but weaker than staggered adoption
- Data: KOKES statistics published annually (need to verify API access or manual download) ⚠️
- Novelty: Very high ✓
- Sample size: 26 cantons × 10+ years ✓
- Risk: Identification relies on organizational variation (softer than staggered policy adoption); KOKES data may require manual collection; federal mandate means no untreated cantons for a clean DiD

---

## Idea 5: Fiscal Transparency and Government Spending: HRM2 Accounting Reform

**Policy:** Swiss cantons adopted the Harmonized Accounting Model 2 (HRM2 / IPSAS-aligned public sector accounting) on a staggered schedule. Early adopters: ZH (2009), BS (2009). Mid-wave: SG (2013), LU (2012), AR (2012). Later: AG (2016), BE (2015), BL (2017), FR (2018), remaining cantons through 2022. HRM2 replaced the older HRM1 system with accrual-based accounting, requiring cantonal and municipal governments to report pension liabilities, depreciation, and other off-balance-sheet obligations for the first time.

**Outcome:** Cantonal government spending, debt, tax rates from BFS public finance statistics (Eidgenössische Finanzverwaltung). Also: cantonal bond yields or credit ratings if available.

**Identification:** Staggered DiD comparing cantons that adopted HRM2 earlier vs. later. The staggering arose from administrative and political readiness, not fiscal performance — the Conference of Cantonal Finance Directors (FDK) recommended HRM2 in 2008 and cantons adopted as their IT systems and accounting staff were ready. Pre-treatment: up to 8 years for late adopters. Triple-diff: compare municipal finances (which also switched to HRM2 on cantonal timelines) within vs. across cantons.

**Why it's novel:** No causal evidence exists on whether public sector accounting reform actually changes government fiscal behavior. The international IPSAS literature is largely descriptive. The Swiss case — with 26 independent fiscal entities adopting the same reform at different times — provides unique causal leverage.

**Feasibility check:**
- Variation: 26 cantons with staggered adoption over 2009-2022 ✓
- Data: BFS public finance statistics likely available via PXWeb ⚠️ (need to verify)
- Novelty: Very high ✓
- Sample size: 26 cantons × ~14 years = 364 canton-years ✓
- Risk: Small N (26 cantons); need to verify exact HRM2 adoption dates for all cantons; fiscal data may lag
