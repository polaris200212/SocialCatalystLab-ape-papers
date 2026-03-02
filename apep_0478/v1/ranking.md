# Research Idea Ranking

**Generated:** 2026-02-28T01:10:05.369032
**Models:** GPT-5.2, Gemini 3.1 Pro, Grok 4.1 Fast
**Reasoning:** high

## Comparison Table

| Idea | GPT-5.2 | Gemini 3.1 Pro | Grok 4.1 Fast |
|------|------|------|------|
| Going Up Alone — Automation, Trust, and ... | PURSUE (76) | — | — |
| Forty Years of Distrust — A Structural M... | CONSIDER (58) | — | — |
| The Last Operators — Race, Gender, and t... | CONSIDER (49) | — | — |
| Building Vertical — Skyscrapers, Elevato... | SKIP (41) | — | — |
| Idea 1: Going Up Alone — Automation, Tru... | — | PURSUE (82) | — |
| Idea 3: Forty Years of Distrust — A Stru... | — | CONSIDER (62) | CONSIDER (68) |
| Idea 2: The Last Operators — Race, Gende... | — | SKIP (55) | CONSIDER (62) |
| Idea 4: Building Vertical — Skyscrapers,... | — | SKIP (38) | SKIP (48) |
| Idea 1: Going Up Alone — Automation, Tru... | — | — | PURSUE (88) |

---

## GPT-5.2

**Tokens:** 5253

### Rankings

**#1: Going Up Alone — Automation, Trust, and the Disappearance of the Elevator Operator (PREFERRED)**
- **Score: 76/100**
- **Strengths:** Genuinely novel setting with a sharp, story-friendly mechanism (behavioral/trust friction) and a plausibly pivotal shock (1945 strike) that can be framed as resolving a long-run “adoption puzzle,” not just documenting displacement. The data scale (full-count Census + linked panels) enables unusually rich labor-market anatomy and heterogeneity.
- **Concerns:** The core causal claim risks being under-identified if you rely mainly on decennial 1940→1950 comparisons: one treated city, few time periods, and many NYC-specific concurrent forces (postwar modernization, building code/insurance changes, labor relations, construction boom) could move both adoption and operator employment. You’ll need *direct* adoption/procurement evidence (installations/modernizations) and strong falsification tests to keep this from reading as an elegant narrative plus suggestive DiD.
- **Novelty Assessment:** High. Elevator-operator automation is widely cited as a canonical example, but to my knowledge it is not already “papered to death” in economics with modern causal tools; the strike-as-coordination-shock angle is especially uncommon.
- **Top-Journal Potential:** **Medium–High** if you can make the strike-to-adoption link tight and document the mechanism chain (strike → exposure/updated beliefs → installation decisions → occupational collapse). The “behavioral barrier stalls superior technology for 40 years” framing is top-journal-friendly *if* it’s empirically pinned down rather than inferred from timing.
- **Identification Concerns:** Main threats are (i) NYC-specific shocks in the 1940s correlated with modernization and labor demand, (ii) inference with a single treated unit, and (iii) using operator employment as a proxy for adoption (could shift due to wages/union rules/building composition without automation). Stronger designs would include annual installation/permit data, a synthetic control with long pre-trends, negative controls (other building-service occupations; smaller buildings; residential vs commercial), and evidence that other cities did not face similar shocks.
- **Recommendation:** **PURSUE (conditional on: obtaining independent adoption/installation data beyond operator counts; implementing a design credible with one treated unit—synthetic control / augmented SCM / permutation inference; building a “mechanism chain” with intermediate outcomes such as modernization contracts, elevator retrofits, or contemporaneous reporting on rider trust/complaints)**

---

**#2: Forty Years of Distrust — A Structural Model of Behavioral Barriers to Technology Adoption**
- **Score: 58/100**
- **Strengths:** If executed well, a structural model could translate the narrative into interpretable primitives (beliefs/trust frictions, adoption costs) and deliver welfare/counterfactuals—exactly the kind of “deliverable” top outlets like when reduced-form variation is limited. It also strengthens the generality beyond a single occupation.
- **Concerns:** High risk of becoming “model-driven” because the key objects (true adoption/retrofit costs, building-level technology choice sets, quality/safety incidents, regulation/insurance constraints) are hard to measure pre-1950; the strike as a single moment condition may not identify what you think it identifies. Without unusually good auxiliary data, referees will treat the structural layer as fragile.
- **Novelty Assessment:** Medium–High. Behavioral frictions in adoption are heavily studied in many contexts, but a historical structural estimation anchored to a coordination shock is less common; still, the novelty hinges on data quality.
- **Top-Journal Potential:** **Medium** in principle, but only if the model is disciplined by multiple moments (not just one shock), produces clean counterfactuals, and clearly dominates a reduced-form account. Otherwise it’s likely to be viewed as an ambitious appendix to Idea 1 rather than a standalone contribution.
- **Identification Concerns:** Parameter identification is vulnerable to omitted margins (codes, insurance, capital scarcity, postwar renovation) that look like “trust,” and to weak linking between operator employment shares and true technology adoption.
- **Recommendation:** **CONSIDER (as an extension module of Idea 1, not the flagship, until you secure rich non-Census adoption/cost/regulatory data and can show parameters are well-identified with sensitivity/partial identification bounds)**

---

**#3: The Last Operators — Race, Gender, and the Queue for Automation's Casualties**
- **Score: 49/100**
- **Strengths:** The demographic composition is striking and policy-relevant, and the linked panel can produce credible descriptive facts about transitions, sorting, and differential exit that are hard to get elsewhere. This could be a strong, publishable “distributional impacts” section.
- **Concerns:** The proposed causal question (“last hired, first fired” vs hierarchy) is difficult to identify cleanly because race/gender differences in exit timing can reflect pre-existing job ladders, union rules, building types, and differential mobility—none exogenous to the strike or automation. As a standalone paper, it risks reading as competent but not conceptually new relative to the large displacement/inequality literature.
- **Novelty Assessment:** Medium–Low. Distributional impacts of technological change and displacement by race/gender are widely studied; the elevator-operator setting is novel, but the main estimand is not.
- **Top-Journal Potential:** **Low–Medium** standalone; **Medium** as part of Idea 1 if tightly linked to the adoption mechanism (e.g., whether belief updating/adoption affected buildings employing more women/Black operators first, and why).
- **Identification Concerns:** Selection into operator jobs and into particular buildings/cities; differential measurement error in linkage; migration between 1940–1950; and the strike affecting outcomes via many channels besides automation (labor relations, wage bargaining).
- **Recommendation:** **CONSIDER (best folded into Idea 1 with a clearly pre-specified heterogeneity structure and strong within-city/building-type controls; avoid overselling causality)**

---

**#4: Building Vertical — Skyscrapers, Elevator Operators, and the Geography of Urban Growth**
- **Score: 41/100**
- **Strengths:** Big-picture question with intuitive policy relevance (how enabling technologies shape urban form) and potential to connect labor demand to city structure. Could yield a useful historical descriptive atlas.
- **Concerns:** Identification is weak (mostly cross-city correlations) and the binding constraint is data: consistent pre-1950 building height/stock measures are sparse and likely endogenous to unobserved city growth shocks. This is the most likely to end up as “interesting facts” without a credible causal lever.
- **Novelty Assessment:** Medium–Low. The elevator/skyscraper nexus is well known in urban economics/history; many papers study determinants of city height/density and transport technologies, so the incremental novelty is limited without a sharp shock or new measurement object.
- **Top-Journal Potential:** **Low** absent a new dataset on building heights/permits with a quasi-experiment (e.g., zoning changes, fire-code reforms, financing shocks) that moves vertical construction independently of demand.
- **Identification Concerns:** Severe endogeneity (growth ↔ skyscrapers ↔ services employment), limited pre-trend testing, and likely measurement error in building stock proxies.
- **Recommendation:** **SKIP (unless you first secure a compelling new building-level dataset and a sharp policy discontinuity that shifts vertical construction)**

---

### Summary

This is a high-variance batch: **Idea 1** is the only concept that plausibly clears the “novel mechanism + first-order stakes + publishable object” bar, but it must overcome real single-treated-unit and proxy-for-adoption concerns to reach top-journal credibility. **Ideas 2 and 3** are best treated as modules that strengthen Idea 1 (distributional impacts and disciplined counterfactuals), while **Idea 4** is least promising without a new data/ID breakthrough.

---

## Gemini 3.1 Pro

**Tokens:** 6958

### Rankings

**#1: Idea 1: Going Up Alone — Automation, Trust, and the Disappearance of the Elevator Operator**
- **Score**: 82/100
- **Strengths**: This brilliantly frames a technology adoption lag as a behavioral equilibrium puzzle, using a highly salient historical shock (the 1945 strike) to explain the sudden collapse of a 40-year friction. It perfectly matches the editorial preference for "puzzle-resolvers" that reveal counter-intuitive mechanisms (trust/behavioral barriers) rather than just estimating standard displacement ATEs.
- **Concerns**: The timing of the data versus the shock is highly problematic; if the strike was in 1945 but automated installations only reached 12.6% by 1950, the 1940-1950 decadal Census will miss the actual displacement wave (which seemingly occurred in the 1950s). Furthermore, NYC is a single treated unit, raising concerns about concurrent post-WWII shocks specific to the city.
- **Novelty Assessment**: High. While the occupation's demise is a known stylized fact (e.g., Bessen 2016), framing its delayed adoption as a behavioral friction broken by a labor strike is a genuinely novel, unstudied angle that speaks directly to modern AI adoption debates.
- **Top-Journal Potential**: High. A top-5 journal would find this exciting because it uses a clean historical natural experiment to test a first-order theoretical question: why does superior technology sit dormant? It delivers a compelling causal chain (feasible tech → behavioral resistance → coordination shock → rapid adoption).
- **Identification Concerns**: The 10-year gap in Census data (1940 to 1950) is too blunt to cleanly identify a late-1945 shock, especially if the adoption curve only steepened in the 1950s. You will desperately need high-frequency (annual) proxy data—like Otis Elevator historical sales records or municipal building permits—to prove a sharp trend-break in NYC vs. control cities exactly in 1946.
- **Recommendation**: PURSUE (conditional on: securing annual/high-frequency adoption data to supplement the decadal Census; proving parallel pre-trends between NYC and control cities pre-1945).

**#2: Idea 3: Forty Years of Distrust — A Structural Model of Behavioral Barriers to Technology Adoption**
- **Score**: 62/100
- **Strengths**: Formalizing the behavioral friction into a structural model elevates the theoretical contribution and allows for counterfactual welfare analysis (e.g., "how much surplus was lost to the 40-year delay?"). 
- **Concerns**: Relying on a single, localized historical event (the NYC strike) as a moment condition to identify a macro-level behavioral parameter is empirically fragile. The data requirements (historical building costs, localized wage series) are likely too sparse to support a credible structural estimation without heroic assumptions.
- **Novelty Assessment**: Medium-High. Structural estimations of historical technology adoption exist, but explicitly modeling the *behavioral/trust* friction using a natural experiment is a fresh approach.
- **Top-Journal Potential**: Medium. While top journals appreciate structural models that yield welfare counterfactuals, the empirical foundation here feels too thin. It risks being viewed as a paper where the assumptions do all the heavy lifting.
- **Identification Concerns**: The exclusion restriction is highly suspect; the strike likely impacted wages, union bargaining power, and building regulations, meaning it did not *only* shift consumer trust. 
- **Recommendation**: CONSIDER (as a Section/Appendix within Idea 1, rather than a standalone paper. Use a simplified model to frame the empirical DiD results of Idea 1).

**#3: Idea 2: The Last Operators — Race, Gender, and the Queue for Automation's Casualties**
- **Score**: 55/100
- **Strengths**: Leverages the massive scale of the IPUMS/MLP linked data to provide a highly granular look at the distributional impacts of automation. It connects well to current literatures on the racial and gendered impacts of labor market shocks.
- **Concerns**: This falls squarely into the "competent but not exciting" trap; it is essentially a descriptive heterogeneity exercise without a clear exogenous shock to *who* gets fired. It lacks the mechanism-changing equilibrium effects that top journals demand.
- **Novelty Assessment**: Low-Medium. The specific setting is new, but the "who gets fired first during automation" question is well-trodden territory, and the findings are likely to be unsurprising (marginalized groups suffer first/most).
- **Top-Journal Potential**: Low. As a standalone paper, it reads as an incremental descriptive study. It lacks a "puzzle" or a sharp policy lever, relying instead on diffuse exposure to a slow-moving trend.
- **Identification Concerns**: Without a source of exogenous variation in the *composition* of layoffs, the analysis is purely descriptive. Unobserved confounders (e.g., sorting of minority workers into older, less-capitalized buildings that automate later, or vice versa) will bias any attempt at causal claims.
- **Recommendation**: SKIP (as a standalone paper. Instead, fold this into Idea 1 as the "Worker Outcomes" section to provide the required heterogeneity and welfare deliverables).

**#4: Idea 4: Building Vertical — Skyscrapers, Elevator Operators, and the Geography of Urban Growth**
- **Score**: 38/100
- **Strengths**: Attempts to link labor market technologies to macro-urban form, which is a fundamentally important topic in urban economics.
- **Concerns**: The premise is historically backward and data-poor; elevators enabled skyscrapers in the late 19th/early 20th century, long before the 1940-1950 window where the MLP data shines. Furthermore, building height data for this era is notoriously sparse and difficult to harmonize across cities.
- **Novelty Assessment**: Low. The fact that elevators enabled vertical urban growth is a well-established stylized fact in urban economics (e.g., the work of Jason Barr, Edward Glaeser). 
- **Top-Journal Potential**: Low. It does not challenge conventional wisdom, lacks a clean identification strategy, and suffers from severe data limitations. It would struggle to place even in a mid-tier field journal.
- **Identification Concerns**: The direction of causality is hopelessly confounded. Did elevators cause skyscrapers, or did the demand for dense urban agglomeration drive the adoption of elevators? Cross-city descriptive regressions cannot disentangle this.
- **Recommendation**: SKIP.

### Summary

This batch contains one genuinely excellent, top-tier concept (Idea 1) surrounded by three weaker derivatives. Idea 1 succeeds because it frames a historical event not just as a labor displacement story, but as a solution to a fundamental economic puzzle regarding behavioral barriers to technology adoption—a highly relevant topic for modern AI policy. I strongly recommend pursuing Idea 1 as the core paper, cannibalizing the structural framing of Idea 3 for the theory section, and using the demographic data of Idea 2 to build out a compelling "worker outcomes" back-half of the paper.

---

## Grok 4.1 Fast

**Tokens:** 5272

### Rankings

**#1: Idea 1: Going Up Alone — Automation, Trust, and the Disappearance of the Elevator Operator (PREFERRED)**
- Score: 88/100
- Strengths: Solves a crisp adoption puzzle (40-year delay despite feasibility) with a novel coordination shock (NYC strike), using massive census data and linked panels for a full occupational lifecycle atlas plus causal evidence on behavioral frictions; directly relevant to AI trust debates with a clear causal chain (strike exposure → broken distrust → rapid automation).
- Concerns: Worker outcomes section risks diluting the core adoption puzzle if not subordinated; comparison cities (e.g., Chicago) may have unobserved heterogeneity in building stocks or unionization that weakens the parallel trends test.
- Novelty Assessment: Highly novel—no prior economics papers on elevator operators as a case of full automation or strikes as adoption shocks; distinct from gradual displacement studies like Feigenbaum & Gross (2024).
- Top-Journal Potential: High—a top-5 journal would find this exciting as a puzzle-resolver (behavioral vs. neoclassical adoption) with a mechanism chain (shock → experience → equilibrium shift), new measurement object (operator atlas), and field-pivoting implications for tech frictions, akin to rewarded "energy efficiency gap" reconciliations.
- Identification Concerns: Strike is plausibly exogenous but NYC's outsized operator share (34%) may amplify spillovers to controls; needs strong pre-1940 parallel trends across cities and building-height controls to rule out mechanical urbanization confounds.
- Recommendation: PURSUE (conditional on: prioritizing adoption puzzle over worker tracking; validating parallel trends with 1900-1940 city panels)

**#2: Idea 3: Forty Years of Distrust — A Structural Model of Behavioral Barriers to Technology Adoption**
- Score: 68/100
- Strengths: Builds on Idea 1's shock with structural estimation to quantify behavioral frictions, potentially delivering welfare counterfactuals for tech adoption policy.
- Concerns: Standalone viability low—relies heavily on Idea 1's descriptive groundwork; moment condition from one strike may not identify friction parameters cleanly without rich building/wage dynamics.
- Novelty Assessment: Moderately novel as first structural take on behavioral adoption barriers in this setting, but builds directly on unstudied elevator case rather than introducing a fresh shock or data object.
- Top-Journal Potential: Medium—top field journals might accept if tightly identified and tied to a chain (e.g., friction estimates → AI counterfactuals), but structural models lose to reduced-form puzzles unless they resolve empirical disagreements; risks "competent but not exciting" without Idea 1's atlas.
- Identification Concerns: Single moment condition risks underidentification of multiple parameters (e.g., trust vs. costs); city-level aggregation loses micro-variation and invites omitted variables like differential urbanization.
- Recommendation: CONSIDER (as extension to Idea 1; risky standalone)

**#3: Idea 2: The Last Operators — Race, Gender, and the Queue for Automation's Casualties**
- Score: 62/100
- Strengths: Leverages same rich census data to document inequality in displacement, connecting to active literature on race/gender in labor markets.
- Concerns: Largely descriptive with weak causal ID (conditioning on city × demographics); overlaps heavily with existing inequality studies, lacking a puzzle or shock.
- Novelty Assessment: Low to moderate—racial/gender stratification in declining occupations is well-studied (e.g., Derenoncourt 2022; Collins & Wanamaker 2022); elevator specificity adds color but not a literature pivot.
- Top-Journal Potential: Low—top journals reject "incremental ATEs" on familiar inequality margins without counter-intuitive mechanisms or new objects; fits "competent but not exciting" pattern, better as a section.
- Identification Concerns: No clear exogenous variation—exit timing correlates with demographics mechanically; risks selection bias without linked-panel matching to non-operators.
- Recommendation: CONSIDER (only as subsection in Idea 1)

**#4: Idea 4: Building Vertical — Skyscrapers, Elevator Operators, and the Geography of Urban Growth**
- Score: 48/100
- Strengths: Connects labor (operators) to urban form, using census for cross-city patterns.
- Concerns: Primarily descriptive with sparse data; no strong causal ID or puzzle beyond known elevator-urbanization link.
- Novelty Assessment: Low—skyscrapers and urbanization 1900-1950 well-studied (e.g., Chandler's Visible Hand; multiple papers on elevators and city growth); labor channel incremental at best.
- Top-Journal Potential: Low—no top-5 excitement without causal identification or mechanism chain; reads as niche descriptive work on a saturated topic, far from "puzzle-resolver" or "first-order stakes."
- Identification Concerns: Cross-city variation endogenous to growth (e.g., demand for height drives both operators and buildings); no shock or pre-trends to credibly identify.
- Recommendation: SKIP

### Summary
This is a strong batch anchored by Idea 1, which stands out for its novelty, clean identification, and top-journal appeal via a behavioral adoption puzzle with live AI relevance—genuinely promising at scale. Ideas 2-4 are competent supplements but lack standalone excitement or causality, best folded into Idea 1; pursue that first and skip the rest unless resourced as extensions. Overall quality is high for a policy institute, with potential for 1-2 publishable outputs if executed sharply.

