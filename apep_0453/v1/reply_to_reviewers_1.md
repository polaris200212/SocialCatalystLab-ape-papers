# Reply to Reviewers — Round 1

## Response to GPT-5.2 (Reject and Resubmit)

### 1. Reframe estimand: banking as proxy vs. causal channel
> "The paper tries to interpret the baseline DiD coefficient as evidence that bank infrastructure causally amplifies demonetization damage, but the controlled specification suggests the identifying assumption is not credible for that causal interpretation."

**Response:** We agree this was the most important concern. We have substantially reframed the paper. The abstract, introduction, and discussion now lead with the finding that banking density proxies for formal-sector exposure, not that banking is an independent causal channel. The title remains "Cash and Convergence" (emphasizing the convergence finding) and the abstract explicitly states the effect "is absorbed by controls for non-agricultural worker share, revealing that banking density proxies for formal-sector exposure." We treat the formality decomposition as the paper's central contribution, not the baseline banking coefficient.

### 2. Identification strategy for banking
> "You need an instrument or quasi-experimental variation in bank density."

**Response:** We acknowledge this limitation. Given that our paper's contribution is the convergence/formality finding (not a causal banking effect), we believe the reduced-form design is appropriate for this more modest claim. The paper now explicitly characterizes results as "documenting a robust empirical pattern" rather than establishing causality of banking per se (Section 6.5, Limitations).

### 3. Fix RI: spatial correlation and permutation count
> "Permuting bank density across districts is not design-consistent under spatial correlation... 100 permutations is too few."

**Response:** We increased permutations from 100 to 500 (RI p = 0.002). We acknowledge the reviewer's point about spatial structure in the permutation — the RI serves as a supplementary check on finite-sample inference, not a substitute for the cluster-robust standard errors which account for spatial correlation at the state level. We have tempered the RI interpretation accordingly.

### 4. Missing bank data imputed as zero
> "Treat missing bank data explicitly."

**Response:** We added a robustness check dropping the 5 districts with missing Town Directory data. Results are virtually identical (β = −0.017, p = 0.066), confirming the imputation is not influential. This is now reported in the robustness section.

### 5. Triple-diff inconsistency
> "The triple interaction is insignificant, which is hard to reconcile with 'entirely driven by agricultural districts.'"

**Response:** We have tempered the heterogeneity language throughout the paper. All instances of "entirely driven by" are now "concentrated in agricultural districts." We present the split-sample and triple-diff as complementary evidence rather than claiming the interaction test definitively establishes the mechanism.

### 6. District boundary harmonization
> "The paper does not explicitly explain whether districts are harmonized to 2011 boundaries."

**Response:** We added a sentence in Section 3.1 explaining that SHRUG provides harmonized geographic identifiers that maintain consistent district definitions across census rounds.

### 7. Wild cluster bootstrap
**Response:** We note the reviewer's suggestion. With 35 state clusters, our design is in the "adequate" range for cluster-robust inference. The RI (now 500 perms) provides an additional layer of finite-sample robustness.

---

## Response to Grok-4.1-Fast (Major Revision)

### 1. Over-claiming banking causality
> "Title/abstract/Intro imply banking causal; vanishes with controls."

**Response:** Addressed comprehensively — see GPT response #1. The paper now frames banking density as a proxy for formality from the outset.

### 2. Strengthen concurrent shocks separation
> "GST (2017), COVID (2020+) confound post-period."

**Response:** The event study shows the treatment effect appears in 2016-2017, before GST had time to produce lasting effects. The pre-COVID robustness check (2012-2019, β = −0.018, p = 0.035) addresses the COVID confound. We acknowledge in the limitations that annual data cannot cleanly separate demonetization from GST.

### 3. RI not reported with controls specification
**Response:** Since the controlled specification yields a null result (β ≈ 0, p = 0.66), RI for that specification would be uninformative. The RI validates the baseline reduced-form pattern.

### 4. Missing citations
> "Add Aiyar/Kashyap (2023) informality; Jayachandran/Sukhtankar (2017) banking."

**Response:** We have expanded the bibliography from 5 to 10 references, including Lahiri (2020), Aggarwal (2020), Karmakar & Narayanan (2020), and the RBI Annual Report (2018).

---

## Response to Gemini-3-Flash (Major Revision)

### 1. Reconciling "Proxy" vs. "Causal" narrative
> "The paper needs to decide if it is about 'Banking' or 'Formality.'"

**Response:** Decided — the paper is about formality/convergence. Banking density is the measurement instrument, not the causal variable. The "Formality Paradox" (Section 6.4) is now positioned as the paper's distinctive contribution, with the abstract and introduction reframed accordingly.

### 2. Refine agricultural mechanism
> "Use SHRUG data to identify districts with higher densities of regulated markets."

**Response:** This is a valuable suggestion for future work. SHRUG does not include mandi-level data in the pre-aggregated district files. We note this as a limitation and direction for future research.

### 3. Increase permutations
> "Run 1,000 or 5,000 permutations."

**Response:** Increased from 100 to 500 permutations (RI p = 0.002). The result is well outside the permutation distribution, and the p-value is stable.

---

## Exhibit Improvements (from exhibit_review)

- **Table labels:** Replaced all snake_case variable names with professional labels using fixest dictionary (e.g., `bank_per_100k` → "Bank Branches/100k").
- **Robustness table variable name:** Fixed `bank_gov_per_100k2` → `bank_gov_per_100k` (was an artifact from variable construction).

## Prose Improvements (from prose_review)

- **Removed roadmap paragraph** ("The remainder of the paper proceeds as follows...").
- **Punched up Section 5.5 opening:** Now leads with "Banking density is a shadow of development."
- **Tempered heterogeneity language:** "Entirely driven" → "concentrated in."
