# Initial Research Plan

## Research Question

Does restoring felon voting rights increase Black political participation beyond the directly affected population? We test whether the "civic chill" of mass felon disenfranchisement — a direct legacy of post-Civil War racial suppression — depresses political engagement in entire Black communities, and whether rights restoration reverses this effect.

## Identification Strategy

**Primary design: Difference-in-Differences (DD)**

We exploit the staggered adoption of felon voting rights restoration laws across US states (26+ states, 1996–2024). Treatment is coded as the first November even-year election at which the reform is operative.

- **Treated units:** States that expand felon voting rights
- **Control units:** States that do not change their felon disenfranchisement laws
- **Outcome:** Black citizen voter turnout and registration rates, relative to White citizen rates (within-state, cross-race comparison)
- **Data:** CPS Voting and Registration Supplement (biennial, November even years, 1996–2024)
- **Estimator:** Callaway and Sant'Anna (2021) for heterogeneity-robust staggered DiD

**Mechanism test: Triple-Difference (DDD)**

To isolate community spillovers from direct effects, we exploit within-race variation in felony risk:
- **Low-risk subgroup (spillover proxy):** Black women 50+, Black citizens with college degree
- **High-risk subgroup (directly affected):** Black men 25–44 without college degree
- **DDD:** (Low-risk Black vs. White) × (reform vs. non-reform state) × (before vs. after)

If low-risk Black citizens' turnout increases after restoration (relative to equivalent Whites), this cannot be explained by direct restoration and must reflect community-level mechanisms.

## Expected Effects and Mechanisms

**Hypotheses:**
1. Felon voting rights restoration increases overall Black voter turnout by 1–3 percentage points relative to White turnout in the same state.
2. The effect is present even among low-felony-risk Black subgroups (spillover), consistent with a "civic chill" mechanism.
3. Effects are larger in states with higher Black incarceration rates (higher "treatment intensity").
4. Effects are larger for voter registration than for turnout (barrier removal vs. mobilization).

**Mechanisms:**
- *Norm/stigma channel:* Disenfranchisement signals political exclusion of the Black community; restoration signals inclusion
- *Mobilization channel:* Restoration increases voter registration drives and community organizing in Black neighborhoods
- *Information channel:* Media coverage of restoration laws increases awareness of voting rights among all community members

## Primary Specification

$$\text{Turnout}_{rst} = \alpha + \beta(\text{Black}_r \times \text{Reform}_{st}) + \gamma \text{Black}_r + \delta_{st} + \varepsilon_{rst}$$

Where $r$ indexes race (Black vs. White), $s$ indexes state, $t$ indexes election year, and $\delta_{st}$ are state × election-year fixed effects. The coefficient $\beta$ captures the change in the Black-White turnout gap associated with rights restoration.

## Planned Robustness Checks

1. **Event-study plots:** Dynamic treatment effects to verify parallel pre-trends
2. **Callaway-Sant'Anna estimator:** Heterogeneity-robust ATT by cohort
3. **Drop reversal states:** Exclude FL and IA (treatment reversals) from main sample
4. **Permanent reforms only:** Restrict to legislative/constitutional reforms (exclude executive orders)
5. **Placebo: Hispanic-White gap:** Test whether concurrent voting laws drive results
6. **Treatment intensity:** Interact with state-level Black incarceration rate
7. **Controls for concurrent voting laws:** Voter ID, same-day registration, early voting
8. **DDD mechanism test:** Low-risk vs. high-risk Black subgroups

## Exposure Alignment (DiD)

- **Who is treated:** Black citizens in states that restore felon voting rights
- **Primary estimand:** Change in Black-White voter turnout/registration gap
- **Placebo population:** White citizens (unaffected by felon disenfranchisement's racial targeting); Hispanic/Asian citizens (placebo for concurrent voting laws)
- **Design:** DD with DDD mechanism test

## Power Assessment

- **Pre-treatment periods:** 10+ biennial elections (1996–2014) before most reforms
- **Treated clusters:** 20+ states (excluding reversal states)
- **Post-treatment periods:** 1–5 elections per cohort (depending on adoption date)
- **Sample size:** CPS Voting Supplement ~60K households per wave; ~8K Black respondents per wave across all states
- **MDE:** With 50 states × 14 elections (1996–2024), ~700 state-election cells. Black subsample per state-election ~100–300. Detectable effect on turnout gap: ~2–4 percentage points (adequate given that the Black-White turnout gap is ~5–10 pp historically).

## Data Sources

1. **CPS Voting and Registration Supplement** (Census Bureau / IPUMS CPS)
   - Variables: VOTED, VOREG, RACE, STATEFIP, VOSUPPWT, AGE, SEX, EDUC
   - Years: 1996, 1998, 2000, ..., 2024 (biennial)
   - Access: Census Microdata API or IPUMS CPS download

2. **State felon voting rights reform database** (compiled from NCSL, Brennan Center, Ballotpedia)
   - Variables: state, reform type, effective date, first eligible election

3. **State concurrent voting law panel** (NCSL)
   - Variables: voter ID law, same-day registration, early voting, automatic voter registration

4. **State incarceration rates by race** (BJS Prisoners series)
   - For treatment intensity heterogeneity analysis
