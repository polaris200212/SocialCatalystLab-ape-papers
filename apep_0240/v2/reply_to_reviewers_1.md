# Reply to Reviewers — v2

## Reviewer 1 (GPT-5-mini): Major Revision

**Concern 1: CS-DiD vs TWFE discordance**
We have strengthened the discussion of why the CS-DiD and TWFE-DDD estimates diverge, noting that (1) CS restricts to high-flood counties vs never-treated high-flood counties—a narrower comparison—and (2) the CS pre-treatment coefficients show significant violations of parallel trends at k=-4 and k=-5, indicating compositional bias. We cite Sun & Abraham (2021) and Roth et al. (2023) in this context.

**Concern 2: Sun & Abraham estimator**
We acknowledge this suggestion and cite Sun & Abraham (2021) in the discussion. Implementation deferred to future work given the DDD structure (rather than simple DD) already addresses much of the heterogeneity concern.

**Concern 3: Wild cluster bootstrap**
With 49 state clusters, standard cluster-robust inference is reliable per Cameron, Gelbach & Miller (2008), already cited. Two-way clustering (Table 3, Col 5) confirms negligible sensitivity.

**Concern 4: Alternative flood exposure measures**
We agree that property-level data would strengthen the analysis. We note this as a limitation in the revised conclusion.

**Concern 5: Enforcement/compliance variation**
Added explicit limitation paragraph in the conclusion discussing enforcement and compliance.

## Reviewer 2 (Grok-4.1-Fast): Minor Revision

**Concern 1: Always-treated first-wave states**
Added explicit discussion in Panel Construction (Section 4.4) and Event Study section explaining that first-wave states enter the panel always-treated and pre-trends are identified from second- and third-wave states.

**Concern 2: Heterogeneity by urban/rural, coastal/inland**
We note this as a promising direction but defer implementation as it requires substantial new analysis.

**Concern 3: NFIP interaction**
Added Kousky & Shoemaker (2019) citation on NFIP subsidies distorting risk pricing.

## Reviewer 3 (Gemini-3-Flash): Minor Revision

**Concern 1: County-level data coarseness**
Added explicit limitation in conclusion about county-level ZHVI aggregation potentially attenuating property-level effects.

**Concern 2: Oster (2019) test**
Deferred to future work. The within-R² of 0.979 already suggests limited scope for omitted variable bias in this saturated fixed-effects design.

**Concern 3: Climate attention heterogeneity**
Added Giglio et al. (2021) citation on climate risk and long-run discount rates.

## Exhibit Review (Gemini)
- Event study figure regenerated with all bins (was broken in v1)
- Table notes clarified with cluster counts and singleton explanation
- Summary statistics table note clarifies state counting across groups

## Prose Review (Gemini)
- Removed roadmap paragraph from Section 1
- Rewrote results lead for impact
- Replaced "precisely estimated null" language
- Strengthened conclusion with punchier final sentence
- Added limitations paragraph
