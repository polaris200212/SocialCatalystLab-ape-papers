# Revision Plan: apep_0454 v3

## Context

Paper 454 v2 ("The Depleted Safety Net") was just published. It documents that pre-COVID HCBS provider exits predicted pandemic-era supply disruption and beneficiary access losses. All three v2 referees gave MAJOR REVISION, with a unified concern: **mechanical pre-trends from the treatment definition** (theta_s constructed from 2018-2019 exits creates near-pre F-test rejection by construction). The broken-trend spec (state-specific linear trends) nullifies the main effect (-0.30, p=0.29).

**Parent:** apep_0454 v2 (published, not yet rated)
**Referee decisions (v2):** GPT MAJOR, Grok MAJOR, Gemini MAJOR
**User directive:** "the paper is nowhere near an abstract and introduction that is Shleifer-level... ridiculously badly connected to conceptual questions, prose, and the literature. As if Shleifer did it."

This v3 has two mandates:
1. **Methodological:** Address the identification concerns with HonestDiD bounds, conditional RI, binarized-treatment robustness via augsynth, and exit-timing validation
2. **Prose:** Completely rewrite the abstract and introduction to Shleifer-level quality — punchy, conceptually grounded, literature-embedded, every sentence earned

---

## Workstream 1: Shleifer-Level Rewrite of Abstract + Introduction

**This is the highest-priority workstream.** The current intro is competent but reads like a report, not a top-journal paper. It lacks a unifying conceptual frame, doesn't connect to deep questions in economics, and buries the reader in institutional detail before establishing intellectual stakes.

### Problems with the Current Intro

1. **No conceptual hook.** Opens with a wage statistic ($14.15/hour). Mildly interesting but not a puzzle or a question. Compare Shleifer's style: he opens with a claim about the world that makes you think.

2. **"This paper documents a troubling pattern" (line 93).** Classic throat-clearing. What pattern? Why should an economist care? The current framing is purely descriptive — "providers left, then COVID was bad." Where's the economic logic?

3. **Literature dump (lines 103-109).** Four paragraphs of "contributes to X literature" read like a checklist, not an argument. Shleifer weaves the literature into the story — you learn what others found *because you need it* to understand the next sentence.

4. **Missing conceptual question.** The paper has one hiding in plain sight: **Does the maintenance of safety-net infrastructure matter, or are markets self-correcting?** This is a first-order question in economics — it connects to Hirschman's "Exit, Voice, and Loyalty," to the literature on hysteresis (Blanchard & Summers 1986), to the debate about whether labor markets clear. The paper never frames itself this way.

5. **The "so what" is buried.** The beneficiary results — the actual welfare consequences — appear in paragraph 4 (line 97). In a Shleifer paper, the human stakes would be in the first paragraph.

### The Rewrite

**New abstract (target: 120 words, every word earned):**

Open with the conceptual insight (infrastructure maintenance vs. reactive spending), state the finding with numbers, state the method, state why it matters. No throat-clearing, no "this paper."

**New introduction structure (Shleifer arc):**

1. **Hook (1 paragraph):** The puzzle of safety-net hysteresis. Markets are supposed to self-correct. A provider exits, a new one enters. But what if the safety net doesn't work like that? What if gradual erosion creates fragility that only becomes visible when a shock arrives? Frame around Hirschman/hysteresis/infrastructure maintenance.

2. **What we do + what we find (2 paragraphs):** Tight description of data (T-MSIS, 617K providers, 84 months), treatment (pre-COVID exit rate), result (6% providers, 7% beneficiaries). State the numbers. The beneficiary result comes early — this is the welfare finding.

3. **The identification tension (1 paragraph):** Be ruthlessly honest upfront. "Because the treatment is constructed from pre-period exits, mechanical pre-trends are present. I address this with [HonestDiD bounds, conditional RI, augsynth robustness]." Owning the weakness early signals confidence, not vulnerability.

4. **Why it matters — conceptual (1 paragraph):** Connect to the economics. This is about whether safety-net labor markets exhibit hysteresis (Blanchard & Summers 1986 in a new domain). The persistence finding (no recovery by 2024 despite $37B ARPA) is the strongest evidence. Connect to Dranove (2003) on hospital vulnerability, but note we're in a fundamentally different market (no barriers to entry, yet no recovery — the puzzle deepens).

5. **Literature positioning (1-2 paragraphs):** Woven into the argument, not a separate section. What do we know about healthcare workforce resilience? What did the Oregon experiment show about the supply-side vs. demand-side of access? How does this paper change our understanding? Each citation earns its place.

6. **Road forward (1 sentence):** Brief, elegant transition. No "The paper is organized as follows."

### Key Prose Principles

- **Every sentence must do work.** Cut "It is important to note," "A growing literature," "Prior research has relied on." Just say the thing.
- **Active voice throughout.** "I construct... I show... The data reveal..."
- **Vary sentence rhythm.** Short sentences land points. Longer ones develop nuance.
- **Numbers tell the story.** Don't say "significantly larger declines" — say "6 percent fewer providers."
- **The reader should feel intellectual excitement**, not obligation.

---

## Workstream 2: HonestDiD Sensitivity Bounds (Primary Methodological Upgrade)

**Goal:** Directly quantify how severe parallel-trends violations would need to be to overturn the result. This is the single most important methodological addition — it converts the mechanical pre-trends problem from an existential threat into a bounded, interpretable quantity.

### Implementation in `04_robustness.R`

```r
library(HonestDiD)

# Extract event study coefficients from fixest (excluding ref period -1)
# Use relative magnitudes approach (Delta^RM):
#   "post-treatment trend deviation <= Mbar × max pre-treatment deviation"
honest_rm <- createSensitivityResults_relativeMagnitudes(
  betahat = es_coef_vec,
  sigma = es_vcov_mat,
  numPrePeriods = n_pre,
  numPostPeriods = n_post,
  Mbarvec = seq(0, 2, by = 0.25),
  alpha = 0.05
)

# Also run smoothness restriction (Delta^SD):
#   bounds the second differences of the bias
honest_sd <- createSensitivityResults(
  betahat = es_coef_vec,
  sigma = es_vcov_mat,
  numPrePeriods = n_pre,
  numPostPeriods = n_post,
  Mvec = seq(0, 0.1, by = 0.01),
  alpha = 0.05
)
```

### New figure: HonestDiD sensitivity plot
- X-axis: Mbar (allowed pre-trend violation magnitude)
- Y-axis: robust confidence set for the treatment effect
- Horizontal line at zero
- Vertical dashed line at breakdown value
- Run for providers AND beneficiaries

### Paper text
- New subsection in Robustness (Section 6.7): "Formal Sensitivity to Pre-Trend Violations"
- Report breakdown Mbar: "The result survives pre-trend violations up to [X] times the maximum observed pre-trend deviation"
- Add to abstract if breakdown value is compelling

---

## Workstream 3: Conditional Randomization Inference

**Goal:** Tighten RI p-value from 0.083 by permuting within Census divisions (preserving regional structure).

### Implementation in `04_robustness.R`

```r
# Permute exit_rate WITHIN 9 Census divisions (5,000 permutations)
# Preserves geographic structure that unconditional RI breaks
# Expected: tighter p-value because regional confounders are held fixed
```

Report: "Conditional RI (within Census divisions, 5,000 permutations): providers p = [X], beneficiaries p = [X]"

---

## Workstream 4: Binarized Treatment + augsynth Robustness

**Goal:** Provide complementary evidence using fundamentally different identifying assumptions.

### Why augsynth
- All counterfactual imputation methods (augsynth, gsynth, synthdid, fect) require binary treatment
- Binarize: above-median exit rate = "treated" (25-26 states)
- augsynth (Ben-Michael et al. 2021) is best fit: handles many treated units, provides pre-treatment fit diagnostics

### Implementation in `04_robustness.R`

```r
library(augsynth)
asyn <- augsynth(
  ln_providers ~ treated_post,
  unit = state, time = month_date,
  data = as.data.frame(hcbs_binary),
  progfunc = "Ridge", scm = TRUE
)
```

### Paper text
- One paragraph in Robustness: "As a complementary check using different identifying assumptions..."
- If qualitatively consistent with main DiD → strengthens paper
- If divergent → discuss honestly

---

## Workstream 5: Exit Timing Validation (McCrary-style)

**Goal:** Show no bunching in exit timing near February 2020 (validates that exits were gradual attrition, not anticipation).

### Implementation in `04_robustness.R`

```r
# Distribution of "last active month" for exiting providers
# Visual: histogram of exit months (should be smooth, no Feb 2020 spike)
# Formal: compare actual Feb 2020 exits to predicted from prior trend
```

### New figure: Exit timing distribution
- Histogram or density of last billing month for exiters
- Overlaid linear trend from prior months
- No spike at Feb 2020 → supports "gradual attrition" interpretation

---

## Workstream 6: Anderson-Rubin Weak-IV Confidence Set

**Goal:** Honestly characterize the shift-share IV with weak-instrument-robust inference.

### Implementation in `04_robustness.R`

```r
# Grid search over beta values
# For each beta0: test H0: beta = beta0 using reduced-form F-stat
# AR confidence set = all beta0 where p > 0.05
```

### Paper text
- If AR set is bounded and consistent with OLS → "supportive, with caveats"
- If AR set is unbounded → demote IV further, present as "directional only"

---

## Workstream 7: Prose Polish Throughout

### Beyond the intro rewrite:

1. **Recalibrate causal claims everywhere.** Replace "amplified" with "predicted" where identification is uncertain. Keep the honest interpretation: "strong predictive association with suggestive causal evidence."

2. **Reframe non-HCBS falsification.** Current framing is defensive. New framing: "theta_s indexes state-level Medicaid ecosystem health. The finding that it predicts disruption across provider types *strengthens* the external validity. Our contribution is not that HCBS is differentially affected (it is not) but that HCBS disruption has the most consequential welfare implications."

3. **Strengthen the discussion.** Connect persistence finding to hysteresis literature. Connect vulnerability interaction to the economics of network effects in thin markets. The current discussion reads like a summary — it should read like the intellectual payoff.

4. **Improve the conclusion.** End with a sentence that sticks. Currently ends with "perpetually depleted and intermittently rescued" — this is good but the preceding paragraph is generic. Make the final paragraph the intellectual crescendo.

5. **Beneficiary measurement.** Replace "beneficiaries served" with "beneficiary-provider service encounters" throughout. Add clear data section explanation.

---

## What We Decline (and Why)

| Reviewer Request | Why We Decline |
|---|---|
| Sun/Abraham or Callaway/Sant'Anna | These address staggered binary adoption. Our treatment is continuous and simultaneous (all states, March 2020). No cohorts, no negative weighting. |
| Bacon decomposition for continuous treatment | Bacon (2021) decomposes timing variation in binary TWFE. With simultaneous treatment, there are no 2x2 comparisons to decompose. |
| Sub-state granular analysis | T-MSIS has no sub-state identifier. NPPES ZIPs are practice addresses with severe small-cell suppression. Note as future research with restricted-use data. |
| Formal sequential-ignorability mediation | Sequential ignorability is implausible when COVID severity is endogenous. DAG discussion + coefficient stability is appropriate. |

Each declined request gets a respectful 2-3 sentence explanation in the reply to reviewers.

---

## File-by-File Changes

| File | Changes | Scope |
|------|---------|-------|
| `paper.tex` | Complete rewrite of abstract + intro; new HonestDiD robustness subsection; recalibrated claims throughout; strengthened discussion; improved conclusion | **Major** |
| `04_robustness.R` | HonestDiD bounds; conditional RI (5,000 perms); augsynth binarized; exit timing analysis; Anderson-Rubin CI | **Major** |
| `05_figures.R` | HonestDiD sensitivity figure; exit timing distribution figure | Medium |
| `06_tables.R` | HonestDiD breakdown row in robustness table; conditional RI row; AR CI row | Small |
| `00_packages.R` | Add `library(HonestDiD)`, `library(augsynth)` | Small |
| `references.bib` | Add Rambachan & Roth (2023), Ben-Michael et al. (2021), Blanchard & Summers (1986), Hirschman (1970) | Small |

---

## Execution Order

1. Create workspace `output/apep_0454/v3/`, copy v2 code/data
2. Install/verify packages: `HonestDiD`, `augsynth`
3. Modify `00_packages.R`, `04_robustness.R` (all new specifications)
4. Modify `05_figures.R`, `06_tables.R` (new exhibits)
5. Run ALL R scripts (00-06)
6. **Complete rewrite of abstract and introduction** (the intellectual core of the revision)
7. Revise robustness section, discussion, conclusion, limitations
8. Recalibrate causal language throughout paper
9. Update `references.bib`
10. Compile PDF, visual QA (page 1 front matter only, 25+ pages, no ??)
11. Full review pipeline: advisor → exhibit → prose → referee → revision
12. Publish with `--parent apep_0454`

---

## Verification

- [ ] HonestDiD breakdown Mbar reported for providers and beneficiaries
- [ ] Conditional RI p-values reported (expected improvement over unconditional 0.083)
- [ ] augsynth ATT qualitatively consistent with main DiD
- [ ] Exit timing figure shows no bunching at Feb 2020
- [ ] AR confidence set reported for IV
- [ ] Abstract is ≤120 words, punchy, conceptually grounded
- [ ] Introduction reads like a Shleifer paper: hook → finding → honesty → conceptual stakes → literature → forward
- [ ] No "this paper documents a troubling pattern" or similar throat-clearing
- [ ] Causal claims calibrated to evidence strength throughout
- [ ] Paper is 25+ pages, all exhibits regenerated
- [ ] All R scripts run without error
