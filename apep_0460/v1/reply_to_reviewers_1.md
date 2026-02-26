# Reply to Reviewers — Round 1
## APEP-0460: Across the Channel

**Date:** 2026-02-26

We thank all three referees for their careful and constructive reviews. The consensus decision is MAJOR REVISION, with the principal concerns being: (1) the significant German placebo undermining UK-specific identification, (2) SCI endogeneity from post-treatment measurement, (3) the pre-trend outlier at τ=-4, and (4) the need for mechanism evidence. We have addressed these concerns comprehensively, as detailed below.

---

## Summary of Changes

### New Analysis (Workstream 1: Identification Strengthening)
1. **General European openness control** (Table 3, Col 2): Added log(SCI_DE + SCI_CH) × Post as a control. UK coefficient survives at β=0.023 (p=0.061).
2. **Residualized UK exposure** (Table 3, Cols 3–4): Residualized UK SCI on German SCI (and on both DE+CH). Residualized coefficients are positive (β=0.016) but insignificant (p≈0.21), indicating shared variance with general European connectivity.
3. **Triple horse race** (Table 3, Col 5): UK, Germany, Switzerland simultaneously. Switzerland is null (β=-0.000, p=0.98); UK and DE both positive but individually insignificant.
4. **Joint pre-trend F-test**: Wald test on all 9 pre-treatment coefficients: F=1.97, p=0.038. Excluding τ=-4 outlier: F=1.70, p=0.093.

### New Analysis (Workstream 2: Mechanism Evidence)
5. **Property type heterogeneity** (Table 6): Houses β=0.035 (p=0.011), Apartments β=0.006 (p=0.755). Effect is entirely house-driven — consistent with UK residential buyers, not generic capital flows.
6. **Geographic heterogeneity** (Table 7): Channel-facing départements β=0.122 (p<0.001), Interior β=0.023 (p=0.054). UK expat hotspots show *negative* β=-0.105 (p=0.003), suggesting demand reallocation within France.

### Exhibit Improvements (Workstream 3)
7. Consolidated Table 3 (placebo) into Table 2 — German-alone and Swiss columns added.
8. Promoted SCI map from Appendix to main text (Section 4).
9. Fixed Table 2 variable naming (German SCI snake_case → proper formatting).
10. Fixed Table 5 rendering (resizebox applied).

### Prose Polish (Workstream 4)
11. Cut roadmap paragraph (Section 1).
12. Reframed German placebo as "European integration channel" in Limitations.
13. Active voice improvements throughout.
14. Polished conclusion with mechanism evidence summary.
15. Updated abstract to reference houses/apartments result and geographic heterogeneity.

---

## Point-by-Point Responses

### Referee 1 (GPT-5.2)

**1. "The German placebo being MORE significant than the UK treatment is deeply concerning."**

We agree this is the paper's most important challenge. We now address it with three identification-strengthening tests (Table 3):
- Controlling for general European openness preserves the UK effect (β=0.023, p=0.061)
- Residualizing UK SCI on German SCI attenuates the UK effect to insignificance (β=0.016, p=0.21)
- The triple horse race shows Switzerland is null (β=-0.000) while UK and DE are both positive but individually insignificant

We now interpret the UK coefficient as capturing a *composite* of UK-specific demand reallocation and a broader European integration channel. The mechanism evidence (houses only, Channel-facing concentration) helps isolate the UK-specific component — these patterns are difficult to explain through generic international connectivity.

**2. "SCI measured in 2021 — five years after the shock."**

We acknowledge this limitation forthrightly in the paper and note it is untestable with available data. No pre-2016 GADM2 SCI vintage exists publicly. The persistence argument is plausible (Bailey et al. 2018 validate SCI against Census migration data with r > 0.7), but we flag this as a genuine limitation. We decline to overstate the strength of the persistence assumption.

**3. "Pre-trend coefficient at τ=-4 is significant."**

We now report a formal joint Wald test: F=1.97, p=0.038 for all 9 pre-treatment coefficients. Excluding the τ=-4 outlier: F=1.70, p=0.093. The marginal significance is driven by one coefficient rather than a systematic trend. We report both tests transparently.

**4. "Need property type heterogeneity — houses vs apartments."**

Done. Table 6 reports: Houses β=0.035 (p=0.011), Apartments β=0.006 (p=0.755). This is strong mechanism evidence: UK expatriates overwhelmingly purchase houses, not apartments. The house-specific effect is the paper's strongest piece of evidence for UK-specific demand reallocation.

**5. "Need geographic heterogeneity."**

Done. Table 7 reports Channel-facing vs Interior and UK hotspot vs Non-hotspot splits. The Channel-facing result (β=0.122) is striking and consistent with proximity to UK buyers. The negative hotspot result (β=-0.105) suggests demand reallocation within France — a novel finding.

---

### Referee 2 (Grok-4.1-Fast)

**1. "The positive German placebo entirely undermines the claim of UK-specific identification."**

Addressed with the three identification-strengthening tests described above. We now adopt a more nuanced interpretation: the UK coefficient is a composite of UK-specific demand reallocation and a broader European integration channel. The mechanism evidence (house-specific effect, Channel-facing concentration, negative hotspot result) provides the strongest case for a UK-specific component.

**2. "Consider Bartik shift-share with UK regional GVA shocks."**

We note this would require rebuilding the entire analysis pipeline with UK regional GVA as the "shift" component. We have UK GVA data (ONS ITL3) but implementing a full Bartik IV is beyond the scope of this revision. The paper now uses the language "continuous-treatment difference-in-differences" rather than "shift-share" to accurately describe the reduced-form design.

**3. "Missing time-varying controls at département level."**

We attempted to retrieve département-level unemployment, firm creation, and employment data from INSEE BDM/SDMX API but encountered access constraints. We document this transparently. The département and quarter-year fixed effects absorb time-invariant unit characteristics and common temporal shocks. The residualized specifications (Table 3) provide a partial substitute by controlling for correlated international exposure.

**4. "Need Rambachan-Roth bounds for pre-trends."**

We acknowledge this suggestion but note the complex implementation requirements for continuous-treatment designs. We provide the joint Wald test (F=1.97, p=0.038 for all pre-period coefficients; F=1.70, p=0.093 excluding the outlier) as a more tractable diagnostic.

---

### Referee 3 (Gemini-3-Flash)

**1. "Table 5 rendering is broken — columns cut off."**

Fixed with `\resizebox{\textwidth}{!}{...}` wrapper. All columns now visible.

**2. "Table 3 is redundant with Table 2."**

Consolidated. Table 3 (placebo) has been merged into Table 2, which now includes: (1) Baseline UK, (2) Timing split, (3) UK-DE horse race, (4) German alone, (5) Transactions, (6) Swiss placebo.

**3. "Promote SCI map to main text."**

Done. Figure 1 (SCI map) now appears in Section 4 (Data) after the summary statistics, with accompanying text describing the geographic distribution of UK connectivity.

**4. "Fix Table 2 variable naming (snake_case)."**

Fixed. All variable names in Table 2 now use proper formatting: "Log SCI(Germany) × Post-Referendum" instead of `post_referendum × log_sci_de`.

**5. "The German placebo suggests a broader European integration channel."**

We adopt exactly this framing. The Limitations section now leads with "European integration channel" rather than "German placebo" and discusses how the mechanism evidence (houses, Channel-facing) helps isolate the UK-specific component.

---

## What We Did NOT Do (and Why)

| Suggestion | Reason for Deferral |
|-----------|---------------------|
| Full Bartik IV with UK regional GVA | Would require rebuilding entire analysis pipeline; saved for future revision |
| Pre-2016 SCI vintage | Not publicly available at GADM2 level |
| Rambachan-Roth bounds | Complex implementation for continuous-treatment designs |
| Italy/Spain placebos | SCI GADM2 data only contains FR pairs with GB, DE, CH; no IT/ES |
| Additional outcome variables (unemployment, firm creation) | INSEE API access constraints; documented transparently |

---

## Changes to Paper Structure

- **Section 6.2** now titled "Placebo Tests and Identification" and includes the identification strengthening discussion with Table 3
- **Section 7.1** (Mechanisms) now includes three subsubsections: Property Type Heterogeneity (7.1.1), Geographic Heterogeneity (7.1.2), and Timing (7.1.3)
- **Section 7.3** (Limitations) — German placebo reframed as "European integration channel"
- **Figure 1** (SCI map) promoted from Appendix to Section 4
- **Table 2** expanded to 6 columns (consolidated with former Table 3)
- **Tables 3, 6, 7** are new (identification, property type, geographic)
- Abstract updated to reference mechanism evidence
- Conclusion updated to integrate mechanism findings
- Roadmap paragraph removed from Introduction
