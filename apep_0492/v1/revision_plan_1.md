# Revision Plan — Round 1 (Post-Referee)

**Timestamp:** 2026-03-03T16:53:00

## Referee Decisions
- GPT-5.2: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MINOR REVISION

## Changes Made

### 1. Incidence Claim (GPT Critical, Grok Optional)
- **Before:** "approximately one-quarter of the subsidy was captured"
- **After:** "likely in the range of 15 to 35 percent... depending on assumptions"
- **Rationale:** GPT correctly noted the point estimate lacks structural identification. Bounded range is more honest.

### 2. Spatial RDD Framing (GPT High-Value)
- **Before:** "Design 3: Spatial RDD at Regional Borders"
- **After:** "Supplementary Spatial Analysis" (methodology) / "Spatial Analysis at Regional Borders" (results)
- **Rationale:** RDD is invalid due to sorting; should not be framed as a primary identification strategy.

### 3. Bootstrap Clustering Caveat (GPT Critical)
- **Added:** Acknowledgment that i.i.d. bootstrap may understate SEs; development identifiers unavailable in PPD.
- **Rationale:** Cannot implement cluster bootstrap without development IDs, but should acknowledge the limitation.

### 4. Abstract Revision
- Removed specific "one-quarter" claim; replaced with "substantial share"
- Added "quality manipulation" alongside "price manipulation"

## Changes Deferred (Beyond Scope of v1)
- Cluster bootstrap implementation (requires development-level identifiers not in PPD)
- Systematic price heaping analysis at placebo thresholds
- Formal elasticity conversion (Grok suggestion — good for v2)
- EPC floor area merge for quality measurement
- Formal pre-trend test for bunching at future caps
