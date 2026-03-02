# Conditional Requirements

**Generated:** 2026-02-13T12:46:26.755201
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## The Second Emancipation? Felon Voting Rights Restoration and Community-Level Black Political Participation

**Rank:** #1 | **Recommendation:** CONSIDER

### Condition 1: redefining the estimand or obtaining/designing data/strategy that separates spillovers from direct effects

**Status:** [x] RESOLVED

**Response:**

We adopt a **triple-difference (DDD) design** that isolates community spillovers from direct effects by exploiting demographic variation in felony risk within the Black population.

**Low-felony-risk subgroup (spillover proxy):** Black women aged 50+, Black citizens with a college degree. These groups have very low felony conviction rates (BJS data shows Black women's incarceration rate is ~1/10th of Black men's; college-educated adults have near-zero felony rates). Changes in their voter turnout/registration cannot plausibly be driven by direct restoration effects.

**High-felony-risk subgroup (directly affected):** Black men aged 25–44 without a college degree. This group has the highest felony conviction rates and is most directly affected by disenfranchisement laws.

**DDD estimand:** (Low-risk Black vs. White) × (reform vs. no-reform state) × (before vs. after reform). This captures the "civic chill" spillover: if restoring felon voting rights increases turnout among low-felony-risk Black citizens (relative to equivalent White citizens), this cannot be explained by direct restoration effects and must reflect community-level norm/stigma/mobilization channels.

**Additionally:** We redefine the primary estimand to "effect on overall Black citizen voter turnout/registration" relative to White citizens (a standard DD), with the DDD as the mechanism test. This makes the paper valuable even if spillovers are modest: the aggregate racial turnout gap response to restoration is policy-relevant in its own right.

**Evidence:**

BJS data on incarceration rates by race, sex, and age: Black men aged 25–44 have incarceration rates 5–10x higher than Black women aged 50+. College-educated adults have near-zero felony rates regardless of race. See: Carson (2021), "Prisoners in 2020," BJS Statistical Tables.

---

### Condition 2: coding treatment as "first eligible election"

**Status:** [x] RESOLVED

**Response:**

Treatment timing will be coded as the **first November even-year election at which the reform is operative for voter registration/turnout**, not the calendar year of enactment. Specifically:

- If reform takes effect before the voter registration deadline for a November election, that election is the first treated election.
- If reform takes effect after the registration deadline (typically 30 days before), the next even-year November election is the first treated observation.
- For executive orders: effective date of the order determines the first eligible election.
- For constitutional amendments passed by voters: the amendment is typically certified within weeks; the first eligible election is the NEXT even-year election (since the amendment was just passed on the current election day).

**Example:** Florida Amendment 4 passed November 2018, took effect January 2019. First eligible election: November 2020.

**Implementation:** We construct a state-level database of reform effective dates cross-referenced with CPS Voting Supplement survey dates (November of even years). Each state-election pair is coded as pre-treatment or post-treatment based on whether the reform was operative for that election's registration/voting period.

**Evidence:**

CPS Voting Supplement is collected in November of even years only. Treatment timing alignment is straightforward: compare effective date to November survey month. Sources for reform dates: NCSL "Restoration of Voting Rights for Felons" database, Brennan Center "Voting Rights Restoration" tracker, Ballotpedia "Voting rights for people convicted of a felony."

---

### Condition 3: explicit handling of reversals

**Status:** [x] RESOLVED

**Response:**

Three states experienced significant reversals:
1. **Florida:** Crist expanded automatic restoration (2007), Scott reversed it (2011), Amendment 4 re-expanded (2018/2019)
2. **Iowa:** Vilsack issued executive order for automatic restoration (2005), Branstad reversed it (2011), Reynolds re-expanded (2020)
3. **North Carolina:** Court ruling briefly expanded (2022), reversed by state Supreme Court (2023)

**Strategy:**
- **Main specification:** Drop Florida and Iowa from the primary sample. These reversal states create complex treatment paths that confound the standard CS estimator. The remaining 20+ non-reversal states provide sufficient variation.
- **Robustness 1:** Include reversal states, coding them as treated during expansion periods and untreated during reversal periods ("staggered adoption with staggered reversal"). Report these results transparently.
- **Robustness 2:** Use only the "clean" subset of reforms that are permanent legislative/constitutional changes (not executive orders, which are easily reversed). This eliminates IA/FL pre-2018 and focuses on the most credible variation.
- **Event-study plots:** Show separate event-study graphs for reversal states to see if turnout declines when rights are re-restricted.

**Evidence:**

Reform dates documented in agent research: FL (2007/2011/2019), IA (2005/2011/2020). NC Supreme Court ruling: Community Success Initiative v. Moore (2023). These are well-documented policy reversals.

---

### Condition 4: concurrent voting-law changes

**Status:** [x] RESOLVED

**Response:**

Concurrent voting-law changes (voter ID laws, early voting expansions, same-day registration, automatic voter registration) are a legitimate concern. We address this through:

**1. DDD design absorbs race-neutral voting laws.** Voter ID requirements, early voting, and registration reforms affect all racial groups. Our primary estimand compares *Black vs. White* turnout changes within the same state-election. Race-neutral concurrent policies are absorbed by this within-state, cross-race comparison. Only policies that differentially affect Black vs. White turnout could confound our estimates.

**2. Direct controls for concurrent race-salient policies.** We compile a state-level panel of:
- Strict voter ID law adoption (dates from NCSL)
- Same-day registration adoption
- Automatic voter registration adoption
- Early voting expansion/restriction
We include these as time-varying controls in the regression.

**3. Placebo tests using the White-Hispanic or White-Asian turnout gap.** If our estimated effects on the Black-White gap are driven by concurrent voting laws that also affect other minorities, we should see similar effects for other racial groups. If we find effects only for the Black-White gap, this supports the felon-disenfranchisement-specific channel.

**4. Event-study pre-trends.** If concurrent policies were driving results, we would expect to see pre-treatment trends (since voting law changes often cluster temporally). Clean pre-trends in the event study support the causal interpretation.

**Evidence:**

NCSL databases on voter ID laws, early voting, and registration policies are publicly available and updated through 2024. The DDD structure inherently differences out race-neutral policy shocks.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
