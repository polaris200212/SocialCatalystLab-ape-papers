# Research Ideas — Teacher Pay and Learning Outcomes in the UK

## Idea 1: The Decade of Decline: How the Austerity Pay Squeeze on Teachers Shaped Student Achievement in England

**Policy:** The 2010-2019 UK public-sector austerity regime imposed a 1% pay cap on teachers, reducing real pay by approximately 8%. Teacher pay is nationally set via the School Teachers' Pay and Conditions Document (STPCD), but private-sector wages vary substantially across Local Authorities. This created differential "competitiveness shocks" — in LAs where private-sector wages grew rapidly (London fringe, tech corridors), teacher pay became far less competitive; in stagnating post-industrial areas, the gap barely moved.

**Outcome:** GCSE Attainment 8 scores, 5+ A*-C GCSE pass rates, Progress 8, teacher vacancy rates, and teacher leaving rates — all available at LA level from DfE Explore Education Statistics and the School Workforce Census (2010/11-2023/24).

**Identification:** DR-AIPW. Define treatment as the cumulative decline in the teacher-to-private-sector-wage ratio at the LA level, 2010-2019. Use doubly robust AIPW estimation: (1) propensity score model predicting treatment intensity from baseline LA characteristics (2010 deprivation, urbanity, region, ethnic composition, baseline GCSE attainment, FSM%); (2) outcome regression model for post-austerity GCSE outcomes conditional on covariates. The AIPW estimator is consistent if either model is correctly specified. Include overlap diagnostics, trimming, and Rosenbaum-style sensitivity analysis for hidden bias.

**Data:** NOMIS ASHE (NM_99_1) for median annual gross pay by LA district, 1997-2025 (verified accessible). DfE KS4 performance data by LA, 2009/10-2024/25 (verified accessible as CSV). DfE SWC for teacher vacancies/retention by LA, 2010/11-2023/24 (verified accessible). ONS population and deprivation data via NOMIS.

**Why it's novel:** While Britton & Propper (2016) study teacher pay competitiveness and hospital outcomes, and Burgess et al. (2022) study the 2013 PRP reform, no paper has (a) used the decade-long austerity pay squeeze as a natural experiment for student outcomes, (b) applied doubly robust methods to the teacher pay competitiveness question, or (c) quantified the mechanism chain from pay competitiveness → vacancies → student achievement at scale. The UK's unique institutional setting (nationally set pay, locally varying labor markets) provides unusually clean identification of the competitiveness channel.

**Feasibility check:** Confirmed — all four data sources return real data via API/download. NOMIS ASHE covers ~370 LA districts × 14 years. DfE KS4 covers ~150 LAs × 16 years. Full overlap in coverage.

**Mechanism chain:** Pay squeeze → teacher pay becomes uncompetitive → vacancies rise, retention falls → replacement teacher quality declines (or positions go unfilled) → student outcomes deteriorate. Each link observable in the data.

---

## Idea 2: Teaching the STEM Gap: Training Bursary Shocks, Recruitment Quality, and Subject-Level Student Outcomes

**Policy:** UK initial teacher training (ITT) bursaries vary dramatically by subject and year — physics trainees receive £29,000 (2025/26) while English trainees receive £5,000. These amounts change annually by £3,000-5,000, creating plausibly exogenous variation in the financial incentive to enter specific teaching subjects.

**Outcome:** GCSE results by subject (physics, chemistry, maths, English, history) at the school level, available from DfE subject-level exam data.

**Identification:** Define treatment at the subject × cohort level: subjects experiencing a large bursary increase (≥£5K) vs. those with stable or declining bursaries. Use DR to compare GCSE results in "treated" subjects 3-4 years later (once the bursary cohort enters classrooms), conditioning on school characteristics and pre-treatment subject-level attainment.

**Data:** DfE published bursary amounts by subject and year. DfE subject-level GCSE results by school. ITT recruitment numbers from DfE Census data.

**Why it's novel:** Bursary variation has been used to study recruitment numbers (Allen et al.) but not traced through to subject-specific student outcomes using DR methods.

**Feasibility check:** Confirmed — DfE publishes subject-level school data (737K+ rows). Bursary schedules are publicly documented. The 3-4 year lag between bursary and classroom entry reduces observations but is identifiable. ~66 subjects × ~10 bursary-year cohorts × ~5,700 secondary schools.

---

## Idea 3: Deregulation Without Deviation: Academy Pay Freedom and the Paradox of Unused Autonomy

**Policy:** Since the 2010 Academies Act, 10,700+ English schools have converted to academy status, gaining freedom to set their own pay outside national STPCD scales. Yet only ~13% of academies actually deviated from national pay — 87% retained the national framework despite having no legal obligation.

**Outcome:** GCSE Attainment 8, Progress 8, teacher vacancy rates — all at school level from DfE/GIAS linkable via URN.

**Identification:** Among academies, compare those that exercised pay deviation vs. those that retained national scales. DR conditions on pre-conversion school characteristics (Ofsted grade, FSM%, prior attainment, MAT membership, geography) to address selection.

**Data:** GIAS register (school characteristics, academy conversion dates, FSM%). DfE KS4 institution-level data. The key constraint: school-level data on whether the academy deviated from STPCD is not publicly available — it was captured in an LGA survey but not at the school level.

**Why it's novel:** The "paradox of unused autonomy" is itself a contribution — why don't 87% of academies use their pay freedom? If deviation leads to better outcomes, there's a massive coordination failure.

**Feasibility check:** MODERATE — the treatment indicator (STPCD deviation) is not directly observable in public data. Would need to proxy via SWC average pay anomalies or use aggregate data from LGA surveys. This is the key limitation.

---

## Idea 4: Teach First Meets Doubly Robust: The Causal Effect of High-Performing Graduates on Disadvantaged Schools

**Policy:** Teach First, launched in 2003 (London only), expanded to Manchester (2006) and then sequentially to all English regions. It places high-performing graduates (2:1 or above from leading universities) in the most disadvantaged schools for a 2-year placement.

**Outcome:** GCSE results, Ofsted ratings, pupil progress measures — all at the school level.

**Identification:** Compare schools receiving Teach First teachers vs. similar non-Teach First schools. Treatment is determined by school eligibility (high deprivation, within Teach First operating areas) and placement success (not all eligible schools receive a participant). DR-AIPW conditions on school-level deprivation, prior attainment, urban/rural status, school size, and region.

**Data:** Teach First publishes regional and school-type information, though exact placement lists may require FOI or partnership. DfE school-level GCSE data and GIAS register are available.

**Why it's novel:** Allen & Allnutt (2017) studied Teach First using propensity score matching. A DR-AIPW approach with more recent data (2003-2023, 20 years of placements) and modern sensitivity analysis (Oster bounds, Rosenbaum Γ) would extend their work. The 20-year panel also allows study of long-run effects — do Teach First schools sustain gains after participants leave?

**Feasibility check:** MODERATE — school-level placement data may not be publicly available. Allen & Allnutt used restricted NPD data. Without school-level Teach First indicators, this idea faces the same data access problem as Idea 3.

---

## Idea 5: The Competitiveness Cliff: Teacher Pay, Local Labor Markets, and the Widening Achievement Gap in England

**Policy:** Same underlying variation as Idea 1 (nationally set teacher pay × locally varying labor markets), but focused specifically on the equity dimension: whether the austerity pay squeeze disproportionately harmed disadvantaged students.

**Outcome:** GCSE achievement gap between FSM-eligible and non-FSM pupils, by LA — available from DfE KS4 data which reports outcomes by pupil characteristic.

**Identification:** Define treatment as the competitiveness shock (as in Idea 1). Outcome is the change in the FSM-nonFSM achievement gap. DR-AIPW conditions on baseline gap, LA deprivation, school mix, prior attainment levels.

**Data:** Same as Idea 1, plus DfE KS4 data broken down by FSM status (confirmed available: "All state-funded pupil characteristics and geography data" dataset has 342,410 rows with FSM breakdowns).

**Why it's novel:** Combines the teacher pay competitiveness story with an inequality lens. If the pay squeeze caused teacher shortages disproportionately in deprived areas (where outside options matter less but replacement pool is thinner), the gap could widen through a composition channel.

**Feasibility check:** Confirmed — all data sources verified. The FSM-breakdown is explicitly available in the DfE data catalogue. Same data pipeline as Idea 1 with additional outcome variable.
