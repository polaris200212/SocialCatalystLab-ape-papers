# Conditional Requirements

**Generated:** 2026-02-26T09:52:57.502384
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

---

## Second Home Caps and Local Labor Markets — RDD at the 20% Threshold (Lex Weber)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: verifying legal "bindingness" at 20% in practice by year

**Status:** [x] RESOLVED

**Response:**

The 20% threshold is constitutionally binding. Article 75b of the Swiss Federal Constitution (adopted March 11, 2012) states: "The proportion of second homes per commune must not exceed twenty per cent of the total number of residential units and the total residential floor area of a commune." The Federal Council issued an implementing ordinance effective January 1, 2013, which immediately prohibited new second-home construction permits in municipalities exceeding 20%. The Second Homes Act (ZWG, SR 702) formalized this from January 1, 2016 with detailed implementation rules.

**Evidence:**

Art. 75b BV (SR 101); Zweitwohnungsverordnung (SR 702.1, effective 2013-01-01); Zweitwohnungsgesetz (SR 702, effective 2016-01-01). The ARE publishes the official municipal-level Zweitwohnungsanteil annually, determining which municipalities face the binding constraint.

---

### Condition 2: explicitly handling anticipation/transition periods

**Status:** [x] RESOLVED

**Response:**

Between the March 2012 vote and January 2013 ordinance, there was a well-documented "construction rush" as developers scrambled to submit building permits before the ban took effect. The design handles this by: (1) using the pre-initiative (2012 or earlier) second-home share as the running variable — this is pre-determined and cannot be manipulated ex post; (2) treating 2012 as a transition year and conducting sensitivity analyses with and without it; (3) modeling event-time dynamics to distinguish immediate vs. medium-term effects.

**Evidence:**

Wüest Partner (2023) documents the construction rush. The RDD running variable is the stock measure (cumulative second-home share), not a flow measure affected by anticipation.

---

### Condition 3: exclude 2012–2013 or model event-time

**Status:** [x] RESOLVED

**Response:**

The baseline specification will use 2014+ outcomes (post-full-implementation of the ordinance) vs. 2009-2011 baseline. Robustness checks will: (a) include 2012-2013 with transition-year dummies; (b) present event-study-style results by year for 2013-2023; (c) test sensitivity to excluding the transition period entirely.

**Evidence:**

This mirrors best practice in policy evaluation — see Hilber & Schöni's DiD specification which similarly handles the transition period.

---

### Condition 4: confirming the second-home-share measure is pre-determined

**Status:** [x] RESOLVED

**Response:**

The running variable will be the 2012 (or earlier) Zweitwohnungsanteil from the GWR (Federal Building and Housing Register). This is measured BEFORE the initiative took effect and reflects decades of cumulative housing construction. It cannot be retroactively manipulated. Post-initiative second-home shares are endogenous (affected by the policy itself) and will NOT be used as the running variable. A McCrary density test at 20% using pre-initiative data will assess whether municipalities strategically positioned themselves near the threshold.

**Evidence:**

The GWR is maintained by municipalities under federal standards (Verordnung über das eidgenössische Gebäude- und Wohnungsregister, SR 431.841). The ARE/BFS applies a uniform national methodology to compute the Zweitwohnungsanteil.

---

### Condition 5: consistently measured across municipalities

**Status:** [x] RESOLVED

**Response:**

The Zweitwohnungsanteil is a federal statistical product computed uniformly by the ARE (Federal Office for Spatial Development) using the GWR. The methodology is standardized nationally: a dwelling is classified as a second home if it is neither a primary residence nor used for other legally defined purposes (hotel, clinic, etc.). This is not a self-classification by municipalities — it is derived from the federal register. The annual publication "Wohnungsinventar und Zweitwohnungsanteil" on opendata.swiss provides the standardized measure for all municipalities.

**Evidence:**

ARE methodology documentation; opendata.swiss dataset "Wohnungsinventar und Zweitwohnungsanteil" covering all Swiss municipalities with consistent methodology.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
