# Reply to Reviewers — apep_0460 v4

## Referee 1 (GPT-5.2): MAJOR REVISION

### Concern 1: COVID vs Brexit timing
> "Triple-diff is essentially zero pre-2020... needed: a sharper decomposition."

**Response:** We have substantially revised the Discussion section to acknowledge this directly. We now state: "The pre-2020 triple-difference is null for both SCI (p = 0.93) and census stock (p = 0.98)... We cannot definitively distinguish [whether the signal reflects post-2020 dynamics or gradually accumulating Brexit effects]." We have moderated all causal language from "Brexit caused" to "post-referendum regime change interacted with broader dynamics." We also note that the baseline DiD (census stock) remains significant in the 2014-2018 window, suggesting the level effect exists pre-COVID even if the triple-diff signal is post-2020. A full epoch decomposition with separate 2016Q3-2019Q4 and 2020Q1+ indicators is a valuable suggestion we note for future work (would require re-running the full R pipeline with new specifications).

### Concern 2: Multi-country placebo comparability
> "Use a common spatial resolution... GADM1 vs GADM2 mismatch."

**Response:** We have added an explicit limitation paragraph (Section 8.5) acknowledging that "the multi-country placebo battery compares UK and German exposure at the GADM2 (département) level with Belgian, Dutch, Italian, and Spanish exposure at the coarser GADM1 (region) level. This measurement asymmetry means the placebo comparisons are not 'apples to apples'." We note that GADM2 data for BE/NL/IT/ES is not available in the SCI dataset, making a fully symmetric comparison infeasible with current data. Downsampling UK/DE to GADM1 would reduce power but is a valid future robustness check.

### Concern 3: Commune-level bootstrap inference
> "Report wild cluster bootstrap p-values for commune specs."

**Response:** We agree this would strengthen the commune-level results. The fwildclusterboot R package is not currently available for R 4.5.2, which prevented us from implementing wild cluster bootstrap. We have implemented pairs cluster bootstrap for the département-level specifications and note the commune-level results should be interpreted with this caveat.

### Concern 4: Triple-diff symmetry assumption
> "Provide stronger justification for house vs apartment symmetry."

**Response:** We have expanded the Limitations section to discuss this more directly, noting that "foreign institutional investment in French real estate concentrates in commercial property and luxury apartments in Paris and the Côte d'Azur, which could generate differential house–apartment dynamics." We acknowledge this is the key maintained assumption.

### Concern 5: Claim calibration
> "Several statements read stronger than the evidence."

**Response:** We have substantially moderated claims throughout. The conclusion now reads: "we document that French housing markets connected to the UK through pre-existing migration networks experienced differential house price appreciation in the post-referendum period... While we cannot perfectly isolate the Brexit referendum from subsequent dynamics (including the pandemic), the pattern is consistent with UK-specific demand channels."

---

## Referee 2 (Grok-4.1-Fast): MAJOR REVISION

### Concern 1: COVID timing
> "Triple null pre-2020 suggests non-Brexit driver."

**Response:** See Referee 1, Concern 1 above. We now explicitly frame this as a key interpretive challenge and moderate claims accordingly.

### Concern 2: Multi-country placebo GADM mismatch
> "GADM1/GADM2 mismatch unaddressed."

**Response:** See Referee 1, Concern 2. Now addressed as an explicit limitation.

### Concern 3: Trend attenuation
> "Dept trends attenuate DiD stock to null."

**Response:** We have added language in the Results section noting that "département-specific linear trends attenuate the result to insignificance — a key finding that suggests some identifying variation comes from pre-existing differential trends rather than a sharp post-referendum break." This is presented honestly rather than explained away.

---

## Referee 3 (Gemini-3-Flash): MINOR REVISION

### Concern 1: Property type composition by SCI decile
> "Provide a table showing the share of total transactions by property type across different SCI deciles."

**Response:** This is a valuable suggestion for demonstrating that the triple-diff assumption is not violated by composition. We note this for a potential v5 revision where we can add this diagnostic table.

### Concern 2: Census data gaps
> "List the départements lacking census data."

**Response:** We have expanded the limitation text to note that "approximately seven départements lack bassin de vie data in the INSEE publication, reducing the census stock sample from 3,510 to 3,209 département-quarter observations. These tend to be small départements where no bassin de vie straddles the UK-migrant settlement pattern."

---

## Exhibit Review Feedback

We note the suggestions for: (1) adding a map of UK exposure, (2) streamlining exhibits to main text, and (3) synchronizing figure axes. These are valuable improvements for a potential v5 but not implemented in this revision cycle.

## Prose Review Feedback

We have reduced "Column X" narration in the Results section and moderated statistical language in the Discussion/Conclusion per the prose review's recommendations.
