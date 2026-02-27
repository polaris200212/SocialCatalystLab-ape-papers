# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-27T21:17:55.373816
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 18981 in / 5285 out
**Response SHA256:** 627d6a6e412a59b0

---

## Referee Report: “Do Energy Labels Move Markets? Multi-Cutoff Evidence from English Property Transactions”

### Summary
The paper uses a multi-cutoff sharp RD design around five EPC band thresholds in England, linking EPC assessments to Land Registry transaction prices (2015–2024). The headline result is a discontinuity at the E/F cutoff (SAP 39) interpreted as MEES-driven regulatory capitalization into prices, supported by a tenure split (private rental vs owner-occupied) and by crisis-period heterogeneity (2021–2023). The topic is important and well suited to top-field/general-interest journals if the causal channel is nailed down and inference is fully defensible.

At present, the paper has promising core intuition (E/F uniquely regulatory; other cutoffs informational) but several threats to identification/inference—most importantly: (i) the “owner-occupied placebo” is not clearly a valid placebo given tenure mismeasurement and buyer-type ambiguity; (ii) postcode-level matching creates non-classical measurement error that may not be innocuous for RD; (iii) discrete running variable / mass points and potential within-postcode correlation raise inference concerns; (iv) key results show internal tension (e.g., large pre-MEES E/F jump; pooled vs tenure-specific patterns; decomposition producing “regulatory” effects when regulation is not in force). These issues are addressable, but they require substantial redesign of the empirical validation and interpretation.

---

# 1. Identification and Empirical Design (Critical)

## 1.1 RD validity at EPC thresholds
**Strengths**
- The institutional setup is appealing: deterministic band assignment at known thresholds; E/F uniquely interacts with MEES (Section 2.2); use of modern RD estimation (Section 4.2).
- The paper runs density tests and donut RD (Section 6.1, 6.3), which is appropriate.

**Concerns**
1. **Discrete running variable + heaping/manipulation may violate “as-good-as-random” local assignment even if density tests “pass.”**  
   SAP scores are integers from 1–100 with visible bunching/heaping (Figure 1 discussion; Table 5 shows manipulation at some thresholds). Even at E/F where the McCrary-style test does not reject (Table 5), discrete-score settings can still have problematic local sorting if agents target the threshold with limited precision. You partly acknowledge assessor discretion (Section 4.6), but the paper treats E/F as “clean” largely on the basis of a density test p-value.

   **Needed**: stronger evidence that units just above/below 39 are comparable in observables *and* in the joint distribution of key housing characteristics, not just marginal density. The covariate balance table (Appendix Table 6) shows discontinuities at E/F (floor area; new-build). That is not fatal, but it weakens the “clean RD” narrative and requires deeper treatment (see below).

2. **Covariate discontinuities at E/F are nontrivial and not convincingly resolved by “controlling.”**  
   Appendix Table 6 shows a jump of **4.26 sq m** at E/F (p=0.002) and a discontinuity in new-build status (p=0.012). In RD, “controlling for” covariates does not automatically fix violations of continuity if the covariates themselves shift because of sorting/manipulation. At minimum, you need to show:
   - baseline RD estimates **without covariates** and with covariates;
   - local randomization / balance over a *set* of covariates jointly;
   - sensitivity to donut sizes beyond ±1, and potentially to restricting to property types / vintage bins.

3. **Postcode-level matching is a first-order identification issue, not a minor limitation.**  
   The running variable (SAP) is assigned by matching to “most recent EPC at same postcode” within 5 years (Section 3.2). With 15–20 addresses per postcode (your claim), mis-linking can be substantial, and it is likely *systematic*:
   - Postcodes are heterogeneous in property type/size; the “most recent EPC” may not correspond to the transacted unit.
   - Mis-link probability may vary with EPC score and with transactions (e.g., properties more likely to have recent EPCs near sale; rental properties may have more frequent EPCs).
   - Because treatment is a discontinuous function of SAP, mismeasurement of SAP is **non-classical** and can cause bias in RD beyond attenuation.

   You argue mismatch “attenuates toward zero” if smooth through cutoffs (Section 4.6), but this is not established. In an RD, *differential measurement error around the cutoff* can generate or destroy discontinuities.

   **Needed**: A validation exercise quantifying match quality and demonstrating it is smooth around cutoffs. For example:
   - Use address fields (PAON/SAON/street) where possible to refine matching within postcode.
   - Where UPRN exists (post-2019 EPC), run the RD on the UPRN-matched subsample as a benchmark (even if shorter panel) and compare estimates.
   - Show discontinuities in “match recency” (days between EPC and sale) at the cutoff; if sellers commission EPCs strategically to clear thresholds pre-sale, that is sorting.

## 1.2 The MEES channel and the “owner-occupied placebo”
The paper’s main causal claim is that the E/F discontinuity is predominantly regulatory via MEES, supported by “owner-occupied placebo” (Introduction; Section 5.4).

**Key problem**: The tenure split is not clearly a placebo because tenure is measured from the EPC register and may not correspond to regulatory exposure at the time of transaction or to buyer intent.

1. **Tenure in EPC is self-reported and may be stale relative to transaction** (you note this in Limitations). A dwelling assessed as “owner-occupied” can be sold to a landlord, and vice versa. MEES relevance depends on whether the marginal buyer intends to rent the property out (or values the option), not on prior tenure at assessment.

2. **Owner-occupied transactions are not a clean control group for regulatory exposure.**  
   Even if the home is owner-occupied at the time of assessment/transaction, the *buyer* could be an investor. Conversely, some “private rental” flagged EPCs could be sold to owner-occupiers. This blurs the mechanism test and can produce misleading “placebo” findings.

3. **The observed pattern is internally hard to reconcile without a clearer model of buyer composition.**  
   - Table 9 reports very large rental-only discontinuities post-MEES (e.g., 34% in 2018–2021).  
   - Yet pooled post-MEES E/F is near zero (Table 3), implying a strong offset from the “owner” group. That’s possible, but it begs for a formal decomposition of shares and estimates, and a demonstration that tenure labels are not driving selection.

**Needed**:
- A more defensible measure of “rental exposure” at transaction. Options:
  - Identify buy-to-let purchases (e.g., corporate buyers if available; or merge with VOA/Companies House where possible; or use Land Registry “company” indicator if present in some releases; or transaction type proxies).
  - Use local rental intensity interacted with MEES: if MEES drives the effect, the E/F price gap should be larger in areas/segments with higher rental demand or higher expected rental yields.
  - Use repeat-sales / within-property transitions where EPC tenure changes.
- At minimum, show robustness of the “placebo” to alternative tenure definitions (EPC tenure vs Land Registry tenure freehold/leasehold is not tenure-of-occupancy but could help; property type × area; or “likely rental” heuristics like flats in high-rental-LA).

## 1.3 Time variation and “crisis amplification”
The crisis amplification is plausible, but identification is weaker than presented.

1. **Period-specific RD estimates are descriptive unless you test differences formally.**  
   Table 3 shows substantial swings at multiple boundaries, including sign reversals at C/D post-crisis and D/E pre-MEES. This could reflect compositional change, local trend changes in hedonic gradients, macro cycles, or matching differences across periods.

   **Needed**: explicit tests of coefficient differences across periods (e.g., interact treatment with period in a pooled specification within a local window; or use Cattaneo et al. “RD with covariates and interactions” carefully). Right now the narrative (“doubled during crisis”) relies on comparing two separately estimated RDs.

2. **The pre-MEES E/F discontinuity is huge (16%) and directly challenges the “MEES regulation explains E/F.”**  
   You discuss anticipation (Section 7.1), but the tenure-by-period table shows pre-MEES rental vs owner are both imprecisely positive (Table 9), not supporting a differential regulatory channel pre-2018. This raises the possibility that E/F is simply a salient boundary for other reasons (financing, stigma, unobserved quality heaping), and MEES may amplify rather than create the discontinuity.

   **Needed**: a clearer event-study style design around April 2018 using the *same cutoff*:
   - RD estimates in narrower windows around implementation (e.g., 2017–2019) to test for a break in the discontinuity at implementation.
   - A formal “difference-in-discontinuities” design: compare the E/F discontinuity before vs after 2018 in a way that holds sample/controls constant and tests for a discontinuity change.

## 1.4 Multi-cutoff “information vs regulation” decomposition
The cross-cutoff decomposition (Section 4.5; Table 4) is not publication-ready:

- It mechanically attributes cross-cutoff differences to “regulation” even **pre-MEES** (you acknowledge this is an artifact), which should be a red flag: the decomposition is not structurally interpretable without strong assumptions about comparability across cutoffs.
- The decomposition assumes independence across cutoff estimates due to “non-overlapping bandwidths.” Even if cutoffs are far apart, dependence can arise from shared postcodes, common shocks, and shared parameter estimation choices (bandwidth selection, covariates).
- Using D/E as an “information” benchmark is problematic given manipulation (Table 5) and covariate imbalance (Appendix Table 6).

**Recommendation**: Either (i) drop this decomposition from the main causal claims and relegate it to exploratory analysis, or (ii) replace it with a within-cutoff design that identifies regulation more directly (difference-in-discontinuities around 2018 at E/F; rental-exposure interaction; etc.).

---

# 2. Inference and Statistical Validity (Critical)

## 2.1 RD inference with discrete running variable and mass points
SAP is integer-valued with limited support. Standard RD asymptotics can be unreliable with mass points. `rdrobust` has functionality to address mass points and to report effective unique-score support; the paper does not report whether this was used.

**Must fix**:
- Report number of unique SAP score values within the chosen bandwidth on each side, not just “effective N.”  
- Use `rdrobust` options appropriate for discrete running variables (mass point adjustments) and/or complement with **local randomization inference** / randomization tests in a small window around the cutoff (Cattaneo, Frandsen & Titiunik framework).

## 2.2 Standard errors and dependence structure
You acknowledge possible within-postcode correlation and then dismiss clustering as “infeasible” (Section 4.6). That is not acceptable for a top journal without further work. Even if each postcode contributes few observations near a cutoff, dependence can still matter; and “few per cluster” is not a reason to ignore clustering—if anything it motivates alternative approaches.

**Must fix** (choose at least one defensible path):
- Cluster at a higher geographic level where clusters are meaningful (e.g., local authority district, MSOA/LSOA, postcode district) and show robustness.
- Use Conley/spatial HAC standard errors with a distance cutoff if geocodes can be assigned (even at postcode centroid).
- Use randomization inference within narrow windows that does not rely on iid errors.
- At minimum, report robustness to **heteroskedasticity + clustering** at some level and discuss power/limitations transparently.

## 2.3 Multiple testing / specification search risk
You estimate 5 cutoffs, multiple periods, multiple tenures, placebos, donuts, polynomials. That is fine, but the paper should adjust claims and/or provide family-wise error controls for the “many estimates” environment (especially when emphasizing A/B, D/E anomalies, and crisis amplification).

**Needed**:
- Pre-specify primary estimands (likely E/F overall and E/F rental post-2018; crisis interaction).
- For secondary cutoffs/time splits, consider presenting adjusted q-values or at least discuss multiplicity.

## 2.4 Coherence of reported uncertainty and estimates
Some reported p-values/SEs appear inconsistent with coefficient/SE ratios (e.g., donut E/F: 0.0951 with SE 0.0563 but p=0.046). Bias-corrected p-values can differ, but this needs to be transparent: provide the conventional estimate/SE and the bias-corrected estimate/CI clearly (rdrobust typically reports conventional and robust bias-corrected).

**Needed**: For key tables, report:
- conventional estimate + conventional SE,
- bias-corrected estimate + robust CI/p-value,
so readers can reconcile magnitudes.

---

# 3. Robustness and Alternative Explanations

## 3.1 Alternative explanations around E/F
Even if MEES matters, other mechanisms could generate an E/F price gap:
- mortgage underwriting or insurance constraints tied to EPC bands,
- buyer stigma/heuristics at “F”,
- unobserved renovation activity timed around sale that differentially pushes properties just above 39,
- assessor behavior that correlates with unobservables even absent density discontinuity.

**High-value robustness**:
- Test for discontinuities in *transaction volume* at E/F (sales counts). If sellers strategically upgrade to sell, volume may dip just below 39 or spike just above.
- Test for discontinuity in EPC assessment timing relative to sale (days between EPC and transaction). Strategic commissioning/upgrading near the threshold would show up here.
- Restrict to transactions where EPC was issued sufficiently before sale (e.g., >6 months) to reduce endogenous pre-sale EPC manipulation.

## 3.2 Donut RD and manipulation
The donut RD is helpful, but ±1 may be too small in an integer-score environment where manipulation could operate within several points (especially if upgrades move scores by small integers). Show a donut sensitivity (±1, ±2, ±3).

Also, the donut results for A/B collapse (Appendix Table 7), consistent with manipulation—this should lead you to de-emphasize A/B rather than highlight it in the abstract/introduction as a “substantial premium.”

## 3.3 External validity and interpretation of magnitudes
The back-of-the-envelope claims (Section 7.3) are not well aligned with what the RD identifies:
- RD identifies a local price jump for marginal properties at 38/39, not the average effect of upgrading F→E in general.
- The implied ROI calculations assume the discontinuity reflects only upgrade costs; but you also interpret it as option value of lettability. Those are different objects.

You should more sharply distinguish:
- capitalization of regulatory constraint/option value,
- capitalization of energy cost savings,
- and local label discontinuity vs continuous SAP slope.

---

# 4. Contribution and Literature Positioning

The paper is well motivated and cites several relevant strands, but for a top general-interest journal the positioning should be strengthened and made more precise:

## Missing / underused econometrics references (RD with manipulation, discrete running variables, local randomization)
Consider citing and using insights from:
- Cattaneo, Idrobo & Titiunik (2019) *A Practical Introduction to Regression Discontinuity Designs* (book; for discrete running variable guidance).
- Cattaneo, Frandsen & Titiunik (2015+) on local randomization methods in RD.
- Recent work on RD with measurement error / misclassification in the running variable (you do not need a full model, but you need to acknowledge that postcode matching is not classical).

## Policy domain / MEES-specific literature
You cite little directly on MEES impacts. There is a growing UK literature on MEES and housing/rental markets (often using listings/rents/retrofit outcomes). For credibility, you should engage it explicitly (even if effects differ).

---

# 5. Results Interpretation and Claim Calibration

## 5.1 Over-claiming relative to design
- The abstract states “Crossing the E/F boundary raises prices by 6.5%” and implies this is “predominantly regulatory.” Given the large **pre-MEES** E/F discontinuity (Table 3) and covariate imbalance (Appendix Table 6), the claim “predominantly regulatory” is not yet fully established by the evidence as currently presented.
- The decomposition table (Table 4) produces “regulatory effects” in periods where regulation is absent (pre-MEES). This undermines the interpretability of the decomposition and should not be used to support the mechanism.

## 5.2 Internal inconsistencies that must be reconciled
- The pooled post-MEES E/F estimate is near zero (Table 3), but rental-only post-MEES is huge (Table 9). This can happen, but the paper should explicitly show the implied weights/shares and whether the “owner” group estimate is precisely estimated enough to offset. It currently reads like a contradiction rather than a compositional fact.
- C/D shows a positive discontinuity post-MEES (Table 3) but sharply negative post-crisis (-9.9%, Table 3). That kind of sign flip calls for more careful interpretation; it weakens the “informational effects are small” conclusion unless explained.

---

# 6. Actionable Revision Requests (Prioritized)

## (1) Must-fix issues before acceptance

1. **Address postcode-level matching error as a central threat to RD validity**  
   - **Why it matters**: Misassignment of SAP scores and tenure can bias RD estimates in unknown directions; it is not safely “attenuation.”  
   - **Concrete fix**: Implement UPRN-level matching where feasible (post-2019), or richer address matching within postcode; present benchmark RD estimates on the high-quality matched subsample; show that match quality (recency, duplicates, number of candidate EPCs) is smooth at cutoffs.

2. **Fix inference for discrete running variable and dependence**  
   - **Why it matters**: Without valid inference, the paper cannot pass.  
   - **Concrete fix**: Use mass-point-robust RD procedures and/or local randomization inference; report unique-score support; provide clustered/spatial-robust inference at a feasible geographic level and show robustness.

3. **Re-establish the MEES mechanism with a within-cutoff design**  
   - **Why it matters**: The current “owner placebo” is not a clean placebo given tenure mismeasurement and buyer intent; cross-cutoff decomposition is not causal.  
   - **Concrete fix**: Implement a difference-in-discontinuities around April 2018 at the E/F cutoff (and around April 2020 for “all tenancies”), ideally interacted with rental exposure proxies. Formally test whether the E/F discontinuity changes at implementation.

4. **Resolve covariate discontinuities at E/F (balance failures)**  
   - **Why it matters**: Discontinuities in floor area/new-build suggest sorting/manipulation; controlling is not enough.  
   - **Concrete fix**: Show main estimates without covariates; then with covariates; then with stronger restrictions (donuts ±1/±2/±3; restrict to non-new-build; narrow property-type strata). Provide joint balance tests.

## (2) High-value improvements

5. **Clarify and formalize crisis amplification**  
   - **Why it matters**: Period-by-period comparisons are suggestive but not causal.  
   - **Concrete fix**: Estimate pooled models with period interactions and formally test differences; check robustness to alternative crisis windows and continuous energy-price measures.

6. **De-emphasize or redesign the multi-cutoff “information vs regulation” decomposition**  
   - **Why it matters**: Cross-cutoff comparability is weak; decomposition yields nonsensical “regulatory” effects pre-policy.  
   - **Concrete fix**: Either drop from main claims, or reframe as descriptive; if retained, restrict benchmark to clean cutoffs (C/D only), and treat as suggestive.

7. **Add diagnostic tests tied to alternative mechanisms**  
   - **Why it matters**: Helps rule out strategic EPC commissioning/upgrading near sale.  
   - **Concrete fix**: Discontinuity tests for (i) assessment-to-sale lag, (ii) transaction counts, (iii) probability of having a very recent EPC, at E/F.

## (3) Optional polish (substance, not style)

8. **More disciplined claim hierarchy and pre-registration of “primary” outcomes**  
   - **Why it matters**: Many estimates raise multiple-testing concerns.  
   - **Concrete fix**: Define primary estimands and treat the rest as secondary with appropriate caution/adjustments.

9. **Strengthen policy interpretation around what object is identified**  
   - **Why it matters**: Readers may misinterpret RD discontinuity as average upgrade return.  
   - **Concrete fix**: Rewrite welfare/ROI discussion to emphasize local effect and option value; avoid implying general upgrade ROI.

---

# 7. Overall Assessment

## Key strengths
- Excellent and policy-relevant setting with a natural discontinuity and a uniquely regulatory threshold (MEES at E/F).
- Large administrative datasets and transparent RD implementation using modern tools.
- A serious attempt at falsification (density tests, donut RD, placebos), which is the right direction.

## Critical weaknesses
- Postcode-level matching and tenure mismeasurement are major threats that are not yet convincingly handled.
- Inference is not demonstrably valid given discrete SAP scores and likely spatial dependence.
- The MEES mechanism is not cleanly identified with the current placebo/decomposition strategy, especially given the large pre-MEES E/F discontinuity.

## Publishability after revision
With a redesigned mechanism test (difference-in-discontinuities around MEES implementation), improved matching validation (UPRN/address-based subsamples), and inference upgrades (mass-point and dependence-robust), the paper could become a credible and interesting contribution suitable for a strong field journal and potentially a top general-interest outlet. In its current form, the core claims are not yet publication-ready.

DECISION: MAJOR REVISION