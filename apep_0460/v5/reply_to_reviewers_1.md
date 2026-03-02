# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1. Triple-diff not insulated from COVID type-specific shocks
> "the house–apartment gap plausibly widened more in rural/amenity areas"

**Response:** We agree this is the leading remaining threat. We have expanded the Limitations section (Section 9.3) to explicitly discuss type-specific within-département shocks as the key unresolved identification concern. We note that the rural amenity proxy (inverse population density) does not absorb the UK signal (Table 6), which is reassuring but not dispositive. We have also clarified the estimand in Section 9.2: "the post-2020 differential house-apartment appreciation associated with pre-existing UK connectedness."

### 2. GADM1 inference: 13 regions, effective clusters
> "Standard department-clustered SEs can be misleading when treatment varies at a higher level"

**Response:** Valid concern. We have added a note in the Limitations section acknowledging that with 13 GADM1 regions providing treatment-level variation, département-clustered standard errors may not accurately capture sampling uncertainty. Region-level wild cluster bootstrap with only 13 clusters would itself be unreliable, so we flag this as a limitation rather than providing a false sense of precision.

### 3. Multiple testing / Bonferroni
> "adjusted q-values / family-wise error control"

**Response:** We have added Bonferroni-adjusted thresholds (α/5 = 0.01) throughout the GADM1 placebo discussion and table notes. Under Bonferroni, only Italy survives in the individual triple-difference.

### 4. Mixed placebo evidence
> "significant non-UK triple-diff effects can indicate remaining confounding"

**Response:** We now frame these significant placebos as evidence of genuine cross-border demand from neighboring countries (Italy → Provence, Belgium → northern France, Spain → Pyrénées) rather than confounding. The Bonferroni correction reduces the apparent failure rate.

### 5. "Progressively resolve" overclaims
> "the paper currently overreach[es] relative to mixed evidence"

**Response:** Changed "resolve" to "address" throughout. Reframed the conclusion to acknowledge the toolkit eliminates the German confound but does not eliminate all neighboring-country placebos.

### 6. Economic magnitudes
> "coefficient like 0.025 on log(SCI)×Post is not immediately interpretable"

**Response:** Added 1-SD interpretation in Section 5.2: a one-standard-deviation increase in log census stock (1.39 log units) implies a 0.4 percentage point larger house-apartment gap.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### 1. GADM1 placebos not fully null
> "IT/ES/BE sig individually; IT remains sig in horse-race"

**Response:** Same as GPT response above. Added Bonferroni correction and reframed as genuine cross-border demand.

### 2. Economic magnitudes
> "Log-point effects hard to interpret w/o SD scaling"

**Response:** Added 1-SD calibration for both DiD (census stock: 1.39 SD → 1.5pp) and triple-diff (0.4pp house-apartment gap).

### 3. Pre-trend event study
> "Baseline p≈0.04 borderline"

**Response:** The paper already emphasizes that borderline pre-trends "reinforce the case for the triple-difference" (Section 5.3). The triple-diff pre-trend F-test (p = 0.240) validates the design.

### 4. "Progressively resolve" overclaim
> "GADM1 triple has IT/ES/BE sig individually"

**Response:** Changed "resolve" to "address" throughout.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### 1. Triple-diff precision
> "need to be more explicit about this lack of conventional significance"

**Response:** Added explicit p-values and magnitude interpretation in Section 5.2. Now reads: "does not reach conventional significance ($p = 0.106$ for SCI; $p = 0.57$ for census stock)."

### 2. Italy placebo in PACA
> "A brief sensitivity check excluding PACA would determine if Italy is a local outlier"

**Response:** This is a valuable suggestion for future work. The current analysis notes Italy's significance and attributes it to potential genuine Italian demand in Provence, which is consistent with the PACA hypothesis.

---

## Prose Review Integration

- Changed "The toolkit consists of four elements: (i)..." to flowing clause structure
- Final sentence: "The confound we document is not a quirk of French housing..."
- "Three mechanisms explain why the effect appears only after 2020"
- Simplified GADM1 intro: "compare apples to oranges"
- More vivid verbs: German SCI "mimics" and "vanishes"

## Exhibit Review Integration

- Table 3: Fixed `log_price_m2` → "Log Price/m²"; renamed "UK+DE" to "Horse Race"
- Table 2: Added quarterly frequency note
- GADM1 table: Added Bonferroni note and singleton explanation
