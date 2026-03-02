# Initial Research Plan — apep_0449

## Research Question

Do criminally-accused politicians harm local development, and if so, through which specific channels? This paper decomposes the aggregate "nightlights" effect documented by Prakash, Rockmore & Uppal (2019 JDE) into specific village-level public goods — roads, electricity, water, schools, health centers, and bank branches — to identify the precise mechanisms through which criminal politicians affect their constituencies.

## Identification Strategy

**Design:** Sharp Regression Discontinuity Design (RDD) exploiting close elections between criminally-accused and non-accused candidates in Indian state assembly elections.

**Running variable:** Vote margin between the criminal and non-criminal candidate in the top-2 finishers. Positive margin = criminal candidate wins; negative = non-criminal wins.

**Treatment:** Constituency elects a criminally-accused MLA (as disclosed in mandatory candidate affidavits, available since 2003 Supreme Court ruling).

**Unit of analysis:** State assembly constituency × election cycle.

**Sample:** All state assembly elections in India from 2003-2017 where the top-2 candidates differ in criminal status. Approximately 4,000 constituencies per election cycle, ~3 cycles = ~12,000 constituency-elections total. RDD bandwidth selection via Calonico, Cattaneo & Titiunik (2014) MSE-optimal procedure.

## Expected Effects and Mechanisms

**Prior (from Prakash et al. 2019):** Criminal MLAs reduce constituency-level nightlights growth by 22-24 percentage points over a 5-year term, with effects concentrated in less-developed states.

**Hypotheses:**

H1 (Infrastructure Neglect): Criminal MLAs reduce new road construction and electricity infrastructure, visible in Census Village Directory changes.

H2 (Service Delivery Capture): Criminal MLAs redirect public goods spending to patronage networks rather than broad-based services, visible in reduced school/health center access but maintained bank branches (which serve private interests).

H3 (Heterogeneous Crime Effects): Financial/corruption charges (IPC sections related to fraud, embezzlement) have larger effects on economic outcomes than violent crime charges, because financial criminals specifically target public resource allocation.

H4 (Alignment Moderation): Criminal MLAs aligned with the state ruling party may show SMALLER negative effects (because alignment provides access to resources that partially offset criminality costs).

## Primary Specification

**Estimator:** Local polynomial RDD via `rdrobust` package in R (Calonico, Cattaneo & Farrell 2020).

```
Y_c = α + τ · D_c + f(margin_c) + ε_c
```

Where:
- Y_c = outcome in constituency c (nightlights growth, village amenity changes)
- D_c = 1 if criminal candidate wins (margin > 0)
- f(margin_c) = local polynomial in vote margin
- τ = causal effect of electing criminal politician

**Bandwidth:** MSE-optimal (Calonico, Cattaneo & Titiunik 2014), with CER-optimal as robustness.
**Inference:** Bias-corrected robust confidence intervals.
**Kernel:** Triangular (default), with uniform and Epanechnikov as robustness.

## Planned Robustness Checks

1. **McCrary (2008) density test** at margin = 0 — test for manipulation/sorting
2. **Covariate balance** at the threshold — pre-treatment Census 2001 characteristics (population, literacy, SC/ST share, urbanization) should be smooth
3. **Bandwidth sensitivity** — plot treatment effect across bandwidth range [0.5h*, 2h*]
4. **Placebo cutoffs** — test at false thresholds (margin = ±2%, ±5%, ±10%)
5. **Donut hole** — exclude observations very close to threshold (|margin| < 0.5%) to address concerns about precise manipulation
6. **Different polynomial orders** — local linear (p=1) and local quadratic (p=2)
7. **Heterogeneity** — by crime type (financial vs. violent), ruling party alignment, caste reservation status, state development level (BIMARU vs. non-BIMARU)

## Data Sources

| Data | Source | Access |
|------|--------|--------|
| Election results (candidate votes, margins) | SHRUG Trivedi candidate-level OR Lok Dhaba TCPD-IED | Free download |
| Criminal background (affidavits) | SHRUG ADR affidavits OR DataMeet/MyNeta | Free (2003-2017) |
| Nightlights (constituency level) | SHRUG nightlights module (DMSP + VIIRS) | Free download |
| Village amenities | SHRUG Census Village Directory 2001, 2011 | Free download |
| Economic Census firms | SHRUG EC 1998, 2005, 2013 | Free download |
| Constituency crosswalk | SHRUG Core Keys | Free download |
| Baseline covariates | SHRUG Census PCA 2001 | Free download |

**Fallback if SHRUG download fails:** Prakash et al. (2019) replication data on Mendeley + district-level outcomes from government portals.

## Power Assessment

- ~12,000 constituency-elections in sample (2003-2017)
- Close races (MSE-optimal bandwidth, typically |margin| < 5-8%): ~2,000-4,000 observations
- Prakash et al. found effects of 22-24 pp on nightlights growth — our MDE should be well below this
- With ~2,000 observations near threshold and standard RDD power calculations, MDE < 10 pp for nightlights
- For binary amenity changes (e.g., "gained paved road"), MDE will be larger — approximately 5-10 pp depending on baseline prevalence
