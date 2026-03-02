# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T02:38:34.829792
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 42657 in / 5019 out
**Response SHA256:** dfc338050c0617a8

---

## Summary and overall evaluation

The paper asks a clear, important question: do “demand recessions” scar labor markets while “supply recessions” do not? It documents a sharp contrast between the Great Recession (GR) and COVID using cross-state reduced-form local projections (LPs): housing-boom-exposed states exhibit persistent relative employment shortfalls, while COVID-exposed states return to parity within ~18 months. It then rationalizes the asymmetry using a DMP model with endogenous participation and duration-dependent skill depreciation, estimated by SMM to match selected LP moments, and produces large welfare-ratio calculations.

The empirical patterns are interesting and potentially publishable, but the current version is **not yet publication-ready for a top general-interest journal** because (i) the causal interpretation is not sufficiently nailed down for the GR design (housing boom exposure is plausibly, but not convincingly, exogenous to long-run state employment trends), (ii) long-horizon “scarring” inference is weak and currently relies on selectively constructed summaries, and (iii) the structural section—especially the “demand shock = permanent productivity loss” mapping and the rejected SMM moments—does not credibly support quantitative welfare claims like “71:1”.

Below I focus on scientific substance and readiness.

---

## 1. Identification and empirical design (critical)

### 1.1 What is identified?
The LPs are **cross-sectional** regressions at each horizon (Eq. (1), Section 5): \(\Delta y_{s,h} = \alpha_h + \pi_h Z_s + \phi_h'X_s + \varepsilon_{s,h}\). This identifies **a differential recovery gradient**: how outcomes vary with baseline exposure across states. That can be interpreted as causal only under strong assumptions about exposure exogeneity.

The paper sometimes states results in causal language (“produced persistent relative employment deficits”; “demand recessions scar, supply recessions don’t”). But with only **two episodes** and **cross-sectional exposure**, the credible claim is narrower: *in these two episodes, cross-state exposure gradients behaved very differently*. The text partially acknowledges this (Introduction/Conclusion), but the causal claim still reads stronger than the design supports.

### 1.2 Great Recession: housing boom as “demand exposure”
Using 2003–2006 HPI boom as exposure is common (Mian–Sufi style), but for your specific estimand—employment **4–10 years** after the peak—the exogeneity burden is heavier than for short-run consumption or employment collapses.

Key threats that remain insufficiently addressed:

**(a) Omitted long-run growth determinants correlated with housing boom exposure.**  
Housing boom states are disproportionately coastal/supply-constrained, high-amenity, high-productivity-growth places (or places with different migration/land-use regimes). Even if pre-trends in *employment* (2004–2007) are flat (Appendix pre-trend table/event study), this does not rule out differential post-2007 trajectories driven by:
- structural reallocation (construction intensity and its longer decline),
- differential fiscal capacity/state policy responses,
- land-use restrictions affecting long-run employment growth,
- differential population growth/aging,
- industry trends (tech, energy) that are spatially concentrated.

You do include region dummies and pre-growth controls, but the set is thin for a top journal given the sweeping claims and long horizons.

**(b) Endogenous “treatment” package and external validity of the “demand recession” label.**  
HPI exposure captures not just demand collapse but a bundle: construction boom/bust, household leverage, banking distress, foreclosure externalities, and local fiscal contractions. You mention this in Threats to Validity, but the paper’s headline frames the difference as “demand vs supply”, while your GR measure is closer to “housing/financial crisis intensity”.

**(c) Timing and definition of the shock.**  
You define outcomes relative to the NBER peak (Dec 2007) but the “demand collapse” in housing starts earlier (mid-2006) and financial crisis peaks later (2008–2009). Cross-state exposure is measured 2003Q1–2006Q4, which is fine, but the “event date” may not be uniform across states. If some states peaked earlier/later, the LP horizon indexing could mix pre- and post- local turning points.

**Concrete improvement needed:** show robustness to alternative alignment (e.g., state-specific employment peak month within 2006–2008; or using 2008Q3 Lehman as a common shock date) and demonstrate results are not an artifact of peak normalization choices.

### 1.3 COVID: Bartik exposure as “supply shock”
The COVID Bartik measure based on 2019 industry shares × national industry employment changes Feb–Apr 2020 is a standard exposure design and plausibly exogenous at impact.

However, for post-2020 persistence you still need:

**(a) A clearer exclusion restriction narrative.**  
Industry composition may also correlate with remote-work capacity, local policy strictness, and subsequent sectoral growth (e.g., tech-heavy states). Those factors could matter for recovery. If the finding is “no persistent gradient”, bias is less concerning, but you should still show that the null is not masking offsetting forces.

**(b) Two-way policy endogeneity differs across states.**  
COVID policies (restrictions, reopening) and transfers varied. The paper says conditioning on policy is “post-treatment bias”; that’s true if policy responds to exposure. But policy might respond to *health shocks* rather than Bartik exposure. A useful design-based check is to show how the Bartik shock correlates with:
- COVID death rates,
- policy stringency measures,
- UI generosity/PPP take-up proxies,
and then argue whether these are mediators vs confounders.

---

## 2. Inference and statistical validity (critical)

### 2.1 Small-N inference is taken seriously, but there are issues
Strengths:
- You report HC1 SEs, permutation \(p\)-values, and wild cluster bootstrap \(p\)-values (Section 5.4; Table 2).
- For shift-share you report AKM exposure-robust SEs (Table 2, Panel B), which is good practice.

Critical concerns:

**(a) Wild cluster bootstrap with 9 clusters and cross-sectional regressions.**  
You cluster at census division (9 clusters) for wild bootstrap. With only 50 observations and coarse clustering, results can be unstable and sensitive to leverage. You should report:
- the number of states per cluster,
- whether results change with alternative clustering (e.g., census region = 4 clusters is too few; but maybe state-level is not clustering at all),
- and ideally use **randomization inference** as the primary approach (you already compute permutation tests).

**(b) Multiple-horizon inference and “pre-specified long-run average.”**  
A major red flag is the move from mostly insignificant long-horizon coefficients (GR at 48–84 months under permutation/wild bootstrap) to a statistically significant “pre-specified long-run average across four horizons” with a wild-bootstrap CI (Main Results, persistence paragraph).

This needs to be formalized and defended:
- Was this long-run average genuinely pre-registered/pre-specified (and where)?
- How exactly is its standard error computed accounting for strong cross-horizon correlation?
- Why those horizons (48,60,84,120) and not others?

Right now it reads like **ex post aggregation to recover significance**, which a top journal will not accept without a clean inferential framework.

**Concrete fix:** define a single primary long-run estimand ex ante (e.g., average effect over months 48–120, using the full 3-month grid) and estimate it in one regression (stacked horizons) with a covariance estimator that accounts for cross-horizon dependence (or block bootstrap over states). Alternatively, implement a Romano–Wolf stepdown or a Westfall–Young procedure adapted to your permutation design.

**(c) Comparability across GR and COVID magnitudes.**  
In Table 2, COVID exposure is standardized to SD=1, GR HPI is not standardized in the table but later you discuss “one SD = 0.15 log points implies 0.8 pp”. You also show standardized comparison in Figure 6 notes. For scientific clarity (not prose), you need a consistent scaling rule for all main tables, or a clear “per SD” presentation for both episodes in the main table.

### 2.2 Staggered DiD issues do not apply, but serial correlation does not exist (cross-section)
Because each horizon is a cross-section, you avoid classic DiD staggered timing pitfalls. But the paper still implicitly treats the sequence of \(\hat{\pi}_h\) as an “IRF” with meaning akin to a time-series response. That is fine descriptively, but inference on *features* like “half-life = 60 months” is currently ad hoc.

**Concrete fix:** compute uncertainty bands for derived statistics (half-life, recovery month, long-run average) via bootstrap/permutation.

### 2.3 IV section: Saiz instrument interpretation
You instrument HPI boom with (negated) Saiz elasticity and report first-stage F=24.9 (Table 3). But your 2SLS estimates attenuate and flip sign at long horizons, with wide AR CIs. This is not just “expected signal-to-noise deterioration”—it can also indicate that:
- the OLS “effect” at long horizons is not truly driven by the exogenous component of the boom, or
- the LATE differs (Saiz IV identifies supply-constrained states).

Also, the IV is only cross-sectional with \(N=50\). You should provide:
- first-stage coefficient and SE,
- reduced form of Saiz on employment outcomes (by horizon),
- and sensitivity to influential points.

---

## 3. Robustness and alternative explanations

### 3.1 Within-GR “horse race” is suggestive but not decisive
The horse race (Table 4) includes HPI and a GR Bartik. The GR Bartik coefficients are large positive but insignificant; HPI remains negative. This is consistent with your story, but interpretation is tricky because:
- the GR Bartik is built from **national industry shocks** during the recession, which themselves are partly driven by housing/finance demand collapse; it is not a clean “supply” proxy.
- multicollinearity and scaling issues can produce unstable coefficients (you report VIF=1.8, moderate).

**Concrete fix:** use additional alternative GR exposure measures that better isolate non-housing channels (e.g., manufacturing import exposure, oil shocks, government spending exposure) and show that the HPI gradient is not just picking up broader secular declines.

### 3.2 Migration and “emp/pop” robustness
Using employment-to-population is a good robustness check (Appendix migration table). But:
- you do not show the construction in detail (population data frequency, interpolation, etc.), and several horizons are missing (“not available”).
- emp/pop still confounds migration with demographic composition changes (aging) unless you use **prime-age** measures.

**Concrete fix:** replicate using prime-age employment/pop or prime-age LFPR at annual frequency (CPS/ACS) even if lower frequency, to address demographic shifts.

### 3.3 Placebos and falsification
You have permutation tests, but a top journal will want **meaningful placebos**, not only re-randomization:
- For GR: show HPI boom does **not** predict employment changes in earlier non-recession windows (e.g., pseudo-peak in 2003, 2001 recession).
- For COVID: show the COVID Bartik does not predict employment changes around GR or other periods.

Also consider placebo outcomes:
- sectors less affected by housing (for GR) or by contact intensity (for COVID),
- or pre-determined outcomes like 2000–2002 trends.

### 3.4 Mechanism evidence is mostly national time series, not identified cross-state mechanisms
The mechanism section leans heavily on national facts (long-term unemployment, temporary layoffs, JOLTS). Those are consistent with your story, but they are not tied to the cross-state identification.

Your “formal mechanism test” uses cross-state unemployment rate LPs (Table 6). That is helpful, but it’s still reduced-form and does not directly test **duration** or **temporary layoff share** across states.

**Concrete fix:** use state-level duration proxies where feasible (CPS micro with state identifiers at monthly/annual; or at least regional duration; or use UI claims duration metrics). Even noisy measures could validate whether more HPI-exposed states experienced longer durations and larger long-term unemployment shares, which is central to your causal narrative.

---

## 4. Contribution and literature positioning

The paper fits into hysteresis/scarring and local labor market adjustment. The basic empirical comparison (GR vs COVID) is novel as a unified state-level exposure LP, but the core claim (“demand shocks scar; supply shocks don’t”) is broad, and you currently have only two episodes.

Suggestions for literature additions/engagement (substance, not exhaustiveness):

- **Local projection / state exposure macro papers**: more engagement with regional macro identification and “local multipliers” literature, including:
  - Nakamura and Steinsson (2014) on local fiscal multipliers (for the “relative vs aggregate” issue).
  - Chodorow-Reich (2019 JEL) on fiscal policy in recessions (for policy endogeneity framing).

- **Hysteresis microfoundations / duration dependence**:
  - Schmieder, von Wachter, and Bender (2016) is cited; also consider Davis and von Wachter (2011) on earnings losses (depending on your focus).
  - Recent work on recalls and temporary layoffs in COVID beyond Fujita–Moscarini (you cite Fujita 2017; consider Hall and Kudlyak work on temporary layoffs/COVID if relevant).

- **Shift-share validity**: you cite Borusyak et al. (2022), Adao et al. (2019), Goldsmith-Pinkham et al. (2020). Good. Consider clarifying whether you are implementing the AKM correction correctly for a single national shock period (Feb–Apr 2020), where the structure is slightly different than multi-period shocks.

---

## 5. Results interpretation and claim calibration

### 5.1 The strongest empirical claim supported
The most credible claim from the reduced-form is:

- GR: HPI boom strongly predicts medium-run (6–36 month) relative employment declines; evidence on persistence beyond 4 years is **suggestive but imprecise**.
- COVID: Bartik exposure predicts short-run employment declines (3–6 months) but the gradient disappears by 18–48 months.

Your text often states more strongly that GR effects “remain significantly below zero through 84 months” (Figure 6 notes) and that COVID “recovered fully within 18 months.” The latter is plausible; the former is not supported by Table 2’s permutation and wild-bootstrap \(p\)-values at long horizons.

**Concrete fix:** keep the narrative aligned with your strongest inference. If long-run persistence is central, you must (i) pre-define a long-run estimand and (ii) show it is statistically distinguishable from zero under valid finite-sample inference.

### 5.2 Structural model: mapping and quantitative welfare claims are not credible as stated
The structural section is currently the biggest “publication readiness” risk for a top journal.

**Major issues:**

**(a) Demand shock modeled as permanent productivity loss** (Section 3.7; Section 8.3).  
A permanent fall in \(a\) is not “demand” in the standard DMP sense; it is closer to a permanent TFP/productivity shift. You justify it as “permanent reduction in aggregate productivity—the key object that demand shocks affect.” That conflates demand deficiency with productivity.

If the goal is to model demand as a wedge in vacancy posting or a decline in surplus due to lower product demand, common approaches include:
- a time-varying discount factor / demand wedge,
- a decline in output price / matching surplus,
- a financial wedge increasing \(\kappa\),
- or an aggregate demand process that is persistent but not literally permanent.

Because your welfare ratio is driven “primarily by permanence” (you acknowledge this), the 71:1 number is essentially an artifact of assuming demand shocks are permanent and supply shocks are transitory. That is not an empirically disciplined mapping in the current paper.

**(b) SMM fit is rejected sharply and key steady-state targets are missed** (Table 9).  
The model misses steady-state unemployment (0.078 vs 0.055) and COVID recovery month (10 vs 18), and the overidentifying restrictions are rejected with \(p=0.0001\). You say this is “expected and normal,” but in a paper that then reports precise welfare ratios, this is not acceptable without much more sensitivity work and alternative specifications.

**(c) Estimated scarring parameters are very imprecise** (\(\lambda\) SE > mean; \(\chi_1\) similarly).  
This undermines the mechanism quantification and welfare decomposition.

**(d) Internal quantitative inconsistency**: the model implies scarring fraction peaks at 0.7% by month 48 (Section 8.3), which seems too small to drive large long-run employment losses unless permanence does nearly all the work—which you essentially confirm. That weakens the paper’s central conceptual emphasis on duration-dependent scarring as the core asymmetry.

**Concrete fix options (pick one direction):**
1. **Make the paper primarily reduced-form** and demote the model to a qualitative illustration with minimal quantitative claims (remove the “71:1” headline, or present it as a wide range under alternative shock processes).
2. **Or** rebuild the model so “demand” corresponds to a persistent but mean-reverting demand wedge calibrated to match the *empirical* GR IRF (including partial recovery), and “supply” corresponds to transitory separation spikes plus recall. Then re-estimate and show it can jointly match key moments without extreme rejection.

Given the empirical nature of AEJ:EP / top general-interest outlets, option (1) is likely more feasible unless you want a macro-theory contribution.

---

## 6. Actionable revision requests (prioritized)

### 1) Must-fix issues before acceptance

1. **Define and defend a single primary long-run scarring estimand and provide valid inference.**  
   - *Why it matters:* Current long-horizon conclusions rely on individually insignificant coefficients and an aggregation that appears ex post. This is a core validity issue.  
   - *Fix:* Pre-specify an estimand like the average effect over months 48–120 (using the full 3-month grid). Estimate it in a single stacked regression and compute inference via state-level bootstrap/permutation that preserves cross-horizon dependence. Report this as the primary “scarring” test.

2. **Strengthen GR identification beyond pre-trends + thin controls.**  
   - *Why it matters:* Housing booms correlate with many long-run state characteristics; causal interpretation at 4–10 year horizons is fragile.  
   - *Fix:* Add richer pre-determined controls (pre-2007 industry shares, education, population growth, pre-trends in multiple outcomes), and/or use alternative designs:
     - state-specific peak alignment robustness,
     - placebo peaks / other episodes,
     - and show that Saiz-IV reduced-form patterns mirror OLS at medium horizons (with full first-stage/reduced-form reporting).

3. **Recalibrate claims to what inference supports.**  
   - *Why it matters:* Statements like “significantly below zero through 84 months” are not supported by your own permutation/wild bootstrap results.  
   - *Fix:* Rewrite interpretation (substance-level) to emphasize strong evidence through 36 months, and treat longer horizons as suggestive unless your new long-run estimand is significant.

4. **Either substantially revise or substantially de-emphasize the structural welfare ratio claims.**  
   - *Why it matters:* The 71:1 result is driven by a modeling choice (permanent “demand” as productivity) and the model is rejected on key moments. This will not survive top-journal scrutiny.  
   - *Fix:* Present welfare as a sensitivity range across alternative shock persistence processes; or drop the ratio headline and keep the model as a qualitative rationalization. If kept quantitative, revise the demand shock process and re-estimate to match the observed recovery dynamics.

### 2) High-value improvements

5. **Mechanism validation using subnational duration / temporary layoff measures.**  
   - *Why it matters:* The core mechanism is duration-driven scarring; currently mechanism evidence is mostly national time series.  
   - *Fix:* Use CPS micro (or at least census-division-level) to show that HPI-exposed states had larger increases in long-term unemployment share and/or lower job-finding, while COVID-exposed states had larger temporary layoffs but faster normalization.

6. **Clarify and test the COVID Bartik exclusion restriction.**  
   - *Why it matters:* Industry composition is correlated with remote work, policy, and amenity-driven migration.  
   - *Fix:* Show correlations with remote-work share, policy stringency, and COVID mortality, and discuss whether these are mediators/confounders. Add robustness controlling for pre-pandemic WFH feasibility.

7. **Formal uncertainty for “half-life” and “recovery month.”**  
   - *Why it matters:* These are featured summary statistics but currently point estimates without uncertainty.  
   - *Fix:* Bootstrap/permutation distribution for these derived metrics.

### 3) Optional polish (still substantive)

8. **Generalizability beyond “sample of two” recessions.**  
   - *Why it matters:* The headline is general; evidence is two episodes.  
   - *Fix:* Add at least one additional episode (e.g., 2001 recession or early-1980s at annual frequency) using analogous exposure logic, or explicitly scope the claim to these episodes more tightly.

9. **Clarify what parameter \(\pi_h\) means for welfare / policy.**  
   - *Why it matters:* \(\pi_h\) is a relative exposure gradient, not an aggregate IRF.  
   - *Fix:* Add a scaling argument translating cross-state gradients into aggregate implications (or explicitly state why you do not attempt aggregation).

---

## 7. Overall assessment

### Key strengths
- Clear motivating contrast (GR vs COVID) and a simple, transparent empirical design using the same units (states) across both episodes.
- Good attention to small-sample inference tools (permutation and wild bootstrap) and shift-share diagnostics (Rotemberg weights, AKM SEs).
- The empirical pattern—persistent GR gradient vs transient COVID gradient—is compelling descriptively and worth publishing if the causal interpretation and inference are tightened.

### Critical weaknesses
- GR identification for long-run scarring is not sufficiently credible with current controls and checks.
- Long-horizon inference is weak; the “long-run average” result needs a principled pre-specified estimand and correct inference.
- Structural welfare claims are not disciplined enough and rely heavily on an assumption (permanent “demand”) that is not empirically validated; SMM fit is rejected.

### Publishability after revision
With substantial work tightening the long-run estimand/inference and strengthening identification (or narrowing the causal claim), the reduced-form portion could become publishable in a strong field journal and possibly AEJ:EP. For a top-5 general-interest journal, the bar for causal identification and/or a clearly credible structural contribution is higher; the current structural section does not meet it.

DECISION: MAJOR REVISION