# Reviewer Response Plan

## Grouped Concerns

### A. Identification (All 3 Reviewers)
- Pre-trend violations invalidate aggregate causal claims → **Reframe paper around descriptive heterogeneity**
- BRGF confounding unaddressed → **Add explicit BRGF discussion, reframe estimand as "backward-district bundle"**
- Phase assignment reconstructed → **Add sensitivity discussion; note attenuation**
- Within-tercile pre-trends not tested → **Run within-tercile event studies**

### B. Inference (GPT, Grok)
- Clustering inconsistent across specs → **Standardize to district-level for all specs**
- Multiple testing in heterogeneity → **Add joint test for heterogeneity**
- Dose-response mechanical → **Move to appendix with stronger caveats (already there)**

### C. Claims Calibration (All 3)
- Abstract overclaims causality → **Add pre-trend qualifier to abstract**
- "Where workfare works" framing too causal → **Soften to "where nightlights respond"**
- GDP calibration speculative → **Bound with uncertainty**

### D. Literature (GPT, Grok)
- Missing Berg 2019, Klonner & Oldiges 2020 → **Add citations**
- Missing electrification confound discussion → **Add RGGVY paragraph**

### E. Exhibits (Exhibit Review)
- Figure aesthetics → **Already improved (cleaner themes)**
- Rambachan-Roth to main text → **Move from appendix**

### F. Prose (Prose Review)
- Kill roadmap sentence → **Done**
- Strengthen final sentence → **Done**
- Active voice in data section → **Done**

## Execution Order
1. New analysis: within-tercile event studies + joint het test + uniform clustering
2. Paper.tex revisions: abstract, intro, results, conclusion language
3. Add missing citations and BRGF/electrification discussion
4. Move Rambachan-Roth to main text
5. Elevate CS-DiD het
6. Recompile and verify
