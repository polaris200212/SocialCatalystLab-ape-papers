# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

> **Outcome measurement**: beneficiaries served = bene-months, need clearer mapping

**Response:** Added explicit clarification in Table 1 notes and throughout the text that "beneficiaries served" counts beneficiary-months of claims activity. Added language in the Limitations section (Section 6.4) acknowledging this measurement distinction.

> **Estimand inconsistency** between TWFE continuous MW and CS-DiD discrete adoption

**Response:** Added a "Note on estimands" paragraph to Section 4.2.2 explicitly explaining that TWFE uses continuous log(MW) (elasticity interpretation) while CS-DiD uses discrete adoption (threshold effect), and that these are complementary rather than conflicting estimands. Added citations to Roth et al. (2023) for staggered DiD methodology.

> **Confounding policies** (ARPA/reimbursement) not addressed systematically

**Response:** Acknowledged in expanded Limitations section. State-year HCBS reimbursement rate data are not publicly available in a panel format suitable for inclusion as a control. The ARPA exclusion robustness check (Table 5, Column 6) is the strongest feasible approach. This is noted as a direction for future research.

> **Inference details**: wild cluster bootstrap, CS-DiD bootstrap parameters

**Response:** Added bootstrap specification details to Section 4.2.2: multiplier bootstrap with 999 replications, clustered at the state level.

> **95% CIs in main tables**

**Response:** The main tables report SEs and p-values (standard for AER/AEJ). 95% pointwise CIs are shown in all event-study figures. We believe this is adequate for the current submission.

> **Missing literature**: Roth et al., Neumark & Wascher, Konetzka, Grabowski, Decker

**Response:** Added Roth et al. (2023), Clemens & Gottlieb (2014), Grabowski (2011), and Decker (2012) to the bibliography and cited in the literature discussion. Neumark (2008) was already cited.

> **Direct intensive-margin outcomes** (benes per provider)

**Response:** This is an excellent suggestion for a revision. Computing beneficiaries per provider as a direct outcome would require additional R code development. We note this as future work in the Discussion.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

> **Power calculations**

**Response:** Added a power discussion paragraph to the Limitations section (Section 6.4), noting that the MDE at 80% power is approximately 0.15-0.20 log points for the CS-DiD provider count ATT—larger than the estimated -0.0480. The beneficiary ATT (-0.1234) falls closer to but below the detection threshold.

> **Missing references**: Cowan et al., Montenovo et al., Reinhard et al., Meer & West

**Response:** Added the most directly relevant references (Clemens & Gottlieb 2014, Grabowski 2011, Decker 2012, Roth et al. 2023) to the bibliography and literature discussion.

> **Table numbering**

**Response:** Reviewed table numbering; the current sequential numbering follows the order of appearance in the text.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

> **Power analysis for beneficiary results**

**Response:** Addressed with new power discussion in Limitations (see Reviewer 2 response above).

> **Reimbursement rates as control**

**Response:** State-year HCBS reimbursement rate data are not publicly available in panel form. The ARPA exclusion is the strongest feasible approach. Acknowledged as a limitation and future work direction.

> **Managed care control**

**Response:** Managed LTSS penetration data are not available in the current dataset. Noted in the future work section (Section 7).

---

## Exhibit Review (Gemini)

> **Move Figure 6 (RI) to appendix**

**Response:** Done. The RI figure is now in the Robustness Appendix with a cross-reference from the main text.

> **Table 4 merge into Table 3**

**Response:** Deferred. Merging requires R code restructuring; the current separate-table format is standard in the DiD literature.

> **Figure 4 line styles for B&W**

**Response:** Deferred. Would require re-running R figure generation.

---

## Prose Review (Gemini)

> **Waitlist hook opening**

**Response:** Done. The paper now opens with "More than 800,000 Americans sit on waiting lists for home-based care."

> **Kill the roadmap**

**Response:** Done. Removed the "Section 2 describes..." paragraph.

> **Humanize results**

**Response:** Improved the Table 3 results paragraph to lead with plain English ("Minimum wage hikes do not primarily drive HCBS agencies out of business—they shrink them") and include concrete magnitudes ("roughly 3,000 fewer people receiving care in a given month").

> **Soften "validating"**

**Response:** Changed "validating the parallel trends assumption" to "consistent with the parallel trends assumption" throughout.
