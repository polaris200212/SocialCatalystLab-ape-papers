# Revision Plan 1 — Stage C Response to Referee Reviews

**Paper:** apep_0481 v1 — Going Up Alone? Gender, Electoral Pathway, and Party Discipline in the German Bundestag
**Date:** 2026-03-02
**Reviews addressed:** GPT-5.2 (Major Revision), Grok-4.1-Fast (Minor Revision), Gemini-3-Flash (Minor Revision)

---

## Priority Changes Implemented

### 1. Reframe DDD as Descriptive (All 3 referees)
- Relabeled DDD regression as "descriptive decomposition" throughout paper
- Removed causal language ("suppresses," "overrides") from Table 2 discussion
- Added explicit statement: "This is a descriptive decomposition — not a causal estimate"
- Reserved causal claims exclusively for the RDD

### 2. RI on Preferred Specification (All 3 referees — unanimous concern)
- Added R6b block in `04_robustness.R`: RI with 999 permutations on Column 4 (with electoral safety control)
- Result: preferred-spec RI p-value = 0.028 (rejects sharp null)
- Updated Table 3 to report both RI p-values (uncontrolled: 0.014, preferred: 0.028)
- Added honest discussion of RI vs asymptotic discrepancy (due to skewed binary outcome with 1.6% mean)

### 3. District Sign Flip Reconciliation (Referee 1)
- Added reconciliation paragraph explaining OLS (+0.27pp) vs RDD (-0.93pp)
- Explained as classic selection-vs-treatment pattern: parties select more rebellious candidates into districts, but causal effect of district mandate is to discipline behavior

### 4. RDD Selection Caveat (Referee 1)
- Added discussion of list-insurance: district losers only observed as MPs if list position delivers seat
- Noted as limitation with partial mitigant (German parties place competitive district candidates in safe list positions)

### 5. Literature Addition (Referees 1, 2)
- Added Hix, Noury & Roland (2005) on European Parliament voting as comparative benchmark
- Cited in introduction's literature review

### 6. Prose and Exhibit Improvements (from Stage A.5/A.6)
- Added Table 2 note about coefficient scaling relative to 1.6% baseline
- Removed formulaic roadmap sentence from introduction
- Improved literature framing transitions
- Enhanced Figure 5 caption with gender-specific estimate note

---

## Changes Deferred to Future Revision

The following referee suggestions are noted but deferred as they require substantial new data collection or analysis beyond the scope of this initial revision cycle:

- McCrary density test and formal balance table for RD (Referees 1, 2)
- List-safe restriction sensitivity analysis (Referee 1)
- Green Party policy domain decomposition (Referees 1, 3)
- Party-specific MDEs (Referee 2)
- LPM robustness with logit / fractional outcome (Referee 1)
- Gender-split RDD figure (Referee 3)
- Free-vote full specification table (Referee 2)
- Party line definition robustness with alternative abstain coding (Referee 1)

These are documented in `reply_to_reviewers_1.md` with commitments for how they would be addressed.

---

## Verification

- Paper recompiled: 37 pages, no LaTeX warnings
- All R scripts re-run successfully
- Tables regenerated with updated RI results
- Lessons.md updated with review and summary sections
