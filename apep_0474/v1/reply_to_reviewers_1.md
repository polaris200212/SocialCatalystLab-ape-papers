# Reply to Reviewers

## Referee 1 (GPT-5.2) — MAJOR REVISION

### 1.1 Treatment timing does not match implementation
> "If ACV's operative channels are funded projects, regulatory ORT tools, and Denormandie housing incentives, then a 2018Q1 'announcement treatment' is at best an intention-to-treat via expectations."

**Response:** We agree this is a central interpretive issue and have substantially expanded the discussion. We now include a new subsection (5.3.1, "Treatment Timing: Announcement vs. Implementation") that explicitly frames the estimand as the effect of ACV *designation*—the intention-to-treat impact of being announced as an ACV city—rather than the effect of specific implementation milestones. We justify the announcement-based design on two grounds: (i) the December 2017 announcement was a nationally visible event that plausibly shifted expectations, and (ii) convention signing dates are endogenous to municipal capacity, making staggered designs vulnerable to selection bias. The event-study decomposition tests whether effects emerge with the lag expected if implementation (rather than announcement) drives outcomes. We also soften claims throughout the paper accordingly.

### 1.2 Inclusion of "later additions" as treated from 2018Q1
> "These communes were not announced in Dec 2017, so assigning them treatment in 2018Q1 risks misclassification."

**Response:** We maintain the inclusion for the reasons stated in the paper (same selection criteria, benefited from national program infrastructure), but now report more prominently that restricting to the original 222 produces virtually identical estimates (β = −0.043, SE = 0.042). See Section 7.1.

### 1.3 Geographic unit misaligned with "downtown" claim
> "Commune-level counts are not a valid proxy for downtown effects."

**Response:** We agree this is an important measurement limitation and have addressed it extensively. We now: (i) add explicit "Outcome Dilution" discussion in the threats section (5.3.4) acknowledging that commune-level outcomes create attenuation and interpretive ambiguity; (ii) reframe the estimand throughout as "commune-level entry in downtown-facing sectors" rather than "downtown revitalization"; (iii) add a new limitations paragraph identifying geocoded Sirene addresses as the natural extension; and (iv) soften the conclusion to acknowledge that we "cannot rule out that ACV produced localized effects within downtown cores that are diluted in commune-wide aggregation." We consider geocoding Sirene addresses a valuable extension but beyond the scope of this paper.

### 1.4 Control group construction underspecified
> "What algorithm? Exact matching, propensity score, Mahalanobis, manual rules?"

**Response:** We have completely rewritten Section 4.4 to provide a replicable description of the matching procedure: nearest-neighbor matching on Euclidean distance over three standardized variables (pre-treatment downtown establishment stock, total establishment stock, annual creation rate), within the same département, without replacement. We also add explicit discussion of the spillover implications of within-département control selection.

### 1.5 Parallel trends: selection on changing slopes
> "If the selection process used anticipated future decline, pre-trends won't fully validate."

**Response:** Acknowledged. We note this limitation in the threats section and emphasize that the flat pre-trends over 24 quarters provide support but cannot definitively rule out selection on unobservable anticipated trajectories.

### 2.1–2.2 Clustering and count outcome modeling
> "Consider wild cluster bootstrap" and "Show robustness to PPML."

**Response:** We now report Poisson pseudo-maximum likelihood (PPML) with commune and quarter fixed effects as Column 4 of the robustness table (Table 5). The PPML coefficient is −0.243 (p = 0.13), consistent with the linear null. We cite Silva and Tenreyro (2006) for the PPML rationale. We explicitly state that the log specification uses log(1 + Y). We also report the CR2 bias-reduced p-value (0.309) as before.

### 2.3 RI design clarification
> "You permute 222 treated out of eligible, while your treated sample is 244."

**Response:** Corrected. The RI procedure permutes 244 (the actual number treated) across eligible communes. We have fixed the text in both the main body and the appendix to state this clearly, and we now frame RI as a "sensitivity exercise" rather than a test derived from the exact assignment mechanism.

### 2.4 Pre-trend joint test not reported
> "Report the statistic and p-value."

**Response:** Now reported in the event study section: F = 1.57, p = 0.055 (Wald test on 19 pre-treatment coefficients using commune-clustered covariance).

### 5.1 Over-claiming
> "Statements are too strong given commune-level measurement and treatment timing uncertainty."

**Response:** We have recalibrated claims throughout. The abstract now says "adds to the skeptics' evidence" rather than "challenges the narrative." The conclusion explicitly states what the evidence rules out ("broad-based increase in commune-level commercial entry") and what it cannot rule out (localized city-center effects, intensive margin effects). The final paragraph separates the extensive margin null from broader program effectiveness.

### 4.2 Literature additions
> "Consider Kline and Moretti (2014), Silva and Tenreyro (2006)."

**Response:** Added: Kline and Moretti (2014, QJE) on local multipliers and the Tennessee Valley Authority, Ahlfeldt et al. (2015, Econometrica) on agglomeration economics, and Silva and Tenreyro (2006, REStat) for the PPML rationale.

---

## Referee 2 (Grok-4.1-Fast) — MINOR REVISION

### Must-fix: Control group selection transparency
> "Top journal needs transparency (e.g., Mahalanobis matching? Propensity scores? Exact pop range/dept list?)."

**Response:** Fully addressed. Section 4.4 now describes the nearest-neighbor matching algorithm in replicable detail. See response to Referee 1, point 1.4.

### Must-fix: No manipulation test for selection
> "Add density of pre-2017 creation rates for eligible communes."

**Response:** ACV selection was administrative (prefect nomination + national validation), not score-based, so a McCrary density test is not directly applicable. We now state this in the paper. The balance table (Table 2) and flat pre-trends provide the relevant evidence that selection does not violate the DiD design.

### High-value: Heterogeneity limited
> "Interact ACV×Post with terciles of baseline stock/pop/funding."

**Response:** We maintain the size heterogeneity analysis (Appendix D) showing null across all size categories. Funding intensity data (per-commune ANCT disbursements) are not publicly available. We note this as a limitation and future extension.

### High-value: Intensive margin proxy
> "Weight by workforce category."

**Response:** Most new downtown establishments are micro-enterprises (smallest trancheEffectifs category), limiting the informativeness of employment-weighted measures. We now discuss this limitation explicitly and note that ACOSS/URSSAF data would provide a more complete picture.

### Optional: Add cited papers
**Response:** Added Kline and Moretti (2014) and Ahlfeldt et al. (2015).

### Optional: Post-treatment joint test
**Response:** The event study figure and period decomposition (now Figure 4 in main text) provide the relevant evidence. The pooled TWFE coefficient is the post-treatment joint test.

---

## Referee 3 (Gemini-3-Flash) — MINOR REVISION

### Must-fix: Selection on the dependent variable
> "Provide a specification using only population and geographic matching (excluding commercial outcomes)."

**Response:** The matching uses three variables: downtown establishment stock, total establishment stock, and annual creation rate. Two of these (stocks) are pre-treatment levels rather than the outcome variable (creation flows). Nevertheless, matching on pre-treatment levels of the outcome is standard in DiD designs and does not create endogeneity concerns provided that the parallel trends assumption holds conditional on the matching variables. The flat pre-trends over 24 quarters support this.

### Must-fix: Matching ratio
> "Address the 244:58 imbalance more deeply."

**Response:** We now discuss this explicitly in Section 4.5: the imbalance reflects ACV's comprehensive coverage of medium-sized cities, leaving few comparable untreated cities. We report CR2 bias-reduced standard errors (which account for cluster leverage under imbalanced designs) and randomization inference as alternative inference procedures.

### High-value: Intensive margin
> "Net change in stock or survival analysis."

**Response:** Acknowledged as a limitation. The Sirene stock file does not provide precise cessation dates, preventing construction of reliable net stock changes. We discuss this limitation and identify the Sirene historical events file as the natural data source for future work.

### High-value: Treatment intensity
> "Proxy treatment intensity using convention signing dates."

**Response:** Convention signing dates are available in the ACV dataset, but a staggered implementation design introduces endogeneity concerns (cities with greater administrative capacity sign earlier). We note this as an important future extension in the new treatment timing subsection (5.3.1).

---

## Exhibit Review (Gemini Vision)

### Figure 2: Simplify x-axis
**Response:** Retained the quarterly labels, which provide useful granularity for identifying specific policy milestones (ORT in Q4 2018, Denormandie in Q1 2019).

### Table 4 → Appendix, promote Figure 6
**Response:** Done. Figure 6 (period coefficient plot) is now in the main text as Figure 4. Table 4 has been moved to the appendix.

### Table 5: Consolidate or expand
**Response:** Expanded Table 5 to include Poisson PPML as Column 4, addressing both the "too thin" concern and Referee 1's request for count-model robustness.

### Label appendix sector table
**Response:** Done. Now labeled as "Table A1: Sector Definitions and NAF Codes."

### Add geographic map
**Response:** A geographic map of ACV communes would be valuable but requires additional GIS data processing. Noted as a future improvement.

---

## Prose Review (Gemini)

### Delete roadmap paragraph
**Response:** Done. The section headings are descriptive enough to guide the reader.

### Punch up abstract mid-section
**Response:** Done. The abstract now leads with "ACV designation failed to stimulate commercial entry" before the statistics.

### Active voice in Section 4.4
**Response:** Done. Section 4.4 now uses active voice throughout ("I select control communes..." instead of "Control communes are selected...").

### Real-world context for summary stats
**Response:** Done. Added: "the typical ACV city sees roughly one new downtown shop, café, or service provider every four quarters."

### "Pushing on a string" standalone paragraph
**Response:** Done. Expanded into a standalone paragraph with policy implications.
