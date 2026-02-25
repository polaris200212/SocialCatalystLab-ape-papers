# Research Ideas

## Idea 1: Wind Farms and Property Values in France

**Policy:** Onshore wind farm installations across France, staggered continuously from 2005-2025. The ODRE registry documents 2,400 wind installations across 1,451 unique communes with precise commissioning dates. Treatment: first wind farm commissioning in a commune.

**Outcome:** Property transaction prices from DVF (Demandes de Valeurs Foncières), available 2020-2025 with commune-level INSEE codes. Approximately 500,000+ residential transactions per year across France.

**Identification:** Staggered DiD (Callaway & Sant'Anna 2021). Treatment cohorts defined by year of first wind installation. For cohorts 2022-2025, we have 2-5 pre-treatment years (2020-2021+). ~216 newly treated communes in this window; ~34,000+ never-treated communes as controls. Event study specification to test parallel trends pre-treatment and estimate dynamic effects post-commissioning.

**Why it's novel:** A 2024 meta-analysis (Environmental and Resource Economics) reviews 25 hedonic studies — none from France. The 2024 PNAS study uses 300M US transactions and 60,000 turbines, finding ~1% effects within viewshed. France has zero rigorous causal evidence despite being Europe's second-largest wind market and having fierce local opposition (contentieux éolien is a major political issue). The combination of ODRE + DVF commune-level data has never been exploited.

**Feasibility check:**
- Variation: ✓ 50-100 newly treated communes per year, continuous staggering
- Data access: ✓ ODRE API returns 2,400 wind records (smoke tested). DVF bulk CSVs available for 2020-2025 (~100MB/year).
- Novelty: ✓ No French causal evidence exists. Not in APEP list.
- Sample size: ✓ ~216 treated communes (2022-2025), ~34,000 controls. Thousands of transactions per commune-year.

**DiD Feasibility:**
- Pre-treatment periods: 2-5 years (2020-2021 minimum for 2022 cohort)
- Treated clusters: ~216 communes (well above 20)
- Selection: Wind farm siting is driven by wind resource availability and permitting — largely exogenous to housing price trends (can test with pre-trends)
- Comparison group: Never-treated communes matched on département, population, rurality


## Idea 2: Vacancy Tax Expansion and Housing Markets

**Policy:** The Taxe sur les Logements Vacants (TLV) was massively expanded in August 2023 (Décret 2023-822), adding 2,263 communes to the 1,151 already covered. The new communes are predominantly small coastal and mountain tourism areas — a fundamentally different context from the original large-agglomeration designation.

**Outcome:** DVF property transactions (prices, volumes, property types) in newly designated vs. control communes, 2020-2025.

**Identification:** DiD comparing newly designated communes (2023 expansion) to similar undesignated communes. Pre-treatment: 2020-2022. Post-treatment: 2024-2025. Sharp timing (decree effective January 2024).

**Why it's novel:** Segu (2020, Journal of Public Economics) studied the original 1999 introduction. The 2023 expansion targets a completely different population (tourism/second-home communes vs. large agglomerations), allowing a test of whether vacancy taxation works in markets dominated by secondary residences rather than speculative vacancy. This is a distinct economic question.

**Feasibility check:**
- Variation: ✓ 2,263 newly treated communes, sharp cutoff January 2024
- Data access: ✓ Commune list available via decree. DVF 2020-2025 available.
- Novelty: ✓ 2023 expansion completely unstudied. Different context from Segu (2020).
- Sample size: ✓ Very large N. Risk: only 1-2 years of post-treatment data.

**DiD Feasibility:**
- Pre-treatment periods: 3 years (2020-2022) — adequate
- Treated clusters: 2,263 communes — excellent
- Selection: Designation criteria based on housing market tension indicators (vacancy rates, price/income ratios) — potential endogeneity that can be addressed with boundary/threshold design
- Comparison group: Communes just below designation threshold


## Idea 3: Municipal Mergers and Local Economic Activity

**Policy:** France's Loi Pélissard (2015) catalyzed a wave of voluntary municipal mergers ("communes nouvelles"). ~800 communes nouvelles created between 2015-2025, absorbing ~2,500 former communes. Major waves in 2016 (~317), 2017 (~182), and 2019 (~238). Financial incentive: guaranteed DGF (Dotation Globale de Fonctionnement) for 3 years.

**Outcome:** Firm creation and survival from INSEE Sirene (establishment-level data with creation/closure dates and commune codes). Secondary: DVF property values (limited to 2020+).

**Identification:** Staggered DiD comparing merged communes to similar non-merged small communes. Treatment defined by merger effective date. Callaway & Sant'Anna with multiple cohorts (2016, 2017, 2018, 2019).

**Why it's novel:** No rigorous causal study of the economic effects of French municipal mergers exists. International literature on municipal mergers (Denmark, Japan, Switzerland) shows mixed effects. France is unique: mergers of very small communes (often <1,000 pop) with strong financial incentives. The question "Does administrative consolidation attract firms to rural areas?" is first-order for French territorial policy.

**Feasibility check:**
- Variation: ✓ ~800 mergers with clear effective dates, staggered across years
- Data access: ✓ Merger list on data.gouv.fr + INSEE COG. Sirene API for firm data.
- Novelty: ✓ No causal economic evidence for France.
- Sample size: ✓ Hundreds of treated units. Sirene has millions of establishments.

**DiD Feasibility:**
- Pre-treatment periods: Variable. For 2019 cohort using Sirene (available back to 2000s): many pre-periods. For DVF: only 2020+ (post-treatment for most cohorts — not viable).
- Treated clusters: ~800 communes nouvelles
- Selection: Voluntary mergers — selection concern. Need to control for observable characteristics and test pre-trends rigorously.
- Comparison group: Small communes that never merged, matched on population/département


## Idea 4: Energy Efficiency Labels and Housing Price Capitalization

**Policy:** France's Loi Climat et Résilience (2021) imposed a progressive ban on renting energy-inefficient properties: G-rated banned from January 2025, F-rated from 2028, E-rated from 2034. The DPE (Diagnostic de Performance Énergétique) became legally binding ("opposable") in July 2021.

**Outcome:** DVF property transactions, exploiting the DPE rating included in post-2021 transactions. Compare price trajectories of F/G-rated vs. A-D rated properties as the ban approaches.

**Identification:** DiD comparing properties with poor DPE ratings (G, then F) to well-rated properties (A-D), before and after the announcements/deadlines. The stagger comes from the progressive schedule (G first, then F, then E). Triple-diff possible: DPE rating × post-announcement × rental market exposure.

**Why it's novel:** International energy efficiency capitalization literature exists but the French "passoire thermique" ban is uniquely strong — an outright prohibition on renting. No other country has imposed such a severe penalty. The anticipation effects are theoretically interesting: do markets price in future rental bans?

**Feasibility check:**
- Variation: ✓ Progressive deadlines create natural stagger. Within-commune variation in DPE ratings.
- Data access: ⚠️ UNCERTAIN. DVF may not consistently include DPE ratings. The ADEME DPE database exists separately but linkage to transactions is non-trivial.
- Novelty: ✓ French ban is unique globally. Limited causal evidence.
- Sample size: ✓ If DPE is in DVF, very large N. If not, linkage challenge.

**DiD Feasibility:**
- Pre-treatment periods: Depends on DPE data availability in DVF
- Treated clusters: Properties with G/F ratings (millions nationwide)
- Selection: DPE rating is determined by building characteristics — exogenous to price trends conditional on location and building type
- Comparison group: Well-rated properties in same commune/building type
