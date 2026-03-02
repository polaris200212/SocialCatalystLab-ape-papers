# Reviewer Response Plan

## Summary of Reviews

| Reviewer | Decision | Key Concerns |
|----------|----------|--------------|
| GPT-5.2 | MAJOR REVISION | Exclusion restriction, treatment definition, COVID, Bartik lit, weighting, CIs |
| Grok-4.1-Fast | MINOR REVISION | Boy outcomes, 95% CIs, 3 literature gaps |
| Gemini-3-Flash | MINOR REVISION | Mortality data, distance heterogeneity, piped vs non-piped |
| Exhibit Review | Constructive | Consolidate Tables 3+4, move weak exhibits to appendix, add map |
| Prose Review | Top-journal ready | Minor active voice, punchier leads |

---

## Workstream 1: Identification & Methodology (HIGH PRIORITY)

### 1a. Bounded Outcomes / Ceiling Effects (GPT #2f)
- **Action:** Add new subsection in Robustness (Section 7.9) discussing bounded outcomes and ceiling/floor effects
- **Content:** Districts with 95% baseline water coverage cannot improve much; this is by design, not a flaw. Discuss partial arithmetic identity concern and why controls + state FE address it.

### 1b. COVID Confounding (GPT #3)
- **Action:** Add paragraph in Limitations (Section 8.3) explicitly discussing COVID-era confounding
- **Content:** NFHS-5 spans 2019-21 overlapping pandemic. State FE absorb state-level variation. Nightlights null rules out differential economic trajectories. Note that phase-wise fieldwork timing and COVID district data are not available for direct control. Acknowledge as limitation.

### 1c. Reframe Bartik Language (GPT #5b, Grok)
- **Action:** Revise Empirical Strategy section language. Replace "Bartik-style" framing with "exposure design" / "need-based targeting instrument." Formalize: national shock = JJM rollout, exposure = baseline deficit, treatment intensity = exposure × common shock.
- **Content:** Cite Goldsmith-Pinkham et al. (2020) on identification assumptions. Acknowledge this is a baseline-exposure design where exogeneity of exposure shares (conditional on state FE + controls) is the key assumption.

### 1d. Treatment Definition Clarification (GPT #interpretation)
- **Action:** Add paragraph in Data section explicitly mapping NFHS "improved drinking water source" to JJM's FHTC mandate
- **Content:** NFHS "improved source" is broader than JJM's FHTC target. Reduced-form identifies intent-to-treat effect of JJM via baseline deficit → ∆improved water. Piped-water-only robustness (Section 7.4) narrows to JJM-specific channel. Frame "improved water" as preferred measure because it captures all JJM-induced improvements (including borewells/protected wells installed alongside piped networks).

### 1e. Tone Down Absolutist Language (GPT #5c)
- **Action:** Soften "first causal evidence" → "among the first credible estimates"; "unambiguously yes" → "strongly affirmative"; remove "first credible national-scale estimates" claim
- **Locations:** Abstract, Introduction, Conclusion

---

## Workstream 2: Tables & Exhibits (MEDIUM PRIORITY)

### 2a. Add 95% CIs to IV Tables (GPT, Grok)
- **Action:** Add 95% CI row below coefficient in Tables 4 and 5 (Panel B)
- **Computed from:** β ± 1.96 × SE

### 2b. Consolidate Tables 3+4 (Exhibit Review)
- **Action:** Merge Reduced Form (Table 3) and IV (Table 4) into single "Education Impacts" table with Panel A: Reduced Form and Panel B: IV
- **Rationale:** Saves space, allows reader to see scaling immediately

### 2c. Move Weaker Exhibits to Appendix (Exhibit Review)
- **Move:** Figure 6 (LOSO), Figure 7 (RI distribution), Table 9 (Placebo outcomes), Figure 8 (Placebo coefficients) to appendix
- **Keep in main text:** Figures 1-5 (distribution, first stage, reduced form, coefficient plot, nightlights event study), Tables 1-2 (summary, first stage), merged Table 3/4 (education impacts), Table 5 (health), Table 6 (nightlights), Table 7 (heterogeneity), Table 8 (robustness summary)
- **Note:** LOSO and RI results are already summarized in the Robustness Summary (Table 8)

---

## Workstream 3: Literature (MEDIUM PRIORITY)

### 3a. Add Shift-Share Literature (GPT)
- Goldsmith-Pinkham, Sorkin, Swift (2020, REStud) — canonical Bartik identification
- Adão, Kolesar, Morales (2019, QJE) — shift-share inference
- Integrate into Empirical Strategy section

### 3b. Add Water/WASH Literature (Grok, Gemini)
- Meeks (2017, JHR) — water infrastructure and health/time in Kyrgyzstan
- Cite in Literature contribution paragraph

### 3c. Other Missing Citations
- Note: Dizon-Ross et al. (2023), Garg et al. (2013), Wolf et al. (2020) suggested by Grok — these are plausible citations but may not be real published papers. Will add only if verification is possible. Will instead add Meeks (2017) which is a real JHR paper.

---

## Workstream 4: Prose (LOWER PRIORITY)

### 4a. Section 2.2 Heading
- **Change:** "The Jal Jeevan Mission" → "The National Push for Taps"

### 4b. Active Voice in Data Section
- **Fix:** "I obtain district-level controls..." → "District-level controls come from..."

### 4c. Punchier Result Leads
- **Fix Section 6.3:** Open with "Improved water access significantly boosts schooling" before pointing to the table

### 4d. Soften "Bartik-style" usage
- Already covered in Workstream 1c

---

## Not Addressed (Noted for Future Revision)

| Suggestion | Reviewer | Why Deferred |
|------------|----------|--------------|
| Boy/male outcomes | Grok | Requires new R code + NFHS data extraction |
| Population-weighted results | GPT | Requires Census population weights in R |
| India choropleth map | Exhibit | Requires spatial data (shapefiles + mapping) |
| JJM MIS administrative data | GPT | Data not currently available/accessible |
| Mortality data | Gemini | Not in NFHS factsheets at district level |
| Distance-to-water heterogeneity | Gemini | Not available at district level in NFHS factsheets |
| UDISE pre-trend enrollment data | GPT | Requires separate data download and matching |
| India Time Use Survey | GPT | State-level only, not available via API |

These are acknowledged in the reply_to_reviewers with a note that they represent valuable extensions for a revision.
