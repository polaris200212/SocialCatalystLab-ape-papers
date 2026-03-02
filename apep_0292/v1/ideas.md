# Research Ideas

## Idea 1: PM2.5 Nonattainment and the Green Industrial Transition

**Policy:** EPA's 2012 revision of the annual PM2.5 National Ambient Air Quality Standard from 15 μg/m³ to 12 μg/m³. Designations finalized December 2014. Counties with 3-year design values exceeding 12 μg/m³ were designated nonattainment, triggering New Source Review permits, emission offset requirements, and compliance plans.

**Outcome:** County-level employment composition (BLS QCEW by 4-digit NAICS), establishment dynamics (Census County Business Patterns), air quality trajectories (EPA AQS monitoring data), and health outcomes (CDC WONDER mortality by county).

**Identification:** Sharp RDD at the 12 μg/m³ design value threshold. Running variable: 3-year average PM2.5 concentration (2011-2013 basis, measured by EPA monitors). Treatment: nonattainment designation. Counties with design values just above 12 μg/m³ face dramatically different regulatory environments than those just below. The design value is determined by atmospheric conditions and emission sources, not by county-level manipulation.

**Why it's novel:** (1) The 2012 PM2.5 revision is substantially less studied than earlier CAA standards — Walker (2013) used ozone; Curtis (2018) used the 2005 PM2.5 standard. (2) Focus on industry COMPOSITION (shift from "dirty" to "clean" sectors) rather than just total employment. (3) Tests the Porter Hypothesis — does regulatory pressure spur green industrial development? (4) Counter-intuitive prediction: nonattainment counties may GAIN clean-sector employment even as dirty-sector employment declines.

**Feasibility check:** BLS QCEW API confirmed returning county × industry employment data. EPA AQS pre-generated annual files available for download. Approximately 47 counties designated nonattainment under the 2012 PM2.5 standard, with ~200-300 counties within ±3 μg/m³ bandwidth. Not in APEP list.

---

## Idea 2: Mandatory Energy Disclosure and the Information Premium in Commercial Real Estate

**Policy:** NYC Local Law 84 (2009, expanded 2016) requires buildings with gross floor area exceeding 25,000 sq ft to publicly benchmark and disclose energy and water consumption annually. Buildings below 25,000 sq ft face no disclosure requirement. During 2016-2019, this was the ONLY energy regulation at the 25,000 sq ft threshold (LL87 energy audits apply at 50,000 sq ft; LL97 emission caps not enacted until 2019).

**Outcome:** Property assessed values (NYC PLUTO database, all buildings), building permit activity (NYC DOB, all buildings), and energy performance (NYC LL84 dataset, above-threshold only). Secondary outcomes: sales prices (NYC DOF rolling sales), housing violations (NYC HPD).

**Identification:** Sharp RDD at the 25,000 sq ft gross floor area threshold. Running variable: building gross floor area (from PLUTO, measured for all buildings regardless of disclosure status). Treatment: mandatory energy and water disclosure. Buildings just above 25,000 sq ft must disclose; those just below face no requirement. Floor area is determined by physical construction, not self-reported, minimizing manipulation.

**Why it's novel:** (1) Tests whether information provision alone (without mandated efficiency improvements) affects real estate markets — a clean test of the "information channel" in environmental policy. (2) The within-city RDD isolates disclosure from confounding policies, unlike cross-city DiD approaches. (3) Speaks to Akerlof (1970) lemons problem: does mandatory quality disclosure resolve information asymmetries in property markets? (4) Counter-intuitive possible finding: disclosure has no effect if markets already internalized energy performance, challenging the rationale for benchmarking mandates.

**Feasibility check:** NYC LL84 Socrata API confirmed working (253 columns, property_gfa_calculated available). NYC PLUTO Socrata API confirmed working (bbl, bldgarea, assesstot, yearbuilt). Sample: ~35,000+ buildings in LL84, hundreds of thousands in PLUTO. Excellent power near the 25,000 sq ft cutoff. Not in APEP list.

---

## Idea 3: Hospital Readmission Penalties and the Quality-Gaming Tradeoff

**Policy:** CMS Hospital Readmissions Reduction Program (HRRP), effective October 2012. Hospitals with excess readmission ratios (ERR) exceeding 1.0 for targeted conditions (AMI, heart failure, pneumonia; COPD and hip/knee added 2015) face Medicare payment reductions up to 3%. The penalty creates a sharp threshold at ERR = 1.0.

**Outcome:** Condition-specific readmission rates, mortality rates, patient volume, length of stay, and emergency department utilization (CMS Hospital Compare, Provider Utilization data). Secondary: observation stay rates (a known gaming margin).

**Identification:** Sharp RDD at ERR = 1.0 for each hospital-condition pair. Running variable: excess readmission ratio (continuous, computed from risk-adjusted readmission models). Treatment: inclusion in penalty calculation. Hospitals with ERR just above 1.0 face financial penalties; those just below face none. The ERR is derived from risk-adjustment models using patient-level claims data, limiting hospital-level manipulation.

**Why it's novel:** (1) Tests whether pay-for-performance improves UNMEASURED quality (mortality, patient safety) or only MEASURED quality (readmissions) — the "teaching to the test" problem. (2) Studies "observation stay" gaming: hospitals reclassify admissions as observation stays (which don't count as readmissions). (3) Counter-intuitive hypothesis: penalty may WORSEN patient outcomes if hospitals prioritize metrics over care. (4) HRRP is one of the largest P4P programs in US healthcare but its effects at the penalty threshold are understudied.

**Feasibility check:** CMS HRRP data confirmed via API (excess_readmission_ratio, facility_id, measure_name, number_of_discharges). ~3,000 hospitals × 6 conditions = ~18,000 hospital-condition observations. Many cluster near ERR = 1.0. Not in APEP list.

---

## Idea 4: Hospital Star Ratings and the Winner-Take-All Effect in Healthcare Markets

**Policy:** CMS Overall Hospital Quality Star Ratings, first published April 2016 (with multiple delays and methodology revisions). Assigns hospitals 1-5 stars based on a latent variable model combining 57 quality measures across 5 groups (mortality, safety, readmission, patient experience, timely care). The discrete star cutoffs create discontinuities where hospitals with nearly identical quality receive different public labels.

**Outcome:** Patient volume changes (CMS Provider Utilization), revenue (CMS cost reports), quality measure trajectories, emergency department visits, and geographic access to care. Secondary: hospital financial performance, staffing changes.

**Identification:** RDD at star rating boundaries (especially 3/4 and 4/5 cutoffs). Running variable: group-level summary scores (published by CMS) or reconstructed composite score. Treatment: discrete star rating assignment. Hospitals just above a star boundary receive a higher rating despite being nearly identical in measured quality to those just below.

**Why it's novel:** (1) Star ratings are recent (2016+) with limited causal research. (2) Tests whether information simplification creates winner-take-all dynamics in healthcare markets — do patients over-respond to discrete labels? (3) Explores whether star ratings create perverse incentives: hospitals at the top of their star category may reduce quality investment (no marginal return until next star). (4) Addresses the fundamental design question: are discrete ratings better or worse than continuous scores for consumer welfare?

**Feasibility check:** CMS Hospital Compare API confirmed working (hospital_overall_rating, facility_id, state, plus measure counts by group). ~4,700 hospitals rated. Challenge: composite score reconstruction needed for the running variable; CMS publishes methodology. Not in APEP list.

---

## Idea 5: SNAP Work Requirements, the Age-50 Cliff, and Labor Supply

**Policy:** Supplemental Nutrition Assistance Program (SNAP) work requirements for Able-Bodied Adults Without Dependents (ABAWDs). Individuals aged 18-49 must work or participate in training ≥80 hours/month to receive SNAP benefits beyond 3 months in a 36-month period. At age 50, the work requirement is lifted — individuals are exempt regardless of employment status.

**Outcome:** Employment, hours worked, earnings, SNAP participation, food security (CPS Annual Social and Economic Supplement via IPUMS). Secondary: self-employment, disability applications (SSA data).

**Identification:** Sharp RDD at age 50. Running variable: age in months or quarters (measured precisely in CPS). Treatment: exemption from SNAP work requirements. Individuals just below 50 face a binding work requirement; those just above do not. Age is obviously not manipulable.

**Why it's novel:** (1) Most SNAP work requirement studies use DiD of waiver expirations (including APEP's apep_0073); the age-50 RDD is a fundamentally different identification strategy. (2) Estimates a LOCAL average treatment effect for a specific demographic (near-50 adults), complementing external-validity-limited DiD estimates. (3) Counter-intuitive hypothesis: lifting work requirements may not reduce labor supply if the requirements are poorly enforced or if the benefit level is too low to affect behavior. (4) Tests whether administrative complexity (compliance burden) affects take-up more than the requirement itself.

**Feasibility check:** CPS ASEC available through IPUMS (API key confirmed). Monthly CPS has precise age data. SNAP participation and employment status are observed. Large samples near age 50 cutoff (hundreds of thousands of person-year observations). Builds on but does not duplicate apep_0073 (which uses DiD on waiver expirations, not age RDD).
