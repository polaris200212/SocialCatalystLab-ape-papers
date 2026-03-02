# Initial Research Plan — apep_0430

## Research Question

Does workfare catalyze long-run rural economic development, or merely provide transitory income transfers? We study this by examining the 15-year trajectory of village-level nighttime luminosity following India's MGNREGA rollout (2006–2008).

## Identification Strategy

**Staggered difference-in-differences** exploiting MGNREGA's three-phase rollout:
- Phase I (Feb 2006): 200 most backward districts
- Phase II (Apr 2007): Additional 130 districts
- Phase III (Apr 2008): All remaining ~310 rural districts

Districts were assigned to phases based on the Planning Commission's backwardness index (agricultural productivity, wages, SC/ST share). This creates deterministic, pre-announced treatment timing across ~640 districts.

**Estimator:** Callaway and Sant'Anna (2021) heterogeneity-robust DiD, which avoids the negative weighting bias of TWFE under staggered adoption with heterogeneous effects. Not-yet-treated groups serve as comparison.

**Key threats and mitigation:**
1. *Backwardness-correlated trends:* Extensive pre-trend analysis (1994–2005, 12 years pre for Phase I). Event-study plots by cohort. Robustness to district-specific linear trends.
2. *Concurrent policies:* PMGSY roads, SSA education, NRHM health launched mid-2000s. Address via: (a) placebo with non-backwardness-targeted programs; (b) heterogeneity — if effects persist past initial push, less likely concurrent shocks.
3. *Partial first-year exposure:* Phase I begins Feb 2006, Phase II Apr 2007. Assign treatment year as the first full calendar year (2007, 2008, 2009 respectively) in baseline; robustness with actual start year.
4. *DMSP–VIIRS harmonization:* Calibrate at 2012–2013 overlap period. Run all analyses separately on DMSP-only (1994–2013) and VIIRS-only (2012–2023), plus harmonized series. Report all three.

## Expected Effects and Mechanisms

**Short-run (1–3 years):** Positive nightlight effects from direct income injection and local demand multiplier (consistent with Cook & Shah 2022 finding of 1–2% GDP increase).

**Medium-run (4–8 years):** Two competing hypotheses:
- *Big push:* Effects grow as infrastructure assets (roads, water conservation) accumulate and labor market tightening drives non-agricultural transformation
- *Transfer dependency:* Effects plateau or fade as program becomes routinized and doesn't catalyze structural change

**Long-run (9–15 years):** The key contribution. If effects persist and grow, MGNREGA catalyzed development. If effects decay toward zero, it was a transfer program without lasting structural impact.

**Heterogeneity:** Effects may be larger in:
- High SC/ST villages (greater program take-up, more binding constraints)
- Low-literacy villages (more room for development)
- Districts with complementary infrastructure (roads + MGNREGA)

## Primary Specification

```
Y_{v,t} = α_v + γ_t + β × Treated_{d(v),t} + ε_{v,t}
```

Where:
- Y_{v,t} = log(nightlights + 1) for village v in year t
- α_v = village fixed effects
- γ_t = year fixed effects
- Treated_{d(v),t} = 1 if village v's district d treated by year t
- Standard errors clustered at district level

Using CS estimator: group-time ATT(g,t) for each cohort g and period t, then aggregate to dynamic event-time estimates.

## Exposure Alignment (DiD)

- **Treated population:** All rural residents in MGNREGA districts (universal program)
- **Primary estimand:** Village-level average nightlights (captures GE effects)
- **Control population:** Not-yet-treated villages in later-phase districts (for CS estimator); or Phase III villages for simple 2×2
- **Design:** Standard staggered DiD (not triple-diff)

## Power Assessment

- **Pre-treatment periods:** 12 years (1994–2005 for Phase I)
- **Treated clusters:** 200 (Phase I), 330 (Phase I+II), 640+ (all)
- **Post-treatment periods:** 15+ years for Phase I, 13+ for Phase II
- **Observations:** ~640K villages × 30 years ≈ 19M village-years
- **MDE:** With 640K villages and district-level clustering (~640 clusters), we can detect very small effects. Even at district level, 640 clusters with 12 pre-periods gives excellent power.

## Planned Robustness Checks

1. **Pre-trend tests:** Event-study plots for each cohort (Phase I, II, III)
2. **DMSP-only analysis (1994–2013):** Avoids sensor harmonization issues
3. **VIIRS-only analysis (2012–2023):** Higher resolution, no top-coding
4. **District-specific linear trends:** Allow differential convergence
5. **Bacon decomposition:** Show which 2×2 comparisons drive TWFE estimate
6. **Sun-Abraham estimator:** Alternative heterogeneity-robust approach
7. **Synthetic DiD:** Abadie et al. (2010) for cohort-level analysis
8. **Placebo tests:**
   - Use Phase III districts as "treated" with fake treatment dates
   - Randomization inference (permute district phase assignment)
9. **Heterogeneity:**
   - By baseline SC/ST share (Census 2001)
   - By baseline literacy rate
   - By baseline worker composition (agricultural vs non-agricultural)
   - By distance to urban centers (if available)
10. **Alternative outcomes:** Population growth (Census 2001→2011), worker composition change
11. **Honest DiD:** Rambachan & Roth (2023) sensitivity to violations of parallel trends
