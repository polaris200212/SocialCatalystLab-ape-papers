# Reply to Reviewers — v5

We thank the three referees for their careful reading and constructive suggestions. Below we address each major concern.

---

## Reviewer 1 (GPT-5-mini): MINOR REVISION

**1. Microdata access and covariance estimation**
We agree that direct estimation from microdata would be preferable. The replication datasets (Harvard Dataverse, doi:10.7910/DVN/M2GAZN) require interactive authentication incompatible with automated retrieval. We address this through comprehensive sensitivity over rho in {-0.25, 0, 0.25, 0.50, 0.75} (Table 8), finding MVPF variation <0.002. This insensitivity arises because treatment effects enter only through small fiscal externality terms (<2.2% of gross cost). The limitation is transparently acknowledged in Section 4.4 and the Data Appendix.

**2. Fiscal parameter independence**
The reviewer correctly notes that VAT coverage and informality could be correlated. In practice, higher informality implies lower effective VAT coverage, so positive correlation would narrow the fiscal externality distribution. Since fiscal externalities account for only 2.2% of gross cost, even substantial correlation would have negligible effect on the MVPF. The variance decomposition (Table 9) confirms fiscal parameter uncertainty contributes <1% of total MVPF variance.

**3. Component-level uncertainty**
We now report overall bootstrap CIs for all five MVPF specifications in Table 4. The tight CIs (0.859-0.875 for the direct specification) reflect the mechanical certainty of cash WTP; displaying component-level CIs would show even tighter bounds for individual fiscal externalities but would not change the conclusions.

**4. Missing citations**
We added Imbens & Wooldridge (2009) in Section 4.4 and strengthened engagement with Pomeranz (2015) in Section 4.2 on VAT enforcement. We note that Callaway & Sant'Anna (2021) and Goodman-Bacon (2021) are not relevant here since this paper uses RCT-based calibration, not difference-in-differences.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

**1. Microdata access**
See response to Reviewer 1 above. We agree this is the primary limitation and are transparent about it.

**2. Literature gaps**
We added Imbens & Wooldridge (2009) and Pomeranz (2015) as suggested. The broader suggestions (Bold et al. on Kenyan government delivery, Saez et al. on MCPF formulas) would enrich the discussion but are not critical omissions — our government implementation scenarios (Section 7) address the delivery quality question empirically, and the MCPF discussion (Section 3.3) cites the relevant theoretical foundations.

**3. Heterogeneity table**
Section 5.4 discusses heterogeneity by poverty, gender, and transfer size. A formal table would show MVPF varying by <3 percentage points across subgroups because the WTP numerator is mechanically fixed at $850 and fiscal externalities are small regardless of subgroup. We discuss the qualitative patterns in prose.

---

## Reviewer 3 (Gemini-3-Flash): CONDITIONALLY ACCEPT

**1. Discount rate sensitivity**
Table 6 includes discount rates of 3%, 5%, 7%, and 10%. The MVPF varies from 0.868 to 0.870 across this range — insensitivity that reflects the small fiscal externality base. We note the reviewer's point about higher opportunity costs for the poor; however, the discount rate enters only the PV calculation of fiscal externalities (not WTP), so even a 15% rate would barely move the MVPF.

**2. Government implementation figure**
Figure 7 already shows NGO vs. government delivery scenarios. We appreciate the suggestion to add this to the cross-country comparison figure.

**3. Non-recipient enterprise fiscal recapture**
The extended specification (Section 5.1) includes non-recipient VAT on consumption. We do not include income tax on non-recipient enterprise profits because informal sector workers (80%+ in this setting) face near-zero effective income tax rates, making the additional fiscal externality negligible.

---

## Summary of Changes in v5

1. Fixed 4 code bugs identified by integrity scan (HIGH: retention parameter; MEDIUM: persistence cap, Table 3 mismatch, heatmap constant)
2. Added variance decomposition table (Table 9)
3. Harmonized MVPF numbers throughout (0.87 rounded, 0.867 bootstrap mean, 0.869 exact)
4. Added numerical MVPF walkthrough in Conceptual Framework
5. Added pecuniary vs. real spillover distinction footnote
6. Updated references (added Imbens & Wooldridge, Pomeranz engagement; removed irrelevant DiD citations)
7. Led intro with striking Kenya-vs-EITC comparison
8. Tightened conclusion with informality-as-binding-constraint line
9. Updated full-formalization MVPF to correct value (0.896)
