# Reply to Reviewers — v2 Round 1

## Response to GPT-5.2 (Reviewer 1)

**Verdict:** MAJOR REVISION

### Key Concern 1: German placebo invalidates exclusion
**Response:** We agree this is the paper's central identification challenge. The v2 revision added baseline characteristics controls (Table 5), exchange rate interactions (Table 4), département-specific trends (Table 6), and shorter event windows (Table 6). These systematically probe the exclusion restriction. The baseline price control result (β collapses from 0.025 to 0.003) is presented transparently as "devastating" evidence in Section 6.4. We reframe the finding as a composite effect and acknowledge openly that "the available cross-sectional variation cannot isolate [the UK-specific component] cleanly."

### Key Concern 2: Baseline price confounding
**Response:** We agree and now present this result prominently in Section 6.4 with the language "The interpretation is stark." This is arguably the paper's most important finding — that SCI proxies for baseline economic characteristics.

### Key Concern 3: Post-treatment SCI measurement
**Response:** We acknowledge this limitation explicitly (Section 7.5, "SCI timing"). No pre-2016 GADM2 vintage exists. We discuss the persistence assumption as "plausible but untestable." Obtaining pre-2016 UK-born census stocks for France would strengthen the analysis but requires data we cannot currently access.

---

## Response to Grok-4.1-Fast (Reviewer 2)

**Verdict:** MAJOR REVISION

### Key Concern 1: Design "not credible"
**Response:** We take this seriously. The paper now frames the identification as revealing *both* a UK-specific component (house/apartment heterogeneity, Channel geography) *and* a broader cosmopolitan-provincial divergence. The exchange rate results (Table 4) provide the most direct test — and the German placebo with exchange rates is also significant, confirming the structural limitation. We acknowledge this openly.

### Key Concern 2: Specification searching
**Response:** Fair criticism. The v2 paper now clearly separates the baseline specification (Table 2) from identification tests (Tables 3-6) and mechanism evidence (Tables 8-10). We note that the primary estimand (log SCI(UK) × Post) was specified before running robustness checks.

### Key Concern 3: Missing mechanism data
**Response:** We agree that buyer nationality data would be transformative. We note this as the primary direction for future work (Section 7.5, "Identification" limitation).

---

## Response to Gemini-3-Flash (Reviewer 3)

**Verdict:** MAJOR REVISION

### Key Concern 1: "Honest failure" framing
**Response:** We accept this characterization. The paper documents both the SCI's genuine network signal (permutation p = 0.038, property type heterogeneity, geographic concentration) and its limits (German placebo, baseline price confounding, trend sensitivity). The contribution is transparency about when and why reduced-form SCI designs fail to isolate country-specific effects.

### Key Concern 2: Claim calibration
**Response:** The v2 abstract and conclusion already state: "The UK-specific component is real but modest, operating within a broader post-2016 divergence of cosmopolitan and provincial France." We believe this accurately represents the evidence.

### Key Concern 3: Pre-trends rejection
**Response:** The v2 paper reports both the full joint test (p = 0.038) and the test excluding the τ = -4 outlier (p = 0.093) transparently. The département-specific trends result (Table 6, β = 0.015, p = 0.217) further acknowledges that differential trends partially drive the result. We state this openly: "D\'epartement-specific linear trends attenuate the UK coefficient to insignificance."

---

## Response to Exhibit Review (Gemini)

- **Table 2 restructuring:** Deferred to a future revision; current structure ensures all placebos are visible alongside the main result.
- **Table margin clipping (Tables 4, 6):** Fixed with adjustbox.
- **Exchange rate sign convention:** Added explanatory table note.
- **"German Placebo Problem" → "Benchmark":** Implemented per prose reviewer suggestion.
- **Missing raw trend figure:** Noted as a useful addition for a future version.

## Response to Prose Review (Gemini)

- **"Top-journal ready" assessment:** Encouraging. The Shleifer-style prose overhaul achieved the target.
- **"Kill throat-clearing" in intro:** Implemented — replaced "I confront the identification challenges directly" with "The main identification challenge is that UK-connected départements are also France's most cosmopolitan hubs."
- **Katz-style result leads:** Implemented in property type section.
- **Active voice in Data:** Implemented for Alsace-Moselle exclusion.
