# Research Idea Ranking

**Generated:** 2026-02-26T09:52:57.494115
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6424

---

### Rankings

**#1: Second Home Caps and Local Labor Markets — RDD at the 20% Threshold (Lex Weber)**
- **Score: 77/100**
- **Strengths:** The running variable (pre-initiative second-home share) is plausibly exogenous to post-2013 outcomes, making the RDD unusually credible. Data availability at the municipality level (employment, permits, tourism) looks strong and supports multiple outcome/robustness checks.
- **Concerns:** The “sharpness” may be weakened by grandfathering/transition rules and anticipatory behavior (permit rush pre-2013) that could shift effects into 2012–2013 and complicate interpretation. Also, municipalities near 20% may be atypical (tourist resorts), so external validity is local-to-cutoff by design.
- **Novelty Assessment:** **High** within this policy space. Lex Weber has been studied (notably via DiD and construction outcomes), but a *local* RDD around 20% with labor-market/tourism sector outcomes is meaningfully new.
- **DiD Assessment (if applicable):** Not applicable (RDD).
- **Recommendation:** **PURSUE (conditional on: verifying legal “bindingness” at 20% in practice by year; explicitly handling anticipation/transition periods—e.g., exclude 2012–2013 or model event-time; and confirming the second-home-share measure is pre-determined and consistently measured across municipalities).**

---

**#2: Do Municipal Mergers Save Money? RDD Evidence from Swiss Merger Referendums**
- **Score: 72/100**
- **Strengths:** Close-election RDD is a gold-standard design, and the referendum setting provides a compelling quasi-randomization story. Policy relevance is high: consolidation/mergers are a live issue in many countries, and credible evidence on scale economies is scarce and valuable.
- **Concerns:** The treatment assignment is **multi-jurisdictional** (“passes in all municipalities or fails”), so you need a correct forcing variable (e.g., minimum vote share across member municipalities) and careful inference—this is not a standard single-unit election RD. Data feasibility is the big risk: referendum vote shares may require extensive hand collection, and mergers change municipal boundaries, forcing nontrivial geographic harmonization (pre-period aggregation to post-merger borders).
- **Novelty Assessment:** **Moderate-to-high.** Municipal consolidation is studied, and referenda have been used in related contexts, but an RD anchored on the *pivotal vote margin* for Swiss municipal mergers would still be a distinctive and publishable contribution if executed cleanly.
- **DiD Assessment (if applicable):** Not applicable (RDD).
- **Recommendation:** **PURSUE (conditional on: securing comprehensive referendum microdata; defining the forcing variable rigorously for “all-must-pass” structure; and building a consistent panel on stable geographic units—e.g., mapping all outcomes onto post-merger municipality boundaries).**

---

**#3: Does Democracy Scale? Municipal Population Thresholds and Governance Quality in Switzerland**
- **Score: 65/100**
- **Strengths:** Population-threshold RDD is a well-understood approach, and Switzerland’s assembly-vs-parliament governance margin is genuinely interesting and institutionally distinctive. If the legal rule is binding and measured cleanly, this can deliver clear causal evidence on governance form.
- **Concerns:** Two common RDD failure modes are real here: (i) **fuzzy compliance** (municipalities may not switch exactly at the threshold, or switching may be delayed), and (ii) **manipulation/sorting** (population thresholds sometimes induce strategic registration or merger behavior). Feasibility hinges on assembling a high-quality governance-structure dataset (who is actually under which system, and when), not just statutory thresholds.
- **Novelty Assessment:** **High for Switzerland**, **moderate globally**. Threshold RDDs on political institutions are common internationally, but the Swiss direct-assembly margin is less studied and could be a strong “institutional design” paper.
- **DiD Assessment (if applicable):** Not applicable (RDD).
- **Recommendation:** **CONSIDER (conditional on: verifying exact legal thresholds and the population measurement rule—census date vs annual register; collecting an “actual governance regime” panel to test for fuzziness; and performing strong manipulation tests around the cutoff).**

---

**#4: Minimum Wages at the Border: Spatial RDD Evidence from Swiss Cantonal Minimum Wages**
- **Score: 60/100**
- **Strengths:** Highly policy-relevant, with unusually high minimum-wage levels and multiple adoption events. The border design is intuitive to policymakers and allows transparent local comparisons.
- **Concerns:** Spatial RDD is often **not cleanly identified** because borders coincide with many discontinuities (taxes, sector mix, urbanization, enforcement intensity, housing costs), and here those canton-level differences are plausibly first-order. Power is also a concern: many border segments have few municipalities, and commuter flows can shift incidence away from residents to cross-border workers/firms, muddying outcome interpretation.
- **Novelty Assessment:** **Moderate.** Minimum-wage border designs are very heavily studied internationally; Switzerland is a new setting, but the design itself is not novel.
- **DiD Assessment (if applicable):** Not applicable (spatial RDD).
- **Recommendation:** **CONSIDER (conditional on: upgrading to a “difference-in-discontinuities” design—border discontinuity pre vs post within each border segment; documenting and controlling for canton-pair discontinuities; and ensuring outcomes match the margin—ideally establishment-level employment/wages near the border rather than broad municipal aggregates).**

---

**#5: Does Pay Transparency Close the Gender Gap? Firm-Size RDD on Switzerland's Equal Pay Mandate**
- **Score: 44/100**
- **Strengths:** Strong policy relevance and a clear statutory threshold (100 employees) that, in principle, lends itself to an RDD. Switzerland’s mandate (analysis + audit + communication) is a meaningful policy treatment.
- **Concerns:** As proposed, **data access is a likely dealbreaker**: without firm-level wage microdata and precise firm size, the RDD cannot be implemented. Even with access, firm-size thresholds often exhibit **bunching/manipulation** (reclassifying headcount) and treatment may be “soft” (an internal analysis requirement may not translate into wage changes quickly), weakening first-stage and interpretability.
- **Novelty Assessment:** **Moderate.** Pay transparency effects are widely studied; Switzerland is a new institutional variant, but the core question is not novel relative to the existing international literature.
- **DiD Assessment (if applicable):** Not applicable (RDD).
- **Recommendation:** **SKIP (unless: you can secure administrative employer-employee data with exact headcount and wages, and you can document a strong first stage—compliance/audits—plus limited manipulation at 100).**

---

### Summary

This is a strong batch overall on design ambition: several ideas correctly target quasi-experimental thresholds rather than weak DiD. The top priorities are **Idea 1** (best mix of novelty, clean identification, and feasible data) and **Idea 3** (potentially very clean RD with high policy value, but only if referendum and boundary-harmonization data hurdles are cleared). The main “do not fund without proof” proposal is **Idea 4**, where spatial border discontinuities and limited border sample sizes make clean causal interpretation much harder than it first appears.