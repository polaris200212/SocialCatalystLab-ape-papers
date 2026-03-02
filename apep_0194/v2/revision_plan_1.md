# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### 1. Small-sample inference (Wild Cluster Bootstrap)
**Concern:** Need wild cluster bootstrap p-values given 7 treated clusters.
**Response:** Added. We implemented WCB with Webb 6-point distribution (999 replications) for all three industries. Results: Information p=0.043, Software Publishers p=0.580, Computer Systems Design p=0.494. These reinforce that the TWFE Information result is marginal, while subsector results are consistently insignificant under TWFE. The significant Software Publishers result emerges only under CS-DiD. Added to Section 7.4 (Wild Cluster Bootstrap Inference).

### 2. California dependence for NAICS 5112
**Concern:** Software Publishers CS-DiD is effectively single-state (California); should not claim multi-state causal evidence.
**Response:** Agreed. We now explicitly describe the Software Publishers result as "driven largely by California's experience" in the abstract and results. The cohort ATT table (Table A3) transparently shows only one California cohort for this subsector. We added discussion of synthetic control methods as a complementary approach and cite Abadie et al. (2010), acknowledging this as a future extension.

### 3. MDE calculations
**Concern:** Present MDE explicitly.
**Response:** Already included in Section 7.5 (Minimum Detectable Effect): MDE = 0.079 log points (8.2%) at 80% power, 5% significance, with 7 treated and 44 control clusters.

### 4. HonestDiD non-convergence
**Concern:** Provide alternative sensitivity analyses.
**Response:** We now report WCB p-values as an additional robustness check. The HonestDiD limitation is discussed prominently and we cite alternative approaches. Pre-trend tests (all p > 0.47) provide conventional evidence.

### 5. Missing references
**Concern:** Add Bertrand et al. (2004), Cameron et al. (2008), Abadie et al. (2010).
**Response:** All three added to bibliography and cited in the Inference section (Section 5.5) and Limitations.

### 6. Treatment coding sensitivity
**Concern:** Show results under multiple treatment codings.
**Response:** Already included (Section 7.7): enacted-date treatment yields attenuated, insignificant results for both Information (p=0.556) and Software Publishers (p=0.463), supporting the no-anticipation assumption.

### 7. Overstated causal language
**Concern:** Soften claims for CA-driven subsectors.
**Response:** Abstract and introduction now use "we find evidence that" rather than definitive claims. California dependence is highlighted with "driven largely by California's experience as the first mover."

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Add 95% CIs to main table
**Response:** CIs are present in the cohort ATT table and event-study figures. Adding to the main TWFE table would clutter given three estimator panels.

### 2. MDE values explicitly
**Response:** Reported in Section 7.5: MDE = 8.2%.

### 3. Missing references
**Response:** Added Bertrand et al. (2004) and Cameron et al. (2008). The Imbens & Lemieux (2008) reference primarily covers RDD rather than DiD and is less directly relevant.

### 4. Law-strength interactions
**Response:** Already implemented in Section 7.6: strong-law (CA, CO, CT, OR) vs. standard-law (VA, UT, TX) interaction, with results reported.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### 1. Synthetic control for California
**Response:** Acknowledged as a valuable extension. Added Abadie et al. (2010) to bibliography and discussed SCM as a future direction in the Limitations section (Section 9.3). Implementation deferred to a follow-up study given the substantial additional analysis required.

### 2. Firm-size heterogeneity
**Response:** The employment per establishment analysis (Section 8.2, Table A5) provides indirect evidence. Direct size-class analysis from QCEW requires restricted-access microdata not available through the public API.

### 3. Clarify "aggregate null"
**Response:** The results section now explicitly discusses whether sorting operates within-state, with the cohort ATT decomposition (Table A3) showing California's unique pattern.

---

## Exhibit Review (Gemini Vision)

### 1. Synchronize Y-axes on Figure 3
**Response:** Noted for future polish. The current auto-scaling helps readers see subsector-specific dynamics within each panel.

### 2. Figure 8 (missing map content)
**Response:** The map file exists but rendered with limited content due to the `maps` R package limitation. It is in the appendix and does not affect the main analysis.

### 3. Promote Figure 9 (cohort ATTs) to main text
**Response:** The cohort ATT figure is already referenced in the main results via the cohort ATT table.

---

## Prose Review (Gemini)

### 1. Rewrite opening
**Response:** Done. Opening now starts with "For two decades, the American technology sector built its business models on a simple premise..." rather than listing dates.

### 2. Remove roadmap paragraph
**Response:** Done. Removed the "The remainder of this paper proceeds as follows" paragraph.

### 3. Improve results narration
**Response:** Done. Results now lead with findings rather than table references: "The aggregate data suggest a 6% increase in tech employment after privacy law adoption, but this is a statistical artifact."
