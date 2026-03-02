# Revision Plan 1

## Summary of Reviews
- **GPT-5-mini:** MAJOR REVISION — wants permutation inference, cohort-specific event studies, synthetic control, age-specific data, concurrent policy controls
- **Grok-4.1-Fast:** MINOR REVISION — praises methodology, wants 3 additional references, youth-specific data, long-run sensitivity
- **Gemini-3-Flash:** MINOR REVISION — wants age-specific data, mechanism check, trimmed event study

## Key Themes
1. **Long-run fragility** (all 3): e=10 relies on 1 state (NJ). Need table of cohort contributions and sensitivity analysis.
2. **Age-specific data** (all 3): All-age rate dilutes youth effects. CDC WONDER restricted-use not available; must acknowledge prominently.
3. **Additional references** (GPT + Grok): Borusyak et al. (2023), others.
4. **Concurrent policy controls** (GPT): Beyond Medicaid expansion.

## Feasible Changes
1. **Add table of cohort contributions per event time** — computed from treatment dates
2. **Add trimmed event study** — show results through e=8 where 4+ cohorts contribute
3. **Add Borusyak et al. (2023) reference** and cite in methodology discussion
4. **Strengthen limitation language** about age-specific data
5. **Add note on concurrent policies** — balance check discussion
6. **Moderate long-run claims** — emphasize "suggestive" throughout

## Not Feasible (acknowledged in reply)
- Age-specific mortality data (requires restricted-use CDC WONDER)
- Synthetic control (would require major new analysis; note as future work)
- Post-2017 data extension (CDC dataset ends 2017)
- Mechanism intermediate outcomes (referral data not publicly available)
