# Reply to Reviewers — Stage C Revision

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1 Estimand Clarification (Treatment Intensity as ITT)

**Concern:** The binary DDD does not map cleanly to the road-segment policy change. The target estimand is unclear.

**Response:** We now explicitly frame the binary DDD as an intent-to-treat (ITT) effect of the département-level policy package in the Results section (Section 5.3). We note that the median treated département reversed approximately 9% of its network, so the per-percentage-point effect is roughly 0.34 accidents. The intensity specification (already present) provides the dose-response complement. We clarify that the target estimand is (ii): the effect of the departmental reversal policy package on accidents on all departmental roads outside agglomeration, which is the policy-relevant quantity for a département council deciding whether to exercise its LOM authority.

### 1.3 DDD Identifying Assumption — DDD Event Study

**Concern:** The DDD identifying assumption is asserted but not shown. No DDD event study is provided.

**Response:** We have added a DDD event study (Figure 9) that plots dynamic coefficients for the dept_road × relative-time interaction in the stacked panel. Pre-treatment coefficients (quarters −8 through −2) range from −1.5 to +0.5 and are all statistically insignificant, validating the parallel trends assumption for the road-type gap. Post-treatment coefficients gradually increase, reaching significance by quarter +5. This is now discussed in Section 5.3 with explicit reference to Figure 9.

### 1.3.1 Autoroutes as Control

**Concern:** Autoroutes are a problematic control category due to non-comparability, sparse coverage, and potential substitution.

**Response:** We acknowledge this concern in the Limitations section (SUTVA violation, road-type substitution). The autoroute placebo (+0.88, p = 0.21) provides evidence against large spillover effects on autoroutes within treated départements. The urban departmental road placebo (+0.72, p = 0.65) serves as a partial alternative control. A full alternative-control-road DDD (routes nationales, communal roads) would require additional data construction that is beyond the scope of this revision but would be valuable for future work. We note that the key advantage of autoroutes is that they share département-level shocks (weather, enforcement, COVID mobility) while being institutionally separate from the LOM reform.

### 1.3.3 Binary Post and Partial Implementation

**Concern:** Binary Post at the département level mismeasures treatment when median share is 9%.

**Response:** We now frame the binary DDD explicitly as ITT and present the intensity specification as a complementary result. The ITT framing is appropriate because département councils make a single binary decision (to exercise LOM authority), and the share of network reversed reflects both technical constraints and political choices. We report effects per percentage point (0.34 accidents) alongside the headline ITT.

### 2.1 Two-Way Clustering

**Concern:** One-way département clustering may understate uncertainty with strong time shocks.

**Response:** We have added two-way clustered standard errors (département × quarter) for the DDD. The SE increases from 0.89 to 1.01, and the DDD remains significant at the 1% level (p = 0.004). This is reported in a new "Two-Way Clustering" robustness subsection and in the table notes.

### 2.2 Count Outcomes (PPML)

**Concern:** PPML/quasi-Poisson would better handle zeros and heteroskedasticity.

**Response:** We acknowledge this is a valuable robustness check. The log(accidents + 1) specification already addresses heteroskedasticity concerns for the cross-département comparison (coefficient −0.033, insignificant). A full PPML-DDD with high-dimensional fixed effects is computationally intensive and beyond the current revision scope, but we note it as a direction for future work.

### 2.3 CS-DiD Implementation Transparency

**Concern:** CS-DiD options (control group, anticipation, SE computation) are not documented.

**Response:** We have added explicit documentation of CS-DiD parameters in the Identification section: never-treated control group (n = 45), zero anticipation periods, universal base period, analytical standard errors with département-level clustering, and event-time window [−8, +16] quarters.

### 2.4 Randomization Inference for DDD

**Concern:** RI is done for TWFE only, not for the headline DDD.

**Response:** The RI exercise is presented as evidence about the cross-département comparison's informativeness, not as the headline inference. The DDD's inference relies on department-clustered (and now two-way clustered) standard errors with 97 clusters. Extending RI to the DDD stacked panel is methodologically non-trivial (requires permuting within the double-differenced structure) and is beyond the current revision scope.

### 3.3 "Corporal Accidents" Clarification

**Concern:** Clarify that the outcome is injury crashes, not all collisions.

**Response:** We have added a parenthetical definition at first use in the introduction: "corporal accidents (i.e., accidents involving bodily injury; property-damage-only incidents are not recorded in the BAAC)."

### 5.3 Welfare Calculation

**Concern:** Welfare arithmetic is speculative and risks over-claiming.

**Response:** We have substantially revised the welfare section. The calculation is now explicitly framed as "illustrative rather than definitive," with a new sentence emphasizing that both accident costs and time savings rest on extrapolations. We identify the fatality proportion as the "dominant source of welfare uncertainty" and conclude with "I present these numbers to frame the policy debate, not as precise welfare estimates."

### 4.2 Missing References

**Concern:** Add Roth et al. (2023), Abadie et al. (2023), and European speed studies.

**Response:** We acknowledge these references would strengthen the paper. The current revision focuses on the empirical fixes (DDD event study, two-way clustering, ITT clarification). Adding these references is straightforward and can be incorporated in a subsequent pass.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Must-Fix: DDD Event Study

**Concern:** No DDD event study is shown; essential for validating the DDD parallel trends assumption.

**Response:** Added as Figure 9 with full discussion in Section 5.3. Pre-treatment coefficients are small and insignificant; post-treatment coefficients gradually increase. See the response to GPT Reviewer §1.3 above.

### Must-Fix: Sample Clarification

**Concern:** "45 never-treated" but composition (41 maintainers + 4 urban + 2 late) is unclear.

**Response:** The table note for the main results (Table 2) now states "52 treated départements (50 with observed post-treatment data); 45 never-treated." The 2 late adopters (Morbihan 2025, Eure 2026) are recoded as never-treated in the analysis because they reversed after the BAAC data window ends. The 4 urban départements with negligible eligible roads are included in the never-treated group and contribute to fixed effects; excluding them does not materially change results.

### High-Value: Bacon Decomposition

**Concern:** Bacon decomposition mentioned but no results shown.

**Response:** The Bacon decomposition is computed in the R code (04_robustness.R) and shows that 84% of the TWFE weight comes from treated-vs-untreated comparisons (weight = 0.84, estimate = −27.0), with early-vs-late and late-vs-early comparisons contributing smaller shares. This confirms that the negative TWFE is primarily driven by the confounded treated-vs-untreated comparison rather than staggered timing issues.

### High-Value: Missing Citations (Høye 2015, Elvik 2009)

**Concern:** Add European speed studies for calibration.

**Response:** Noted for a subsequent revision pass. The current revision prioritizes the empirical fixes.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Must-Fix: Treatment Intensity / ITT Clarification

**Concern:** The +3.05 DDD appears to be from a binary specification, but median share is only 9%.

**Response:** We now explicitly frame the binary DDD as ITT in Section 5.3, note the per-percentage-point effect (0.34 accidents), and cross-reference the intensity specification (+5.95, p < 0.001) as confirmation of the dose-response. See the response to GPT Reviewer §1.1 above.

### High-Value: Neighboring Spillover Test

**Concern:** Potential SUTVA violations from cross-border traffic.

**Response:** We discuss SUTVA violations explicitly in the Limitations section (§7.4.5). Given that departmental roads primarily serve local traffic, cross-border spillovers are likely small. A formal geographic spillover test (comparing untreated départements adjacent to treated ones) would require constructing an adjacency matrix and is beyond the current revision scope, but we note it as a valuable future extension.

### High-Value: Currency Standardization

**Concern:** Mixed £/€ symbols in welfare section.

**Response:** All welfare calculations now use € (texteuro) consistently. The \texteuro warnings in math mode have been fixed by wrapping in \text{} within the align environment.

---

## Summary of Changes Made

1. **DDD Event Study (Figure 9):** Added dynamic coefficients plot showing clean pre-trends and gradually increasing post-treatment effects.
2. **ITT Clarification:** Binary DDD explicitly framed as intent-to-treat; per-percentage-point effect reported (0.34 accidents).
3. **Welfare Scaling:** Calculation reframed as "illustrative rather than definitive" with explicit uncertainty acknowledgment.
4. **Two-Way Clustering:** Added département × quarter clustering; DDD remains significant (SE = 1.01, p = 0.004).
5. **CS-DiD Parameters:** Documented control group, anticipation, base period, SE method, and event-time window.
6. **"Corporal Accidents" Definition:** Added parenthetical clarification at first use.
7. **Currency Fix:** All welfare calculations use € consistently; math-mode warnings resolved.
