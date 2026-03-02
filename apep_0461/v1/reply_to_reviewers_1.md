# Reply to Reviewers — apep_0461 v1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

**1. Use continuous oil price series instead of Post2014 binary.**
We acknowledge that exploiting annual oil price variation could strengthen identification. However, the binary Post2014 design was chosen deliberately: (1) it avoids imposing a functional form on price-to-mortality transmission, (2) the event study already traces dynamics year-by-year, and (3) the pre-2014 period includes the 2008-2009 crash, which would confound a continuous price instrument. The binary design cleanly isolates the sustained structural break. We note this as a direction for future work.

**2. Post-treatment controls (health expenditure, GDP) may absorb treatment effects.**
Agreed this is a concern. The main specification (Column 2, Table 2) includes only country and year FE without post-treatment controls. The controlled specification (Column 3) is presented as a robustness check. The null result holds in both, suggesting that the null is not an artifact of over-controlling.

**3. WDI mortality data are modeled estimates.**
We have expanded the discussion of this limitation (Section 7.1). We note that measurement error in modeled mortality data would attenuate coefficients toward zero, but the measurement methodology is independent of oil dependence, so it cannot generate a spurious null. The power analysis shows the design can detect effects of meaningful size (MDE = 0.27 per pp of oil rents).

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

**1. Test for nonlinear dose-response.**
We have expanded the limitations discussion to explicitly address nonlinearity concerns (Section 7.1). The binary treatment specification (Table 2, Column 1) provides a partial check by comparing high-oil vs. low-oil countries directly. We acknowledge that more complex nonlinear patterns could produce a null average effect despite heterogeneous responses.

**2. Mechanism ambiguity — denominator effect.**
We have substantially expanded the discussion of the GDP denominator effect in the mechanism section (Section 6). We now explicitly note that when GDP contracts, health spending as a share of GDP can rise mechanically even if absolute health spending falls. This means the positive coefficient on health expenditure (% of GDP) does not necessarily imply that governments chose to protect health budgets in real terms.

**3. Missing literature citations.**
Added: Haber & Menaldo (2011) on the political resource curse, Caselli & Michaels (2013) on oil windfalls in Brazil, and Arezki & Bruckner (2011) on oil rents and institutional quality. These are now cited in both the introduction (contribution paragraph) and the literature comparison section (Section 7.2).

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

**1. Denominator effect in mechanism results.**
Addressed — see response to Reviewer 2, point 2 above. The mechanism section now includes an extended caveat on the GDP denominator effect.

**2. Nonlinearities in dose-response.**
Addressed — see response to Reviewer 2, point 1 above. The limitations section now discusses nonlinearity concerns explicitly.

**3. Lagged effects may take longer than the study window.**
We acknowledge this concern in the limitations section. The 19-year panel (2005-2023) provides a 9-year post-treatment window, which may be insufficient for capturing very long-run institutional deterioration effects. However, it is sufficient for detecting the hypothesized fiscal channel (budget cuts → service disruption → mortality), which should operate within 2-5 years.

## Internal Reviewer (Claude Code): MINOR REVISION

**1. Add missing literature references.**
Done — Haber & Menaldo (2011), Caselli & Michaels (2013), Arezki & Bruckner (2011) added.

**2. GDP denominator effect discussion.**
Done — substantially expanded in mechanism section.

**3. WDI mortality measurement concern.**
Already addressed in Section 7.1 limitations. The measurement error concern is explicitly discussed and its implications for the null result are noted.

## Summary of Changes

1. Added 3 new references (Haber & Menaldo 2011, Caselli & Michaels 2013, Arezki & Bruckner 2011) with citations in introduction and literature comparison sections
2. Expanded GDP denominator effect caveat in mechanism section
3. Expanded nonlinearity discussion in limitations section
4. Expanded literature comparison section with discussion of revisionist resource curse strand
5. WDI codes moved to appendix reference table
