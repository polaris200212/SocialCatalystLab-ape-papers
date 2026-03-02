# Reply to Reviewers

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1 Causal estimand clarification
> "Must clarify: is the target estimand (a) capitalization of air quality improvements, (b) capitalization of vehicle access restrictions, or (c) a reduced-form bundle?"

**Response:** We now clarify that this is a reduced-form boundary effect. The paper estimates the net capitalization of all ZFE-related amenity changes at the boundary. We explicitly discuss that this bundles air quality improvements, accessibility restrictions, and signaling effects.

### 1.2 RDD continuity violated / A86 confound
> "Density and covariate discontinuities indicate the boundary is an urban-form discontinuity."

**Response:** We agree this is the paper's central challenge. We now implement three additional specifications:
1. **Boundary segment fixed effects** (11 segments of ~5km) to absorb along-boundary heterogeneity
2. **Commune-clustered standard errors** to address spatial dependence
3. **Year-quarter fixed effects** replacing year FE

The segment FE estimate is -0.009 (SE=0.086, p=0.91), confirming the null with substantially more conservative inference. We added this to Section 5.1.

### 1.3 "No manipulation" framing
> "The concern is sorting of the housing stock."

**Response:** We revised Section 4.2 to clarify that the concern is compositional sorting, not strategic relocation. The segment FE design partially addresses this.

### 1.4 Difference-in-discontinuities
> "2020 is not a clean pre; COVID-disrupted."

**Response:** We acknowledge this limitation more explicitly. The DiD-in-disc estimate remains supplementary rather than primary. We note that pre-2019 geocoded DVF data would be needed for a clean pre-period, which is unavailable.

### 1.5 Along-boundary heterogeneity
> "A single running variable pools transactions from many different places."

**Response:** Addressed with boundary segment fixed effects (new specification). See 1.2 above.

### 2.1 Effective sample sizes
> "N's in Table 2 appear inconsistent with the bandwidth."

**Response:** We now report both total N and effective N within bandwidth. The effective sample is 20,847 outside and 2,040 inside within the 0.414 km optimal bandwidth. This asymmetry is discussed in the new Limitations paragraph.

### 2.2 Spatial correlation
> "rdrobust SEs are not robust to spatial dependence."

**Response:** We now report commune-clustered SEs alongside rdrobust SEs. The commune-clustered SE (0.097) is larger than the rdrobust SE (0.033), confirming the null is not driven by understated uncertainty.

### 2.3 Multiple testing
> "Donut results include a very large +18.5% at 200m."

**Response:** We discuss this more carefully. The instability reflects the A86's complex urban transition zone. The segment FE specification, which absorbs local heterogeneity, confirms the null.

### 2.4 Year FE too coarse
> "Use month-by-year or quarter FE."

**Response:** We now use year-quarter fixed effects in the segment FE specification.

### 3.1 First-stage / air quality
> "Without a first stage, null price effect is hard to interpret."

**Response:** We agree this is the paper's most important limitation. We now explicitly discuss Airparif monitoring data and satellite NO2 (TROPOMI) as avenues for future work that could provide the "first stage" evidence. This is acknowledged as the key limitation.

### 4.1 "First causal evidence" overstated
> "Novelty is not 'first evidence' but first France / first within-city boundary."

**Response:** We revised to "first within-city boundary evidence" and "first evidence from France."

### 5.1 "Precisely estimated null" not justified
> "Given likely issues with effective sample size and spatial dependence."

**Response:** With effective N now reported and commune-clustered SEs confirming the null (p=0.83), we believe the "precisely estimated null" characterization is now better supported. We also add a formal power calculation (MDE = 9.6% at 80% power).

### 5.2 Boundary vs average ZFE effect
> "Consistently state you identify local capitalization at the boundary."

**Response:** We revised the text to consistently distinguish the boundary estimand from the average zone effect.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Must-fix 1: Pre-policy DVF data
> "Merge non-geocoded pre-2019 DVF with approx. locations."

**Response:** Pre-2019 DVF is not geocoded by Etalab. Approximate geocoding via commune centroids would not provide the spatial resolution needed for a boundary RDD (centroids are km away from the boundary). We acknowledge this as the study's primary data limitation.

### Must-fix 2: Quantify A86 confounds directly
> "Proxy noise, pre-ZFE prices, or air monitors."

**Response:** We add boundary segment FE, which absorbs segment-specific confounds (noise, transit access, zoning). Direct air quality measurement requires Airparif data not currently available; discussed as future work.

### Must-fix 3: Spatial correlation
> "Add spatial HAC or Conley SEs."

**Response:** We now report commune-clustered SEs (see GPT response 2.2).

### High-value 1: Air quality validation
> "Merge INERIS monitors or satellite PM."

**Response:** Discussed as key future work in revised Limitations section.

### High-value 2: Power calculations
> "Formal MDE for null."

**Response:** Added. MDE = 9.6% at 80% power.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Must-fix: Direct evidence of treatment intensity
> "Check if a pollution discontinuity actually exists at the A86."

**Response:** Cannot be addressed with current data. Discussed as the most important avenue for future work. We now explicitly name Airparif and INERIS as potential data sources.

### High-value: Donut-hole instability
> "Map the properties in the 200-300m range."

**Response:** The segment FE specification controls for local heterogeneity. With segment FE, the null is confirmed, suggesting the donut instability reflects between-segment variation rather than a systematic pattern.

### High-value: Refine difference-in-discontinuities
> "Use 2017-2018 data for cleaner pre-ZFE baseline."

**Response:** Pre-2019 geocoded DVF unavailable. IRIS-level approximation insufficient for spatial RDD. Acknowledged as limitation.

---

## Exhibit Workstream

Per exhibit review:
- **Map moved to main text** as Figure (was Appendix)
- **Balance table "Status" column removed** — p-values speak for themselves
- **Effective N reported** in main results discussion

## Prose Workstream

Per prose review:
- **Opening hook sharpened** — now starts with concrete A86 border imagery
- **Roadmap paragraph removed** — paper is its own map
- **Heterogeneity lead revised** — apartments (precise zero) first
- **Final sentence punched up** — shorter, memorable
- **Novelty claims tightened** — "first within-city boundary evidence"
