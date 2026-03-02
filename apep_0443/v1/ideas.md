# Research Ideas

## Idea 1: Party Alternation and Local Economic Development — A Close-Election RDD from Indian State Assemblies

**Policy:** Indian state assembly elections — democratic competition as a governance mechanism. India's distinctive "anti-incumbency" pattern means incumbent parties lose seats at ~50% rates (vs. ~90% retention in US), creating abundant close races where party control changes.

**Outcome:** Constituency-level nightlights (DMSP 1994–2013 + VIIRS 2012–2023) from SHRUG, pre-aggregated to `ac07_id` and `ac08_id` constituency codes. Census 2011 demographics as controls and secondary outcomes (literacy, employment composition, amenities).

**Identification:** Sharp regression discontinuity at the zero vote-margin threshold. In each constituency-election, calculate the vote margin between the winner's party and the party that held the seat in the previous election. Treatment = party alternation (different party wins); control = same party retains. At the margin, which party wins is as-good-as-random (Lee 2008). McCrary density test, covariate balance, and bandwidth sensitivity (Calonico-Cattaneo-Titiunik optimal bandwidth) provide standard validation.

**Why it's novel:** Three gaps in the literature: (1) Prakash et al. (2019) and Jain & Kashyap (2022) use Indian close-election RDD but condition on candidate characteristics (criminality, education) — no paper studies party alternation itself; (2) the party alternation question is theoretically rich because India's anti-incumbency creates a unique setting where political turnover is the norm, not the exception; (3) the theoretical prediction is ambiguous — alternation could improve development (democratic accountability) or hurt it (policy discontinuity, incomplete projects, bureaucratic reshuffling) — making the result informative regardless of sign.

**Feasibility check:**
- **Variation:** 398,703 candidate records across 30 states, 1951–2013 (datameet/india-election-data, CC-BY-SA). Post-2008 delimitation elections match SHRUG constituency boundaries.
- **Data accessible:** ✓ datameet election data cloned and verified; SHRUG constituency nightlights present locally (DMSP + VIIRS + Census at ac07/ac08 level).
- **Not overstudied:** No paper studies party alternation → economic development in India. Lee (2008) does US House elections but with very different institutional context.
- **Sample size:** Thousands of close races across decades of state elections. With 30 states holding elections every 5 years, ~6,000 constituency-elections per cycle × multiple cycles = ample power.

---

## Idea 2: Roads to Equality? PMGSY and the Gender Gap in Non-Farm Employment

**Policy:** Pradhan Mantri Gram Sadak Yojana (PMGSY) — India's flagship rural road construction program launched in 2000. Habitations above population thresholds (500 in plains, 250 in hills/tribal/desert areas) became eligible for all-weather road connectivity.

**Outcome:** Female non-agricultural worker share from SHRUG Census data (2001 pre, 2011 post). Specifically: `pc11_pca_main_ot_p` (non-agricultural "other" workers) and `pc11_pca_main_hh_p` (household industry workers) disaggregated by gender. Secondary: female literacy rate, female labor force participation rate. Nightlights (1992–2021) as continuous annual proxy.

**Identification:** Sharp RDD at the population threshold. Running variable = village population from Census 2001 (`pc01_pca_tot_p`). Threshold = 500 for plains, 250 for scheduled/hilly areas. Villages above the threshold were eligible for PMGSY road construction; those below were not. Intent-to-treat estimand (eligibility, not actual road construction) avoids selection concerns from implementation.

**Why it's novel:** Asher & Novosad (2020, AER) is the seminal PMGSY RDD paper, finding significant consumption effects but modest average employment effects. They did NOT examine gender-specific outcomes. India's female LFPR is among the world's lowest (~25% in 2011), and the theoretical prediction is ambiguous: roads could increase female non-farm employment (reduced transport costs to market work) or decrease it (income effects from male earnings gains). This is a first-order development question — do infrastructure investments narrow or widen the gender gap?

**Feasibility check:**
- **Variation:** Sharp population threshold with ~640K villages in SHRUG; clear discontinuity in road construction at cutoff (documented in Asher & Novosad 2020).
- **Data accessible:** ✓ All data in SHRUG (present locally). Census 2001 provides running variable; Census 2011 provides outcomes. No external API needed.
- **Not overstudied:** Gender dimension of PMGSY is genuinely understudied. A few descriptive studies exist but no rigorous RDD on female labor outcomes.
- **Sample size:** ~640K villages with population running variable. Bandwidth of ±250 around threshold still yields tens of thousands of villages.

---

## Idea 3: Does Political Competition Drive Public Goods? Close Elections and Village Amenities in India

**Policy:** Same close-election setting as Idea 1, but focused on granular public goods outcomes rather than nightlights. When constituencies are politically competitive (narrow margins), do they receive better public goods provision?

**Outcome:** SHRUG Village Directory amenities (Census 2011): paved roads (`pc11_vd_tar_road`), electricity (`pc11_vd_power_all`), primary schools (`pc11_vd_prim_sch`), health centers (`pc11_vd_phc`), bank branches (`pc11_vd_bank_*`), tap water (`pc11_vd_tap`). These are binary/count indicators at village level, aggregated to constituency level.

**Identification:** Same close-election RDD as Idea 1. Additionally, exploit the panel structure: compare amenity changes between Census 2001 and 2011 for constituencies where party alternation did/didn't occur in elections during that interval.

**Why it's novel:** Moves beyond nightlights (which are a noisy economic proxy) to specific, policy-relevant public goods. Tests the specific channel through which political competition affects welfare. If party alternation improves nightlights but not public goods, the mechanism is private-sector investment; if it improves public goods, politicians are directly responsive to electoral pressure.

**Feasibility check:**
- **Variation:** Same as Idea 1 (close elections provide the RDD).
- **Data accessible:** ✓ All Village Directory data in SHRUG locally. Census 2001 and 2011 VD available.
- **Not overstudied:** Papers exist on reservation → public goods (Chattopadhyay & Duflo 2004) but not on party alternation → public goods using close-election RDD.
- **Sample size:** Same as Idea 1, with village-level outcomes aggregated to constituencies.

---

## Idea 4: Do Criminally-Accused Politicians Worsen Long-Run Development? Extended Evidence from India

**Policy:** Same close-election RDD framework, but treatment is whether a candidate with pending criminal cases wins. Extends Prakash et al. (2019) with VIIRS nightlights (2012–2023) for long-run effects beyond the politician's term.

**Outcome:** VIIRS nightlights 2012–2023 (extending well beyond Prakash et al.'s DMSP data). Also Economic Census 2013 employment data from SHRUG. Tests whether criminal politicians' negative effects persist after they leave office or revert.

**Identification:** Close-election RDD comparing constituencies where criminal vs. non-criminal candidates narrowly win/lose. Running variable = vote margin.

**Why it's novel:** Prakash et al. (2019) used DMSP through ~2012. We can now test: do the negative effects persist? Do they compound? Or do they revert when the criminal politician is voted out? The persistence question is crucial for understanding the welfare cost of criminal politics.

**Feasibility check:**
- **Variation:** Same close-election framework; criminal background data available from ADR/MyNeta affidavits.
- **Data accessible:** ✓ SHRUG nightlights through 2023; election data through 2013.
- **Partially studied:** Direct extension of Prakash et al. (2019). Novel in persistence dimension.
- **Sample size:** Sufficient — Prakash et al. had adequate power with similar data.
- **Risk:** Criminal background data (MyNeta) may require scraping; not as cleanly downloadable as election results.
