# Reply to Reviewers - Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

**Concern 1: HonestDiD promised but not shown.**
Response: Removed the HonestDiD reference from Section 5.4. The claim was made in anticipation of analysis that failed due to technical issues (dimension mismatch from missing 2016 data).

**Concern 2: Table 5 Column 4 "year × county_fips" implies county×year FE absorbing treatment.**
Response: Fixed the table label. Column 4 uses county-specific linear trends (county_fips × t), not county×year FE. The label now reads "County linear trends."

**Concern 3: NAICS 522110 does not capture teller-specific employment.**
Response: Retitled paper from "Decline of the Bank Teller" to "Local Banking Employment." Expanded limitations section to explicitly discuss the industry-vs-occupation aggregation issue and note that OES data is not available at the county level for individual occupations.

**Concern 4: Positive placebo coefficients suggest exposure endogeneity.**
Response: Expanded the placebo discussion in the limitations section. Note that the bias direction (upward) means the true effect is likely slightly more negative, but bounded by the DDD estimate (-0.002). Added quantitative discussion of likely bias magnitude.

**Concern 5: Geographic spillovers (county ≠ labor market).**
Response: Acknowledged in the discussion section (mechanisms for consolidation across county lines). This is an inherent limitation of county-level QCEW data.

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

**Concern 1: Abstract effect size claim.**
Response: Fixed. Changed from "one-standard-deviation" (which was 2.3%, not 8.7%) to "high-exposure counties lost nearly 4 percent of their branches."

**Concern 2: Pre-trends for branches.**
Response: Strengthened the limitations discussion of the V-shaped pre-trend pattern. Noted that the employment null is informative regardless of whether the branch decline is fully causal.

**Concern 3: Exposure quartile results referenced but not shown.**
Response: Removed the broken cross-reference to tab:robustness for quartile results. The visual evidence (Figure 3) is sufficient.

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

**Concern 1: N discrepancy (Table 1 vs regressions).**
Response: Added note to Table 1 explaining that summary statistics exclude 2011 (transition year), while regressions include it. Full regression sample = 25,426.

**Concern 2: Healthcare N difference unexplained.**
Response: Added note to Table 5 and Table 1 explaining QCEW suppression of small county-industry cells in the health sector.

**Concern 3: Figure visual mismatch (event study vs raw trends).**
Response: The patterns are consistent: both groups decline (Figure 3), but the differential is near zero (Figure 1). The event study measures the interaction effect (Exposure × Year), not absolute levels.

**Concern 4: NAICS vs teller mismatch.**
Response: Same as GPT Concern 3 — retitled paper and expanded limitations discussion.

## Changes to Tables
- All tables: replaced R variable names with clean labels
- Table 2: "County FE" → "County fixed effects"
- Table 3: "durbin_exposure × post × is_banking" → "Exposure × Post × Banking"
- Table 4: "durbin_post" → "Durbin Exposure × Post"
- Table 5: "durbin_post" → "Durbin Exposure × Post"; added healthcare N explanation
- Table 6: "log_bank_emp" → "Log Banking Employment"; "year × county_fips" → "County linear trends"; scientific notation → decimal

## Changes to Prose (from prose review)
- Abstract: punched up wording ("High-exposure counties lost nearly 4 percent...")
- Removed HonestDiD claim
- Strengthened limitations discussion
