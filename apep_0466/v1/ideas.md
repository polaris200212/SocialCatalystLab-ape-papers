# Research Ideas

## Idea 1: Does Local Governance Scale Matter? Municipal Population Thresholds and Firm Creation in France

**Policy:** French municipal governance mandates are assigned by discrete population thresholds (Article L2121-2 CGCT for council size; Article L2123-23 CGCT for mayor compensation). At each threshold, council size increases by 2-6 seats and mayor salary jumps discretely. Key thresholds: 500 (council 11→15 at next bracket; salary €1,042→€1,647), 1,000 (salary €1,647→€2,108; since 2013 also proportional voting), 1,500 (council 15→19), 3,500 (salary €2,108→€2,247; council 23→27; pre-2013 also proportional voting), 10,000 (salary €2,247→€2,656; council 29→33).

**Outcome:** INSEE Sirene establishment data aggregated to commune×year: firm creation rate, closure rate, net creation, sectoral composition (manufacturing, services, retail), micro-entrepreneur share, employer-establishment share.

**Identification:** Multi-cutoff sharp RDD using commune legal population as running variable. At each threshold, governance mandates change discretely. The 2013 electoral reform (lowering proportional voting threshold from 3,500 to 1,000) creates a natural difference-in-discontinuities (DiDisc) design at the 3,500 threshold: before 2013, both electoral system AND governance mandates change; after 2013, only governance mandates change.

**Why it's novel:** Eggers et al. (2018 AJPS) used these thresholds to study political outcomes and highlight methodological pitfalls. Garicano et al. (2016 AER) studied firm-size distortions at the 50-employee threshold. NO prior study has examined the effect of municipal governance changes at commune population thresholds on local firm dynamics using Sirene data. This is the first paper to combine France's rich municipal institutional variation with the universe of firm-level outcomes.

**Feasibility check:**
- Variation: 14 thresholds with multiple treatments. At 3,500: 1,333 communes within ±20% bandwidth. At 1,000: 3,296 communes. Statistical power is excellent.
- Data access: Sirene API confirmed working (X-INSEE-Api-Key-Integration header). Commune population data available from data.gouv.fr (34,935 communes with population field).
- McCrary pre-check: Population density smooth around all key thresholds (no bunching).
- Not overstudied: Literature uses these thresholds for political outcomes only.

---

## Idea 2: Rural Revitalization Zones and Firm Creation: Evidence from the ZRR-to-FRR Reclassification

**Policy:** The ZRR (Zones de Revitalisation Rurale) program provided tax exemptions for firms in eligible rural communes (exonération d'impôt sur les bénéfices, exonération de cotisations patronales for 12 months). On July 1, 2024, ZRR was replaced by FRR (France Ruralités Revitalisation), reclassifying 17,800 communes. ~2,200 communes lost ZRR status.

**Outcome:** Sirene: firm creation rates, establishment closures, and sectoral composition in treated vs. untreated communes pre/post reclassification. Also: auto-entrepreneur creation rates as a proxy for self-employment.

**Identification:** Geographic/administrative RDD comparing communes that marginally gained or lost FRR status. The classification uses EPCI-level criteria (population density ≤ median of metro EPCIs AND median income ≤ median). Communes in EPCIs just above/below the density or income thresholds provide quasi-random variation.

**Why it's novel:** Existing ZRR literature (Lorenceau 2009; Combes et al.) studied the original 1996 program. The 2024 reclassification is unstudied. FRR classification data is available on data.gouv.fr.

**Feasibility check:**
- Variation: 2,200 communes lost eligibility; ~4,000 gained it. Sufficient mass.
- Data access: FRR zone list on data.gouv.fr (confirmed). Sirene API for firm outcomes (confirmed).
- Challenge: Running variable is at EPCI level, not commune level. Multidimensional criteria (density + income) may require multidimensional RDD or index-based approach.
- RISK: Reform is very recent (July 2024); only ~18 months of post-treatment data. May be underpowered for detecting firm creation effects.

---

## Idea 3: DGF Fiscal Equalization Transfers and Local Entrepreneurship

**Policy:** The DGF (Dotation Globale de Fonctionnement) is France's primary intergovernmental transfer, distributing ~€27 billion annually to communes. The "dotation forfaitaire" component uses a logarithmic population coefficient that creates slope changes at population brackets. Additionally, the DSR (Dotation de Solidarité Rurale) and DSU (Dotation de Solidarité Urbaine) have eligibility thresholds.

**Outcome:** Sirene firm creation/closure by commune, local investment proxies.

**Identification:** RDD at population-based eligibility cutoffs for DSR/DSU, or regression kink design (RKD) at DGF coefficient slope changes.

**Why it's novel:** Fiscal transfer → firm creation is understudied in France. Most DGF literature focuses on political economy (strategic manipulation of population counts).

**Feasibility check:**
- RISK: The DGF formula is complex and has been reformed multiple times. The coefficient may be linearly interpolated within brackets (kink, not jump). Need to verify exact formula structure from Légifrance.
- RISK: DSR/DSU eligibility depends on multiple criteria (population + fiscal potential + social housing share), making clean RDD difficult.
- This idea is the least developed and highest-risk.

---

## Idea 4: Proportional Representation and Local Business Environments: The 2013 Electoral Reform as a Natural Experiment

**Policy:** Loi n° 2013-403 du 17 mai 2013 lowered the threshold for proportional list voting in municipal elections from 3,500 to 1,000 inhabitants. Communes with 1,000-3,499 residents switched from two-round majoritarian (panachage) to proportional list voting with mandatory gender parity.

**Outcome:** Sirene: firm creation, establishment density, sectoral composition. Also elections data: council composition, political fragmentation.

**Identification:** RDD at the 1,000 population threshold, comparing outcomes post-2014 (first election under new rules) in communes just above vs. just below 1,000.

**Why it's novel:** Lopes da Fonseca (2017) studied political fragmentation at this threshold. Apep_0433 studied gender quotas (same reform, different angle). No study has examined the effect of proportional representation on local firm dynamics.

**Feasibility check:**
- Variation: 3,296 communes within ±20% of 1,000. Very well-powered.
- Data access: Confirmed for both Sirene and population data.
- CONCERN: Angle overlap with apep_0433 (same threshold, same reform). The differentiation is outcome (firm dynamics vs. gender economic participation), but the identification is identical. Risk of being too similar.
- CONCERN: Multiple treatments at 1,000 threshold (electoral system + partial salary change). Compound treatment problem per Eggers et al. (2018).
