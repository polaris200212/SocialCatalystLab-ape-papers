# Research Idea Ranking

**Generated:** 2026-02-27T15:36:32.272931
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 10648

---

### Rankings

**#1: Downtown for Sale? Commercial Displacement Effects of France's Action Cœur de Ville Program**
- **Score: 78/100**
- **Strengths:** Very high novelty with unusually strong *administrative-universe* outcomes (Sirene) and a large number of treated units (≈222), making modern staggered-DiD feasible. The displacement (center vs nearby periphery) question is exactly the kind of general-equilibrium effect policymakers routinely miss.
- **Concerns:** Treatment selection is plausibly related to pre-existing decline (parallel trends risk), and ACV is bundled with closely related instruments (ORT, Denormandie) plus COVID shocks that may differentially hit “medium-city centers.” The biggest practical risk is *spatial mismatch*: ACV targets the **city center**, but commune-level outcomes may dilute effects if you cannot localize “downtown” precisely.
- **Novelty Assessment:** **Highly novel.** I’m not aware of a credible causal evaluation of ACV; the Cour des Comptes critique is consistent with a genuine gap.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (2012–2017 gives 6 years; quarterly aggregation feasible from Sirene event dates).
  - **Selection into treatment:** **Marginal** (likely targeted to places with problems; need strong pre-trend/event-study diagnostics + matching within département and “HonestDiD” style sensitivity).
  - **Comparison group:** **Marginal** (matching helps, but “other communes” may not be comparable to medium-sized central cities; best to compare to *similar central places* or use within-département reweighting).
  - **Treatment clusters:** **Strong** (≈222 treated communes >> 20).
  - **Concurrent policies:** **Marginal** (Denormandie/ORT are intertwined with ACV; COVID is a large coincident shock—must show controls were hit similarly and/or interact shocks with pre-urban structure).
  - **Outcome-Policy Alignment:** **Marginal → Strong if refined.** Sirene establishment creation/cessation in retail/hospitality/services is tightly connected to “commercial revitalization,” but only **Strong** if you define downtown geography (e.g., geocode establishments and restrict to a downtown polygon/buffer rather than whole-commune totals).
  - **Data-Outcome Timing:** **Marginal.** Sirene can be constructed quarterly (e.g., quarter-end stock or within-quarter flows). Treatment starts **March 26, 2018** (announcement) but implementation via **convention signatures (Oct 2018–2024)**; you must align “treated” to *post-signature quarters* (and avoid counting the signature quarter as full exposure).
  - **Outcome Dilution:** **Marginal.** If measured at commune level, ACV affects a subset (city center) rather than the full commune economy; dilution could be large in communes with sizable peripheries. Geocoding downtown reduces this risk substantially.
- **Recommendation:** **PURSUE (conditional on: downtown geolocation/definition rather than commune-only; transparent event-study pre-trend tests and sensitivity; explicit handling of ACV as a bundled package incl. ORT/Denormandie and COVID heterogeneity).**

---

**#2: The Energy Penalty — How France's Rental Ban on Low-DPE Housing Reshaped Property Values**
- **Score: 48/100**
- **Strengths:** Big-policy relevance (millions of units) and potentially elegant within-market variation (ratings) that avoids “which commune adopted what” problems. If designed well, this could provide an early, policy-salient estimate of capitalization/stranding risk for low-efficiency housing.
- **Concerns:** As written, the design is threatened by **(i) very short pre-period** around Aug 2021 and **(ii) a major concurrent structural break**: the **DPE methodology reform on July 1, 2021** mechanically changes ratings, creating a near-impossible confound with the Aug 2021 law announcement. Rating endogeneity (diagnosis timing, selective renovations, strategic relabeling) is also non-trivial.
- **Novelty Assessment:** **Moderately high.** There is a growing European “energy label capitalization” literature, but France-specific DVF×DPE at scale with the rental-ban schedule is still relatively uncrowded.
- **DiD Assessment (treating DDD as DiD-family):**
  - **Pre-treatment periods:** **Weak (as proposed).** DVF window stated as 2020H2–Aug 2021 yields ≤1 year pre for the announcement study; too short to validate trends.
  - **Selection into treatment:** **Strong.** National policy; exposure is by rating, not by politically selected geography (though rating itself is endogenous).
  - **Comparison group:** **Marginal.** D/C-rated homes are not naturally comparable to G-rated homes; needs tight hedonic controls, location×time FE, and possibly within-micro-area comparisons.
  - **Treatment clusters:** **Strong.** Enormous number of observations (transactions); inference at appropriate clustering level (micro-area) is feasible.
  - **Concurrent policies:** **Weak (as proposed).** The July 2021 DPE reform is a first-order coincident “policy” affecting the key running variable (rating).
  - **Outcome-Policy Alignment:** **Strong.** Sales prices are the correct object for capitalization of future rental restrictions/renovation obligations.
  - **Data-Outcome Timing:** **Marginal.** Outcome is measured at **transaction date** (day-level in DVF). Treatment is **Aug 22, 2021** (announcement) but the binding constraint is **Jan 2025** for G rentals; an announcement-based design is vulnerable to anticipation and slow updating of beliefs/renovation options.
  - **Outcome Dilution:** **Marginal.** “Treated” (G/F) is a minority of transactions (often ~10–20% depending on market), so effects may be measurable but not guaranteed without large samples and careful stratification.
- **Recommendation:** **CONSIDER (conditional on: redesign around the *Jan 2025 implementation* discontinuity rather than Aug 2021; explicitly modeling/isolating the July 2021 DPE reform—e.g., restrict to diagnoses under the new method and use a longer pre 2021Q3–2024 window; strong micro-location×time FE and robustness to diagnosis timing).**  
  *Without this redesign, I would SKIP due to the DPE-reform confound + short pre-period.*

---

**#3: Does Rental Licensing Improve Housing Quality or Just Reduce Supply? Evidence from France's Permis de Louer**
- **Score: 42/100**
- **Strengths:** High policy relevance (habitability enforcement vs supply contraction) and, in principle, a large treated set (500+ communes) that could support credible staggered designs if treatment dates and treated geographies are measured correctly.
- **Concerns:** Two near-dealbreakers: **(i) treatment timing data** are not centralized (high risk the “policy date” is wrong, killing identification), and **(ii) outcome mismatch/dilution**—Permis de Louer targets *rental units in designated zones*, while DVF is *all sales* in a commune (owner-occupied + rental, treated zone + untreated zone). Selection is also likely related to deteriorating housing markets.
- **Novelty Assessment:** **High.** I’m not aware of a well-known economics causal paper on France’s Permis de Louer; internationally the selective licensing literature is thin.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak (as written).** With DVF starting 2020H2, many adoptions won’t have ≥3–4 years pre; early adopters (2017–2019) have essentially no pre.
  - **Selection into treatment:** **Marginal → Weak.** Adoption is explicitly targeted to “habitat indigne,” plausibly correlated with declining prices/quality (trend-driven adoption risk).
  - **Comparison group:** **Marginal.** Never-treated communes are likely structurally different; better would be within-département border areas or within-urban-area comparisons.
  - **Treatment clusters:** **Strong** (500+ communes if dates are correct).
  - **Concurrent policies:** **Marginal.** Many housing/energy policies overlap; must show no coincident local shocks drive results.
  - **Outcome-Policy Alignment:** **Marginal.** Sale prices could reflect regulatory burden or quality signaling, but it’s indirect relative to the program’s primary mechanism (rental authorization/inspections). Quality outcomes would be stronger if you can measure enforcement/renovation.
  - **Data-Outcome Timing:** **Marginal.** DVF is at sale date; policy effective dates can be mid-year and enforcement ramps slowly—requires careful “exposure” coding (exclude partial quarters, allow lags).
  - **Outcome Dilution:** **Weak (likely).** Only a subset of the commune and a subset of dwellings (rentals in zoned areas) are treated; in many communes this could easily be <10–20% of DVF transactions unless you geo-identify the exact zones and rental-relevant segments.
- **Recommendation:** **SKIP (unless: you can assemble a validated national adoption-date + zone-boundary dataset; and you can measure outcomes at the treated-zone level or on a sample highly likely to be rental-relevant; and you can recover ≥3–4 years pre for the cohorts you study).**  

---

**#4: Rent Control and Firm Creation — Evidence from France's Staggered Encadrement des Loyers**
- **Score: 40/100**
- **Strengths:** Interesting mechanism and a genuinely underexplored outcome (entrepreneurship/firm entry rather than rents). Sirene is excellent for measuring firm creation with long panels.
- **Concerns:** The proposed staggered DiD is not credible with **only ~9 treated territories** (inference fragile; high sensitivity to specification) and **major coincident shocks** (e.g., Lille’s March 2020 adoption coincides with COVID). Also, outcome-policy linkage is conceptually indirect: rent control affects *some renters in some neighborhoods*, while firm creation is economy-wide.
- **Novelty Assessment:** **Moderate.** Rent control is heavily studied, but France-specific recent episodes and “firm creation” as the outcome are relatively novel.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (Sirene provides many years pre for all units).
  - **Selection into treatment:** **Marginal.** Cities opt in via application/approval and often in response to rent pressure and local politics.
  - **Comparison group:** **Marginal.** Paris/Lyon/etc. differ strongly from potential controls; requires very careful donor pool construction.
  - **Treatment clusters:** **Weak (dealbreaker for DiD).** <10 treated clusters/territories.
  - **Concurrent policies:** **Weak.** COVID overlaps with key adoptions; other local economic policies may co-move.
  - **Outcome-Policy Alignment:** **Marginal.** Mechanism (housing costs → entrepreneurship) is plausible, but rent control affects a subset of households and does not directly target firms.
  - **Data-Outcome Timing:** **Marginal.** Firm creation measured by quarter; effective dates are mid-year/month-specific—must ensure post periods reflect real exposure.
  - **Outcome Dilution:** **Weak.** Only a fraction of potential entrepreneurs are renters affected by the cap, and the cap applies within specific zones; aggregate commune firm creation is likely mostly untreated.
- **Recommendation:** **SKIP as a staggered DiD.** Potentially **CONSIDER** only as a *small-N policy evaluation* (Paris-only or Paris+Lille) using synthetic control / carefully designed metro-area border comparisons, but that is a different project than proposed.

---

### Summary

This is a strong batch on **novel French policy evaluation using administrative data**, but only **Idea 1 (ACV)** currently clears the identification bar without a “Weak” red flag. Ideas 2–4 all contain at least one near-dealbreaker (missing/uncertain treatment timing + dilution for Permis de Louer; DPE reform confound + short pre-period for the Energy Penalty as proposed; too few treated clusters and heavy dilution for Rent Control → Firm Creation). If funding one immediately, fund **Idea 1**, and only fund **Idea 3** if the design is re-anchored to the **Jan 2025 implementation** and explicitly separates the **July 2021 DPE reform** from the rental-ban effect.