# Conditional Requirements

**Generated:** 2026-02-24T18:45:08.121567
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

---

## The Cocoa Boom and Human Capital in Ghana

**Rank:** #1 | **Recommendation:** CONSIDER

### Condition 1: add credible pre-trends using additional pre-2000 data or repeated surveys

**Status:** [x] RESOLVED

**Response:**

IPUMS International has Ghana 1984 census (gh1984a, 1.3M person records) with GEO1_GH regional identifiers. This gives us THREE census periods: 1984, 2000, 2010.

Design:
- Pre-boom period 1 → Pre-boom period 2: 1984→2000 (cocoa prices were flat/declining in the 1980s-1990s)
- Pre-boom period 2 → Boom period: 2000→2010 (cocoa prices tripled)

Pre-trend test: estimate whether cocoa-region vs. non-cocoa-region differences in education/employment were ALREADY changing at the same rate in 1984-2000 (when no cocoa boom occurred). If trends are parallel in 1984-2000, the divergence in 2000-2010 is credibly attributed to the cocoa boom.

Additionally, DHS data (1988, 1993, 1998, 2003, 2008, 2014) provides 6 pre/post observations for health-related outcomes (fertility, child mortality) at the regional level, enabling a visual event study.

**Evidence:** IPUMS extract confirmed gh1984a has 1,309,352 person records with AGE, SEX, EDATTAIN, GEO1_GH. Variables are harmonized across all three censuses.

---

### Condition 2: redesign comparison group within the forest belt

**Status:** [x] RESOLVED

**Response:**

Main specification restricts to the 6 FOREST-BELT regions of Ghana: Western, Central, Eastern, Ashanti, Brong-Ahafo, and Volta. These share the same ecological zone (tropical forest/transition), climate, and agricultural structure. They differ in cocoa intensity.

Excluded from main specification:
- Greater Accra (urban, industrial — structurally different)
- Northern, Upper East, Upper West (savanna zone — completely different ecology and economy)

Robustness specifications include: (a) full 10-region sample, (b) forest-belt only excluding Volta (lowest cocoa among forest regions), (c) restricting to rural areas only within forest belt.

This addresses the "south vs. north" concern by comparing cocoa-heavy forest regions to cocoa-light forest regions, which share much more similar pre-treatment trends.

**Evidence:** Ghana's ecological zones are well-documented. Western, Ashanti, Brong-Ahafo, and Eastern are the high-cocoa regions (>90% of production). Central and Volta are forest-belt but low-cocoa. This gives within-forest-belt variation.

---

### Condition 3: continuous treatment intensity & address migration/composition

**Status:** [x] RESOLVED

**Response:**

1. **Continuous treatment:** Replace binary "cocoa/non-cocoa" with regional cocoa production shares as continuous treatment intensity. Treatment_rt = CocoaShare_r × log(CocoaPrice_t). Cocoa production shares by region are published in COCOBOD annual reports and well-documented in academic literature (Vigneri 2005, Kolavalli & Vigneri 2011). Standard Bartik/shift-share design (Goldsmith-Pinkham, Sorkin, Swift 2020).

2. **Migration/composition:** Test for differential migration by comparing (a) working-age population growth across cocoa vs. non-cocoa regions between census years, (b) share of inter-regional migrants by region in each census (IPUMS has MIGRATE1 variable for Ghana). If migration is balanced, composition effects are unlikely to drive results. The DR estimator also adjusts for observable composition differences through the propensity score.

3. **Outcome dilution:** Address by estimating both (a) ITT at the regional level (all individuals in cocoa regions) and (b) subgroup effects for agricultural workers (IPUMS INDGEN identifies agriculture). Agricultural households are more directly exposed to cocoa prices.

**Evidence:** Bartik/shift-share design is standard in development economics. Sant'Anna & Zhao (2020) DR DiD handles repeated cross-section design with rich individual covariates.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Status: RESOLVED**
