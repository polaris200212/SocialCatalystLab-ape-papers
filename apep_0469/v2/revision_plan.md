# Revision Plan: apep_0469 v1 → v2

## Core Problem

v1 used IPUMS 1% samples (`us1930a`, `us1940a`, `us1950a`) as **pooled repeated cross-sections**. HISTID was not requested, not available in 1% samples, and no longitudinal linking was performed. The "individual panel" (`indiv_panel`) in `02_clean_data.R` is just different people from 1940 and 1950 stacked together. This violates the user's core request for MLP linked longitudinal census data.

## Solution

Use IPUMS **full-count (100%) databases** (`us1930d`, `us1940b`, `us1950b`) which include HISTID — the person linkage key that enables tracking the same individuals across censuses. This creates a true within-person panel of millions of linked individuals.

## Workstreams

### WS1: Data Pipeline (01_fetch_data.R, 02_clean_data.R)

1. **Fetch**: Submit IPUMS extract #195 (full-count 1930/1940/1950 with HISTID, ~400M records)
2. **Link**: Match individuals across censuses using HISTID
   - 1940→1950 link: Primary analysis sample
   - 1930→1940→1950 link: Three-wave panel for pre-trend validation
3. **Panel construction**: For each linked individual, compute ΔY (change in LFP, occ score, SEI) between waves
4. **Selection analysis**: Compare linked vs unlinked individuals to assess linkage bias
5. **Memory management**: Use Arrow/data.table chunked processing for ~400M records with 96GB RAM

### WS2: Analysis (03_main_analysis.R, 04_robustness.R)

1. **Primary specification**: Individual first-difference regression
   - ΔY_i = α + β·Mob_s + γ·X_{i,1940} + δ_region + ε_i
   - Where ΔY is within-person change in outcome, Mob is state mobilization
2. **Individual FE panel**: Y_it = α_i + β·(Post × Mob_s) + ε_it for two-period panel
3. **Triple-diff**: Female × Post × Mobilization with individual FE
4. **Decomposition**: Oaxaca-Blinder decomposition
   - Aggregate convergence = within-person female gains + within-person male losses + compositional shifts
5. **Pre-trend validation**: Apply same spec to 1930→1940 changes (should be zero)
6. **All robustness from v1**: RI, HC3, LOO, ANCOVA (upgraded to panel context)

### WS3: Paper (paper.tex)

1. Rewrite abstract and introduction to center on longitudinal contribution
2. New Data section describing HISTID linking, match rates, sample construction
3. New methodology section for within-person design
4. Decomposition section as primary contribution
5. Updated results narrating within-person estimates
6. Maintain all v1 robustness but add panel-specific diagnostics

### WS4: Review & Publish

1. Fresh advisor review (3/4 must PASS)
2. Exhibit + prose review
3. External referee reviews
4. Address feedback, publish with `--parent apep_0469`

## Execution Order

WS1 → WS2 → WS3 → WS4 (strictly sequential — each depends on the previous)

## Verification Criteria

- `has_histid = TRUE` in track_info.rds
- Linked panel N > 1 million individuals (1940→1950)
- Within-person ΔY regressions run and produce real coefficients
- Paper explicitly describes HISTID linking methodology
- No reference to "pooled cross-sections" or "stacked panel" in the main text
