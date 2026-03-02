# Research Ideas

## Idea 1: Did India's GST Create a Common Market? Evidence from State-Level Price Convergence

**Policy:** India's Goods and Services Tax (GST), implemented July 1, 2017. Replaced a fragmented patchwork of state-level VAT (rates varied 5-15% by state and commodity), Central Sales Tax (2% on interstate transactions with no input credit), entry taxes, and octroi. Unified into 4 national slabs: 5%, 12%, 18%, 28%.

**Outcome:** State-level Consumer Price Index (CPI) from MoSPI eSankhyiki API. Monthly data for 36 states/UTs, January 2013-December 2025 (156 months). Available by commodity group: Food & Beverages, Clothing & Footwear, Fuel & Light, Housing, Miscellaneous, Pan/Tobacco/Intoxicants + General index. Rural, Urban, and Combined sectors. **API confirmed working:** `GET https://api.mospi.gov.in/api/cpi/getCPIIndex` returns real data, no auth required.

**Identification:** Continuous-intensity difference-in-differences. The "treatment" is GST-induced tax harmonization, which varied across states because pre-GST indirect tax burdens differed. States with HIGHER pre-GST indirect tax revenue (as share of GSDP) faced LARGER effective tax rate changes from GST. Treatment intensity = (pre-GST state indirect tax revenue / GSDP) from RBI State Finances reports (publicly available PDFs with state-wise data). Post = July 2017+. Specification: CPI_{s,g,t} = α_s + γ_g + δ_t + β × (Post_t × Intensity_s) + ε_{s,g,t}. Additional heterogeneity by commodity group: goods whose effective tax rates changed more (e.g., textiles went from ~5% VAT to 5-12% GST; restaurant food from ~18-20% to 5%) should show larger price adjustments. Cluster SEs at state level.

**Why it's novel:** Kumar, Kakarlapudi & Renjith (2025, Springer chapter) tested price convergence but used simple beta/sigma convergence without causal identification. Barnwal, Dingel et al. (JDE forthcoming) studied border checkpost removal (transport cost mechanism), not tax harmonization per se. No rigorous DiD study using continuous treatment intensity and commodity-group heterogeneity exists. This paper brings modern econometric methods (CS-DiD, randomization inference, commodity-level triple-diff) to India's biggest tax reform.

**Feasibility check:**
- Variation: 36 states/UTs with heterogeneous pre-GST tax burdens ✓
- Data access: MoSPI CPI API tested and confirmed (36 states × 156 months × 8 commodity groups) ✓
- Pre-treatment periods: 54 months (Jan 2013-Jun 2017) ✓
- Not overstudied: No top-journal DiD paper on GST price convergence exists ✓
- Sample size: ~36 states × 156 months × 8 groups = ~44,928 state-group-month observations ✓
- Confound management: Demonetization (Nov 2016) is 8 months pre-GST; include as separate event. COVID (Mar 2020) handled with period indicators.

---

## Idea 2: One Nation, One Ration Card and Rural Labor Market Flexibility

**Policy:** ONORC (One Nation One Ration Card), enabling PDS portability. Staggered state adoption from August 2019 (4 pilot states: AP, Telangana, Gujarat, Maharashtra) through June 2022 (all 36 states/UTs). Clean 3-year stagger documented in IMPDS system. Tumbe & Jha (2024) documented limited interstate uptake (~0.5M/month interstate vs ~21M intrastate portable transactions).

**Outcome:** (a) State-level PLFS annual labor indicators from MoSPI API: LFPR, WPR, unemployment rate, average casual wages (2017-18 to 2023-24, 7 years). **API confirmed working:** `GET https://api.mospi.gov.in/api/plfs/getData`. (b) State/district-level MGNREGA person-days from nrega.nic.in MIS (publicly accessible without login, FY 2006-present).

**Identification:** Staggered DiD using Callaway & Sant'Anna estimator. Treatment = first month/year of ONORC activation in each state. Never-yet-treated states serve as comparison until they adopt. 36 states/UTs with 3-year stagger. Pre-period: 2017-2019 for PLFS (2-3 years); 2006-2019 for MGNREGA (13 years). Cluster at state level.

**Why it's novel:** Tumbe & Jha (2024) was descriptive (documenting transaction patterns), not causal. No DiD study of ONORC's labor market effects exists. The hypothesis — that PDS portability reduced MGNREGA dependency by facilitating within-state labor mobility — is policy-relevant and testable.

**Feasibility check:**
- Variation: 36 states, staggered over 3 years ✓
- Data access: MoSPI PLFS API confirmed; MGNREGA MIS publicly accessible ✓
- Pre-treatment periods: 2-3 years (PLFS) or 13 years (MGNREGA) — PLFS is borderline ✗/✓
- Not overstudied: No causal ONORC paper in economics literature ✓
- Sample size: 36 states × 7 annual PLFS rounds = 252 state-year observations ✓
- Concern: PLFS pre-period is short (2 annual rounds for early adopters). MGNREGA outcome gives longer baseline but different mechanism.

---

## Idea 3: NFSA State Implementation and Local Food Price Dynamics

**Policy:** National Food Security Act (NFSA), enacted September 2013, but state implementation staggered 2013-2016. 11 states implemented by October 2014 (Bihar, Chandigarh, Chhattisgarh, Delhi, Haryana, HP, Karnataka, MP, Maharashtra, Punjab, Rajasthan). Remaining states joined through 2015-2016 (Gujarat last in 2016). NFSA mandated subsidized grain at Rs. 1-3/kg for 67% of population.

**Outcome:** State-level CPI Food & Beverages index from MoSPI API (same data source as Idea 1). Monthly × 36 states × 2013-2025.

**Identification:** Staggered DiD using state-level NFSA implementation dates. Early adopters (2013-2014) vs late adopters (2015-2016). Theory: massive subsidized grain supply → reduced demand for market food → lower market food prices (substitution effect). Alternative: NFSA → increased food demand among poor → higher food prices (income effect). Direction is an empirical question.

**Why it's novel:** NFSA's effects on market food prices (general equilibrium price effects) are understudied. Most NFSA research focuses on nutritional outcomes or PDS leakage, not market price spillovers.

**Feasibility check:**
- Variation: ~25 states with varying implementation dates over 2-3 years ✓
- Data access: MoSPI CPI API confirmed ✓
- Pre-treatment periods: Jan 2013 is both NFSA enactment and CPI start date — very short pre for early adopters ✗
- Concern: Compressed implementation window (most states by 2014-2015) limits stagger. State-specific implementation dates hard to verify precisely. ✗
- Sample size: 36 × 156 months adequate ✓

---

## Idea 4: Jan Dhan Banking Expansion and Rural Credit Growth

**Policy:** Pradhan Mantri Jan Dhan Yojana (PMJDY), launched August 28, 2014. India's financial inclusion initiative opening 530+ million new bank accounts by 2024. National shock with cross-sectional intensity: states/districts with LOWER pre-2014 banking penetration received a bigger "dose" of financial inclusion.

**Outcome:** State-level credit and deposit data from RBI DBIE (state-wise credit deployment, annual/quarterly). Also PLFS earnings data (MoSPI API) to test whether banking access affected wages or self-employment income.

**Identification:** Continuous-intensity DiD. Intensity = (1 - pre-2014 bank account penetration rate) or (inverse of pre-2014 bank branches per capita). States/districts that were MORE financially excluded got a larger marginal effect from Jan Dhan. Pre: 2010-2014. Post: 2015-2024.

**Why it's novel:** Jan Dhan has been studied for account opening patterns, but the downstream effects on state-level credit growth and wage dynamics through the lens of modern DiD methods are less explored. Agarwal et al. focused on household-level effects using CMIE; a state-level study using public data with intensity design fills a different niche.

**Feasibility check:**
- Variation: 36 states with heterogeneous pre-existing banking infrastructure ✓
- Data access: RBI DBIE has state-level credit/deposit tables (downloadable Excel); MoSPI PLFS API confirmed ✓
- Pre-treatment periods: 4+ years (2010-2014) using RBI data ✓
- Concern: Jan Dhan is well-studied (not as novel as GST convergence) ✗
- Sample size: 36 states × 15+ years adequate ✓

---

## Idea 5: Demonetization, Digital Payments, and the Formalization of India's Economy

**Policy:** Demonetization of Rs. 500 and Rs. 1,000 notes, announced November 8, 2016. Overnight removal of 86% of currency in circulation. National shock with cross-sectional intensity: states with higher cash dependence (lower banking penetration, more informal economy) were MORE affected.

**Outcome:** (a) State-level CPI from MoSPI (price effects), (b) PLFS employment structure from 2017-18 onward (formalization — shift from casual/self-employment to regular wage employment), (c) GST revenue from July 2017 onward (as proxy for formal sector activity by state).

**Identification:** Continuous-intensity event study. Intensity = pre-demonetization cash dependence (e.g., ATM withdrawals per capita, or inverse of digital payment penetration). Specification: Y_{s,t} = α_s + δ_t + Σ_k β_k × 1(t=k) × Intensity_s + ε_{s,t}. Pre-trends test using 2013-2016 monthly CPI data. Post-demonetization: Nov 2016 onward.

**Why it's novel:** Chodorow-Reich et al. (2020, AER) studied demonetization using district-level nightlights and employment. But the longer-run formalization question — did demonetization permanently shift India toward formal/digital economy? — remains open, especially with 9 years of post-event data now available. Using PLFS (unavailable in 2020) adds direct employment evidence.

**Feasibility check:**
- Variation: 36 states with heterogeneous cash dependence ✓
- Data access: MoSPI CPI API confirmed; PLFS API confirmed; GST data from GST Council press releases ✓
- Pre-treatment periods: 47 months (Jan 2013-Oct 2016) for CPI ✓
- Concern: Extensively studied (Chodorow-Reich et al. 2020; many others). Need very clear novelty claim. ✗
- Sample size: Adequate ✓
- Confound: GST (July 2017) is 8 months after demonetization — hard to disentangle effects in PLFS data that starts 2017-18 ✗
