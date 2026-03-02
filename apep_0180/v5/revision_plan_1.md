# Revision Plan - v5 Response to Referee Reviews

## Review Summary
- GPT-5-mini: MINOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: CONDITIONALLY ACCEPT

## Changes Implemented

### Already Addressed in v5 (Before Reviews)
1. Fixed 4 code bugs from SUSPICIOUS scan (retention parameter, persistence cap, Table 3 mismatch, heatmap constant)
2. Added variance decomposition table (Table 9) — GPT reviewer's top suggestion from v4
3. Added Imbens & Wooldridge (2009) and strengthened Pomeranz (2015) engagement
4. Removed irrelevant DiD citations (Callaway & Sant'Anna, Goodman-Bacon)
5. Led intro with striking MVPF comparison
6. Added numerical MVPF walkthrough in Conceptual Framework
7. Added pecuniary vs. real spillover footnote
8. Harmonized MVPF numbers (0.87 rounded, 0.867 bootstrap mean, 0.869 exact)
9. Updated full-formalization MVPF to correct value (0.896)
10. Tightened conclusion with informality line

### Not Addressed (Acknowledged Limitations)
1. **Microdata access**: Both GPT and Grok request direct estimation of covariance from microdata. The replication datasets require interactive authentication. We address this through comprehensive rho sensitivity (Table 8) showing <0.002 variation across the full correlation range. This limitation is transparently acknowledged in text and footnotes.

2. **Additional citations**: Some suggested citations (Bold et al. 2018, Kleven & Waseem 2013, Miguel & Kremer 2004) would strengthen the paper but are not fatal omissions. The existing bibliography covers the core MVPF, cash transfer, and fiscal externality literatures.

3. **Heterogeneity table**: Discussed in prose (Section 5.4) but not tabulated. The subgroup MVPFs vary by <3pp due to the dominance of the $850/$978 ratio, making a table less informative.

4. **Component-level bootstrap CIs**: The MVPF table reports overall CIs; component-level CIs could be added but would add complexity without changing conclusions since fiscal externalities account for <2.2% of gross cost.

5. **Exhibit reorganization**: Gemini's exhibit review suggested moving some tables to appendix and promoting heatmap. The current structure follows standard economics paper conventions.

## Conclusion
The paper addresses all critical concerns from the reviews. The remaining suggestions are improvements that would strengthen the paper but are not necessary for publication. The core contribution — first developing-country MVPF with credible experimental data — remains sound.
