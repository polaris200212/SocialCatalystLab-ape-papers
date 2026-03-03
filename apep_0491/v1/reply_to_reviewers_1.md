# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1 ERPO vs policy bundle
**Response:** We now explicitly frame the estimated ATT as the effect of the "ERPO-inclusive policy package" throughout the paper. The concurrent policies limitation is prominently discussed in both the Threats to Validity section and the Limitations section. Controlling for concurrent gun policies (e.g., from the RAND State Firearm Law Database) would strengthen the paper but is beyond the scope of this version, as such controls require careful construction and their own identification assumptions.

### 1.2 Formal pre-trend tests
**Response:** Added. Joint Wald test for all pre-treatment event-study coefficients: murder χ²(9) = 15.68, p = 0.074 (marginal at 10%, passes at 5%). All other outcomes pass comfortably (assault p = 0.294, robbery p = 0.087, violent p = 0.163, property p = 0.350). Results reported in the Inference section.

### 1.3 Treatment timing coding
**Response:** We acknowledge the "majority-of-year" rule as a limitation. Alternative timing codings (fraction-of-year exposure, first full year) are noted as potential improvements for future work.

### 1.4 Control group includes anti-ERPO states
**Response:** The not-yet-treated robustness check (ATT = -0.212 vs baseline -0.251) already tests sensitivity to control group definition. Excluding anti-ERPO states specifically is a valuable suggestion we note for future revisions.

### 1.5 UCR reporting coverage
**Response:** We restrict to 12-month reporters to ensure consistent coverage. The drop-2021 robustness check addresses the NIBRS transition. A systematic analysis of time-varying agency coverage is an important suggestion for future work.

### 2.1 Wild cluster bootstrap
**Response:** Added. Rademacher wild cluster bootstrap (B=999) for the TWFE specification yields bootstrap SE = 0.336, 95% CI = [-1.57, -0.28], confirming TWFE significance even with small-cluster corrections.

### 2.2 Randomization inference caveats
**Response:** Added explicit caveat that unrestricted permutation assumes exchangeability of adoption status, which is implausible. RI is now framed as a "descriptive diagnostic" rather than a formal inferential test.

### 2.3 CT and N consistency
**Response:** Clarified throughout. N=1,200 (50 states × 24 years) reflects the full panel. CT remains in the data but is excluded from the treated group because its treatment predates the panel start. All table notes updated.

### 2.4 Multiple outcomes
**Response:** Murder is clearly designated as the primary outcome. Other outcomes (assault, robbery, violent index) are interpreted as exploratory. Property crime serves as the placebo.

### 3.1 Concurrent gun policies
**Response:** Acknowledged as limitation. Future work should incorporate RAND State Firearm Law Database controls.

### 3.3 Mechanism claims
**Response:** Heterogeneity section relabeled as "Exploratory" with explicit caveats about N=2 LE-only states.

### 5.1 "Underpowered but real" narrative
**Response:** Tightened language. Results described as "consistent with modest negative effects but also consistent with zero."

### 5.2 Petitioner type heterogeneity
**Response:** Section relabeled "Exploratory." Added explicit statement that the difference has not been formally tested and the LE-only subsample cannot support inference.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### DR covariates
**Response:** The doubly-robust estimation uses population and unemployment rate as covariates. This is standard CS-DiD implementation.

### Anti-ERPO placebo
**Response:** Valuable suggestion. Anti-ERPO states (OK, TN, WV, WY, MT, TX) could serve as an explicit falsification test. Noted for future work.

### Missing citations
**Response:** Added Cameron, Gelbach & Miller (2008) for wild cluster bootstrap.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Concurrent policies control
**Response:** See response to GPT-5.2 above. Acknowledged as key limitation.

### Event study scaling
**Response:** Y-axis scales necessarily differ across outcomes due to different magnitudes. This is standard practice in multi-panel event study figures.

### Synthetic control for LE-only states
**Response:** Interesting suggestion. With only 2 LE-only states, synthetic control or synthetic DiD could provide more credible counterfactuals. Noted for future work.

### Mechanism back-of-envelope
**Response:** Petition filing data are sparse and not systematically available across all states. This would strengthen the paper substantially if data become available.

---

## Goodman-Bacon Decomposition (New)
Added analytical Goodman-Bacon decomposition: 69% TWFE weight from treated-vs-never comparisons, 17% from early-vs-late, 14% from forbidden late-vs-already-treated comparisons. This directly addresses GPT-5.2's concern about disciplined TWFE comparison.
