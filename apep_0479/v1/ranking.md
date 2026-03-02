# Research Idea Ranking

**Generated:** 2026-02-28T11:19:52.996177
**Models:** GPT-5.2, Gemini 3.1 Pro, Grok 4.1 Fast
**Reasoning:** high

## Comparison Table

| Idea | GPT-5.2 | Gemini 3.1 Pro | Grok 4.1 Fast |
|------|------|------|------|
| When Revenue Falls, Branches Follow — Th... | PURSUE (74) | — | — |
| The Digital Cliff — How Mobile Banking A... | PURSUE (62) | — | — |
| Merger Waves and Teller Displacement — T... | CONSIDER (58) | — | — |
| Cash or Card? ATM Surcharge Deregulation... | SKIP (33) | — | — |
| Idea 1: When Revenue Falls, Branches Fol... | — | PURSUE (74) | PURSUE (78) |
| Idea 3: Merger Waves and Teller Displace... | — | CONSIDER (58) | SKIP (58) |
| Idea 2: The Digital Cliff — How Mobile B... | — | SKIP (45) | CONSIDER (68) |
| Idea 4: Cash or Card? ATM Surcharge Dere... | — | SKIP (15) | SKIP (42) |

---

## GPT-5.2

**Tokens:** 5767

### Rankings

**#1: When Revenue Falls, Branches Follow — The Durbin Amendment, Bank Restructuring, and the Decline of the Bank Teller**
- **Score: 74/100**
- **Strengths:** Clear national policy shock with a sharp eligibility cutoff (> $10B) and rich administrative outcomes (branches, deposits, employment) over a long panel. Credible “causal chain” potential: Durbin revenue hit → branch footprint/operations → teller employment/occupational mix, with concrete welfare-adjacent implications (access, service quality, local employment).
- **Concerns:** The core exposure (share of deposits in >$10B banks) is highly correlated with urbanicity, income, and pre-existing digital adoption—so differential trends (not Durbin) are the main threat. County-level outcomes may also reflect general post-2010 banking tech trends that load more in “large-bank counties.”
- **Novelty Assessment:** **Moderately novel.** Durbin’s incidence on fees/profits is well-studied, but the **labor/branch-network restructuring** channel is much less covered and could be a genuine value-add if executed cleanly.
- **Top-Journal Potential: Medium.** Likely **top field journal (AEJ:EP) feasible**, and top-5 is possible only if you (i) nail identification diagnostics and (ii) deliver a mechanism package that changes how we think about “regulation → technology adoption/branch retrenchment,” not just a decline in tellers.
- **Identification Concerns:** Shift-share DiD hinges on “parallel trends in high–large-bank-share vs low-share counties” absent Durbin; that’s questionable given differential digitization and urban recovery paths. A DDD with non-banking employment helps with local macro shocks but not with *banking-sector-specific* secular trends correlated with large-bank presence; you’ll need strong pre-trend evidence and possibly designs closer to the $10B threshold at the bank level (or within-bank geographic comparisons).
- **Recommendation:** **PURSUE (conditional on: (i) convincing event-study pre-trends and robustness to county-specific linear trends / urban×time controls; (ii) at least one design that leverages the $10B cutoff more directly—e.g., bank-level or branch-level comparisons near the threshold; (iii) mechanism validation using FDIC income-line items to show the Durbin revenue hit maps into operational cuts).**

---

**#2: The Digital Cliff — How Mobile Banking Adoption Broke the ATM-Teller Complementarity**
- **Score: 62/100**
- **Strengths:** High-upside question with broad relevance: digital infrastructure as a general-purpose technology reshaping service delivery and local labor demand. If you can credibly isolate mobile banking adoption, this becomes a compelling “platform automation” test with relevance beyond banking.
- **Concerns:** The proposed instrument (terrain ruggedness × carrier rollout) has a **fragile exclusion restriction**: earlier 4G changes local economic activity, commuting/search, retail competition, and household finance broadly—any of which can affect branches independent of mobile banking. Also, 4G coverage is an imperfect proxy for *banking app adoption*; weak first-stage risk is real without direct adoption data.
- **Novelty Assessment:** **High novelty** in the specific framing (mobile broadband → banking branch structure/labor) though related literatures on broadband effects and bank branch decline exist; the “break in ATM-teller complementarity” angle is relatively fresh if empirically pinned down.
- **Top-Journal Potential: Medium (high variance).** If you can produce a tight first stage to *mobile banking adoption* and rule out broad “4G boosts everything” confounding with strong placebos/negative controls, this could interest top field journals and possibly a top-5. Without that, it will read as an over-ambitious broadband paper with a banking application.
- **Identification Concerns:** Main threats are (i) exclusion failure (4G affects outcomes via many channels), (ii) measurement error (coverage ≠ adoption), and (iii) differential pre-trends where carriers target growth markets. You will need extensive falsification (other industries’ establishments, local credit demand, population flows) and ideally bank/app-specific adoption data to anchor the mechanism.
- **Recommendation:** **CONSIDER (upgrade to PURSUE only if: you can obtain credible mobile-banking adoption measures—bank app downloads/active users by geography, or survey/admin adoption—and show strong first stage + targeted-placebo evidence).**

---

**#3: Merger Waves and Teller Displacement — The Labor Market Cost of Bank Consolidation**
- **Score: 58/100**
- **Strengths:** Sensible and policy-relevant: consolidation is ongoing, and branch overlap is a plausible predictor of closure intensity. FDIC SOD + merger records can produce a nice “new object” (overlap-based closure exposure) with clear mapping from event → branch closures → local employment.
- **Concerns:** The merger literature is enormous, and reviewers will suspect you’re re-labeling a familiar phenomenon unless the labor-market angle produces a surprising mechanism or welfare-relevant distributional result. Identification is the core weakness: voluntary merger timing is endogenous, and even “overlap” is not randomly assigned to counties.
- **Novelty Assessment:** **Moderate-to-low novelty.** “Mergers → branch closures” is well-trodden; “mergers → teller displacement” is less studied, but close enough to existing consolidation work that you must differentiate sharply (e.g., reemployment, wage scarring, local service access, distributional impacts).
- **Top-Journal Potential: Low-to-Medium.** More naturally a solid field-journal paper unless you can (i) use FDIC-assisted failures as the main quasi-experiment and (ii) deliver a bigger conceptual punch (e.g., consolidation as a labor-market shock with persistent local effects and equity implications).
- **Identification Concerns:** Endogeneity of merger selection/timing to local conditions; anticipatory closures; and spillovers across county borders (customers/branches substitute). FDIC-assisted acquisitions help, but you must show failures aren’t simply proxies for collapsing local economies (and that “exposure” isn’t mechanically higher in declining places).
- **Recommendation:** **CONSIDER (conditional on: making FDIC-assisted/failed-bank resolutions the primary design; demonstrating clean pre-trends; and adding outcomes beyond headcounts—wages, occupational transitions, local banking access).**

---

**#4: Cash or Card? ATM Surcharge Deregulation and the Restructuring of Bank Labor**
- **Score: 33/100**
- **Strengths:** The policy lever is conceptually sharp (surcharge price changes), and the hypothesis is intuitive and testable in principle. If there were many treated states, it would be a clean, teachable DiD.
- **Concerns:** Too few treated units (effectively 2–3 states) and messy legal/timing details make credible inference very hard; standard staggered DiD tools won’t rescue “N=2 treatment states.” The period also overlaps with many simultaneous structural shifts in banking and payments, complicating attribution.
- **Novelty Assessment:** **Moderate novelty** for labor outcomes specifically, but ATM surcharge policy itself has been studied, and the empirical design here is not defensible given the treated-sample limitation.
- **Top-Journal Potential: Low.** Even with perfect execution, editors/referees will view it as underpowered and fragile.
- **Identification Concerns:** Fundamental small-treated-units problem plus confounding national trends; inference will hinge on functional form and idiosyncratic state shocks.
- **Recommendation:** **SKIP** (unless you can find a richer, more granular policy discontinuity or many more jurisdictions with meaningful variation).

---

### Summary

This is a fairly coherent set centered on how revenue, technology, and consolidation reshape bank physical presence and labor—good thematic focus. The clear first move is **Idea 1**, which has the best combination of feasible data, policy salience, and plausibly credible identification if you aggressively address differential-trend threats. **Idea 2** has the highest conceptual upside but is only worth serious investment if you can directly measure mobile-banking adoption and convincingly isolate it from “general 4G effects.”

---

## Gemini 3.1 Pro

**Tokens:** 8423

Here is my evaluation and ranking of the research proposals, applying the criteria and editorial patterns provided.

### Rankings

**#1: Idea 1: When Revenue Falls, Branches Follow — The Durbin Amendment, Bank Restructuring, and the Decline of the Bank Teller**
- **Score**: 74/100
- **Strengths**: Cleverly links a well-known financial regulatory shock to a novel labor/automation outcome, providing a clear mechanism for the breakdown of the ATM-teller complementarity. The data is highly feasible, and the continuous DiD design is standard and executable.
- **Concerns**: Large banks (>$10B) and the counties they dominate may have been on different recovery trajectories post-2008 compared to small-bank counties, threatening parallel trends. 
- **Novelty Assessment**: The Durbin Amendment is heavily studied regarding consumer fees and bank profitability, but the pivot to physical infrastructure and labor composition is a fresh, creative angle that hasn't been saturated.
- **Top-Journal Potential**: Medium to High. While the Durbin Amendment is old news, framing this as a "puzzle-resolver" for the Bessen (2015) ATM-teller paradox elevates it from a standard policy evaluation to a broader, more exciting paper about the economics of automation.
- **Identification Concerns**: The main threat is that counties with high >$10B bank deposit shares differ systematically in their post-Great Recession recovery dynamics. The proposed DDD using non-banking employment is crucial but may not fully absorb banking-specific local macro shocks.
- **Recommendation**: PURSUE (conditional on: passing strict pre-trend tests; demonstrating the DDD effectively absorbs local macro shocks).

**#2: Idea 3: Merger Waves and Teller Displacement — The Labor Market Cost of Bank Consolidation**
- **Score**: 58/100
- **Strengths**: Highly feasible with standard, accessible administrative data. The use of FDIC-assisted acquisitions provides a plausible path to cleaner identification than voluntary mergers.
- **Concerns**: The finding that overlapping bank mergers lead to branch closures and teller layoffs is highly intuitive and borders on mechanical. It lacks a surprising mechanism.
- **Novelty Assessment**: Bank consolidation and branch closures are extensively studied (e.g., Nguyen 2019), though usually focusing on credit supply rather than labor displacement. The labor angle is an incremental addition to a crowded literature.
- **Top-Journal Potential**: Low. This fits the exact profile of a "technically competent but not exciting" paper. It applies a standard DiD to a familiar margin without a surprising mechanism, counter-intuitive equilibrium effect, or broader welfare deliverable.
- **Identification Concerns**: Voluntary mergers are highly endogenous to local economic conditions. Even FDIC-assisted acquisitions occur in areas experiencing severe local economic distress, making it hard to isolate the merger effect from the underlying economic shock.
- **Recommendation**: CONSIDER (as a solid field-journal paper, but do not expect top-5 interest).

**#3: Idea 2: The Digital Cliff — How Mobile Banking Adoption Broke the ATM-Teller Complementarity**
- **Score**: 45/100
- **Strengths**: The conceptual framing—distinguishing "process automation" (ATMs) from "platform automation" (mobile banking)—is brilliant and highly relevant to current AI and labor debates.
- **Concerns**: The proposed instrumental variable (terrain ruggedness interacted with carrier rollout) is fundamentally flawed and violates the exclusion restriction.
- **Novelty Assessment**: Very high. Directly testing the mechanism that broke the ATM-teller complementarity using the 4G rollout is a highly original approach to the automation literature.
- **Top-Journal Potential**: High conceptually, but Low in execution. Top journals love mechanism-changing papers on automation, but editors will immediately reject this paper over the fragile identification strategy.
- **Identification Concerns**: Fatal flaw in the IV. Terrain ruggedness affects historical development and infrastructure, while 4G rollout impacts all sectors of the local economy, making it impossible to isolate the mobile banking channel from broader digital trends.
- **Recommendation**: SKIP (unless a completely new, credible identification strategy for mobile banking adoption can be found).

**#4: Idea 4: Cash or Card? ATM Surcharge Deregulation and the Restructuring of Bank Labor**
- **Score**: 15/100
- **Strengths**: Asks an interesting historical question about how pricing networks affect labor composition.
- **Concerns**: The research design is mathematically impossible to execute credibly due to a severe lack of treated units.
- **Novelty Assessment**: Moderate. The historical ATM surcharge wars are known, but the labor angle is somewhat new.
- **Top-Journal Potential**: Low. It is a historical curiosity without the statistical power to deliver a convincing, precisely estimated causal effect.
- **Identification Concerns**: Fatal flaw. With only 2-3 treated states, a staggered DiD (or Callaway-Sant'Anna) cannot reliably estimate treatment effects or cluster standard errors.
- **Recommendation**: SKIP.

### Summary

This batch presents a mix of creative conceptual framing and significant identification challenges. Idea 1 is the clear standout, successfully pivoting a well-worn regulatory shock into a novel puzzle-resolver about the economics of automation, and should be pursued. The remaining ideas suffer from either fatal identification flaws (Ideas 2 and 4) or a lack of top-journal ambition (Idea 3), highlighting the need for tighter alignment between exciting mechanisms and credible causal designs.

---

## Grok 4.1 Fast

**Tokens:** 5277

### Rankings

**#1: Idea 1: When Revenue Falls, Branches Follow — The Durbin Amendment, Bank Restructuring, and the Decline of the Bank Teller**
- Score: 78/100
- Strengths: Clean national shock with continuous local exposure variation enables a compelling causal chain from revenue loss to branch/teller shedding, directly extending the ATM-teller paradox into policy-driven restructuring; excellent data availability and pre-trends testing make execution straightforward and credible.
- Concerns: Continuous treatment intensity may suffer from sorting or anticipation if large banks preemptively adjusted; teller-specific outcomes at MSA level slightly misalign with county-level ID.
- Novelty Assessment: Moderately studied—Durbin effects on profitability/pricing well-covered (e.g., Kay et al. 2014), but labor/infrastructure angle untouched, no papers link it explicitly to Bessen-style complementarity breakdown.
- Top-Journal Potential: High—resolves a puzzle (why teller-ATMs stayed complementary until ~2011) via a crisp policy shock and mechanism chain (revenue → infrastructure → digital shift), with first-order welfare implications for fintech regulation; fits editorial wins on "puzzle-resolvers" and "mechanism-changing equilibrium effects."
- Identification Concerns: Parallel trends credible with 5+ pre-periods and DDD, but Bartik intensity vulnerable to national banking trends confounding local exposure if large-bank deposits correlate with unobserved county factors.
- Recommendation: PURSUE (conditional on: validating no pre-Durbin branch anticipation in event study; linking to consumer welfare via deposit shifts)

**#2: Idea 2: The Digital Cliff — How Mobile Banking Adoption Broke the ATM-Teller Complementarity**
- Score: 68/100
- Strengths: Novel distinction between process (ATMs) and platform (mobile) automation ties directly to Bessen puzzle and current AI debates, with potential for dynamic event-study tracing of branch decline.
- Concerns: Terrain IV exclusion restriction highly suspect (4G boosts local economy broadly, spilling over to non-banking demand); FCC data processing is messy and sample may lack power for tract-to-county aggregation.
- Novelty Assessment: Fairly novel—Bessen (2015) paradox unresolved post-2010, no causal studies on mobile broadband's role in banking labor; scattered descriptive work on mobile adoption but no ID on branch effects.
- Top-Journal Potential: Medium—counter-intuitive mechanism (platform shift breaks complementarity) has field-wide appeal for automation debates, but lacks "live policy frontier" stakes and risks reading as niche tech shock without tight welfare deliverable.
- Identification Concerns: Instrument plausibly predicts rollout but fails exclusion (terrain affects all mobile-dependent sectors); backup shift-share too mechanical without strong national shock.
- Recommendation: CONSIDER (conditional on: strong first-stage/terrain validation via placebo industries; FCC data pilot confirming tract coverage power)

**#3: Idea 3: Merger Waves and Teller Displacement — The Labor Market Cost of Bank Consolidation**
- Score: 58/100
- Strengths: Links mergers to tangible labor outcomes using predicted overlap exposure, with FDIC-assisted deals providing cleaner exogenous variation; feasible branch-level matching.
- Concerns: Merger timing endogenous to local conditions (e.g., weak economies prompt consolidation); teller reemployment tracking via ACS too aggregate for precise displacement effects.
- Novelty Assessment: Somewhat studied—merger lit heavy on pricing/credit (e.g., dozens of papers post-2008), some on branches but few on tellers/labor; incremental extension.
- Top-Journal Potential: Low—competent DiD on familiar consolidation margin yields unsurprising ATE (branches close → jobs lost) without counter-intuitive mechanism or lit pivot; fits "technically sound but not exciting" losing pattern.
- Identification Concerns: Overlap prediction quasi-exogenous but high-exposure counties likely differ systematically (e.g., denser markets); assisted mergers help but sample-limited.
- Recommendation: SKIP

**#4: Idea 4: Cash or Card? ATM Surcharge Deregulation and the Restructuring of Bank Labor**
- Score: 42/100
- Strengths: Tests pricing's role in ATM-teller substitution, potentially revealing labor composition shifts.
- Concerns: Critically low variation (2-3 treated states, blurred timings from litigation) dooms staggered DiD power and credibility; ancient policy (1996) with massive confounders like internet rise.
- Novelty Assessment: Heavily studied—ATM surcharging effects on usage/fees covered in 1990s-2000s papers (e.g., Hancock-Collier); labor angle redundant and outdated.
- Top-Journal Potential: Low—no stakes, no novelty, no clean ID; classic "small question" loser with diffuse exposure.
- Identification Concerns: Too few treated units (<20 needed per appendix patterns) + heterogeneous timing violate staggered DiD assumptions (Callaway-Sant'Anna fragile here).
- Recommendation: SKIP

### Summary
This batch has one standout (Idea 1) with top-journal promise via novel policy-labor linkage and airtight ID, while others suffer feasibility/ID flaws or lack excitement. Pursue Idea 1 first for its puzzle-resolving potential; Idea 2 warrants a data pilot but risks IV pitfalls; skip 3-4 as incremental or unfeasible. Overall quality is solid but typical—mostly "competent" mid-tier ideas needing sharper mechanisms to elevate.

