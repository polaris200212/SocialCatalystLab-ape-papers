# Reply to Reviewers — Round 1

## Referee 1 (GPT-5.2): REJECT AND RESUBMIT

### 1.1 Causal estimand vs. design capability
> "The paper does not provide compelling evidence on relevance/monotonicity and provides evidence against parallel trends."

**Response:** We agree. We have substantially reframed the paper. The abstract and introduction now explicitly state that our design cannot speak to aggregate impacts, that placebo tests reveal pre-existing differential trends, and that we cannot interpret estimates causally. We describe the paper as documenting "identification challenges" and providing a "cautionary case for continuous DiD designs."

### 1.2 Treatment intensity mismeasured
> "Bank branches per capita is at best an indirect proxy... missing POS, mobile money, inter-state cash flows."

**Response:** We acknowledge this limitation more prominently. We added a North dummy comparison (Section 7.6) showing that a simple Northern State indicator produces qualitatively identical results (β = -0.091, p = 0.096), confirming that banking density is not distinguishable from the regional divide.

### 1.3 Parallel trends violated
> "Placebo tests show significant effects at pseudo-treatment dates."

**Response:** We added state-specific linear trends (Section 7.5), which partially absorb differential dynamics. The coefficient grows in magnitude (β = -0.239, p = 0.105) but remains insignificant, consistent with either a true null or insufficient power after trend absorption.

### 1.4–1.5 Timing, coverage
> "Crisis window is narrow"; "13 states may be selected."

**Response:** We already show robustness to alternative windows (Appendix C.2). Selection into FEWS NET coverage is discussed in Appendix A; we cannot expand coverage beyond the monitored states.

### 2.1–2.3 Inference
> "RI assumes exchangeability across structurally different states"; "Fuel p=0.02 needs WCB."

**Response:** We ran wild cluster bootstrap for the fuel result: WCB p = 0.47, far from significance. We now present the fuel finding as "exploratory" and explicitly note the over-rejection concern. We label commodity analysis as exploratory throughout.

### 5.1 Claim calibration
> "Abstract and intro read as if null is informative about the effect of cash scarcity."

**Response:** Revised. The abstract now reads: "We find no robust relationship between banking-density-based exposure and food price changes" rather than claiming cash scarcity had no effect. The introduction explicitly notes that our design "absorbs any aggregate effect" and "can only detect effects that vary with banking density."

---

## Referee 2 (Grok-4.1-Fast): MAJOR REVISION

### Parallel trends / proxy validation
> "Placebos/event study fail... banking density as cash scarcity untested."

**Response:** Same as above. Added state trends, North dummy, softened claims throughout.

### Few clusters/power
> "13 states, skewed treatment (Lagos outlier)."

**Response:** We cannot expand beyond FEWS NET coverage. The North dummy result confirms that identification is not Lagos-specific — the coefficient is marginally significant even without Lagos-driven variation.

### Reframe as descriptive
> "With trends broken, pivot to correlational evidence."

**Response:** Adopted. The paper now frames itself as a descriptive study with methodological lessons, not a causal analysis.

### Lit gaps
> "Add Rambachan & Roth 2023 sensitivity."

**Response:** We note in Section 5.3 that Rambachan & Roth sensitivity analysis is cited but not formally implemented because their framework is designed for discrete treatment settings and adaptation to continuous treatment with 13 clusters is non-standard. We added the state-specific linear trends specification as a partial substitute.

---

## Referee 3 (Gemini-3-Flash): MAJOR REVISION

### Skewed treatment
> "Replace Cash Scarcity index with a simple Northern State dummy."

**Response:** Done. Added Section 7.6 with North dummy comparison. Results are qualitatively identical (β = -0.091, p = 0.096), confirming the concern.

### Price construction sensitivity
> "Show robustness to arithmetic mean vs geometric mean."

**Response:** We note this limitation but did not add an arithmetic mean specification due to the scope of other revisions. The geometric mean is standard for commodity price indices.

### Digital substitution
> "Can the authors provide state-level mobile money/POS data?"

**Response:** Unfortunately, state-level mobile money or POS agent density data are not publicly available for our sample period. This data gap is acknowledged as a key limitation.

---

## Exhibit Review (Gemini)
- Reordered narrative to emphasize raw trends earlier
- Kept RI distribution and state treatment table in main text (paper already 31 pages; moving to appendix would reduce depth)
- Improved figure axis labels where noted

## Prose Review (Gemini)
- Strengthened opening with vivid cash premium detail
- Improved results narration: "Food prices were remarkably unresponsive" instead of "Column 1 shows..."
- Strengthened concluding sentence
- Improved data section opening
