# Initial Research Plan: Did India's GST Create a Common Market?

## Research Question

Did the implementation of India's Goods and Services Tax (GST) on July 1, 2017, reduce cross-state price dispersion, and did this convergence vary predictably with pre-reform tax heterogeneity and commodity-level tax rate changes?

## Motivation

Before GST, India's indirect tax system was a patchwork of state Value Added Taxes (VAT rates varied 5-15% across states and commodities), a Central Sales Tax (2% on interstate transactions with no input tax credit), state-level entry taxes, and octroi. This fragmented system created price wedges across state borders — a "united" market in name but a set of quasi-independent fiscal territories in practice. GST replaced this system with four national rate slabs (5%, 12%, 18%, 28%), full input tax credit for interstate transactions (via IGST), and elimination of cascading taxes. The reform was billed as India's most transformative fiscal policy since 1991 liberalization.

The core question: did this tax harmonization actually create a common market, as measured by convergence in consumer prices across states? And did the convergence follow the predicted pattern — larger adjustments where pre-GST tax wedges were larger?

## Identification Strategy

**Continuous-intensity difference-in-differences.** GST was a national policy (no untreated states), but treatment intensity varied because pre-GST indirect tax burdens differed across states. States with HIGHER pre-GST tax dependence faced larger effective tax rate changes, creating a natural continuous "dose" variable.

### Primary Specification (State × Month Level)

```
CPI_{s,t} = α_s + δ_t + β × (Post_t × Intensity_s) + X'_{s,t}γ + ε_{s,t}

Where:
  s = state (36 states/UTs)
  t = month (Jan 2013 - Dec 2025, 156 months)
  Post_t = 1 if t ≥ July 2017
  Intensity_s = pre-GST indirect tax revenue / GSDP (from RBI State Finances 2016-17)
  X_{s,t} = optional state-level controls (oil prices × state petrol tax, demonetization dummy)
  Cluster: state level
```

β < 0 implies high-tax states saw *relative* CPI decreases after GST (convergence).

### Event Study Specification

```
CPI_{s,t} = α_s + δ_t + Σ_{k≠-1} β_k × 1(t=k) × Intensity_s + ε_{s,t}

Where k indexes months relative to July 2017 (k = -54 to +102, omitting k = -1).
```

Flat pre-trend (β_k ≈ 0 for k < 0) is the key identification assumption.

### Triple-Diff (State × Commodity Group × Month)

```
CPI_{s,g,t} = α_sg + δ_gt + γ_st + β × (Post_t × State_Intensity_s × Commodity_ΔTax_g) + ε_{s,g,t}

Where:
  g = commodity group (Food, Clothing, Fuel, Housing, Miscellaneous, Pan/Tobacco)
  Commodity_ΔTax_g = magnitude of national tax rate change for commodity group g
  State × group FE (α_sg), group × time FE (δ_gt), state × time FE (γ_st) absorb all lower-order interactions
```

This is the strongest specification: convergence should be largest for commodity groups that experienced the biggest tax rate changes, in states that had the highest pre-GST tax burden.

## Expected Effects and Mechanisms

1. **Price convergence (primary):** High-tax states should see relative CPI declines after GST, especially for commodity groups where GST reduced effective tax rates (Food, Clothing, Consumer Electronics).

2. **Fuel & Light placebo:** Petroleum products were excluded from GST (states retained authority). Fuel & Light CPI should show NO differential convergence by state intensity — a powerful placebo test.

3. **Timing:** Effects should appear immediately in July 2017 (GST rate changes took effect on the first day) but may intensify over 6-12 months as supply chains adjust.

4. **Heterogeneity by sector:** Rural vs. Urban CPI may converge at different rates (rural consumption baskets are more food-heavy, and food saw larger tax reductions).

## Data Sources

| Variable | Source | Access | Coverage |
|----------|--------|--------|----------|
| State-level CPI (by commodity group, rural/urban/combined) | MoSPI eSankhyiki API | Confirmed: `api.mospi.gov.in/api/cpi/getCPIIndex` | 36 states, monthly, Jan 2013-Dec 2025 |
| Pre-GST indirect tax revenue by state | RBI State Finances 2016-17 | PDF: rbidocs.rbi.org.in | 28 states + UTs |
| GSDP by state | RBI DBIE / MoSPI NAS | Public tables | Annual, all states |
| GST commodity rate schedule | CBIC | Public: cbic-gst.gov.in | All goods/services |
| Pre-GST state VAT schedules | State finance departments | Published in RBI reports | Summary tables by state |

## Power Assessment

- **States:** 36 states/UTs with CPI data
- **Time periods:** 156 months (54 pre, 102 post)
- **Commodity groups:** 8 groups (Food & Beverages, Clothing & Footwear, Fuel & Light, Housing, Miscellaneous, Pan/Tobacco/Intoxicants, Consumer Food Price, General)
- **Total observations (triple-diff):** ~36 × 8 × 156 ≈ 44,928 state-group-months
- **Clustering:** 36 state clusters — above standard thresholds for cluster-robust inference
- **Pre-treatment months:** 54 — sufficient for placebo-in-time tests and event study

## Robustness Checks

1. **Alternative intensity measures:** (a) VAT revenue/GSDP, (b) pre-GST price dispersion, (c) binary high/low tax states
2. **Time windows:** (a) Exclude Nov 2016-Jun 2017 (demonetization transition), (b) Pre-COVID only (Jul 2017-Feb 2020), (c) Full sample with COVID indicators
3. **Placebo commodity:** Fuel & Light (excluded from GST) should show no effect
4. **Randomization inference:** Permute state intensity assignments, compute exact p-values (1000+ permutations)
5. **Callaway & Sant'Anna:** Treat high-tax states as "cohort" for heterogeneity-robust estimation
6. **Leave-one-out:** Exclude each state sequentially to check influence
7. **Confound controls:** (a) State-level oil prices × petrol tax interaction, (b) Demonetization intensity × post-Nov 2016 interactions

## Planned Paper Structure

1. Introduction (3 pages)
2. Background: India's Pre-GST Tax Architecture (3 pages)
3. Data and Measurement (3 pages)
4. Empirical Strategy (3 pages)
5. Results (5 pages)
6. Mechanisms and Heterogeneity (3 pages)
7. Robustness (3 pages)
8. Conclusion (2 pages)
9. References
10. Appendix: Additional tables and figures

Target: 28-30 pages main text.
