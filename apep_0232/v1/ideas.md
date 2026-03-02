# Research Ideas

## Idea 1: The Geography of Monetary Transmission — Household Liquidity and Regional Impulse Responses

**Policy:** Federal Reserve monetary policy (interest rate changes, 1994–2020)
**Outcome:** State-level nonfarm employment (FRED, monthly, 50 states), state GDP (BEA, annual), state personal income (BEA, quarterly)
**Identification:** Local projections à la Jordà (2005) with Bu-Rogers-Wu (2021) high-frequency monetary policy shocks interacted with pre-determined state-level hand-to-mouth (HtM) share. Time and state fixed effects absorb level effects; identification comes from differential response of high- vs low-HtM states to the same national monetary shock. This is the Nakamura-Steinsson cross-regional approach applied to monetary transmission with HANK heterogeneity.

**Why it's novel:**
- **First cross-state empirical test of the core HANK transmission prediction.** Kaplan, Moll, Violante (2018) derive that monetary policy works primarily through indirect (labor income) channels amplified by HtM households, but this has never been tested with cross-regional identification.
- **Distinct from the Regional Keynesian Cross** (Auclert et al.): That paper uses county MPCs and non-tradable employment shares as sufficient statistics. We use state-level HtM household shares directly, testing a different (and more fundamental) HANK mechanism — the MPC channel rather than the trade channel.
- **Bridges two literatures:** Nakamura-Steinsson regional macro identification + HANK heterogeneous agents theory.
- **Multiple HANK predictions testable:** (1) Higher HtM → larger employment responses (amplification), (2) Asymmetry in tightening vs easing, (3) The HtM channel should operate through labor income (indirect) not asset prices (direct).

**Feasibility check:**
- BRW monetary shock series: Downloaded from Fed website, monthly 1994–2020 ✓
- State employment: FRED, monthly, 50 states, 1990–2025 ✓
- State poverty rate (HtM proxy): FRED, annual, 1989–2024 ✓
- State GDP: BEA SAGDP, annual, 2000–2023 ✓
- State personal income: BEA SQINC, quarterly ✓
- Sample: ~15,600 state-month observations (50 states × 312 months)

**Theoretical framework:** Simple two-region HANK model with HtM and Ricardian households. Derive comparative static: ∂(employment response)/∂(HtM share) > 0. Map cross-state estimate to aggregate monetary multiplier using Nakamura-Steinsson (2020) PE-to-GE framework.


## Idea 2: Fiscal Transfers and the HANK Multiplier — Cross-State Evidence from Federal Transfer Shocks

**Policy:** Federal fiscal transfer payments to states (UI, SNAP, SSI, EITC, Medicaid, Social Security — 44 BEA categories)
**Outcome:** State GDP (BEA, annual), state employment (FRED, annual), state personal income (BEA)
**Identification:** Bartik shift-share instrumental variable. "Shift" = national changes in each transfer category. "Share" = pre-determined state exposure to each category (measured 5 years prior). Instrument predicts state-level transfer changes driven by federal policy/national conditions, not local economic shocks. Interact predicted transfers with state HtM share to test HANK amplification.

**Why it's novel:**
- **Nakamura-Steinsson (2014) estimated purchase multipliers; we estimate transfer multipliers.** HANK theory predicts transfer multipliers depend on recipient HtM share — a prediction their framework cannot test.
- **Di Maggio & Kermani (2016) tested UI only.** We use the FULL transfer basket (44 categories), allowing decomposition by progressivity and recipient population.
- **First Bartik-based test of the HANK fiscal multiplier cross-sectionally.**

**Feasibility check:**
- BEA SAINC35: 44 transfer categories, all 50 states, 2000–2023 ✓ (API tested)
- BEA SAGDP: State GDP, 2000–2023 ✓
- FRED: State employment, annual ✓
- FRED: State poverty rates, 1989–2024 ✓
- Sample: ~1,200 state-year observations (50 states × 24 years)

**Concern:** Annual frequency limits power. But 44 transfer categories provide rich Bartik variation. Can use multiple Bartik instruments (by transfer type) and test overidentifying restrictions.


## Idea 3: Asymmetric Monetary Transmission — Does Tightening Hurt More Than Easing Helps?

**Policy:** Fed monetary tightening vs easing episodes (1994–2020)
**Outcome:** State employment and income (FRED/BEA)
**Identification:** Separate local projections for positive and negative BRW shocks × HtM share. HANK predicts asymmetry: tightening hurts high-HtM states disproportionately more than easing helps them, because HtM households cannot smooth negative income shocks.

**Why it's novel:**
- Tests a second-order HANK prediction about state-dependence of monetary transmission
- Most macro estimates are linear; this tests the nonlinearity that HANK uniquely predicts
- Policy-relevant: if tightening is more costly in high-HtM regions, the Fed faces a distributional tradeoff

**Feasibility check:** Same data as Idea 1. Subset analysis by shock sign.

**Concern:** Splitting the sample reduces power. Need enough tightening and easing episodes.


## Idea 4: The Forward Guidance Puzzle at the Regional Level

**Policy:** Fed forward guidance (medium-term rate surprises) vs conventional rate surprises
**Outcome:** State employment (FRED, monthly)
**Identification:** Decompose monetary shocks into "target" and "path" components (Gürkaynak, Sack, Swanson 2005). HANK predicts forward guidance should be less effective than conventional policy (the FG puzzle), and the attenuation should be STRONGER in high-HtM states (because HtM households don't respond to future rate expectations).

**Why it's novel:**
- Nobody has tested the forward guidance puzzle cross-regionally
- Provides the first micro-founded empirical evidence on WHY forward guidance is less powerful
- Could resolve the FG puzzle debate empirically

**Feasibility check:**
- Gürkaynak-Sack-Swanson factor data: Available from Fed/NBER, but may need updating
- Monthly state employment: FRED ✓
- HtM proxy: FRED ✓

**Concern:** Decomposing shocks introduces measurement error. The path factor is noisier than the target factor. May lack power for the triple interaction (path × HtM × horizon).


## Ranking Recommendation

**Pursue Idea 1** (Monetary Transmission × HtM) as the primary paper, incorporating elements of **Idea 2** (Fiscal Transfers) as a secondary test and **Idea 3** (Asymmetry) as a robustness exercise. This creates a comprehensive paper testing multiple HANK predictions with two independent identification strategies (monetary shocks + fiscal transfer Bartik).

**Skip Idea 4** — too ambitious for a single paper and data limitations are binding.
