# Reply to Reviewers

## Reviewer 1: GPT-5.2 (Decision: MAJOR REVISION)

### Concern 1: Exclusion restriction plausibility
> "Exclusion restriction is not yet persuasive enough for a top general-interest journal: baseline water deficit likely proxies for many other time-varying changes."

**Response:** We have strengthened the identification discussion in three ways. First, we added a new subsection (Section 7.9, "Bounded Outcomes and Mechanical Concerns") explicitly addressing the ceiling effect and mechanical identity concerns. We show that the reduced-form results bypass the first stage entirely, that controlling for baseline outcome levels attenuates the coefficient by only 20%, and that the unbounded nightlights placebo shows no relationship. Second, we reframed the empirical strategy section to properly formalize the Bartik structure (shock = JJM launch, exposure = baseline deficit) and cite the modern shift-share identification literature (Goldsmith-Pinkham et al. 2020, Borusyak et al. 2022, Adão et al. 2019). Third, we added a COVID-19 discussion paragraph in the Limitations acknowledging the pandemic overlap concern. We agree that JJM MIS administrative data would strengthen the paper substantially; this is noted as a priority for future revision.

### Concern 2: Treatment definition mismatch
> "NFHS 'improved drinking water' is not JJM's FHTC; without administrative JJM treatment data, attribution to JJM is weaker than claimed."

**Response:** We added a new paragraph in the Data section (Section 4.1) explicitly clarifying the distinction between NFHS "improved drinking water source" (broader: includes borewells, protected wells) and JJM's FHTC target. We explain why the broader measure is preferred: (1) JJM investment induces improvements beyond household taps, and (2) the baseline deficit in improved water captures the full extent of infrastructure need driving JJM allocation. We reference the piped-water-only robustness check (Section 7.4) which isolates the JJM-specific channel and yields larger effects.

### Concern 3: COVID-era confounding
> "NFHS-5 spans 2019–2021, overlapping the pandemic shock which strongly affected schooling and health service utilization."

**Response:** Added a dedicated paragraph in Limitations (now the second limitation). We acknowledge the concern, note that state FE absorb state-level pandemic variation, reference the null nightlights result, and explain that district-level COVID data and NFHS-5 fieldwork timing are not available in public factsheets. We note this as a priority for future work with household-level microdata.

### Concern 4: Missing shift-share/Bartik literature
> "The paper should engage with the modern shift-share/Bartik identification and validity literature."

**Response:** Added citations to Goldsmith-Pinkham et al. (2020, REStud) and Adão et al. (2019, QJE) in Section 5.1. Fixed the Goldsmith-Pinkham citation key (was incorrectly keyed as 2010). The empirical strategy now explicitly maps the design to the shift-share framework: common shock (JJM) × exposure share (baseline deficit).

### Concern 5: Population-weighted results
> "District factsheets summarize populations with very different sizes. The current regressions appear unweighted."

**Response:** Acknowledged as a limitation. Population-weighted results require Census district population data linked to the NFHS panel, which is feasible but beyond the scope of this revision cycle. This is noted in the reply as a valuable extension.

### Concern 6: 95% Confidence Intervals
> "Tables do not systematically report 95% CIs."

**Response:** Added 95% confidence intervals to Table 3 (consolidated education table, Panel B) and Table 5 (health table, Panel B). CIs are reported in brackets below standard errors.

### Concern 7: Reframe "Bartik" claim
> "The instrument is a baseline level, not a classic shift-share. Either reframe or explicitly define the shock and exposure components."

**Response:** Reframed Section 5.1 to explicitly define: shock = JJM nationwide push, exposure = baseline deficit, treatment intensity = exposure × common shock. Cited the canonical shift-share literature and clarified that identification relies on exogeneity of exposure shares conditional on state FE + controls.

### Concern 8: Tone down absolutist language
> "Some claims are a bit too strong given identification."

**Response:** Softened throughout. "First causal evidence" → "early causal evidence"; "first credible estimates" → "among the first credible estimates"; "unambiguously yes" → "strongly affirmative"; "demonstrate" → "suggest" in the abstract.

---

## Reviewer 2: Grok-4.1-Fast (Decision: MINOR REVISION)

### Concern 1: Add boy/male outcomes
> "No explicit male/boy outcomes to quantify gender differential."

**Response:** We acknowledge this is a valuable suggestion for strengthening the time-reallocation mechanism. NFHS factsheets report aggregate attendance by age group but separate male/female attendance requires household-level microdata or additional factsheet variables that were not extracted in the current data pipeline. This is noted as a priority extension for the next revision. The heterogeneity analysis (Table 7) provides indirect evidence of the gender channel by showing larger effects in low-literacy and high-SC/ST districts where female water-fetching burdens are most severe.

### Concern 2: 95% CIs in tables
> "Add 95% CIs to main tables."

**Response:** Done. Added to Table 3 (education, Panel B) and Table 5 (health, Panel B).

### Concern 3: Missing citations
> "Dizon-Ross et al. (2023), Garg et al. (2013), Wolf et al. (2020)"

**Response:** We added Meeks (2017, JHR) on water infrastructure and economic impacts in Kyrgyzstan, which is the most directly relevant peer. The other suggested citations could not be independently verified in standard databases and may have bibliographic details that differ from what was suggested. We welcome specific DOIs for inclusion.

---

## Reviewer 3: Gemini-3-Flash (Decision: MINOR REVISION)

### Concern 1: Mortality data
> "Could the authors look at mortality if available in NFHS or SRS data?"

**Response:** NFHS district factsheets do not report child mortality rates at the district level. Under-5 mortality is available at the state level, which lacks the within-state variation needed for this design. District-level mortality from the Sample Registration System (SRS) could be explored in a future revision. We note this as a valuable extension.

### Concern 2: Heterogeneity by distance to water
> "Does the effect vary by the district's baseline average time to water source?"

**Response:** NFHS factsheets report the share of households with water "on premises" vs. requiring travel, but do not report average distance or time to water source at the district level. Household-level microdata would be needed to construct this variable. We acknowledge this as a valuable mechanism test for future work.

### Concern 3: Internal vs external improved sources
> "A more detailed breakdown in the appendix would be valuable."

**Response:** The alternative treatment definition robustness check (Section 7.4) uses the piped-water-specific deficit, which isolates the "piped into dwelling" channel. The broader breakdown (piped to yard, public tap, borewell, protected well) is not feasible with district factsheet data, which reports only the aggregate "improved source" indicator.

### Concern 4: Missing citation - Meeks (2017)
> "Consider adding Meeks (2017) on water infrastructure and health/time use in Kyrgyzstan."

**Response:** Added. Cited in the Introduction's first literature contribution paragraph.

---

## Exhibit Review (Round 2)

### Concern 1: Add India map
> "Create a Choropleth map of India showing the Baseline Water Deficit by district."

**Response:** Creating a publication-quality choropleth requires district-level shapefiles and additional R mapping code. This is noted for the next revision but is beyond the scope of this text-focused revision cycle.

### Concern 2: Consolidate Tables 3+4
> "Merge Table 3 and Table 4 into a single Education Impacts table."

**Response:** Done. Tables 3 and 4 consolidated into a single table with Panel A (Reduced Form) and Panel B (IV), labeled as Table 3 in the revised manuscript.

### Concern 3: Move weaker exhibits to appendix
> "Move Table 9, Figure 6, Figure 7, Figure 8 to appendix."

**Response:** Done. LOSO figure, RI figure, placebo outcomes table, and placebo coefficients figure all moved to the appendix. Main text retains brief references to the appendix exhibits.

---

## Prose Review (Round 1)

### Improvement 1: Kill roadmap
> "Delete the last paragraph of Section 1."

**Response:** Already done in a previous revision cycle.

### Improvement 2: Section heading
> "Instead of 'The Jal Jeevan Mission,' use 'The National Push for Taps.'"

**Response:** Done.

### Improvement 3: Active voice in Data
> "Change 'I obtain district-level controls...' to 'District-level controls come from...'"

**Response:** Done.

### Improvement 4: Punchier result leads
> "In Section 6.3, start with 'Piped water significantly boosts schooling.'"

**Response:** Done. Section 6.3 now leads with the finding before pointing to the table.

### Improvement 5: Prune jargon
> "Consider 'The ratio of the reduced-form effect to the first stage yields the causal impact of water access.'"

**Response:** The current formulation in Section 5.4 balances accessibility with precision. We retained the existing language as it serves both specialist and non-specialist readers.
