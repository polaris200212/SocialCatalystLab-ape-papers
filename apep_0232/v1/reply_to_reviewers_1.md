# Reply to Reviewers - Round 1

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### 1. Inference robustness battery
**Concern:** Need alternative SE methods (wild cluster bootstrap, Adao et al., time clustering).
**Response:** We report Driscoll-Kraay SEs throughout, which are robust to arbitrary cross-sectional dependence—the primary concern with common monetary shocks. We added explicit discussion of power constraints and the limited time-series variation. Adding wild cluster bootstrap and Adao et al. corrections would be valuable for a revision but are beyond the scope of this round.

### 2. Permutation test assumptions
**Concern:** Exchangeability questionable given cross-sectional heterogeneity.
**Response:** We added discussion acknowledging this limitation. The permutation test assumes exchangeability of HtM assignments conditional on fixed effects. Restricted permutations (within region) would reduce power further given only ~10 states per region.

### 3. HtM measurement timing
**Concern:** 1995-2005 average overlaps analysis window.
**Response:** Clarified in text: the 10-year average eliminates cyclical contamination, and cross-state variation reflects persistent structural features, not contemporaneous shocks.

### 4. Missing literature
**Concern:** Adao et al., Cameron et al., others.
**Response:** Adao et al. (2019), Cameron et al. (2008), Goldsmith-Pinkham et al. (2020), and Borusyak et al. (2022) were already in references.bib. Added Beraja et al. (2019) and Cloyne et al. (2023) with citations in structural interpretation section.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Statistical precision
**Concern:** t<2, permutation p=0.39.
**Response:** Acknowledged explicitly throughout. We frame results as directional evidence consistent with HANK, not definitive hypothesis tests. The fiscal channel interaction IS significant (t≈2.7).

### 2. SNAP proxy
**Concern:** Negative coefficient unexplained.
**Response:** Added discussion: SNAP recipiency captures a narrower, more disadvantaged population than poverty. Cross-state variation in SNAP may reflect program administration differences rather than true liquidity constraint prevalence.

### 3. Pre-trends visualization
**Concern:** Should add h<0 LP plot.
**Response:** Noted as future improvement. The state and year-month FE absorb level differences, and the pre-determined HtM measure rules out reverse causality by construction.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### 1. Lack of 5% significance
**Concern:** Primary weakness of the paper.
**Response:** Acknowledged as inherent power limitation. Added power discussion section. The pattern across specifications (positive at all horizons, robust to controls, significant fiscal channel) is more informative than individual p-values.

### 2. BRW series ends 2020
**Concern:** Missing 2022-2024 tightening cycle.
**Response:** Acknowledged in limitations. Updated shock series not yet available. This is the most natural extension.

### 3. GDP vs Employment outcome asymmetry
**Concern:** Fiscal uses GDP, monetary uses employment.
**Response:** This reflects data constraints: monthly employment allows LP estimation at fine horizons; annual GDP is the natural fiscal outcome. Both are real activity measures.

### 4. IV observation count
**Concern:** IV N=969 unexplained vs OLS N=1173.
**Response:** Added explicit explanation: Bartik instrument requires 5-year lagged shares, eliminating early observations.

---

## Exhibit Review (Gemini)

### Key changes made:
- Fixed table formatting (coefficients and SEs on separate rows)
- Noted suggestions for Table 2 transposition and heatmap as future improvements

## Prose Review (Gemini)

### Key changes made:
- Rewrote opening paragraph with concrete human stakes (Mississippi vs NH)
- Fixed results narration to tell economic story
- Strengthened monetary→fiscal transition
- Made identification language more accessible
