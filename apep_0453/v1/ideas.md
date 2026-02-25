# Research Ideas — apep_0453

## Idea 1: Banking Infrastructure, Demonetization, and India's Structural Transformation

**Policy:** India's November 8, 2016 demonetization — overnight invalidation of 86.9% of currency in circulation (Rs 500/1000 notes, worth Rs 15.44 trillion / ~12.5% of GDP). A massive exogenous shock to the cash economy.

**Outcome:** SHRUG VIIRS annual nightlights (2012–2023) at the district level (640 districts × 12 years = 7,680 district-year observations). Secondary outcomes from Census PCA (2001, 2011) and Economic Census (2005, 2013) for heterogeneity analysis by pre-existing economic structure.

**Identification:** Continuous-treatment DiD (intensity design). Demonetization is a national shock; treatment intensity is measured by pre-existing banking infrastructure from Census 2011 Town Directory (government + private + cooperative bank branches per capita). Villages/districts with fewer bank branches had higher costs of note exchange → stronger negative shock. The identifying assumption is that conditional on district fixed effects and baseline characteristics × year trends, pre-existing bank branch density is not correlated with unobserved shocks to nightlights around November 2016.

**Why it's novel:** (1) The definitive paper — Chodorow-Reich, Gopinath, Mishra & Narayanan (2020, QJE) — operates at the district level (~700 units) using currency replacement ratios. No published paper uses SHRUG village/sub-district data. (2) The intensity measure is different: banking infrastructure (demand-side/access cost) vs. currency replacement (supply-side). (3) The time horizon extends through 2023, enabling analysis of both short-run disruption AND long-run recovery/structural change — did banking access accelerate formalization? (4) Heterogeneity by agricultural vs non-agricultural structure (from Economic Census) is untested.

**Feasibility check:**
- Variation: All 640 districts treated; banking density has strong cross-sectional variation (mean 4.9, SD 4.8 branches per 100K). ✓
- Data: VIIRS 2012–2023 at district level confirmed (640 districts). Census TD banking variables confirmed (635 merge). Census PCA and EC available. All in local SHRUG data. ✓
- Novelty: No SHRUG-based demonetization paper exists. Chodorow-Reich et al. (2020, QJE) and Chanda & Cook (2022, J. Macro) are the only published nightlights papers, both at district level. ✓
- Pre-periods: 4 clean (2012–2015) + 2016 partial. ✓
- Post-periods: 7 (2017–2023). ✓
- Sample: 640 districts clustered in 28+ states. ✓

---

## Idea 2: One Nation One Ration Card and State Economic Activity

**Policy:** India's One Nation One Ration Card (ONORC) system — PDS portability enabling ration card holders to access food grains at any fair price shop nationwide. Staggered state adoption: 4 states (Aug 2019) → 36 states/UTs (June 2022) across 14 distinct cohorts. Key mechanism: removing food security barriers to interstate labor mobility.

**Outcome:** SHRUG VIIRS nightlights at state level (monthly or annual), measuring aggregate economic activity in migrant-receiving states (Maharashtra, Gujarat, Karnataka, Tamil Nadu, Delhi) vs migrant-sending states (Bihar, UP, Odisha, Jharkhand, Chhattisgarh).

**Identification:** Staggered DiD using state-level adoption dates. 14 cohorts over 3 years. Early adopters (AP, Gujarat, Maharashtra, Telangana in Aug 2019) vs late adopters (Delhi July 2021, West Bengal Aug 2021, Chhattisgarh Feb 2022, Assam June 2022). Callaway-Sant'Anna estimator for heterogeneous treatment effects.

**Why it's novel:** No published causal study uses ONORC's staggered adoption for DiD. Only descriptive work exists (Tumbe & Jha 2024) and an RCT on information treatment (World Bank WP 10549). A clean staggered DiD would be genuinely novel.

**Feasibility check:**
- Variation: 14 cohorts, 36 states/UTs. ✓
- Data: State adoption dates documented (PIB press releases). Nightlights at state level from SHRUG. ✓
- Novelty: No causal DiD paper exists. ✓
- **CONCERN: COVID confound.** Bulk of rollout (May–Dec 2020) coincides with India's lockdown. 20 of 36 states joined during COVID. Would need to control for lockdown severity or restrict to post-COVID comparisons (late adopters 2021–2022 vs early pre-COVID adopters).
- **CONCERN: Low utilization.** Interstate portability transactions are <500K/month vs 20M+ intrastate. Effects may be undetectable.
- Pre-periods: 2012–2018 (7 years for early adopters). ✓
- Treated clusters: 36 states/UTs. ✓

---

## Idea 3: Ayushman Bharat PM-JAY and District-Level Health Utilization

**Policy:** India's Ayushman Bharat PM-JAY — world's largest government health insurance program (500M+ eligible, Rs 5 lakh/family/year coverage). Launched September 2018. Most states adopted within 6 months; holdouts: West Bengal (never), Odisha (Jan 2025), Delhi (April 2025), Telangana (rejoined May 2021).

**Outcome:** District-level health facility utilization from HMIS (monthly, 2008–present): institutional deliveries, OPD/IPD visits, immunization. Secondary: NFHS-4 (2015–16) vs NFHS-5 (2019–21) for household-level insurance coverage and OOP spending.

**Identification:** Within-state district-level implementation intensity design. Rather than state adoption timing (near-simultaneous), exploit variation in district-level e-card issuance rates and empaneled hospital density. Districts with more PM-JAY infrastructure → higher effective treatment intensity.

**Why it's novel:** No published top-journal DiD paper on PM-JAY exists despite being the world's largest health insurance program. RSBY predecessors showed null results (Karan et al. 2017, SSM). "Did PM-JAY succeed where RSBY failed?" is a compelling research question.

**Feasibility check:**
- Variation: District-level intensity within states. ~640 districts. Conditional on data availability. ⚠️
- Data: HMIS accessibility uncertain (smoke test FAIL in scoping notes). PM-JAY dashboard not downloadable. ⚠️
- Novelty: Wide open — no rigorous evaluation published. ✓
- **CONCERN: HMIS data access.** Server was unreachable during SHRUG scoping. Need to verify.
- **CONCERN: COVID confound.** PM-JAY launched Sep 2018; COVID hit Mar 2020. Only 18-month pre-COVID window.
- **CONCERN: Near-simultaneous adoption** at state level makes standard staggered DiD infeasible.

---

## Idea 4: RERA (Real Estate Regulation Act) and Construction Sector Formalization

**Policy:** The Real Estate (Regulation and Development) Act, 2016, mandated project registration, escrow accounts, and transparency for developers. State-level implementation varied: Maharashtra (May 2017, early mover), other states 2017–2018. Some states implemented weak versions (diluted rules). Strong inter-state variation in regulatory quality.

**Outcome:** Nightlights in urban areas (VIIRS), construction employment (PLFS state-level aggregates), RBI credit data to real estate sector.

**Identification:** Staggered state-level DiD using RERA implementation dates. Compare urban nightlight growth in early-implementing vs late-implementing states. Heterogeneity by pre-existing developer market structure.

**Why it's novel:** No published DiD evaluation of RERA's economic effects exists. The literature is qualitative/legal.

**Feasibility check:**
- Variation: State-level implementation timing 2017–2018. Moderate stagger. ⚠️
- Data: Nightlights available. RERA implementation dates would need web research. ⚠️
- Novelty: Unstudied econometrically. ✓
- **CONCERN: Short stagger window** — most states implemented within 12 months of each other.
- **CONCERN: Weak variation** — difficult to distinguish RERA effects from GST (same period) and demonetization aftermath.
- Pre-periods: Limited (RERA implemented 2017, demonetization was 2016). ⚠️

---

## Summary Ranking (Pre-GPT)

| Rank | Idea | Strength | Key Risk |
|------|------|----------|----------|
| 1 | Demonetization + Banking | Very Strong | QJE paper exists at district level |
| 2 | ONORC + Economic Activity | Moderate | COVID confound, low utilization |
| 3 | PM-JAY + Health Utilization | Moderate | Data access uncertain, near-simultaneous |
| 4 | RERA + Construction | Weak | Short stagger, confounded period |
