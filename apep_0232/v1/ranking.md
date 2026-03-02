# Research Idea Ranking

**Generated:** 2026-02-12T09:27:46.005007
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 5431

---

### Rankings

**#1: The Geography of Monetary Transmission — Household Liquidity and Regional Impulse Responses**
- **Score: 74/100**
- **Strengths:** Cross-regional monetary identification (common national shock × regional exposure) is a credible and policy-relevant way to study heterogeneous transmission, and interacting with liquidity/HtM is a clear mapping to HANK theory. Data are abundant (monthly panel, long time series), enabling well-powered local projections and rich heterogeneity tests.
- **Concerns:** The biggest threat is **measurement/construct validity of “HtM share” at the state level**—a poverty rate proxy is likely too noisy and conceptually off-target (HtM is about liquid wealth/credit access, not just income). Heterogeneous responses may reflect **industry mix / cyclicality / housing/leverage channels** correlated with HtM proxies rather than the HANK liquidity channel unless you aggressively benchmark against these alternative mechanisms.
- **Novelty Assessment:** **Moderately novel.** Regional monetary transmission is well-studied (Nakamura–Steinsson-style designs; regional exposure papers), and HANK mechanisms are heavily studied structurally, but **a clean cross-state test specifically of HtM/liquidity amplification** is not yet saturated—novel if you can measure HtM credibly and distinguish from competing channels.
- **Recommendation:** **PURSUE (conditional on: obtaining a defensible state-level liquidity/HtM measure beyond poverty; pre-specifying a battery of “horse race” controls—industry composition, tradable share, housing leverage, bank exposure—to isolate the liquidity channel; using inference robust to cross-sectional dependence/common shocks).**

---

**#2: Fiscal Transfers and the HANK Multiplier — Cross-State Evidence from Federal Transfer Shocks**
- **Score: 66/100**
- **Strengths:** High policy relevance (transfer design and stabilization) and the question is meaningful for HANK: transfer multipliers should vary with recipient liquidity constraints. The BEA transfer category richness is a real asset and allows decomposition (UI vs Medicaid vs retirement vs safety net).
- **Concerns:** The core risk is **shift-share (Bartik) validity**: many transfer components (especially UI and some means-tested programs) are mechanically tied to state economic conditions, and state “shares” may proxy for **structural cyclical sensitivity** (creating differential trends even absent policy). Annual frequency plus formula-driven endogeneity make “federal shock” interpretation fragile unless you isolate plausibly exogenous national changes (e.g., legislated benefit schedules/eligibility changes) and apply modern shift-share diagnostics.
- **Novelty Assessment:** **Some novelty, but not wide-open.** Fiscal multipliers and ARRA/UI-style regional designs are heavily studied; “transfer multipliers” are studied too, though **the full 44-category basket + heterogeneity by liquidity/HtM** is less common. The novelty will hinge on a credible exogenous “shift” definition.
- **Recommendation:** **CONSIDER (conditional on: constructing shifts from clearly exogenous federal policy changes or rule changes rather than raw national spending growth; implementing Borusyak–Hull / Goldsmith-Pinkham–Sorkin–Swift-style shift-share validity checks; separating mechanically endogenous components like UI unless the shift is explicitly legislated and timing-clean).**

---

**#3: The Forward Guidance Puzzle at the Regional Level**
- **Score: 55/100**
- **Strengths:** The regional test of the forward-guidance puzzle is conceptually fresh and would be high-impact if executed cleanly; it offers a mechanism-based way to adjudicate why “path” guidance underperforms in practice, and heterogeneity by liquidity constraints is theoretically sharp.
- **Concerns:** Data/measurement and power are the binding constraints: the “path” factor is **notoriously noisy**, forward guidance regimes change over time, and mapping high-frequency announcement surprises into monthly state employment risks attenuation and timing mismatch (effects may be slow-moving and confounded by coincident macro news). The triple layering (path vs target × HtM × horizons) is likely underpowered and vulnerable to specification mining.
- **Novelty Assessment:** **Fairly novel as a cross-regional empirical test**, but it sits on an extensively debated identification object (forward guidance shocks), where small measurement differences can flip conclusions.
- **Recommendation:** **CONSIDER** as an *add-on module* to Idea 1 (shared infrastructure), not as a standalone flagship, unless you can show strong first-stage signal (path surprises) and stable results across shock datasets (GSS vs Swanson-style measures).

---

**#4: Asymmetric Monetary Transmission — Does Tightening Hurt More Than Easing Helps?**
- **Score: 52/100**
- **Strengths:** Policy-relevant (asymmetry matters for stabilization) and easy to implement given Idea 1’s pipeline; if real, the asymmetry result would be interpretable and meaningful for distributional/regional policy concerns.
- **Concerns:** As a standalone contribution it’s thin—**asymmetry in monetary policy effects is already a large literature**, and splitting shocks by sign substantially reduces effective sample size and increases sensitivity to outliers/regime changes (ZLB period, post-2008 communication shifts). Identification is also less crisp because “easing” and “tightening” episodes differ systematically in macro context (risk sentiment, financial stress), so sign-based comparisons risk conflating state dependence with shock sign.
- **Novelty Assessment:** **Low-to-moderate.** The novelty is mainly the interaction with HtM at the regional level, but the asymmetry question itself is well-trodden.
- **Recommendation:** **SKIP as a primary project;** keep as a **robustness/extension** inside Idea 1 if pre-registered and carefully framed (e.g., focusing on comparable regimes, excluding ZLB, or using state-dependent LP methods).

---

### Summary

This is a strong, coherent bundle around a single theme (heterogeneous transmission in HANK), but only **Idea 1** looks like a clear flagship given identification strength and data richness—*provided* you solve the state-level HtM measurement problem and convincingly separate liquidity constraints from correlated regional exposures. **Idea 2** is promising but will live or die on modern shift-share validity and disentangling endogenous transfer components; **Ideas 3–4** are better positioned as auxiliary tests within the Idea 1 framework than as standalone papers.