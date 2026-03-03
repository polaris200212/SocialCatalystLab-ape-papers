# Literature Review & Novelty Validation

**Generated:** 2026-03-03T17:54:59.576528
**Checkpoint:** Early (post-ranking, pre-initial-plan)
**Data Source:** NBER metadata (human-authored working papers)

This file is a required novelty checkpoint before execution.

---

## Idea #1: The Price of Austerity: Council Tax Support Localisation and Low-Income Employment

- **Ranking recommendation:** PURSUE
- **Search query terms:** `price austerity council tax support`
- **Overlap assessment:** **Low**
- **Novelty recommendation:** **PROCEED**

### Top Existing Human-Published/Working Papers
1. No close NBER matches found for this query.

### Required Delta Statement
- If proceeding, explicitly state what differs in policy window, outcome, population, geography, or identification relative to the papers above.

---

## Idea #2: Conditioned to Work? Universal Credit's In-Work Regime and Labour Supply at the Intensive Margin

- **Ranking recommendation:** CONSIDER
- **Search query terms:** `conditioned work universal credit in-work`
- **Overlap assessment:** **Low**
- **Novelty recommendation:** **PROCEED**

### Top Existing Human-Published/Working Papers
1. No close NBER matches found for this query.

### Required Delta Statement
- If proceeding, explicitly state what differs in policy window, outcome, population, geography, or identification relative to the papers above.

---

## Idea #3: The Training Tax: Britain's Apprenticeship Levy and the Restructuring of Youth Employment

- **Ranking recommendation:** CONSIDER
- **Search query terms:** `training tax britain apprenticeship levy`
- **Overlap assessment:** **Low**
- **Novelty recommendation:** **PROCEED**

### Top Existing Human-Published/Working Papers
1. No close NBER matches found for this query.

### Required Delta Statement
- If proceeding, explicitly state what differs in policy window, outcome, population, geography, or identification relative to the papers above.

---

## Additional Literature (Manual Search)

### Fetzer (2019, AER) — "Did Austerity Cause Brexit?"
- Uses CTS localisation as ONE of ~6 austerity measures (bundled Beatty & Fothergill exposure)
- Outcome: UKIP voting / Brexit support (POLITICAL, not employment)
- Identification: District-level exposure to ALL welfare reforms, not CTS-specific
- **Our delta:** We isolate CTS scheme variation specifically, study EMPLOYMENT outcomes (not voting), and use modern staggered DiD (not cross-sectional OLS)

### Adam, Joyce, Pope (2019, IFS Report)
- Direct study of CTS localisation employment effects
- Found null employment result using cross-sectional regression
- No panel structure, no event-study, no modern DiD
- **Our delta:** Monthly panel 2008-2023, event-study design, CS-DiD, mechanism chain (employment + arrears + collection), longer post-period, HonestDiD sensitivity

### Beatty & Fothergill (2013, CRESR)
- Simulated per-capita welfare losses by district for all coalition reforms including CTB abolition
- Descriptive/simulation only, no causal inference
- **Our delta:** Causal identification of employment effects using scheme-level variation

---

## Selection Decision (Required)

- **Selected idea title:** The Price of Austerity: Council Tax Support Localisation and Low-Income Employment
- **Why this is not duplicative:** No peer-reviewed journal paper uses modern causal inference to study CTS localisation → employment. Fetzer (2019) bundles CTS with other reforms for political outcomes. IFS (2019) uses only cross-sectional regression.
- **Specific contribution delta:** First panel event-study exploiting heterogeneous CTS scheme adoption across 326 English LAs to estimate employment effects of benefit conditionality, with a mechanism battery (arrears, collection rates) distinguishing work incentive from financial distress channels.
- **Approval:** [x] Proceed  [ ] Pivot  [ ] Restart discovery
