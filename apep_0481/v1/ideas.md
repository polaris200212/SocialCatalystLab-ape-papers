# Research Ideas

## Idea 1: Mandates and Mavericks — Gender, Electoral Pathway, and Party Discipline in the German Bundestag

**Policy:** Germany's Mixed-Member Proportional (MMP) electoral system, in which legislators enter parliament via two distinct pathways: (1) direct district mandates (Direktmandate) won by plurality in single-member districts, and (2) party list mandates (Listenmandate) allocated proportionally from closed party lists. List members owe their seats entirely to party rank ordering; district members have an independent constituency base. German parties have adopted internal gender quotas for list positions at staggered dates: SPD (40% zipper lists, 1988), Greens (50% since founding), CDU (33% "quorum," 1996), FDP (no formal quota), CSU (40%, 2010), Linke (50%). These party-level quota changes create time-varying shifts in the gender composition of list vs. district delegations.

**Outcome:** Roll-call voting rebellion rates — individual votes that deviate from the party faction (Fraktion) majority position. Measured using the BTVote V2 dataset (Harvard Dataverse), which contains all ~2,424 roll-call votes (namentliche Abstimmungen) in the Bundestag from 1949 to 2021, covering ~3,500 MPs and ~1,100,000 individual voting decisions. The dataset includes gender, mandate type (list/district), party, electoral safety, and vote characteristics (policy area, initiator).

**Identification:** Triple-difference (DDD) design: Gender × Mandate Type × Party-Term FE. The key parameter is the triple interaction: does the gender gap in party-line deviation differ between list and district members? If the gender gap is identical regardless of mandate type, the mechanism is preferences (women's intrinsic policy positions). If the gender gap only exists for district members (who have an independent electoral base and can afford to deviate), the mechanism is institutional incentives — party dependence constrains behavior regardless of gender. Supplementary RDD: for "dual candidates" who appear on both a district ballot and a party list, use the close-race margin in the district to estimate the causal effect of mandate-type assignment on discipline, with heterogeneity by gender.

**Why it's novel:** Ohmura (2021, *Government and Opposition*) is the closest paper — studies gender and Bundestag rebellion using BTVote but employs only observational regression with controls. No causal identification. Sieberer & Ohmura (2021, *Party Politics*) study mandate type and defection but not the gender interaction causally. Clayton & Zetterberg (2021, *APSR*) is the field's benchmark (17 African legislatures) but uses surveys, not roll-call data. Our paper provides the first causal decomposition of the gender-discipline gap into preferences vs. institutional incentives, exploiting the MMP natural experiment.

**Feasibility check:** Confirmed. BTVote V2 is publicly available on Harvard Dataverse (doi:10.7910/DVN/24U1FR, doi:10.7910/DVN/QSFXLQ, doi:10.7910/DVN/AHBBXY). Gender coded as binary (1=female, 0=male). Mandate type coded (direct/list). ~2,424 RCVs × ~600 MPs per period = ~1.1M individual votes. Free votes (Gewissensentscheidungen) identified by Hohendorf et al. (2022, *WEP*) and can be dropped or analyzed separately. Clustering at party-period level (5-6 parties × 19 periods ≈ 90+ clusters). Abgeordnetenwatch API (CC0 license) available for extending to 20th/21st periods.

---

## Idea 2: Quota Shock and Party Loyalty — How National Gender Quotas Reshape MEP Discipline in the European Parliament

**Policy:** Staggered adoption of binding gender quotas for EP elections across EU member states: France (2000, 50% parity), Belgium (2002, 50%), Portugal (2006, 33%), Slovenia (2006, 35-40%), Spain (2007, 40%), Poland (2011, 35%), Italy (2014, 50%). These quotas exogenously increase the female share of national delegations to the EP.

**Outcome:** MEP party-group loyalty — whether individual MEPs vote with their EP party group position. Measured using VoteWatch Europe (2004-2022) and Hix-Noury-Roland (1979-2009) datasets. Over 12,000 roll-call votes across 9 EP terms. Gender must be merged from EP Open Data Portal biographical records.

**Identification:** Staggered DiD: countries that adopt gender quotas (treatment) vs. countries that do not (control), comparing within-EP-group, across-delegation loyalty rates before and after quota adoption. The CS-DiD estimator handles heterogeneous treatment timing. Event study to test parallel trends in pre-quota periods.

**Why it's novel:** The EP is "almost completely unstudied on gender and party-line deviation" (confirmed by literature review). No paper exploits national quota adoption as an instrument for changes in EP discipline. Speaks to both the gender-politics and European integration literatures.

**Feasibility check:** Partially confirmed. Hix-Noury-Roland dataset freely available. VoteWatch Europe archived at EUI (Cadmus). Gender data must be merged from external source (EP Open Data Portal). Main concern: gender is not native to any voting dataset — assembly required. ~700 MEPs per term provides adequate sample. Staggered adoption across 7+ countries with different timing provides clean variation. However, quotas affect candidate lists, not guaranteed seat composition — compliance varies.

---

## Idea 3: When the Whip Comes Off — Gender Gaps in German Bundestag "Conscience Votes"

**Policy:** The Bundestag periodically declares votes as "Gewissensentscheidungen" (conscience votes) where party discipline is officially suspended. These include votes on embryonic stem cell research (2002, 2008), late-term abortion (1992, 1995), same-sex marriage (2017), organ donation (2020), and assisted suicide (2015, 2020). Hohendorf et al. (2022, *WEP*) document that these free votes are frequent, address a broad range of issues, and display substantial behavioral variation.

**Outcome:** Voting behavior in free votes vs. whipped votes, by gender. Using BTVote V2 plus Hohendorf et al.'s free-vote classification.

**Identification:** Diff-in-diff: Gender gap in vote outcomes on the same topic, comparing whipped votes (party line enforced) to free votes (party line removed). The "treatment" is the removal of party discipline. If gender gaps widen when the whip comes off, this reveals latent preference differences that party discipline normally suppresses. Within-legislator, within-topic variation controls for selection.

**Why it's novel:** Hohendorf et al. (2022) identify free votes as a methodological concern but do not analyze gender differences. This approach reveals the "shadow" of party discipline on gendered representation — how much substantive representation is suppressed by party loyalty norms.

**Feasibility check:** Confirmed. BTVote V2 includes all necessary variables. Hohendorf et al.'s free-vote coding is available (published data). However, the number of free votes is relatively small (~50-100 over 70 years), which limits statistical power. The design is conceptually clean but may be underpowered for detecting modest gender gaps.

---

## Idea 4: Do Quotas Breed Loyalty? Gender, Party Discipline, and the Laranja Problem in Brazil's Chamber of Deputies

**Policy:** Brazil's 2009 gender quota enforcement reform (Law 12.034) changed the candidate quota from "reservar" (reserve slots) to "preencher" (fill slots), requiring parties to actually nominate 30% female candidates. First fully applied in 2014. Female deputies rose from 45 (2006) to 77 (2018) to 91 (2022).

**Outcome:** Party-line deviation rates — comparing individual deputy votes to the party leader's recommendation (orientação de bancada), available from the Câmara dos Deputados open data API. Covers 1999-present with complete party orientation records.

**Identification:** DiD: party-level variation in quota compliance gap (distance between pre-2009 female candidate share and 30% threshold) × post-2009. Compare discipline of quota-induced female deputies (entered post-reform in parties with large compliance gaps) vs. pre-reform female deputies vs. male deputies.

**Why it's novel:** Brazilian party discipline and women's representation are studied as separate literatures (Figueiredo & Limongi vs. Htun & Weldon). Nobody has merged roll-call votes with party orientations and gender. The fragmented party system (20+ parties) provides a "boundary test" for theories developed in two-party systems.

**Feasibility check:** Partially confirmed. API functional (dadosabertos.camara.leg.br). R packages available (congressbr, electionsBR). However, female representation is very low (8-18%), limiting statistical power for within-party comparisons. The "laranja" problem (dummy female candidates) means the 2009 reform may not have generated a clean discontinuity in the TYPE of women elected. Treatment is muddied.
