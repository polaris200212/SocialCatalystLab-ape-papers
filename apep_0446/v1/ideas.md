# Research Ideas

## Idea 1: Digital Markets and Price Discovery — Evidence from India's e-NAM Agricultural Platform

**Policy:** The electronic National Agriculture Market (e-NAM), launched April 14, 2016, integrates India's fragmented agricultural mandis (wholesale markets) into a unified online trading platform. Rollout was staggered: 21 mandis in 8 states at launch → 250 by Nov 2016 → 585 by Mar 2018 → 1,000 by May 2020 → 1,361+ by 2024 across 23 states and 4 UTs. The platform enables electronic bidding, transparent price discovery, and inter-mandi trade.

**Outcome:** Daily mandi-level crop prices (modal, min, max) and arrival quantities from the CEDA Ashoka AgMarkNet dataset (agmarknet.ceda.ashoka.edu.in). The CEDA API provides JSON data for 453 commodities across 2,700+ mandis, with daily observations from 2006–2025. The API is confirmed working with no authentication required.

**Identification:** Staggered difference-in-differences exploiting the phased integration of ~1,000 mandis into e-NAM from 2016–2020. Treatment group: mandis integrated into e-NAM (identifiable from the official e-NAM Directory PDF). Control group: ~1,700 non-integrated mandis in the same CEDA dataset. Use Callaway-Sant'Anna (2021) heterogeneity-robust estimators to handle staggered treatment timing. Treatment cohorts defined at the state-phase level (8 states in Apr 2016, additional states through 2020). Pre-treatment period: 2007–2015 (8+ years), enabling strong parallel trends testing.

**Why it's novel:** No published large-scale, multi-state DiD study of e-NAM exists. The only existing work is either (a) descriptive (Reddy & Mehjabeen 2019), (b) tiny sample (Reddy 2016: 32 mandis in Karnataka only; SSRN 5259485: 2 mandis in AP), or (c) government reports. The literature gap is wide open for a rigorous application of modern staggered DiD methods to 1,000+ treated mandis across 20+ states. This directly extends the canonical literature on ICT and market integration (Jensen 2007 QJE mobile phones and Kerala fish markets; Aker 2010 mobile phones and grain prices in Niger) to the digital platform era.

**Feasibility check:**
- ✅ Variation: 1,000+ treated mandis staggered across 2016–2020; ~1,700 never-treated mandis
- ✅ Data access: CEDA Ashoka API confirmed working (POST to /api/prices with state_id, commodity_id, district_id; returns daily mandi-level data 2006–2025)
- ✅ Pre-periods: 8+ years (2007–2015) of pre-treatment daily price data
- ✅ Treated clusters: 23 states adopted e-NAM (far exceeds 20-state minimum)
- ✅ Novelty: No rigorous multi-state DiD in published literature
- ⚠️ Treatment date precision: Exact mandi-level integration dates not available in a single source; will use state-phase cohort assignment from PIB press releases and NAARM report

---

## Idea 2: One Nation, One Ration Card (ONORC) and Inter-State Economic Activity

**Policy:** ONORC enables PDS beneficiaries to access food grain from any Fair Price Shop nationwide via Aadhaar-linked biometric verification. Staggered state adoption from Aug 2019 (4 pilot states: AP, Telangana, Gujarat, Maharashtra) through June 2022 (Assam, 36th state/UT). Clean 3-year stagger with 36 treated units. Late adopters (Delhi, West Bengal, Chhattisgarh, Assam) were opposition-governed states — political selection is both a threat and a research angle.

**Outcome:** State-level monthly GST revenue (from GST Council press releases, July 2017–present) as proxy for formal economic activity; state-level PLFS employment aggregates (from MoSPI MCP Portal, quarterly 2017+).

**Identification:** Staggered DiD across 36 states/UTs. Monthly GST data provides 25+ pre-periods (July 2017–Aug 2019) for earliest adopters. CS-DiD with state and month fixed effects.

**Why it's novel:** No DiD study of ONORC exists. Tumbe & Jha (2024) is descriptive. World Bank WP 10549 is an RCT on information awareness. This would be the first causal estimate of ONORC's effects on economic activity.

**Feasibility check:**
- ✅ Variation: 36 states/UTs with staggered adoption 2019–2022
- ⚠️ Data access: GST revenue from press releases (requires web scraping); PLFS aggregates from MoSPI MCP (confirmed working)
- ⚠️ Pre-periods: Only 2 years for GST (July 2017–Aug 2019), but 25 monthly observations
- ✅ Novelty: No causal study exists
- ⚠️ Rapid adoption: 24/36 states by Aug 2020 → bulk of variation concentrated in one year
- ⚠️ Political selection: Late adopters are systematically different (opposition-governed)

---

## Idea 3: Aadhaar Enrollment and Financial Deepening — Evidence from India's Biometric Identity Rollout

**Policy:** Aadhaar (unique biometric ID) enrollment began in 2010 and expanded to 1.38 billion individuals by 2024. State-level enrollment rates varied significantly during the ramp-up period 2010–2017, driven by differences in enrollment infrastructure, state government cooperation, and population density. Aadhaar enabled simplified KYC for bank accounts, insurance, and other financial products.

**Outcome:** State-level banking indicators from RBI DBIE (confirmed working): bank branches per capita, aggregate deposits, credit, credit-deposit ratio. Annual data available from 2005+, providing 5+ years of pre-Aadhaar observations.

**Identification:** Intensity DiD using state-level Aadhaar enrollment rate as continuous treatment variable. Pre-period: 2005–2009 (banking data before Aadhaar). Post-period: 2010–2020. State and year fixed effects. Instrument: pre-existing state IT infrastructure × post-2010 dummy.

**Why it's novel:** Existing Aadhaar literature focuses on welfare delivery efficiency (Muralidharan et al. 2016 AER; 2023 Econometrica). The financial deepening channel — Aadhaar enabling bank account penetration beyond Jan Dhan — is underexplored with causal methods.

**Feasibility check:**
- ✅ Pre-periods: 5+ years (2005–2009 banking data)
- ⚠️ Treatment variation: Intensity design, not clean stagger; enrollment was fast everywhere
- ⚠️ Data access: RBI DBIE requires manual download from web portal (confirmed accessible)
- ⚠️ Confounders: Jan Dhan Yojana (Aug 2014) and demonetization (Nov 2016) confound Aadhaar's independent effect
- ⚠️ Novelty: Moderate — financial inclusion in India is well-studied, but Aadhaar-specific channel is less explored

---

## Idea 4: ONORC and Internal Migration Facilitation

**Policy:** Same as Idea 2 — ONORC staggered adoption 2019–2022.

**Outcome:** PLFS migration-related indicators (available in annual reports): inter-state migration rates, labor force participation by migrant status, sectoral employment composition in high-migration states.

**Identification:** Same staggered DiD as Idea 2. Focus specifically on migration outcomes rather than aggregate economic activity. Test whether PDS portability reduces migration costs and increases labor mobility.

**Why it's novel:** The migration facilitation hypothesis is central to ONORC's stated rationale. Tumbe & Jha (2024) document low inter-state portability uptake (<0.5M monthly transactions vs 20M+ intra-state). A causal test of whether ONORC actually affects migration would be highly policy-relevant, even (especially) if the result is null.

**Feasibility check:**
- ✅ Variation: Same as Idea 2
- ⚠️ Data access: PLFS migration data available only in annual reports (not via MCP API); state-level aggregates extractable from published tables
- ⚠️ Pre-periods: PLFS starts 2017-18 → only 2 annual pre-periods
- ⚠️ Sample size: PLFS state-level migration estimates may be noisy
- ✅ Novelty: High — no causal study of ONORC on migration
