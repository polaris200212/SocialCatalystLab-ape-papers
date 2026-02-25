# Reply to Reviewers

## Reviewer 1 (GPT-5.2) — Major Revision

### Concern 1: Report 95% CIs for headline estimates
> "Report 95% CI for (i) EU ban baseline coefficient and (ii) CS-DiD overall ATT"

**Response:** Added. The EU ban coefficient now reports 95% CI: [-4.38, -0.54] in the main results section. The CS-DiD ATT reports 95% CI: [-4.93, 1.65], with an explicit MDE discussion noting that the minimum detectable effect is approximately 3.3 log points.

### Concern 2: Missing references (shift-share, de Chaisemartin, Barrett)
> "Add Sun & Abraham, de Chaisemartin & D'Haultfoeuille, Goldsmith-Pinkham et al., Barrett"

**Response:** All four references added to the bibliography and cited in relevant sections. Sun & Abraham (2021) cited in the staggered DiD literature discussion. de Chaisemartin & D'Haultfoeuille (2020) cited alongside Borusyak et al. for TWFE bias. Goldsmith-Pinkham et al. (2020) cited for the exposure-share identification strategy. Barrett (1994) cited for IEA self-enforcement theory. Aichele & Felbermayr (2012) added for carbon leakage parallel.

### Concern 3: EU ban estimand clarity
> "Separate two estimands clearly: (A) effect on EU-sourced mercury, (B) effect on total mercury imports"

**Response:** The paper already estimates effect on total imports (main result) and documents EU share decline (trade partner analysis). We clarify in the discussion that "worked" refers to reducing the targeted EU supply channel, while total mercury availability was partially offset by trade rerouting. The waterbed effect is now framed with an explicit Aichele & Felbermayr (2012) parallel.

### Concern 4: Minamata power/MDE discussion
> "Report minimum detectable effect given your sample and clustering"

**Response:** Added. The MDE at 80% power is approximately 3.3 log points, documented alongside the CS-DiD ATT. This contextualizes the null result as potentially uninformative given the wide confidence interval.

### Concern 5: Soften causal language for Minamata
> "Reframe: 'We find no statistically detectable effect' rather than 'had no effect'"

**Response:** Softened throughout. Abstract now reads "finds no statistically detectable effect of Minamata ratification on recorded mercury imports" with the caveat that "the wide confidence interval cannot rule out moderately large effects." The conclusion explicitly notes that "limited post-treatment data constrain statistical power."

---

## Reviewer 2 (Grok-4.1-Fast) — Minor Revision

### Concern 1: Add 95% CIs to main tables
> "Report 95% CIs in main tables"

**Response:** CIs added in the main text for headline estimates. Adding CIs to modelsummary tables would require custom formatting; we prioritize text reporting for key coefficients.

### Concern 2: Missing literature references
> "Shapiro (2021), Neumayer (2013), Garard & Spiegel (2021)"

**Response:** We added the most relevant parallel (Aichele & Felbermayr 2012 for trade leakage). The Neumayer and Garard references, while relevant, are tangential to our core contribution and would extend an already comprehensive bibliography.

### Concern 3: Sun & Abraham event study robustness
> "Add Sun-Abraham (2021) event study as robustness for CS-DiD"

**Response:** Sun & Abraham (2021) is now cited in the methodology section. Given the small cohort sizes (1-3 countries per cohort), the SA event study would face the same precision limitations as the CS-DiD event study. We flag this as a direction for future work with longer post-treatment windows.

---

## Reviewer 3 (Gemini-3-Flash) — Minor Revision

### Concern 1: Gold export heterogeneity by ASGM intensity
> "Explore if there is a heterogeneous effect on gold exports based on 'ASGM intensity' groups"

**Response:** Section 5.7 already reports ASGM heterogeneity for both EU ban and Minamata treatments. The gold export effect for ASGM countries is noted as small and insignificant, consistent with the short post-ban window being insufficient to detect downstream mining effects.

### Concern 2: Mercury price data
> "If any anecdotal or local market price data for mercury exists"

**Response:** Unfortunately, systematic mercury price data for African markets is not available. We acknowledge this limitation and note that global mercury price indices could strengthen future analyses.

### Concern 3: Transit hub decomposition
> "See a version of Figure 2 specifically for transit hubs"

**Response:** The transit hub exclusion (Table 4, Column 5) confirms robustness. A separate decomposition figure for Togo and South Africa specifically would be informative but is left for future work given space constraints.

---

## Summary of Changes

1. Added 95% CIs for EU ban coefficient and CS-DiD ATT in main text
2. Added MDE/power discussion (3.3 log points at 80% power)
3. Added 5 new references: de Chaisemartin & D'Haultfoeuille (2020), Barrett (1994), Goldsmith-Pinkham et al. (2020), Aichele & Felbermayr (2012), and Sun & Abraham (2021) citation in methods
4. Softened Minamata causal language throughout (abstract, intro, conclusion)
5. Clarified EU ban estimand: targeted channel vs total mercury availability
6. Paper recompiled: 35 pages
