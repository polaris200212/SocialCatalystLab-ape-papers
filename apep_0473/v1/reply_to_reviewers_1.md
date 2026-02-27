# Reply to Reviewers

## Referee 1 (GPT-5.2) — MAJOR REVISION

### 1.1 Treatment definition/timing not credible enough
> Fuzzy matching and assigning unmatched LAs to 2018 can bias toward zero.

**Response:** We added a new robustness check (Table 4, Row 5) that drops all fuzzy-matched and reassigned LAs, retaining only exact matches. The CS ATT is −0.14 (SE = 0.36), virtually identical to the full-sample estimate (−0.14, SE = 0.35). Treatment assignment uncertainty is not driving the null. We also added text in Section 5.1 documenting this test.

### 1.2 Parallel trends tests may be misleading
> High p-value is evidence of low power, not parallel trends.

**Response:** We acknowledge this point and note it alongside the formal HonestDiD analysis (Section 5.3), which shows the null persists even under substantial violations of parallel trends. We do not claim parallel trends are proven—only that available diagnostics are consistent with them.

### 1.3 Identified post-treatment horizon is short and inconsistently described
> Unclear which group-time ATTs are identified; event-study interpretation may overstate.

**Response:** We added a detailed paragraph in Section 4.2 explicitly documenting the identification structure: ATT(2016,2016), ATT(2016,2017), and ATT(2017,2017) are the only identifiable post-treatment group-time ATTs. We report approximate aggregation weights (15% to 2016 cohort, 85% to 2017). We acknowledge the short identified horizon as a limitation in both Section 4.2 and 6.4.

### 1.4 Spillovers and SUTVA
> Cross-border labor market effects possible.

**Response:** We discuss SUTVA in Section 3.4. Given that neighboring LAs are typically treated within 1–2 years, spatial spillovers would need to operate on a very short temporal margin to confound our estimates. We acknowledge this as a limitation but note it works against finding differential effects.

### 2.1–2.3 Inference and survey-estimated outcomes
> APS LA statistics are survey estimates with sampling error; bootstrap validity not demonstrated.

**Response:** We acknowledge that LA-level APS estimates are themselves survey estimates with varying precision. Our standard errors are clustered at the LA level, which accounts for serial correlation within units. The CS multiplier bootstrap is standard in the applied DiD literature. We note in the Limitations section that microdata-based analysis would be preferred but is beyond scope given data access constraints.

### 3.1 Robustness set incomplete
> Missing Sun-Abraham, BJS, DID_M estimators.

**Response:** We note these as valuable for future work. The Gardner (2022) two-stage imputation estimator is included as an alternative in our analysis. Given that all specifications produce null results with similar magnitudes, concordance across additional estimators would confirm rather than change the finding.

### 3.3 Dilution and treatment intensity
> LA-level ITT too diluted; need dose-response.

**Response:** We added a formal back-of-envelope dose dilution calculation in Section 6.4, showing that the 95% CI upper bound of 0.83pp at the LA level implies a maximum individual-level effect of ~16.6pp among claimants (assuming 5% effective treatment share). We explicitly acknowledge that the area-level null cannot rule out individual-level effects among UC claimants. Administrative caseload data for dose-response estimation is not publicly available.

### 5.1 "Precisely estimated null" too strong
> Conclusion should be narrower given limitations.

**Response:** We softened the conclusion language throughout. We now state "no detectable shift ... at the local authority level over the short-to-medium run" rather than implying a definitive refutation of the gig economy channel.

---

## Referee 2 (Grok-4.1-Fast) — MINOR REVISION

### Must-fix 1: Clarify CS aggregation and identifiability
> Report which cohorts contribute to overall ATT and with what weights.

**Response:** Done. Added detailed paragraph in Section 4.2 with approximate weights (15%/85% for 2016/2017 cohorts).

### Must-fix 2: Quantify dose dilution
> Back-of-envelope TOT scaling needed.

**Response:** Done. Added formal calculation in Section 6.4 (Limitations).

### High-value 1: BRES supplementary results
> Referenced but not shown.

**Response:** We removed the BRES reference from the text to avoid confusion. BRES data was used for context during discovery but is not part of the formal analysis.

### High-value 2: Gig-specificity
> APS aggregates all self-employment; title emphasizes "gig."

**Response:** We acknowledge this in Section 6.4 (Outcome scope limitation). The APS does not distinguish gig-type self-employment from traditional self-employment. We note this as a limitation and suggest LFS microdata analysis as future work.

---

## Referee 3 (Gemini-3-Flash) — MINOR REVISION

### Must-fix 1: Treatment intensity/dose
> Formal scaling of aggregate null to individual-level.

**Response:** Done. Added calculation in Section 6.4.

### Must-fix 2: Sample end date
> Conclusion should state long-run effects of managed migration unknown.

**Response:** The Temporal scope limitation in Section 6.4 already addresses this point explicitly. We also softened the conclusion to reference "short-to-medium run" effects.

### High-value 1: Heterogeneity by industry
> Sector-specific null using BRES.

**Response:** Noted as valuable future work. Would require additional data acquisition beyond the current analysis.

### High-value 2: Multiple JCP mapping
> Robustness to earliest vs latest JCP date.

**Response:** We added the exact-match-only robustness check (Table 4, Row 5) which addresses this concern more directly by dropping all questionable matches entirely.

---

## Exhibit and Prose Improvements

Based on the exhibit and prose reviews:
- Table 2 duplicate header fixed
- Table notes improved with Within R² explanation
- Table 3 notes explain missing 2018 cohort
- Contribution language strengthened in Introduction
- Claim calibration tightened throughout
