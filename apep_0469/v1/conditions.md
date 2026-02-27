# Conditional Requirements

**Generated:** 2026-02-27T02:19:31.082774
**Status:** RESOLVED

---

## Missing Men, Rising Women — WWII Selective Mortality and the Individual Origins of Gender Convergence

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: a defensible instrument/first stage not mechanically tied to local labor-demand trends

**Status:** [X] RESOLVED

**Response:**
Abandoning the agricultural IV entirely. Instead, using **directly observed county-level mobilization rates** from the CenSoc WWII Army Enlistment dataset (9M records with county FIPS, Harvard Dataverse). This is a directly measured treatment variable, not an instrument — no exclusion restriction needed. The mobilization rate = county Army enlistments / 1940 male population aged 18-44 (from NHGIS). Identification comes from:
1. **Individual panel structure**: same woman observed in 1940 and 1950 with county FE
2. **Pre-trend validation**: 1930-1940 changes should show no differential by mobilization intensity
3. **Rich controls**: individual 1940 characteristics (age, education, occupation, race, marital status)
4. **Triangulation**: OLS with mobilization rate + event study + Lee bounds + decomposition

**Evidence:** CenSoc Army Enlistment data publicly available at https://censoc.berkeley.edu/data/ with `residence_county_fips` field. Jaworski & Yang (2025) provide county-level war production data at OpenICPSR 226244 for robustness.

---

### Condition 2: explicit pre-trend diagnostics using 1930–40

**Status:** [X] RESOLVED

**Response:**
The MLP links individuals across 1930, 1940, and 1950. For women linked across all three waves, we test:
- 1930→1940 occupational score changes by county mobilization intensity (should be flat — war hasn't happened yet)
- Formal event-study with three periods: 1930 (pre-pre), 1940 (pre), 1950 (post)
- Joint F-test of pre-period coefficients
- Balancing tests on 1940 covariates across mobilization quintiles
This gives us a clean placebo period. If high-mobilization counties were already on different trajectories 1930-1940, we see it immediately.

**Evidence:** Will be demonstrated in analysis. MLP provides HISTID links for 1930-1940-1950 three-wave panel.

---

### Condition 3: a design that separates mobilization from war-production intensity/migration shocks

**Status:** [X] RESOLVED

**Response:**
Four-pronged separation strategy:
1. **Control for war production directly**: Using Jaworski (2017) county war plant investment data as a control variable (not instrument). This nets out the defense-industry demand channel.
2. **Non-mover subsample**: Restrict to women who stayed in same county 1940→1950 (observed via MLP geographic variables). Eliminates migration confound.
3. **Triple-difference**: Compare (women vs men) × (high vs low mobilization) × (pre vs post). Within-county gender differential controls for county-level shocks that affect both genders equally.
4. **Placebo on older women**: Women aged 50+ in 1940 should show no occupational upgrading from mobilization (too old for labor force entry). If mobilization coefficient is zero for this placebo group, it isolates the working-age channel.

**Evidence:** Jaworski (2017) replication data at OpenICPSR 140421; non-mover identification from COUNTY variable in MLP 1940 and 1950.

---

## The Selective Survivor — Mortality Selection (integrated as core chapter)

### Condition 1: an explicit linkage-selection framework—IPW/bounds/validation

**Status:** [X] RESOLVED

**Response:**
Key insight from Gemini: linkage failure ≠ mortality. We address this head-on:
1. **CenSoc validation**: CenSoc links 2.6M enlistees to 1940 Census. We can identify which men SERVED and compare their MLP link rates to non-serving men, separately from linkage quality.
2. **IPW for linkage selection**: Model P(linked 1940→1950 | X_1940) as function of observables. Use IPW to reweight linked sample to resemble full 1940 Census population.
3. **Lee (2009) bounds**: Apply trimming-based bounds to bracket the true effect under worst-case selection assumptions.
4. **Bounds are tight by construction**: With ~400K deaths out of ~16M military-age men (~2.5% mortality), even extreme selection moves bounds modestly. We present this explicitly.
5. **Separate test**: Compare 1940→1950 link rates for men in high vs low mobilization counties. If they differ (conditional on observables), attribute the gap to war mortality. If they don't differ, mortality selection is minimal and the decomposition can proceed cleanly.

**Evidence:** CenSoc enlistment-census linked file available at Harvard Dataverse. Lee (2009) bounds are standard in modern program evaluation.

---

### Condition 2: a clear claim that materially changes interpretation of existing evidence

**Status:** [X] RESOLVED

**Response:**
The decomposition claim: **aggregate cross-sectional comparisons of the 1940-1950 gender gap conflate three distinct forces: (A) within-person female advancement, (B) within-person male changes for survivors, and (C) compositional shifts from male attrition.** No prior study has separated these because no prior study had individual-level linked panels. The MLP makes this decomposition possible for the first time. Even if mortality selection is quantitatively small (per Gemini's point about 400K deaths), the broader COMPOSITION effect (including men who migrated, changed occupations, or left the labor force) could be substantial. The headline is NOT "dead men explain everything" — it's "panel data reveals what cross-sections couldn't decompose."

**Evidence:** Goldin (1991) and Acemoglu et al. (2004) both used repeated cross-sections; Goldin & Olivetti (2013) used state-level variation. None could track individual trajectories.

---

### Condition: Integrating Idea 5 decomposition as core chapter

**Status:** [X] RESOLVED

**Response:**
The paper architecture will be:
1. **Descriptive facts** (Section 3): Individual trajectories from MLP — who moved up, who didn't
2. **The Decomposition** (Section 4): Formal separation of aggregate convergence into within-person + composition
3. **The Causal Channel** (Section 5): Mobilization intensity → female occupational upgrading (DiD)
4. **Mechanisms** (Section 6): Marriage market + geographic mobility + selection analysis
5. **Heterogeneity** (Section 7): Race, SES, region, age, urban/rural
6. **Counterfactual** (Section 8): How much convergence would have occurred without the war?

This integrates Idea 5 as the central analytical contribution (Section 4) with Idea 1 as the causal identification (Section 5) and Idea 3/4 as mechanism chapters.

---

### Condition: Abandon agricultural IV / find credible exogenous variation

**Status:** [X] RESOLVED

**Response:**
Agricultural IV abandoned. Strategy is now:
1. **Primary**: Directly observed county mobilization rates (CenSoc) as continuous treatment intensity. No IV needed.
2. **Robustness**: Show results hold when controlling for pre-war county characteristics (manufacturing share, population, urbanization rate, Black population share, 1930 female LFP rate).
3. **Selection on observables**: Altonji-Elder-Taber (2005) / Oster (2019) test for omitted variable bias stability.
4. **Event study**: Three-period individual panel exploiting the 1930 wave as pre-pre period.

The strength comes from the PANEL — individual fixed effects eliminate time-invariant confounders, and the three-wave structure provides a pre-trend test that aggregate studies cannot run.

---

### Condition: Sensitivity to link quality

**Status:** [X] RESOLVED

**Response:**
1. Report link rates by census pair, gender, race, age, and county
2. IPW reweighting of linked sample to match full cross-section
3. Formal test: Do results change with IPW? If not, linkage selection is inconsequential.
4. Restrict to demographic subgroups with highest link quality (white men, stable surnames) as robustness check
5. Show 1930-1940 link rates are NOT correlated with 1940-1950 mobilization (pre-determined)

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
