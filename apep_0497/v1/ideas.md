# Research Ideas — apep_0497

## Idea 1: Who Captures a Tax Cut? Property Price Capitalization from France's €20B Taxe d'Habitation Abolition

**Policy:** France abolished the taxe d'habitation (TH) on primary residences between 2018 and 2023. The reform was phased by household income: 80% of households (below ~€27,000 RFR for singles) received progressive relief in 2018-2020 (30%, 65%, 100%); the remaining 20% were phased out in 2021-2023. This was a €23.4B annual tax elimination — the largest residential property tax abolition in any OECD country in recent decades.

**Outcome:** Property transaction prices from the DVF (Demandes de Valeurs Foncières), covering the universe of property sales in France 2014-2024 (~25M transactions).

**Identification:** Staggered continuous DiD exploiting two sources of variation:
1. **Cross-commune TH rate variation:** Pre-reform TH rates ranged from ~5% to >30% of valeur locative cadastrale. Communes with higher TH rates experienced a larger effective tax cut per property.
2. **Income-based phase-in timing:** Communes with higher shares of below-threshold households (from Filosofi) received effective tax relief earlier (2018) than affluent communes (2021-2023). This creates staggered treatment timing.
3. **Built-in placebo:** Secondary residences were EXEMPT from the TH abolition (and actually received a surtax in "zones tendues"). Communes with high secondary residence shares (coastal/mountain resorts) were less treated. This provides a natural control group.

Modern staggered DiD (Callaway-Sant'Anna) for the phased rollout; HonestDiD sensitivity for parallel trends; heterogeneity by housing supply elasticity (dense urban vs. elastic rural); mechanism decomposition: immediate vs delayed capitalization, transaction volume effects, seller vs buyer capture.

**Why it's novel:** The only existing study is IPP Report No. 48 (Bach et al. 2023), a government-commissioned policy report using basic TWFE with no causal identification strategy, no event study, no modern estimators, no supply elasticity channel, and no welfare analysis. No journal paper exists. This is the first causal study of the largest residential property tax elimination in modern OECD history, using universe transaction data.

**Feasibility check:** CONFIRMED. DVF (2014-2024, open), REI tax rates (1982-present, open), Filosofi income (2012-2021, open), RP housing census (2010-2022, open). All downloadable as CSV. Alsace-Moselle excluded from DVF (dropped from analysis). 35,000+ communes provide massive N for DiD. Pre-reform period 2014-2017 gives 4 years of pre-trends.

---

## Idea 2: Maternity Ward Closures and Birth Outcomes in France

**Policy:** France has systematically closed small maternity wards since the 1990s, driven by safety regulations requiring minimum delivery volumes (300/year, later raised). Over 400 maternity units closed between 1997 and 2019, increasing travel distances for pregnant women in rural areas.

**Outcome:** Commune-level birth statistics from INSEE état civil (birth weight, prematurity, neonatal mortality) linked to hospital-level data from DREES SAE (Statistique Annuelle des Établissements de santé).

**Identification:** Staggered DiD around maternity ward closure events. Treatment = communes whose nearest maternity ward closes. Control = communes whose nearest ward remains open. Event-study design centered on closure year.

**Why it's novel:** While maternity ward closures are studied in the US (Lindo 2010, Grzenda & Ayyagari 2022), there is limited causal evidence from France despite the much larger scale of closures. The centralized closure process (driven by regulatory volume thresholds) provides a cleaner quasi-experiment than US market-driven closures.

**Feasibility check:** UNCERTAIN. SAE hospital-level data is on data.gouv.fr but the specific closure date fields need verification. Commune-level birth statistics are available from INSEE but the birth outcome granularity (birth weight, prematurity) may require SNDS access rather than open état civil data. Need to verify whether open-access data has sufficient outcome detail.

---

## Idea 3: Low-Emission Zones (ZFE) and Property Values at City Boundaries

**Policy:** France's ZFE-m (Zones à Faibles Émissions - mobilité) restrict older, more polluting vehicles from entering designated urban areas. Paris implemented Crit'Air restrictions from 2015, with expansion waves in 2017, 2019, and 2021. Lyon, Grenoble, Strasbourg, and other cities followed with staggered implementation from 2019-2024.

**Outcome:** DVF property transactions near ZFE boundaries; air quality from ATMO regional monitoring networks (open data on data.gouv.fr).

**Identification:** Spatial RDD at ZFE boundaries: compare property prices just inside vs. just outside the restricted zone. Combine with temporal variation from staggered city adoption for a difference-in-discontinuities design.

**Why it's novel:** Growing literature on low-emission zones in Germany (Gehrsitz 2017) and London (ULEZ studies), but limited causal evidence from France's distinctive Crit'Air system. The multi-city staggered adoption strengthens identification.

**Feasibility check:** PARTIALLY CONFIRMED. DVF provides geocoded transactions; ZFE boundary shapefiles need verification on data.gouv.fr. Air quality monitoring stations may be too sparse for fine-grained spatial analysis. Boundary precision is critical for RDD validity.

---

## Idea 4: Municipal Mergers (Communes Nouvelles) and Local Public Goods

**Policy:** France's 2015 reform (loi NOTRe + incentives in PLF 2016) encouraged voluntary municipal mergers ("communes nouvelles"). Over 2,500 communes merged into ~800 communes nouvelles between 2015 and 2020, reducing the total number of French communes from ~36,700 to ~34,900.

**Outcome:** Property values (DVF), public service locations (Base Permanente des Équipements), municipal budget data (DGFiP comptes des communes).

**Identification:** Event-study DiD comparing merged communes to similar-sized non-merged communes. Exploit the voluntary but incentivized nature: fiscal incentives (maintaining dotation forfaitaire for 3 years) created a wave of adoptions. Match merged communes to never-merged controls.

**Why it's novel:** Municipal mergers are studied in Denmark (Blom-Hansen et al. 2016) and Japan, but France's massive voluntary merger wave is understudied. The property value channel (do mergers signal better governance → higher prices, or loss of local identity → lower prices?) is unexplored.

**Feasibility check:** CONFIRMED for data (DVF, commune boundary changes from COG, budget data from DGFiP). UNCERTAIN on identification — voluntary selection into merging is a serious endogeneity concern. Matching on pre-merger characteristics may not resolve this fully.

---

## Idea 5: Sunday Trading Liberalization and Local Retail Markets

**Policy:** The Loi Macron (August 2015) expanded Sunday trading rights in France by creating "Zones Touristiques Internationales" (ZTI) in major cities. 12 ZTIs were designated in Paris, plus zones in Nice, Cannes, and Deauville. Shops in ZTIs can open every Sunday without prefectoral authorization.

**Outcome:** Firm-level outcomes from INSEE Sirene (firm creation, closure, employment via DADS), property rents from DVF.

**Identification:** Spatial DiD comparing retail establishments inside vs. outside ZTI boundaries, before vs. after designation. The sharp spatial boundary allows difference-in-discontinuities.

**Why it's novel:** Sunday trading effects are studied in Germany (Kirchner & Painter 2024) and the Netherlands, but France's ZTI system — creating sharp spatial discontinuities in trading rights within the same city — provides an unusually clean natural experiment.

**Feasibility check:** PARTIALLY CONFIRMED. ZTI boundaries are published in JORF. Sirene provides firm locations. But employment outcomes (DADS) require restricted access. Without employment data, the paper is limited to firm creation/closure — which may be too narrow.
