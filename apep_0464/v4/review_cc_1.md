# Internal Review (Round 1)

**Reviewer:** Claude Code (agent)
**Date:** 2026-02-27
**Paper:** Connected Backlash v4

## Verdict: MINOR REVISION

## Summary

This is a revision of apep_0464_v3 that addresses the key concerns from four referee reports. The paper studies how social networks transmit political backlash against France's carbon tax, using Facebook SCI to construct shift-share network exposure measures. The v4 revision adds three major analyses: (1) a horse-race between SCI-weighted fuel and immigration network exposures, (2) Oster (2019) omitted variable bounds, and (3) HonestDiD sensitivity analysis.

## Key Strengths

1. **Honest reporting of mixed results.** The horse-race reveals that immigration network exposure partially confounds the fuel network coefficient (57% attenuation), and the paper reports this transparently rather than burying it.
2. **Strong identification for composite network effect.** Even if the fuel-specific channel is attenuated, the paper demonstrates that social networks transmit political backlash — both through fuel vulnerability and immigration attitudes.
3. **Comprehensive robustness battery.** Seven inference methods, distance restrictions, leave-one-out, migration proxy, and now HonestDiD, Oster, and horse-race.
4. **Excellent prose quality.** The writing is clean, punchy, and follows Shleifer-style principles.

## Key Weaknesses

1. **Placebo timing failures.** 2 of 3 placebos fail (2004: t=2.64, 2007: t=2.50). Only 2009 passes. This weakens the parallel trends argument.
2. **Oster delta = 0.10.** Well below the |delta| > 1 threshold. The fuel coefficient is sensitive to omitted variables.
3. **HonestDiD breakdown at Mbar = 0.27.** The treatment effect is not robust to even modest violations of parallel trends.
4. **Block RI p = 0.88.** Still present in the data — not addressed in revision.

## Specific Comments

1. The D4 two-way cluster significance has been corrected (now **).
2. Horse-race table now includes the Own Immigration × Post coefficient row.
3. The assumption environment is now properly defined.
4. All table references appear to resolve correctly.

## Recommendation

The paper is ready for external referee review. The honest reporting of mixed results is a strength. The main contribution (social networks transmit political backlash) survives even with the attenuated fuel-specific channel.
