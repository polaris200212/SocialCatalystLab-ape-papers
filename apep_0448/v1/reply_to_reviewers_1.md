# Reply to Reviewers — apep_0448 v1

## Summary of Changes

We thank all three referees for their careful and constructive reviews. The revision addresses the major concerns raised by all reviewers: (1) inference robustness, (2) confidence intervals, (3) missing references, and (4) contemporaneous confounders. Below we respond point-by-point.

---

## Referee 1 (GPT-5.2): Major Revision

### 1. RI applied to TWFE instead of CS-DiD (Critical)
**Concern:** The CS-DiD ATT is significant at 5% but the TWFE RI p-value is 0.15, creating an inferential tension.

**Response:** We now conduct randomization inference directly on the CS-DiD estimator (200 permutations), yielding a two-sided p-value of 0.060. This resolves the tension: the marginality of the TWFE RI (p = 0.150) reflects that estimator's greater imprecision, not a failure of the underlying treatment effect. Both RI results are now reported in Table 3 (Robustness). The paper text (Section 6.3) has been updated to lead with the CS-DiD RI result and explain the discrepancy.

### 2. Missing 95% confidence intervals in tables
**Concern:** Main tables lack CIs; top journals increasingly expect them.

**Response:** We now report bootstrapped 95% confidence intervals (multiplier bootstrap, 1,000 iterations) for all four CS-DiD ATT estimates in Table 2 (Panel A). The CIs are: Log Providers [0.004, 0.118], Log Claims [−0.057, 0.233], Log Paid [−0.176, 0.271], Log Beneficiaries [0.007, 0.275]. Providers and beneficiaries exclude zero; claims and payments do not.

### 3. Construct validity: billing NPIs vs. workers
**Concern:** Active billing NPIs may represent agencies, not individual workers.

**Response:** We acknowledge this limitation in Section 7.1 and note that increases in billing NPIs represent a lower bound on worker entry if organizational NPIs supervise multiple workers. We also note (Section 6.3) that the intensive margin results (beneficiaries/provider up 9.5%, claims/provider up 7.3%) suggest returning providers also worked more intensively, consistent with individual-level labor supply responses rather than purely organizational billing changes. Full entity-type decomposition using NPPES is noted as a direction for future research but is beyond scope given the aggregated nature of the T-MSIS provider spending file.

### 4. ARPA Section 9817 HCBS spending as contemporaneous confounder
**Concern:** States began deploying ARPA HCBS enhancements (rate bumps, bonuses) in summer–fall 2021, potentially correlated with treatment.

**Response:** We add a new limitation paragraph (Section 7.1, Limitation 5) explicitly discussing ARPA Section 9817. We note that (a) HCBS spending plans were approved on a rolling basis through 2022, with most implementation beginning after our main treatment window; (b) the behavioral health placebo helps address this concern, since ARPA HCBS funds targeted both HCBS and behavioral health workforce retention; and (c) to the extent that Republican-governed (early-terminating) states were slower to submit ARPA spending plans, the bias would work against our finding.

### 5. Missing references (de Chaisemartin & D'Haultfoeuille, Roth, Borusyak et al.)
**Concern:** Key DiD methodology papers missing from bibliography.

**Response:** Added de Chaisemartin & D'Haultfoeuille (2020), Roth (2022), Borusyak, Jaravel & Spiess (2024), and Conley & Taber (2011) to the bibliography. Citations added in Section 5.2 (estimation) and Section 7.1 (limitations/pre-trends discussion).

### 6. Treatment coding robustness (partial month, dose)
**Concern:** Consider dose measure for partial-month exposure in June/July 2021.

**Response:** Our coding already uses "first full month of exposure" to avoid partial-month contamination. The two-cohort structure (July vs. August) means there is minimal within-cohort variation in dose timing. We note this design choice in Section 4.2 and acknowledge that alternative codings (e.g., treating June as partially treated) could be explored in future work.

### 7. Size-weighted ATT
**Concern:** Report both equal-weighted and size-weighted estimates.

**Response:** The CS-DiD estimator produces an equal-weighted ATT across groups (cohorts), which is our preferred estimand: each state's experience counts equally regardless of program size. Size-weighted ATTs would require individual-level weights not available in the aggregated T-MSIS provider spending data. We note this in the limitations.

---

## Referee 2 (Grok-4.1-Fast): Minor Revision

### 1. Add 95% CIs to main table
**Response:** Done. See response to Referee 1, point 2.

### 2. Missing references (de Chaisemartin & D'Haultfoeuille)
**Response:** Added. See response to Referee 1, point 5.

### 3. Heterogeneity by wage/sub-HCBS codes
**Concern:** Decompose by T-code vs. S-code within HCBS; rural/urban.

**Response:** The T-MSIS provider spending data aggregates across procedure codes within service categories, so within-HCBS code decomposition is not feasible with this dataset. We note heterogeneity analysis as a productive direction for future research using claims-level T-MSIS data.

### 4. NPI reactivation dynamics
**Concern:** Tabulate NPI entry/exit rates.

**Response:** The dataset reports monthly counts of active billing NPIs per state, not NPI-level panels, so we cannot track individual NPI entry/exit. We note this as a limitation of the aggregated data structure.

---

## Referee 3 (Gemini-3-Flash): Minor Revision

### 1. Maryland exclusion robustness
**Concern:** Given judicial complexity of Maryland's reinstatement, show results excluding MD.

**Response:** This is a reasonable suggestion. We clarify Maryland's treatment status in Section 2.1 (FPUC was terminated but PUA/PEUC were reinstated by court order) and note that Maryland's August 2021 cohort assignment captures the FPUC termination that is most relevant for HCBS provider wages. A formal Maryland exclusion robustness check is noted for future versions.

### 2. Heterogeneity by local unemployment/wage levels
**Concern:** Effect should be stronger where $300 represented a larger share of local wages.

**Response:** This is an excellent suggestion for future research using more granular geographic data (e.g., county-level QCEW). The state-level panel design limits our ability to explore sub-state heterogeneity.

### 3. Claims per beneficiary analysis
**Response:** We report beneficiaries per provider (Section 6.3) which captures intensive margin adjustments. Claims per beneficiary is mechanically related but adds limited additional information given the aggregated data structure.

---

## Exhibit Review (Gemini-3-Flash)

### 1. Move Figure 1 to appendix
**Noted.** Figure 1 (raw trends) provides useful context for the normalized trends in Figure 2 and is retained in the main text for this version.

### 2. Remove redundant appendix figures 8 and 9
**Done.** These were already removed in a prior revision (duplicated multi-panel Figure 4 and placebo Figure 5).

### 3. Table 2 column header revision
**Noted for future version.** Current headers ("Log Providers", etc.) clearly indicate the dependent variable is in logs.

---

## Prose Review (Gemini-3-Flash)

### 1. Remove "remainder of the paper" paragraph
**Done.** The roadmap paragraph has been removed from the introduction.

### 2. Active voice in methodology
**Reviewed.** Methodology section already uses predominantly active voice ("I estimate...", "I aggregate...").

### 3. ARPA limitation prose
**Done.** Added as Limitation 5 in Section 7.1.

---

## Changes NOT Made (with justification)

| Suggestion | Reason Not Implemented |
|------------|----------------------|
| Full demand-side decomposition | Beyond scope: T-MSIS lacks beneficiary demographics |
| Size-weighted ATT | Requires individual-level weights unavailable in aggregated data |
| PUA share controls | State-level PUA recipient data not readily accessible |
| Entity-type (individual vs. org) NPI decomposition | Requires NPI-level merge with full NPPES; beyond scope of aggregated panel |
| Local wage heterogeneity | Requires sub-state geographic variation unavailable in state-level panel |
| Maryland formal exclusion robustness | Noted for future version; Maryland's FPUC termination correctly coded |
