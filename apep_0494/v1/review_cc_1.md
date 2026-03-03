# Internal Review: review_cc_1.md

**Paper:** "Who Captures a Tax Cut? Property Price Capitalization and Fiscal Substitution from France's Residence Tax Abolition"
**Paper ID:** apep_0494 v1
**Reviewer:** Claude Code (Internal Review 1)
**Date:** 2026-03-03

---

## 1. Summary

This paper studies the capitalization of France's abolition of the taxe d'habitation (TH) -- a EUR 22 billion local residence tax eliminated between 2018 and 2023 -- into property prices. Using 5.4 million residential transactions from the DVF registry matched to commune-level tax rates from the REI, the author exploits cross-commune variation in pre-reform TH rates as a continuous treatment intensity measure. The central finding is a precisely estimated null: no significant capitalization of TH abolition into property prices. The paper argues this is explained by fiscal substitution -- communes raised taxe fonciere (TFB) rates by approximately 22 percentage points on average, offsetting roughly half the nominal TH rate. The paper contributes to the literatures on tax capitalization (Oates, 1969; Palmon and Smith, 1998; Lutz, 2015), fiscal federalism and vertical tax competition (Zodrow and Mieszkowski, 1986; Baicker et al., 2012), and French local public finance (Bach et al., 2023).

---

## 2. Identification Strategy Credibility

**Strengths:**

- The reform is nationally mandated and exogenous to individual communes, eliminating the standard concern that local tax changes reflect local economic conditions. This is a genuine advantage over most tax capitalization studies.
- The continuous-treatment design using pre-reform TH rates is well-motivated and provides substantial cross-sectional variation (SD of ~29 percentage points across 33,000 communes).
- The departement-by-year fixed effects absorb regional price trends effectively, and the leave-one-out analysis (Figure 7) is reassuring.

**Concerns:**

- **Fundamental identification problem: no pre-reform data.** The DVF data begins in 2020, when the reform was already 80% implemented. The paper cannot test pre-treatment parallel trends in any meaningful sense. The event study (Figure 2) only shows that prices did not diverge further between 2020 and 2025 -- but this is a test of whether the *remaining 20%* of reform implementation had differential effects, not whether the *full reform* was capitalized. The paper acknowledges this (Section 7.5, limitation #1) but understates how damaging it is. If capitalization occurred between 2017 and 2020 (the announcement-to-early-implementation period), the cross-sectional design would embed this in the level relationship between TH rates and prices, and the within-period event study would correctly show no further divergence. The null result could thus reflect *completed* capitalization, not *absent* capitalization. DVF data is available from 2014 -- extending the data window back would directly test this alternative explanation and should be treated as essential, not aspirational.

- **Selection on TH rates.** Pre-reform TH rates are not randomly assigned. They reflect decades of commune-level fiscal decisions correlated with unobservable characteristics (fiscal need, amenity levels, political preferences, demographic composition). The departement FE absorb between-departement variation, but within-departement correlation between TH rates and price determinants remains a concern. The paper does not include any direct controls for commune-level observables (population, income, urbanization, public goods provision) that might confound the TH-price relationship. A balance table showing how high-TH and low-TH communes differ on observables would strengthen the design considerably.

- **SUTVA concerns from general equilibrium.** Since the reform is universal, all communes are treated simultaneously. If TH abolition raises prices nationally (a general equilibrium effect), the cross-sectional design identifies only the *relative* effect of having a higher TH rate. The paper acknowledges this (limitation #3) but does not attempt to bound the magnitude of such effects, for instance by comparing French housing price trends to comparable European countries over the same period.

---

## 3. Statistical Validity

**Strengths:**

- Standard errors clustered at the departement level (~93 clusters) are appropriate given that TH rates vary at the commune level within departements.
- The attempt at wild cluster bootstrap (04_robustness.R) is commendable, though wrapped in a tryCatch that would silently fall back to analytical SEs if it fails.
- With 5.4 million observations and ~33,000 communes, statistical power is not a concern for detecting economically meaningful effects.

**Concerns:**

- **Power calculation is informal.** The paper notes (p. 15) that the standard error of ~0.0004 allows ruling out effects larger than 0.1% per percentage point of TH rate. This is a valid back-of-the-envelope calculation, but a formal minimum detectable effect (MDE) analysis benchmarked against theoretical predictions would be more convincing. Given a mean TH rate of 46%, a discount rate of 3-5%, and the interquartile range of ~31 pp, what magnitude of capitalization does theory predict, and how does this compare to the confidence interval?

- **Table 2 coefficient magnitudes are suspicious.** The TH rate coefficient in Column 1 is reported as -5.17 x 10^-5, but in Column 3 it becomes -0.0008. That is a 15-fold increase in magnitude when controlling for baseline TFB rate. This large sensitivity to a single control variable is not adequately discussed. If the cross-sectional relationship between TH rates and prices is this fragile, it raises questions about what omitted variables might be driving the level correlation.

- **Fiscal substitution regression (Table 3) has a puzzling sign.** Column 1 shows a *negative* coefficient of TH rate on TFB change (-0.0031, insignificant). Only when controlling for baseline TFB rate does it become positive (0.0036, marginally significant). This means the unconditional relationship between pre-reform TH rates and TFB increases is effectively zero. The paper interprets the 22 pp average TFB increase as "fiscal substitution," but the regression evidence for *differential* substitution (high-TH communes raising TFB more) is weak. The R-squared of 0.80 in both specifications suggests departement FE explain nearly everything -- the within-departement variation attributable to TH rates is minimal.

- **The scatterplot (Figure 5) contradicts the substitution narrative.** The regression line is nearly flat, and the data show massive dispersion. The visual impression is that TFB increases were roughly uniform across communes regardless of TH rate -- consistent with a mechanical departement transfer, not strategic commune behavior. The paper should separate the mechanical component (departement TF share transfer) from behavioral rate-setting more carefully.

---

## 4. Robustness Assessment

**Strengths:**

- The battery of robustness checks in Table 5 is thorough: binary treatment, standardized treatment, exclusion of Ile-de-France, high-value transactions only, and property-type splits.
- The leave-one-out analysis (Figure 7) is convincing that no single departement drives the result.
- The binscatter (Figure 6) provides clean visual evidence of the null.

**Weaknesses:**

- **No Conley spatial SEs.** With geographic data (DVF has coordinates), spatial correlation in property prices across commune borders could inflate test statistics or compress standard errors. Conley (1999) standard errors would address this.
- **No placebo tests on secondary residences.** The paper mentions (Section 2.2) that TH on secondary residences was *not* abolished, creating a natural placebo group. This is a powerful test: if the null reflects genuine non-capitalization rather than confounding, we should see no differential relationship between TH rates and secondary residence prices either. The paper does not exploit this because DVF does not distinguish primary from secondary residences at the transaction level, but this should be flagged as a first-order limitation rather than relegated to the future work section.
- **No randomization inference.** Given the cross-sectional nature of the main specification, permutation tests that randomly reassign TH rates across communes within departements would provide a distribution-free test of the null hypothesis.
- **Missing pre-reform period.** As noted above, extending DVF data back to 2014-2019 is feasible and would provide genuine pre-treatment parallel trends evidence and a test of whether capitalization occurred at announcement (2017) or early implementation (2018-2019).

---

## 5. Contribution and Literature Positioning

**Strengths:**

- The paper is well-positioned relative to the tax capitalization literature (Oates, 1969; Palmon and Smith, 1998; Lutz, 2015) and the fiscal federalism literature (Suarez Serrato and Zidar, 2016; Baicker et al., 2012).
- The fiscal substitution mechanism is a genuinely interesting finding with clear policy implications. The idea that overlapping fiscal authorities can undo intended tax relief is important for tax reform design.
- The comparison with Bach et al. (2023) is well-drawn, and the paper's advantages (full DVF universe, formal fiscal substitution estimation) are real.

**Weaknesses:**

- **The literature review is thin.** Thirteen references is well below what a top-journal submission requires. Key omissions include: Yinger (1982) on capitalization theory, Brueckner (1982) on property tax capitalization, Ross and Yinger (1999) on sorting and capitalization, Cellini et al. (2010) on school bonds capitalization, Hilber and Mayer (2009) on land use and capitalization, Adelino et al. (2014) on housing prices and fiscal policy. The Hilber (2017) synthesis is cited once but deserves deeper engagement -- what does his framework predict for this setting?
- **The conceptual framework is too simple.** The Tiebout/Oates model in Section 3 assumes perfect mobility, homogeneous preferences, and no supply response. In reality, housing supply elasticity varies dramatically across French communes (Combes et al., 2019, cited but not used for this purpose). The null result could partly reflect elastic supply in high-TH communes -- new construction absorbs demand without price increases. The paper should discuss supply-side mechanisms or control for supply elasticity.
- **The "fiscal substitution explains the null" claim is overstated.** The average TFB increase of 22 pp against a mean TH rate of 46% implies a substitution rate of ~48%. This means roughly half the TH benefit was *not* offset. If capitalization theory holds, we should still see *partial* capitalization of the remaining ~52%. The null on net capitalization (Section 6.6) is harder to reconcile with the framework than the paper suggests.

---

## 6. Results Interpretation

- **The null is more ambiguous than presented.** The paper frames the result as "no capitalization due to fiscal substitution," but at least three alternative explanations are equally consistent: (a) capitalization occurred pre-2020 and is already embedded in prices; (b) housing supply responses absorbed the shock without price changes; (c) buyer inattention or salience effects prevented capitalization. The paper discusses (a) but dismisses it too quickly, and barely mentions (b) and (c).

- **The welfare analysis (Section 7.2) is speculative.** The claim that renters unambiguously gained requires that rents did not adjust -- but if TH abolition reduced renters' costs, landlords might raise rents (particularly in tight markets). Without rental data, the distributional claims are assertions, not findings.

- **The "net benefit" variable (Section 6.6) conflates mechanical and behavioral substitution.** The net_benefit = TH_2017 - delta_TFB measure treats the departement transfer (mechanical) and voted rate increases (behavioral) identically. But from a policy perspective, only the behavioral component represents a true fiscal response. The mechanical transfer was a design feature of the reform, not an unintended consequence. Decomposing these would sharpen the contribution.

---

## 7. Actionable Revision Requests

### Essential (must address):

1. **Extend DVF data to 2014-2019.** This is the single most important improvement. DVF data is publicly available from 2014. Adding pre-reform years would (a) provide genuine pre-treatment parallel trends evidence, (b) test whether capitalization occurred at announcement/early implementation, and (c) dramatically strengthen the event study design.

2. **Add commune-level observable controls.** Include population, median income (from Filosofi), urbanization indicators, and housing stock composition. Present a balance table showing how communes across the TH rate distribution differ on observables.

3. **Decompose mechanical vs. behavioral TFB increases.** The departement TF share transfer amount is knowable from administrative data. Separate the mechanical rate increase from discretionary commune rate-setting to clarify whether the substitution is a policy design artifact or a behavioral fiscal response.

4. **Formal power analysis.** Compute the minimum detectable effect under different capitalization rate assumptions (25%, 50%, 100%) and compare to confidence intervals. This is essential for interpreting the null.

5. **Expand the literature review substantially.** At least 25-30 references for a top-journal submission. Engage with the capitalization theory literature, housing supply elasticity, salience effects (Chetty et al., 2009 is cited but its implications are not developed), and the broader vertical fiscal externality literature.

### Strongly recommended:

6. **Attempt secondary residence placebo.** Even without transaction-level indicators, communes with high secondary residence shares can be identified from census data. Testing whether these communes show different price dynamics would be informative.

7. **Add Conley spatial standard errors.** Given the geographic nature of the data and potential for spatial spillovers in housing markets.

8. **Discuss housing supply elasticity.** Do high-TH communes have different supply elasticities? If they are more urban (as suggested on p. 12), they may face more elastic supply from new construction, attenuating price effects.

9. **Strengthen the event study interpretation.** Be explicit that Figure 2 tests only the *marginal* capitalization from 80% to 100% reform completion, not the overall reform effect. Rename the section accordingly.

### Desirable:

10. **Add randomization inference.** Permute TH rates within departements to construct a reference distribution for the null hypothesis.

11. **Include rental market analysis.** Even limited data on rent levels by commune (from INSEE or Observatoire des Loyers) would help evaluate the distributional claims.

12. **Discuss political economy of TFB increases more carefully.** Are TFB increases concentrated in certain types of communes (left-leaning, fiscally distressed)? This would enrich the fiscal substitution narrative.

---

## 8. Overall Assessment

This is a well-executed empirical paper that asks an important question and arrives at a genuinely interesting finding -- the fiscal substitution mechanism that offsets tax capitalization. The institutional setting is compelling, the data are high-quality and comprehensive, and the null result is robust across specifications. The paper is well-written with a clear narrative arc.

However, the paper has a fundamental identification limitation that it underplays: the absence of pre-reform price data means the null cannot be distinguished from early capitalization. The fiscal substitution evidence, while suggestive, is weaker than presented -- the within-departement relationship between TH rates and TFB changes is marginal, and the paper does not separate mechanical from behavioral components. The literature engagement is too thin for a top-journal submission, and the conceptual framework does not address housing supply responses.

With the revisions outlined above -- particularly extending the data window, adding commune controls, decomposing fiscal substitution, and deepening the literature -- this paper could make a solid contribution to the public finance literature. The core idea that overlapping fiscal authorities can undo tax reform is important and policy-relevant. In its current form, the paper is a strong working paper but requires substantial additional work to reach top-journal standards.

**Rating: 6.5/10** -- Above-average research with a compelling question and credible (if incomplete) execution. Major revision required.

---

DECISION: REVISE (Major Revision)
