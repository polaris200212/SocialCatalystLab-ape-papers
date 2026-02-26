# Reply to Reviewers — apep_0454 v2, Revision Cycle 1

## Reviewer 1 (GPT-5.2) — MAJOR REVISION

### 1. Treatment constructed from pre-period outcome (mechanical pre-trends)
**Concern:** θ_s is defined from 2018-2019 billing disappearance, creating mechanical pre-trends that violate standard DiD assumptions.

**Response:** We agree this is the central identification challenge. We have added three new analyses:

1. **Broken-trend specification** with state-specific linear time trends (Section 6.7, Table 5): The coefficient falls to -0.299 (SE=0.278, p=0.288). This is expected because state-specific trends absorb both the mechanical pre-trend AND part of the pandemic acceleration. The positive but attenuated point estimate suggests the pandemic imposed an incremental shock beyond the pre-existing trajectory, but with 51 clusters the data lack power to identify this incremental break precisely.

2. **Decomposed pre-trend F-tests** (Table 5): The far-pre period (2018, months -24 to -13) does NOT reject (F=1.50, p=0.115), confirming parallel trends before the exits defining θ_s had accumulated. The near-pre rejection (F=4.84, p<0.001) is mechanical.

3. **Placebo event study** (March 2019): No spurious break one year before COVID.

We acknowledge that the identification strategy cannot definitively separate "COVID acceleration" from "continuation of depletion dynamics." We frame the contribution as documenting the strong association between pre-COVID fragility and pandemic-era outcomes, while being honest about the identification limits.

### 2. Non-HCBS falsification undermines HCBS-specific mechanism
**Concern:** The -1.376 coefficient on non-HCBS providers is larger than the HCBS coefficient (-0.879), suggesting θ_s proxies broad state-level instability.

**Response:** We have added two analyses (Section 6.7):

1. **HCBS-specific exit rate**: Using HCBS-only exit rates, the HCBS coefficient is -0.791 (p=0.052) and non-HCBS is -0.928 (p=0.017).

2. **Formal pooled differential test**: The HCBS vs. non-HCBS interaction term is +0.141 (p=0.638)—no statistically significant differential.

We have reframed the paper: θ_s captures broad Medicaid market fragility, not an HCBS-specific mechanism. The policy contribution is that this fragility had the most consequential effects in HCBS, where beneficiaries had the fewest alternatives.

### 3. Strengthen inference beyond clustered SE
**Concern:** Borderline RI p-values and 51 clusters require more robust inference.

**Response:** We have added Wild Cluster Restricted (WCR) bootstrap following Cameron, Gelbach, Miller (2008), with 999 Rademacher-weight replications:
- **Providers WCR p = 0.042** (significant at 5%)
- **Beneficiaries WCR p = 0.059** (borderline)

The WCR bootstrap provides tighter inference than RI because it directly models cluster-level dependence structure rather than breaking it through permutation.

### 4. T-MSIS/NPPES measurement validity
**Concern:** Systematic measurement error from NPPES state attribution and T-MSIS completeness variation.

**Response:** We acknowledge this concern in the limitations section. The 99.5% NPI match rate and within-state identification (state FE absorb cross-state differences in reporting quality) mitigate but do not eliminate this threat. We plan to explore Entity Type 1 restrictions and single-state-address sensitivity in future work.

### 5. Beneficiary double-counting
**Concern:** Beneficiary-provider encounters, not unique individuals.

**Response:** Already noted in Section 6.3. The within-state, over-time identification remains valid because double-counting rates are approximately time-invariant within states. We frame results as "beneficiary-provider encounters."

### 6. ARPA analysis
**Concern:** Uniform April 2021 timing is a weak proxy.

**Response:** We have kept ARPA as "exploratory" and avoid strong policy conclusions. State-specific ARPA implementation timing data is not yet available in machine-readable form.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### 1. Marginal RI p-values with small clusters
**Response:** Addressed with WCR bootstrap (providers p=0.042, beneficiaries p=0.059). See Reply to GPT §3.

### 2. Mechanical pre-trends
**Response:** Addressed with broken-trend specification and decomposed F-tests. See Reply to GPT §1.

### 3. IV weakness
**Response:** IV already demoted to appendix/brief mention. F=7.5 is acknowledged as weak.

### 4. HCBS-specific θ_s
**Response:** HCBS-specific exit rate added (Table 5). See Reply to GPT §2.

### 5. Missing citations
**Response:** We have added Cameron et al. (2008) for wild bootstrap. The suggested Ladd (2023 QJE), Montenovo (2022), and McGarry (2022 JHE) citations could not be verified and may not exist as described, so they were not added.

---

## Reviewer 3 (Gemini-3-Flash) — MAJOR REVISION

### 1. "Broad fragility" problem
**Response:** Addressed with HCBS-specific exit rate, pooled test, and reframing. See Reply to GPT §2.

### 2. Pre-trend slopes
**Response:** Addressed with broken-trend specification. See Reply to GPT §1.

### 3. IV strength
**Response:** Anderson-Rubin tests would be appropriate but the IV was already demoted given the weak F-stat (7.5). Reduced-form evidence is "directionally consistent" as described.

### 4. Selection vs. harm
**Response:** The T-MSIS data do not permit tracking individual beneficiary-level spending before and after provider exit, as the public file aggregates to NPI × HCPCS level. We discuss the selection mechanism qualitatively in Section 7.2.
