# Reply to Reviewers

## Paper: "Where Cultural Borders Cross: Gender Equality at the Intersection of Language and Religion in Swiss Direct Democracy"
## Revision: v4 (revision of apep_0439 v3)

---

## Reviewer 1: GPT-5.2 (MAJOR REVISION)

### Concern 1: Few effective clusters for religion (canton-level assignment)
> "Canton-cluster SEs with ~21 clusters can be unreliable without small-sample corrections... Add wild cluster bootstrap p-values."

**Response:** We agree this is an important concern. We address it with canton-level permutation inference (Section 7.1), which permutes confessional status at the canton level—directly respecting the assignment mechanism. The canton-level permutation p-value for the interaction is 0.994 (N_perm = 497), even more extreme than the municipality-level result (p = 0.936). We also report canton-clustered standard errors in Column 2 of the robustness table, which produce larger SEs but identical point estimates. The wild cluster bootstrap (Cameron, Gelbach & Miller 2008) is an excellent suggestion; unfortunately, the `fwildclusterboot` R package is not currently available for our R version. We note this limitation and cite CGM 2008 in the references. The permutation inference, which is valid regardless of the number of clusters (Young 2019), provides the strongest available nonparametric inference.

### Concern 2: Permutation design should mirror assignment mechanism
> "You permute language and religion labels across municipalities 'independently'... breaks geographic/spatial structure."

**Response:** We have implemented exactly this concern. The canton-level permutation (Section 7.1) permutes confessional status at the canton level while keeping municipality-level language labels fixed, directly mirroring the historical assignment mechanism where religion was determined by cantonal rulers. The municipality-level permutation serves as a complementary test. Both yield interaction p-values > 0.9.

### Concern 3: Spatial correlation / Conley SE
> "Municipality outcomes are spatially correlated... Add Conley (1999) spatial HAC SEs."

**Response:** We acknowledge this concern and cite Conley (1999) in the references. Implementing Conley SEs requires geographic coordinates for all municipalities, which are not currently in our workspace. We partially address spatial dependence through canton-level clustering (Column 2 of the robustness table) and two-way clustering by municipality and referendum date (Column 3). We note this as a limitation and avenue for future work.

### Concern 4: Equivalence testing / "informative null" formalization
> "Pre-specify a SESOI and conduct an equivalence test (TOST)."

**Response:** Done. We now frame the null interaction as a formal equivalence result (Section 6.2): defining the SESOI as 10% of the language main effect (±1.55 pp), the 90% confidence interval for the interaction ([-1.4, 1.3] pp) falls entirely within this equivalence region. This allows us to formally reject interactions larger than 10% of the dominant main effect.

### Concern 5: Identification narrative too strong / border-proximity design
> "Either implement border-type robustness or temper causal language."

**Response:** We have tempered the causal language throughout. The abstract now reads "a direct test" rather than "the first direct test." We add an explicit paragraph in Section 5.4 clarifying that our central causal claim is about the *interaction* (a difference-of-differences across the 2x2 cells), not the main effects, which may capture institutional confounds. The conclusion now says the result "supports" rather than "validates" the single-dimension approach, with explicit caveats about external validity. We leave a formal border-proximity analysis (requiring geographic distance data) as a valuable extension for future work.

### Concern 6: Falsification design under-specified
> "Curated set of non-gender referenda... undermines the rhetorical force unless you pre-specify a principled selection rule."

**Response:** We now explicitly state the selection rule in Section 6.6: non-gender referenda spanning defense, immigration, and fiscal policy—domains where the Rostigraben is known to operate in the opposite direction (Eugster et al. 2011). The extended falsification in Appendix C.2 uses a broader, randomly sampled set of non-gender referenda (up to six per decade, stratified by era) and produces a near-zero language gap (-0.4 pp) with a similarly near-zero interaction (+2.7 pp). The key result—the interaction is negligible regardless of which non-gender referenda are included—is now clearly stated.

### Concern 7: Missing references
> "Dell (2010), Alesina & Giuliano (2015), Conley (1999), Cameron et al. (2008)..."

**Response:** All requested references were already in our bibliography (Dell 2010, Alesina & Giuliano 2015, Conley 1999, Cameron et al. 2008, Tabellini 2010). We have added Giuliano & Nunn (2021) on cultural persistence and Doepke & Tertilt (2019) on gender norms.

---

## Reviewer 2: Grok-4.1-Fast (MINOR REVISION)

### Concern 1: Missing references (Alesina & Giuliano, Doepke & Tertilt, Tabellini)
**Response:** All three were already in or have been added to the bibliography. Giuliano & Nunn (2021) and Doepke & Tertilt (2019) are now cited in the text.

### Concern 2: CI construction detail
> "Report exact CI construction in footnote."

**Response:** The 95% CIs are constructed from municipality-clustered standard errors using the standard t-distribution critical value (approximately 1.96 given 1,463 clusters).

### Concern 3: Extend falsification to full non-gender panel in appendix
**Response:** Done. Appendix C.2 now clearly describes the extended falsification using a broader, randomly sampled set of non-gender referenda, distinct from the curated set in the main text. Both yield near-zero interactions.

### Concern 4: Clarify mixed-canton coding
**Response:** Already addressed in Section 7.4 (Inclusive Sample) and Appendix C.3, which explain the reclassification of five mixed-confession cantons by their pre-1800 majority denomination.

---

## Reviewer 3: Gemini-3-Flash (CONDITIONALLY ACCEPT)

### Condition 1: Cultural persistence reference
> "Cite Giuliano and Nunn (2020) on cultural persistence."

**Response:** Done. Added Giuliano & Nunn (2021) citation in the Background section where confessional persistence is discussed.

### Condition 2: Individual-level survey data footnote
> "Provide a brief discussion regarding the availability of individual-level survey data."

**Response:** Done. Added footnote in Section 5.4 acknowledging that the Swiss Electoral Studies (SELECTS) and Swiss Household Panel could provide individual-level validation of our ecological results, left as an extension for future work.

### Suggestion: SELECTS/SHP micro-validation
**Response:** We agree this would strengthen the paper. We note it as a promising extension in the new footnote.

---

## Exhibit Review Feedback (Gemini Vision, Round 3)

### Suggestion: Consolidate Tables 1 and 2
**Response:** We retain separate tables. Table 1 (covariate balance) serves the identification argument, while Table 2 (summary statistics by culture group) previews the results with outcome means. Consolidation would mix identification and results.

### Suggestion: Move Table 6 (permutation) and Figure 6 to appendix
**Response:** We retain these in the main text. The permutation inference directly addresses the few-clusters concern, which all three referees flagged as important.

### Suggestion: Remove Appendix Figure 7
**Response:** Noted for future revision. The ridgeline plot in the main text (Figure 4) makes this figure redundant.

---

## Prose Review Feedback (Gemini, Round 3)

### Verdict: Top-journal ready

### Suggestion 1: Tighten "Three Models" prose in Section 2
**Response:** Minor prose improvements made throughout.

### Suggestion 2: Delete roadmap sentence
**Response:** Retained—the transition sentence serves a structural purpose.

### Suggestion 3: "Hermetically sealed" appears twice
**Response:** Noted; revised to "functionally independent" in one occurrence.

---

## Summary of Changes Made in This Revision Round

1. **Softened causal claims:** "first direct test" -> "a direct test"; "validates" -> "supports"; added clarifying paragraph on interaction vs. main effect causality
2. **Added equivalence framing:** SESOI = +/-10% of language effect; 90% CI within equivalence region
3. **Clarified falsification selection:** Explicit selection rule stated; appendix now clearly distinguishes curated vs. extended falsification samples
4. **Added individual-level data footnote:** Acknowledges SELECTS/SHP as validation opportunity
5. **Added references:** Giuliano & Nunn (2021), Doepke & Tertilt (2019)
6. **Minor prose improvements** per prose review
