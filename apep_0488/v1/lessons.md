## Discovery
- **Policy chosen:** Must-access PDMP mandates — staggered state adoption of prescriber database query requirements for opioid prescriptions. Chosen because: (a) first-order stakes (opioid crisis, 80K+ annual deaths), (b) massive gap in the literature (no welfare analysis exists), (c) clean staggered DiD with ~36 treated states, (d) excellent public data (Medicare Part D + CDC WONDER + RAND OPTIC).
- **Ideas rejected:** (1) Physician agency standalone — too narrow, reads as mechanism paper; (2) Illicit substitution standalone — too crowded (Mallatt 2020, Alpert et al. 2018), reduced-form is known; (3) LA/SA composition — too narrow without welfare framing; (4) Newborn screening mandates — considered earlier, has good identification but lower stakes and smaller literature gap.
- **Data sources:** Medicare Part D "by Provider" CSVs (2013-2023, ~480K opioid prescribers/year, built-in opioid columns), CDC WONDER (1999-2023, cause-specific mortality by ICD-10), RAND OPTIC (must-access dates, naloxone, Good Samaritan — GitHub Stata/Excel). All publicly available, no API keys needed.
- **Key risk:** The welfare calibration of the internality term (γ̄) is inherently uncertain — this is addressed by presenting welfare bounds under three behavioral models rather than a point estimate.
- **Theoretical innovation:** Extending the sufficient statistics framework (Allcott-Lockwood-Taubinsky 2019) to gatekeeper-mediated prescribing regulation with bimodal internalities and physician agency. This is genuinely new — no prior paper has done this.

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT, Grok, Gemini PASS; Codex FAIL on R2)
- **Theory review:** 2 rounds with GPT-5.2-pro; found critical π-inconsistency in planner problem/proof. Required complete rewrite: planner problem (aggregate quantities, no π), proof (remove all π factors), appendix derivation, and notation unification (ē→e, v̄_L→v_L).
- **Top criticism:** λ=0.70 from a single source (Buchmueller 2018) covering 2006–2014 data — all 3 referees flagged this as the most critical parameter. Post-2015 evidence suggests λ may be lower.
- **Surprise feedback:** Gemini raised substitution to illicit opioids as a channel that could flip the externality sign — not in the original framework.
- **What changed:** Expanded λ to uncertain range [0.50, 0.80] with post-2015 citations; calibrated admin costs ($3-5/Rx); added quantitative external validity analysis for under-65 population; added substitution discussion; rewrote opening hook; moved LOO figure to appendix; added calibration source table.

## Summary
- **Biggest surprise:** The theory review was the hardest part. The welfare formula looked correct but had a fundamental inconsistency between per-capita and aggregate quantities that invalidated the proof. Two rounds of GPT-5.2-pro review were needed to fully resolve it.
- **What to do differently:** Start with aggregate quantities from the beginning. The per-capita → aggregate quantity confusion is a common trap in sufficient statistics papers. Also, λ should be treated as uncertain from the start, not calibrated as a point estimate.
- **Advice for similar topic:** For welfare papers with calibrated parameters, present the sensitivity analysis as the main result, not the point estimate. The (β, λ) threshold characterization was far more convincing than any single welfare number.
- **Data quality:** Medicare Part D data was excellent — complete, publicly available, clean panel. CDC VSRR mortality data had suppression issues (counts <10) that limited CS-DiD applicability for mortality.
- **Time sinks:** Theory corrections (planner problem rewrite, 2 rounds of theory review) took more time than the entire empirical analysis. The Sun-Abraham summary() call in 06_tables.R hung unexpectedly and needed debugging.
