# Internal Review - Round 1

**Reviewer:** Claude Code (Reviewer 2 mode)
**Paper:** Choking the Supply, Signing the Treaty: Mercury Regulation and Artisanal Gold Mining in Africa
**Date:** 2026-02-25

---

## PART 1: CRITICAL REVIEW

### 1. Format Check

- **Length:** 34 pages total, main text through page ~25 (before references). Passes 25-page requirement.
- **References:** Adequate coverage. Cites Callaway & Sant'Anna (2021), Goodman-Bacon (2021), Sant'Anna & Zhao (2020), Roth et al. (2023), plus policy-specific literature (Fritz et al. 2022, Girard et al. 2025).
- **Prose:** All major sections in paragraph form. No bullet-point results.
- **Section depth:** Each section has 3+ substantive paragraphs.
- **Figures:** 7 figures, all with visible data and proper axes.
- **Tables:** 6 tables plus appendix table, all with real regression output.

### 2. Statistical Methodology

a) **Standard Errors:** All regressions report clustered SEs in parentheses. PASS.
b) **Significance Testing:** Stars reported at 10/5/1% levels. PASS.
c) **Confidence Intervals:** Event study figures show 95% CIs. Main results rely on SEs. Acceptable.
d) **Sample Sizes:** N reported in all tables. PASS.
e) **DiD with Staggered Adoption:** Uses Callaway-Sant'Anna DR-DiD for Minamata. Reports TWFE for comparison and highlights the bias. PASS.

### 3. Identification Strategy

**EU Ban:** Continuous DiD exploiting pre-ban EU import share as treatment intensity. Strong design:
- Pre-trends tested via event study (flat pre-coefficients)
- Formal pre-trend test (p=0.67)
- Placebo commodity (fertilizer) yields null
- Leave-one-out confirms no single country drives result

**Minamata Convention:** CS-DiD with doubly robust estimation. Adequate given the setting:
- Never-treated and not-yet-treated comparison groups both tested
- The null result under CS-DiD vs. positive TWFE is itself informative
- Limitation: treatment endogeneity not fully addressed (ratification is voluntary)

**Concern:** The log(x+1) transformation introduces bias for observations near zero. The IHS specification is a good robustness check, but making IHS the primary specification would be stronger given the large number of zero-import observations.

### 4. Literature

Literature review is solid for methodology and mercury policy. Some gaps:
- Could cite Hentschel et al. (2002) on ASGM economics
- Missing discussion of Seccatore et al. (2014) on mercury-free alternatives
- Could engage with Telmer and Veiga (2009) on mercury trade patterns
- The environmental treaty effectiveness literature (Barrett 2003) deserves mention

### 5. Writing Quality

**Prose quality is strong.** The opening sentence hooks immediately ("Every year, millions of artisanal miners across Africa vaporize hundreds of tons of mercury..."). The narrative arc is clear and compelling. Results sections tell a story rather than narrating tables. The conclusion reframes effectively.

Minor issues:
- Section 5.4 (Minamata CS-DiD) could better explain why TWFE and CS-DiD diverge for a general audience
- The Discussion section on "why supply works and demand doesn't" could be more concise

### 6. Constructive Suggestions

1. **Heterogeneity by governance quality:** Countries with stronger rule of law might enforce Minamata obligations more effectively. An interaction between ratification and governance could reveal whether the null is driven by weak-enforcement countries.

2. **Gold price interaction:** ASGM activity is sensitive to gold prices. Including gold price × ASGM as a control would help separate gold boom effects from mercury regulation effects.

3. **Synthetic control for major importers:** For the 3-5 largest mercury importers (Ghana, Tanzania, Burkina Faso), a synthetic control analysis could provide country-level causal estimates.

4. **Extensive vs. intensive margin decomposition:** Currently brief. A more formal Heckman selection model could separate the ban's effect on entry/exit from its effect on import volumes.

## PART 2: OVERALL ASSESSMENT

### Key Strengths
- Novel research question with direct policy relevance
- Two clean identification strategies exploiting different policy variation
- The TWFE vs. CS-DiD comparison is a pedagogically valuable contribution
- Trade rerouting analysis adds genuine insight beyond the binary "did it work"
- Strong prose quality

### Critical Weaknesses
- Log(x+1) transformation not ideal for zero-heavy data (IHS preferred)
- Minamata endogeneity partially unresolved
- Event study confidence intervals for Minamata are very wide, limiting conclusions

### Specific Suggestions
1. Consider IHS as primary specification
2. Add gold price controls
3. Discuss governance heterogeneity more formally
4. The "waterbed effect" concept deserves a more prominent role in the framing

DECISION: MINOR REVISION
