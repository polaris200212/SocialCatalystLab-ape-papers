# Research Ideas

## Idea 1: Who Captures a Tax Cut? Property Price Capitalization and Fiscal Substitution from France's €22 Billion Residence Tax Abolition

**Policy:** France abolished the taxe d'habitation (TH) on primary residences between 2018 and 2023 — the largest local tax abolition in modern French history (€22B/year). The reform was staggered: 80% of households (below income thresholds) received 30% relief in 2018, 65% in 2019, and full exemption in 2020. The remaining 20% were phased out during 2021–2023. Communes were compensated with a transfer of national taxe foncière (TF) revenue, but retained authority to set TF rates — creating incentives for fiscal substitution.

**Outcome:** Property transaction prices from DVF (Demandes de Valeurs Foncières), covering the universe of French property transactions 2014–2025. Commune-level tax rates (TH and TF) from the REI (Recensement des Éléments d'Imposition), available 2014–2024.

**Identification:** Continuous-treatment DiD exploiting cross-commune variation in pre-reform TH rates as a measure of treatment intensity. Communes with higher pre-reform TH rates experienced larger fiscal windfalls from abolition. The design compares property price trajectories in high- vs. low-TH-rate communes, before and after phased abolition. Event study specification traces out the capitalization dynamics year by year.

Key design features:
- **Built-in placebo:** Taxe d'habitation on secondary residences (résidences secondaires) was NOT abolished — it was maintained and even increased in some tourist areas. Comparing price effects for primary-residence-dominated communes vs. secondary-residence communes provides a natural placebo.
- **Fiscal substitution decomposition:** Can directly measure whether communes raised TF rates to offset TH revenue losses, and estimate the net capitalization (gross TH savings minus TF increases).
- **DDD opportunity:** Low-income households (80%) were treated first (2018–2020) vs. high-income (20%, treated 2021–2023). Communes with different income compositions thus experienced differential treatment timing, enabling a DDD design.

**Why it's novel:** The only existing study is a French policy report (Bach, Bozio, Dutronc-Postel, Fize, Guillouzouic, and Malgouyres, IPP Report No. 48, 2023) — not a peer-reviewed journal article and not in English. That report uses continuous treatment intensity, not staggered DiD. No English-language paper connects this reform to the international tax capitalization literature (Oates 1969, Palmon and Smith 1998, Lutz 2015). The fiscal substitution angle (do communes raise foncière to offset?) is entirely unstudied causally.

**Feasibility check:** ✅ Confirmed. DVF provides 2014–2025 transaction-level data (all communes except Alsace-Moselle). REI provides commune-level TH and TF rates 2014–2024. Both are open data, no API key needed. Treatment variation across ~35,000 communes gives massive power. Pre-reform period 2014–2017 provides 4 years for parallel trends. Clusters at département level (96) are well above the ≥20 threshold.

---

## Idea 2: Do Priority Schools Help or Stigmatize? Property Price Effects of France's 2015 Education Zone Reform

**Policy:** In September 2015, France completely redrew its priority education map, replacing the old ZEP/ECLAIR system with REP and REP+ designations. Approximately 1,100 schools were designated REP/REP+ — some newly entering priority status (gaining extra resources), others exiting (losing resources and the "disadvantaged" label).

**Outcome:** Property transaction prices from DVF, geocoded at the parcel level. Can measure prices within defined radii (500m, 1km, 2km) of schools that entered or exited REP/REP+ status.

**Identification:** DiD comparing neighborhoods around schools that gained REP/REP+ status vs. those that lost it vs. those unchanged, before and after September 2015. The reform date is sharp and nationally determined.

Key design features:
- **Two treatment arms:** Entering REP (resource gain + stigma) vs. exiting REP (resource loss + stigma removal) create opposite-sign predictions that help identify the mechanism.
- **Mechanism decomposition:** Resource effect (more teachers, smaller classes) vs. stigma/signaling effect ("this is a bad neighborhood"). If entering REP raises prices → resources dominate. If entering REP lowers prices → stigma dominates.
- **Distance gradient:** Effect should decay with distance from school.

**Why it's novel:** Benabou, Kramarz, and Prost (2009, REStat) studied the original ZEP designation's labor market effects. The 2015 reform is much more recent and hasn't been studied with DVF property data. No paper has tested whether REP designation helps or hurts local property values — a question with direct implications for place-based education policy worldwide.

**Feasibility check:** ⚠️ Partially confirmed. DVF is available and geocoded (2014–2025). The list of REP/REP+ schools exists on education.gouv.fr. The main risk is obtaining georeferenced school addresses that match DVF's commune/parcel identifiers. The number of treated schools (~1,100) provides adequate power. Need to verify: does data.gouv.fr have geocoded REP school lists?

---

## Idea 3: Does Social Housing Enforcement Reshape Cities? Evidence from France's 2013 SRU Penalty Tripling

**Policy:** France's loi SRU (Solidarité et Renouvellement Urbain, 2000) requires communes above 3,500 inhabitants (1,500 in Île-de-France) to have at least 25% social housing. The 2013 Duflot reform tripled financial penalties for non-compliance and empowered prefects to override local building permits ("carence" declarations). Hundreds of communes faced dramatically higher penalties starting in 2014.

**Outcome:** Social housing construction (RPLS — Répertoire des Logements Locatifs des Bailleurs Sociaux), property transaction prices (DVF), and demographic composition (census/INSEE BDM).

**Identification:** DiD comparing communes with social housing shares between 20–25% (newly binding under the raised target) vs. communes already above 25% (always compliant). The penalty tripling in 2013 provides a sharp intensification of treatment.

Key design features:
- **Compliance heterogeneity:** Some communes pay fines rather than build. This creates interesting variation in actual treatment uptake vs. assignment.
- **Property price effects:** New social housing could lower nearby property values (stigma/NIMBY) or raise them (neighborhood investment, public services).
- **Sorting:** Do high-income residents leave communes that increase social housing?

**Why it's novel:** The SRU law has been studied descriptively (Gobillon and Vanhoni 2021, CGEDD reports), but no rigorous causal paper uses the 2013 penalty tripling as a quasi-experiment with DVF property price data. The question of whether enforced social housing mandates reshape neighborhood composition is globally relevant (US inclusionary zoning, UK Section 106).

**Feasibility check:** ⚠️ Partially confirmed. DVF is available. RPLS (social housing inventory) is on data.gouv.fr. Commune-level social housing shares are in census data. The main risk is the endogeneity of pre-reform social housing shares to local politics. Need approximately 200+ communes in the 20–25% range for adequate power. The population threshold (3,500) also creates an RDD opportunity, though the paper uses DiD.

---

## Idea 4: Taxe Foncière Hikes and Housing Market Dynamics After France's Local Tax Reform

**Policy:** Following the TH abolition, French communes retained the power to set taxe foncière (TF) rates. Average TF rates increased 37% between 2014 and 2024 — but with enormous cross-commune variation. Some communes barely changed rates; Paris increased its rate by 52% in a single year (2023).

**Outcome:** Property transaction prices (DVF) and transaction volumes.

**Identification:** Event-study DiD around discrete, large TF rate increases, using communes with stable rates as controls.

**Why it's novel:** Property tax capitalization has been studied for the US (Palmon and Smith 1998, Lutz 2015) but rarely for France, and never using the dramatic post-TH-abolition variation.

**Feasibility check:** ⚠️ This is effectively a sub-component of Idea 1. The fiscal substitution mechanism in Idea 1 already addresses this question. Including it as a standalone idea would overlap. **Recommend pursuing as part of Idea 1's mechanism analysis rather than separately.**
