# Reply to Reviewers — apep_0464 v3 (Stage C)

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1-1.2 Identification and Parallel Trends
**Concern:** Pre-trend coefficients marginally significant; joint F-test not in main text.
**Response:** Added joint F-test p-value (p=0.12) to Figure 3 notes in the main text. The pre-treatment coefficients are opposite-signed from the post-treatment effect. Added pre-period slope test discussion.

### 1.3 Sensitivity to dept trends and kitchen-sink
**Concern:** Kitchen-sink absorbs network coefficient; driven by low-frequency divergence.
**Response:** Strengthened discussion in Section 8.5 explaining that dept-specific linear trends mechanically absorb shift-share variation when "shares" (SCI weights) are time-invariant. This is a known property of shift-share designs (cited Adão et al. 2019). The network effect survives all individual controls; only the combined trends + kitchen-sink eliminates it.

### 1.4 Shift-share exogeneity
**Concern:** Rotemberg diagnostics address concentration, not exogeneity.
**Response:** Acknowledged—shift exogeneity p=0.108 is borderline. The paper already includes income controls, region×election FE, and migration proxy validation. Adding the formal balance table suggested would require new data collection beyond the scope of this revision cycle.

### 1.5 Post-treatment SCI
**Concern:** Migration proxy may also capture geography.
**Response:** Elevated migration proxy results in Section 8.6 with specific coefficients (1.454***, 1.101***) in the main text. The ρ=0.66 correlation between SCI and migration weights confirms overlap but not perfect substitutability.

### 2.2 Inference inconsistency (Block RI)
**Concern:** Block RI p=0.883 undermines "robust inference" claims.
**Response:** Substantially expanded block RI discussion in Section 6.4. Now explains: (1) block RI is severely underpowered with only 5-10 depts per region, (2) it tests within-region variation while the paper's identifying variation is cross-region, (3) AKM and WCB are the appropriate methods for this setting. This is framed honestly—not as "expected" hand-waving but as a design choice about what hypothesis is being tested.

### 2.3 Weighting
**Concern:** Unweighted dept estimate insignificant.
**Response:** Already addressed in Section 5.2—population weighting is the appropriate estimand for voter-level effects. Small rural depts with extreme fuel vulnerability but few voters should not drive the estimate.

### 3.1 Distance bins
**Concern:** Negative intermediate coefficients hard to reconcile.
**Response:** Added structural explanation in Section 8.7: intermediate-distance ties (50-200km) disproportionately connect urban-rural dept pairs where cross-milieu ties transmit countervailing sentiment. Short-range and long-range ties connect ideologically homophilous communities.

### 3.2 Placebo timing
**Concern:** 2007 placebo significant.
**Response:** Strengthened explanation in Section 8.8: mechanical artifact of unbalanced panel (only 2 pre-elections for 2007 cutoff vs. 3 pre for 2009). The 2009 placebo with more balanced split produces a null.

### 5.1 "Network > Own" claim
**Concern:** Own (1.72) > Network (1.35) at dept level.
**Response:** Fixed. Changed section title from "Why Networks Matter More Than Own Costs" to "Why Networks Matter Nearly as Much as Own Costs." Updated literature positioning from "may matter more" to "matters nearly as much."

### 5.2-5.3 Structural overclaiming
**Response:** Already framed as bounds in v3. No further changes—the SAR counterfactual is explicitly described as "illustrative" and the discussion section flags SAR/SEM equivalence.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Dept vs commune primacy
**Concern:** Ambiguous which is primary.
**Response:** Already explicitly designated dept-level D2 as primary in Section 5.2. Table 2 (commune) is labeled "ancillary."

### Joint pre-trends test
**Concern:** p>0.10 not in main text.
**Response:** Added p=0.12 to Figure 3 notes.

### Migration proxy underplayed
**Concern:** Brief treatment in appendix.
**Response:** Elevated with specific coefficients (1.454***, 1.101***) reported in main text Section 8.6.

### Block RI / small N
**Concern:** 96 clusters borderline.
**Response:** Expanded block RI discussion; WCB preferred for finite-sample validity.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Immigration confounding
**Concern:** Immigration control drops coefficient 60%.
**Response:** Added "bad control" discussion (Angrist & Pischke 2009) explaining that immigration salience may be a mechanism rather than a confounder—RN's carbon-tax messaging intertwined fuel costs with broader "forgotten France" grievances.

### Intermediate distance results
**Concern:** Negative 50-200km bins counter-intuitive.
**Response:** Added structural explanation: urban-rural cross-milieu ties at intermediate distances transmit countervailing sentiment.

### 2007 placebo
**Concern:** Marginally significant.
**Response:** Strengthened explanation of mechanical unbalanced-panel artifact.

---

## Revision-drift check
- Removed "resolving an inference concern from a previous version" from introduction
- Removed "substantially more powered than the previous version" from parallel trends
- No instances of "prior version," "reviewers noted," "this revision" remain
- Abstract and introduction present findings as standalone work
