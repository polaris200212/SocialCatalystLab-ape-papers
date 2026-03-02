# Research Idea Ranking

**Generated:** 2026-02-26T16:12:38.216751
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 8458

---

### Rankings

**#1: Cash Scarcity and Food Prices: Evidence from Nigeria's 2023 Currency Redesign**
- **Score: 77/100**
- **Strengths:** Very high novelty with an unusually sharp, short-lived national shock and exceptionally rich weekly price data with ~20 years of pre-period for credible pre-trend diagnostics. The “intensity” design (financial exclusion/cash dependence) is conceptually tight and parallels a known demonetization identification strategy.
- **Concerns:** Only **15 state-level treatment clusters** (if intensity is only at the state level) makes inference fragile; also worry about **state-varying contemporaneous shocks correlated with financial exclusion** (e.g., insecurity, fuel shortages, election-related disruptions) that could differentially move prices during the same weeks.
- **Novelty Assessment:** **High.** Demonetization is studied (India 2016 especially), but the **Nigeria 2023 redesign** itself appears largely unstudied in causal work, and high-frequency commodity-price impacts are not already “papered to death.”
- **DiD Assessment (continuous DiD):**
  - **Pre-treatment periods:** **Strong** (weekly data back to 2003).
  - **Selection into treatment:** **Strong** (federal policy; intensity based on *pre* banking/cash infrastructure).
  - **Comparison group:** **Marginal** (identification rests on “as-good-as-random” intensity conditional on FE + trends; exclusion may proxy for remoteness/insecurity).
  - **Treatment clusters:** **Marginal** (15 state clusters → wild cluster bootstrap needed; power/inference constraints).
  - **Concurrent policies:** **Marginal** (national shocks difference out, but any **state-varying** coincident shocks correlated with exclusion are a threat).
  - **Outcome-Policy Alignment:** **Strong** (cash scarcity plausibly disrupts market transactions/marketing margins → food prices are directly affected).
  - **Data-Outcome Timing:** **Strong** (weekly prices; treatment effective late Jan/early Feb 2023; outcomes observed during full crisis weeks).
  - **Outcome Dilution:** **Strong** (cash is a dominant medium in food retail/wholesale; the affected population likely >50% in high-exclusion states).
- **Recommendation:** **PURSUE (conditional on: (i) event-study with multiple leads and commodity×market fixed effects; (ii) explicit controls/sensitivity for insecurity/fuel disruptions during Jan–Mar 2023; (iii) inference via wild cluster bootstrap at the state level and/or showing robustness to alternative clustering; (iv) pre-register 6–8 week “crisis window” to avoid specification searching).**

---

**#2: Closing the Gate: The Price Effects of Nigeria's 2019 Border Closure**
- **Score: 48/100**
- **Strengths:** Clear policy with a straightforward mechanism for tradables (especially rice) and high-frequency prices; long pre-period enables serious pre-trends checks. Strong policy relevance for trade enforcement and food inflation.
- **Concerns:** As currently framed, the DiD is close to a **regional comparison (border vs interior) with only 5 interior FEWS states**, making inference and comparability weak; and **concurrent macro/policy shocks** (notably **COVID-era disruptions in 2020**, plus other rice trade/FX policies) are a major confounding risk.
- **Novelty Assessment:** **Moderate.** The specific Nigeria border-closure episode is not saturated in top journals, but it is a “natural” topic and there is already at least some prior applied work (even if not high-quality).
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (many years of weekly pre-data).
  - **Selection into treatment:** **Strong** (border location is predetermined; closure is federal).
  - **Comparison group:** **Weak** (border states differ structurally; within FEWS you have a thin/possibly unrepresentative interior comparison set).
  - **Treatment clusters:** **Weak** (only ~5 control clusters in the FEWS sample → fragile inference).
  - **Concurrent policies:** **Weak** (COVID period overlaps heavily with treatment; other trade/FX/rice policies likely move prices too).
  - **Outcome-Policy Alignment:** **Strong** (rice prices directly reflect import/smuggling disruption).
  - **Data-Outcome Timing:** **Strong** (closure begins Aug 20, 2019; weekly prices capture exposure immediately and throughout).
  - **Outcome Dilution:** **Marginal** (closure likely shifts national rice prices too; border vs interior contrast may understate “true” national effect or capture compositional differences rather than treatment intensity).
- **Recommendation:** **SKIP (unless redesigned)** — becomes **CONSIDER** only if you can (i) **avoid COVID confounding** by focusing on Aug 2019–Feb 2020 (pre-pandemic) or explicitly modeling pandemic disruptions, and (ii) **move below the state border dummy** to a more credible intensity (e.g., market-level distance-to-border / historical smuggling corridors) with enough clusters and better comparability.

---

**#3: Cash Crises and Democratic Participation: Nigeria's Currency Redesign and the 2023 Election**
- **Score: 44/100**
- **Strengths:** Very novel and policy-relevant question; good “shock timing” narrative (cash crisis immediately before election day) and plenty of cross-state variation in financial inclusion.
- **Concerns:** With only **4 elections (3 pre periods)**, credible DiD/event-study diagnostics are extremely limited; more importantly, **2023 had many other state-varying turnout shocks** (security, BVAS/administration changes, candidate-specific mobilization) plausibly correlated with financial exclusion, creating a serious omitted-variables threat.
- **Novelty Assessment:** **High** for this exact policy–turnout link, but the broader “economic shocks and participation” literature is already large; the challenge here is not novelty but credible identification.
- **DiD Assessment (continuous DiD):**
  - **Pre-treatment periods:** **Marginal** (3 pre-election observations; hard to assess parallel trends).
  - **Selection into treatment:** **Strong** (policy is federal; intensity predetermined).
  - **Comparison group:** **Marginal** (continuous design uses all states, but exclusion is highly correlated with region, ethnicity, urbanization, and baseline political engagement).
  - **Treatment clusters:** **Strong** (37 states/FCT).
  - **Concurrent policies:** **Weak** (2023 election administration/security factors vary by state and are plausibly correlated with exclusion; with only 4 elections you cannot credibly soak this up with rich dynamics).
  - **Outcome-Policy Alignment:** **Marginal** (turnout could fall due to cash constraints, but turnout is also driven by many non-economic election-specific factors).
  - **Data-Outcome Timing:** **Marginal** (turnout is measured on election day during the crisis—relevant exposure, but not “full-year” and hard to separate anticipation/short-run disruptions).
  - **Outcome Dilution:** **Marginal** (cash constraint mainly binds the unbanked/low-income; likely well below 100% of voters, and substitution to e-transfers/party-provided transport is possible).
- **Recommendation:** **SKIP (as proposed).** It becomes **CONSIDER** only if you can (i) extend to **more elections (e.g., 1999/2003/2007)** with consistent state-level turnout definitions, and/or (ii) find **within-2023 microvariation** plausibly tied to cash scarcity (e.g., polling-unit logistics disruptions tied to banknote supply) that is less confounded by regional political differences.

---

**#4: Conflict and Food Security: How Armed Violence Affects Agricultural Markets in Nigeria**
- **Score: 38/100**
- **Strengths:** Important policy question and the data combination (high-frequency prices + conflict events) is valuable; staggered variation could support dynamic responses if the shock definition is credible.
- **Concerns:** Identification is the core problem: conflict is **highly endogenous** to economic conditions (including food prices), and “sudden escalations” are rarely plausibly exogenous without a strong instrument or design. With only **15 price-covered states**, external validity and inference are also constrained.
- **Novelty Assessment:** **Low-to-moderate.** The conflict–markets/agriculture relationship is heavily studied in many settings (including Nigeria); the incremental contribution would need to come from a genuinely new identification strategy, not just higher frequency.
- **DiD Assessment (staggered/event-study/“shock” DiD):**
  - **Pre-treatment periods:** **Strong** (long pre-period in both datasets).
  - **Selection into treatment:** **Weak** (conflict escalation is not externally assigned; likely responds to omitted shocks).
  - **Comparison group:** **Weak** (states experiencing conflict waves differ systematically; “never-treated” may be incomparable).
  - **Treatment clusters:** **Marginal** (15 states with price data).
  - **Concurrent policies:** **Weak** (military operations, displacement responses, curfews, market closures—often coincide with escalations and directly affect prices).
  - **Outcome-Policy Alignment:** **Strong** (conflict plausibly affects production, transport, market functioning → prices).
  - **Data-Outcome Timing:** **Strong** (weekly/monthly conflict → weekly prices can be aligned tightly).
  - **Outcome Dilution:** **Marginal** (conflict may be localized; FEWS price quotes often reflect specific markets, not the whole state’s exposure).
- **Recommendation:** **SKIP** unless you can articulate a **credible exogenous shifter of conflict** (and defend the exclusion restriction) or a design that isolates plausibly exogenous, sudden disruptions (e.g., specific, externally triggered border/mobility closures unrelated to prices).

---

### Summary

This is a lopsided batch: **Idea 1** is genuinely promising—high novelty plus unusually strong pre-period and timing—and is the clear first project to pursue (with careful inference and confound checks). The other three each have at least one **“Weak” DiD checklist item** as currently framed—**Idea 2** (few clusters + COVID/concurrent policy confounding), **Idea 3** (concurrent election shocks + too few pre periods), and **Idea 4** (endogenous treatment)—and should be treated as redesign-or-drop rather than “execute and hope.”