# Reviewer Response Plan (Round 1)

## Summary of Feedback

### GPT-5.2 (Major Revision)
- **Critical**: No first-stage evidence (eligibility → road receipt)
- **Critical**: Over-interpretation of null as "roads don't matter" without showing roads changed
- Add 95% CIs in main table; report cluster counts, left/right N_eff
- Literature gaps: Lee & Lemieux (2010), Imbens & Kalyanaraman (2012), Borker (2022)
- Add intermediate outcomes discussion

### Grok-4.1-Fast (Minor Revision)
- Add first-stage discussion (cite Asher 2020 ~20-30% first stage)
- Formalize heterogeneity (North vs South; high/low literacy)
- 3-4 additional references
- Overall: "Publication-caliber"

### Gemini-3-Flash (Minor Revision)
- First-stage sanity check needed
- Mechanisms: interact RDD with norms proxy
- State heterogeneity table

### Exhibit Review
- Figure 1 (density): increase contrast, remove minor gridlines
- Figure 2 (histogram): move to appendix
- Figure 7 (balance): fix variable labels to "Publication English"
- Consolidate Figures 3+4 into panels
- Move Table 2 to appendix, keep Figure 7 in main text

### Prose Review
- Opening needs a vivid hook (monsoon/isolation)
- Results section: narrate findings, not tables
- Trim "First, Second, Third" contribution list
- Punchier conclusion

## Revision Plan

### Workstream 1: First-Stage Discussion (addresses GPT critical concern)
- Add subsection in Results: "First-Stage Evidence from Prior Work"
- Cite Asher & Novosad (2020) first-stage: ~20-30% increase in road receipt at threshold
- Compute implied TOT: 0.0005/0.25 = 0.002 — still economically negligible
- Add SUTVA/spillover discussion
- Moderate claims throughout: "eligibility" not "roads"

### Workstream 2: Prose Polish (addresses Prose Review)
- Rewrite opening paragraph with vivid monsoon hook
- Fix Results section: narrate findings not tables
- Improve contribution framing (less list-like)
- Punchier conclusion

### Workstream 3: Exhibits (addresses Exhibit Review)
- Fix variable labels in Figure 7 (covariate balance) R code
- Move Figure 2 (histogram) to appendix
- Add 95% CI column to main results table

### Workstream 4: References
- Already have Lee & Lemieux (2010), Imbens & Kalyanaraman (2012), Cattaneo et al. (2020) in bib
- Add Borker (2022) reference
