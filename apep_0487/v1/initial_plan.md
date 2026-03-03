# Initial Research Plan: Voting Their Wallet?

## Research Question

Do healthcare providers whose income depends on Medicaid become more politically engaged when Medicaid expands? Specifically: does the ACA Medicaid expansion — which created a large positive revenue shock for safety-net providers — cause providers with high Medicaid dependence to increase their political donations, and do those donations flow toward candidates who support the program?

## Motivation

Healthcare providers receive $1.09 trillion annually from Medicaid (T-MSIS, 2018–2024). A fundamental question in political economy is whether government transfer programs create durable political constituencies among their beneficiaries. The literature has established this for voters (Clinton & Sances 2018; Baicker & Finkelstein 2019) and for firms (AEA 2026 rent-seeking paper). But we know almost nothing about whether *providers* — the supply side — become politically engaged to protect the programs that fund them.

This gap is puzzling because providers have far more resources, organization, and political access than beneficiaries. If Medicaid creates a provider constituency, it has profound implications for the political persistence of entitlement programs, regulatory capture, and the political economy of healthcare reform.

Complicating this: Bonica et al. (2014) show that physicians lean Republican despite benefiting enormously from government insurance programs. This creates a tension between ideology and economic interest that our data can directly test.

## Key Literature

- **Kim (2024):** Links 309K physicians' DIME contributions to Medicare claims. Finds 13% spending gap by party. Medicare-FEC only; no Medicaid.
- **Jena et al. (2018) BMJ:** Links Medicare claims to DIME via NPI. Null result on end-of-life spending differences. Reverse causal direction (politics → clinical).
- **Bonica, Rosenthal, Rothman (2014) JAMA Int Med:** Maps physician political ideology. 311K physician contributors matched from 1M NPI records. Physicians lean Republican; women, younger, and lower-paid specialties lean Democratic.
- **Clinton & Sances (2018) APSR:** Medicaid expansion increases voter registration among *beneficiaries*. Provider side unstudied.
- **Baicker & Finkelstein (2019):** Oregon HIE — Medicaid expansion increases *beneficiary* voter participation.

**Our contribution fills the gap:** First Medicaid claims × FEC linkage. First causal evidence on policy → provider political behavior. The literature's two branches (provider politics → clinical behavior; policy → beneficiary participation) have never been connected through the provider side.

## Identification Strategy

### Primary: Triple-Difference (DDD)

**Treatment:** Staggered ACA Medicaid expansion for 7 late-expanding states within the T-MSIS window:

| State | Expansion Date | Pre-periods (cycles) | Post-periods (cycles) |
|-------|---------------|---------------------|----------------------|
| Virginia | Jan 2019 | 1 (2018) | 3 (2020, 2022, 2024) |
| Maine | Jan 2019 | 1 (2018) | 3 (2020, 2022, 2024) |
| Idaho | Jan 2020 | 1 (2018) | 3 (2020, 2022, 2024) |
| Nebraska | Oct 2020 | 1 (2018) | 2 (2022, 2024) |
| Missouri | Oct 2021 | 2 (2018, 2020) | 2 (2022, 2024) |
| Oklahoma | Jul 2021 | 2 (2018, 2020) | 2 (2022, 2024) |
| South Dakota | Jul 2023 | 3 (2018, 2020, 2022) | 1 (2024) |

**Never-treated:** 10 non-expansion states (TX, FL, GA, WI, WY, MS, AL, SC, TN, KS)

**Three differences:**
1. **State × time:** Expansion vs. non-expansion states, before/after expansion
2. **Provider Medicaid dependence:** High vs. low share of revenue from Medicaid (continuous, measured pre-expansion)
3. **Before/after:** Election cycle timing relative to state expansion date

### Specification

Y_{i,s,t} = β₁(Expand_{s,t} × MedShare_i) + β₂(Expand_{s,t}) + β₃(MedShare_i × Post_t) + α_i + γ_{s,t} + δ(MedShare_i × t) + X_{i,t}' Γ + ε_{i,s,t}

Where:
- Y_{i,s,t}: Political donation outcome for provider i in state s during election cycle t
- Expand_{s,t}: 1 if state s has expanded Medicaid by cycle t
- MedShare_i: Pre-expansion Medicaid revenue share (from T-MSIS ÷ (T-MSIS + Medicare PUF))
- α_i: Provider fixed effects
- γ_{s,t}: State × cycle fixed effects
- X_{i,t}: Time-varying controls (BLS county unemployment, ACS demographics)
- Clustering: State level (51 clusters)

β₁ is the DDD estimand: the differential change in political donations for high-Medicaid-dependence providers in expanding states, relative to low-dependence providers in the same state and high-dependence providers in non-expanding states.

### Expected Effects and Mechanisms

**Primary hypothesis:** β₁ > 0 — Medicaid expansion increases political donations among providers who benefit most.

**Mechanism decomposition:**
1. **Income effect:** Higher revenue → more disposable income → more donations (test: effect concentrated in small practices where personal income directly affected)
2. **Political investment:** Providers invest in protecting their revenue source (test: donations shift toward pro-ACA candidates, health committee members)
3. **Ideology vs. wallet:** Does the effect differ by baseline provider party? Do Republican-leaning physicians who benefit from expansion shift donations?

**Alternative hypothesis:** β₁ ≤ 0 — Ideology dominates economic interest. Providers don't change political behavior in response to revenue shocks. This would be a precisely bounded null, still publishable if well-powered.

### Built-in Placebos

1. **Low-Medicaid-dependence providers** in expanding states: should NOT see differential donation changes
2. **High-Medicaid-dependence providers** in non-expanding states: same provider type, no treatment
3. **Donations to non-health committees** (NRA, environmental, arts): should NOT shift differentially
4. **Cosmetic/elective-only providers** in expanding states: no Medicaid revenue exposure
5. **Pre-treatment trends** in donation behavior (2018 cycle)

### Robustness

- Callaway-Sant'Anna (2021) for staggered adoption
- HonestDiD/Rambachan-Roth sensitivity bounds for pre-trend violations
- Wild cluster bootstrap (51 state clusters)
- Randomization inference (permute expansion timing across states)
- Leave-one-out (drop each expansion state)
- Alternative matching: probabilistic (fastLink) vs. deterministic
- Lee (2009) trimming bounds for false-match attenuation

## Data

### Core Datasets

| Dataset | Source | Role | Size |
|---------|--------|------|------|
| T-MSIS | Local Parquet | Provider Medicaid billing | 227M rows, 2.74 GB |
| NPPES | CMS bulk download | Provider name, state, ZIP, specialty | ~9.4M providers |
| FEC Schedule A | FEC bulk download | Individual political donations | ~5-8 GB/cycle |
| Medicare Physician PUF | data.cms.gov | Cross-payer revenue denominator | NPI-level |
| Census ACS | API (CENSUS_API_KEY) | County-level demographics | County × year |
| BLS QCEW | Direct CSV | County employment/wages | County × quarter |
| FRED | API (FRED_API_KEY) | State unemployment | State × month |

### Panel Construction

Unit: Provider (NPI) × Election Cycle (2018, 2020, 2022, 2024)

**From T-MSIS:** Total Medicaid revenue, claims, beneficiaries by provider. Compute Medicaid revenue share = T-MSIS paid / (T-MSIS paid + Medicare PUF paid).

**From FEC:** Total donations, number of donations, share to Democratic/Republican candidates, share to health committee members. Aggregate by provider-election cycle.

**From NPPES:** State, ZIP, specialty, entity type, gender, enumeration date.

### Exposure Alignment (DiD Requirements)

- **Who is treated?** Providers with high pre-expansion Medicaid revenue share in states that expanded during 2019-2024
- **Primary estimand population:** Individual providers (NPPES Entity Type 1) who bill both Medicaid and make FEC donations
- **Placebo/control population:** Low-Medicaid-dependence providers in expansion states; all providers in non-expansion states
- **Design:** DDD (expansion × Medicaid dependence × time)

### Power Assessment

- **Pre-treatment periods:** 1-3 election cycles per state (depending on expansion timing)
- **Treated clusters:** 7 expansion states
- **Never-treated clusters:** 10 non-expansion states
- **Post-treatment periods:** 1-3 cycles per cohort
- **Expected matched providers:** 30,000-90,000 per cycle (conservative)
- **MDE:** With N = 50,000+ provider-cycles and 17 state clusters, power is sufficient to detect a 2-3 percentage point change in donation probability (base rate ~15-25% for physicians)

## Analysis Plan

### R Scripts

| Script | Purpose |
|--------|---------|
| `00_packages.R` | Load libraries, set themes |
| `01_fetch_data.R` | Download FEC bulk, Medicare PUF, NPPES, ACS, QCEW |
| `02_clean_data.R` | Build provider panel, match T-MSIS → NPPES → FEC |
| `03_main_analysis.R` | DDD regressions, event studies, CS-DiD |
| `04_robustness.R` | Placebos, HonestDiD, bootstrap, RI, leave-one-out |
| `05_figures.R` | Event-study plots, maps, descriptive figures |
| `06_tables.R` | Summary stats, regression tables |

### Key Figures

1. **Map:** Geographic distribution of Medicaid provider-donors (heat map by state)
2. **Descriptive:** Donation patterns by Medicaid dependence quartile (pre-expansion)
3. **Event study:** DDD coefficients by cycle relative to expansion
4. **Mechanism:** Donation direction (Dem vs. Rep) by Medicaid dependence × expansion status
5. **Placebo:** Non-health committee donations (should be flat)

### Key Tables

1. **Summary statistics:** Provider characteristics by expansion status and Medicaid dependence
2. **Linkage quality:** Match rates, validation statistics, FEC occupation concordance
3. **Main DDD results:** Extensive margin (any donation), intensive margin ($ amount), direction
4. **Mechanism decomposition:** By candidate party, committee assignment, provider specialty
5. **Robustness:** CS-DiD, HonestDiD bounds, bootstrap, RI, leave-one-out
6. **Placebo results:** Low-dependence providers, non-health donations, cosmetic providers

## Extensions

1. **Medicaid unwinding (2023+):** Symmetric negative shock — does losing patients/revenue change political behavior? (Limited to one post-cycle.)
2. **HCBS rate shocks:** ARPA-funded rate increases as an additional treatment, restricted to T-code billing providers.
3. **Cross-payer heterogeneity:** Do providers with balanced Medicaid-Medicare portfolios respond differently than Medicaid-only providers?
