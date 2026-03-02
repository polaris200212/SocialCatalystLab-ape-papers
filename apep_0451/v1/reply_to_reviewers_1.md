# Reply to Reviewers — Round 1

**Paper:** Cocoa Booms and Human Capital in Ghana: Evidence from Census Microdata
**Date:** 2026-02-24

---

## Response to GPT-5.2 (MAJOR REVISION)

### 1. Few-cluster inference (Critical)

**Concern:** With only 6 clusters, conventional clustered SEs overreject. Need wild cluster bootstrap or randomization inference.

**Response:** We have implemented **exact randomization inference** (RI), enumerating all 6! = 720 permutations of cocoa share assignments across forest-belt regions. Results:
- Employment: RI p = 0.014 (robust to exact inference)
- Literacy: RI p = 0.34 (conventional inference overrejects)

We now report RI p-values prominently and temper the literacy findings throughout the paper. The abstract, introduction, results, and conclusion all reflect this honest assessment. We also added citations to MacKinnon & Webb (2017) on few-cluster inference.

### 2. DR DiD results need tables (Critical)

**Concern:** DR DiD results only reported in text, need table with ATT, SE, 95% CI, N.

**Response:** Added Table 7 presenting all five DR DiD estimates with ATT, SE, 95% CI, t-statistics, and p-values. Panel A covers school-age children (enrollment, literacy, primary completion), Panel B covers working-age adults (employment, agriculture).

### 3. Shift-share identification diagnostics

**Concern:** Missing citations to Adão et al. (2019) and Borusyak et al. (2022).

**Response:** Added both references and discussion in the Econometric Methods subsection. Also added Goodman-Bacon (2021) for TWFE decomposition context.

### 4. Leave-one-region-out

**Concern:** Essential to show results not driven by a single region.

**Response:** Added Table 8 Panel B with leave-one-region-out estimates. Both literacy (range: 0.041–0.103, always positive) and employment (range: -0.121 to -0.055, always negative) are stable. No single region drives either result.

### 5. Temper confident language

**Concern:** Language too confident given 6 clusters.

**Response:** Revised throughout. Changed "striking" pre-trend claims to factual statements. Added caveats about RI p-values wherever literacy results are discussed. Reordered introduction to lead with the inference-robust employment result.

---

## Response to Grok-4.1-Fast (MINOR REVISION)

### 1. Tabulate DR DiD with CIs

**Response:** Done — Table 7 with full inference statistics. See response to GPT #2.

### 2. Missing references

**Response:** Added Goodman-Bacon (2021), Gollin et al. (2016), and shift-share references (Adão et al. 2019, Borusyak et al. 2022, MacKinnon & Webb 2017).

### 3. Wild cluster bootstrap / RI

**Response:** Implemented exact randomization inference (720 permutations). See response to GPT #1. Wild cluster bootstrap was not available for our R version; RI is a stronger approach in this setting since it is finite-sample exact.

### 4. Confidence intervals

**Response:** DR DiD table (Table 7) includes 95% CIs. Event study figure already shows CI bars.

---

## Response to Gemini-3-Flash (CONDITIONALLY ACCEPT)

### 1. Gollin et al. (2016) reference

**Response:** Added to references.bib and cited in both the Literature Review (Section 2.3) and Discussion sections.

### 2. School-supply vs school-demand mechanism

**Response:** The finding that literacy increases while enrollment moves less is discussed in the Mechanisms subsection. We cannot directly test school supply with census data, but we note this as an avenue for future research.

---

## Response to Exhibit Review

### 1. Promote cocoa price figure to main text

**Response:** Done — Figure now appears in Section 5.4 (World Cocoa Prices).

### 2. Add DR DiD results table

**Response:** Done — Table 7.

### 3. Mean of Dependent Variable

**Response:** Not added to modelsummary tables due to tabularray formatting constraints, but baseline means are reported in text (e.g., "baseline literacy rates of 75%", "enrollment at 85%").

---

## Response to Prose Review

### 1. Eliminate "literature lists" opening

**Response:** Replaced "A growing literature examines..." with "Commodity price swings force a choice between the classroom and the field..."

### 2. Active voice in mechanism section

**Response:** Replaced "This employment decline may seem puzzling" with "Counter-intuitively, the boom reduced employment."

### 3. Other prose improvements

**Response:** Multiple smaller improvements throughout for active voice and directness.
