# Research Ideas

## Idea 1: Who Believes God Forgives? Comprehensive Cross-Cultural Analysis of Divine Punishment and Forgiveness Beliefs

**Policy:** Not a traditional policy evaluation — descriptive and correlational analysis of divine punishment/forgiveness beliefs across cultures and their economic correlates.

**Outcome:** Divine punishment and forgiveness beliefs measured across 5 datasets: GSS (individual-level, USA), D-PLACE Ethnographic Atlas (775 societies), SCCS (186 societies), Pulotu (137 Austronesian cultures), Seshat (348 polity-periods).

**Identification:** Descriptive analysis (Part 1) and OLS correlations (Part 2). No causal identification claimed — the contribution is comprehensiveness and measurement documentation.

**Why it's novel:** No prior study has integrated all freely available datasets measuring divine punishment/forgiveness into a single analysis. The paper documents the measurement landscape and argues why economics should care about divine temperament beliefs.

**Feasibility check:** Confirmed: All 5 datasets freely downloadable via APIs/GitHub. GSS via NORC (75,699 respondents), D-PLACE/SCCS/Pulotu via GitHub CLDF format, Seshat via GitHub CSV. FRED API provides economic covariates. Data fetched and cleaned successfully.

**Data sources:**
- GSS cumulative file (1972-2024): COPE4, FORGIVE3, God-image battery, afterlife beliefs
- D-PLACE Ethnographic Atlas: EA034 (high gods) for 775 societies
- D-PLACE SCCS: SCCS238 (high gods) + 125 covariates for 186 societies
- Pulotu: Supernatural punishment for impiety across 137 Austronesian cultures
- Seshat: MSP composite scores for 348 polity-periods
- FRED: Gini, unemployment, GDP growth, median income, social benefits
