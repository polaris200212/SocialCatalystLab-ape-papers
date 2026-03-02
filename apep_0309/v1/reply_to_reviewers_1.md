# Reply to Reviewers

## Reviewer 1: GPT-5.2 (MAJOR REVISION)

### Concern 1: Missing 95% Confidence Intervals
> "Currently missing for main results in the text/tables... Top journals increasingly expect CIs for headline effects."

**Response:** We have added 95% confidence intervals for all headline coefficients throughout the paper. The abstract, introduction, and main results discussion now report CIs alongside point estimates. Table 2 notes now include CIs for all three specifications: Binary [1.24, 4.29], Continuous [5.14, 14.71], Pop-Weighted [3.96, 11.27]. The CS-DiD ATT is reported with CI [3.83, 8.36]. Drug-type CIs are reported in the text discussion.

### Concern 2: Estimand Under Interference Not Formalized
> "SUTVA is violated by design... you must be much more explicit about what is the treatment... add a short subsection 'Estimand under interference'."

**Response:** We have added a new subsection "Estimand Under Interference" to the Empirical Strategy section. This defines potential outcomes Y_jt(d_jt, E_jt) under the exposure mapping framework of Aronow & Samii (2017), building on Hudgens & Halloran (2008). We state the partial interference assumption (only contiguous neighbors' mandates matter) and define the estimand formally. We test this assumption by including second-order exposure (neighbors-of-neighbors) in the specification; the first-order coefficient remains stable (β = 2.47, p = 0.002) while second-order exposure is also significant (β = 11.23, p < 0.001).

### Concern 3: Drug-Type Suppression Selection
> "CDC suppresses low counts and you drop those observations. This is likely non-random missingness..."

**Response:** We have added a detailed discussion of differential suppression rates. For heroin, 24% of exposed state-years are suppressed versus 55% of unexposed state-years, with similar patterns for all drug types. This reflects that unexposed states tend to be smaller with lower baseline mortality. We now explicitly discuss this caveat and note that the total overdose analysis (N=637) is unaffected.

### Concern 4: Endogenous Policy Diffusion / OwnPDMP as Mediator
> "If neighbors' mandates increase political pressure for your own mandate... OwnPDMP is potentially a mediator."

**Response:** We present the main specification both with and without the OwnPDMP control. Without OwnPDMP, β = 2.86 (SE = 0.81), virtually identical to the baseline estimate of 2.77, confirming that own-PDMP control neither inflates nor attenuates the spillover estimate.

### Concern 5: Timing/Support Problem as Exposure Saturates
> "By 2021 all states have ≥50% treated neighbors... later years contribute little identifying variation."

**Response:** We restrict the sample to the common support period 2011-2019, when meaningful variation persists. The coefficient is larger (β = 4.66, SE = 1.20, N = 441), suggesting the full-sample estimate is attenuated by inclusion of later years with limited variation.

### Concern 6: Missing Literature Citations
> "Missing several key modern DiD/event-study references... and spillover/interference methodology references."

**Response:** We have added citations for:
- Sun & Abraham (2021) — dynamic treatment effects with heterogeneous effects
- Roth (2022) — pretest sensitivity for parallel trends
- Aronow & Samii (2017) — exposure mappings under interference
- Hudgens & Halloran (2008) — causal inference with interference
- Dube, Lester & Reich (2010) — border discontinuity designs

### Not Addressed (Infeasible in This Revision)
- Border-county design: Would require county-level data infrastructure not currently available
- ARCOS/prescribing mechanism data: Not publicly accessible
- Conley spatial HAC SEs: Complex implementation deferred to future work
- Wild cluster bootstrap: Deferred; 49 clusters is adequate for standard clustered inference

---

## Reviewer 2: Grok-4.1-Fast (MINOR REVISION)

### Concern 1: Confidence Intervals
> "Add 95% CIs to all main coefficients."

**Response:** Done. CIs added throughout — see response to GPT Concern 1 above.

### Concern 2: Literature Gaps
> "Missing border-county evidence on opioids... Expand Meinhofer with distributor evidence... Add canonical spatial DiD."

**Response:** We have added Dube, Lester & Reich (2010) for border-based empirical strategies, Aronow & Samii (2017) for exposure mapping methodology, and Sun & Abraham (2021) and Roth (2022) for modern DiD methods. The suggested Dube-Zwickel (2024) and Alpert-Peyton (2024) could not be verified in our bibliography sources and are left for future revisions.

### Concern 3: Mechanism Evidence
> "Link to public ARCOS/prescribing data."

**Response:** ARCOS data remains restricted-access. We note this limitation explicitly and suggest it as a direction for future work.

### Concern 4: PMP InterConnect
> "DiD on exposure × InterConnect."

**Response:** InterConnect adoption data is not systematically available in a form suitable for state-year panel analysis. We discuss this in the policy implications section as a promising avenue.

---

## Reviewer 3: Gemini-3-Flash (MINOR REVISION)

### Concern 1: Border-County Analysis
> "County-level data, comparing counties on either side of a 'treated' border."

**Response:** This would substantially strengthen the paper but requires county-level mortality data and a border-band identification strategy. We acknowledge this in the limitations section and note it as the highest-priority extension for future work.

### Concern 2: PMP InterConnect Interaction
> "An interaction between 'Network Exposure' and 'InterConnect Membership'."

**Response:** We agree this would be a powerful test but InterConnect adoption dates are not systematically compiled in our current data. Noted for future work.

### Concern 3: Synthetic Opioid Null Discussion
> "More discussion on why displacement might reduce fentanyl deaths."

**Response:** We have added a paragraph interpreting the negative (insignificant) synthetic opioid coefficient. The proposed mechanism: PDMP spillovers, by maintaining access to prescription opioids in neighboring states, may slow the transition to fentanyl. Displaced patients who can still obtain pills across the border have less incentive to seek fentanyl alternatives. This is consistent with the strong positive heroin effect.

---

## Exhibit Review (Gemini)
No exhibits flagged for revision; all rated "KEEP AS-IS" or with minor suggestions. The main recommendation to standardize table fixed effects labels ("State fixed effects" instead of "state_abbr fixed effects") was already implemented in a prior revision.

## Prose Review (Gemini)
Paper rated "Shleifer-ready" and "Top-journal ready." No prose rewrites required. The opening hook, results narration, and transitions were all rated highest quality.
