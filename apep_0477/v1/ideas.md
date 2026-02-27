# Research Ideas

## Idea 1: Do Energy Labels Move Markets? Multi-Cutoff RDD Evidence from English Property Transactions

**Policy:** Energy Performance Certificate (EPC) labeling system in England and Wales. Properties receive an energy efficiency score (1-100) mapped to bands A-G with sharp thresholds: A(92+), B(81-91), C(69-80), D(55-68), E(39-54), F(21-38), G(1-20). EPCs mandatory at point of sale/rent since 2008. Since April 2018, Minimum Energy Efficiency Standards (MEES) make it illegal to let properties rated F or G, creating a regulatory threshold at score 39 layered on top of the informational threshold.

**Outcome:** Residential property transaction prices from HM Land Registry Price Paid Data (24M+ transactions, 1995-2025). Linked to EPC register (30M certificates) via postcode and address matching.

**Identification:** Multi-cutoff sharp RDD at EPC band boundaries. The running variable is the EPC numerical score (1-100, continuous). At each band boundary (39, 55, 69, 81, 92), the letter label changes discretely while the underlying energy characteristics are near-identical for properties just above vs below the threshold. Key innovation: the E/F boundary (score 39) carries both an informational effect (label change) AND a regulatory effect (MEES makes F/G unlettable), while other boundaries (C/D at 69, D/E at 55) carry only the informational effect. Comparing discontinuities across boundaries decomposes regulation vs information. Second innovation: comparing discontinuities before vs during the 2021-2023 energy crisis tests whether energy cost salience amplifies label capitalization.

**Why it's novel:** (1) No UK-specific RDD at EPC band boundaries exists — Aydin et al. (2020, JUE) did this for the Netherlands only. (2) The decomposition of regulatory vs informational effects via multi-cutoff comparison is entirely new. (3) The energy crisis amplification channel is unstudied for UK (a 2026 JEnvEconMgmt paper did DiD in Norway but not RDD). (4) Fuerst et al. (2015) and Ghosh et al. (2024) used hedonic/DiD methods for UK EPC capitalization but not RDD.

**Feasibility check:** Confirmed: EPC register bulk download available (30M records, registration required, free). Land Registry PPD confirmed accessible at new URL (data through Dec 2025). Both link via postcode. EPC score is continuous (1-100), making it ideal for RDD. McCrary density test required to check for assessor bunching at boundaries — European evidence (Applied Energy 2018) documents some bunching but EPC scores are computed by complex SAP models, limiting precise manipulation.

---

## Idea 2: Does Rate Relief Save the High Street? Evidence from the £12,000 Threshold

**Policy:** Small Business Rate Relief (SBRR) in England. Non-domestic properties with rateable value ≤£12,000 receive 100% business rates relief (zero tax). Relief tapers from £12,001 to £15,000, then full rates apply. The threshold was increased from £6,000 to £12,000 in April 2017. Creates a massive cost discontinuity for small businesses.

**Outcome:** Business formation and dissolution rates from Companies House bulk data (5M+ companies with SIC codes, registered addresses, and incorporation/dissolution dates). Secondary outcomes: high-street vacancy rates, local employment from NOMIS.

**Identification:** Sharp RDD at the £12,000 rateable value threshold. Running variable: rateable value from VOA rating lists (confirmed publicly downloadable, property-level). Properties just below £12K pay zero rates; those just above pay the full rate (approx. 49.9p per £1 of rateable value = ~£6,000/year for a £12K property). This is a massive cost cliff. Link VOA properties to Companies House firms via address/postcode to measure firm-level outcomes.

**Why it's novel:** One Oxford WP (20-18) studied SBRR effects on property occupancy using RDD/RKD but did NOT examine business outcomes (firm survival, employment, growth). No paper examines whether rate relief actually helps businesses thrive or merely affects which properties they occupy. The 2017 threshold increase (£6K→£12K) provides a natural experiment for temporal comparison.

**Feasibility check:** Confirmed: VOA rating list data downloadable (property-level rateable values, free). Companies House monthly CSV downloadable (468MB, free). Linkage via address/postcode. Key concern: potential bunching at £12K if assessors or property owners influence valuations — VOA assessments are independent but appeals exist. McCrary test essential.

---

## Idea 3: Priced Out of Clean Air? Property Value Effects of London's ULEZ Boundary

**Policy:** Ultra Low Emission Zone (ULEZ) expansion in London. Non-compliant vehicles pay £12.50/day. Expanded to inner London (within North/South Circular roads) October 25, 2021. The boundary creates a sharp spatial discontinuity in transport costs and air quality.

**Outcome:** Residential property prices from Land Registry PPD. Secondary: air quality from London Air Quality Network monitors, firm formation from Companies House.

**Identification:** Spatial RDD at the inner London ULEZ boundary (North/South Circular). Running variable: distance from property (by postcode) to the ULEZ boundary. Properties just inside face ULEZ charges; those just outside do not. Focus on the October 2021 inner London expansion (not the August 2023 London-wide expansion, which eliminated the boundary). Use pre-expansion data (2019-2021) as a placebo period.

**Why it's novel:** No study examines property value capitalization at the ULEZ boundary. McNeil & Mitsch (2025) used spatial RDD for political effects but found comparability concerns across the boundary. Air quality studies exist but capitalization is unstudied. The boundary follows administrative road routes, not natural geographic features, supporting plausible exogeneity.

**Feasibility check:** Land Registry PPD covers London with postcode-level precision. Postcodes.io API (free) converts postcodes to coordinates for distance calculation. The North/South Circular boundary is well-defined. Concern: spatial confounders at the boundary (road noise, congestion patterns differ on major roads). Need careful bandwidth selection and covariate balance tests. The fact that the boundary is a busy road (North Circular = A406) creates "pre-existing barrier" risk flagged in tournament feedback.

---

## Idea 4: Building on Borrowed Time: Flood Re Eligibility and Property Values

**Policy:** Flood Re scheme (operational from April 2016). Provides affordable flood insurance for domestic properties in flood-risk areas. Critical eligibility cutoff: properties built AFTER 1 January 2009 are permanently excluded from Flood Re, meaning they face market-rate (potentially unaffordable) flood insurance. Properties built before 1 Jan 2009 have access to capped premiums.

**Outcome:** Property prices from Land Registry PPD (distinguishes new-build transactions). Secondary: transaction volumes (market liquidity) in flood-risk areas.

**Identification:** Sharp date-based RDD. Running variable: property construction date relative to 1 January 2009. Properties completed just before the cutoff are Flood Re eligible; those just after are not. Focus on properties in EA-designated flood zones (Zones 2 and 3). Use first new-build sale date as proxy for construction date. The construction date cutoff is exogenous to individual property characteristics (set by national policy, not local conditions).

**Why it's novel:** No study has examined the Flood Re eligibility cutoff as an RDD. The flood insurance literature in the UK focuses on aggregate effects (Surminski & Eldridge 2017) or NFIP in the US (Bin & Landry 2013). The construction date threshold creates a unique within-flood-zone RDD that isolates the insurance access channel from physical flood risk.

**Feasibility check:** Land Registry PPD identifies new builds and transaction dates. EA flood zone maps are downloadable as shapefiles from data.gov.uk. Postcodes.io enables geographic matching. Key concern: construction date precision — Land Registry records transaction date, not construction completion date. For new-builds, first transaction date approximates construction date within months. Additional concern: builders near the cutoff may have strategically timed completion to qualify for Flood Re — need to check for bunching around Jan 2009.

---

## Idea 5: Minimum Standards or Minimum Supply? MEES Regulation and the Rental Housing Market

**Policy:** Minimum Energy Efficiency Standards (MEES) for privately rented properties in England and Wales. From April 2018 (new tenancies) and April 2020 (all existing tenancies), landlords cannot legally let a property with an EPC rating below E (score < 39). Exemptions available if improvement costs exceed £3,500.

**Outcome:** Property prices for rental-tenure properties from Land Registry PPD, linked to EPC register (which includes tenure type). Secondary: rental supply (number of F/G-rated properties listed for let), renovation activity (EPC score upgrades via re-assessment), and landlord portfolio adjustment (Companies House for buy-to-let corporate landlords).

**Identification:** Sharp RDD at the EPC score 39 threshold (E/F boundary), specifically for rental properties. Running variable: EPC numerical score. Compare properties scoring 38 (rated F, cannot be let) vs 40 (rated E, can be let). Layered with DiD: compare the E/F discontinuity before MEES (pre-2018) vs after MEES (post-2018 for new lets, post-2020 for existing). Also compare to owner-occupied properties at the same EPC threshold (should show no regulatory effect, only information effect — serves as placebo).

**Why it's novel:** A December 2025 paper (Energy Policy) studied MEES using RDD + DiD but found null effects on RENTS. However, it did NOT examine: (a) property SALE values (landlord exit/investment decision), (b) rental SUPPLY effects (are F/G properties withdrawn?), (c) EPC score UPGRADING behavior (bunching analysis of reassessments), or (d) heterogeneity by exemption take-up, property type, or region. The key puzzle: if rents don't change but the regulation bites, the margin of adjustment must be quantity (supply) or investment (upgrading) — this paper identifies which.

**Feasibility check:** Same data as Idea 1 (EPC register + Land Registry PPD). The EPC register includes TENURE field, enabling separate analysis of rental vs owner-occupied properties. The 2025 paper's null result on rents makes the supply/investment channel even more interesting scientifically. McCrary bunching test critical — if assessors help landlords score 39+ to comply with MEES, this IS the treatment effect (compliance upgrading), not a validity threat.
