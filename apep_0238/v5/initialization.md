# Human Initialization
Timestamp: 2026-02-12T19:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0238
**Parent Title:** Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets
**Parent Decision:** REVISION (code-paper consistency fixes)
**Revision Rationale:** Fix verified code-paper inconsistencies: (1) QCEW→CES data source claim, (2) "log population"→log nonfarm employment control, (3) Add missing PBS sector to Bartik (9→10 supersectors), (4) Dynamic Figure 10 rescaling, (5) Fix Appendix Eq A.2 level→log notation, (6) Fix COVID horizon 52→48 months, (7) Fix discount rate 4.8→4.7%, (8) Fix all code headers apep_0234→apep_0238.

## Key Changes Planned

- Fix data source: paper said QCEW, code uses CES via FRED → update paper to CES
- Fix control variable: paper said "log population", code uses log(emp_2007) → update paper to "log nonfarm employment at recession peak"
- Add PBS/PROF sector to state-level industry fetching (was 9 sectors, paper claimed 10)
- Replace hard-coded 0.3 rescaling in Figure 10 with dynamically computed SD ratio
- Fix Eq A.2 from level changes to log changes matching code
- Fix COVID horizon: paper said 52 months, code uses 48 → update paper
- Fix calibration table: annual discount rate 4.8% → 4.7% (matching 1 - β^12)
- Fix all code file headers from apep_0234 to apep_0238

## Inherited from Parent

- Research question: Same (demand vs supply recession scarring)
- Identification strategy: Same LP framework with controls
- Primary data source: Same (FRED API, BLS CES/LAUS, FHFA, JOLTS)
