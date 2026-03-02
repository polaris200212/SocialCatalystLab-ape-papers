# Research Ideas — Close-Election RDD in India

## Idea 1: Criminal Politicians and the Composition of Local Development (TOP PICK)

**Policy:** India's democracy has an exceptionally high share of legislators facing criminal charges (~43% of state MLAs by 2024). The Supreme Court's 2003 mandate requiring candidate affidavit disclosure created the data infrastructure to study this, but existing research relies on a single broad outcome (DMSP nightlights) covering only 2004-2008 elections.

**Outcome:** Multi-dimensional development outcomes from SHRUG: (a) VIIRS nightlights at constituency level (2012-2021, higher resolution than DMSP), (b) Census Village Directory amenities changes 2001→2011 (roads, electricity, water supply, schools, health centers, bank branches), (c) Economic Census firm counts and employment changes, (d) SECC household deprivation scores.

**Identification:** Close-election RDD comparing constituencies where a criminally-accused candidate barely wins vs. barely loses. Running variable: vote margin between criminal and non-criminal candidates. Sharp RDD at margin = 0. ADR affidavit data identifies criminal status (2003-2017 state assembly elections, ~4,000 constituencies per election cycle).

**Why it's novel:** Prakash, Rockmore & Uppal (2019 JDE) is the existing benchmark — but they used (a) DMSP-OLS nightlights only (integer 0-63, top-coded, noisy), (b) only 2004-2008 elections (~1 election cycle per state), (c) no mechanism decomposition into specific public goods. This paper: (i) extends to 2003-2017 elections (3× more variation), (ii) uses VIIRS nightlights (continuous, no top-coding), (iii) decomposes into SPECIFIC village amenities to test whether criminal MLAs harm all public goods equally or target particular channels, (iv) tests whether effects differ by crime type (financial vs. violent), ruling-party alignment, and caste reservation status. The decomposition is the key contribution — knowing WHICH public goods deteriorate under criminal politicians has direct policy implications for monitoring and accountability design.

**Feasibility check:** CONFIRMED. SHRUG bundles pre-linked TCPD elections + ADR affidavit data (`affidavits_clean.dta`, 24+ variables, 2003-2017) + nightlights (DMSP + VIIRS at constituency level) + Census VD + Economic Census. All freely downloadable. Prakash et al. replication data on Mendeley provides validation benchmark. Sample: ~4,000 state assembly constituencies × ~3 election cycles with affidavit data = ~12,000 constituency-elections. Close races (|margin| < 5%) should yield ~2,000+ observations. McCrary test, covariate balance, bandwidth sensitivity all standard.

**Key references:** Prakash et al. (2019 JDE), Chemin (2012 JLE), Vaishnav (2017 book), Poblete-Cazenave (2025 AJPS), George et al. (2019 SCID)

---

## Idea 2: Party Alignment and Village Public Goods: Evidence from Close State Elections in India

**Policy:** Indian fiscal federalism concentrates implementation power at the state level. State MLAs aligned with the ruling party can lobby for better implementation of centrally-sponsored schemes (MGNREGA, PMGSY, Swachh Bharat) in their constituencies. This creates a "patronage channel" in public goods delivery.

**Outcome:** Village-level public goods from SHRUG Census Village Directory (2001 vs 2011): paved roads, electricity supply, tap water, primary/secondary schools, primary health centres, bank branches, post offices. Also: nightlights growth during the MLA's 5-year term.

**Identification:** Close-election RDD between the state ruling party's candidate and the main opposition candidate. Running variable: vote margin. Treatment: constituency represented by an aligned MLA. Sharp RDD.

**Why it's novel:** Asher & Novosad (2017 AEJ:Applied) is the existing benchmark — they showed alignment increases nightlights and private sector employment. But they did NOT examine SPECIFIC public goods via Census Village Directory. I decompose the alignment "benefit" into concrete amenities: do aligned constituencies get more roads, electricity, schools? This reveals whether the alignment effect operates through broad economic growth or targeted infrastructure patronage. The granularity of SHRUG's Village Directory (~640K villages) is what makes this decomposition possible for the first time.

**Feasibility check:** CONFIRMED. SHRUG has TCPD election data with party identification + Census Village Directory 2001/2011 + nightlights at constituency level. Need to identify state ruling party for each election cycle (from ECI data). Sample: ~4,000 constituencies per election × multiple elections. Close races (|margin| < 5%) should be abundant.

**Key references:** Asher & Novosad (2017 AEJ:Applied), Lehne et al. (2018 JDE), Dey & Sen (2016 IZA WP)

---

## Idea 3: Educated Politicians and Human Capital Investment: Close-Election Evidence from India

**Policy:** India's state assembly candidates vary enormously in education — from illiterate to PhD holders. ADR affidavit data records education level for all candidates since 2003. Does electing a more educated politician improve human capital outcomes?

**Outcome:** Census literacy rates (2001→2011 change), SHRUG DISE/UDISE+ school data (enrollment, pupil-teacher ratio, school infrastructure), Census Village Directory education facilities.

**Identification:** Close-election RDD between college-educated and non-college candidates. Running variable: vote margin. Treatment: constituency elects a college-educated MLA. Restrict to races where top-2 candidates differ in education level.

**Why it's novel:** Martinez-Bravo (2017) studied politician education in Indonesia using a different design (randomized municipal elections). No comparable study exists for India using close-election RDD with SHRUG's village-level education outcomes. The interaction between politician education and caste reservation (SC/ST constituencies) could reveal whether education matters more or less in reserved seats.

**Feasibility check:** MODERATE. SHRUG ADR data includes `ed` (education level). Need to verify: (a) how many close races have education-differential top-2 candidates, (b) whether the sample is large enough for RDD. Education is correlated with wealth and criminal status, creating potential confounding — need careful subsample analysis. Village Directory has school counts; DISE has richer education outcomes but may need separate download.

**Key references:** Martinez-Bravo (2017), Clots-Figueras (2012 AEJ:Applied)

---

## Idea 4: Wealthy Representatives and Local Economic Activity

**Policy:** Indian elections have seen rapidly escalating candidate wealth. ADR affidavit data reveals massive variation in candidate assets — from Rs. 0 to Rs. 1,000+ crore. Does electing a wealthier politician help or hurt the local economy?

**Outcome:** Nightlights growth (constituency level), Economic Census firm counts and employment.

**Identification:** Close-election RDD where the treatment is electing the wealthier candidate. In each close race, identify whether the winner or loser had higher net assets. Running variable: vote margin. Fuzzy RDD where crossing the margin threshold changes the probability of "high-wealth" representation.

**Why it's novel:** No published paper studies politician WEALTH effects using RDD. The theoretical prediction is ambiguous: wealthy politicians may invest more (pro-development), extract more (rent-seeking), or simply represent different voter coalitions. The sign of the effect is a genuine empirical question.

**Feasibility check:** MODERATE. SHRUG ADR data includes `assets`, `liabilities`, `cash`, `income`. The challenge is defining "wealthy" vs "not wealthy" — wealth is continuous, not binary. Could use within-race relative wealth (winner richer than median candidate). Sample size should be adequate since nearly all races have wealth variation. But: wealth is correlated with criminal status and party, creating identification concerns.

**Key references:** Fisman et al. (2014 AER) on US politician wealth effects, Vaishnav (2017) on Indian electoral dynamics

---

## Idea 5: Women MLAs and MGNREGA Implementation: Gender and Workfare in India

**Policy:** MGNREGA is India's largest workfare program, guaranteeing 100 days of employment per rural household. Women constitute a large share of MGNREGA workers (~54% of person-days in 2023-24). Does electing a woman MLA increase women's MGNREGA participation or change spending patterns?

**Outcome:** MGNREGA person-days (total and by gender), expenditure per person-day, material-to-wage expenditure ratio, wage payment delays (from MGNREGA MIS at district/block level).

**Identification:** Close-election RDD between male and female candidates in UNRESERVED state assembly constituencies. Running variable: vote margin. Treatment: constituency elects a female MLA.

**Why it's novel:** Baskaran et al. (2023 J. Economic Growth) studied women legislators + nightlights; Clots-Figueras (2011, 2012) studied women + education. No published paper examines women legislators → MGNREGA outcomes. This is policy-relevant because MGNREGA's self-targeting design means differential implementation by MLA gender could have large welfare effects for poor women.

**Feasibility check:** LOW. Two constraints: (a) Sample size — mixed-gender close races in unreserved seats are rare (~5-10% of races have a woman among top-2 candidates), severely limiting the RDD sample. (b) MGNREGA data requires web scraping from nrega.nic.in (no bulk download); constituency-to-GP mapping is complex and imprecise.

**Key references:** Baskaran et al. (2023 J. Econ Growth), Clots-Figueras (2011 JPubE, 2012 AEJ:Applied), Bhalotra & Clots-Figueras (2014 JPubE)
