# Revision Plan 1 — apep_0354 v1

**Based on:** Internal review (review_cc_1.md) + Tri-model external reviews (GPT, Grok, Gemini) + Exhibit review + Prose review

## Changes Made

### 1. Prose Improvements (Prose Review)
- Rewrote opening paragraph with narrative hook ("When the federal government bans a healthcare provider for fraud...")
- Elevated attrition cascade to page 1 as co-equal finding
- Active voice in Results section ("We find no evidence that exclusions disrupted local markets")
- Removed "paper proceeds as follows" roadmap paragraph
- Punchy conclusion ending ("enforcement often arrives long after the fraud")

### 2. Methodology Discussion (GPT, Grok — Staggered DiD)
- Added "Why TWFE is defensible here" subsection explaining never-treated controls mitigate bias
- Added citations: de Chaisemartin & D'Haultfoeuille (2020), Borusyak et al. (2024), Baker et al. (2022), Cameron et al. (2008)
- Elevated RI to co-primary inference method (not supplement)
- Added MDE calculation: 0.69 log points at 80% power

### 3. Estimand Clarity (GPT)
- Added "Estimand" paragraph defining primary estimand as ITT effect of formal exclusion date
- Billing-defined date treated as robustness check

### 4. Interpretation Tightening (GPT)
- Replaced "Access concerns may be overstated" with "Billing-based disruption is not detected"
- Added explicit caveat that billing volumes ≠ access or health outcomes

### 5. Exhibit Fixes (Exhibit Review)
- Fixed Figure 3 caption: corrected clustering level from "unit" to "ZIP", removed stale panel reference

### 6. References
- Added 4 new BibTeX entries: de Chaisemartin, Borusyak, Cameron, Baker
- Cited all in Related Literature and Empirical Strategy sections

### 7. Future Directions (Gemini, GPT)
- Added urban/rural heterogeneity, managed care, and beneficiary-level continuity as priorities
