# Research Idea Ranking

**Generated:** 2026-02-27T20:10:10.470624
**Models:** GPT-5.2, Gemini 3.1 Pro, Grok 4.1 Fast
**Reasoning:** high

## Comparison Table

| Idea | GPT-5.2 | Gemini 3.1 Pro | Grok 4.1 Fast |
|------|------|------|------|
| Minimum Standards or Minimum Supply? MEE... | PURSUE (74) | — | — |
| Do Energy Labels Move Markets? Multi-Cut... | PURSUE (69) | — | — |
| Does Rate Relief Save the High Street? E... | CONSIDER (63) | — | — |
| Building on Borrowed Time: Flood Re Elig... | SKIP (55) | — | — |
| Priced Out of Clean Air? Property Value ... | CONSIDER (44) | — | — |
| Idea 5: Minimum Standards or Minimum Sup... | — | PURSUE (88) | PURSUE (76) |
| Idea 1: Do Energy Labels Move Markets? M... | — | PURSUE (74) | PURSUE (85) |
| Idea 4: Building on Borrowed Time: Flood... | — | CONSIDER (65) | CONSIDER (61) |
| Idea 2: Does Rate Relief Save the High S... | — | SKIP (52) | CONSIDER (68) |
| Idea 3: Priced Out of Clean Air? Propert... | — | SKIP (35) | SKIP (54) |

---

## GPT-5.2

**Tokens:** 7247

### Rankings

**#1: Minimum Standards or Minimum Supply? MEES Regulation and the Rental Housing Market**
- Score: 74/100
- Strengths: Combines a crisp compliance threshold (E/F at 39) with policy timing (2018/2020) and credible placebos (owner-occupied at same cutoff), and it directly targets the key “puzzle” left by existing MEES rent results: if rents didn’t move, where did adjustment occur (supply vs upgrading vs exit)? The design naturally supports a mechanism chain (MEES → upgrades/bunching/exemptions → rental supply/landlord exit → sale prices), which is the kind of packaging editors reward.
- Concerns: The hardest practical issue is correctly defining “rental properties” at the time outcomes are measured—EPC tenure fields and Land Registry sales don’t perfectly reveal landlord status, so misclassification could attenuate effects. Supply measurement may require nontrivial additional data (lettings listings, EPC lodgement purpose, or local authority licensing) to avoid “proxy endogeneity.”
- Novelty Assessment: **Moderately studied policy, but under-studied margins.** MEES has a growing literature (incl. at least one RDD/DiD on rents), but the supply/exit/upgrading channels and sale-price capitalization are still comparatively open and could meaningfully change interpretation of prior nulls.
- Top-Journal Potential: **Medium.** Not inherently a top-5 topic, but it can become top-field (AEJ:EP / JPubE / JUE) if framed as resolving a live policy puzzle with a full adjustment accounting (prices *and* quantities *and* investment), plus tight falsification tests.
- Identification Concerns: Main threats are manipulation/sorting around 39 via reassessments and selective transaction timing; these are partly “effects” but can still break standard RDD assumptions for sale-price capitalization unless modeled as an endogenous first stage (e.g., treat “achieving E” as the object). Needs strong density/bunching diagnostics and a clear timing design (pre vs post) with stable measurement.
- Recommendation: **PURSUE (conditional on: a defensible rental-status definition; a pre-specified supply measure that is not mechanically driven by EPC re-lodgements; RDD manipulation/bunching handled explicitly as part of the mechanism rather than ignored).**

---

**#2: Do Energy Labels Move Markets? Multi-Cutoff RDD Evidence from English Property Transactions**
- Score: 69/100
- Strengths: The multi-cutoff structure is genuinely useful: it allows internal comparison across label boundaries and the special E/F boundary where regulation is layered on information—this is a clean way to separate “label salience” from “legal constraint.” The 2021–2023 energy price shock adds a high-salience test that could strengthen the interpretation (information capitalization should rise when energy costs matter more).
- Concerns: There is a sizeable existing EPC capitalization literature in Europe/UK using hedonic/DiD, so the paper must avoid reading as “same question, nicer design.” Address matching and repeated EPCs per property can introduce non-classical measurement error in the running variable and treatment assignment near thresholds.
- Novelty Assessment: **Somewhat studied question, fresher design.** “Do EPC labels affect prices?” is well-trodden; “multi-cutoff decomposition of regulation vs information + salience shock in UK using admin universe” is much less common.
- Top-Journal Potential: **Medium-Low.** Strong chance at top field (AEJ:EP / JUE) if the decomposition is sharp and the crisis-salience interaction is theory-forward; top-5 is unlikely unless it substantially revises how economists think labels vs mandates operate in housing markets.
- Identification Concerns: Requires convincing evidence of limited manipulation (or a clear interpretation if manipulation exists), stable covariates across thresholds, and careful handling of heaping/rounding in EPC scores. Multi-cutoff comparisons also need harmonized bandwidth/functional form choices to avoid “researcher degrees of freedom.”
- Recommendation: **CONSIDER (upgrade to PURSUE if: manipulation tests look good across cutoffs; you pre-register cutoff-by-cutoff specs and a clear decomposition estimand).**

---

**#3: Does Rate Relief Save the High Street? Evidence from the £12,000 Threshold**
- Score: 63/100
- Strengths: The policy notch is economically large and legible (a real tax cliff), and the 2017 threshold expansion adds an extra time dimension that can strengthen credibility and interpretation. If the address link works, you can speak directly to a first-order policy debate (whether rate relief preserves small businesses or just reshuffles occupancy).
- Concerns: The key feasibility/validity risk is the linkage and outcome definition: Companies House registration address is not reliably the trading location, and incorporations/dissolutions are noisy proxies for local business activity (many small retailers are sole traders and won’t appear cleanly). There is also real risk of valuation sorting/bunching around £12k through appeals or assessment practices, which can be non-random.
- Novelty Assessment: **Moderate.** Business rates and SBRR have been studied, and RDD around thresholds exists in grey literature/working papers; the “firm outcomes (survival/employment) not occupancy” angle is meaningfully less explored but not wholly untouched.
- Top-Journal Potential: **Medium-Low.** This is policy-relevant and could hit AEJ:EP/JPubE if the measurement is convincing and results are not obvious; top-5 is unlikely unless it uncovers strong general-equilibrium effects (e.g., displacement across nearby streets, wage effects, or dynamic selection) with clear welfare implications.
- Identification Concerns: Density/bunching at the threshold is a first-order threat; even if valuations are “independent,” appeals and revaluations can induce sorting. Also, the taper region (12–15k) complicates “sharp” treatment unless you restrict tightly or use a kink/notch design explicitly.
- Recommendation: **CONSIDER (conditional on: validating trading-location measures—e.g., business register/VAT/PAYE or local vacancy datasets; and demonstrating limited sorting at £12k or re-framing as a manipulation-inclusive estimand).**

---

**#4: Building on Borrowed Time: Flood Re Eligibility and Property Values**
- Score: 55/100
- Strengths: The eligibility rule is unusually sharp and nationally defined, and the question (insurance access capitalized into house prices/liquidity in flood zones) is both policy-relevant and comparatively under-identified in UK settings. If executed well, it isolates an “insurance market design” channel distinct from physical flood risk.
- Concerns: The running variable is problematic: Land Registry gives transaction dates, not true construction completion dates, and “first sale date” can be delayed by market conditions—creating non-classical measurement error exactly around the cutoff. The cutoff sits near the financial crisis period, raising concerns that timing of completions/sales around 2009 may reflect macro disruptions rather than the insurance rule.
- Novelty Assessment: **High.** Flood Re’s 2009 build-date exclusion is not a standard object in the empirical literature, and UK flood-insurance causal work is far thinner than US NFIP work.
- Top-Journal Potential: **Medium (if identification holds), otherwise Low.** A clean design would be attractive to top field journals because it speaks to climate adaptation and insurance design; but editors will be unforgiving if “construction date” is not measured cleanly.
- Identification Concerns: Potential manipulation (developers timing completion/registration), outcome discontinuities driven by crisis-era shifts in new-build quality/location, and mismeasurement of the forcing variable are all serious RDD threats. You likely need external build-completion records (planning/building control, EPC first-lodgement dates, or Valuation Office/property attributes) to make this credible.
- Recommendation: **SKIP unless** you can obtain a high-quality construction/completion date measure (or a robust alternative design such as difference-in-discontinuities using non-flood zones as a control, plus strong validation that “first sale date ≈ completion date” tightly around the cutoff).

---

**#5: Priced Out of Clean Air? Property Value Effects of London's ULEZ Boundary**
- Score: 44/100
- Strengths: The policy is salient, the boundary is clear, and the question is understandable to policymakers (do environmental driving charges affect household wealth via housing markets?). If you could credibly link to air quality improvements, the welfare narrative is potentially strong.
- Concerns: Spatial RDD at a boundary that is literally major arterial roads (North/South Circular) is a classic “pre-existing barrier” problem: noise, traffic, neighborhood sorting, and amenities can jump at the road irrespective of ULEZ, making the design fragile. The treatment is also partial—many households don’t drive non-compliant vehicles—so the “first stage” in behavior/cost exposure may be weak without vehicle ownership/compliance data.
- Novelty Assessment: **Moderate-Low.** There is a large literature on congestion pricing/LEZ/ULEZ-type policies (especially air quality and sometimes economic activity); “property price spatial discontinuity” is less saturated but not so novel that it offsets the identification fragility.
- Top-Journal Potential: **Low.** Unless you can (i) convincingly neutralize boundary confounding and (ii) show a clear causal chain through measured air quality and driving-cost exposure, this will likely be viewed as a fragile border design on a well-studied policy family.
- Identification Concerns: Discontinuities driven by the road itself; differential pre-trends across the boundary; compositional differences in housing stock; and endogenous avoidance behavior/traffic re-routing that breaks the local comparability premise.
- Recommendation: **SKIP** (or only **CONSIDER** if you can redesign using stronger quasi-experimental variation—e.g., instrumented exposure using pre-policy vehicle fleet composition by small area, or exploiting phased implementation components not aligned with major roads).

---

### Summary

This is a strong batch in terms of “crisp policy margins + admin data,” but only two ideas (MEES supply/upgrading and multi-cutoff EPC labeling) have a clear path to both credible identification and an editor-friendly mechanism narrative. I would start with **Idea 5** (best chance to resolve a live policy puzzle with a full adjustment accounting) and keep **Idea 1** as the close second (excellent design if manipulation and matching issues are handled tightly).

---

## Gemini 3.1 Pro

**Tokens:** 8670

Here is my evaluation of the research proposals, ranked from most to least promising. As requested, I have applied a highly critical lens, grounding my assessments in the empirical realities of top-tier economics publishing and causal inference standards.

### Rankings

**#1: Idea 5: Minimum Standards or Minimum Supply? MEES Regulation and the Rental Housing Market**
- **Score**: 88/100
- **Strengths**: This proposal brilliantly pivots a standard policy evaluation into a mechanism-driven puzzle resolver. By investigating the quantity (supply) and investment (upgrading) margins to explain a recent null result on rents, it constructs a compelling, falsifiable causal chain. 
- **Concerns**: The primary risk is data quality in the EPC register's "tenure" field, which is self-reported at the time of assessment and may not perfectly track dynamic shifts between rental and owner-occupied status over time.
- **Novelty Assessment**: High. While MEES has been studied, the specific focus on supply withdrawal vs. compliance upgrading—and using owner-occupiers as a placebo group in a triple-difference RDD framework—is highly novel and addresses a glaring gap in the climate-housing literature.
- **Top-Journal Potential**: High. This perfectly matches the "puzzle-resolvers beat incremental ATEs" pattern from the Appendix. It takes a first-order policy question (climate retrofits) and uses a sharp, multi-layered design (RDD + DiD + DDD) to reveal equilibrium market adjustments. A top-5 or *AEJ: Policy* would find the mechanism decomposition highly attractive.
- **Identification Concerns**: The traditional RDD McCrary density test will almost certainly "fail" here because landlords will manipulate their score to exactly 39 to comply. However, in this specific design, *the bunching is the treatment effect* (compliance upgrading). The authors must use bunching estimators (a la Kleven) rather than standard RDD to quantify this margin.
- **Recommendation**: PURSUE

**#2: Idea 1: Do Energy Labels Move Markets? Multi-Cutoff RDD Evidence from English Property Transactions**
- **Score**: 74/100
- **Strengths**: The multi-cutoff decomposition to isolate regulatory vs. informational effects is an elegant, structural-feeling approach to a reduced-form design. Layering the 2021-2023 energy crisis as an exogenous shock to cost salience adds excellent temporal variation.
- **Concerns**: EPC scores are generated by assessors who are heavily incentivized by homeowners to push properties just over the band thresholds (e.g., from 68 to 69 to get a C). This manipulation threatens the continuity assumption of the RDD.
- **Novelty Assessment**: Moderate-High. The UK EPC capitalization literature is saturated with hedonic and DiD papers, but the multi-cutoff RDD decomposition of regulation vs. information is a fresh, rigorous upgrade.
- **Top-Journal Potential**: Medium. It risks falling into the "technically competent but not exciting" bucket if it only delivers an ATE of energy labels. To hit a top journal, the energy crisis amplification mechanism must be the star of the paper, proving how macro-shocks alter the capitalization of micro-labels.
- **Identification Concerns**: Severe risk of precise manipulation at the running variable thresholds. If unobservable property investments (e.g., new boilers) are made specifically to cross the threshold, the RDD estimates the return on those investments, not just the label/regulatory effect.
- **Recommendation**: PURSUE (conditional on: passing McCrary density tests at the informational thresholds, or using a "donut RDD" to exclude manipulated observations).

**#3: Idea 4: Building on Borrowed Time: Flood Re Eligibility and Property Values**
- **Score**: 65/100
- **Strengths**: Using a strict construction date cutoff to isolate insurance access from physical flood risk is a highly creative identification strategy. It addresses a major confounding problem in the climate finance literature.
- **Concerns**: The January 1, 2009 cutoff coincides exactly with the depths of the Global Financial Crisis, meaning properties built just before vs. just after may differ radically in unobservable quality, builder survival, and financing.
- **Novelty Assessment**: High. The UK flood insurance literature is mostly aggregate or descriptive; applying a sharp date-based RDD to Flood Re eligibility is an unexploited and clever angle.
- **Top-Journal Potential**: Medium. Climate risk capitalization is a hot topic (as noted in the Appendix regarding "flood-map failures"), but the paper would need to deliver a broader welfare or counterfactual deliverable about public insurance provision to break into the Top 5.
- **Identification Concerns**: Beyond the GFC macro-shock, "first transaction date" is a noisy proxy for construction completion. The authors must use a DiD-RDD approach—comparing the 2009 discontinuity *inside* flood zones to the same discontinuity *outside* flood zones—to difference out the GFC construction shock.
- **Recommendation**: CONSIDER (conditional on: implementing a spatial placebo to control for the 2008/2009 housing market crash).

**#4: Idea 2: Does Rate Relief Save the High Street? Evidence from the £12,000 Threshold**
- **Score**: 52/100
- **Strengths**: The policy creates a massive, undeniable cost cliff (£0 vs ~£6,000), ensuring a very strong first stage. 
- **Concerns**: Linking VOA property data to Companies House data via address is notoriously messy; many small businesses use their accountant's address or a virtual office as their registered address, destroying the spatial link to the rateable property.
- **Novelty Assessment**: Low-Moderate. While the specific UK business outcomes haven't been exhaustively studied via this threshold, the "small business tax threshold" literature is incredibly crowded globally (e.g., the French 50-employee threshold).
- **Top-Journal Potential**: Low. This is the textbook definition of the Appendix's #1 losing pattern: "standard DiD/RDD on a familiar policy margin + unsurprising/localized effect." It lacks a counter-intuitive mechanism or a new measurement object.
- **Identification Concerns**: Rateable values are highly manipulated. Businesses aggressively appeal their valuations specifically to get under the £12,000 threshold. This endogenous sorting will almost certainly invalidate the RDD design.
- **Recommendation**: SKIP

**#5: Idea 3: Priced Out of Clean Air? Property Value Effects of London's ULEZ Boundary**
- **Score**: 35/100
- **Strengths**: High policy relevance, as ULEZ and similar low-emission zones are highly controversial and politically salient.
- **Concerns**: The identification strategy is fatally flawed by geographic reality, and the capitalization of air quality is a very old, well-trodden literature.
- **Novelty Assessment**: Low. ULEZ has been studied exhaustively across health, transport, and political domains. Property value capitalization of air quality is standard environmental economics.
- **Top-Journal Potential**: Low. Top journals demand pristine identification for spatial RDDs, and this design fails the most basic geographic exogeneity tests.
- **Identification Concerns**: Fatal flaw. The inner ULEZ boundary is the North/South Circular—a massive, highly congested, heavily polluting multi-lane highway. As explicitly warned in the Appendix ("A86 motorway-style borders repeatedly criticized as 'pre-existing barrier' confounds"), properties just inside vs. just outside this boundary are separated by a massive pre-existing barrier that dictates neighborhood sorting, noise, and local amenities. Covariate balance will fail.
- **Recommendation**: SKIP

### Summary

This is a mixed batch, but the top idea is exceptionally strong. **Idea 5 (MEES Supply/Investment)** is a standout proposal that perfectly aligns with top-journal preferences for puzzle-solving, mechanism-tracing, and exploiting multiple layers of variation (RDD+DiD+DDD); it should be your institute's top priority. **Idea 1** and **Idea 4** are solid, publishable field-journal papers if their respective identification threats (bunching and GFC confounding) can be mitigated, while Ideas 2 and 3 suffer from fatal identification flaws and a lack of scientific novelty.

---

## Grok 4.1 Fast

**Tokens:** 6255

### Rankings

**#1: Idea 1: Do Energy Labels Move Markets? Multi-Cutoff RDD Evidence from English Property Transactions**
- **Score**: 85/100
- **Strengths**: Exceptional novelty through UK-specific multi-cutoff RDD decomposing regulatory vs. informational effects at EPC boundaries, plus unstudied energy crisis interaction; clean causal chain (label/reg → price capitalization → amplified by salience) with massive linked data enabling precise inference and heterogeneity.
- **Concerns**: Assessor bunching at boundaries (noted in European EPC studies) could invalidate RDD if severe; requires robust McCrary and covariate tests across multiple cutoffs.
- **Novelty Assessment**: Highly novel—no UK EPC band RDD exists (Dutch only), decomposition entirely new, crisis channel unstudied in UK RDD context.
- **Top-Journal Potential**: High—fits editorial winners as mechanism-changing decomposition (info vs. reg effects) on live energy policy frontier with counter-intuitive salience amplification; packages as causal chain with welfare implications for labeling standards, likely AER/QJE exciting.
- **Identification Concerns**: Multi-cutoff strengthens exogeneity by differencing effects across boundaries, but needs pre-crisis parallel trends and sufficient bandwidth per cutoff for power; MEES regulatory bite at 39 confirmed but first-stage verification essential.
- **Recommendation**: PURSUE (conditional on: strong McCrary across cutoffs; pre-specify crisis interaction in pre-analysis plan)

**#2: Idea 5: Minimum Standards or Minimum Supply? MEES Regulation and the Rental Housing Market**
- **Score**: 76/100
- **Strengths**: Clever puzzle-resolver building on recent null rent paper by tracing adjustment margins (supply withdrawal, upgrading, sales) via RDD+DiD with owner-occupied placebo; high feasibility with tenure-linked EPC data.
- **Concerns**: Overlaps with Idea 1 at EPC 39 cutoff, risking redundant effort; post-regulation bunching could reflect treatment (compliance) but complicates clean RDD interpretation without careful bunching analysis.
- **Novelty Assessment**: Moderately novel—extends 2025 Energy Policy paper's nulls to new outcomes/margins, but EPC RDD basics now emerging; supply/upgrading channels unstudied.
- **Top-Journal Potential**: High—resolves "where's the effect?" puzzle via mechanism chain (regulation → supply/investment adjustment), with policy deliverable on landlord responses; top field journal (AEJ:EP) strong, top-5 possible if heterogeneity maps to exemption costs.
- **Identification Concerns**: Strong placebo (owner-occupied) and DiD timing control threats well, but needs pre-MEES parallel trends at 39 and multiple-testing correction across outcomes.
- **Recommendation**: PURSUE (conditional on: differentiation from Idea 1 via rental-specific supply data; RW multiple-testing)

**#3: Idea 2: Does Rate Relief Save the High Street? Evidence from the £12,000 Threshold**
- **Score**: 68/100
- **Strengths**: Novel shift to firm outcomes (survival, employment) beyond prior occupancy focus, with massive tax cliff and 2017 threshold change for temporal robustness; links public VOA/Companies House data feasibly.
- **Concerns**: Address matching for firm-property linkage may introduce noise/attenuation; policy relevance high but effect size may be small/localized without broader generalizability.
- **Novelty Assessment**: Solidly novel—no business-level SBRR studies, prior Oxford WP only on properties.
- **Top-Journal Potential**: Medium—challenges "relief boosts occupancy but not firms?" conventional wisdom with causal chain to high-street vitality, but lacks counter-intuitive twist or scale for top-5; AEJ:Applied strong.
- **Identification Concerns**: Bunching/appeals at £12k threshold likely (VOA independent but manipulable), requiring McCrary/RKD; firm-level outcomes need address precision to avoid aggregation bias.
- **Recommendation**: CONSIDER

**#4: Idea 4: Building on Borrowed Time: Flood Re Eligibility and Property Values**
- **Score**: 61/100
- **Strengths**: Unique national construction-date cutoff isolates insurance access in flood zones, addressing climate adaptation policy with transaction volume secondary outcomes.
- **Concerns**: Construction date proxied by first-sale (months off), risking misclassification; strategic builder timing around 2009 cutoff probable, contaminating RDD.
- **Novelty Assessment**: Novel—no Flood Re RDD, distinct from US NFIP aggregates.
- **Top-Journal Potential**: Medium—first-order climate policy stakes, but standalone ATE on capitalization without mechanism chain or lit pivot feels incremental; field journal viable if null rules out large effects.
- **Identification Concerns**: Bunching test critical for strategic completion; within-flood-zone focus helps but pre-2009 trends may differ systematically by era/build quality.
- **Recommendation**: CONSIDER (conditional on: bunching analysis showing no manipulation; sensitivity to date proxy)

**#5: Idea 3: Priced Out of Clean Air? Property Value Effects of London's ULEZ Boundary**
- **Score**: 54/100
- **Strengths**: Timely air quality capitalization with clean spatial boundary and pre-expansion placebo.
- **Concerns**: Boundary is major road (A406), creating classic pre-existing confounds (noise, congestion, socioeconomics); spatial RDD often fails covariate balance per editorial patterns.
- **Novelty Assessment**: Moderately novel—no ULEZ capitalization study, but spatial air policy RDDs common elsewhere.
- **Top-Journal Potential**: Low—technically competent capitalization ATE but unsurprising/localized without mechanism or puzzle-resolution; boundary flaws echo "A86 motorway" rejections, unlikely top-5/field excitement.
- **Identification Concerns**: High risk of imbalance (road as barrier), needing extensive covariate/density tests; post-2021 power limited without wide bandwidth.
- **Recommendation**: SKIP

### Summary
This is a strong batch overall, with two genuinely promising ideas (1 and 5) leveraging EPC data for novel mechanism decompositions on energy policy frontiers—far above average for policy evals. Pursue Idea 1 first for its multi-cutoff innovation and top-journal upside, then Idea 5 as a complementary puzzle-solver; the rest are competent but hampered by identification risks or excitement gaps typical of "good but not field-changing" proposals.

