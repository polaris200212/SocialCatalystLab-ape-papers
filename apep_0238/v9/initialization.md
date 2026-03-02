# Human Initialization
Timestamp: 2026-02-26T12:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0238
**Parent Title:** Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets
**Parent Decision:** REVISION (structural model fix + empirical additions)
**Revision Rationale:** v9 revision of v8 addressing fundamental model issues: (1) demand shock was permanent, making scarring parameter λ quantitatively irrelevant — replaced with AR(1) mean-reverting shock; (2) sensitivity table contained fabricated values not matching model output — replaced with auto-generated table; (3) SMM used scaling hack instead of genuine moment matching — removed; (4) δ=0.034 → δ=0.023 to fix SS UR overshoot (0.078 vs 0.055 target); (5) added Romano-Wolf stepdown p-values (reviewer request); (6) added Montiel Olea-Pflueger weak IV diagnostics (reviewer request); (7) added per-moment SMM fit table (reviewer request).

## Key Changes Planned

- Fix δ from 0.034 to 0.023 (match standard DMP calibration, fix SS UR)
- Replace permanent demand shock with AR(1) mean-reverting: a_t = a*(1 - shock_size * ρ^t)
- Remove SMM scaling hack (direct moment comparison)
- Re-estimate SMM with corrected model
- Add Romano-Wolf stepdown p-values for LP horizons
- Add Montiel Olea-Pflueger weak instrument diagnostics for Saiz IV
- Add per-moment SMM fit table
- Rewrite model/welfare sections with new numbers
- Fix fabricated sensitivity table with auto-generated values

## Inherited from Parent

- Research question: Same (demand vs supply recession scarring)
- Identification strategy: Same LP framework with Saiz IV, wild bootstrap, AKM SEs
- Primary data source: Same (FRED API, BLS CES/LAUS, FHFA, JOLTS)
- Empirical results: Unchanged (LP estimates, permutation tests)
