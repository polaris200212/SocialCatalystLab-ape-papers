# Revision Plan: apep_0478 v2 — "Going Up Alone"

## Core Problem

The v1 paper tries to be two things — a definitive economic history of the only fully automated occupation AND a causal study of the 1945 strike. Every reviewer loved the first and attacked the second. Seven rounds of advisor review were spent defending a fragile SCM that produces a paradoxical result (NYC retained operators longer, contradicting the "strike accelerated automation" narrative). The SCM has 100% weight on DC, one post-treatment period, borderline p=0.056, and a failed janitor placebo.

## The Shift

| Aspect | v1 | v2 |
|--------|----|----|
| Centerpiece | SCM + 1945 strike | Adoption puzzle + individual transitions |
| Opening | "In 1940, the Census recorded 82,666..." | Vivid strike scene → technology paradox |
| Analytical backbone | State-level SCM (fragile) | Individual-level linked panel (38,562 operators) |
| SCM role | Main result (4.5 pages) | Supporting evidence (2 pages) |
| Individual transitions | Supporting (5 pages) | Core analysis (8-10 pages, expanded) |
| Descriptive atlas | Good but brief (4 pages) | Expanded, definitive (6-8 pages) |
| Paradox treatment | Awkward footnote | Headline finding |

## New Code

1. NYC vs. non-NYC transition comparison
2. Occupational ladder analysis (OCCSCORE destinations)
3. Selection into persistence (logit)
4. Demographic composition shift (cross-sectional)
5. IPW reweighting

## New Paper Structure

1. Introduction (3 pages) — Strike scene hook → adoption puzzle → 3 contributions
2. Historical Background (2.5 pages)
3. Data (2.5 pages)
4. Lifecycle of an Extinct Occupation (7 pages) — EXPANDED
5. Where Did They Go? Individual Transitions (8 pages) — NEW CORE
6. The Strike as Coordination Shock (3 pages) — COMPRESSED
7. Discussion (2 pages)
8. Conclusion (1 page)

Target: 30-32 pages main text

## Exposure Alignment (DiD/SCM)

**Who is treated:** New York State elevator operators (proxy for NYC, which experienced the 1945 strike).

**Primary estimand population:** Elevator operators in New York State in 1940-1950, compared to a synthetic control weighted from 18 donor states.

**Placebo/control population:** Building service workers (janitors, porters, guards) who did not face direct automation during 1940-1950. For individual-level regressions, the comparison group is ~445,000 linked building service workers.

**Design:** Synthetic control (state-level, 1900-1950, treated post-1945) + individual-level comparative regressions (not causal — conditional associations). Triple-difference as robustness (elevator × NY × post-1945).
