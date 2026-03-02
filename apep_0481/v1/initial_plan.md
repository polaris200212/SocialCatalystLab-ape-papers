# Initial Research Plan — apep_0481

## Title
Mandates and Mavericks: Gender, Electoral Pathway, and Party Discipline in the German Bundestag

## Research Question
Does the gender gap in party-line deviation depend on how legislators enter parliament? In Germany's MMP system, some legislators hold direct mandates (district seats won by personal vote) while others hold list mandates (party-controlled proportional allocation). Do female list members (who owe their seats entirely to the party) deviate at the same rate as female district members (who have independent constituency bases)? If so, the mechanism is gendered preferences. If only district women deviate more than district men, the mechanism is institutional incentives — party dependence constrains behavior regardless of gender.

## Identification Strategy

### Primary Design: Triple-Difference (DDD)
- **Unit of observation:** Legislator × vote
- **Outcome:** Binary indicator = 1 if legislator votes against party faction majority
- **Treatment dimensions:** Gender (Female=1) × Mandate Type (District=1) × Party-Term FE
- **Key parameter:** β₃ on (Female × District) — does the gender gap in rebellion differ between list and district members?
- **Interpretation:**
  - β₃ > 0: Gender gap widens for district members → institutional incentives matter (independence enables gendered deviation)
  - β₃ ≈ 0: Gender gap is constant → pure preference channel
  - β₃ < 0: Gender gap narrows for district members → complex selection story

### Secondary Design: Close-Race RDD (Supplementary)
- For "dual candidates" (those on both district ballot and party list), use district vote margin as running variable
- Narrow-win district → enters as district member; narrow-loss → enters as list member
- Estimate causal effect of mandate type on discipline, with heterogeneity by gender
- McCrary density test, covariate balance, donut robustness, bandwidth sensitivity

### Staggered Party-Quota DiD (Supplementary)
- SPD adopted 40% list quota in 1988, Greens 50% from founding, CDU 33% in 1996, CSU 40% in 2010
- Event study: gender gap in rebellion before/after party-level quota changes
- CS-DiD estimator for staggered treatment timing

## Expected Effects and Mechanisms

**Hypothesis 1 (Institutional Incentives):** Women with district mandates deviate more than list women because the independent electoral base provides "cover" for ideological expression. The gender gap in party-line deviation is a product of institutional position, not intrinsic preferences. Prediction: β₃ > 0.

**Hypothesis 2 (Pure Preferences):** Women deviate differently from men regardless of mandate type, reflecting genuine policy preference differences (e.g., greater support for social spending, gender equality measures). Prediction: β₃ ≈ 0, with a significant main effect of Female.

**Hypothesis 3 (Conditional Preferences):** Women's preferences only diverge from men's on specific policy domains ("feminine" issues: health, family, education), and this divergence is amplified by institutional independence. Prediction: β₃ > 0 for social policy votes, β₃ ≈ 0 for economic/defense votes.

## Primary Specification

Y_{ivpt} = β₁·Female_i + β₂·District_i + β₃·(Female_i × District_i) + X'_i·γ + μ_p × δ_t + ε_{ivpt}

Where:
- i = legislator, v = vote, p = party, t = legislative period
- Y = 1 if vote differs from party faction majority
- X = controls (seniority, committee membership, electoral safety, age)
- μ_p × δ_t = party × period fixed effects (absorb party-level time trends)
- Standard errors clustered at legislator level (robust to within-legislator correlation across votes)

## Planned Robustness Checks

1. **Alternative party-line definitions:** 90% supermajority threshold; government vs. opposition bills only
2. **Free votes excluded:** Drop Gewissensentscheidungen per Hohendorf et al. (2022) classification
3. **Policy domain heterogeneity:** Interact with "feminine" vs. "masculine" policy classification
4. **RCV selection bias:** Drop opposition-initiated RCVs; compare with all-vote sessions
5. **Close-race RDD:** Dual-candidate subsample with McCrary, donut, bandwidth sensitivity
6. **Event study:** Party-quota adoption with CS-DiD and HonestDiD sensitivity
7. **Wild cluster bootstrap:** Address concern about few party clusters (~5-6)
8. **Randomization inference:** Permute gender assignment within party × period cells
9. **Placebo outcome:** Absenteeism rates (should not show same pattern)
10. **Multiple testing:** Holm correction across policy domain subgroups

## Data Sources

| Source | Content | Access |
|--------|---------|--------|
| BTVote Voting Behavior (doi:10.7910/DVN/24U1FR) | Individual vote records, 1949-2021 | Harvard Dataverse (free) |
| BTVote MP Characteristics (doi:10.7910/DVN/QSFXLQ) | Gender, mandate type, party, electoral safety | Harvard Dataverse (free) |
| BTVote Vote Characteristics (doi:10.7910/DVN/AHBBXY) | Policy area, initiator, vote type | Harvard Dataverse (free) |
| Abgeordnetenwatch API | Extended MP data, recent periods | CC0 public API |

## Exposure Alignment (DiD Component)

- **Treated:** Female legislators entering via party lists after party-level quota adoption
- **Primary estimand population:** List members in parties that adopted gender quotas
- **Control population:** List members in parties without quotas (FDP), or pre-adoption periods in treated parties
- **Placebo/control population:** District members (whose composition is less affected by list quotas)

## Power Assessment

- ~800,000 individual votes in post-1983 periods (when RCVs became frequent)
- ~30% female legislators in recent periods (35% in 19th WP)
- Party-line deviation rate: ~3-5% in typical whipped votes (Sieberer & Ohmura 2021)
- With ~400,000 female observations and 400,000 male observations, detectable effect size for β₃ at conventional significance: ~0.5 percentage points difference in deviation rates between mandate types by gender
- MDE is small relative to baseline deviation (~3-5%), providing adequate power
