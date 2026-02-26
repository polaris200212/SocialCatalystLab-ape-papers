# Research Ideas

## Idea 1: Second Home Caps and Local Labor Markets — RDD at the 20% Threshold (Lex Weber)

**Policy:** Switzerland's Second Home Initiative (Zweitwohnungsinitiative), approved March 11, 2012. Federal constitutional amendment (Art. 75b BV) prohibiting new second-home construction in municipalities where second homes exceed 20% of total housing stock. Implemented via Federal Second Homes Ordinance from January 1, 2013, and Second Homes Act (ZWG) from January 1, 2016. Approximately 360 municipalities were above the 20% threshold.

**Outcome:** Municipal-level employment by sector (STATENT, annually from 2011), tourism overnight stays (BFS Beherbergungsstatistik, HESTA), municipal unemployment rates, construction permits (BFS Bau- und Wohnbaustatistik), and municipal population dynamics. All available at the Gemeinde level from BFS/opendata.swiss.

**Identification:** Sharp RDD at the 20% second-home share threshold. Running variable: pre-initiative municipal second-home share (measured by BFS from federal building/housing register GWR). Municipalities just above 20% face binding construction restrictions; those just below do not. Compare outcomes for municipalities in a narrow bandwidth around the 20% cutoff. Validity: McCrary density test for bunching at threshold; covariate balance on pre-treatment characteristics (population, altitude, language region, income level); bandwidth sensitivity using Calonico-Cattaneo-Titiunik (2014) optimal bandwidth selection; donut-hole RDD excluding observations very close to cutoff.

**Why it's novel:** Existing literature (Hilber & Schöni; Swiss Journal of Economics and Statistics 2022) uses difference-in-differences comparing all above-20% vs all below-20% municipalities. NO study has applied a proper RDD design exploiting the sharp 20% threshold with local estimation. The RDD focuses on the causal effect at the margin — municipalities near the threshold — providing cleaner identification than DiD, which includes municipalities far from the cutoff. Additionally, no study examines labor market outcomes (employment composition, tourism employment, local wages) — existing work focuses on construction permits only.

**Feasibility check:** Confirmed: (1) Second-home share data available on opendata.swiss ("Wohnungsinventar und Zweitwohnungsanteil") at municipal level; (2) Employment by sector from STATENT available from BFS PXWeb; (3) Tourism overnight stays from HESTA; (4) ~360 treated municipalities with continuous running variable = high power for RDD; (5) 10+ years post-treatment (2013-2024); (6) Not overstudied — Google Scholar shows <20 papers on Lex Weber, none using RDD.


## Idea 2: Does Democracy Scale? Municipal Population Thresholds and Governance Quality in Switzerland

**Policy:** Swiss cantons mandate different governance structures based on municipal population thresholds. Key example: Canton Vaud requires municipalities above 800 inhabitants to establish a formal Conseil général (municipal parliament) instead of assemblée communale (town meeting). Other cantons have similar thresholds at varying population levels. These thresholds determine whether legislative decisions are made by direct citizen assembly or elected representatives.

**Outcome:** Municipal expenditure per capita, tax multipliers (Steuerfuss), debt levels, investment spending, and voter turnout — all from BFS municipal finance statistics and political statistics.

**Identification:** Sharp RDD at cantonal population thresholds. Running variable: municipal population. Municipalities just above the threshold must adopt representative governance; those just below retain direct assembly democracy. This is similar to Gagliarducci & Nannicini (2013) for Italian mayors, but applied to governance structure rather than mayor pay.

**Why it's novel:** While population-threshold RDD designs are common in other countries (Italy, Brazil, Germany), the Swiss setting is uniquely interesting because the treatment is governance TYPE (assembly vs. parliament) rather than just administrative resources. Switzerland's tradition of Gemeindeversammlung (direct assembly democracy) is globally unique — studying where this transitions to representative democracy addresses fundamental questions about democratic design.

**Feasibility check:** Partially confirmed: (1) Population data available from BFS; (2) Municipal finance data available; (3) Governance structure data needs verification — exact thresholds must be confirmed for each canton from cantonal legislation; (4) Sample size may be limited if focusing on single canton (Vaud: ~300 municipalities); (5) Novelty: High — no RDD on Swiss governance thresholds found.


## Idea 3: Do Municipal Mergers Save Money? RDD Evidence from Swiss Merger Referendums

**Policy:** Swiss municipalities regularly vote on proposed mergers. Between 2000-2025, the number of municipalities fell from ~2,900 to ~2,100 through hundreds of mergers. Each merger requires referendum approval in EACH participating municipality. A merger proposal that barely passes (>50%) in all constituent municipalities goes through; if any municipality votes no, the merger fails.

**Outcome:** Municipal expenditure per capita, administrative costs, tax rates, public service quality indicators, and political participation — from BFS Finanzstatistik der Gemeinden.

**Identification:** Sharp RDD at the 50% vote threshold. Running variable: referendum vote share in the pivotal municipality (the one closest to 50%). Mergers where the closest vote was just above 50% (approved) vs. just below (rejected) provide quasi-random assignment of merger treatment. Validity: vote share running variable is difficult to manipulate in close elections (standard assumption in election RDD literature). McCrary test, covariate balance, bandwidth sensitivity.

**Why it's novel:** Existing work on Swiss municipal mergers uses DiD (Frey 2023 on political participation) or synthetic control. No study has exploited the referendum vote margin as an RDD running variable. This is the first RDD on municipal mergers globally, addressing a fundamental public economics question: do mergers generate scale economies?

**Feasibility check:** Partially confirmed: (1) Municipal finance data available from BFS; (2) SMMT tracks which municipalities merged and when; (3) Individual referendum vote shares may NOT be centrally available — would need to be collected from cantonal sources; (4) Sample size depends on number of close votes among ~500+ merger events; (5) Data collection is the main bottleneck.


## Idea 4: Does Pay Transparency Close the Gender Gap? Firm-Size RDD on Switzerland's Equal Pay Mandate

**Policy:** Revised Federal Gender Equality Act (Gleichstellungsgesetz, GlG), effective July 1, 2020. Firms with ≥100 employees must conduct an internal equal pay analysis (using the government's Logib tool), have it verified by an external auditor, and communicate results to employees. The 100-employee threshold creates a sharp discontinuity.

**Outcome:** Gender pay gap, female employment share, firm hiring patterns, and wage distributions — ideally from Swiss Earnings Structure Survey (Lohnstrukturerhebung, LSE) or SAKE/SLFS labor force survey.

**Identification:** Sharp RDD at the 100-employee threshold. Running variable: number of employees. Firms just above 100 must comply with transparency mandate; those just below face no requirement. Compare gender pay gaps and female employment in firms near the threshold. Standard firm-size RDD (Calonico et al. bandwidth, McCrary for bunching at 100, covariate balance on sector, region, firm age).

**Why it's novel:** While pay transparency laws have been studied in Denmark (Bennedsen et al. 2022) and the UK, Switzerland's mandatory ANALYSIS requirement (not just disclosure) is a stronger treatment. No empirical RDD study exists on the Swiss mandate.

**Feasibility check:** LOW FEASIBILITY: (1) The key barrier is micro-data access — firm-level wage data near the 100-employee threshold is restricted; (2) LSE and SAKE require BFS special access permission; (3) Without firm-level data, cannot implement RDD; (4) Could potentially use aggregate data by size class, but this is too coarse for RDD.


## Idea 5: Minimum Wages at the Border: Spatial RDD Evidence from Swiss Cantonal Minimum Wages

**Policy:** Five Swiss cantons have introduced cantonal minimum wages: Neuchâtel (CHF 20/hr, 2017), Jura (CHF 20/hr, 2017), Geneva (CHF 23/hr, 2020), Ticino (varying, 2021), and Basel-Stadt (CHF 21/hr, 2021). These create sharp spatial discontinuities at canton borders — municipalities on one side face minimum wages while neighboring municipalities do not.

**Outcome:** Employment, wages, hours worked, and firm entry/exit at the municipal or firm level — from BFS STATENT and SLFS/SAKE.

**Identification:** Spatial RDD at canton borders. Running variable: distance to the canton border between minimum-wage and non-minimum-wage cantons. Municipalities just inside the minimum-wage canton vs just outside provide quasi-random treatment variation. Multiple border pairs: Geneva-Vaud, Neuchâtel-Bern, Basel-Stadt-Basel-Landschaft, Jura-Bern, Ticino-Graubünden.

**Why it's novel:** Spatial RDD on minimum wages is established (Dube, Lester, Reich 2010 for US counties), but has NEVER been applied to Switzerland. Swiss setting offers unique advantages: (1) very high minimum wages (CHF 20-23/hr are among world's highest); (2) tight labor markets; (3) cross-border commuter flows add complexity; (4) multiple treated borders for heterogeneity analysis.

**Feasibility check:** Partially confirmed: (1) Employment data available from STATENT at municipal level; (2) Geographic assignment to border municipalities straightforward using BFS commune data; (3) Concern: limited number of border municipalities per pair (each pair may have only 10-30 municipalities on each side); (4) Multiple pairs can be pooled for power; (5) Commuter flows complicate interpretation (SLFS has commuting data).
