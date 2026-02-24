# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### Concern 1: Behavioral health comparison group validity
> "BH is plausibly directly affected by lockdowns... Lockdowns plausibly increase BH need"

**Response:** We substantially expanded the discussion of comparison group validity in Section 4.2. We now present three pieces of evidence: (1) the timing pattern (no acute effect, delayed emergence) is inconsistent with contemporaneous BH demand shocks; (2) Figure 4 shows parallel BH trends across high/low stringency states—the DDD is driven by HCBS diverging, not BH diverging; (3) the CPT professional services alternative comparison group (Table 4) yields qualitatively similar results, providing triangulation. We acknowledge this remains the paper's most important identifying assumption.

### Concern 2: April 2020 stringency as proxy for persistent state characteristics
> "April 2020 stringency is a proxy for persistent state characteristics: political preferences, Medicaid administration capacity, labor market tightness"

**Response:** This concern is addressed by the state-by-month fixed effects, which absorb all time-varying state characteristics that affect HCBS and BH equally. The threat would need to operate through a channel that differentially affects HCBS relative to BH and changes over time in correlation with stringency. We discuss this explicitly in the limitations section.

### Concern 3: Wild cluster bootstrap p-values
> "Report wild cluster bootstrap p-values"

**Response:** The `fwildclusterboot` package is not available for our R version. We address the 51-cluster concern through two alternatives: (1) randomization inference (1,000 permutations) provides a finite-sample p-value that does not rely on asymptotic clustering assumptions; (2) we cite Cameron, Gelbach & Miller (2008) and note that 51 clusters is generally sufficient for asymptotic inference.

### Concern 4: 95% CIs in main tables
> "Report 95% CIs for the main coefficient(s)"

**Response:** Added 95% CI for the headline claims result in text: [-2.95, -0.40].

### Concern 5: Missing references (DiD methodology)
> "Callaway & Sant'Anna, Goodman-Bacon, Sun & Abraham, Roth"

**Response:** These were already in the bibliography. We now cite them explicitly in the Empirical Strategy section, noting that staggered-adoption concerns do not apply because our treatment is time-invariant with a common adoption date.

### Concern 6: Log-ratio specification
> "Construct log(HCBS) - log(BH) and run a simpler DiD"

**Response:** This is an interesting suggestion that we note for future work. The current triple-interaction specification with service-by-month FEs is algebraically equivalent to this approach but allows for separate extensive margin analyses (providers, beneficiaries) that the ratio approach does not accommodate.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: 95% CIs in main table
> "Suggest adding CIs to main Table 1 as columns"

**Response:** Added 95% CI for the headline result in text.

### Concern 2: Literature gaps (DiD/DDD methods, HCBS-COVID)
> "No cites to modern DiD/DDD foundations"

**Response:** Added explicit citations of Goodman-Bacon (2021), Callaway & Sant'Anna (2021), and Sun & Abraham (2021) in Section 4.1, with explanation of why staggered DiD concerns don't apply.

### Concern 3: Positive acute DDD
> "Positive acute DDD interpreted as BH telehealth ramp-up, but could reflect HCBS resilience"

**Response:** Good point. We discuss both interpretations in Section 5.3 (period effects).

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Concern 1: "Late emergence" puzzle—wage competition evidence
> "Can the author show state-level wage growth in retail/warehousing as an interaction?"

**Response:** We added a citation to Autor, Dube & McGrew (2023) documenting the unprecedented low-wage compression during 2021-2022, which provides the labor market context for the workforce scarring mechanism. State-level wage interactions are noted for future work as they would require additional data beyond T-MSIS.

### Concern 2: Medicaid policy heterogeneity (PHE unwinding, ARPA FMAP)
> "Does the timing of continuous enrollment or ARPA 9817 funds correlate with recovery?"

**Response:** We discuss ARPA HCBS enhanced FMAP in the Discussion section, noting that these interventions may have been insufficient to reverse structural workforce losses. The state-by-month FEs absorb the common component of these policies.

### Concern 3: Wild cluster bootstrap
> "Wild Cluster Bootstrap would be a standard top journal robustness check"

**Response:** Package unavailable for current R version; addressed via RI (1,000 permutations) and citation to Cameron et al. (2008).

---

## Prose and Exhibit Improvements

Per prose review feedback:
- Replaced "Several potential threats deserve explicit discussion" with "Three risks stand out"
- Replaced "Several features of the data merit discussion" with "Three features of this panel are worth noting"
- Replaced "Several limitations deserve acknowledgment" with "Four limitations constrain interpretation"
- Changed "The provider count margin shows a negative but imprecise effect" to "We see fewer providers overall—though the estimate is noisy"

Per exhibit review feedback:
- Updated Figure 1 y-axis label to "Triple-Difference Coefficient (log spending)"
- Updated Figure 1 caption to specify it shows "Triple-difference coefficients" from the Stringency × HCBS × Quarter interaction
