# Conditional Requirements

**Generated:** 2026-02-19T20:15:37.834302
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

---

## The Visible and the Invisible: Traffic Exposure, Political Salience, and the Quality of Bridge Infrastructure Maintenance

**Rank:** #1 | **Recommendation:** CONSIDER → PROCEEDING

### Condition 1: adding a sharper quasi-experiment

**Status:** [x] RESOLVED

**Response:**

Three complementary identification strategies strengthen the design beyond cross-sectional DR:

**(A) Electoral Maintenance Cycle (primary quasi-experiment):** If the visibility mechanism operates through political incentives, repair rates for high-ADT bridges should spike in gubernatorial election years. We interact ADT tercile × election year × state FE to test whether high-visibility bridges receive disproportionate investment before elections. Low-ADT bridges should show no such cycle. This is a triple-interaction test (bridge visibility × electoral timing × maintenance investment) that cleanly separates political incentives from engineering need.

**(B) Bridge Fixed Effects Panel:** With 620,000+ bridges tracked annually for 30 years, we use bridge FE + state×year FE to isolate within-bridge variation in condition changes. The key regressor is ADT×post-election-year interaction, asking: does the same bridge deteriorate faster when elections are distant vs. imminent?

**(C) Instrumental Variable — Road Reclassification:** When roads are reclassified (e.g., from state highway to US route, or inclusion in new Interstate connectors), traffic changes exogenously. We use reclassification events from NBI's "functional classification" field as an IV for ADT changes.

**Evidence:** NBI data includes functional classification (Item 26), which changes when roads are reclassified. Governor election years are public knowledge. Both variables are available in the NBI panel.

---

### Condition 2: e.g.

**Status:** [x] NOT APPLICABLE

**Response:** This appears to be a template placeholder.

---

### Condition 3: plausibly exogenous traffic shocks from new highway openings/closures

**Status:** [x] RESOLVED

**Response:**

Two sources of exogenous traffic shocks:

**(A) Functional Reclassification Events:** NBI Item 26 (functional classification) and Item 26A (year of sufficiency rating) track when a bridge's road is reclassified (e.g., minor arterial → principal arterial). These reclassifications change traffic patterns without direct relation to bridge condition. We use pre-post reclassification ADT changes as shocks to visibility.

**(B) Nearby Highway Openings:** When a new highway segment opens nearby, traffic on existing routes shifts. We can identify these events from the NBI panel itself — new bridge entries (year built = recent) on Interstate/US routes near existing bridges indicate highway network expansion that redirects traffic.

Both create plausibly exogenous variation in the "visibility" of existing bridges.

**Evidence:** NBI Item 27 (year built) and Item 26 (functional class) are recorded annually, allowing us to track both new construction and reclassification events in the panel.

---

### Condition 4: or leveraging close elections/term limits as an interaction to separate "visibility" from "economic importance"

**Status:** [x] RESOLVED

**Response:**

**(A) Close Elections:** We interact bridge ADT with the margin of victory in the most recent gubernatorial election for that bridge's state. If the visibility channel is political, the ADT-maintenance gradient should be steeper in states with competitive elections (small margins) where politicians face stronger incentives to deliver visible public goods.

**(B) Term Limits:** We compare governors facing re-election vs. term-limited governors. The visibility effect should attenuate under term limits (no electoral incentive). Term limit data is available from NCSL.

**(C) Urban vs. Rural Within Same ADT:** Bridges with identical ADT but located in urban areas (near population centers, media coverage) vs. rural areas (less media, less political salience) provide a direct test. If "visibility = political monitoring," urban bridges should be maintained better conditional on ADT. NBI Item 26 (functional class) and latitude/longitude allow this classification.

**Evidence:** Governor election margins from state Secretary of State offices (public). Term limit data from NCSL. Urban/rural classification from NBI functional class field and Census urban area definitions.

---

### Condition 5: validating that ADT is not itself affected by maintenance/closures in a way that biases results

**Status:** [x] RESOLVED

**Response:**

Three strategies address reverse causality:

**(A) Lagged ADT:** Use INITIAL (first-observed) ADT as the visibility measure, not contemporaneous ADT. Since we observe bridges from 1992 onward, the first-year ADT predates most maintenance decisions in our panel and is predetermined relative to subsequent condition changes.

**(B) Long-Difference ADT:** Use the average of the first 3 years of ADT observation as the exposure measure, removing year-to-year noise from closures/detours.

**(C) Placebo Test — Closed Bridges:** Bridges undergoing major rehabilitation (temporarily closed, ADT drops to near-zero) should show ADT RECOVERY after reopening. If ADT is mechanically driven by maintenance rather than underlying demand, this pattern would not hold. We test this directly.

**Evidence:** NBI reports ADT annually. We can verify that lagged-ADT and contemporaneous-ADT specifications produce consistent results as a robustness check.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED** ✓
