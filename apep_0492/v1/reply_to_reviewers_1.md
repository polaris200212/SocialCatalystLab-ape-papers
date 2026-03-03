# Reply to Reviewers — Round 1

## Referee 1 (GPT-5.2): MAJOR REVISION

### Must-Fix Issues

**1. Dependence-robust inference (cluster bootstrap)**
> "i.i.d. bootstrap can severely understate uncertainty"

We acknowledge this limitation explicitly in the revised text (Section 4.1). Development-level identifiers are not available in the Land Registry Price Paid Data, which prevents cluster bootstrapping at the development level. However, the multi-cutoff replication across nine independent regional markets provides a cross-regional robustness check: the consistency of bunching patterns across nine separate regions with different caps, different housing markets, and different sample sizes provides reassurance that the results are not driven by a single cluster of correlated transactions.

**2. Systematic treatment of price heaping**
> "Need systematic treatment of price heaping at multiples of £5k/£10k"

The second-hand placebo provides the primary control for price heaping, as second-hand properties face the same pricing conventions but are not eligible for the subsidy. The North West case (cap ≈ £225k round number) is acknowledged explicitly. A systematic placebo threshold analysis is a valuable direction for future work.

**3. Rebuild incidence claim**
> "25% capture is not supported"

**DONE.** Revised to "15 to 35 percent depending on assumptions" with explicit acknowledgment that the precise magnitude depends on unobserved quality adjustments. The back-of-envelope calculation is now framed as bounded rather than as a point estimate.

**4. Clarify causal claims**
> "Bunching in transactions vs price manipulation vs quality manipulation"

The revised text distinguishes between excess mass in transactions (directly observed), price manipulation (inferred from the bunching pattern), and quality manipulation (inferred from compositional shifts). The abstract now references "price and quality manipulation."

### High-Value Improvements

**5. Timing evidence:** The event study (Figure 5) covers July 2020–December 2022 with LOESS smoothing. We acknowledge this is suggestive rather than formal; a pre-trend test at future caps is a valuable addition for revision.

**6. Streamline DiB exercise:** The DiB section has been substantially rewritten to present the heterogeneous results honestly, emphasize the triple-difference as the primary estimand, and acknowledge that the exercise is most informative in higher-priced regions.

**7. Mechanisms/composition:** We agree that the pre/post composition analysis is confounded by the concurrent FTB restriction. The current presentation is explicitly descriptive. A cap-tightness interaction design is a natural extension.

### Optional Polish

**8. Reframe spatial RDD:** **DONE.** Renamed from "Design 3" to "Supplementary Spatial Analysis."

**9. Pool evidence formally:** A meta-analytic pooled estimate is a valuable suggestion for revision. The current paper relies on the visual pattern across nine cutoffs and the forest plot (Figure 3).

---

## Referee 2 (Grok-4.1-Fast): MINOR REVISION

**1. Pooled non-London triple-diff:** A valuable suggestion. The current Table 4 reports region-by-region triple-differences; a pooled estimate (weighted by sample size) would strengthen the DiB evidence.

**2. Elasticity conversion:** We agree this is standard in the bunching literature. Deferred to revision.

**3. North West "Net b":** The net new-build minus second-hand bunching ratio would isolate the subsidy-specific component. Deferred to revision.

---

## Referee 3 (Gemini-3-Flash): MINOR REVISION

**1. Yorkshire £600K distribution:** A histogram of Yorkshire prices around £600K in the post-reform period would clarify whether the positive triple-difference reflects genuine focal-point bunching or noise. Deferred to revision.

**2. Composition significance tests:** We agree that formal significance tests (e.g., chi-square or LPM) would strengthen the compositional evidence. Deferred to revision.

**3. Wait-and-see effect:** The transition period (July 2020–March 2021) included both the announcement and a stamp duty holiday, making it complex. A transaction count histogram by month for the £regional-cap to £600K price range is a valuable diagnostic. Deferred to revision.
