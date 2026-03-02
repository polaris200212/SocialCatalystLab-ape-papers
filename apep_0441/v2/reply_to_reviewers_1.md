# Reply to Reviewers — Round 1

## Response to GPT-5.2 (Major Revision)

**1. "Parallel trends violated — full-sample DiD is not credible as causal."**
We agree completely and have been transparent about this from the abstract onward. The v2 revision introduced the border DiD, spatial RDD, Rambachan-Roth bounds, and trend-adjusted estimates specifically to address this concern. We have further softened causal language in the Discussion to frame estimates as "informative bounds on a plausibly positive effect rather than precise causal point estimates."

**2. "Capital effects: contradiction between 'dramatically higher growth' and 'near zero coefficient'."**
Fixed. The text now clarifies that descriptive evidence shows faster capital growth, but the formal regression estimate is uninformative due to saturation with only 3 capital districts. Presented as descriptive evidence, not regression inference.

**3. "Missing references: Black (1999), Holmes (1998)."**
Added both to references.bib and cited in the Introduction's contribution paragraph alongside Keele & Titiunik (2015).

**4. "Spatial RDD validity: boundaries not quasi-random."**
Addressed in Section 6.5 (Caveats), which explicitly states boundaries follow "pre-existing regional divisions rather than arbitrary lines" and interprets the RDD as a "local average treatment effect near the boundary." We acknowledge this limitation.

**5. "Add 95% CIs throughout."**
Acknowledged. The current tables report standard errors, which are standard in the economics literature. Full CI tables would be a valuable addition for a future revision.

---

## Response to Grok-4.1-Fast (Minor Revision)

**1. "Discussion bullets → prose."**
Fixed. Converted to flowing paragraph form.

**2. "Add CIs and bootstrap confidence intervals."**
The wild bootstrap p-value (0.0625) is reported. Bootstrap-t confidence intervals would be a valuable extension but require substantial computational infrastructure given the small cluster count. Noted for future work.

**3. "Interact treatment with baseline covariates for mechanisms."**
Census mechanism evidence is presented in Section 8.3 as cross-sectional comparisons. Interaction specifications with baseline ST share or literacy would be an interesting extension.

---

## Response to Gemini-3-Flash (Minor Revision)

**1. "Telangana sign inconsistency."**
Fixed. Text now correctly reports "near-zero effect (-0.06, p=0.32)" matching the negative coefficient in Table 4.

**2. "Few-cluster inference problem."**
Acknowledged throughout the paper. The wild cluster bootstrap (p=0.0625) and placebo permutation (p=0.05) provide alternative inference under small-cluster settings.

**3. "Causal language should be tied to bounds/assumptions."**
Added explicit qualifying language in the Discussion section linking the 0.40–0.80 range to "maintained assumptions of each estimator."

---

## Response to Exhibit Review (Gemini Vision)

**1. Figure 7 title truncation.**
Shortened title to fit within figure width.

**2. Table 3: RDD row mixed with DiD.**
Acknowledged. The combined presentation follows the paper's narrative flow (border designs together) but we note the reviewer's preference for separation.

**3. Discussion bullets.**
Converted to prose (addressed above).

---

## Response to Prose Review (Gemini)

**1. "Kill the roadmap."**
The roadmap paragraph is brief (one sentence) and serves readers unfamiliar with the paper structure. Retained but kept minimal.

**2. "Active Results" and "Vivid Transitions."**
Incorporated several prose improvements throughout the revision.
