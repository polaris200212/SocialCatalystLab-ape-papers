# Reviewer Response Plan — apep_0432 v1

## Review Summary

| Reviewer | Decision | Key Issues |
|----------|----------|------------|
| GPT-5.2 | MAJOR REVISION | First-stage, multiple testing, mechanism overclaiming |
| Grok-4.1-Fast | MINOR REVISION | Missing refs, CIs, male outcomes |
| Gemini-3-Flash | MINOR REVISION | 250 non-replication, teacher supply, male literacy |
| Theory (GPT-5.2-pro) | 2 CRITICAL | Framework comparative static wrong; no boys' choice |
| Exhibit (Gemini) | REVISE | Promote validity to main text; create ST literacy fig |
| Prose (Gemini) | Polish | Tighten data section; active voice; kill roadmap |

## Revision Priorities

### Priority 1: Fix Conceptual Framework (Theory CRITICAL #1, #2)

**Problem:** The model claims ∂h_f/∂(w_m−w_f) < 0 but under standard assumptions ∂h_f/∂w_m > 0 (education is normal good). Model has no boys' choice h_m and no return technology linking education to wages.

**Fix:** Extend the model to include:
- Two-child allocation: h_m and h_f with budget p_h(h_m + h_f)
- Returns technology: payoffs w_m(h_m, R) and w_f(h_f, R) where roads R shift relative returns
- Derive the reallocation comparative static: when ∂w_m/∂R > ∂w_f/∂R, households shift investment toward sons
- State decision rule for L_f ∈ {0,1} with indirect utility comparison
- Add standard curvature assumptions (u'' < 0, g'' < 0)

### Priority 2: Add Male Literacy Outcome (All 3 referees)

**Problem:** All reviewers want male literacy as outcome to test the "reallocation toward sons" channel.

**Fix:** Run rdrobust on male literacy change (already in data). If positive or less negative than female → supports reallocation story. Add to Table 3 (heterogeneous) and discuss.

### Priority 3: Multiple Testing Correction (GPT)

**Problem:** 9 outcomes × 3 subsamples → risk of false positives.

**Fix:** Implement Benjamini-Hochberg q-values within outcome families (employment family, human capital family). Report adjusted p-values alongside raw.

### Priority 4: Fix RDD Equations (Theory WARNING #5, #6)

**Problem:** Continuity assumption only for Y(0); RDD equation uses common f() not piecewise.

**Fix:**
- State continuity for both E[Y(0)|X=x] and E[Y(1)|X=x]
- Rewrite RDD equation with piecewise f_-(·) and f_+(·)

### Priority 5: Fix McCrary Misuse (Theory WARNING #7)

**Problem:** Discussion claims McCrary test "implies" no population growth discontinuity.

**Fix:** Delete this implication. State correctly that McCrary tests baseline density manipulation only. If needed, note that population growth could be tested as a separate outcome.

### Priority 6: Add Missing References (All reviewers)

Add: Imbens & Lemieux (2008), Lee & Lemieux (2010), Gelman & Imbens (2019), Calonico et al. (2015), Hahn et al. (2001), Romano & Wolf (2005), Kling et al. (2007), Shah & Steinberg (2017).

### Priority 7: Add 95% CIs to Tables (GPT, Grok)

**Fix:** Extract CIs from rdrobust output and add CI columns to Tables 2 and 3.

### Priority 8: Reorganize Exhibits (Exhibit review)

- Promote McCrary (Fig 5) and Balance (Fig 6) to main text as combined identification figure
- Create new ST literacy RDD plot for main text
- Move bandwidth sensitivity (Fig 3) and placebo (Fig 4) to appendix
- Move Table 5 (250 threshold) to appendix
- Clean up Table 4 (group interaction terms at top)

### Priority 9: Prose Improvements (Prose review)

- Rewrite Data section as narrative (not inventory)
- Active voice throughout
- Delete roadmap paragraph at end of intro
- Tighten Section 2.1 (cut road specifications)
- Strengthen "Missed Opportunity" translation of magnitudes

### Priority 10: Temper Mechanism Claims (GPT)

**Problem:** Null nightlights and null EC outcomes undermine "roads raised returns" story.

**Fix:** Reframe as "eligibility-induced changes at the margin" — the reduced-form ITT captures the net effect of being eligible for priority road construction, which may include modest economic shifts insufficient to detect in aggregate nightlights but sufficient to trigger household behavioral responses in marginalized communities.

## Execution Order

1. R analysis: male literacy + multiple testing + CI extraction + new figures
2. LaTeX: framework rewrite + equations + exhibits + prose + references
3. Recompile
4. Write reply_to_reviewers_1.md
