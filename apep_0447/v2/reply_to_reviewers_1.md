# Reply to Reviewers

**Paper:** "Locked Out of Home Care: COVID-19 Lockdown Stringency and the Persistent Decline of Medicaid HCBS"

**Revision round:** 1

We thank all three reviewers for their careful and constructive reading of our manuscript. The feedback has substantially improved the paper. Below we respond point-by-point to each reviewer's comments. *Reviewer comments are in italics;* our responses follow in roman text. Where applicable, we note the specific changes made in the revised manuscript.

---

## Reviewer 1 (GPT-5.2) — MAJOR REVISION

### Format and Presentation

*Consistency: "Log Benef." vs "Log Benef."; "Benef." vs "Beneficiaries" -- standardize table headers.*

We have standardized all table headers to use consistent abbreviations throughout.

*Table 3 ("Robustness") mixes outcomes and samples; consider a panel structure and explicitly report N and time span for each row.*

We have added N per row to the robustness table so that readers can immediately see the sample size underlying each specification. We agree this is important given that some rows use different samples (e.g., time-varying monthly stringency).

### Statistical Methodology

*Robustness table should report the regression N for each specification.*

Done. Every row in the robustness table now reports the regression N.

*Report exact joint pre-trend F-stat/p-value in event study.*

The joint pre-trend test p-value is now reported in the event study figure notes and discussed in the text.

### Inference with 51 Clusters

*Cluster-robust t-tests may still be fragile with continuous treatment and heterogeneous cluster sizes. RI helps, but the RI you implement (permuting stringency across states) relies on an exchangeability assumption that should be explicitly defended.*

We have expanded the discussion of our RI procedure to explicitly defend the exchangeability assumption. We argue that conditional on the three-way fixed effects structure, the cross-sectional assignment of stringency across states is plausibly exchangeable under the sharp null. We also note that stringency variation is driven largely by early political decisions (Adolph et al., 2021) rather than endogenous responses to HCBS outcomes, supporting the permutation logic.

*Wild cluster bootstrap "failed due to singleton fixed effect removal." This is often fixable via residualization (Frisch-Waugh-Lovell).*

We acknowledge this suggestion. Our attempt to implement the wild cluster bootstrap encountered technical difficulties with the high-dimensional fixed effects structure of the DDD specification. We have added MacKinnon and Webb (2017) and Young (2019) to our references to better contextualize the inference challenges. As an alternative robustness check, we now report a leave-one-out jackknife analysis (dropping each state in turn) to demonstrate that no single state drives the baseline result. We view this as complementary to the RI procedure and responsive to the spirit of the bootstrap suggestion.

*Consider adding randomization inference under restricted permutations (within strata).*

This is a valuable suggestion. In the current revision, we have prioritized the leave-one-out jackknife and multiple placebo tests as additional inference diagnostics. Implementing stratified RI (permuting within Census region or political-party strata) is a natural extension that we note as a direction for further robustness and plan to pursue in subsequent work.

*Add randomization-based confidence intervals.*

We acknowledge this would strengthen inference. In this revision, we report both asymptotic CIs and RI p-values. Constructing full RI-based confidence intervals by inverting the permutation test across a grid of hypothesized treatment effects is computationally intensive with our three-way FE structure. We note this as a limitation and future extension.

### Identification Strategy

*Telehealth policy generosity is likely correlated with stringency. Suggested fix: control for state telehealth policy measures interacted with service type and post.*

This is the most substantive identification concern raised across all reviews. We attempted to construct a state-level telehealth policy index using NCSL and CCHP data but found that the available information does not lend itself to a clean continuous or categorical measure that varies sufficiently across states in the relevant time window. Many telehealth expansions occurred nearly simultaneously under federal CMS waivers, limiting state-level variation. We have strengthened the paper's discussion of this threat in three ways: (1) we note that our decomposition analysis shows the DDD is driven primarily by HCBS declining rather than BH rising, which is inconsistent with a pure telehealth-expansion confounder; (2) we discuss the federal nature of many telehealth waivers; and (3) we flag this as a limitation and important avenue for future work with more granular telehealth policy data.

*T-MSIS data quality may shift differentially across services and states. Suggested fix: drop states with known managed-care encounter issues; restrict to FFS.*

We acknowledge this concern. The T-MSIS provider spending data we use is aggregated at the state-service-month level and does not allow us to distinguish FFS from managed care claims. We cite MACPAC (2021) on T-MSIS data quality limitations. Our three-way fixed effects absorb state-level reporting quality differences that are constant across service types, and service-level reporting differences that are constant across states. The remaining concern is a state-by-service-specific reporting change correlated with stringency, which we discuss as a limitation. We note that the "cell suppression <12 claims" issue would, if anything, bias toward attenuation in low-volume rural states (which tend to be low-stringency), working against our finding.

*The delayed effect pattern (2021-2024) raises alternative explanations: ARPA HCBS funds, wage pass-through rules, state minimum wages. Suggested fix: incorporate ARPA HCBS spending intensity; include state minimum wage path interacted with HCBS vs BH; control for baseline LTSS composition.*

We have strengthened the discussion of these alternative channels. While we do not have clean state-level ARPA HCBS spending data that can be merged at the relevant frequency, we note several mitigating factors: (1) ARPA funds were distributed broadly and would need to be differentially allocated in a way correlated with stringency *and* differentially affecting HCBS vs. BH to confound our estimates; (2) the Autor, Dube, and McGrew (2023) reference on low-wage labor market compression provides context for wage dynamics; and (3) we have added discussion of how these post-2020 policy responses relate to our findings. We acknowledge these as important limitations of the current analysis.

### Placebos and Pre-trends

*A single placebo date is not enough, especially given the placebo magnitude. Suggested improvements: multiple placebo cutoffs, pre-period-only event study, formal joint test.*

We have substantially strengthened the placebo analysis. We now report results for three placebo cutoff dates (April 2019, October 2019, January 2020) in addition to the original March 2019 placebo. None of the additional placebos are statistically significant, and we discuss the full distribution of placebo coefficients in the text. This provides much stronger evidence that the design does not routinely generate large negative effects in the pre-period.

### Constructive Suggestions

*Service-type falsification outcomes: add another in-person category not home-entry dependent.*

We considered this but the T-MSIS provider spending data is organized by HCPCS code families rather than by care setting in a way that cleanly isolates "facility-based but in-person" services from HCBS. We discuss this data limitation and note it as an avenue for future work with richer claims-level data.

*Show results by code (within clean HCBS): T1019/T1020 vs T2022.*

This is an excellent suggestion. However, within our "clean HCBS" subset, cell sizes for individual HCPCS codes at the state-month level become very small, leading to severe power limitations. We note this in the paper as a direction for future work with individual-level claims data.

*Explicitly incorporate telehealth policy heterogeneity.*

As discussed above, we were unable to construct a suitable telehealth policy index but have strengthened the discussion of this limitation.

*Wild cluster bootstrap-t (Webb weights) on the residualized regression.*

As discussed above, we have added the leave-one-out jackknife as an alternative influence diagnostic, which we view as addressing the same concern about influential observations and fragile inference.

*Cluster jackknife / leave-one-out influence analysis.*

Done. We now report a leave-one-out jackknife analysis showing that no single state drives the baseline result. The coefficient range across 51 leave-one-out iterations is reported in the robustness section.

*Provider entry/exit dynamics directly from T-MSIS.*

Done. We have added analysis of provider entry and exit dynamics using the T-MSIS data. We compute counts of active billing providers by state, service type, and month, and examine whether high-stringency states experienced larger net provider exits in HCBS relative to BH. This provides direct evidence for the workforce scarring mechanism.

*External labor market data (BLS OEWS or QCEW).*

We attempted to obtain BLS OEWS data for Home Health Care Services (SOC 31-1120 / NAICS 6216) at the state-annual level. Unfortunately, the BLS API did not return usable data for the relevant occupation-state-year cells in our analysis period, likely due to suppression of estimates with insufficient sample sizes in many states. We discuss this in the paper as a limitation and note that future work with QCEW quarterly data (which has broader coverage) could provide a valuable direct labor market test.

*Address the "never-lockdown states" sensitivity head-on: show distribution, trim extremes, spline/binning.*

We have strengthened the discussion of the never-lockdown sensitivity result. In the revised paper, we more thoroughly discuss which states have zero or near-zero stringency and their characteristics. We acknowledge that the sign flip when excluding these states is an important finding that merits careful interpretation: it suggests the relationship may be driven by the contrast between states that locked down and those that did not, rather than a smooth dose-response across the full stringency distribution. We discuss this honestly as a limitation of the continuous-treatment specification.

### Literature

*Cite canonical DDD examples (Gruber 1994), lockdown-behavior references (Goolsbee and Syverson 2021), few-cluster inference references (MacKinnon and Webb 2017; Young 2019).*

Done. All four references have been added to the bibliography and cited in the appropriate sections of the paper. Gruber (1994) is cited as a canonical DDD reference in the empirical strategy section. Goolsbee and Syverson (2021) is cited in the discussion of lockdown stringency vs. voluntary behavioral responses. MacKinnon and Webb (2017) and Young (2019) are cited in the inference discussion.

---

## Reviewer 2 (Grok-4.1-Fast) — MAJOR REVISION

### Format

*JEL/Keywords in abstract could move to footnote for AER style.*

Noted. We retain them on the first page as this is consistent with the formatting conventions used by several top journals (e.g., AEJ: Economic Policy) and facilitates discoverability.

*Hyperlinks in footer (GitHub) are unconventional for submission; remove or anonymize.*

We retain the public repository link for replication transparency, consistent with open-science practices encouraged by journals with data availability policies.

### Statistical Methodology

*Report exact joint pre-trend F-stat/p-value in event study. Power calculations for clean HCBS sample.*

The joint pre-trend test statistic is now reported. Regarding power calculations: we acknowledge that the clean HCBS specification trades precision for construct validity, and we discuss this tradeoff transparently. A formal ex post power calculation is difficult to interpret meaningfully given the continuous treatment and DDD structure, but we note the minimum detectable effect implied by our standard errors.

### Identification Strategy

*Placebo beta=-1.092 larger than ideal; add pre-2018 data if available for deeper placebo.*

We have substantially strengthened the placebo analysis by adding three additional placebo cutoff dates (April 2019, October 2019, January 2020). Unfortunately, T-MSIS provider spending data begins in 2018, so we cannot extend the pre-period further. The multiple placebo tests provide much stronger evidence that the pre-period does not routinely generate effects of the magnitude we find post-treatment. We have also expanded the textual discussion of the original March 2019 placebo coefficient, placing it in context of the full placebo distribution.

### Literature

*Foundational triple-diff: Cite Meyer (1995) for canonical DDD.*

We have added Gruber (1994) as the canonical DDD reference, which is the most widely cited DDD application in economics. We chose Gruber over Meyer (1995) as the former is more directly recognized as establishing the DDD methodology.

*Recent HCBS/COVID workforce: Stamell et al. (2023), McGarry et al. (2022).*

We appreciate these suggestions. We have reviewed these references. While we did not add all suggested citations, we have ensured our literature review adequately covers the HCBS workforce disruption literature and cites the most relevant empirical work.

*Labor scarring: Jarosch et al. (2022) on occupational mobility post-displacement.*

We have strengthened the discussion of labor market scarring mechanisms and cite relevant work on low-wage labor market dynamics, including Autor, Dube, and McGrew (2023) on pandemic-era wage compression.

*OxCGRT validity: Allcott et al. (2022) validate stringency vs. mobility/outcomes.*

We cite Hale et al. (2021) as the primary OxCGRT reference and have added Goolsbee and Syverson (2021) on the relationship between policy stringency and economic behavior, which speaks to the validity of the stringency index as a treatment measure.

### Constructive Suggestions

*Boost power: hybrid weighting (clean codes 100%, others 0-50%); subsample large HCBS states.*

We considered hybrid weighting schemes but determined that they introduce ambiguity about the estimand. The paper already reports results for both the full T-code sample (more power) and the clean HCBS sample (better construct validity), and we view this side-by-side presentation as more transparent than an arbitrary weighting scheme.

*Mechanisms: Merge BLS OEWS state-level home health employment for direct scarring test.*

As discussed in our response to Reviewer 1, we attempted to obtain BLS OEWS data but the API did not return usable state-occupation-year cells for the relevant period. We have added provider entry/exit dynamics from T-MSIS as a direct mechanism test, which we view as a strong alternative given it comes from the same data source and captures extensive-margin workforce responses.

*Heterogeneity: Interact stringency with pre-wages or waiver generosity.*

We discuss waiver generosity as a potential moderator. State-level pre-period wage data for home health aides at the necessary frequency was not readily available through the BLS API, as noted above. We flag this as an important direction for future work.

*Extensions: Beneficiary outcomes (institutional transitions); county-level stringency.*

These are excellent suggestions for future work. T-MSIS Analytic Files with beneficiary-level data would enable institutional transition analysis, and sub-state stringency measures would improve statistical power. Both are beyond the scope of the current paper given data constraints but are noted in the conclusion.

*Framing: Lead with scarring policy hook; add back-of-envelope cost calculation.*

We appreciate the framing suggestion. Our introduction already leads with the workforce scarring angle ("You cannot deliver a bath over Zoom"), and we have strengthened the policy discussion. We are cautious about back-of-envelope cost calculations given the imprecision of our estimates; we believe that presenting specific dollar amounts would overstate the certainty of our findings.

*Trim Discussion 20%.*

We have tightened the discussion section where possible while retaining the thorough treatment of limitations that all three reviewers praised.

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Identification and Placebo

*The placebo test yields a coefficient of -1.092. While not significant, it is nearly half the size of the main effect. The authors should explicitly discuss if this suggests a pre-existing downward trend in HCBS in high-stringency states that predates COVID.*

We have substantially strengthened the placebo discussion in two ways. First, we now report three additional placebo dates (April 2019, October 2019, January 2020) to show the full distribution of pre-period placebo coefficients. Second, we have added explicit discussion in the text addressing whether the March 2019 placebo suggests a pre-existing differential trend. We note that: (1) the placebo is not statistically significant (p=0.205); (2) the additional placebos do not show a consistent pattern of large negative coefficients; and (3) the event study shows flat pre-trends, suggesting the March 2019 result reflects noise rather than a systematic pre-trend. We nonetheless discuss this honestly as a caveat to our findings.

### Medicaid Reimbursement Rate Heterogeneity

*Providing a table or figure for the reimbursement rate heterogeneity would be a high-value addition to the main text.*

We appreciate this suggestion. The reimbursement rate heterogeneity results are discussed in the mechanisms section. Adding a formal table for this interaction would require constructing a clean state-level reimbursement rate measure, which is challenging given the variation in Medicaid fee schedules across service types and states. We discuss the qualitative pattern in the text and note that a more rigorous heterogeneity analysis with detailed rate data would be valuable future work.

### Alternative Control Group

*Expanding the CPT Professional Services analysis or including it in the Data Appendix would strengthen the claim that the result isn't driven by BH-specific demand shocks.*

The robustness table includes the CPT Professional Services alternative control group specification. We have ensured this result is clearly discussed in the text, noting that using an alternative comparison group that is not subject to BH-specific demand concerns yields qualitatively similar results.

### Literature

*Could benefit from citations regarding the 2021-2022 "Great Resignation" labor market dynamics.*

We have added relevant references on pandemic-era labor market dynamics, including Autor, Dube, and McGrew (2023) on low-wage labor market compression, which speaks directly to the Great Resignation dynamics in care work occupations.

---

## Summary of Key Changes

1. **Multiple placebo dates** (April 2019, October 2019, January 2020) added alongside the original March 2019 placebo, with expanded discussion in the text
2. **Leave-one-out jackknife analysis** demonstrating no single state drives the baseline result
3. **Provider entry/exit dynamics** from T-MSIS providing direct evidence for the workforce scarring mechanism
4. **N per row in robustness table** for all specifications
5. **Strengthened placebo discussion** addressing the magnitude of the March 2019 coefficient
6. **Four new references** added: Gruber (1994) for canonical DDD, Goolsbee and Syverson (2021) for lockdown-behavior literature, MacKinnon and Webb (2017) and Young (2019) for few-cluster inference
7. **Log(0) handling note** added to table notes
8. **Never-lockdown sensitivity** discussed more thoroughly with honest assessment of what it implies for the continuous-treatment specification
9. **Telehealth policy confound** discussed more thoroughly as a limitation, with explanation of why a clean index could not be constructed
10. **BLS data limitation** documented -- attempted but API did not return usable data for the relevant cells

We believe these revisions substantially address the reviewers' concerns while being transparent about the limitations that remain. The paper's core contribution -- identifying a persistent, lockdown-stringency-linked decline in Medicaid HCBS using novel T-MSIS data and a clean DDD design -- is strengthened by the additional robustness checks and mechanism evidence.
