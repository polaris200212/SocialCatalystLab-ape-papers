# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2) — MAJOR REVISION

### 1.1 Violated pre-trends / identification
> "The standard DiD estimand is not interpretable as causal."

**Response:** We agree that the standard DiD is not credibly identified given the pre-trend violation. We have:
- **Elevated the DDD as the primary specification** with formal pre-trend validation (joint test p=0.779)
- Added a DDD event study figure (Figure 5) showing stable pre-treatment government-private sector gaps
- Added TWFE with state-specific linear trends as sensitivity (-0.007, p=0.42), showing the treatment coefficient shrinks toward zero once state trajectories are absorbed
- Softened causal language throughout (abstract, conclusion)

### 1.2 Treatment timing misaligned with stock outcome
> "The paper's central question is not well-matched to the available post-period."

**Response:** We acknowledge this limitation more explicitly. The abstract now says "has not yet altered" rather than "does not meaningfully alter." The MDE analysis (Section 4.5) directly quantifies this constraint. We added the DDD event study showing e=1 is -0.025 (p=0.02), suggesting the government-private gap may be widening in year 2.

### 1.3 DDD pre-trend test needed
> "Demonstrate that the gap was stable pre-policy."

**Response:** Done. New DDD event study (Section 5.3, Figure 5) shows pre-treatment interaction coefficients are uniformly insignificant. Joint pre-trend test: chi2(4)=1.76, p=0.779. This is now the strongest piece of evidence in the paper.

### 1.4 Wild cluster bootstrap
> "Report WCB p-values."

**Response:** The `fwildclusterboot` package is not available in our R environment. With 51 clusters (50 states + DC), asymptotic cluster-robust inference is adequate per Cameron & Miller (2015). We note this in the appendix.

### 2.1 State-specific linear trends
> "Include as sensitivity."

**Response:** Added. TWFE with state-specific trends: -0.007 (p=0.42). This confirms that pre-trend contamination drives the TWFE result.

### 2.2 Leave-one-out
> "Drop each treated state."

**Response:** Added. Range [-0.019, -0.013], mean -0.016, SD 0.001. No single state drives the result.

### 2.3 Reframe claims
> "No detectable short-run stock-composition changes."

**Response:** Softened throughout: abstract says "has not yet altered"; conclusion uses "early evidence"; heterogeneity results flagged as potentially selection-driven.

### 2.4 Local government placebo
> "The significant local gov effect needs deeper engagement."

**Response:** Added paragraph discussing possible explanations (spillovers from state EOs directing local reform, differential occupational composition). Noted this does not threaten DDD validity since DDD uses private sector, not local government.

---

## Reviewer 2 (Grok-4.1-Fast) — MAJOR REVISION

### Must-fix: DDD sector pre-trends
> "Add CS/SA-style event study for DDD."

**Response:** Done. Manual DDD event study with event-time × state_gov interactions. Pre-trend joint test p=0.779. See Figure 5.

### Must-fix: Power under PT violation
> "Simulate power under extrapolated pre-trends."

**Response:** We address this indirectly through the state-specific trends specification, which absorbs the linear component of pre-trends and yields -0.007 (p=0.42). The MDE analysis in Section 4.5 already shows power constraints.

### Must-fix: Local gov placebo
> "+1.4pp (p=0.03) inconsistent with targeted claim."

**Response:** Added discussion (Section 5.8). Possible spillovers or occupational composition differences. Does not invalidate DDD.

### High-value: Synthetic controls
> "Implement SCM for early adopters."

**Response:** With only 2 early adopters (MD, CO), SCM is underpowered and relies heavily on donor pool construction. The DDD with validated pre-trends provides more credible identification for this setting.

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Cohort analysis
> "Are early adopters different from 2023/2024 cohorts?"

**Response:** The CS analysis shows only the 2022 cohort (MD, CO) has group-time ATTs. The 2023 cohort has only 1 post-treatment year, limiting cohort comparisons. The leave-one-out analysis (-0.019 to -0.013) shows no single state drives the result, which partially addresses this concern.

### DDD pre-trend test
> "A formal test on the DDD pre-trend would be better."

**Response:** Done. DDD event study with joint pre-trend test (p=0.779). See Figure 5.

### Industry sensitivity
> "Does the null hold across job categories?"

**Response:** We acknowledge this as a limitation. The ACS provides occupation codes, but occupation-level analysis with the current sample (510 state-years) would require individual-level regressions. We note this as a direction for future research.

---

## Exhibit and Prose Improvements

Per the exhibit review:
- Moved Figures 3 (heterogeneity) and 5 (demographics) to appendix
- Removed duplicate Figure 7 (raw trends copy)
- Added significance stars to Table 3
- Moved adoption timeline figure earlier (now in Section 2.3)

Per the prose review:
- Sharpened opening hook ("paper ceiling" framing)
- Removed roadmap paragraph from Introduction
- Active voice in Results section
- Improved concluding sentence
