# Internal Review (Round 2) - APEP-0180 v5

## Review Summary

This v5 revision addresses the code bugs identified in the integrity scan (SUSPICIOUS verdict) and adds a variance decomposition table. The four bugs (wrong retention parameter, persistence cap, Table 3 mismatch, heatmap hardcoded constant) have been fixed and all R scripts run cleanly. The prose improvements (opening hook, numerical walkthrough, tighter conclusion, pecuniary spillover footnote) strengthen the paper's tournament competitiveness.

## Verification of Bug Fixes

1. **Retention parameter (HIGH)**: Line 77 of 04_robustness.R now uses `earnings_retention` (0.75) instead of hardcoded 0.25. Confirmed: formality sensitivity MVPFs are now consistent with the main analysis.
2. **Persistence cap (MEDIUM)**: Earnings loop now caps at `min(years, 5)` instead of extending beyond 5 with flat decay. Confirmed: 10-year persistence MVPF now correctly stops accumulating income tax PV at year 5.
3. **Table 3 (MEDIUM)**: Treatment effect rows now show Egger et al. (2022) USD values ($116.5 consumption, $72.4 earnings) instead of incorrectly attributed H&S monthly PPP values. Confirmed: table matches bootstrap parameters.
4. **Heatmap (MEDIUM)**: Figure 4 now uses proper `pv_stream()` calls with consumption_retention and earnings_retention instead of simplified annuity factor and hardcoded -10. Confirmed: heatmap values are consistent with main analysis.

## New Content Assessment

- Variance decomposition table is well-executed. Treatment effects dominate MVPF variance (~98%), confirming that fiscal parameter uncertainty is second-order.
- The >100% sum of shares is correctly noted in table footnote as due to interaction effects.
- Opening hook paragraph is compelling and immediately positions the paper's contribution.
- Pecuniary/real spillover footnote addresses a key conceptual distinction.

## Remaining Issues

- None that require further revision before external review.

DECISION: CONDITIONALLY ACCEPT
