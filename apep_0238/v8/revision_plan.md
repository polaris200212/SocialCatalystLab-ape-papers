# Revision Plan: apep_0238 v8 — Demand Recessions Scar, Supply Recessions Don't

## Context

**Parent paper:** apep_0238 v7 (tournament rating: μ=23.6, conservative=19.4, 38 matches)
**Why revise:** The theory and structural estimation are the paper's weakest link. The DMP model is externally calibrated with ad-hoc scarring dynamics (magic numbers), no moment matching to the LP IRFs, risk-neutral welfare, and a reduced-form proxy instead of proper duration distribution tracking. Multiple reviewers flagged this. For macro economists, a structural model that isn't estimated is a toy model. We will make it AER-quality structural macro.

**Scan status:** SUSPICIOUS — METHODOLOGY_MISMATCH in COVID half-life computation and scarring proxy. Must fix.

**User directive:** Theory must be watertight. Use GPT-5.2-pro theory review in iterative loops until perfect. Go beyond mandatory review steps. Make it impressive for macro people.

---

## Workspace

- **Source:** `papers/apep_0238/v7/` (read-only)
- **Target:** `output/apep_0238/v8/`
- **Version:** v8 (latest published is v7)

---

## Revision Workstreams

### Workstream 1: Replace Ad-Hoc Scarring Proxy with Duration Distribution Tracking

**Problem:** Lines 157-166 of `05_model.py` use `scarred_frac = 0.95 * scarred_frac + 0.1 * max(0, 1-f/0.4)` — three magic numbers (0.95, 0.1, 0.4) not in the calibration table, not microfounded, not consistent with the Bellman equations that define d* = 12 months.

**Fix:** Track the full discrete unemployment duration distribution as a vector `u_d[0], u_d[1], ..., u_d[D_max]`. Each period:
- New separations enter at d=0
- Surviving unemployed at d advance to d+1
- Workers with d >= d* get h reduced by λ
- Scarred fraction s_t = sum(u_d for d >= d*) / sum(u_d)
- This is exactly what the Bellman equations describe — now the code matches the theory

**Files:** `code/05_model.py`, `paper.tex` (Section 3.7 Simulation Approach, Appendix A.6)

### Workstream 2: SMM Estimation Targeting LP IRF Moments

**Problem:** All 14 parameters externally calibrated. No model-data discipline. GPT-5.2 referee: "Model is calibrated but not disciplined by reduced-form LP moments." This is the single biggest credibility gap for macro economists.

**Fix:** Implement Simulated Method of Moments (SMM):
- **Externally calibrated (fixed):** β=0.996, α=0.5, γ=0.5, δ=0.034, b=0.71, b_olf=0.65, ψ=0.03, d*=12
- **Estimated via SMM (4 parameters):** λ (scarring), χ₁ (duration-dependent OLF exit), A (matching efficiency), κ (vacancy cost)
- **Target moments (6 moments, overidentified):**
  1. GR employment response at h=12 (from LP Table 2)
  2. GR employment response at h=48 (from LP Table 2)
  3. GR employment response at h=84 (from LP Table 2)
  4. COVID recovery month (month when |emp_change| < 0.005)
  5. Steady-state unemployment rate (5.5%, BLS 2001-2019)
  6. Steady-state job-finding rate (0.40, Shimer 2005)
- **Optimizer:** scipy.optimize.minimize (Nelder-Mead), identity weighting matrix, then optimal weighting
- **Standard errors:** Parametric bootstrap (200 draws)
- **Overidentification:** J-test (6 moments - 4 parameters = 2 degrees of freedom)
- **Report:** Point estimates, SEs, J-stat, p-value in new Table (main text)

**Files:** `code/05_model.py` (new `smm_estimate()` function), `paper.tex` (new subsection 7.2 "Structural Estimation")

### Workstream 3: CRRA Welfare with Risk Aversion

**Problem:** Risk-neutral utility (linear in consumption). Macro people expect CRRA. The 330:1 welfare ratio is meaningless without curvature.

**Fix:** Add CRRA utility u(c) = c^(1-σ)/(1-σ) for σ ∈ {1, 2, 5}:
- σ=1: log utility (baseline)
- σ=2: moderate risk aversion (standard macro)
- σ=5: high risk aversion
- Report welfare table with all three + risk-neutral as reference
- Consumption = wage for employed, b for unemployed, b_olf for OLF

**Files:** `code/05_model.py` (new `compute_welfare_crra()`), `paper.tex` (Table 7 expansion)

### Workstream 4: Update Paper Theory Sections

**Problem:** The paper's Conceptual Framework (Section 3) and Model Estimation (Section 7) need to reflect the new estimation approach and duration distribution.

**Changes to paper.tex:**
- **Section 3.7 (Simulation Approach):** Remove the apology for the "tractable approximation" — the model now tracks the full duration distribution
- **Section 7.1 (Calibration):** Split into "Externally Calibrated" and "Internally Estimated" parameters
- **Section 7.2 (NEW: Structural Estimation):** SMM procedure, target moments, estimates table with SEs, J-test, model fit figure (overlay model IRF on LP IRF with confidence bands)
- **Section 7.3 (Welfare):** CRRA table replaces risk-neutral-only results
- **Appendix A.6:** Full algorithm with duration distribution, SMM objective function, bootstrap procedure
- **Abstract:** Update welfare numbers if they change materially

### Workstream 5: Fix Code-Paper Discrepancies (Scan Report)

**Problem:** Scan report flagged METHODOLOGY_MISMATCH (HIGH):
1. Bartik sector coverage: paper claims 10 supersectors, code fetches 7-8
2. Scarring proxy magic numbers not in calibration table (resolved by Workstream 1)
3. COVID half-life sign convention inconsistency in `03_main_analysis.py`

**Fixes:**
- Verify Bartik construction covers all 10 BLS supersectors
- Fix half-life computation sign convention
- Document any remaining discrepancies

**Files:** `code/01_fetch_data.py`, `code/02_clean_data.py`, `code/03_main_analysis.py`

### Workstream 6: Iterative GPT-5.2-pro Theory Review Loop

**This is the core quality assurance mechanism.** After each round of theory improvements:

```
Loop (target: 0 CRITICAL issues, minimum 3 iterations):
  1. Compile PDF (pdflatex × 3 + bibtex)
  2. Run theory_review.py → GPT-5.2-pro evaluates mathematical rigor
  3. Read feedback, categorize CRITICAL/WARNING/NOTE
  4. Fix all CRITICAL issues, address WARNINGs where possible
  5. If CRITICAL > 0: go to 1
  6. If CRITICAL == 0 for 2 consecutive iterations: exit loop
```

**Schedule:**
- Round 1: After Workstreams 1-4 (duration distribution + SMM + CRRA + tex updates)
- Round 2: After fixing Round 1 CRITICALs
- Round 3: After fixing Round 2 issues (confirmation round)
- Rounds 4+: Only if CRITICALs persist

**Files:** `output/apep_0238/v8/theory_review_1.md`, `theory_review_2.md`, etc.

### Workstream 7: Standard Review Pipeline

After the theory is locked down:
1. **Stage A:** Advisor review (quad-model, 3/4 must PASS)
2. **Stage A.3:** Theory review (one final GPT-5.2-pro pass — should be clean by now)
3. **Stage A.5:** Exhibit review (Gemini vision)
4. **Stage A.6:** Prose review (Gemini)
5. **Stage B:** External referee review (tri-model)
6. **Stage C:** Revision cycle (address all feedback)

### Workstream 8: Publish

```bash
python3 scripts/revise_and_publish.py output/apep_0238/ --parent apep_0238 --push
```

---

## Execution Order

```
[1] Create workspace, copy artifacts
[2] Workstream 1: Duration distribution (code)
[3] Workstream 2: SMM estimation (code)
[4] Workstream 3: CRRA welfare (code)
[5] Run all R/Python scripts to verify code works
[6] Workstream 4: Update paper.tex theory sections
[7] Workstream 5: Fix scan report discrepancies
[8] Compile PDF
[9] Workstream 6: Theory review loop (3+ iterations)
[10] Workstream 7: Standard review pipeline
[11] Workstream 8: Publish
```

---

## Key Files to Modify

| File | Changes |
|------|---------|
| `code/05_model.py` | Duration distribution, SMM, CRRA welfare |
| `code/03_main_analysis.py` | Half-life sign fix |
| `code/01_fetch_data.py` | Verify sector coverage |
| `code/06_figures.py` | Model-data overlay figure |
| `code/08_tables.py` | SMM estimates table, CRRA welfare table |
| `paper.tex` | Sections 3.7, 7.1-7.3, Appendix A.6, abstract |
| `references.bib` | Add SMM references (Gourieroux et al. 1993, etc.) |

## Verification

1. All Python scripts run without errors
2. Model reproduces qualitative demand/supply asymmetry
3. SMM converges with reasonable parameter estimates
4. J-test does not reject at 5%
5. Theory review returns 0 CRITICAL issues for 2 consecutive rounds
6. Advisor review passes 3/4
7. PDF compiles cleanly, 25+ pages
8. All tables/figures regenerated from code (no stale exhibits)
