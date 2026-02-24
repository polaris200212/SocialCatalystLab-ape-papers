# Reviewer Response Plan — apep_0449 v1

## Review Summary

| Reviewer | Model | Decision |
|----------|-------|----------|
| GPT-5.2 | External referee | MAJOR REVISION |
| Grok-4.1-Fast | External referee | MINOR REVISION |
| Gemini-3-Flash | External referee | MINOR REVISION |
| Gemini-3-Flash | Exhibit review | Constructive |
| Gemini-3-Flash | Prose review | Constructive |

---

## Workstream 1: Identification & Methodology (Priority: HIGH)

### 1a. Endogenous sample selection (GPT §3.1)
GPT raises the concern that restricting to elections where top-two candidates differ in criminal status is a collider-type selection. **Response:** Add a paragraph in §5.5 (Threats to Validity) explicitly acknowledging this concern, clarifying the estimand, and noting that Prakash et al. use the same construction. This is a valid point but standard in the close-elections criminal RDD literature.

### 1b. NL truncation / variable post-window (GPT §3.2)
GPT flags that variable-length post-windows (capped at 2013) could create systematic measurement differences by election year. **Response:** Add a paragraph in §7.2 (Alternative Explanations) expanding the existing "Measurement Timing" discussion. Note that this is partially addressed by the period heterogeneity table (Table D.3) showing effects in both 2004-2008 and 2009-2012 subperiods.

### 1c. Donut hole interpretation (GPT §3.3, Grok)
Reviewers want deeper engagement. **Response:** The current discussion is candid and two-sided. Add a sentence noting the power calculation interpretation (removing 204 elections within ±1% drastically cuts effective N).

### 1d. Clustering / dependence (GPT §2)
GPT asks about repeated constituencies across elections. **Response:** Add a note in the estimation section clarifying that each constituency-election is a unique observation; constituencies can appear across election years but the RDD treats each election independently.

### 1e. Multiple testing explicitness (GPT §2)
GPT wants clarity on which heterogeneity tests are pre-specified vs exploratory. **Response:** Add a sentence noting BIMARU is pre-specified (motivated by the literature) while SC reservation is exploratory.

---

## Workstream 2: Prose Improvements (Priority: HIGH)

### 2a. Opening hook (Prose review)
Replace the opening sentence with a more vivid, Shleifer-style hook. Current: "Nearly one-third of members..." Revised: Start with the dramatic tension between democracy and criminality.

### 2b. Move contradiction earlier (Prose review)
The sign reversal vs Prakash et al. is buried on page 3. Bring it to the second paragraph.

### 2c. Kill roadmap paragraph (Prose review)
Delete "The remainder of the paper proceeds as follows..." on page 4. Section headers suffice.

### 2d. Active results narration (Prose review)
Replace "Table X reports..." with active-voice statements. Lead with findings, cite tables parenthetically.

### 2e. Vivid mechanism language (Prose review)
In §6.2, use more energetic language for the bank result.

---

## Workstream 3: Exhibit Improvements (Priority: MEDIUM)

### 3a. Add significance stars to Tables 2, 3, 4 (Exhibit review, GPT)
Add *, **, *** to coefficients in all regression tables per standard convention.

### 3b. Move Table 5 (balance) to appendix (Exhibit review)
Replace main-text Table 5 with Figure 5 (covariate balance plot), which is more visually impactful. Reference the full table in the appendix.

### 3c. Move Table 6 (placebo) to appendix (Exhibit review)
Summarize in text, move the table to appendix. Replace with Figure 6 (placebo plot) reference.

### 3d. Promote Figure 7 (heterogeneity) to main text (Exhibit review)
Add after Table 4 for visual impact.

---

## Workstream 4: Missing References (Priority: MEDIUM)

Add 4-6 references cited across reviews:
- Lee & Lemieux (2010, JEL) — canonical RDD review (GPT)
- Imbens & Kalyanaraman (2012, REStud) — bandwidth selection (GPT)
- Chen & Nordhaus (2011, PNAS) — nightlights validation (GPT)
- Cole (2009, AEJ:Applied) — political economy of agricultural credit in India (Gemini)

---

## Workstream 5: Tighten Language (Priority: MEDIUM)

### 5a. Causal language around mechanisms (GPT)
Change "crowd out banks" → "associated with lower bank presence" in appropriate places. Keep causal language only where RDD supports it.

### 5b. Clarify compound treatment (GPT §6.5)
Expand the compound treatment paragraph slightly to note that criminal heterogeneity by charge severity would be valuable but is beyond current scope.

### 5c. Clarify reconciliation with Prakash (GPT §6.1, Grok)
Strengthen the Prakash reconciliation by noting that a formal specification ladder is an important direction for future work.

---

## Scope Decisions (Not Addressed)

The following suggestions require new data collection or substantial new analysis and are noted as future work:
- Fixed-horizon nightlights results (GPT) — requires code rewrite
- VIIRS extension (Grok, Gemini) — data not available in current pipeline
- Local randomization inference (GPT) — methodological extension
- Alternative running variable definition (GPT) — conceptual reframing
- Criminal heterogeneity by severity (GPT, Grok) — needs ADR severity data
- Bank type decomposition: PSB vs private (Gemini) — data not available
- India map figure (Exhibit review) — requires shapefiles
- Welfare outcomes via IHDS/DHS (Grok) — out of scope

These are acknowledged in the reply to reviewers as productive directions for future work.
