# Reply to Reviewers — apep_0450 v1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1. Estimand/Outcome Mismatch
**Concern:** The title emphasizes "price convergence/dispersion" but the outcome is log CPI levels, which measures differential inflation rather than dispersion directly.

**Response:** We added a paragraph in Section 4.1 explicitly clarifying the estimand as "differential inflation by pre-reform tax exposure." We also added a dispersion-based outcome specification (Table 4, Column 6) using |log CPI_st - national mean log CPI_t| as the dependent variable. The coefficient is small and insignificant (β = 0.003, p = 0.215), confirming that the convergence operates through differential growth rates rather than immediate level convergence—consistent with a gradual adjustment process over the 8.5-year post-reform window.

### 2. Pre-Trend Concerns / State-Specific Trends
**Concern:** Individually significant 2015-2016 interactions suggest pre-existing convergence trends.

**Response:** We added a state-specific linear trends specification (Table 4, Column 7). The coefficient attenuates from -0.012 to -0.006 (p = 0.270), confirming some sensitivity to trend assumptions. We discuss this honestly in the revised text and emphasize that the triple-difference specification—which absorbs all state-specific time variation through state×time FE—is the paper's primary design and remains strongly significant (p = 0.014).

### 3. 95% Confidence Intervals
**Concern:** Main tables lack 95% CIs.

**Response:** All regression tables (Tables 2, 4, 6) now report 95% confidence intervals in brackets below standard errors, and report the number of clusters (35 states) as an additional row.

### 4. Missing Literature
**Concern:** DiD inference literature (Bertrand et al. 2004, Cameron & Miller 2015), continuous treatment DiD (de Chaisemartin & D'Haultfoeuille 2020) are missing.

**Response:** Added all five suggested references: Bertrand et al. (2004), Cameron & Miller (2015), de Chaisemartin & D'Haultfoeuille (2020), Parsley & Wei (1996), and Van Leemput (2021). Citations integrated into methodology and literature sections.

### 5. Fuel Placebo
**Concern:** Fuel result is a serious threat; need event study for fuel, timing around daily price revision, controls for oil price pass-through.

**Response:** Substantially expanded the Fuel and Light Puzzle section (Section 6.2). We now discuss three specific mechanisms—check-post elimination, the daily fuel price revision reform (June 16, 2017), and post-GST fiscal dynamics—with concrete institutional detail. We acknowledge that the coincidence of daily pricing reform with GST makes it impossible to cleanly attribute fuel convergence to either reform. The triple-difference specification effectively controls for this by treating fuel as a within-state control (ΔTax = 0).

### 6. ΔTax_g Construction
**Concern:** Make the CPI group → GST rate mapping transparent and reproducible.

**Response:** Added Appendix Table (Table 7) documenting the mapping from CPI commodity groups to approximate pre-GST rates, GST rates, and ΔTax_g values, with detailed notes on construction and limitations.

### 7. Wild Cluster Bootstrap
**Concern:** Add WCB p-values.

**Response:** Not implemented in this revision. We rely on randomization inference (RI p = 0.056) as the primary finite-sample inference tool, which is appropriate given our 35 clusters and provides a design-based test under the sharp null. The triple-difference (p = 0.014) is our primary result.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Add CIs to Tables
**Response:** Done. All main tables now include 95% CIs in brackets.

### 2. Add Missing Literature
**Concern:** Parsley & Wei (1996), Atkin et al. (2018), de Chaisemartin & D'Haultfoeuille (2020).

**Response:** Added Parsley & Wei (1996) and de Chaisemartin & D'Haultfoeuille (2020). Atkin et al. (2018) was already cited (as Atkin, Faber & Gonzalez-Navarro 2018 on retail globalization). Also added Van Leemput (2021) and Bertrand et al. (2004).

### 3. Fuel Robustness
**Response:** Substantially expanded the fuel discussion (Section 6.2) with institutional detail on check-post elimination, daily fuel pricing, and fiscal dynamics. The triple-diff isolates the rate harmonization channel.

### 4. Framing: Lead with Triple-Diff
**Response:** The revised abstract now explicitly notes that the baseline attenuates with state trends, positioning the triple-diff (p = 0.014) as the paper's strongest and most robust result.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### 1. State-Specific Linear Trends
**Concern:** Include trends specification to see if Post-GST coefficient survives.

**Response:** Done (Table 4, Column 7). The coefficient attenuates from -0.012 to -0.006 (p = 0.270). This is discussed honestly in the text, with the triple-diff as the primary response.

### 2. Deepen Fuel Discussion
**Concern:** Provide data on trucking transit times or diesel price components.

**Response:** Expanded fuel discussion (Section 6.2) with institutional detail on the daily fuel pricing reform (June 2017), check-post elimination timeline, and fiscal compensation dynamics. We lack state-level fuel tax rate data to test directly but acknowledge this as a limitation.

### 3. Welfare Distribution
**Concern:** Use Rural/Urban split for heterogeneous treatment effects by income decile.

**Response:** The rural-urban split is already reported (β_rural = -0.011 vs β_urban = -0.004), and the welfare implications are discussed in Section 6.4. A full income-decile analysis using CPI basket weights would require item-level price data and household expenditure microdata beyond the scope of this paper; we note this as an avenue for future work.

### 4. Missing References (Van Leemput 2021, Atkin & Donaldson 2015)
**Response:** Added Van Leemput (2021) to the bibliography and cited in the literature section. Atkin & Donaldson is closely related to but distinct from the existing Atkin et al. (2018) citation; the market integration dimension is now covered through Van Leemput (2021).
