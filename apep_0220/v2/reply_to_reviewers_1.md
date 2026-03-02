# Reply to Reviewers: apep_0220 → v2

## Response to GPT-5-mini (Decision: MAJOR REVISION)

### R1.1: Abstract overflow and page 1 fit
**Concern:** Abstract too long (224 words), overflows page 1.
**Response:** Reduced abstract from 224 to 117 words. Page 1 now comfortably contains title, authors, abstract, JEL codes, and keywords with ample white space.

### R1.2: COPE4/FORGIVE3 scale direction unclear
**Concern:** Readers may be confused about the direction of the ordinal scales.
**Response:** Added explicit coding note in Section 4.1.2: "coded 1 = a great deal to 4 = not applicable" for both COPE4 and FORGIVE3. Updated Table 4 notes with complete scale direction information.

### R1.3: Missing references
**Concern:** Several foundational references absent (Angrist & Pischke 2009, Oster 2019).
**Response:** Added Angrist & Pischke (2009) citation in the correlational estimates caveat, and Oster (2019) for sensitivity analysis context. Also added Campante & Yanagizawa-Drott (2015) in the economics of religion literature review.

## Response to Grok-4.1-Fast (Decision: MINOR REVISION)

### R2.1: Repetitive "asymmetry" phrasing
**Concern:** The word "asymmetry" appears on pp. 4, 15, 32, becoming repetitive.
**Response:** Varied the phrasing: "gap" (abstract, Section 5), "lopsided" (Section 4.1.1), retained "asymmetry" only in the opening paragraph where it is most natural.

### R2.2: Verbose introduction
**Concern:** Three-contribution enumeration is overly wordy.
**Response:** Compressed the contribution block from ~150 words to ~80 words while preserving all three contributions.

## Response to Gemini-3-Flash (Decision: MAJOR REVISION)

### R3.1: Table 4 notes truncated
**Concern:** Note text appears cut off ("positive coeff. = les...").
**Response:** Rebuilt Table 4 using stargazer with complete, untruncated notes. All five dependent variable codings are now fully spelled out.

### R3.2: Add 95% confidence intervals to Table 4
**Concern:** Regression table lacks CIs, making it harder to assess precision.
**Response:** Added 95% confidence intervals based on heteroskedasticity-robust standard errors to every coefficient in Table 4.

### R3.3: Coefficient plot for Table 4
**Concern:** A visual summary of regression results would aid interpretation.
**Response:** Added new Figure (coefficient plot) showing point estimates with 95% CI bars for all five dependent variables, color-coded by outcome.

### R3.4: Summary Statistics discussion brief
**Concern:** Section 3.6 has no narrative text, just a table input.
**Response:** Added a descriptive paragraph before the table explaining Panel A (GSS individual-level data, sample size variation across modules) and Panel B (cross-cultural database coverage).

### R3.5: Missing references (Nunn 2012, Campante & Yanagizawa-Drott 2015)
**Concern:** Important references in the economics of religion and cultural evolution literatures are absent.
**Response:** Added Nunn & Puga (2012), Campante & Yanagizawa-Drott (2015), Oster (2019), and Angrist & Pischke (2009).

## Summary of All Changes
| Item | Status |
|------|--------|
| Abstract ≤150 words | Done (117 words) |
| Title shortened | Done (11 words) |
| Prose tightened | Done |
| Table 4 notes fixed | Done |
| 95% CIs added | Done |
| Coefficient plot added | Done |
| Summary stats expanded | Done |
| Scale direction clarified | Done |
| References added (4) | Done |
| Revision footnote | Done |
