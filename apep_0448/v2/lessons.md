## Inherited from parent
- #1 ranked APEP paper (22.6 conservative, 10W-0L)
- Novel T-MSIS data + behavioral health placebo = strong identification
- ARPA confounding acknowledged but not empirically tested

## Discovery
- **Revision trigger:** Code integrity scan flagged SUSPICIOUS — RI ran on TWFE but paper reported CS-DiD RI results that were hand-edited into LaTeX tables
- **Three specific discrepancies:** (1) 04_robustness.R RI uses TWFE only, (2) Table 3 CIs and stars hand-edited, (3) Table 4 phantom CS-DiD RI row
- **Key risk:** Fixing the code might produce different numbers than the hand-edited ones

## Execution
- CS-DiD RI required careful handling of the `g_period` column type (integer → double) because `att_gt()` converts 0 to Inf internally for never-treated states
- The actual CS-DiD RI p-value (0.040) is stronger than the hand-reported 0.060, strengthening the paper
- ATT coefficients shifted slightly due to bootstrap randomness (e.g., providers ATT 0.0610→0.0609, benes 0.1410→0.1385)
- All text references had to be updated to match — found 15.1% still in conclusion during advisor review

## Review
- **Advisor verdict:** 4 of 4 PASS (after 2 rounds fixing text-table consistency)
- **Top criticism:** ARPA §9817 confounding — all three referees flagged it as the primary concern
- **Surprise feedback:** GPT raised valid point about "never-treated" framing when FPUC expired nationally
- **What changed:** Added estimand clarity paragraph, strengthened ARPA and NPI discussions in Limitations, fixed Panel C blank cells, fixed 15.1%→14.9% inconsistency, removed throat-clearing

## Summary
- Code integrity revision that also surfaced and fixed pre-existing text-table inconsistencies
- The structural verification gate (revision_checklist.md) prevented drift into advisor loop
- Key lesson: hand-editing LaTeX tables creates integrity risk — always generate from code
