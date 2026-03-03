# Reviewer Response Plan 1

## Summary of Feedback

All three reviewers (GPT: R&R, Grok: Major Revision, Gemini: Major Revision) converge on three core concerns:

### Concern 1: No pre-reform data (ALL reviewers — CRITICAL)
DVF starts 2020, but reform announced 2017, started 2018. Cannot distinguish "no capitalization" from "early capitalization 2017-2019." DVF available from 2014.

**Response:** Extend DVF data to 2014-2019. This is the single highest-value improvement. With pre-reform data, we can:
- Test pre-trends (2014-2016 should be flat)
- Test for announcement effects (2017-2018 shift)
- Run proper event study with pre-period

**Implementation:** Modify 01_fetch_data.R to download 2014-2019 DVF files. Update 02_clean_data.R to process all years. Update 03_main_analysis.R for full event study. Update figures.

### Concern 2: Mechanical vs behavioral TFB decomposition (ALL reviewers)
22pp TFB increase conflates mechanical (département share transfer) and behavioral (voluntary rate hikes). Tab 3 shows weak conditional relationship.

**Response:** We acknowledge this limitation more clearly and reframe. The decomposition requires detailed data on the département-to-commune transfer formula that we cannot obtain. However, we will:
- Be explicit about what we can and cannot decompose
- Reframe: for capitalization, total TFB change matters regardless of source
- Strengthen the conditional regression interpretation

### Concern 3: Stronger inference and commune controls (GPT, Grok)
No balance table, no IV, weak endogeneity discussion.

**Response:** Add balance table on commune observables. Add commune-level controls (population, income proxy from tax base). Add wild bootstrap p-values.

### Concern 4: Euro-denominated effects (GPT)
Rate-point analysis doesn't translate to incidence in euros.

**Response:** Add a back-of-envelope calculation translating rate-point effects to euros for a median commune.

### Concern 5: Claim calibration (ALL)
"No capitalization whatsoever" is overclaimed given design. Should be "no incremental capitalization post-2020."

**Response:** Soften claims. With pre-reform data, we can make stronger claims; without it, recalibrate language.

## Execution Plan

### Workstream 1: Extend DVF to 2014-2019 (HIGH PRIORITY)
- Modify `01_fetch_data.R` to download DVF 2014-2019
- Update `02_clean_data.R` for additional years
- Add pre-reform event study to `03_main_analysis.R`
- Update `05_figures.R` with new event study figures
- Update paper.tex: add pre-trend results, update claims

### Workstream 2: Strengthen inference
- Add balance table (commune-level observables vs TH rate)
- Add wild bootstrap p-values for main specs
- Add back-of-envelope euro calculation
- Add formal power analysis

### Workstream 3: Reframe fiscal substitution
- Clarify mechanical vs behavioral in text
- Soften "strongly correlated" language where conditional evidence is weak
- Add discussion of what decomposition would require

### Workstream 4: Prose and exhibit improvements
- Apply remaining prose suggestions from prose review
- Apply exhibit improvements from exhibit review

### Workstream 5: Claim calibration
- Soften absolute null claims
- Distinguish cross-sectional null from dynamic null
- Recalibrate conclusion
