# Research Ideas

## Idea 1: Tearing the Paper Ceiling — Do Skills-Based Hiring Laws Actually Change Who Works in Government?

**Policy:** Between March 2022 and January 2025, 22+ US states adopted "skills-based hiring" laws or executive orders removing bachelor's degree requirements for state government jobs. Maryland was first (March 2022), followed by Colorado, Tennessee, Utah, Pennsylvania, Alaska, North Carolina, New Jersey, South Dakota, Virginia, Ohio, California, Minnesota, Massachusetts, Washington, Delaware, Georgia, Florida, Missouri, Connecticut, Idaho, Louisiana, Indiana, and New York. Adoption is bipartisan (Republican and Democratic governors).

**Outcome:** American Community Survey (ACS) microdata via IPUMS. Primary outcome: share of state government employees without a bachelor's degree. Secondary outcomes: racial/ethnic composition of state government workforce, earnings by education level, occupational composition. ACS provides ~3.5 million observations per year with class-of-worker (state government), educational attainment, state, occupation, earnings, race/ethnicity, and age. CPS monthly data provides higher-frequency but smaller samples.

**Identification:** Staggered difference-in-differences using Callaway and Sant'Anna (2021) estimator. Treatment: state adoption of skills-based hiring policy. Control: never-treated and not-yet-treated states. 20+ treated states with staggered adoption dates spanning March 2022 to January 2025. 17+ years of pre-treatment data (ACS 2005-2021). Bipartisan adoption reduces political selection concerns.

**Why it's novel:** Only one existing paper touches this policy: Blair, Heck, Corcoran de Castillo, and Debroy (NBER WP 33220, December 2024) — but they study *job postings* and public awareness, NOT actual employment outcomes. Nobody has tested whether removing degree requirements actually changes who gets hired. Separately, the Harvard Business School / Burning Glass Institute report (Fuller et al. 2024) studied the private sector and found only 3.5pp increase in non-degree hiring — suggesting posting changes don't translate to hiring changes. Our paper would be the first to test whether these laws change the actual composition of the public sector workforce.

**Epistemic framing:** The bachelor's degree is the modern equivalent of the priestly credential — it certifies access to knowledge-economy jobs without necessarily teaching job-specific skills. These laws represent the largest policy experiment in "de-credentialization" in American history. If removing the degree requirement doesn't change workforce composition, it suggests the credential is deeply entrenched as an epistemic gatekeeper. If it does change composition without degrading outcomes, the credential was a bottleneck, not a quality filter.

**Feasibility check:** Confirmed: 20+ treated states with documented adoption dates (Maryland March 2022, Tennessee July 2022, Utah December 2022, Pennsylvania January 2023, etc.). ACS data available through 2023, with 2024 expected late 2025. CPS monthly available through December 2025. NCSL, Brookings, NGA, and state executive order databases confirm adoption dates. Policy is bipartisan, staggered, and directly measurable in ACS class-of-worker × education variables.

---

## Idea 2: Does the Internet Kill God? Broadband Rollout and the Decline of Religious Authority in America

**Policy:** Staggered rollout of broadband internet across US counties (2000-2015). FCC Form 477 data provides county-level broadband deployment and subscription data. Treatment intensity varies by county × year, driven by pre-existing telecommunications infrastructure.

**Outcome:** ARDA Religious Congregations and Membership Study (RCMS) at the county level: congregations, members, adherents. Available for 2000, 2010, and 2020. Supplemented by ACS data on clergy employment and ATUS on time spent in religious activities.

**Identification:** Long-difference DiD or instrumental variables. Potential instrument: pre-existing telecom infrastructure (1990s cable TV franchise areas, distance to fiber backbone, terrain ruggedness affecting infrastructure cost). Several precedents: Geraci et al. (2022, JPubE) use distance from telephone exchange in UK; Falck et al. (2014, AER) use pre-existing voice network in Germany.

**Why it's novel:** No causal paper exists on broadband and religious participation — for any country. Downey (2014) argued internet → religious decline but used correlational methods (logistic regression on GSS cross-sections). The European broadband literature has established causal effects on civic participation, political engagement, and media consumption (Geraci et al. 2022; Falck et al. 2014; Bhuller et al. 2013; Olken 2009), but none has specifically examined religious outcomes. This directly tests the Gutenberg thesis: just as the printing press weakened priestly authority over scripture, broadband internet weakened religious institutions' monopoly on moral and spiritual guidance.

**Feasibility check:** CONCERN: RCMS is decennial (only 3 data points: 2000, 2010, 2020). This severely limits panel estimation and pre-trends testing. FCC county-level subscription data begins June 2009, but ZIP-level provider counts available from December 1999. No clean "distance from exchange" instrument exists for the US comparable to European studies. Overall: HIGH NOVELTY but MEDIUM-LOW FEASIBILITY due to thin temporal data.

---

## Idea 3: The Expert Gatekeeper's Scorecard — Does NIH Peer Review Predict Scientific Breakthroughs?

**Policy:** NIH Simplified Review Framework reform (effective January 2025 for applications, January 2026 for unified funding strategy). NIH restructured from 5 evaluation criteria to 3, explicitly to reduce "reputational bias" in peer review. Historical payline system (institute-specific percentile cutoffs) being replaced with unified funding strategy.

**Outcome:** NIH RePORTER API data (funded grants, amounts, PIs, institutions) linked to OpenAlex (publications, citations, disruption index). Could measure whether grants funded under the new system produce different science than those funded under the old system.

**Identification:** RDD at the payline (for historical data) or before-after comparison around the 2025 reform. Jacob & Lefgren (2011, QJE) pioneered the payline RDD; Li & Agha (2015, Science) extended it; Fang et al. (2016, eLife) showed scores explain <1% of variance in productivity; Pier et al. (2018, PNAS) showed reviewers fundamentally disagree on scores. The 2025-2026 reform is a fresh natural experiment.

**Why it's novel:** The literature is active but specific angles remain open. Using the disruption index (CD index) as an outcome — testing whether peer review selects for incremental vs. transformative science — has not been done with causal methods. The 2025 reform is too recent for outcome data.

**Feasibility check:** REJECT. Priority scores are confidential (not in RePORTER API or ExPORTER bulk downloads). Jacob & Lefgren accessed them through special NIH data use agreement (CGAF). The 2025 reform has no post-treatment outcome data yet. We could study only funded grants using public data, but that eliminates the RDD variation. Data access is the binding constraint.

---

## Idea 4: ChatGPT and the Decline of Knowledge Work — Occupation-Level Evidence from the CPS

**Policy:** ChatGPT launch (November 30, 2022) as a universal information technology shock. Differential exposure across occupations based on AI exposure scores (Felten et al. 2021 AIOE scores, Eloundou et al. 2023 GPTs-are-GPTs scores).

**Outcome:** CPS monthly earnings and employment data by occupation (6-digit SOC). Also: Stack Exchange public data dumps (topic-level question volume, quality), Chegg financial data from SEC filings.

**Identification:** Continuous DiD using occupation-level AI exposure as the cross-sectional variation × post-November 2022 indicator. Triple-diff with education level within occupations.

**Why it's novel:** NARROW GAP REMAINS but the field is crowded. Key concern: "AI-exposed jobs deteriorated before ChatGPT" (arXiv:2601.02554, January 2025) shows pre-trends are violated — AI-exposed occupations were declining before the November 2022 launch. Brynjolfsson et al. (QJE 2024) documented productivity gains; Hui, Jin, Li (2024) documented freelancer earnings decline; Humlum & Vestergaard (NBER 2025) found null aggregate effects in Denmark. The pre-trends problem is devastating for identification.

**Feasibility check:** REJECT. Parallel trends assumption is violated (documented in arXiv:2601.02554). The field is already crowded with well-executed papers in top journals. Any marginal contribution risks being scooped or undermined by the pre-trends critique.

---

## Idea 5: The Telegraph and the Market for Local Expertise — Did Information Technology Destroy the Knowledge Monopoly? (1850-1880)

**Policy:** Staggered arrival of telegraph stations across US counties (1848-1880). The telegraph was the first technology to transmit information faster than a person could travel, destroying local information monopolies held by professionals (lawyers, doctors, clergy, merchants).

**Outcome:** IPUMS complete-count census data (1850, 1860, 1870, 1880). Occupation shares for knowledge workers (lawyers, physicians, clergy, teachers) relative to other occupations. No wage data available before 1940.

**Identification:** DiD exploiting staggered telegraph arrival at county level. Instrument: distance to nearest railroad (telegraph lines followed railroads). Precedents: Steinwender (2018, AER) on cotton trade; Koudijs (2016, AER) on financial information.

**Why it's novel:** Nobody has studied how the telegraph affected the LABOR MARKET FOR PROFESSIONALS specifically. Existing work focuses on trade (Steinwender), financial markets (Koudijs), and city growth (Dittmar on the printing press). The epistemic angle — professionals as knowledge gatekeepers — is entirely new.

**Feasibility check:** CONCERN: No wage data before 1940. Limited to extensive margin (occupation shares). Telegraph arrival data needs to be constructed from historical records (Western Union archives, Congressional reports). This is feasible but requires substantial data assembly work that may exceed session capacity. Also, IPUMS complete counts for 1850-1880 are extremely large files.
