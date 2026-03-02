# Research Ideas — India: Gender × Caste

## Idea 1: The Caste Ceiling on Women's Work: How Social Norms Moderate the Returns to India's Rural Employment Guarantee

**Policy:** MGNREGA (Mahatma Gandhi National Rural Employment Guarantee Act) — phased rollout:
- Phase I: Feb 2006, 200 most backward districts
- Phase II: Apr 2007, +130 districts
- Phase III: Apr 2008, all remaining ~310 districts

**Outcome:** Village-level female employment outcomes from SHRUG:
- Census 2001 (pre) vs 2011 (post): Female workers by type (cultivator, agricultural laborer, household industry, other worker), female non-workers, female literacy
- EC 2005 (pre) vs 2013 (post): Female employment in non-farm establishments, female-owned firms
- SECC 2011: Household-level income sources, female-headed households by caste
- Nightlights 2000–2015: Annual proxy for economic activity (validates growth channel)

**Identification:** Staggered DiD exploiting MGNREGA's three-phase rollout across ~640 districts. Key innovation: triple-difference using within-district village-level variation in caste composition (SC share, ST share, non-SC/ST share) as the heterogeneity moderator. Treatment varies at district level; moderator varies at village level → interaction is identified from within-district caste variation, avoiding the mechanical correlation between backwardness index and SC/ST share.

Specification: ΔY_v = β₁ Phase_d + β₂(Phase_d × SC_Share_v) + β₃(Phase_d × ST_Share_v) + X_v'γ + δ_s + ε_v

With state FE: β₂ and β₃ tell us whether MGNREGA's female employment effects differ by village caste composition. With district FE: absorb β₁ but still identify the interactions from within-district caste variation.

Additional CS-DiD estimation using Callaway-Sant'Anna (2021) for group-time ATTs, with heterogeneity by SC/ST tercile.

**Why it's novel:**
1. First paper to decompose MGNREGA's gender effects along the caste hierarchy (SC vs ST vs upper-caste) at village level
2. Tests the "cultural constraints" vs "economic constraints" hypothesis: if β₂ > 0, MGNREGA was most transformative for women where norms were least restrictive (SC/ST villages)
3. Uses 596K villages — orders of magnitude larger than any existing MGNREGA gender study
4. The three-way caste decomposition (SC, ST, non-SC/ST) reveals distinct pathways: ST villages have bride-price traditions (more gender-egalitarian), SC villages have poverty-driven female labor force participation, and upper-caste villages have purdah/seclusion norms
5. Novel conceptual framework linking Sanskritization theory (Srinivas 1956) to modern employment policy

**Feasibility check:** Confirmed: SHRUG data (596K villages) downloaded locally with Census 2001/2011 PCA (female workers by type, SC/ST shares), EC 2005/2013 (female employment), SECC (household income sources by caste), nightlights 1992–2021. MGNREGA phase assignment data available from published sources. Not overstudied from this specific angle — existing MGNREGA papers (Imbert & Papp 2015 AER, Muralidharan et al. 2017 AER) focus on aggregate labor market effects, not the caste × gender decomposition at village level.

---

## Idea 2: Missing at the Margins: How India's Son Preference Varies with Economic Growth Across the Caste Hierarchy

**Policy:** Not a single policy — uses continuous nightlight growth (1992–2011) as the "treatment intensity" representing structural transformation. Instruments nightlight growth with distance to nearest highway/railroad (from SHRUG crosswalk: `pc11_td_br_dist`, `pc11_td_rail_dist`) or PMGSY road eligibility.

**Outcome:** Child sex ratio (ages 0–6) from Census 2001 and 2011 PCA:
- `pc01_pca_m_06` / `pc01_pca_f_06` → sex ratio 2001
- `pc11_pca_m_06` / `pc11_pca_f_06` → sex ratio 2011
- Change in sex ratio as outcome

**Identification:** Cross-sectional intensity design. Villages that experienced faster economic growth (nightlight increase 2001–2011) should show changes in child sex ratios. But the direction depends on caste:
- Upper-caste villages: Growth → higher dowry → more son preference → worse sex ratios
- ST villages (bride-price): Growth → no dowry incentive → sex ratios unchanged or improved
- SC villages: Intermediate — growth enables Sanskritization (adopting upper-caste norms including dowry/son preference)

Instrument nightlight growth with baseline infrastructure connectivity (distance to railroad, highway) from Census 2001.

**Why it's novel:**
1. Tests the provocative hypothesis that economic growth WORSENS gender inequality through the dowry/Sanskritization channel
2. First paper to use village-level child sex ratios × caste composition × economic growth at the 596K village scale
3. Three-way caste decomposition provides a clean test of the mechanism: if ST villages (bride-price culture) show no sex ratio worsening with growth, but upper-caste villages do, the dowry mechanism is confirmed

**Feasibility check:** Confirmed: Census 2001 and 2011 PCA have `m_06` and `f_06` (male/female ages 0–6) at village level via SHRUG. SC/ST shares available. Nightlights available annually. Infrastructure distance variables in crosswalk. Sample: ~500K+ rural villages with non-missing data.

---

## Idea 3: Breaking Purdah with Pavement: Caste-Specific Gender Returns to Rural Roads in India

**Policy:** PMGSY (Pradhan Mantri Gram Sadak Yojana) — India's rural roads program. Eligibility threshold: population ≥ 500 (plains), ≥ 250 (hills/tribal/desert areas).

**Outcome:** Same as Idea 1 (Census and EC female employment outcomes), plus:
- Female literacy change (Census 2001 → 2011)
- Female non-worker share (proxy for labor force withdrawal)
- EC 2013 female-owned establishments

**Identification:** Fuzzy RDD at the PMGSY population eligibility threshold. Running variable: Census 2001 village population. ITT estimates: compare villages just above/below 500 (plains) or 250 (hills). Heterogeneity: interact RDD treatment with SC/ST share.

Key concern: Population threshold applies to habitations, not Census villages. This introduces measurement error. Mitigation: (1) focus on small single-habitation villages near threshold; (2) use Census 2001 population as best available proxy; (3) report reduced-form ITT.

**Why it's novel:**
1. Asher & Novosad (2020 AER) studied PMGSY's economic effects but did NOT examine gender × caste heterogeneity
2. Tests whether roads help or hurt women: in upper-caste villages, roads may enable male out-migration for non-farm work while women stay home (widening the gender gap)
3. The RDD provides sharper identification than DiD

**Feasibility check:** Confirmed: Census 2001 village population available in SHRUG. All outcome variables available. Concern: without PMGSY OMMAS data on actual road construction, the RDD is an ITT only. McCrary test needed to check for manipulation at threshold. The habitation vs village measurement issue is a real limitation but addressable.

---

## Idea 4: The Double Bind: How SC/ST Political Reservation Affects Women's Outcomes Across Caste Lines

**Policy:** India's 2008 Delimitation Commission redesigned constituency boundaries and reassigned SC/ST reservation status. Some constituencies switched from General to SC-reserved (or vice versa), creating exogenous variation in political representation.

**Outcome:** Village-level outcomes (Census 2001 vs 2011): female literacy, female employment, child sex ratios. Aggregated to constituency level for the RDD.

**Identification:** RDD using SC/ST population share as the running variable (constituencies with SC share above a threshold get reserved). Compare constituencies just above/below the reservation threshold. Study effects on women's outcomes in reserved vs non-reserved constituencies.

**Why it's novel:**
1. Studies the intersection of caste representation and gender outcomes — does having an SC/ST MLA improve women's outcomes?
2. The 2008 delimitation provides quasi-random variation in reservation status
3. Could reveal whether political representation for one marginalized group (SC/ST) has positive spillovers for another (women)

**Feasibility check:** PARTIAL. The main challenge is mapping constituency boundaries to SHRUG villages. SHRUG v2.1 includes corrected Assembly Constituency definitions (`shrid_con07`, `shrid_con08` keys). However, the exact SC/ST population thresholds for reservation assignment are complex (depend on the Delimitation Commission's methodology, not a simple threshold). This makes the RDD running variable imprecise. Additionally, the delimitation is a one-time shock with no staggering.

---

## Idea 5: From Fields to Firms: The Gendered Structural Transformation of India's Villages, 1991–2013

**Policy:** No single policy — descriptive + causal analysis of India's structural transformation (agriculture → non-farm). Uses village-level Economic Census panel (1990, 1998, 2005, 2013) combined with Census panel (1991, 2001, 2011).

**Outcome:** Village-level sectoral composition of female employment:
- Census: Female cultivators, agricultural laborers, household industry workers, other workers, non-workers (1991, 2001, 2011)
- EC: Female employment in non-farm establishments (1990, 1998, 2005, 2013)
- Nightlights: Annual economic activity proxy

**Identification:** Part 1 (Descriptive): Document the divergent trajectories of female employment across the caste hierarchy using the 3-Census + 4-EC village panel. Part 2 (Causal): Use MGNREGA phased rollout (as in Idea 1) to test whether guaranteed public employment can break the pattern. Part 3 (Mechanism): Use SECC data to decompose effects by household poverty status within each caste group.

**Why it's novel:**
1. First village-level documentation of India's gendered structural transformation using the FULL SHRUG panel
2. The 640K-village × 3-Census panel is unprecedented in scale
3. Combines descriptive contribution (documenting the puzzle) with causal evidence (MGNREGA) and mechanism (SECC poverty)

**Feasibility check:** Confirmed: All data available in SHRUG. Census 1991 PCA may have fewer variables (no detailed worker categories), but 2001 and 2011 are comprehensive. EC data available for all 4 rounds. The descriptive part is straightforward; the causal part depends on MGNREGA phase data availability.
