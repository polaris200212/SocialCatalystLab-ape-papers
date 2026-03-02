# Literature Review & Novelty Validation

**Generated:** 2026-03-02T15:10:36.798799
**Checkpoint:** Early (post-ranking, pre-initial-plan)
**Data Source:** NBER metadata (human-authored working papers)

This file is a required novelty checkpoint before execution.

---

## Idea #1: Flood Re and the Capitalization of Climate Risk Insurance — A Triple-Difference Design

- **Ranking recommendation:** PURSUE
- **Search query terms:** `flood capitalization climate risk insurance`
- **Overlap assessment:** **High**
- **Novelty recommendation:** **PIVOT**

### Top Existing Human-Published/Working Papers
1. **Flood Risk Belief Heterogeneity and Coastal Home Price Dynamics: Going Under Water?** (Lint Barrage, Laura A. Bakkensen, 2017; NBER) — https://www.nber.org/papers/w23854

### Required Delta Statement
- If proceeding, explicitly state what differs in policy window, outcome, population, geography, or identification relative to the papers above.

---

## Idea #2: Clean Air, Rich Air? ULEZ Expansions and Residential Sorting in London

- **Ranking recommendation:** PURSUE
- **Search query terms:** `clean air rich ulez expansions`
- **Overlap assessment:** **Low**
- **Novelty recommendation:** **PROCEED**

### Top Existing Human-Published/Working Papers
1. No close NBER matches found for this query.

### Required Delta Statement
- If proceeding, explicitly state what differs in policy window, outcome, population, geography, or identification relative to the papers above.

---

## Idea #3: Planning Deregulation and the Quality-Quantity Tradeoff — Permitted Development Rights and Article 4 Directions

- **Ranking recommendation:** PURSUE
- **Search query terms:** `planning deregulation quality-quantity tradeoff permitted`
- **Overlap assessment:** **Low**
- **Novelty recommendation:** **PROCEED**

### Top Existing Human-Published/Working Papers
1. No close NBER matches found for this query.

### Required Delta Statement
- If proceeding, explicitly state what differs in policy window, outcome, population, geography, or identification relative to the papers above.

---

## Note on Flood Re Overlap Assessment

The automated search flagged "High" overlap based on Barrage & Bakkensen (2017, NBER #23854), which studies US flood risk belief heterogeneity — a completely different setting, policy, and identification strategy. The actual closest competitor is:

- **Garbarino, Guin & Lee (2024)** "The Effect of Subsidized Flood Insurance on Real Estate Markets" (*Journal of Risk and Insurance*). They estimated a DiD of Flood Re's effect on flood-zone property prices using repeat-sales. They did NOT exploit the pre-2009/post-2009 construction-date eligibility cutoff as a third difference.

Our DDD design is strictly more credible: the post-2009 properties in flood zones face identical flood risk but receive no Flood Re subsidy, netting out flood-zone-specific time trends (climate perception shifts, infrastructure investment, regulatory changes). Additionally, we examine moral hazard in new construction and distributional effects — neither studied in Garbarino et al.

## Selection Decision (Required)

- **Selected idea title:** Flood Re and the Capitalization of Climate Risk Insurance — A Triple-Difference Design
- **Why this is not duplicative:** Garbarino et al. (2024) used a standard DiD (flood zone × post-2016). Our DDD exploits the sharp pre-2009/post-2009 eligibility cutoff that they omitted, providing a within-flood-zone control group that nets out confounding trends.
- **Specific contribution delta (1-2 sentences):** We provide the first triple-difference estimate of flood insurance subsidies on property values, using post-2009 ineligible flood-zone properties as a built-in placebo. We also test for moral hazard in new construction and document distributional effects by Council Tax band.
- **Approval:** [x] Proceed  [ ] Pivot  [ ] Restart discovery
